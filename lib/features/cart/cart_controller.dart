import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_item_model.dart';

class CartController extends StateNotifier<List<CartItem>> {
  CartController() : super([]);

  void addItem(CartItem item) {
    state = [...state, item];
  }

  void removeItem(int index) {
    state = [...state]..removeAt(index);
  }

  void clearCart() {
    state = [];
  }

  void updateItem(int index, CartItem updatedItem) {
    final updatedList = [...state];
    updatedList[index] = updatedItem;
    state = updatedList;
  }

  double get totalPrice => state.fold(0, (sum, item) => sum + item.price);
}

final cartProvider = StateNotifierProvider<CartController, List<CartItem>>(
  (ref) => CartController(),
);
