import 'package:flutter/material.dart';
import 'package:team3/features/auth/signup_screen.dart';
import 'package:team3/features/home/home_screen.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

            // 아이디
            const TextField(
              decoration: InputDecoration(
                labelText: '아이디',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // 비밀번호
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            // 로그인 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()
                    ), // 이거 나중에 인증 유무가냐 안가냐로바꿀 예정
                );
              },
              child: const Text('로그인'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()
                  ),
              );
            },
                child: const Text('회원가입')
            ),
          ],
        ),
      ),
    );
  }
}