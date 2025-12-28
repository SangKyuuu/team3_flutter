import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../home/constants/app_colors.dart';
import '../home/home_screen.dart';
import 'services/signature_service.dart';
import 'models/electronic_signature.dart';
import 'widgets/password_input_dialog.dart';
import '../../data/service/fund_subscription_api.dart';

class FundSubscriptionScreen extends StatefulWidget {
  final String fundTitle;
  final String? fundCode;  // 펀드 코드 추가
  final String badge;
  final String yieldText;
  final bool isMockInvestment;

  const FundSubscriptionScreen({
    super.key,
    required this.fundTitle,
    this.fundCode,  // 선택적으로 받음
    required this.badge,
    required this.yieldText,
    this.isMockInvestment = false,
  });

  @override
  State<FundSubscriptionScreen> createState() => _FundSubscriptionScreenState();
}

class _FundSubscriptionScreenState extends State<FundSubscriptionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final List<ChatItem> _chatItems = [];
  int _currentStep = 0;
  bool _isTyping = false;
  
  // 사용자 선택 저장
  String? _riskAwareness;
  String? _lossScale;
  String? _investmentType;
  String? _investmentSchedule; // 매일/매주/매월 선택
  String? _weeklyDay; // 매주 선택 시 요일
  int? _monthlyDay; // 매월 선택 시 일자
  int? _investmentAmount;
  int? _currentAccountBalance; // 현재 계좌 잔액
  bool _isCompleted = false;
  bool _isDuplicateSubscription = false;  // 중복 가입 여부
  int? _existingSubscriptionAmount;  // 이미 가입된 펀드의 투자금액
  String? _existingSubscriptionStartAt;  // 이미 가입된 펀드의 투자시작일
  
  // 전자서명 기록
  ElectronicSignature? _signature;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();
    _amountFocusNode.dispose();
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

  Future<void> _addBotMessage(ChatItem item, {int delay = 600}) async {
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

  Future<void> _startConversation() async {
    String welcomeTitle = widget.isMockInvestment
        ? '반가워요! 😊\n${widget.fundTitle} 모의투자를 시작해볼까요?'
        : '안녕하세요! 😊\n${widget.fundTitle} 가입을 도와드릴게요.';

    String welcomeDesc = widget.isMockInvestment
        ? '연습용 가상 자산으로 부담 없이 투자해보세요. 실제 돈은 나가지 않으니 안심하세요!'
        : '펀드는 예금과 달라서 원금의 일부 또는 전부를 잃을 수도 있어요. 걱정 마세요, 차근차근 안내해 드릴게요!';

    await _addBotMessage(
      ChatItem.cardMessage(
        title: welcomeTitle,
        description: welcomeDesc,
      ),
      delay: 400,
    );

    await _addBotMessage(
      ChatItem.selectionCard(
        question: '먼저 한 가지 여쭤볼게요.\n펀드의 **원금 손실 위험**에 대해 어떻게 생각하세요?',
        options: ['원금 손실 위험이 있다', '원금 손실 위험이 없다'],
        onSelect: _handleRiskAwareness,
      ),
      delay: 500,
    );
    
    setState(() => _currentStep = 1);
  }

  Future<void> _handleRiskAwareness(String answer) async {
    _addUserMessage(answer);
    setState(() => _riskAwareness = answer);
    _disableLastSelection();

    if (answer == '원금 손실 위험이 없다') {
      await _addBotMessage(
        ChatItem.textMessage('앗, 펀드는 원금 손실 위험이 있는 상품이에요! 😅\n다시 한번 생각해보시고 선택해 주세요~'),
      );
      await _addBotMessage(
        ChatItem.selectionCard(
          question: '펀드의 **원금 손실 위험 가능성**에 대해\n어떻게 생각하세요?',
          options: ['원금 손실 위험이 있다', '원금 손실 위험이 없다'],
          onSelect: _handleRiskAwareness,
        ),
      );
      return;
    }

    await _addBotMessage(
      ChatItem.textMessage('맞아요! 잘 이해하고 계시네요 👍'),
    );
    
    await _addBotMessage(
      ChatItem.selectionCard(
        question: '그럼 **원금 손실 규모**는 어느 정도라고 생각하세요?',
        options: ['전부 손실도 가능하다', '원금 손실 위험이 없다'],
        onSelect: _handleLossScale,
      ),
    );
    setState(() => _currentStep = 2);
  }

  Future<void> _handleLossScale(String answer) async {
    _addUserMessage(answer);
    setState(() => _lossScale = answer);
    _disableLastSelection();

    if (answer == '원금 손실 위험이 없다') {
      await _addBotMessage(
        ChatItem.textMessage('음, 상품마다 다르지만 최대 100%까지 손실이 발생할 수 있어요. 😮\n다시 선택해 주실래요?'),
      );
      await _addBotMessage(
        ChatItem.selectionCard(
          question: '펀드의 **원금 손실 규모**에 대해 어떻게\n생각하세요?',
          options: ['전부 손실도 가능하다', '원금 손실 위험이 없다'],
          onSelect: _handleLossScale,
        ),
      );
      return;
    }

    await _addBotMessage(
      ChatItem.textMessage('정확해요! 투자에 대해 잘 알고 계시네요 😊'),
    );

    await _addBotMessage(
      ChatItem.confirmCard(
        title: '지금까지 내용을 충분히 확인하셨나요?',
        description: '투자로 인한 손실은 고객님께 귀속돼요. 충분히 이해하신 후 진행해 주시면 좋겠어요!',
        confirmText: '네, 확인했어요',
        cancelText: '아니오, 다시 볼래요',
        onConfirm: () => _handleConfirmRisk(true),
        onCancel: () => _handleConfirmRisk(false),
      ),
    );
    setState(() => _currentStep = 3);
  }

  Future<void> _handleConfirmRisk(bool confirmed) async {
    _addUserMessage(confirmed ? '네, 확인했어요' : '아니오, 다시 볼래요');
    _disableLastSelection();

    if (!confirmed) {
      // 아니오 선택 시 한번 더 확인
      await _addBotMessage(
        ChatItem.textMessage('괜찮아요! 천천히 확인하시는 게 좋아요 😊'),
      );
      await _addBotMessage(
        ChatItem.cardMessage(
          title: '다시 한번 정리해 드릴게요!',
          description: '• 펀드는 원금 손실 위험이 있어요\n• 최대 100%까지 손실이 발생할 수 있어요\n• 투자 손실은 투자자 본인에게 귀속돼요',
        ),
      );
      await _addBotMessage(
        ChatItem.confirmCard(
          title: '이제 충분히 이해가 되셨나요?',
          description: '언제든 궁금한 점이 있으시면 고객센터로 문의해 주세요!',
          confirmText: '네, 이해했어요!',
          cancelText: '가입을 취소할게요',
          onConfirm: () => _handleSecondConfirm(true),
          onCancel: () => _handleSecondConfirm(false),
        ),
      );
      return;
    }

    await _proceedToInvestmentType();
  }

  Future<void> _handleSecondConfirm(bool confirmed) async {
    _addUserMessage(confirmed ? '네, 이해했어요!' : '가입을 취소할게요');
    _disableLastSelection();

    if (!confirmed) {
      await _addBotMessage(
        ChatItem.textMessage('알겠어요! 다음에 다시 찾아와 주세요 🙋‍♀️\n언제든 환영이에요!'),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.pop(context);
      return;
    }

    await _proceedToInvestmentType();
  }

  Future<void> _proceedToInvestmentType() async {
    await _addBotMessage(
      ChatItem.textMessage('좋아요! 그럼 본격적으로 시작해 볼까요? 🚀'),
    );

    await _addBotMessage(
      ChatItem.selectionCard(
        question: '어떻게 투자할까요?',
        options: ['매일, 매주, 매월 투자하기', '한 번만 투자하기'],
        onSelect: _handleInvestmentType,
      ),
    );
    setState(() => _currentStep = 4);
  }

  Future<void> _handleInvestmentType(String answer) async {
    _addUserMessage(answer);
    _disableLastSelection();

    if (answer.contains('매일') || answer.contains('매주') || answer.contains('매월')) {
      setState(() => _investmentType = '매일, 매주, 매월 투자하기');
      await _addBotMessage(ChatItem.textMessage('꾸준히 투자하시는군요! 좋은 습관이에요 💪'));
      
      // 자동이체 주기 선택 - 휠 피커 사용
      await _addBotMessage(
        ChatItem.wheelPicker(
          pickerType: 'schedule', // 주기 선택 모드
          onSelect: (frequency, day) {
            if (frequency == '매일') {
              _handleInvestmentSchedule('매일');
            } else if (frequency == '매주' && day.isNotEmpty) {
              setState(() {
                _investmentSchedule = '매주';
                _weeklyDay = day;
              });
              _handleScheduleComplete('매주 $day');
            } else if (frequency == '매월' && day.isNotEmpty) {
              setState(() {
                _investmentSchedule = '매월';
                _monthlyDay = int.parse(day.replaceAll('일', ''));
              });
              _handleScheduleComplete('매월 $day');
            } else {
              // 주기만 선택하고 날짜/요일은 아직 선택하지 않은 경우
              _handleInvestmentSchedule(frequency);
            }
          },
        ),
      );
      setState(() => _currentStep = 4);
    } else {
      setState(() => _investmentType = '한 번만 투자하기');
      await _addBotMessage(ChatItem.textMessage('좋아요! 원하실 때 추가 투자도 가능해요 😊'));

      final accountBalance = 5000000; // 잔액 (예시)
      _currentAccountBalance = accountBalance;
      await _addBotMessage(
        ChatItem.amountInput(
          question: '얼마를 투자하실 건가요?',
          hint: '1,000원 이상, 잔액 이하로 입력해 주세요',
          accountName: '내 통장',
          accountNumber: '1234',
          accountBalance: accountBalance,
          onSubmit: _handleAmountSubmit,
        ),
      );
      setState(() => _currentStep = 5);
    }
  }

  Future<void> _handleInvestmentSchedule(String schedule) async {
    // 주기 선택 휠 피커에서 이미 선택했으므로 바로 처리
    if (schedule == '매일') {
      _addUserMessage('매일');
      setState(() => _investmentSchedule = '매일');
      _disableLastSelection();
      _handleScheduleComplete('매일');
    } else if (schedule == '매주') {
      // 매주는 요일 선택 필요 - 휠 피커에서 이미 선택했을 수 있음
      // 하지만 여기서는 주기만 받았으므로 요일 선택 휠 피커를 보여줌
      _addUserMessage('매주');
      setState(() => _investmentSchedule = '매주');
      _disableLastSelection();
      await _addBotMessage(
        ChatItem.wheelPicker(
          pickerType: 'weekly',
          onSelect: (frequency, day) {
            setState(() => _weeklyDay = day);
            _handleScheduleComplete('매주 $day');
          },
        ),
      );
    } else if (schedule == '매월') {
      // 매월은 일자 선택 필요 - 휠 피커에서 이미 선택했을 수 있음
      // 하지만 여기서는 주기만 받았으므로 일자 선택 휠 피커를 보여줌
      _addUserMessage('매월');
      setState(() => _investmentSchedule = '매월');
      _disableLastSelection();
      await _addBotMessage(
        ChatItem.wheelPicker(
          pickerType: 'monthly',
          onSelect: (frequency, day) {
            setState(() => _monthlyDay = int.parse(day.replaceAll('일', '')));
            _handleScheduleComplete('매월 $day');
          },
        ),
      );
    }
  }

  Future<void> _handleScheduleComplete(String scheduleText) async {
    await _addBotMessage(ChatItem.textMessage('$scheduleText로 자동이체 하시는군요! 알겠어요 📅'));

    final accountBalance = 5000000; // 잔액 (예시)
    _currentAccountBalance = accountBalance;
    await _addBotMessage(
      ChatItem.amountInput(
        question: '얼마를 투자하실 건가요?',
        hint: '1,000원 이상, 잔액 이하로 입력해 주세요',
        accountName: '내 통장',
        accountNumber: '1234',
        accountBalance: accountBalance,
        onSubmit: _handleAmountSubmit,
      ),
    );
    setState(() => _currentStep = 5);
  }

  Future<void> _handleAmountSubmit(int amount) async {
    // 잔액 검증 (이중 체크)
    if (_currentAccountBalance != null && amount > _currentAccountBalance!) {
      await _addBotMessage(
        ChatItem.textMessage(
          '출금 계좌 잔액(${_formatNumber(_currentAccountBalance!)}원)보다 많은 금액은 투자할 수 없어요.\n다시 입력해 주세요 💰',
        ),
      );
      // 금액 입력 카드 다시 표시
      await _addBotMessage(
        ChatItem.amountInput(
          question: '얼마를 투자하실 건가요?',
          hint: '1,000원 이상, 잔액 이하로 입력해 주세요',
          accountName: '내 통장',
          accountNumber: '1234',
          accountBalance: _currentAccountBalance,
          onSubmit: _handleAmountSubmit,
        ),
      );
      // 입력 필드 초기화
      _amountController.clear();
      return;
    }

    _addUserMessage('${_formatNumber(amount)}원');
    setState(() => _investmentAmount = amount);
    _disableLastSelection();

    await _addBotMessage(
      ChatItem.textMessage('${_formatNumber(amount)}원이요! 알겠어요 💰'),
    );

    await _addBotMessage(
      ChatItem.accountConfirmCard(
        amount: amount,
        accountName: '내 통장',
        accountNumber: '1234',
        accountBalance: 5000000, // 잔액 (예시)
        onConfirm: () => _handleAccountConfirm(true),
        onChange: () => _handleAccountConfirm(true),
      ),
    );
    setState(() => _currentStep = 6);
  }

  Future<void> _handleAccountConfirm(bool confirmed) async {
    _addUserMessage('확인했어요');
    _disableLastSelection();

    await _addBotMessage(
      ChatItem.textMessage('거의 다 왔어요! 마지막으로 확인해 주세요 📋'),
    );

    await _addBotMessage(
      ChatItem.summaryCard(
        fundName: widget.fundTitle,
        amount: _investmentAmount!,
        investmentType: _getInvestmentTypeText(),
        accountInfo: '내 통장 (1234)',
        onSubmit: _handleFinalSubmit,
      ),
    );
    setState(() => _currentStep = 7);
  }

  Future<void> _handleFinalSubmit() async {
    _disableLastSelection();

    // 모의투자라면 전자서명 단계를 건너뛰거나 가상 서명으로 처리
    if (widget.isMockInvestment) {
      await _addBotMessage(ChatItem.textMessage('모의투자 신청을 처리 중입니다... ⚙️'));

      // 모의투자 전용 API 호출
      // bool success = await MockApi.subscribeMockFund(widget.fundTitle, _investmentAmount!);
      await Future.delayed(const Duration(seconds: 1));

      await _addBotMessage(
        ChatItem.textMessage('모의투자 가입 완료! 🎉\n포트폴리오에서 수익률을 확인해보세요!'),
      );

      setState(() => _isCompleted = true);
      return;
    }
    
    // 펀드 가입 API 호출
    await _addBotMessage(
      ChatItem.textMessage('펀드 가입을 처리 중입니다... ⚙️'),
    );

    try {
      // 투자 타입과 주기 정보 설정
      String? cycleType;
      String? weeklyDay;
      int? monthlyDay;
      
      if (_investmentType == '매일, 매주, 매월 투자하기') {
        // 자동이체인 경우
        if (_investmentSchedule == '매일') {
          cycleType = '매일';
        } else if (_investmentSchedule == '매주') {
          cycleType = '매주';
          weeklyDay = _weeklyDay; // "월요일" 등
        } else if (_investmentSchedule == '매월') {
          cycleType = '매월';
          monthlyDay = _monthlyDay; // 1~31
        }
      }

      // API 호출
      final result = await FundSubscriptionApi.subscribe(
        fundCode: widget.fundCode ?? widget.fundTitle, // fundCode가 있으면 사용, 없으면 fundTitle 사용 (하위 호환)
        tradeAmount: _investmentAmount!,
        investmentType: _investmentType ?? '한 번만 투자하기',
        cycleType: cycleType,
        weeklyDay: weeklyDay,
        monthlyDay: monthlyDay,
      );

      if (result['success'] == true) {
        await _addBotMessage(
          ChatItem.textMessage('가입이 완료되었어요! 🎉\n좋은 결과 있으시길 바랄게요!'),
        );
        
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          setState(() => _isCompleted = true);
        }
      } else {
        // 중복 가입인 경우 완료 화면으로 이동
        final errorMessage = result['message'] as String? ?? '가입 처리 중 오류가 발생했어요. 다시 시도해 주세요.';
        if (errorMessage.contains('이미 가입한 펀드') || errorMessage.contains('이미 가입된 펀드')) {
          // 기존 가입 정보 추출
          if (result['existingSubscription'] != null) {
            final existingInfo = result['existingSubscription'] as Map<String, dynamic>;
            _existingSubscriptionAmount = existingInfo['amount'] as int?;
            _existingSubscriptionStartAt = existingInfo['startAt'] as String?;
          }
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            setState(() {
              _isDuplicateSubscription = true;
              _isCompleted = true;
            });
          }
        } else {
          await _addBotMessage(
            ChatItem.textMessage('$errorMessage 😢'),
          );
        }
      }
    } catch (e) {
      print('펀드 가입 오류: $e');
      // DioException인 경우 백엔드 메시지 확인
      String errorMessage = '가입 처리 중 오류가 발생했어요. 다시 시도해 주세요.';
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData['message'] != null) {
          errorMessage = responseData['message'] as String;
        }
      }
      
      // 중복 가입인 경우 완료 화면으로 이동
      if (errorMessage.contains('이미 가입한 펀드') || errorMessage.contains('이미 가입된 펀드')) {
        // 기존 가입 정보 추출
        if (e is DioException && e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData is Map && responseData['existingSubscription'] != null) {
            final existingInfo = responseData['existingSubscription'] as Map<String, dynamic>;
            _existingSubscriptionAmount = existingInfo['amount'] as int?;
            _existingSubscriptionStartAt = existingInfo['startAt'] as String?;
          }
        }
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          setState(() {
            _isDuplicateSubscription = true;
            _isCompleted = true;
          });
        }
      } else {
        await _addBotMessage(
          ChatItem.textMessage('$errorMessage 😢'),
        );
      }
    }
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _getInvestmentTypeText() {
    String investmentTypeText = _investmentType ?? '한 번만 투자하기';
    if (_investmentType == '매일, 매주, 매월 투자하기') {
      if (_weeklyDay != null) {
        investmentTypeText = '매주 $_weeklyDay';
      } else if (_monthlyDay != null) {
        investmentTypeText = '매월 $_monthlyDay일';
      } else if (_investmentSchedule == '매일') {
        investmentTypeText = '매일';
      } else {
        // 기본값 (선택이 안 된 경우)
        investmentTypeText = '매일, 매주, 매월 투자하기';
      }
    }
    return investmentTypeText;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            '펀드 가입',
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
              value: _currentStep / 7,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 3,
            ),
          ),
          // 채팅 영역
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 화면 터치 시 키패드 닫기
                FocusScope.of(context).unfocus();
              },
              child: Builder(
                builder: (context) {
                  final bottomInset = MediaQuery.of(context).padding.bottom;
                  const extraPadding = 60.0; // 기기 하단바와 겹치지 않게 추가 여백 (28 -> 60으로 증가)
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      20 + bottomInset + extraPadding,
                    ),
                    itemCount: _chatItems.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _chatItems.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildChatItem(_chatItems[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isDuplicateSubscription ? Icons.info_outline_rounded : Icons.check_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isDuplicateSubscription ? '이미 가입된 펀드입니다.' : '펀드가입 완료!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _isDuplicateSubscription ? Colors.red.shade700 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isDuplicateSubscription 
                        ? '이미 가입하신 펀드입니다.\n다른 펀드를 선택해 주세요.' 
                        : '투자의 좋은 시작이에요 🌱',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildCompletionRow('펀드', widget.fundTitle),
                          const SizedBox(height: 16),
                          _buildCompletionRow(
                            '투자금액', 
                            _isDuplicateSubscription && _existingSubscriptionAmount != null
                                ? '${_formatNumber(_existingSubscriptionAmount!)}원'
                                : '${_formatNumber(_investmentAmount!)}원'
                          ),
                          const SizedBox(height: 16),
                          _buildCompletionRow(
                            '투자시작일', 
                            _isDuplicateSubscription && _existingSubscriptionStartAt != null
                                ? _existingSubscriptionStartAt!
                                : _getFormattedDate()
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false, // 모든 이전 화면 제거
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBotAvatar(),
          const SizedBox(height: 8), // 로고와 말풍선 사이 간격
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
              );
            },
          ),
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
          const SizedBox(height: 8), // 로고와 말풍선 사이 간격
          Padding(
            padding: const EdgeInsets.only(left: 4), // 약간 들여쓰기
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
              color: AppColors.primaryColor,
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
      case ChatItemType.wheelPicker:
        return _buildWheelPicker(item);
      case ChatItemType.confirm:
        return _buildConfirmCard(item);
      case ChatItemType.amountInput:
        return _buildAmountInputCard(item);
      case ChatItemType.accountConfirm:
        return _buildAccountConfirmCard(item);
      case ChatItemType.summary:
        return _buildSummaryCard(item);
      case ChatItemType.signature:
        return _buildSignatureCard(item);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextBubble(String text) {
    // 중복 가입 메시지인 경우 크게 표시
    final bool isDuplicateMessage = text.contains('이미 가입한 펀드');
    final double fontSize = isDuplicateMessage ? 18.0 : 15.0;
    final FontWeight fontWeight = isDuplicateMessage ? FontWeight.w600 : FontWeight.normal;
    final Color textColor = isDuplicateMessage ? Colors.red.shade700 : Colors.black87;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDuplicateMessage ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDuplicateMessage ? Border.all(color: Colors.red.shade200, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: isDuplicateMessage 
                ? Colors.red.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.5,
          color: textColor,
          fontWeight: fontWeight,
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
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
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
          _buildRichText(item.question!),
          const SizedBox(height: 18),
          ...item.options!.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: item.isDisabled ? null : () => item.onSelect!(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isDisabled
                        ? Colors.grey.shade100
                        : AppColors.primaryColor,
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade400
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
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
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWheelPicker(ChatItem item) {
    return _WheelPickerWidget(
      pickerType: item.wheelPickerType!,
      onSelect: item.onWheelSelect!,
      isDisabled: item.isDisabled,
    );
  }

  Widget _buildConfirmCard(ChatItem item) {
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.06),
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
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.isDisabled ? null : item.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: item.isDisabled
                    ? Colors.grey.shade100
                    : AppColors.primaryColor,
                foregroundColor: item.isDisabled
                    ? Colors.grey.shade400
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                item.confirmText ?? '확인했어요',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: item.isDisabled ? null : item.onCancel,
              style: TextButton.styleFrom(
                foregroundColor: item.isDisabled
                    ? Colors.grey.shade300
                    : Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                item.cancelText ?? '아니오',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputCard(ChatItem item) {
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
            item.question!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!item.isDisabled) ...[
            const SizedBox(height: 16),
            // 계좌 정보 표시
            if (item.accountName != null && item.accountBalance != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.accountName}${item.accountNumber != null ? ' (${item.accountNumber})' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _handleBalanceClick(item.accountBalance!),
                            child: Row(
                              children: [
                                Text(
                                  '잔액: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${_formatNumber(item.accountBalance!)}원',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.touch_app,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: item.hint ?? '금액 입력',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixText: '원',
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = _amountController.text.replaceAll(',', '');
                  final amount = int.tryParse(text);
                  if (amount != null && amount >= 1000) {
                    // 잔액 검증
                    if (item.accountBalance != null && amount > item.accountBalance!) {
                      // 잔액 초과 시 에러 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '출금 계좌 잔액(${_formatNumber(item.accountBalance!)}원)보다 많은 금액은 투자할 수 없어요.',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                    // 현재 잔액 저장
                    _currentAccountBalance = item.accountBalance;
                    item.onAmountSubmit!(amount);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleBalanceClick(int balance) async {
    // 잔액 전체를 입력 필드에 설정
    _amountController.text = _formatNumber(balance);
    
    // 확인 질문 표시
    await _addBotMessage(
      ChatItem.confirmCard(
        title: '잔액 전체를 투자하시겠어요?',
        description: '${_formatNumber(balance)}원을 투자하시면 계좌 잔액이 0원이 됩니다.\n정말 진행하시겠어요?',
        confirmText: '네, 전체 투자할게요',
        cancelText: '아니오, 다시 입력할게요',
        onConfirm: () => _handleFullBalanceConfirm(balance),
        onCancel: () => _handleFullBalanceCancel(),
      ),
    );
  }

  Future<void> _handleFullBalanceConfirm(int balance) async {
    _addUserMessage('네, 전체 투자할게요');
    _disableLastSelection();
    
    // 금액 제출
    await _handleAmountSubmit(balance);
  }

  Future<void> _handleFullBalanceCancel() async {
    _addUserMessage('아니오, 다시 입력할게요');
    _disableLastSelection();
    
    // 입력 필드 초기화
    _amountController.clear();
    
    await _addBotMessage(
      ChatItem.textMessage('알겠어요! 원하시는 금액을 입력해 주세요 💰'),
    );
    
    // 바로 투자 금액 입력 카드 표시
    final accountBalance = _currentAccountBalance ?? 5000000;
    await _addBotMessage(
      ChatItem.amountInput(
        question: '얼마를 투자하실 건가요?',
        hint: '1,000원 이상, 잔액 이하로 입력해 주세요',
        accountName: '내 통장',
        accountNumber: '1234',
        accountBalance: accountBalance,
        onSubmit: _handleAmountSubmit,
      ),
    );
  }

  Future<void> _handleChangeAmount() async {
    // 현재 금액 입력 카드 찾아서 비활성화
    _disableLastSelection();
    
    // 사용자 메시지 추가
    _addUserMessage('금액을 변경하고 싶어요');
    
    // 금액 입력 카드 다시 표시
    await _addBotMessage(
      ChatItem.textMessage('알겠어요! 다시 투자 금액을 입력해 주세요 💰'),
    );
    
    final accountBalance = _currentAccountBalance ?? 5000000;
    await _addBotMessage(
      ChatItem.amountInput(
        question: '얼마를 투자하실 건가요?',
        hint: '1,000원 이상, 잔액 이하로 입력해 주세요',
        accountName: '내 통장',
        accountNumber: '1234',
        accountBalance: accountBalance,
        onSubmit: _handleAmountSubmit,
      ),
    );
    
    // 입력 필드 초기화
    _amountController.clear();
  }

  Widget _buildAccountConfirmCard(ChatItem item) {
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
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '${_formatNumber(item.amount!)}원',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: '을\n아래 계좌에서 출금할게요 💳'),
              ],
            ),
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
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, 
                         color: AppColors.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '출금계좌',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${item.accountName} (${item.accountNumber})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (item.accountBalance != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 30), // 아이콘 너비만큼 여백
                      Text(
                        '잔액',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_formatNumber(item.accountBalance!)}원',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: item.isDisabled ? null : () => _handleChangeAmount(),
                  style: TextButton.styleFrom(
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '금액 변경',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: item.isDisabled ? null : item.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isDisabled
                        ? Colors.grey.shade100
                        : AppColors.primaryColor,
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade400
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인했어요',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ChatItem item) {
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
              Icon(Icons.receipt_long_outlined, 
                   color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                '가입 내용 요약',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('펀드명', item.fundName!),
                const SizedBox(height: 12),
                _buildSummaryRow('투자금액', '${_formatNumber(item.amount!)}원'),
                const SizedBox(height: 12),
                _buildSummaryRow('투자방식', item.investmentType!),
                const SizedBox(height: 12),
                _buildSummaryRow('출금계좌', item.accountInfo!),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade400, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '가입 즉시 투자금액이 출금돼요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: item.isDisabled ? null : () => _handleChangeAmount(),
                  style: TextButton.styleFrom(
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade300
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '금액 변경',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: item.isDisabled ? null : item.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isDisabled
                        ? Colors.grey.shade100
                        : AppColors.primaryColor,
                    foregroundColor: item.isDisabled
                        ? Colors.grey.shade400
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '펀드 가입하기 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
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

  Widget _buildRichText(String text) {
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final matches = regex.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      );
    }

    List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: Colors.black87,
        ),
        children: spans,
      ),
    );
  }
}

// ============== 데이터 클래스 ==============

enum ChatItemType {
  text,
  user,
  card,
  selection,
  wheelPicker,
  confirm,
  amountInput,
  accountConfirm,
  summary,
  signature,
}

class ChatItem {
  final ChatItemType type;
  final bool isUser;
  final String? text;
  final String? title;
  final String? description;
  final String? question;
  final String? hint;
  final List<String>? options;
  final Function(String)? onSelect;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Function(int)? onAmountSubmit;
  final int? amount;
  final String? accountName;
  final String? accountNumber;
  final int? accountBalance; // 계좌 잔액
  final String? fundName;
  final String? investmentType;
  final String? accountInfo;
  final VoidCallback? onSubmit;
  final bool isDisabled;
  // 전자서명 관련 필드
  final String? signatureId;
  final DateTime? signedAt;
  final String? hashPreview;
  // 휠 피커 관련 필드
  final String? wheelPickerType; // 'monthly' or 'weekly'
  final Function(String, String)? onWheelSelect; // (주기, 날짜/요일)

  ChatItem({
    required this.type,
    this.isUser = false,
    this.text,
    this.title,
    this.description,
    this.question,
    this.hint,
    this.options,
    this.onSelect,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.onAmountSubmit,
    this.amount,
    this.accountName,
    this.accountNumber,
    this.accountBalance,
    this.fundName,
    this.investmentType,
    this.accountInfo,
    this.onSubmit,
    this.isDisabled = false,
    this.signatureId,
    this.signedAt,
    this.hashPreview,
    this.wheelPickerType,
    this.onWheelSelect,
  });

  bool get hasInteraction => 
      type == ChatItemType.selection ||
      type == ChatItemType.wheelPicker ||
      type == ChatItemType.confirm ||
      type == ChatItemType.amountInput ||
      type == ChatItemType.accountConfirm ||
      type == ChatItemType.summary;

  ChatItem copyWithDisabled() {
    return ChatItem(
      type: type,
      isUser: isUser,
      text: text,
      title: title,
      description: description,
      question: question,
      hint: hint,
      options: options,
      onSelect: onSelect,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      onAmountSubmit: onAmountSubmit,
      amount: amount,
      accountName: accountName,
      accountNumber: accountNumber,
      accountBalance: accountBalance,
      fundName: fundName,
      investmentType: investmentType,
      accountInfo: accountInfo,
      onSubmit: onSubmit,
      signatureId: signatureId,
      signedAt: signedAt,
      hashPreview: hashPreview,
      wheelPickerType: wheelPickerType,
      onWheelSelect: onWheelSelect,
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
    required Function(String) onSelect,
  }) {
    return ChatItem(
      type: ChatItemType.selection,
      question: question,
      options: options,
      onSelect: onSelect,
    );
  }

  factory ChatItem.confirmCard({
    required String title,
    required String description,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return ChatItem(
      type: ChatItemType.confirm,
      title: title,
      description: description,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  factory ChatItem.amountInput({
    required String question,
    String? hint,
    String? accountName,
    String? accountNumber,
    int? accountBalance,
    required Function(int) onSubmit,
  }) {
    return ChatItem(
      type: ChatItemType.amountInput,
      question: question,
      hint: hint,
      accountName: accountName,
      accountNumber: accountNumber,
      accountBalance: accountBalance,
      onAmountSubmit: onSubmit,
    );
  }

  factory ChatItem.accountConfirmCard({
    required int amount,
    required String accountName,
    required String accountNumber,
    int? accountBalance,
    required VoidCallback onConfirm,
    required VoidCallback onChange,
  }) {
    return ChatItem(
      type: ChatItemType.accountConfirm,
      amount: amount,
      accountName: accountName,
      accountNumber: accountNumber,
      accountBalance: accountBalance,
      onConfirm: onConfirm,
    );
  }

  factory ChatItem.summaryCard({
    required String fundName,
    required int amount,
    required String investmentType,
    required String accountInfo,
    required VoidCallback onSubmit,
  }) {
    return ChatItem(
      type: ChatItemType.summary,
      fundName: fundName,
      amount: amount,
      investmentType: investmentType,
      accountInfo: accountInfo,
      onSubmit: onSubmit,
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

  factory ChatItem.wheelPicker({
    required String pickerType, // 'monthly' or 'weekly'
    required Function(String, String) onSelect, // (주기, 날짜/요일)
  }) {
    return ChatItem(
      type: ChatItemType.wheelPicker,
      wheelPickerType: pickerType,
      onWheelSelect: onSelect,
    );
  }
}

// ============== 유틸리티 클래스 ==============

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final numericValue = newValue.text.replaceAll(',', '');
    final intValue = int.tryParse(numericValue);
    if (intValue == null) return oldValue;

    final formatted = intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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

// ============== 휠 피커 위젯 ==============

class _WheelPickerWidget extends StatefulWidget {
  final String pickerType; // 'monthly' or 'weekly'
  final Function(String, String) onSelect; // (주기, 날짜/요일)
  final bool isDisabled;

  const _WheelPickerWidget({
    required this.pickerType,
    required this.onSelect,
    this.isDisabled = false,
  });

  @override
  State<_WheelPickerWidget> createState() => _WheelPickerWidgetState();
}

class _WheelPickerWidgetState extends State<_WheelPickerWidget> {
  final ScrollController _frequencyController = ScrollController();
  final ScrollController _dayController = ScrollController();
  
  String _selectedFrequency = '매월';
  String _selectedDay = '1일';
  
  List<String> get _frequencies => ['매일', '매주', '매월'];
  List<String> get _days {
    if (widget.pickerType == 'schedule') {
      // 주기 선택 모드에서는 선택된 주기에 따라 날짜/요일 표시
      if (_selectedFrequency == '매주') {
        return ['월요일', '화요일', '수요일', '목요일', '금요일'];
      } else if (_selectedFrequency == '매월') {
        return List.generate(31, (index) => '${index + 1}일');
      } else {
        // 매일은 날짜 선택 불필요
        return [];
      }
    } else if (widget.pickerType == 'weekly') {
      return ['월요일', '화요일', '수요일', '목요일', '금요일'];
    } else {
      return List.generate(31, (index) => '${index + 1}일');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.pickerType == 'schedule') {
      // 주기 선택 모드 - 기본값으로 매월 선택하고 날짜도 함께 표시
      _selectedFrequency = '매월';
      final monthlyDays = List.generate(31, (index) => '${index + 1}일');
      _selectedDay = monthlyDays[0]; // 기본값: 1일
    } else if (widget.pickerType == 'weekly') {
      _selectedFrequency = '매주';
      _selectedDay = '월요일';
    } else {
      _selectedFrequency = '매월';
      _selectedDay = '1일';
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter(_frequencyController, _frequencies.indexOf(_selectedFrequency));
      if (_days.isNotEmpty && _selectedDay.isNotEmpty) {
        final dayIndex = _days.indexOf(_selectedDay);
        if (dayIndex >= 0) {
          _scrollToCenter(_dayController, dayIndex);
        }
      }
    });
    
    _frequencyController.addListener(_onFrequencyScroll);
    _dayController.addListener(_onDayScroll);
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _onFrequencyScroll() {
    if (!_frequencyController.hasClients) return;
    final index = _getCenterIndex(_frequencyController);
    if (index >= 0 && index < _frequencies.length) {
      final newFrequency = _frequencies[index];
      if (newFrequency != _selectedFrequency) {
        setState(() {
          _selectedFrequency = newFrequency;
          // 주기 변경 시 날짜/요일 초기화
          if (widget.pickerType == 'schedule') {
            if (newFrequency == '매주' && _days.isNotEmpty) {
              _selectedDay = _days[0];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_dayController.hasClients) {
                  _scrollToCenter(_dayController, 0);
                }
              });
            } else if (newFrequency == '매월' && _days.isNotEmpty) {
              _selectedDay = _days[0];
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_dayController.hasClients) {
                  _scrollToCenter(_dayController, 0);
                }
              });
            } else {
              _selectedDay = '';
            }
          }
        });
        _onSelectionChanged();
      }
    }
  }

  void _onDayScroll() {
    if (!_dayController.hasClients) return;
    final index = _getCenterIndex(_dayController);
    if (index >= 0 && index < _days.length) {
      final newDay = _days[index];
      if (newDay != _selectedDay) {
        setState(() {
          _selectedDay = newDay;
        });
        _onSelectionChanged();
      }
    }
  }

  void _onSelectionChanged() {
    // 주기 선택 모드에서는 확인 버튼을 눌러야만 전달
    // 스크롤 중에는 전달하지 않음
  }

  int _getCenterIndex(ScrollController controller) {
    if (!controller.hasClients) return -1;
    final offset = controller.offset;
    const itemHeight = 50.0;
    return (offset / itemHeight).round();
  }

  void _scrollToCenter(ScrollController controller, int index) {
    if (!controller.hasClients) return;
    const itemHeight = 50.0;
    final targetOffset = index * itemHeight;
    controller.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildWheelColumn(
                  controller: _frequencyController,
                  items: _frequencies,
                  selectedItem: _selectedFrequency,
                ),
              ),
              if (widget.pickerType == 'schedule' && _days.isNotEmpty) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: _buildWheelColumn(
                    controller: _dayController,
                    items: _days,
                    selectedItem: _selectedDay,
                  ),
                ),
              ] else if (widget.pickerType != 'schedule') ...[
                const SizedBox(width: 20),
                Expanded(
                  child: _buildWheelColumn(
                    controller: _dayController,
                    items: _days,
                    selectedItem: _selectedDay,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isDisabled ? null : () {
                if (widget.pickerType == 'schedule') {
                  if (_selectedFrequency == '매일') {
                    widget.onSelect(_selectedFrequency, '');
                  } else {
                    widget.onSelect(_selectedFrequency, _selectedDay);
                  }
                } else {
                  widget.onSelect(_selectedFrequency, _selectedDay);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDisabled
                    ? Colors.grey.shade100
                    : AppColors.primaryColor,
                foregroundColor: widget.isDisabled
                    ? Colors.grey.shade400
                    : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelColumn({
    required ScrollController controller,
    required List<String> items,
    required String selectedItem,
  }) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 선택 영역 표시 (가운데 노란색 선)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.primaryColor, width: 2),
                  bottom: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          // 스크롤 가능한 리스트 (3개만 보이도록)
          ListView.builder(
            controller: controller,
            padding: const EdgeInsets.symmetric(vertical: 50),
            itemCount: items.length,
            itemExtent: 50,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selectedItem;
              return Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.black : Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

