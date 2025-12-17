import 'package:flutter/material.dart';
import 'package:team3/features/auth/signup_screen.dart';
import 'package:team3/features/home/home_screen.dart';
import 'package:team3/data/service/auth_api.dart';
import 'package:team3/data/service/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);

    try {
      final token = await AuthApi.login(
        _idController.text,
        _pwController.text,
      );
      await TokenStorage.saveToken(token);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디 또는 비밀번호가 올바르지 않습니다')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('로그인'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
