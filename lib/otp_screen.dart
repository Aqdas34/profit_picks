import 'package:flutter/material.dart';
import 'api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String? message;

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String? email;
    String? sentOtp;
    String? argError;
    if (routeArgs is Map<String, dynamic> &&
        routeArgs['email'] != null &&
        routeArgs['otp'] != null) {
      email = routeArgs['email'] as String;
      sentOtp = routeArgs['otp'] as String;
    } else {
      argError =
          'Invalid or missing arguments. Please restart the registration process.';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (argError != null) ...[
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 24),
                Text(
                  argError,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ] else ...[
                const Text(
                  'Enter OTP',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              setState(() {
                                isLoading = true;
                                message = null;
                              });
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              if (otpController.text.trim() == sentOtp) {
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.pushNamed(
                                  context,
                                  '/final_register',
                                  arguments: email,
                                );
                              } else {
                                setState(() {
                                  isLoading = false;
                                  message = 'Invalid OTP. Please try again.';
                                });
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Verify OTP'),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
