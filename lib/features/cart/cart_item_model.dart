class CartItem {
  final String id;
  final String dishName;
  final double price;
  final String imageUrl;
  final String spiceLevel;
  final String portionSize;
  final String notes;

  // 🔄 NEW FIELDS
  final String restaurantId;
  final String restaurantName;
  final String foodType;

  CartItem({
    required this.id,
    required this.dishName,
    required this.price,
    required this.imageUrl,
    required this.spiceLevel,
    required this.portionSize,
    required this.notes,
    required this.restaurantId,
    required this.restaurantName,
    required this.foodType,
  });
}
