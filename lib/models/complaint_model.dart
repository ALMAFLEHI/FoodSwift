import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String complaintId;
  final String userId;
  final String userName;
  final String orderId;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final DateTime createdAt;
  final String? adminResponse;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.complaintId,
    required this.userId,
    required this.userName,
    required this.orderId,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.adminResponse,
    this.resolvedAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      complaintId: map['complaintId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      orderId: map['orderId'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'normal',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      adminResponse: map['adminResponse'],
      resolvedAt: map['resolvedAt'] != null
          ? (map['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }
}
