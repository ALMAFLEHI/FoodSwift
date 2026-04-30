import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../feedback/feedback_form.dart';
import '../../../app/theme/color_scheme.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userId = userSnapshot.data!.uid;

          final orderStream = FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: orderStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              final orders = snapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final data = order.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: const Icon(Icons.fastfood),
                    title: Text(data['dishName'] ?? 'Unknown'),
                    subtitle: Text('Status: ${data['status'] ?? 'N/A'}'),
                    trailing: Text(
                      (data['timestamp'] as Timestamp)
                          .toDate()
                          .toString()
                          .split('.')[0],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // ✅ FAB to open feedback form
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const FeedbackForm(),
          );
        },
        icon: const Icon(Icons.feedback),
        label: const Text('Send Feedback'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
