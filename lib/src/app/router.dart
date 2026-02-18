import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/categories/presentation/categories_screen.dart';
import '../features/feedback/presentation/feedback_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/menu/presentation/menu_screen.dart';
import '../features/menu/presentation/menu_item_detail_screen.dart';
import '../features/promotions/presentation/promotions_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CategoriesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MenuScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = state.extra;
                      if (extra is MenuItemDetailArgs) {
                        return MenuItemDetailScreen(args: extra);
                      }
                      return const MenuItemDetailScreen(
                        args: MenuItemDetailArgs.empty(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/promotions',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PromotionsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/feedback',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FeedbackScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_TabItem>[
    _TabItem('/home', Icons.home_rounded, 'Home'),
    _TabItem('/categories', Icons.grid_view_rounded, 'Categories'),
    _TabItem('/menu', Icons.coffee_rounded, 'Menu'),
    _TabItem('/promotions', Icons.local_offer_rounded, 'Deals'),
    _TabItem('/feedback', Icons.chat_bubble_outline_rounded, 'Feedback'),
  ];

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          navigationShell.goBranch(
            i,
            initialLocation: false,
          );
        },
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.location, this.icon, this.label);
  final String location;
  final IconData icon;
  final String label;
}
