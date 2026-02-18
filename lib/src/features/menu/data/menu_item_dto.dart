class MenuItemDto {
  const MenuItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.imageUrl,
    required this.categoryId,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String description;
  final num price;
  final String currency;
  final String? imageUrl;
  final String categoryId;
  final bool isAvailable;

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return MenuItemDto(
      id: id,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] is num) ? (json['price'] as num) : num.tryParse((json['price'] ?? '0').toString()) ?? 0,
      currency: (json['currency'] ?? 'THB').toString(),
      imageUrl: json['imageUrl']?.toString(),
      categoryId: (json['categoryId'] ?? '').toString(),
      isAvailable: json['isAvailable'] == true,
    );
  }
}
