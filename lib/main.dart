import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/Panier/presentation/providers/cart_provider.dart';
import 'features/orders/presentation/providers/orders_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/home_page.dart';
import 'features/orders/presentation/pages/checkout_page.dart';
import 'features/orders/presentation/pages/create_order_page.dart';
import 'features/payment/presentation/pages/payment_page.dart';
import 'features/orders/domain/entities/placed_order.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous is Authenticated && next is Unauthenticated) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
        ref.read(cartControllerProvider.notifier).clear();
        ref.invalidate(ordersProvider);
        ref.invalidate(profileProvider);
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Ma boutique',
      routes: {
        '/home': (_) => const HomePage(),
        '/checkout': (_) => const CheckoutPage(),
        '/new-order': (_) => const CreateOrderPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/payment' && settings.arguments is PlacedOrder) {
          return MaterialPageRoute(
            builder: (_) =>
                PaymentPage(order: settings.arguments as PlacedOrder),
          );
        }
        return null;
      },
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}
