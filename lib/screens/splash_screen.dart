import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ph_power/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Start listening for the first authentication event.
    _redirect();
  }

  @override
  void dispose() {
    // Clean up the listener to prevent memory leaks.
    _authSubscription.cancel();
    super.dispose();
  }

  void _redirect() {
    // This stream fires immediately with the restored session or null.
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      // Stop listening after the first event.
      _authSubscription.cancel();

      // Navigate based on whether a session exists.
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
