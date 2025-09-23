import 'package:flutter/material.dart';
import '../db/task_database.dart';
import '../task_color/app_color.dart';
import 'login.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final db = MyDatabase();
  bool _loading = false;

  Future<void> _showDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.terracotta,
          ),
        ),
        content: Text(message,
            style: const TextStyle(color: AppColors.saddle, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.latte,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.saddle),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    final res = await db.insertUser({
      'username': username,
      'password': password,
    });

    if (res > 0) {
      await _showDialog('Success', 'Signup successful!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      await _showDialog('Error', 'User already exists or something went wrong.');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.caramel, AppColors.latte],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.terracotta,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.saddle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign up to continue",
                        style: TextStyle(color: AppColors.mocha, fontSize: 15),
                      ),
                      const SizedBox(height: 28),

                      // Username
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.terracotta),
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter username'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppColors.terracotta),
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Enter password'
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppColors.terracotta, AppColors.caramel],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Switch to Login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: AppColors.saddle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
