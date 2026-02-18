import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../../categories/presentation/categories_providers.dart';
import '../domain/feedback_payload.dart';
import 'feedback_providers.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final payload = FeedbackPayload(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      message: _messageCtrl.text,
    );

    final controller = ref.read(feedbackControllerProvider.notifier);

    final result = await controller.submit(payload);
    if (!mounted) return;

    if (result == 'ok') {
      _messageCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks! Your feedback has been sent.')),
      );
    } else {
      final err = ref.read(feedbackControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err?.toString() ?? 'Failed to submit feedback.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(feedbackControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us how we can improve',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Name (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return null;
                        final ok = RegExp(r'^.+@.+\..+$').hasMatch(value);
                        return ok ? null : 'Please enter a valid email';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _messageCtrl,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Message is required';
                        if (value.length < 5) return 'Message is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: submitting ? null : _submit,
                        child:
                            Text(submitting ? 'Sending...' : 'Send feedback'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, _) {
              final selected = ref.watch(selectedCategoryIdProvider);
              if (selected == null) return const SizedBox.shrink();
              return const EmptyState(
                title: 'Tip',
                message:
                    'You have a category filter active in Menu. You can reset it from the Menu filter chips.',
                icon: Icons.info_outline,
              );
            },
          ),
        ],
      ),
    );
  }
}
