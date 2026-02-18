import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_providers.dart';
import '../data/feedback_api_service.dart';
import '../data/feedback_repository_impl.dart';
import '../domain/feedback_payload.dart';
import '../domain/feedback_repository.dart';

final feedbackApiServiceProvider = Provider<FeedbackApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return FeedbackApiService(dio);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final api = ref.watch(feedbackApiServiceProvider);
  return FeedbackRepositoryImpl(api);
});

class FeedbackController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> submit(FeedbackPayload payload) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(feedbackRepositoryProvider);
      await repo.submitFeedback(payload);
    });

    return state.hasError ? '' : 'ok';
  }
}

final feedbackControllerProvider =
    AutoDisposeAsyncNotifierProvider<FeedbackController, void>(
  FeedbackController.new,
);
