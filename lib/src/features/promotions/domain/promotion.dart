class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
}
