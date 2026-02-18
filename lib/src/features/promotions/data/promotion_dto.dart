class PromotionDto {
  const PromotionDto({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isActive;

  factory PromotionDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    final id = (json['_id'] ?? json['id'] ?? '').toString();
    return PromotionDto(
      id: id,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      startsAt: parseDate(json['startsAt']),
      endsAt: parseDate(json['endsAt']),
      isActive: json['isActive'] == true,
    );
  }
}
