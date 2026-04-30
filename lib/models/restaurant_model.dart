class Restaurant {
  final String id;
  final String name;
  final String description;
  final String location;
  final String logoUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.logoUrl,
  });

  factory Restaurant.fromFirestore(String id, Map<String, dynamic> data) {
    return Restaurant(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
    );
  }
}
