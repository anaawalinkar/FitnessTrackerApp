class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  //lists to store
  List<Map<String, dynamic>> workouts = [];
  List<Map<String, dynamic>> meals = [];

  //workout methods
  Future<int> insertWorkout(String exercise, String sets, String reps, String duration) async {
    print('=== INSERT WORKOUT CALLED ===');
    print('Exercise: $exercise');
    print('Sets: $sets');
    print('Reps: $reps');
    print('Duration: $duration');
    
    try {
      //workout object
      Map<String, dynamic> workout = {
        'id': workouts.length + 1,
        'exercise': exercise,
        'sets': sets,
        'reps': reps,
        'duration': duration,
        'date_created': '2024-01-01',
      };
      
      workouts.add(workout);
      print('Workout added successfully! Total workouts: ${workouts.length}');
      return 1;
    } catch (e) {
      print('ERROR in insertWorkout: $e');
      print('Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    print('=== GET WORKOUTS CALLED ===');
    print('Returning ${workouts.length} workouts');
    return workouts;
  }

  Future<int> deleteWorkout(int id) async {
    workouts.removeWhere((workout) => workout['id'] == id);
    return 1;
  }

 //meal methods
  Future<int> insertMeal(String foodItem, String calories, String mealType) async {
    print('=== INSERT MEAL CALLED ===');
    print('Food: $foodItem');
    print('Calories: $calories');
    print('Meal Type: $mealType');
    
    try {
      Map<String, dynamic> meal = {
        'id': meals.length + 1,
        'food_item': foodItem,
        'calories': calories,
        'meal_type': mealType,
        'date_created': '2024-01-01',
      };
      
      meals.add(meal);
      print('Meal added successfully! Total meals: ${meals.length}');
      return 1;
    } catch (e) {
      print('ERROR in insertMeal: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    return meals;
  }

  Future<int> deleteMeal(int id) async {
    meals.removeWhere((meal) => meal['id'] == id);
    return 1;
  }


  Future<Map<String, dynamic>> getSettings() async {
    return {
      'daily_calorie_goal': 2000.0,
      'daily_workout_goal': 30,
    };
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    return 1;
  }
}