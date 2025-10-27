class WorkoutEntry {
  final int? id;
  final String exercise;
  final String sets;
  final String reps;
  final String duration;
  final DateTime? dateCreated;

  WorkoutEntry({
    this.id,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.duration,
    this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'duration': duration,
      'date_created': dateCreated?.toIso8601String(),
    };
  }

  factory WorkoutEntry.fromMap(Map<String, dynamic> map) {
    return WorkoutEntry(
      id: map['id'],
      exercise: map['exercise'],
      sets: map['sets'],
      reps: map['reps'],
      duration: map['duration'],
      dateCreated: map['date_created'] != null 
          ? DateTime.parse(map['date_created'])
          : null,
    );
  }
}