class MealEntry {
  final int? id;
  final String foodItem;
  final String calories;
  final String mealType;
  final DateTime? dateCreated;

  MealEntry({
    this.id,
    required this.foodItem,
    required this.calories,
    required this.mealType,
    this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_item': foodItem,
      'calories': calories,
      'meal_type': mealType,
      'date_created': dateCreated?.toIso8601String(),
    };
  }

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'],
      foodItem: map['food_item'],
      calories: map['calories'],
      mealType: map['meal_type'],
      dateCreated: map['date_created'] != null 
          ? DateTime.parse(map['date_created'])
          : null,
    );
  }
}