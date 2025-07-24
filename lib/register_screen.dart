import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:math';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String? message;
  String? sentOtp;

  void sendOtp() async {
    setState(() {
      isLoading = true;
      message = null;
    });
    final api = ApiService();
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    sentOtp = otp;
    final response = await api.sendOtp(
      otp: otp,
      email: emailController.text.trim(),
    );
    print('Send OTP response: \n${response.body}');
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200 || response.statusCode == 202) {
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'email': emailController.text.trim(), 'otp': sentOtp},
      );
    } else {
      String errorMsg = '';
      try {
        final Map<String, dynamic> data =
            response.body.isNotEmpty
                ? Map<String, dynamic>.from(jsonDecode(response.body))
                : {};
        errorMsg = data['error']?.toString() ?? response.body;
      } catch (_) {
        errorMsg = response.body;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendOtp,
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Send OTP'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
