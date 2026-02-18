class FeedbackPayload {
  const FeedbackPayload({
    required this.name,
    required this.email,
    required this.message,
  });

  final String name;
  final String email;
  final String message;
}
