import 'package:flutter/material.dart';

class CsNoticeScreen extends StatelessWidget {
  const CsNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("공지사항")),
      body: const Center(child: Text("공지사항 화면")),
    );
  }
}
