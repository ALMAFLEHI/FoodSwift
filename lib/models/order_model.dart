import 'package:cloud_firestore/cloud_firestore.dart'; // FIX: Added import

class OrderModel {
  final String dishName;
  final String foodType;
  final String imageUrl;
  final String notes;
  final String portionSize;
  final double price;
  final String restaurantId;
  final String restaurantName;
  final String spiceLevel;
  final String status;
  final DateTime timestamp;
  final String userId;

  OrderModel({
    required this.dishName,
    required this.foodType,
    required this.imageUrl,
    required this.notes,
    required this.portionSize,
    required this.price,
    required this.restaurantId,
    required this.restaurantName,
    required this.spiceLevel,
    required this.status,
    required this.timestamp,
    required this.userId,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      dishName: map['dishName'] ?? '',
      foodType: map['foodType'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      notes: map['notes'] ?? '',
      portionSize: map['portionSize'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      restaurantId: map['restaurantId'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      spiceLevel: map['spiceLevel'] ?? '',
      status: map['status'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dishName': dishName,
      'foodType': foodType,
      'imageUrl': imageUrl,
      'notes': notes,
      'portionSize': portionSize,
      'price': price,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'spiceLevel': spiceLevel,
      'status': status,
      'timestamp': timestamp,
      'userId': userId,
    };
  }
}
