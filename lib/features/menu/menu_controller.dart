import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/menu_item_model.dart'; // ✅ Must point to correct model

final menuItemsProvider = FutureProvider<List<MenuItemModel>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('menu').get();

  return snapshot.docs.map((doc) {
    return MenuItemModel.fromFirestore(doc.id, doc.data());
  }).toList();
});
