import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home_page.dart';
import '../../../splash/splash_page.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

/// Splash pendant la restauration de session, puis catalogue ou connexion.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  static const _minSplash = Duration(milliseconds: 1500);
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_minSplash, () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final Widget child = !_splashDone || auth is AuthUnknown
        ? const SplashPage()
        : auth is Authenticated
        ? const HomePage()
        : const LoginPage();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
    );
  }
}
