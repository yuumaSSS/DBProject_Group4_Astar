import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login.dart';
import 'screens/loading.dart';
import 'screens/wrapper.dart';
import 'screens/stock.dart';
import 'screens/manage.dart';
import 'screens/about.dart';
import 'screens/manage_add.dart';
import 'screens/manage_update.dart';
import 'screens/manage_delete.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://zpvgfbxmnuzjujzrftnw.supabase.co',
    anonKey: 'sb_publishable_1q7A-Pk2y5cfEfPvlz7HIA_pEvHzIAH'
  );
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),

    GoRoute(
      path: '/loading',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const LoadingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 1000),
        );
      },
    ),

    StatefulShellRoute(
      navigatorContainerBuilder: (context, navigationShell, children) {
        return MainWrapper(
          navigationShell: navigationShell,
          children: children,
        );
      },
      pageBuilder: (context, state, navigationShell) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: navigationShell,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stock',
              builder: (context, state) => const StockScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manage',
              builder: (context, state) => const ManageScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const ManageAddScreen(),
                ),
                GoRoute(
                  path: 'update',
                  builder: (context, state) => const ManageUpdateScreen(),
                ),
                GoRoute(
                  path: 'delete',
                  builder: (context, state) => const ManageDeleteScreen(),
                ),
              ],
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/about',
              builder: (context, state) => const AboutScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
