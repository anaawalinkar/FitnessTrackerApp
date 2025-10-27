import 'package:flutter/material.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  
  bool workoutReminders = true;
  bool calorieReminders = false;
  TimeOfDay selectedTime = TimeOfDay(hour: 8, minute: 0);
  double dailyCalorieGoal = 2000.0;
  int dailyWorkoutGoal = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _databaseService.getSettings();
    setState(() {
      dailyCalorieGoal = (settings['daily_calorie_goal'] ?? 2000).toDouble();
      dailyWorkoutGoal = settings['daily_workout_goal'] ?? 30;
      workoutReminders = settings['workout_reminders'] == 1;
      calorieReminders = settings['calorie_reminders'] == 1;
      
      //parse reminder time
      final timeString = settings['reminder_time'] ?? '08:00';
      final parts = timeString.split(':');
      selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    });
  }

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

  Future<void> _saveSettings() async {
    final settings = {
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_workout_goal': dailyWorkoutGoal,
      'workout_reminders': workoutReminders ? 1 : 0,
      'calorie_reminders': calorieReminders ? 1 : 0,
      'reminder_time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
    };

    await _databaseService.updateSettings(settings);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved successfully!')),
    );
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
            
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _saveSettings,
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