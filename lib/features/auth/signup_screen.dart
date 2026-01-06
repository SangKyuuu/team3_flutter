import 'package:flutter/material.dart';
import 'package:team3/features/auth/auth_api.dart';
import 'package:team3/features/kakao_address_screen.dart';

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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _zipController = TextEditingController();
  final _addr1Controller = TextEditingController();
  final _addr2Controller = TextEditingController();

  String _gender = 'M'; // 기본값

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwCheckController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _zipController.dispose();
    _addr1Controller.dispose();
    _addr2Controller.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'custId': _idController.text,
      'password': _pwController.text,
      'custName': _nameController.text,
      'custHp': _phoneController.text,
      'custEmail': _emailController.text,
      'zipCode': _zipController.text,
      'addr1': _addr1Controller.text,
      'addr2': _addr2Controller.text,
      'gender': _gender,
    };

    try {
      await AuthApi.signup(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 완료')),
      );

      Navigator.pop(context); // 로그인 화면
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 실패')),
      );
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _input(_nameController, '이름'),
              _gap(),

              _input(_idController, '아이디', minLength: 4),
              _gap(),

              _password(_pwController, '비밀번호'),
              _gap(),

              _passwordConfirm(),
              _gap(),

              _input(_phoneController, '휴대폰 번호', hint: '010-1234-5678'),
              _gap(),

              _input(_emailController, '이메일', hint: 'example@bnk.co.kr'),
              _gap(),

              _genderSelect(),
              _gap(),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _zipController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '우편번호',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KakaoAddressScreen(),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          _zipController.text = result['zipCode'];
                          _addr1Controller.text = result['addr1'];
                        });
                      }
                    },
                    child: const Text('주소 검색'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

// 기본주소
              TextFormField(
                controller: _addr1Controller,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '기본주소',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

// 상세주소
              TextFormField(
                controller: _addr2Controller,
                decoration: const InputDecoration(
                  labelText: '상세주소',
                  border: OutlineInputBorder(),
                ),
              ),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 공통 위젯 =====

  Widget _input(
      TextEditingController controller,
      String label, {
        String? hint,
        int? minLength,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label을(를) 입력해주세요';
        }
        if (minLength != null && value.length < minLength) {
          return '$label은 $minLength자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _password(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return '비밀번호는 6자 이상이어야 합니다';
        }
        return null;
      },
    );
  }

  Widget _passwordConfirm() {
    return TextFormField(
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
    );
  }

  Widget _genderSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('성별', style: TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            Radio<String>(
              value: 'M',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const Text('남'),
            Radio<String>(
              value: 'F',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const Text('여'),
          ],
        ),
      ],
    );
  }

  Widget _gap({double height = 16}) => SizedBox(height: height);
}
