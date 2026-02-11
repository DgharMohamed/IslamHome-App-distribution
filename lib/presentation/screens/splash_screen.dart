import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔔 SplashScreen: initState');
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    debugPrint('🔔 SplashScreen: Starting 2s timer...');
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('🕒 SplashScreen: 2s delay finished, mounted=$mounted');
    if (mounted) {
      debugPrint('🚀 SplashScreen: Attempting context.go("/")');
      try {
        context.go('/');
        debugPrint('✅ SplashScreen: context.go("/") called');
      } catch (e, stack) {
        debugPrint('❌ SplashScreen: Navigation error: $e');
        debugPrint(stack.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔔 SplashScreen: build');
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Icon(Icons.mosque, size: 100, color: Color(0xFFC6A243)),
      ),
    );
  }
}
