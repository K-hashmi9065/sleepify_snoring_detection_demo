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
    Future.delayed(const Duration(seconds: 2), () {
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nightlight_round, size: 80, color: Color(0xFF4A6CF7)),
            const SizedBox(height: 16),
            const Text('Sleepify', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Track your sleep. Know your snore.'),
          ],
        ),
      ),
    );
  }
}
