import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/restaurant_model.dart';

final restaurantProvider = FutureProvider<List<Restaurant>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('restaurants')
      .get();

  return snapshot.docs.map((doc) {
    return Restaurant.fromFirestore(doc.id, doc.data());
  }).toList();
});
