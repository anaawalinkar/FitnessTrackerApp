import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool workoutReminders = true;
  bool calorieReminders = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);
  double dailyCalorieGoal = 2000.0;
  int dailyWorkoutGoal = 30;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Goals Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goals',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // Calorie Goal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Calorie Goal: ${dailyCalorieGoal.toInt()} cal'),
                        Slider(
                          value: dailyCalorieGoal,
                          min: 1000,
                          max: 5000,
                          divisions: 40,
                          label: dailyCalorieGoal.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              dailyCalorieGoal = value;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Workout Goal
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Workout Goal: $dailyWorkoutGoal minutes'),
                        Slider(
                          value: dailyWorkoutGoal.toDouble(),
                          min: 10,
                          max: 120,
                          divisions: 11,
                          label: dailyWorkoutGoal.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              dailyWorkoutGoal = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Notifications Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // Workout Reminders
                    SwitchListTile(
                      title: Text('Workout Reminders'),
                      subtitle: Text('Daily reminders for workouts'),
                      value: workoutReminders,
                      onChanged: (bool value) {
                        setState(() {
                          workoutReminders = value;
                        });
                      },
                    ),
                    
                    // Calorie Reminders
                    SwitchListTile(
                      title: Text('Calorie Logging Reminders'),
                      subtitle: Text('Reminders to log your meals'),
                      value: calorieReminders,
                      onChanged: (bool value) {
                        setState(() {
                          calorieReminders = value;
                        });
                      },
                    ),
                    
                    // Reminder Time
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Reminder Time'),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // App Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    ListTile(
                      leading: Icon(Icons.palette),
                      title: Text('Theme'),
                      subtitle: Text('Change app appearance'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Theme settings would go here
                      },
                    ),
                    
                    ListTile(
                      leading: Icon(Icons.security),
                      title: Text('Privacy'),
                      subtitle: Text('Manage your data privacy'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Privacy settings would go here
                      },
                    ),
                    
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help & Support'),
                      subtitle: Text('Get help using the app'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Help section would go here
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Save Button
            ElevatedButton(
              onPressed: () {
                // Save settings logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings saved successfully!')),
                );
              },
              child: Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}