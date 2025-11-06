import 'package:equatable/equatable.dart';

class AlertModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertType type;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    AlertType? type,
    bool? isRead,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: AlertType.values.firstWhere(
        (e) => e.toString() == 'AlertType.${json['type']}',
        orElse: () => AlertType.info,
      ),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'isRead': isRead,
    };
  }

  @override
  List<Object> get props => [id, title, message, timestamp, type, isRead];
}

enum AlertType { info, warning, error, success }
