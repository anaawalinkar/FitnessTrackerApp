import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'calorie_tracker_screen.dart';

class ProgressSummaryScreen extends StatefulWidget {
  @override
  _ProgressSummaryScreenState createState() => _ProgressSummaryScreenState();
}

class _ProgressSummaryScreenState extends State<ProgressSummaryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String selectedTimeframe = 'Weekly';
  List<Map<String, dynamic>> workoutStats = [];
  List<Map<String, dynamic>> calorieStats = [];
  List<Map<String, dynamic>> workouts = [];
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final workoutsData = await _databaseService.getWorkouts();
    final mealsData = await _databaseService.getMeals();
    
    setState(() {
      workouts = workoutsData;
      meals = mealsData;
      workoutStats = _calculateWorkoutStats(workoutsData);
      calorieStats = _calculateCalorieStats(mealsData);
    });
  }

  List<Map<String, dynamic>> _calculateWorkoutStats(List<Map<String, dynamic>> workouts) {
    //group workouts by date and calculate totals
    Map<String, Map<String, dynamic>> statsByDate = {};
    
    for (var workout in workouts) {
      String date = workout['date_created']?.split('T')[0] ?? 'Unknown';
      if (!statsByDate.containsKey(date)) {
        statsByDate[date] = {
          'date': date,
          'total_workouts': 0,
          'total_duration': 0,
          'exercises': <String>[],
        };
      }
      
      statsByDate[date]!['total_workouts'] = statsByDate[date]!['total_workouts'] + 1;
      statsByDate[date]!['total_duration'] = statsByDate[date]!['total_duration'] + 
          (int.tryParse(workout['duration'] ?? '0') ?? 0);
      
      if (!statsByDate[date]!['exercises'].contains(workout['exercise'])) {
        statsByDate[date]!['exercises'].add(workout['exercise']);
      }
    }
    
    return statsByDate.values.toList();
  }

  List<Map<String, dynamic>> _calculateCalorieStats(List<Map<String, dynamic>> meals) {
    //group meals by date and calculate totals
    Map<String, Map<String, dynamic>> statsByDate = {};
    
    for (var meal in meals) {
      String date = meal['date_created']?.split('T')[0] ?? 'Unknown';
      if (!statsByDate.containsKey(date)) {
        statsByDate[date] = {
          'date': date,
          'total_calories': 0.0,
          'meal_count': 0,
        };
      }
      
      statsByDate[date]!['total_calories'] = statsByDate[date]!['total_calories'] + 
          (double.tryParse(meal['calories'] ?? '0') ?? 0);
      statsByDate[date]!['meal_count'] = statsByDate[date]!['meal_count'] + 1;
    }
    
    return statsByDate.values.toList();
  }

  Map<String, dynamic> _getSummaryStats() {
    int totalWorkouts = workouts.length;
    int totalDuration = workouts.fold(0, (sum, workout) => 
        sum + (int.tryParse(workout['duration'] ?? '0') ?? 0));
    double totalCalories = meals.fold(0.0, (sum, meal) => 
        sum + (double.tryParse(meal['calories'] ?? '0') ?? 0));
    
    // Calculate unique exercise types
    Set<String> uniqueExercises = {};
    for (var workout in workouts) {
      uniqueExercises.add(workout['exercise']);
    }
    
    return {
      'totalWorkouts': totalWorkouts,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories.round(),
      'uniqueExercises': uniqueExercises.length,
      'totalMeals': meals.length,
    };
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _getSummaryStats();
    final recentWorkouts = workouts.take(5).toList();
    final recentMeals = meals.take(5).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalorieTrackerScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeframeButton('Weekly'),
                    _buildTimeframeButton('Monthly'),
                    _buildTimeframeButton('All Time'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            //overall stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Overall Progress - $selectedTimeframe',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Workouts', '${summary['totalWorkouts']}', 
                            Icons.directions_run, Colors.green),
                        _buildStatCard('Exercises', '${summary['uniqueExercises']}', 
                            Icons.fitness_center, Colors.blue),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Duration', _formatDuration(summary['totalDuration']), 
                            Icons.timer, Colors.orange),
                        _buildStatCard('Calories', '${summary['totalCalories']}', 
                            Icons.local_fire_department, Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            //recent activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Workouts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    recentWorkouts.isEmpty
                        ? Text(
                            'No workouts yet. Start logging your exercises!',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          )
                        : Column(
                            children: recentWorkouts.map((workout) {
                              return ListTile(
                                leading: Icon(Icons.fitness_center, color: Colors.green, size: 20),
                                title: Text(workout['exercise'] ?? 'Unknown'),
                                subtitle: Text('${workout['sets']} sets × ${workout['reps']} reps • ${workout['duration']} min'),
                                dense: true,
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            //recent meals
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Meals',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    recentMeals.isEmpty
                        ? Text(
                            'No meals logged yet. Start tracking your nutrition!',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          )
                        : Column(
                            children: recentMeals.map((meal) {
                              return ListTile(
                                leading: Icon(Icons.restaurant, color: Colors.orange, size: 20),
                                title: Text(meal['food_item'] ?? 'Unknown'),
                                subtitle: Text('${meal['meal_type']} • ${meal['calories']} cal'),
                                dense: true,
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            //daily progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Averages',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    _buildDailyAverageStats(summary),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            //progress insights
            if (workouts.isNotEmpty || meals.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Insights',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      _buildProgressInsights(summary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeButton(String timeframe) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedTimeframe = timeframe;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTimeframe == timeframe ? Colors.purple : Colors.grey[300],
        foregroundColor: selectedTimeframe == timeframe ? Colors.white : Colors.black,
      ),
      child: Text(timeframe),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDailyAverageStats(Map<String, dynamic> summary) {
    int totalDays = workoutStats.length;
    
    if (totalDays == 0) {
      return Text(
        'No data available yet. Keep logging your activities!',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    
    double avgWorkoutsPerDay = summary['totalWorkouts'] / totalDays;
    double avgDurationPerDay = summary['totalDuration'] / totalDays;
    double avgCaloriesPerDay = summary['totalCalories'] / totalDays;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workouts per day:'),
            Text('${avgWorkoutsPerDay.toStringAsFixed(1)}'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Duration per day:'),
            Text('${avgDurationPerDay.toStringAsFixed(0)} min'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Calories per day:'),
            Text('${avgCaloriesPerDay.toStringAsFixed(0)} cal'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tracking days:'),
            Text('$totalDays days'),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressInsights(Map<String, dynamic> summary) {
    List<Widget> insights = [];
    
    if (summary['totalWorkouts'] == 0) {
      insights.add(Text(
        '💪 Start your first workout to see insights!',
        style: TextStyle(color: Colors.blue),
      ));
    } else if (summary['totalWorkouts'] < 5) {
      insights.add(Text(
        '🔥 Great start! Keep going to build momentum.',
        style: TextStyle(color: Colors.green),
      ));
    } else {
      insights.add(Text(
        '🚀 Amazing consistency! You\'re doing great!',
        style: TextStyle(color: Colors.green),
      ));
    }
    
    if (summary['uniqueExercises'] >= 3) {
      insights.add(SizedBox(height: 8));
      insights.add(Text(
        '🎯 Good exercise variety!',
        style: TextStyle(color: Colors.orange),
      ));
    }
    
    if (summary['totalDuration'] > 60) {
      insights.add(SizedBox(height: 8));
      insights.add(Text(
        '⏱️ Over 1 hour of total workout time!',
        style: TextStyle(color: Colors.purple),
      ));
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: insights,
    );
  }
}