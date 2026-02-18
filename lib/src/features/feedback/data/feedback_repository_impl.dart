import '../domain/feedback_payload.dart';
import '../domain/feedback_repository.dart';
import 'feedback_api_service.dart';
import 'feedback_create_dto.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl(this._api);

  final FeedbackApiService _api;

  @override
  Future<String> submitFeedback(FeedbackPayload payload) {
    return _api.submitFeedback(FeedbackCreateDto.fromDomain(payload));
  }
}
