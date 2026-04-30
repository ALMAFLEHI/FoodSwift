import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_controller.dart';
import '../../../app/theme/color_scheme.dart';
import '../../../models/menu_item_model.dart';
import '../../../models/restaurant_model.dart';
import '../restaurant/restaurant_controller.dart';
import '../../../providers/food_type_provider.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String? selectedRestaurantId;
  String? selectedFoodType;

  final List<String> foodTypes = [
    'All',
    'Malaysian',
    'Indian',
    'Chinese',
    'Western',
  ];

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(restaurantProvider);
    final menuAsync = ref.watch(menuItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 🔘 Restaurant Selector with Logos
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: restaurantAsync.when(
              data: (restaurants) => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final r = restaurants[index];
                  final isSelected = selectedRestaurantId == r.id;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () => selectedRestaurantId = isSelected ? null : r.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.xl,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textLight,
                            width: 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              AppShadows.card
                            else
                              AppShadows.button,
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(r.logoUrl),
                              radius: 16,
                              backgroundColor: AppColors.background,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              r.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.textWhite
                                    : AppColors.textDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: Text(
                    'Error loading restaurants: $e',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔘 Food Type Chips (Modern Design)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: foodTypes.length,
              itemBuilder: (context, index) {
                final type = foodTypes[index];
                final isSelected =
                    selectedFoodType == type ||
                    (type == 'All' && selectedFoodType == null);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFoodType = type == 'All' ? null : type;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textLight,
                          width: 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            AppShadows.card
                          else
                            AppShadows.button,
                        ],
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? AppColors.textWhite
                              : AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔘 Menu Grid (Modern Cards)
          Expanded(
            child: menuAsync.when(
              data: (items) {
                var filtered = items;

                // Filter by selected restaurant
                if (selectedRestaurantId != null) {
                  filtered = filtered
                      .where((i) => i.restaurantId == selectedRestaurantId)
                      .toList();
                }

                // Filter by selected food type
                if (selectedFoodType != null) {
                  filtered = filtered
                      .where((i) => i.foodType == selectedFoodType)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.xl,
                            ),
                            boxShadow: [AppShadows.card],
                          ),
                          child: Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No matching dishes found',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try different filters',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/customize',
                          arguments: item,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.lg,
                          ),
                          boxShadow: [AppShadows.card],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(AppBorderRadius.lg),
                                    ),
                                    child: Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.background,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.restaurant,
                                                  color: AppColors.textLight,
                                                  size: 40,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    top: AppSpacing.sm,
                                    right: AppSpacing.sm,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(
                                          AppBorderRadius.round,
                                        ),
                                        boxShadow: [AppShadows.button],
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.textWhite,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.dishName,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "RM ${item.price.toStringAsFixed(2)}",
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              AppBorderRadius.sm,
                                            ),
                                          ),
                                          child: Text(
                                            item.foodType,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
