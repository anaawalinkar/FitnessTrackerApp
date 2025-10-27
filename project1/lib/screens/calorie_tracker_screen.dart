import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CalorieTrackerScreen extends StatefulWidget {
  @override
  _CalorieTrackerScreenState createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> meals = [];
  Map<String, dynamic> settings = {};
  
  TextEditingController foodController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController mealTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadMeals();
    await _loadSettings();
  }

  Future<void> _loadMeals() async {
    final mealsList = await _databaseService.getMeals();
    setState(() {
      meals = mealsList;
    });
  }

  Future<void> _loadSettings() async {
    final settingsData = await _databaseService.getSettings();
    setState(() {
      settings = settingsData;
    });
  }

  @override
  Widget build(BuildContext context) {
    double dailyCalorieGoal = (settings['daily_calorie_goal'] ?? 2000).toDouble();
    double totalCalories = _calculateTotalCalories();
    double remainingCalories = dailyCalorieGoal - totalCalories;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Daily Calorie Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCalorieInfo('Goal', '${dailyCalorieGoal.toInt()}'),
                        _buildCalorieInfo('Consumed', '${totalCalories.toInt()}'),
                        _buildCalorieInfo(
                          'Remaining', 
                          '${remainingCalories.toInt()}',
                          color: remainingCalories >= 0 ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: totalCalories / dailyCalorieGoal,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalCalories <= dailyCalorieGoal ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Add Food Entry',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: foodController,
                        decoration: InputDecoration(
                          labelText: 'Food Item',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter food item';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Calories',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter calories';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: mealTypeController,
                              decoration: InputDecoration(
                                labelText: 'Meal Type',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addMeal,
                        child: Text('Add Food'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Expanded(
              child: meals.isEmpty
                  ? Center(
                      child: Text(
                        'No meals logged yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.restaurant, color: Colors.orange),
                            title: Text(meal['food_item']),
                            subtitle: Text('${meal['meal_type']} - ${meal['calories']} cal'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeMeal(meal['id']),
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

  Widget _buildCalorieInfo(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.blue,
          ),
        ),
      ],
    );
  }

Future<void> _addMeal() async {
  if (foodController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a food item')),
    );
    return;
  }

  if (caloriesController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter calories')),
    );
    return;
  }

  try {
    print('🔄 Adding meal...');
    
    await _databaseService.insertMeal(
      foodController.text.trim(),
      caloriesController.text.trim(),
      mealTypeController.text.trim(),
    );
    
    await _loadMeals();
    
    foodController.clear();
    caloriesController.clear();
    mealTypeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Meal added successfully!')),
    );
    
  } catch (e) {
    print('❌ Error adding meal: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding meal. Please try again.')),
    );
  }
}

  Future<void> _removeMeal(int id) async {
    await _databaseService.deleteMeal(id);
    await _loadMeals(); // Reload from database
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Meal deleted!')),
    );
  }

  double _calculateTotalCalories() {
    double total = 0;
    for (var meal in meals) {
      total += double.tryParse(meal['calories'] ?? '0') ?? 0;
    }
    return total;
  }
}