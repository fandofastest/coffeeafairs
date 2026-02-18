import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

class CoffeeAffairsApp extends ConsumerWidget {
  const CoffeeAffairsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Coffee Affairs',
      theme: buildCoffeeTheme(Brightness.light),
      darkTheme: buildCoffeeTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
