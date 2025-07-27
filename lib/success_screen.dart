import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String message =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Success!';
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/upload');
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 32),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    ),
                child: const Text('Back to Login'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
