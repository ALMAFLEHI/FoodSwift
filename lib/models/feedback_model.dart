import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Added import

class FeedbackModel {
  final String message;
  final String type;
  final String userId;
  final DateTime timestamp;

  FeedbackModel({
    required this.message,
    required this.type,
    required this.userId,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type,
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}
