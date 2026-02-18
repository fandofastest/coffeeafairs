import 'feedback_payload.dart';

abstract class FeedbackRepository {
  Future<String> submitFeedback(FeedbackPayload payload);
}
