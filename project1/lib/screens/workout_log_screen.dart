import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'progress_summary_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> workouts = [];
  
  TextEditingController exerciseController = TextEditingController();
  TextEditingController setsController = TextEditingController();
  TextEditingController repsController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workoutsList = await _databaseService.getWorkouts();
    setState(() {
      workouts = workoutsList;
    });
  }

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
            
            if (workouts.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout Summary',
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
                        final workout = workouts[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.fitness_center, color: Colors.green),
                            title: Text(workout['exercise']),
                            subtitle: Text('Sets: ${workout['sets']} | Reps: ${workout['reps']} | ${workout['duration']} min'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeWorkout(workout['id']),
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

Future<void> _addWorkout() async {
  // Basic validation
  if (exerciseController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter an exercise name')),
    );
    return;
  }

  try {
    print('Adding workout...');
    
    await _databaseService.insertWorkout(
      exerciseController.text.trim(),
      setsController.text.trim(),
      repsController.text.trim(),
      durationController.text.trim(),
    );
    
    // Reload the workouts
    await _loadWorkouts();
    
    // Clear the form
    exerciseController.clear();
    setsController.clear();
    repsController.clear();
    durationController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout added successfully!')),
    );
    
  } catch (e) {
    print('Error adding workout: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding workout. Please try again.')),
    );
  }
}

  Future<void> _removeWorkout(int id) async {
    await _databaseService.deleteWorkout(id);
    await _loadWorkouts(); // Reload from database
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout deleted!')),
    );
  }

  String _calculateTotalDuration() {
    int total = 0;
    for (var workout in workouts) {
      total += int.tryParse(workout['duration'] ?? '0') ?? 0;
    }
    return total.toString();
  }
}