import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/color_scheme.dart';
import 'cart_controller.dart';
import 'cart_item_model.dart';
import 'edit_cart_item_sheet.dart';

class CartScreen extends ConsumerWidget {
  final void Function()? onOrderPlaced; // ✅ Optional callback

  const CartScreen({super.key, this.onOrderPlaced});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cart = ref.read(cartProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    void placeOrder() async {
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cart is empty.')));
        return;
      }

      for (final item in cartItems) {
        await FirebaseFirestore.instance.collection('orders').add({
          'userId': user?.uid ?? 'guest',
          'dishName': item.dishName,
          'price': item.price,
          'imageUrl': item.imageUrl,
          'spiceLevel': item.spiceLevel,
          'portionSize': item.portionSize,
          'notes': item.notes,
          'restaurantId': item.restaurantId,
          'restaurantName': item.restaurantName,
          'foodType': item.foodType,
          'status': 'preparing',
          'timestamp': Timestamp.now(),
        });
      }

      cart.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

      if (onOrderPlaced != null) {
        onOrderPlaced!(); // ✅ Notify HomeWrapper to switch tab
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      boxShadow: [AppShadows.card],
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your cart is empty',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add some delicious items to get started',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.lg,
                          ),
                          boxShadow: [AppShadows.card],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.md,
                                ),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColors.background,
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: AppColors.textLight,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.dishName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${item.portionSize} • ${item.spiceLevel}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'RM ${item.price.toStringAsFixed(2)}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(
                                        AppBorderRadius.md,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: AppColors.surface,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(
                                                AppBorderRadius.xl,
                                              ),
                                            ),
                                          ),
                                          builder: (_) => EditCartItemSheet(
                                            initialItem: item,
                                            index: index,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppBorderRadius.md,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      onPressed: () => cart.removeItem(index),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppBorderRadius.xl),
                    ),
                    boxShadow: [AppShadows.card],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'RM ${cart.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.shopping_bag_outlined,
                            color: AppColors.textWhite,
                          ),
                          label: Text(
                            'Place Order',
                            style: AppTextStyles.button,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.md,
                              ),
                            ),
                            shadowColor: AppColors.shadow,
                          ),
                          onPressed: placeOrder,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
