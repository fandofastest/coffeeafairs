class StoreDto {
  const StoreDto({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.openingHours,
    required this.contactInfo,
  });

  final String id;
  final String name;
  final String description;
  final String address;
  final String openingHours;
  final String contactInfo;

  factory StoreDto.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return StoreDto(
      id: id,
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      openingHours: (json['openingHours'] ?? json['hours'] ?? '').toString(),
      contactInfo: (json['contactInfo'] ?? json['phone'] ?? '').toString(),
    );
  }
}
