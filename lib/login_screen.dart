import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:convert'; // Added for jsonDecode

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? message;

  void login() async {
    setState(() {
      isLoading = true;
      message = null;
    });
    final api = ApiService();
    final response = await api.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    print('Login response: \n${response.body}');
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200 || response.statusCode == 202) {
      Navigator.pushReplacementNamed(
        context,
        '/success',
        arguments: 'Login successful!',
      );
    } else {
      String errorMsg = '';
      try {
        final Map<String, dynamic> data =
            response.body.isNotEmpty
                ? Map<String, dynamic>.from(jsonDecode(response.body))
                : {};
        errorMsg =
            data['error']?.toString() ??
            data['message']?.toString() ??
            response.body;
      } catch (_) {
        errorMsg = response.body;
      }
      // If errorMsg is still a JSON object, try to extract a value
      if (errorMsg.startsWith('{') && errorMsg.endsWith('}')) {
        try {
          final Map<String, dynamic> data = Map<String, dynamic>.from(
            jsonDecode(errorMsg),
          );
          errorMsg = data.values.first.toString();
        } catch (_) {}
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back!',
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
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Login'),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    color:
                        message == 'Login successful!'
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
