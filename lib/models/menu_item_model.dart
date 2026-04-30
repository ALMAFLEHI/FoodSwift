class MenuItemModel {
  final String id;
  final String dishName;
  final String restaurantId;
  final String restaurantName;
  final String foodType;
  final String imageUrl;
  final double price;

  MenuItemModel({
    required this.id,
    required this.dishName,
    required this.restaurantId,
    required this.restaurantName,
    required this.foodType,
    required this.imageUrl,
    required this.price,
  });

  factory MenuItemModel.fromFirestore(String id, Map<String, dynamic> data) {
    print('📦 Raw Firestore data: $data');

    return MenuItemModel(
      id: id,
      dishName: data['dishName'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      foodType: data['foodType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num).toDouble(),
    );
  }
}
