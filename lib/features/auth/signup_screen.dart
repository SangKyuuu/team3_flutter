import 'package:flutter/material.dart';
/*============================================
대충 느낌만 내봤음 / 향후 디자인 결정 되면 약관 기본 정보 입력 상세 하게 추가 예정
================================================*/
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 완료')),
      );

      // 지금은 회원 가입 완료 후 로그인 화면으로 돌아가기
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 아이디
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요';
                  }
                  if (value.length < 4) {
                    return '아이디는 4자 이상이어야 합니다';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 비밀번호
              TextFormField(
                controller: _pwController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 비밀번호 확인
              TextFormField(
                controller: _pwCheckController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _pwController.text) {
                    return '비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: _submit,
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
