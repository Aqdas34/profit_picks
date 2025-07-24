import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:convert';

class FinalRegisterScreen extends StatefulWidget {
  const FinalRegisterScreen({Key? key}) : super(key: key);

  @override
  State<FinalRegisterScreen> createState() => _FinalRegisterScreenState();
}

class _FinalRegisterScreenState extends State<FinalRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? message;

  void register(String email) async {
    setState(() {
      isLoading = true;
      message = null;
    });
    final api = ApiService();
    final response = await api.register(
      name: nameController.text.trim(),
      email: email,
      password: passwordController.text.trim(),
    );
    print('Register response: \n${response.body}');
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200 || response.statusCode == 202) {
      Navigator.pushReplacementNamed(
        context,
        '/success',
        arguments: 'Registration successful!',
      );
    } else {
      String errorMsg = '';
      try {
        final Map<String, dynamic> data =
            response.body.isNotEmpty
                ? Map<String, dynamic>.from(jsonDecode(response.body))
                : {};
        errorMsg = data['message'] ?? response.body;
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
    final String email =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Registration')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Set Name & Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Text('Email: $email', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => register(email),
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Register'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    color:
                        message == 'Registration successful!'
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
