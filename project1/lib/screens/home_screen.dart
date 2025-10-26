import 'package:flutter/material.dart';
import 'workout_log_screen.dart';
import 'calorie_tracker_screen.dart';
import 'progress_summary_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 50, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'Welcome to Fitness Tracker',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Track your workouts, calories, and progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
            
            // Navigation Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    'Workout Log',
                    Icons.directions_run,
                    Colors.green,
                    WorkoutLogScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    'Calorie Tracker',
                    Icons.restaurant,
                    Colors.orange,
                    CalorieTrackerScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    'Progress Summary',
                    Icons.assessment,
                    Colors.purple,
                    ProgressSummaryScreen(),
                  ),
                  _buildFeatureCard(
                    context,
                    'Settings',
                    Icons.settings,
                    Colors.grey,
                    SettingsScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}