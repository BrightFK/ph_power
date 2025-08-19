import 'package:flutter/material.dart';
import 'package:ph_power/main.dart';
import 'package:ph_power/utils/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      showSnackBar(context, 'Please fill all fields', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Attempt to sign up the user. Because we turned off email confirmation,
      // a successful signUp call also logs the user in.
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // On success, navigate directly to the home screen.
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on AuthException catch (error) {
      if (mounted) showSnackBar(context, error.message, isError: true);
    } catch (error) {
      if (mounted)
        showSnackBar(context, 'An unexpected error occurred.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // (The UI code is unchanged from our beautified version)
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_add_alt_1_outlined,
                    size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text('Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Join the community to start reporting.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[400])),
                const SizedBox(height: 48),
                TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password')),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: _signUp,
                            child: const Text('Sign Up & Continue'))),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Already have an account?",
                      style: TextStyle(color: Colors.grey[400])),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Login")),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
