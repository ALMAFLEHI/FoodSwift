import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/menu_item_model.dart';

class CustomizeOrderScreen extends StatefulWidget {
  final MenuItemModel menuItem;

  const CustomizeOrderScreen({super.key, required this.menuItem});

  @override
  State<CustomizeOrderScreen> createState() => _CustomizeOrderScreenState();
}

class _CustomizeOrderScreenState extends State<CustomizeOrderScreen> {
  String _spiceLevel = 'Mild';
  String _portionSize = 'Regular';
  final _notesController = TextEditingController();

  Future<void> _submitOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    final order = {
      'userId': user?.uid ?? 'unknown',
      'dishName': widget.menuItem.dishName,
      'restaurantId': widget.menuItem.restaurantId, // ✅ new
      'restaurantName': widget.menuItem.restaurantName, // ✅ new
      'foodType': widget.menuItem.foodType, // ✅ new
      'price': widget.menuItem.price,
      'imageUrl': widget.menuItem.imageUrl,
      'spiceLevel': _spiceLevel,
      'portionSize': _portionSize,
      'notes': _notesController.text,
      'status': 'preparing',
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('orders').add(order);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customize ${widget.menuItem.dishName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _spiceLevel,
              items: ['Mild', 'Medium', 'Spicy'].map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (val) => setState(() => _spiceLevel = val!),
              decoration: const InputDecoration(labelText: 'Spice Level'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _portionSize,
              items: ['Small', 'Regular', 'Large'].map((size) {
                return DropdownMenuItem(value: size, child: Text(size));
              }).toList(),
              onChanged: (val) => setState(() => _portionSize = val!),
              decoration: const InputDecoration(labelText: 'Portion Size'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitOrder,
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}
