import 'package:flutter/material.dart';
import 'package:team3/features/cs/cs_chatbot_screen.dart';
import 'package:team3/features/home/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cs_faq_list_screen.dart';
import 'cs_my_tickets_screen.dart';
import 'cs_one_on_one_inquiry_screen.dart';

// 고객센터 메인 화면
class CsMainScreen extends StatefulWidget {
  const CsMainScreen({super.key});

  @override
  State<CsMainScreen> createState() => _CsMainScreenState();
}

class _CsMainScreenState extends State<CsMainScreen> {
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
          "고객센터",
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 12),
          const _SectionHeader(title: "자주 하는 질문(FAQ)"),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              child: Column(
                children: [
                  const _FaqExpansionTile(
                    question: "펀드가 뭐에요?",
                    answer: "펀드는 펀드에요.",
                  ),
                  const _FaqExpansionTile(
                    question: "주식 모으기를 종료하고 싶어요",
                    answer: "주식 모으기 설정 화면에서 '종료' 또는 '해지'를 선택해 진행할 수 있어요.",
                  ),
                  const _FaqExpansionTile(
                    question: "주식을 팔았는데 출금할 수 없어요",
                    answer: "매도 후 정산(결제)까지 시간이 필요할 수 있어요. 정산 완료 후 출금이 가능합니다.",
                  ),
                  _MenuTile(
                    title: "자주 하는 질문(FAQ) 더 보기",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CsFaqListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 12, color: const Color(0xFFE0E0E0)),
          const SizedBox(height: 12),
          const _SectionHeader(title: "문의 채널"),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionCard(
              child: Column(
                children: [
                  _MenuTile(
                    title: "1:1문의",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CsOneOnOneInquiryScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuTile(
                    title: "문의 내역",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CsMyTicketsScreen(),
                        ),
                      );
                    },
                  ),
                  _MenuTile(
                    title: "전화 상담",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "전화 상담",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: const Text(
                              "1234-5678",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("확인"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final Uri phoneUri = Uri(
                                    scheme: 'tel',
                                    path: '1234-5678',
                                  );
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('전화를 걸 수 없습니다'),
                                        ),
                                      );
                                    }
                                  }
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text("전화걸기"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  _MenuTile(
                    title: "우사기 봇",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CsChatbotScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MenuTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _FaqExpansionTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqExpansionTile({required this.question, required this.answer});

  @override
  State<_FaqExpansionTile> createState() => _FaqExpansionTileState();
}

class _FaqExpansionTileState extends State<_FaqExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          title: Text(
            widget.question,
            style: const TextStyle(
              fontSize: 18,
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
