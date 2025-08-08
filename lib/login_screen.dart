import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth_controller.dart'; // อย่าลืมเปลี่ยน path ให้ตรงกับโฟลเดอร์คุณ

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                final password = passwordController.text;
                authController.login(email, password, context);
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('สมัครสมาชิก'),
            )
          ],
        ),
      ),
    );
  }
}