class MenuItem {
  const MenuItem({
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
}
