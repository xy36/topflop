import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/product/product_form_screen.dart';
import '../features/product/product_screen.dart';
import '../features/rating/rating_screen.dart';
import '../features/scanner/scanner_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stores/store_detail_screen.dart';
import '../features/stores/stores_screen.dart';
import 'shell.dart';

final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, _) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/stores', builder: (_, _) => const StoresScreen())],
        ),
      ],
    ),
    GoRoute(path: '/scan', builder: (_, _) => const ScannerScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(
      path: '/product/new',
      builder: (_, state) => ProductFormScreen(barcode: state.uri.queryParameters['barcode']),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (_, state) => ProductScreen(productId: int.parse(state.pathParameters['id']!)),
      routes: [
        GoRoute(
          path: 'rate',
          builder: (_, state) => RatingScreen(
            productId: int.parse(state.pathParameters['id']!),
            ratingId: int.tryParse(state.uri.queryParameters['rating'] ?? ''),
            openDetailAfterSave: state.uri.queryParameters['then'] == 'detail',
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/store/:id',
      builder: (_, state) => StoreDetailScreen(storeId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
