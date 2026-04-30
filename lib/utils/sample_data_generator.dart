import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/feedback_model.dart';
import '../models/menu_item_model.dart';
import '../models/complaint_model.dart';

class SampleDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> generateAllSampleData() async {
    print('Starting sample data generation...');

    await Future.wait([
      generateUsers(),
      generateMenuItems(),
      generateOrders(),
      generateFeedbacks(),
      generateComplaints(),
    ]);

    print('Sample data generation completed!');
  }

  // Generate sample users
  static Future<void> generateUsers() async {
    final users = [
      UserModel(email: 'student1@example.com', role: 'student'),
      UserModel(email: 'student2@example.com', role: 'student'),
      UserModel(email: 'staff1@example.com', role: 'staff'),
      UserModel(email: 'admin@foodswift.com', role: 'admin'),
    ];

    for (var user in users) {
      await _firestore.collection('users').add(user.toMap());
    }
    print('Generated ${users.length} sample users');
  }

  // Generate sample menu items
  static Future<void> generateMenuItems() async {
    final menuItems = [
      MenuItemModel(
        id: 'item1',
        dishName: 'Chicken Rice',
        restaurantId: 'rest1',
        restaurantName: 'Asian Delights',
        foodType: 'Main Course',
        imageUrl: '',
        price: 5.50,
      ),
      MenuItemModel(
        id: 'item2',
        dishName: 'Vegetable Noodles',
        restaurantId: 'rest1',
        restaurantName: 'Asian Delights',
        foodType: 'Main Course',
        imageUrl: '',
        price: 4.50,
      ),
      MenuItemModel(
        id: 'item3',
        dishName: 'Fish & Chips',
        restaurantId: 'rest2',
        restaurantName: 'Western Grill',
        foodType: 'Western',
        imageUrl: '',
        price: 8.00,
      ),
    ];

    for (var item in menuItems) {
      await _firestore.collection('menuItems').doc(item.id).set({
        'id': item.id,
        'dishName': item.dishName,
        'restaurantId': item.restaurantId,
        'restaurantName': item.restaurantName,
        'foodType': item.foodType,
        'imageUrl': item.imageUrl,
        'price': item.price,
      });
    }
    print('Generated ${menuItems.length} sample menu items');
  }

  // Generate sample orders
  static Future<void> generateOrders() async {
    final orders = [
      OrderModel(
        dishName: 'Chicken Rice',
        foodType: 'Main Course',
        imageUrl: '',
        notes: 'Extra spicy',
        portionSize: 'Regular',
        price: 5.50,
        restaurantId: 'rest1',
        restaurantName: 'Asian Delights',
        spiceLevel: 'Medium',
        status: 'completed',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        userId: 'student1',
      ),
      OrderModel(
        dishName: 'Vegetable Noodles',
        foodType: 'Main Course',
        imageUrl: '',
        notes: 'No onions',
        portionSize: 'Large',
        price: 4.50,
        restaurantId: 'rest1',
        restaurantName: 'Asian Delights',
        spiceLevel: 'Mild',
        status: 'preparing',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        userId: 'student2',
      ),
    ];

    for (var order in orders) {
      await _firestore.collection('orders').add({
        'dishName': order.dishName,
        'foodType': order.foodType,
        'imageUrl': order.imageUrl,
        'notes': order.notes,
        'portionSize': order.portionSize,
        'price': order.price,
        'restaurantId': order.restaurantId,
        'restaurantName': order.restaurantName,
        'spiceLevel': order.spiceLevel,
        'status': order.status,
        'timestamp': Timestamp.fromDate(order.timestamp),
        'userId': order.userId,
      });
    }
    print('Generated ${orders.length} sample orders');
  }

  // Generate sample feedbacks
  static Future<void> generateFeedbacks() async {
    final feedbacks = [
      FeedbackModel(
        message: 'Great food!',
        type: 'positive',
        userId: 'student1',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      FeedbackModel(
        message: 'Delivery was late',
        type: 'negative',
        userId: 'student2',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];

    for (var feedback in feedbacks) {
      await _firestore.collection('feedbacks').add({
        'message': feedback.message,
        'type': feedback.type,
        'userId': feedback.userId,
        'timestamp': Timestamp.fromDate(feedback.timestamp),
      });
    }
    print('Generated ${feedbacks.length} sample feedbacks');
  }

  // Generate sample complaints
  static Future<void> generateComplaints() async {
    final complaints = [
      ComplaintModel(
        complaintId: 'complaint1',
        userId: 'student1',
        userName: 'John Doe',
        orderId: 'order1',
        subject: 'Wrong order delivered',
        description: 'I received the wrong order items',
        status: 'pending',
        priority: 'high',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        adminResponse: null,
        resolvedAt: null,
      ),
      ComplaintModel(
        complaintId: 'complaint2',
        userId: 'student2',
        userName: 'Jane Smith',
        orderId: 'order2',
        subject: 'Food quality issue',
        description: 'The food was cold and poorly prepared',
        status: 'resolved',
        priority: 'medium',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        adminResponse: 'We apologize and will issue a refund',
        resolvedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    for (var complaint in complaints) {
      await _firestore.collection('complaints').doc(complaint.complaintId).set({
        'complaintId': complaint.complaintId,
        'userId': complaint.userId,
        'userName': complaint.userName,
        'orderId': complaint.orderId,
        'subject': complaint.subject,
        'description': complaint.description,
        'status': complaint.status,
        'priority': complaint.priority,
        'createdAt': Timestamp.fromDate(complaint.createdAt),
        'adminResponse': complaint.adminResponse,
        'resolvedAt': complaint.resolvedAt != null
            ? Timestamp.fromDate(complaint.resolvedAt!)
            : null,
      });
    }
    print('Generated ${complaints.length} sample complaints');
  }
}
