import '../domain/feedback_payload.dart';

class FeedbackCreateDto {
  const FeedbackCreateDto({
    required this.name,
    required this.email,
    required this.message,
  });

  final String name;
  final String email;
  final String message;

  factory FeedbackCreateDto.fromDomain(FeedbackPayload payload) {
    return FeedbackCreateDto(
      name: payload.name,
      email: payload.email,
      message: payload.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name.trim().isNotEmpty) 'name': name.trim(),
      if (email.trim().isNotEmpty) 'email': email.trim(),
      'message': message.trim(),
    };
  }
}
