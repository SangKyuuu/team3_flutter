import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../../data/service/faq_api.dart';

class CsFaqListScreen extends StatelessWidget {
  const CsFaqListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text(
          "자주 하는 질문(FAQ)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<FaqItem>>(
        future: FaqApi.fetchFaqs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'FAQ를 불러오지 못했습니다',
                style: TextStyle(color: Colors.red.shade600),
              ),
            );
          }
          final faqs = snapshot.data ?? [];
          if (faqs.isEmpty) {
            return const Center(child: Text('FAQ가 없습니다'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return _FaqTile(question: faq.question, answer: faq.answer);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: faqs.length,
          );
        },
      ),
    );
  }

}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          title: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _expanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ),
          shape: const Border(),
          collapsedShape: const Border(),
          children: [
            Text(
              widget.answer,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// FaqItem 모델은 data/service/faq_api.dart에서 정의됨
