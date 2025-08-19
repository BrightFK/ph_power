import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ph_power/main.dart';
import 'package:ph_power/utils/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _user;

  @override
  void initState() {
    super.initState();
    // Get the initial user state
    _user = supabase.auth.currentUser;
    // Listen for any changes in the authentication state
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        // When auth state changes, update the local user variable and rebuild the widget
        setState(() => _user = data.session?.user);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (context.mounted) {
        // After signing out, navigate the user back to the login screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (error) {
      if (context.mounted)
        showSnackBar(context, 'Logout failed.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CircleAvatar(
                  radius: 50, child: Icon(Icons.person, size: 60)),
              const SizedBox(height: 16),
              // Use the reactive _user variable to display the email
              Text(
                _user?.email ?? 'Not logged in',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.grey[300]),
              ),
              const Spacer(),
              // Only show the logout button if a user is logged in
              if (_user != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400], // A distinct logout color
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _signOut,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
