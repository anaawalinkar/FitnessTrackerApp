import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_entry.dart';
import '../models/meal_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    //workout table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise TEXT NOT NULL,
        sets TEXT NOT NULL,
        reps TEXT NOT NULL,
        duration TEXT NOT NULL,
        date_created TEXT NOT NULL
      )
    ''');

    //meals table
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_item TEXT NOT NULL,
        calories TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        date_created TEXT NOT NULL
      )
    ''');

    //user settings table
    await db.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        daily_calorie_goal REAL DEFAULT 2000,
        daily_workout_goal INTEGER DEFAULT 30,
        workout_reminders INTEGER DEFAULT 1,
        calorie_reminders INTEGER DEFAULT 0,
        reminder_time TEXT DEFAULT '08:00'
      )
    ''');

    //insert default settings
    await db.insert('user_settings', {
      'id': 1,
      'daily_calorie_goal': 2000,
      'daily_workout_goal': 30,
      'workout_reminders': 1,
      'calorie_reminders': 0,
      'reminder_time': '08:00'
    });
  }

  //workout Methods
  Future<int> insertWorkout(WorkoutEntry workout) async {
    final db = await database;
    return await db.insert('workouts', {
      'exercise': workout.exercise,
      'sets': workout.sets,
      'reps': workout.reps,
      'duration': workout.duration,
      'date_created': DateTime.now().toIso8601String(),
    });
  }

  Future<List<WorkoutEntry>> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      orderBy: 'date_created DESC',
    );
    
    return List.generate(maps.length, (i) {
      return WorkoutEntry(
        exercise: maps[i]['exercise'],
        sets: maps[i]['sets'],
        reps: maps[i]['reps'],
        duration: maps[i]['duration'],
      );
    });
  }

  Future<int> deleteWorkout(int id) async {
    final db = await database;
    return await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getWorkoutStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        COUNT(*) as total_workouts,
        SUM(CAST(duration as INTEGER)) as total_duration,
        DATE(date_created) as workout_date
      FROM workouts 
      GROUP BY DATE(date_created)
      ORDER BY workout_date DESC
      LIMIT 30
    ''');
  }

  //meal Methods
  Future<int> insertMeal(MealEntry meal) async {
    final db = await database;
    return await db.insert('meals', {
      'food_item': meal.foodItem,
      'calories': meal.calories,
      'meal_type': meal.mealType,
      'date_created': DateTime.now().toIso8601String(),
    });
  }

  Future<List<MealEntry>> getMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'meals',
      orderBy: 'date_created DESC',
    );
    
    return List.generate(maps.length, (i) {
      return MealEntry(
        foodItem: maps[i]['food_item'],
        calories: maps[i]['calories'],
        mealType: maps[i]['meal_type'],
      );
    });
  }

  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCalorieStats() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        SUM(CAST(calories as REAL)) as total_calories,
        DATE(date_created) as calorie_date
      FROM meals 
      GROUP BY DATE(date_created)
      ORDER BY calorie_date DESC
      LIMIT 30
    ''');
  }

  //settings Methods
  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_settings');
    return maps.first;
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final db = await database;
    settings['id'] = 1;
    return await db.update(
      'user_settings',
      settings,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  //close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}