class Product {
  final String id;
  final String stripePriceId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> features;
  final String category;
  final bool inStock;

  Product({
    required this.id,
    required this.stripePriceId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.features,
    required this.category,
    this.inStock = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      stripePriceId: json['stripePriceId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      features: List<String>.from(json['features'] ?? []),
      category: json['category'] ?? 'general',
      inStock: json['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stripePriceId': stripePriceId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'features': features,
      'category': category,
      'inStock': inStock,
    };
  }
}