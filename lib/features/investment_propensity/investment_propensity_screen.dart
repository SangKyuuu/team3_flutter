import 'package:flutter/material.dart';
import '../home/constants/app_colors.dart';
import '../subscription/widgets/password_input_dialog.dart';
import '../subscription/services/signature_service.dart';
import '../terms_agreement/terms_agreement_screen.dart';

class InvestmentPropensityScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final String? fundTitle;
  final String? badge;
  final String? yieldText;

  const InvestmentPropensityScreen({
    super.key,
    this.onComplete,
    this.fundTitle,
    this.badge,
    this.yieldText,
  });

  @override
  State<InvestmentPropensityScreen> createState() => _InvestmentPropensityScreenState();
}

class _InvestmentPropensityScreenState extends State<InvestmentPropensityScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatItem> _chatItems = [];
  int _currentStep = 0;
  bool _isTyping = false;
  
  // 사용자 응답 저장 (점수 계산용)
  final List<int> _scores = [];
  String? _resultType;
  String? _resultDescription;
  int? _resultPercentage;

  @override
  void initState() {
    super.initState();
    _startSurvey();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _addBotMessage(ChatItem item, {int delay = 500}) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: delay));
    setState(() {
      _isTyping = false;
      _chatItems.add(item);
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _chatItems.add(ChatItem.userMessage(message));
    });
    _scrollToBottom();
  }

  Future<void> _startSurvey() async {
    await _addBotMessage(
      ChatItem.cardMessage(
        title: '안녕하세요! 👋\n투자성향을 알아볼게요.',
        description: '총 10개의 질문이에요.\n솔직하게 답변해 주시면 더 정확한 결과를 받을 수 있어요!',
      ),
      delay: 300,
    );

    await _askQuestion1();
  }

  // 질문 1: 투자 경험
  Future<void> _askQuestion1() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '투자, 어디까지 해봤어요?',
        options: [
          '예적금만 해봤어요',
          '펀드나 주식은 해봤어요',
          '웬만한 투자는 다 해봤어요 ✌️',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion2),
        scores: [1, 2, 3],
      ),
    );
    setState(() => _currentStep = 1);
  }

  // 질문 2: 투자 지식
  Future<void> _askQuestion2() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '주식, 펀드에 대해 잘 아시나요?',
        options: [
          '잘 모르겠어요',
          '매수와 매도를 구분할 수 있어요',
          '가치주와 성장주를 이해하고 있어요',
          'PER과 PBR을 설명할 수 있어요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion3),
        scores: [1, 2, 3, 4],
      ),
    );
    setState(() => _currentStep = 2);
  }

  // 질문 3: 자산 비중
  Future<void> _askQuestion3() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '총자산(부동산 제외) 대비\n투자상품의 비중은 어떻게 되나요?',
        options: [
          '10% 이하',
          '10% ~ 25%',
          '25% ~ 50%',
          '50% 초과',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion4),
        scores: [1, 2, 3, 4],
      ),
    );
    setState(() => _currentStep = 3);
  }

  // 질문 4: 투자 목적
  Future<void> _askQuestion4() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '투자를 하려는 이유가 뭐예요?',
        options: [
          '내 자산을 더 늘리고 싶어요',
          '미래에 필요한 자금을 준비하고 싶어요',
          '곧 사용할 돈을 짧게 굴리고 싶어요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion5),
        scores: [3, 2, 1],
      ),
    );
    setState(() => _currentStep = 4);
  }

  // 질문 5: 수입 전망
  Future<void> _askQuestion5() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '앞으로 수입이 어떻게 될 것 같나요?',
        options: [
          '일정한 수입이 없어요',
          '비슷하게 유지될 것 같아요',
          '앞으로 증가할 것 같아요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion6),
        scores: [1, 2, 3],
      ),
    );
    setState(() => _currentStep = 5);
  }

  // 질문 6: 손실 감내
  Future<void> _askQuestion6() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '손실이 있다면 어디까지 괜찮아요?',
        options: [
          '손실은 절대 안돼요',
          '-10%까지는 괜찮아요',
          '-20%까지는 괜찮아요',
          '-50%까지는 괜찮아요',
          '더 큰 손실도 괜찮아요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion7),
        scores: [1, 2, 3, 4, 5],
      ),
    );
    setState(() => _currentStep = 6);
  }

  // 질문 7: 투자 기간
  Future<void> _askQuestion7() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '투자하는 돈이 언제 필요한가요?',
        options: [
          '1년 이내',
          '1년 ~ 2년',
          '2년 ~ 3년',
          '3년 이후',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion8),
        scores: [1, 2, 3, 4],
      ),
    );
    setState(() => _currentStep = 7);
  }

  // 질문 8: 손실 시 대응
  Future<void> _askQuestion8() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '투자 중 20% 손실이 발생하면\n어떻게 하실 건가요?',
        options: [
          '바로 전부 팔아요',
          '일부만 팔고 지켜볼래요',
          '기다리면서 상황을 볼래요',
          '오히려 더 사고 싶어요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion9),
        scores: [1, 2, 3, 4],
      ),
    );
    setState(() => _currentStep = 8);
  }

  // 질문 9: 기대 수익률
  Future<void> _askQuestion9() async {
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '기대하는 연간 수익률은 얼마인가요?',
        options: [
          '예금 금리 수준 (3~4%)',
          '예금 금리 + α (5~10%)',
          '두 자릿수 수익 (10~20%)',
          '높은 수익 (20% 이상)',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _askQuestion10),
        scores: [1, 2, 3, 4],
      ),
    );
    setState(() => _currentStep = 9);
  }

  // 질문 10: 금융취약 소비자
  Future<void> _askQuestion10() async {
    await _addBotMessage(
      ChatItem.cardMessage(
        title: '마지막!\n혹시 금융취약 소비자인가요?',
        description: '• 금융감독원 기준에 따라 만 65세 이상,\n  주부, 은퇴자가 이에 해당합니다.',
      ),
    );
    
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '',
        options: [
          '금융취약 소비자예요',
          '아니에요',
        ],
        onSelect: (answer, score) => _handleAnswer(answer, score, _showResult),
        scores: [-2, 0], // 금융취약 소비자는 점수 감점
      ),
    );
    setState(() => _currentStep = 10);
  }

  Future<void> _handleAnswer(String answer, int score, Future<void> Function() nextQuestion) async {
    _addUserMessage(answer);
    _disableLastSelection();
    _scores.add(score);
    
    await Future.delayed(const Duration(milliseconds: 300));
    await nextQuestion();
  }

  Future<void> _showResult() async {
    // 총점 계산 (최소 7점 ~ 최대 34점)
    int totalScore = _scores.fold(0, (sum, score) => sum + score);
    
    // 결과 유형 결정 (5가지 유형이 골고루 나오도록 조정)
    // 7~12점: 안정형, 13~17점: 안정추구형, 18~22점: 위험중립형
    // 23~27점: 적극투자형, 28점 이상: 공격투자형
    if (totalScore <= 12) {
      _resultType = '안정형';
      _resultDescription = '안전한 투자를 선호해요.\n원금 보존이 가장 중요하고,\n낮은 수익률도 괜찮아요.\n\n추천 상품: 예금, 적금, MMF';
      _resultPercentage = 25;
    } else if (totalScore <= 17) {
      _resultType = '안정추구형';
      _resultDescription = '안정적인 수익을 원해요.\n약간의 손실은 감수할 수 있지만\n큰 위험은 피하고 싶어요.\n\n추천 상품: 채권형 펀드, 혼합형 펀드';
      _resultPercentage = 30;
    } else if (totalScore <= 22) {
      _resultType = '위험중립형';
      _resultDescription = '적당한 위험을 감수해요.\n수익과 손실의 균형을\n중요하게 생각해요.\n\n추천 상품: 혼합형 펀드, 배당주 펀드';
      _resultPercentage = 24;
    } else if (totalScore <= 27) {
      _resultType = '적극투자형';
      _resultDescription = '높은 수익을 추구해요.\n상당한 손실도 감수할 수 있고\n적극적으로 투자해요.\n\n추천 상품: 주식형 펀드, 해외 펀드';
      _resultPercentage = 15;
    } else {
      _resultType = '공격투자형';
      _resultDescription = '최대 수익을 추구해요.\n큰 손실도 감수할 준비가 되어있고\n공격적으로 투자해요.\n\n추천 상품: 레버리지 펀드, 파생상품';
      _resultPercentage = 6;
    }

    await _addBotMessage(
      ChatItem.textMessage('투자성향 분석이 완료됐어요! 🎉'),
    );

    await _addBotMessage(
      ChatItem.resultCard(
        resultType: _resultType!,
        description: _resultDescription!,
        percentage: _resultPercentage!,
        onConfirm: _handleResultConfirm,
      ),
    );
    
    setState(() => _currentStep = 11);
  }

  Future<void> _handleResultConfirm() async {
    if (widget.fundTitle != null) {
      // 전자서명 다이얼로그 표시
      final password = await showPasswordInputDialog(
        context: context,
        title: '전자서명',
        description: '투자성향 조사를 완료하려면\n비밀번호를 입력해주세요.',
      );
      
      if (password == null || password.isEmpty) {
        // 취소한 경우
        return;
      }
      
      // 전자서명 생성 (성향분포 조사용)
      final signature = SignatureService.createSignature(
        userId: 'USER_001',  // 실제로는 로그인된 사용자 ID
        productName: '투자성향 조사',
        investmentAmount: 0,  // 성향분포는 금액이 없으므로 0
        password: password,
        deviceInfo: 'Flutter App',
      );
      
      // 전자서명 완료 메시지 추가
      await _addBotMessage(
        ChatItem.textMessage('전자서명이 완료되었어요! ✍️'),
      );
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 약관 동의 화면으로 이동 (pop하지 않고 push)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermsAgreementScreen(
              fundTitle: widget.fundTitle!,
              badge: widget.badge!,
              yieldText: widget.yieldText!,
            ),
          ),
        );
      }
    } else {
      Navigator.pop(context);
    }
    widget.onComplete?.call();
  }

  void _disableLastSelection() {
    setState(() {
      for (int i = _chatItems.length - 1; i >= 0; i--) {
        if (_chatItems[i].hasInteraction) {
          _chatItems[i] = _chatItems[i].copyWithDisabled();
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 24),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            '투자성향',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          centerTitle: true,
        ),
      body: Column(
        children: [
          // 진행 바
          Container(
            color: Colors.white,
            child: LinearProgressIndicator(
              value: _currentStep / 11,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 3,
            ),
          ),
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 40, // 하단 여백 추가
              ),
              itemCount: _chatItems.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _chatItems.length) {
                  return _buildTypingIndicator();
                }
                return _buildChatItem(_chatItems[index]);
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return _TypingDot(delay: index * 150);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0), // 따뜻한 베이지 배경
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/말풍선우사기.PNG',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.pets_rounded,
                color: AppColors.primaryColor,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatItem item) {
    if (item.isUser) {
      return _buildUserMessage(item.text!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: _buildBotContent(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotContent(ChatItem item) {
    switch (item.type) {
      case ChatItemType.text:
        return _buildTextBubble(item.text!);
      case ChatItemType.card:
        return _buildCardBubble(item);
      case ChatItemType.selection:
        return _buildSelectionCard(item);
      case ChatItemType.result:
        return _buildResultCard(item);
      case ChatItemType.signature:
        return _buildSignatureCard(item);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCardBubble(ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          if (item.description != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectionCard(ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.question!.isNotEmpty) ...[
            Text(
              item.question!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...List.generate(item.options!.length, (index) {
            final option = item.options![index];
            final score = item.scores![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: item.isDisabled 
                      ? null 
                      : () => item.onSelectWithScore!(option, score),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade400
                        : Colors.black87,
                    backgroundColor: item.isDisabled
                        ? Colors.grey.shade100
                        : Colors.white,
                    side: BorderSide(
                      color: item.isDisabled
                          ? Colors.grey.shade200
                          : Colors.grey.shade300,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 투자성향별 이미지 및 색상 가져오기
  Map<String, dynamic> _getResultStyle(String resultType) {
    switch (resultType) {
      case '안정형':
        return {
          'image': 'assets/images/안정형.png', // 안정형 이미지
          'color': const Color(0xFFE8F5E9), // 연한 초록
          'icon': Icons.shield_outlined,
        };
      case '안정추구형':
        return {
          'image': 'assets/images/안정추구형.png', // 안정추구형 이미지
          'color': const Color(0xFFFFF4E0), // 따뜻한 베이지
          'icon': Icons.security_outlined,
        };
      case '위험중립형':
        return {
          'image': 'assets/images/위협중립형.png', // 위험중립형 이미지
          'color': const Color(0xFFFFF8E1), // 연한 노랑
          'icon': Icons.balance_outlined,
        };
      case '적극투자형':
        return {
          'image': 'assets/images/적극투자형.png', // 적극투자형 이미지
          'color': const Color(0xFFE3F2FD), // 연한 파랑
          'icon': Icons.trending_up_outlined,
        };
      case '공격투자형':
        return {
          'image': 'assets/images/위험추구형 (1).png', // 공격투자형 이미지
          'color': const Color(0xFFFFEBEE), // 연한 빨강
          'icon': Icons.rocket_launch_outlined,
        };
      default:
        return {
          'image': 'assets/images/logo.png',
          'color': const Color(0xFFF5F5F5),
          'icon': Icons.person_outline,
        };
    }
  }

  Widget _buildResultCard(ChatItem item) {
    final style = _getResultStyle(item.resultType!);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '나와 동일한 성향 ${item.percentage}%',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.resultType!,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 280,
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: ClipRect(
              child: Image.asset(
                style['image'] as String,
                width: 280,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    style['icon'] as IconData,
                    size: 60,
                    color: AppColors.primaryColor,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item.resultDescription!,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.fundTitle != null ? '펀드 가입하러 가기' : '확인',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCard(ChatItem item) {
    final formattedDate = _formatSignatureDate(item.signedAt!);
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified,
                  color: Colors.green.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '전자서명 완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.fingerprint, 
                         color: AppColors.primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '서명 ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.signatureId!.substring(0, 8) + '...',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.lock_outline, 
                         color: AppColors.primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '서명 해시',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.hashPreview! + '...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade400, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '이 전자서명은 법적 효력을 가집니다',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSignatureDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

// ============== 데이터 클래스 ==============

enum ChatItemType {
  text,
  user,
  card,
  selection,
  result,
  signature,
}

class ChatItem {
  final ChatItemType type;
  final bool isUser;
  final String? text;
  final String? title;
  final String? description;
  final String? question;
  final List<String>? options;
  final List<int>? scores;
  final void Function(String, int)? onSelectWithScore;
  final String? resultType;
  final String? resultDescription;
  final int? percentage;
  final VoidCallback? onConfirm;
  final bool isDisabled;
  // 전자서명 관련 필드
  final String? signatureId;
  final DateTime? signedAt;
  final String? hashPreview;

  ChatItem({
    required this.type,
    this.isUser = false,
    this.text,
    this.title,
    this.description,
    this.question,
    this.options,
    this.scores,
    this.onSelectWithScore,
    this.resultType,
    this.resultDescription,
    this.percentage,
    this.onConfirm,
    this.isDisabled = false,
    this.signatureId,
    this.signedAt,
    this.hashPreview,
  });

  bool get hasInteraction => type == ChatItemType.selection;

  ChatItem copyWithDisabled() {
    return ChatItem(
      type: type,
      isUser: isUser,
      text: text,
      title: title,
      description: description,
      question: question,
      options: options,
      scores: scores,
      onSelectWithScore: onSelectWithScore,
      resultType: resultType,
      resultDescription: resultDescription,
      percentage: percentage,
      onConfirm: onConfirm,
      signatureId: signatureId,
      signedAt: signedAt,
      hashPreview: hashPreview,
      isDisabled: true,
    );
  }

  factory ChatItem.userMessage(String text) {
    return ChatItem(type: ChatItemType.user, isUser: true, text: text);
  }

  factory ChatItem.textMessage(String text) {
    return ChatItem(type: ChatItemType.text, text: text);
  }

  factory ChatItem.cardMessage({
    required String title,
    String? description,
  }) {
    return ChatItem(
      type: ChatItemType.card,
      title: title,
      description: description,
    );
  }

  factory ChatItem.selectionCard({
    required String question,
    required List<String> options,
    required void Function(String, int) onSelect,
    required List<int> scores,
  }) {
    return ChatItem(
      type: ChatItemType.selection,
      question: question,
      options: options,
      scores: scores,
      onSelectWithScore: onSelect,
    );
  }

  factory ChatItem.resultCard({
    required String resultType,
    required String description,
    required int percentage,
    required VoidCallback onConfirm,
  }) {
    return ChatItem(
      type: ChatItemType.result,
      resultType: resultType,
      resultDescription: description,
      percentage: percentage,
      onConfirm: onConfirm,
    );
  }

  factory ChatItem.signatureCard({
    required String signatureId,
    required DateTime signedAt,
    required String hashPreview,
  }) {
    return ChatItem(
      type: ChatItemType.signature,
      signatureId: signatureId,
      signedAt: signedAt,
      hashPreview: hashPreview,
    );
  }
}

// ============== 애니메이션 위젯 ==============

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.3 + (_animation.value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

