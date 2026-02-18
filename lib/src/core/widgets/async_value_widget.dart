import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    required this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget loading;
  final Widget Function(Object err, StackTrace st) error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading,
      error: error,
    );
  }
}
