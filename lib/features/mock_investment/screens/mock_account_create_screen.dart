import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../home/constants/app_colors.dart';
import '../../subscription/fund_subscription_screen.dart';
import '../../../data/service/mock_api.dart';

class MockAccountCreateScreen extends StatefulWidget {
  const MockAccountCreateScreen({super.key});

  @override
  State<MockAccountCreateScreen> createState() => _MockAccountCreateScreenState();
}

class _MockAccountCreateScreenState extends State<MockAccountCreateScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _amountController = TextEditingController();
  final List<ChatItem> _chatItems = [];
  bool _isTyping = false;
  int? _selectedAmount; // 선택한 금액 저장용
  String? _selectedPassword; // 입력한 비밀번호 저장용

  @override
  void initState() {
    super.initState();
    _startOnboarding();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _startOnboarding() async {
    // 1. 환영 메시지
    await _addBotMessage(ChatItem.cardMessage(
      title: '모의투자 계좌 개설을 시작할게요! 📈',
      description: '실제 자산에 영향 없이 자유롭게 연습할 수 있습니다.',
    ));

    // 2. 투자 성향 연동
    String? riskType = await MockApi.getInvestmentType();
    await _addBotMessage(ChatItem.textMessage(
      '회원님의 투자 성향은 **${riskType ?? "분석 중"}**입니다.\n성향에 맞춰 초기 자본금을 설정해볼까요?',
    ));

    // 3. 금액 입력 단계
    await _addBotMessage(ChatItem.amountInput(
      question: '초기 투자 금액을 입력해주세요.',
      hint: '최대 1억 원까지 가능합니다.',
      onSubmit: _handleAmountSubmit,
    ));
  }

  // 금액 입력 처리 (유효성 검사 추가)
  Future<void> _handleAmountSubmit(int amount) async {
    // 유효성 검사 실패 시 (1,000원 미만 또는 1억 원 초과)
    if (amount < 1000 || amount > 100000000) {
      // 사용자가 입력한 잘못된 금액을 말풍선으로 표시
      _addUserMessage('${_formatNumber(amount)}원');
      _disableLastSelection();

      // 컨트롤러 비우기
      _amountController.clear();

      // 봇의 에러 메시지 알림
      await _addBotMessage(ChatItem.textMessage(
        '죄송합니다. 초기 투자 금액은 **1,000원부터 1억 원**까지만 설정 가능합니다. 다시 입력해주세요.',
      ));

      // 다시 금액 입력창 띄우기 (비밀번호로 넘어가지 않고 여기서 멈춤)
      await _addBotMessage(ChatItem.amountInput(
        question: '초기 투자 금액을 입력해주세요.',
        hint: '1,000원 ~ 100,000,000원',
        onSubmit: _handleAmountSubmit,
      ));

      return; // 유효성 검사 실패 시 여기서 함수를 종료하여 아래 비밀번호 단계로 가지 못하게 함
    }

    // 유효성 검사 통과 시
    _addUserMessage('${_formatNumber(amount)}원');
    _disableLastSelection();

    // 다음(비밀번호) 입력을 위해 컨트롤러를 비워줍니다.
    _amountController.clear();

    // 통과했을 때만 비밀번호 설정 단계로 이동
    await _promptPassword(amount);
  }

  // 비밀번호 설정 요청 (새로 추가)
  Future<void> _promptPassword(int amount) async {
    await _addBotMessage(ChatItem.textMessage(
        '보안을 위해 모의투자 계좌에서 사용할 **비밀번호 4자리**를 설정해주세요.'
    ));

    // 숫자 입력을 위해 amountInput을 재활용합니다.
    await _addBotMessage(ChatItem.amountInput(
      question: '비밀번호 4자리를 입력해주세요.',
      hint: '비밀번호 4자리',
      onSubmit: (pass) => _handlePasswordSubmit(amount, pass.toString()),
    ));
  }

  // 비밀번호 입력 처리
  Future<void> _handlePasswordSubmit(int amount, String password) async {
    if (password.length != 4) {
      _amountController.clear();
      await _addBotMessage(ChatItem.textMessage('비밀번호는 반드시 **숫자 4자리**여야 합니다.'));
      await _promptPassword(amount); // 다시 입력받기
      return;
    }

    _addUserMessage('****'); // 보안상 별표 표시
    _disableLastSelection();
    _amountController.clear();

    // 마지막 확인 카드 호출
    await _addBotMessage(ChatItem.confirmCard(
      title: '계좌를 개설하시겠습니까?',
      description: '입력하신 ${_formatNumber(amount)}원과 비밀번호로 가상 계좌가 생성됩니다.',
      confirmText: '개설하기',
      cancelText: '취소',
      onConfirm: () => _finalizeAccount(amount, password),
      onCancel: () => Navigator.pop(context),
    ));
  }

  // 최종 개설 처리
  Future<void> _finalizeAccount(int amount, String password) async {
    bool success = await MockApi.createMockAccount(amount, password);

    if (success) {
      await _addBotMessage(ChatItem.textMessage('개설 완료! 🎉 이제 대시보드로 이동합니다.'));
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) Navigator.pushReplacementNamed(context, '/mock/dashboard');
    } else {
      await _addBotMessage(ChatItem.textMessage('계좌 생성 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'));
    }
  }

  // 데이터 관리 헬퍼 함수
  Future<void> _addBotMessage(ChatItem item) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 600));
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('모의계좌 개설', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _chatItems.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _chatItems.length) {
                  return const SizedBox(); // 타이핑 인디케이터는 필요시 추가
                }
                return _buildChatItem(_chatItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // UI 빌더 함수 (fund_subscription_screen.dart 스타일 적용)
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
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: _buildBotContent(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
      child: ClipOval(child: Padding(padding: const EdgeInsets.all(6), child: Image.asset('assets/images/logo.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Icon(Icons.water_drop_rounded, color: AppColors.primaryColor, size: 22)))),
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildBotContent(ChatItem item) {
    switch (item.type) {
      case ChatItemType.text: return _buildTextBubble(item.text!);
      case ChatItemType.card: return _buildCardBubble(item);
      case ChatItemType.amountInput: return _buildAmountInputCard(item);
      case ChatItemType.confirm: return _buildConfirmCard(item);
      default: return const SizedBox();
    }
  }

  Widget _buildTextBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Text(text, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
    );
  }

  Widget _buildCardBubble(ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5)),
          if (item.description != null) ...[
            const SizedBox(height: 14),
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: Text(item.description!, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.6))),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountInputCard(ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.question!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (!item.isDisabled) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              // 비밀번호 입력 단계인지 힌트 텍스트 등으로 판별하여 처리 가능
              obscureText: item.hint?.contains('비밀번호') ?? false,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                // 비밀번호일 경우 4글자 제한
                LengthLimitingTextInputFormatter(item.hint?.contains('비밀번호') == true ? 4 : 10),
              ],
              decoration: InputDecoration(
                  hintText: item.hint ?? '금액 입력',
                  suffixText: item.hint?.contains('비밀번호') == true ? '' : '원',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = int.tryParse(_amountController.text.replaceAll(',', ''));
                  if (amount != null) item.onAmountSubmit!(amount);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('확인'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmCard(ChatItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Text(item.description!, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.isDisabled ? null : item.onConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(item.confirmText ?? '확인'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: item.isDisabled ? null : item.onCancel, child: Text(item.cancelText ?? '취소')),
          ),
        ],
      ),
    );
  }
}