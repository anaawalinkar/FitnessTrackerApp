import 'package:flutter/material.dart';

class CalorieTrackerScreen extends StatefulWidget {
  @override
  _CalorieTrackerScreenState createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  List<MealEntry> meals = [];
  double dailyCalorieGoal = 2000.0;
  
  TextEditingController foodController = TextEditingController();
  TextEditingController caloriesController = TextEditingController();
  TextEditingController mealTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            // Calorie Summary
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
            
            // Input Form
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
            
            // Meal List
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
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.restaurant, color: Colors.orange),
                            title: Text(meals[index].foodItem),
                            subtitle: Text('${meals[index].mealType} - ${meals[index].calories} cal'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeMeal(index),
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

  void _addMeal() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        meals.add(MealEntry(
          foodItem: foodController.text,
          calories: caloriesController.text,
          mealType: mealTypeController.text.isEmpty ? 'Meal' : mealTypeController.text,
        ));
        
        // Clear form
        foodController.clear();
        caloriesController.clear();
        mealTypeController.clear();
      });
    }
  }

  void _removeMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
  }

  double _calculateTotalCalories() {
    double total = 0;
    for (var meal in meals) {
      total += double.tryParse(meal.calories) ?? 0;
    }
    return total;
  }
}

class MealEntry {
  final String foodItem;
  final String calories;
  final String mealType;

  MealEntry({
    required this.foodItem,
    required this.calories,
    required this.mealType,
  });
}