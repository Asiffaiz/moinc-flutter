import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime reminderDate;
  final DateTime createdAt;
  final ReminderType type;
  final bool isCompleted;
  final bool isImportant;

  const ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.reminderDate,
    required this.createdAt,
    required this.type,
    this.isCompleted = false,
    this.isImportant = false,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? reminderDate,
    DateTime? createdAt,
    ReminderType? type,
    bool? isCompleted,
    bool? isImportant,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reminderDate: DateTime.parse(json['reminderDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == 'ReminderType.${json['type']}',
        orElse: () => ReminderType.general,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminderDate': reminderDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
    };
  }

  @override
  List<Object> get props => [
    id,
    title,
    description,
    reminderDate,
    createdAt,
    type,
    isCompleted,
    isImportant,
  ];
}

enum ReminderType {
  birthday,
  meeting,
  task,
  general,
  anniversary,
  medication,
  payment,
}
