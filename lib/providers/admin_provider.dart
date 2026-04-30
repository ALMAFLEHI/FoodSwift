import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/menu_item_model.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/feedback_model.dart';
import '../models/complaint_model.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dashboard Statistics
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  int _activeUsers = 0;
  double _averageRating = 0.0;
  Map<String, int> _ordersByStatus = {};
  Map<String, double> _revenueByDay = {};
  List<MenuItemModel> _popularDishes = [];

  // User Management
  List<UserModel> _users = [];
  List<UserModel> _staffUsers = [];

  // Feedback Management
  List<FeedbackModel> _feedbacks = [];

  // Menu Management
  List<MenuItemModel> _menuItems = [];
  List<Restaurant> _restaurants = [];

  // Complaint Management
  List<ComplaintModel> _complaints = [];

  bool _isLoading = false;

  // Getters
  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;
  int get activeUsers => _activeUsers;
  double get averageRating => _averageRating;
  Map<String, int> get ordersByStatus => _ordersByStatus;
  Map<String, double> get revenueByDay => _revenueByDay;
  List<MenuItemModel> get popularDishes => _popularDishes;
  List<UserModel> get users => _users;
  List<UserModel> get staffUsers => _staffUsers;
  List<FeedbackModel> get feedbacks => _feedbacks;
  List<MenuItemModel> get menuItems => _menuItems;
  List<Restaurant> get restaurants => _restaurants;
  List<ComplaintModel> get complaints => _complaints;
  bool get isLoading => _isLoading;

  // Initialize admin data
  Future<void> initializeAdminData() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      loadDashboardData(),
      loadUsers(),
      loadFeedbacks(),
      loadMenuItems(),
      loadRestaurants(),
      loadComplaints(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // Dashboard Analytics
  Future<void> loadDashboardData() async {
    try {
      // Load orders data
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .get();
      _totalOrders = ordersSnapshot.docs.length;

      _totalRevenue = 0.0;
      _ordersByStatus = {};
      _revenueByDay = {};

      for (var doc in ordersSnapshot.docs) {
        OrderModel order = OrderModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );

        // Calculate total revenue
        _totalRevenue += order.price;

        // Count orders by status
        _ordersByStatus[order.status] =
            (_ordersByStatus[order.status] ?? 0) + 1;

        // Calculate revenue by day
        String dayKey =
            "${order.timestamp.year}-${order.timestamp.month}-${order.timestamp.day}";
        _revenueByDay[dayKey] = (_revenueByDay[dayKey] ?? 0) + order.price;
      }

      // Load active users count
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      _activeUsers = usersSnapshot.docs.length;

      // Calculate average rating
      QuerySnapshot feedbackSnapshot = await _firestore
          .collection('feedbacks')
          .get();

      if (feedbackSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        int count = 0;
        for (var doc in feedbackSnapshot.docs) {
          // Your feedback model doesn't have rating, so we'll skip this for now
          // totalRating += (doc.data() as Map<String, dynamic>)['rating'];
          count++;
        }
        _averageRating = count > 0 ? totalRating / count : 0;
      }

      // Load popular dishes
      await _loadPopularDishes();

      notifyListeners();
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _loadPopularDishes() async {
    try {
      QuerySnapshot menuSnapshot = await _firestore
          .collection('menuItems')
          .limit(5)
          .get();

      _popularDishes = menuSnapshot.docs.map((doc) {
        return MenuItemModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print('Error loading popular dishes: $e');
    }
  }

  // User Management
  Future<void> loadUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      _staffUsers = _users.where((user) => user.role == 'staff').toList();
      notifyListeners();
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<bool> createUser({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Create user document
        UserModel newUser = UserModel(email: email, role: role);

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        await loadUsers();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Feedback Management
  Future<void> loadFeedbacks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('feedbacks')
          .orderBy('timestamp', descending: true)
          .get();

      _feedbacks = snapshot.docs
          .map(
            (doc) => FeedbackModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading feedbacks: $e');
    }
  }

  // Menu Management
  Future<void> loadMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menuItems').get();
      _menuItems = snapshot.docs.map((doc) {
        return MenuItemModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading menu items: $e');
    }
  }

  Future<void> loadRestaurants() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('restaurants').get();
      _restaurants = snapshot.docs.map((doc) {
        return Restaurant.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading restaurants: $e');
    }
  }

  Future<bool> updateMenuItem(MenuItemModel item) async {
    try {
      await _firestore.collection('menuItems').doc(item.id).update({
        'dishName': item.dishName,
        'restaurantId': item.restaurantId,
        'restaurantName': item.restaurantName,
        'foodType': item.foodType,
        'imageUrl': item.imageUrl,
        'price': item.price,
      });
      await loadMenuItems();
      return true;
    } catch (e) {
      print('Error updating menu item: $e');
      return false;
    }
  }

  // Complaint Management
  Future<void> loadComplaints() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .get();

      _complaints = snapshot.docs
          .map(
            (doc) => ComplaintModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading complaints: $e');
    }
  }

  Future<bool> resolveComplaint(String complaintId, String response) async {
    try {
      await _firestore.collection('complaints').doc(complaintId).update({
        'adminResponse': response,
        'status': 'resolved',
      });
      await loadComplaints();
      return true;
    } catch (e) {
      print('Error resolving complaint: $e');
      return false;
    }
  }

  // Report Generation
  Future<Map<String, dynamic>> generateReport({
    required DateTime startDate,
    required DateTime endDate,
    required String reportType,
  }) async {
    try {
      Map<String, dynamic> reportData = {
        'generatedAt': DateTime.now(),
        'startDate': startDate,
        'endDate': endDate,
        'reportType': reportType,
      };

      // Fetch data based on report type
      switch (reportType) {
        case 'sales':
          QuerySnapshot orderSnapshot = await _firestore
              .collection('orders')
              .where('timestamp', isGreaterThanOrEqualTo: startDate)
              .where('timestamp', isLessThanOrEqualTo: endDate)
              .get();

          double totalSales = 0;
          int orderCount = orderSnapshot.docs.length;

          for (var doc in orderSnapshot.docs) {
            OrderModel order = OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            totalSales += order.price;
          }

          reportData['totalSales'] = totalSales;
          reportData['orderCount'] = orderCount;
          reportData['averageOrderValue'] = orderCount > 0
              ? totalSales / orderCount
              : 0;
          break;

        case 'popular_dishes':
          reportData['popularDishes'] = _popularDishes
              .map(
                (dish) => {
                  'name': dish.dishName,
                  'category': dish.foodType,
                  'price': dish.price,
                },
              )
              .toList();
          break;

        case 'peak_hours':
          Map<int, int> hourlyOrders = {};
          QuerySnapshot orderSnapshot2 = await _firestore
              .collection('orders')
              .where('timestamp', isGreaterThanOrEqualTo: startDate)
              .where('timestamp', isLessThanOrEqualTo: endDate)
              .get();

          for (var doc in orderSnapshot2.docs) {
            OrderModel order = OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
            );
            int hour = order.timestamp.hour;
            hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
          }

          reportData['hourlyOrders'] = hourlyOrders;
          break;
      }

      return reportData;
    } catch (e) {
      print('Error generating report: $e');
      return {};
    }
  }
}
