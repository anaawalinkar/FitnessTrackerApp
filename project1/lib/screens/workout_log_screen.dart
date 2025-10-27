import 'package:flutter/material.dart';
import '/models/workout_entry.dart';
import '../services/database_service.dart';
import 'progress_summary_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final _formKey = GlobalKey<FormState>();
  List<WorkoutEntry> workouts = [];
  
  TextEditingController exerciseController = TextEditingController();
  TextEditingController setsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProgressSummaryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Add New Exercise',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: exerciseController,
                        decoration: InputDecoration(
                          labelText: 'Exercise Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter exercise name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: setsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Sets',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: repsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Reps',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: durationController,
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addWorkout,
                        child: Text('Add Exercise'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Current Session Summary
            if (workouts.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Session Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Total Exercises: ${workouts.length}'),
                      Text('Total Duration: ${_calculateTotalDuration()} minutes'),
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
            
            // Workout List
            Expanded(
              child: workouts.isEmpty
                  ? Center(
                      child: Text(
                        'No workouts logged yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.fitness_center, color: Colors.green),
                            title: Text(workouts[index].exercise),
                            subtitle: Text('Sets: ${workouts[index].sets} | Reps: ${workouts[index].reps} | ${workouts[index].duration} min'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeWorkout(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _addWorkout() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        workouts.add(WorkoutEntry(
          exercise: exerciseController.text,
          sets: setsController.text,
          reps: repsController.text,
          duration: durationController.text,
        ));
        
        // Clear form
        exerciseController.clear();
        setsController.clear();
        repsController.clear();
        durationController.clear();
      });
    }
  }

  void _removeWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });
  }

  String _calculateTotalDuration() {
    int total = 0;
    for (var workout in workouts) {
      total += int.tryParse(workout.duration) ?? 0;
    }
    return total.toString();
  }
}

class WorkoutEntry {
  final String exercise;
  final String sets;
  final String reps;
  final String duration;

  WorkoutEntry({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.duration,
  });
}