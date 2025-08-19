import 'package:flutter/material.dart';
import 'package:ph_power/screens/auth/login_screen.dart';
import 'package:ph_power/screens/home/home_screen.dart';
import 'package:ph_power/screens/splash_screen.dart';
import 'package:ph_power/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: kUrl,
    anonKey: kAnonKey,
  );

  runApp(const PHPowerApp());
}

final supabase = Supabase.instance.client;

class PHPowerApp extends StatelessWidget {
  const PHPowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PH Power',
      debugShowCheckedModeBanner: false,
      // --- THEME CHANGES START HERE ---
      themeMode: ThemeMode.dark, // Enforce dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue[400],
        scaffoldBackgroundColor:
            const Color(0xFF121212), // Standard dark background

        // Use a modern color scheme generated from a seed color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),

        // Style all TextFields in the app for a consistent look
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),

        // Style all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[400],
            foregroundColor: Colors.black, // Text color on the button
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Style all TextButtons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue[300],
          ),
        ),

        // App Bar Theme (for screens that have one)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
      ),
      // --- THEME CHANGES END HERE ---

      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
