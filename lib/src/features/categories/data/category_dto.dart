class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final String id;
  final String name;
  final bool isActive;

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return CategoryDto(
      id: id,
      name: (json['name'] ?? '').toString(),
      isActive: json['isActive'] == true,
    );
  }
}
