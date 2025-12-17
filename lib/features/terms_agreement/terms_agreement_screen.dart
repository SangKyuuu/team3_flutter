import 'package:flutter/material.dart';
import '../home/constants/app_colors.dart';

class TermsAgreementScreen extends StatefulWidget {
  final String fundTitle;
  final String badge;
  final String yieldText;

  const TermsAgreementScreen({
    super.key,
    required this.fundTitle,
    required this.badge,
    required this.yieldText,
  });

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<ChatItem> _chatItems = [];
  bool _isTyping = false;
  int _currentStep = 0;

  // 문서 확인 상태
  bool _checkedCoreSummary = false; // 핵심상품설명서
  bool _checkedSimpleGuide = false; // 간이투자설명서
  bool _checkedFullGuide = false; // 투자설명서
  bool _checkedTerms = false; // 집합투자규약

  bool get _allChecked =>
      _checkedCoreSummary &&
      _checkedSimpleGuide &&
      _checkedFullGuide &&
      _checkedTerms;

  @override
  void initState() {
    super.initState();
    _startConversation();
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

  Future<void> _startConversation() async {
    await _addBotMessage(
      ChatItem.cardMessage(
        title: '거의 다 왔어요! 📄',
        description: '가입 전에 중요한 서류들을 확인해 주세요.\n각 문서를 눌러서 내용을 확인하시면 돼요!',
      ),
      delay: 300,
    );

    await _addBotMessage(
      ChatItem.textMessage('먼저 펀드 설명서부터 확인해 볼까요? 🔍'),
    );

    await _showDocumentsCard();
  }

  Future<void> _showDocumentsCard() async {
    await _addBotMessage(
      ChatItem.documentsCard(
        onDocumentTap: _handleDocumentTap,
        checkedCoreSummary: _checkedCoreSummary,
        checkedSimpleGuide: _checkedSimpleGuide,
        checkedFullGuide: _checkedFullGuide,
        checkedTerms: _checkedTerms,
        onConfirm: _handleConfirm,
        allChecked: _allChecked,
      ),
    );
    setState(() => _currentStep = 1);
  }

  void _handleDocumentTap(String documentType) {
    // 문서 상세 보기 (바텀시트로 표시)
    _showDocumentDetail(documentType);
  }

  void _showDocumentDetail(String documentType) {
    String title;
    String content;

    switch (documentType) {
      case 'core':
        title = '핵심상품설명서';
        content = '''
[핵심상품설명서]

1. 상품 개요
본 펀드는 국내외 주식 및 채권에 분산 투자하여 안정적인 수익을 추구하는 혼합형 펀드입니다.

2. 주요 투자 대상
• 국내 주식: 40~60%
• 해외 주식: 20~30%
• 채권: 10~30%

3. 투자 위험
• 원금 손실 가능성이 있습니다.
• 시장 상황에 따라 수익률이 변동될 수 있습니다.

4. 수수료
• 선취판매수수료: 없음
• 환매수수료: 90일 미만 환매 시 이익금의 70%

5. 기타 유의사항
• 과거의 운용실적이 미래의 수익을 보장하지 않습니다.
• 예금자보호법에 따라 보호되지 않습니다.
''';
        break;
      case 'simple':
        title = '간이투자설명서';
        content = '''
[간이투자설명서]

1. 펀드의 명칭
${widget.fundTitle}

2. 펀드의 종류
혼합자산, 개방형, 추가형, 종류형

3. 투자목적
국내외 다양한 자산에 분산 투자하여 안정적인 투자수익을 추구합니다.

4. 위험등급
${widget.badge}

5. 보수 및 수수료
• 총보수: 연 0.5%
• 판매보수: 연 0.3%
• 운용보수: 연 0.15%

6. 환매 방법
• 영업일 15시 이전: 제3영업일 기준가격으로 환매
• 영업일 15시 이후: 제4영업일 기준가격으로 환매
''';
        break;
      case 'full':
        title = '투자설명서';
        content = '''
[투자설명서]

제1장 총칙
본 투자설명서는 투자자가 펀드에 가입하기 전에 반드시 읽어야 하는 문서입니다.

제2장 펀드의 개요
1. 펀드의 명칭: ${widget.fundTitle}
2. 펀드의 종류: 혼합자산, 개방형, 추가형
3. 운용기간: 별도 정함 없음

제3장 투자목적 및 운용전략
1. 투자목적
국내외 주식, 채권 등에 분산 투자하여 안정적인 투자수익을 추구합니다.

2. 운용전략
시장 상황에 따라 주식과 채권의 비중을 탄력적으로 조절합니다.

제4장 투자위험
1. 시장위험: 주식시장, 채권시장 등의 가격 변동에 따른 위험
2. 신용위험: 발행자의 재무상태 악화에 따른 위험
3. 환율위험: 해외자산 투자 시 환율 변동에 따른 위험

제5장 수수료 및 보수
상세 내용은 핵심상품설명서를 참조해 주세요.
''';
        break;
      case 'terms':
        title = '집합투자규약';
        content = '''
[집합투자규약 (약관)]

제1조 (목적)
이 규약은 투자자의 권익 보호와 펀드의 효율적인 운용을 위해 필요한 사항을 정함을 목적으로 합니다.

제2조 (용어의 정의)
• "수익자"란 수익증권을 보유한 자를 말합니다.
• "집합투자업자"란 펀드를 운용하는 자를 말합니다.

제3조 (수익자의 권리)
1. 수익자는 언제든지 수익증권의 환매를 청구할 수 있습니다.
2. 수익자는 수익자총회에 참석하여 의결권을 행사할 수 있습니다.

제4조 (수익자의 의무)
1. 수익자는 본 규약 및 관련 법규를 준수해야 합니다.
2. 수익자는 정확한 개인정보를 제공해야 합니다.

제5조 (분배금)
1. 분배금은 회계기간 종료 후 수익자에게 지급됩니다.
2. 분배금 지급방식은 현금 또는 재투자 중 선택할 수 있습니다.

제6조 (규약의 변경)
1. 규약 변경 시 수익자총회의 의결을 거쳐야 합니다.
2. 단, 법령 개정에 따른 변경은 수익자총회 없이 가능합니다.
''';
        break;
      default:
        title = '문서';
        content = '내용을 불러올 수 없습니다.';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDocumentBottomSheet(title, content, documentType),
    );
  }

  Widget _buildDocumentBottomSheet(String title, String content, String documentType) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.8,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ),
          // 확인 버튼
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _markDocumentAsRead(documentType);
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
                  '확인했어요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markDocumentAsRead(String documentType) {
    setState(() {
      switch (documentType) {
        case 'core':
          _checkedCoreSummary = true;
          break;
        case 'simple':
          _checkedSimpleGuide = true;
          break;
        case 'full':
          _checkedFullGuide = true;
          break;
        case 'terms':
          _checkedTerms = true;
          break;
      }

      // 채팅 리스트에서 마지막 documentsCard 업데이트
      for (int i = _chatItems.length - 1; i >= 0; i--) {
        if (_chatItems[i].type == ChatItemType.documents) {
          _chatItems[i] = ChatItem.documentsCard(
            onDocumentTap: _handleDocumentTap,
            checkedCoreSummary: _checkedCoreSummary,
            checkedSimpleGuide: _checkedSimpleGuide,
            checkedFullGuide: _checkedFullGuide,
            checkedTerms: _checkedTerms,
            onConfirm: _handleConfirm,
            allChecked: _allChecked,
          );
          break;
        }
      }
    });

    // 체크 완료 메시지
    String docName;
    switch (documentType) {
      case 'core':
        docName = '핵심상품설명서';
        break;
      case 'simple':
        docName = '간이투자설명서';
        break;
      case 'full':
        docName = '투자설명서';
        break;
      case 'terms':
        docName = '집합투자규약';
        break;
      default:
        docName = '문서';
    }

    _addUserMessage('$docName 확인 완료');

    // 모두 체크했으면 축하 메시지
    if (_allChecked) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _addBotMessage(
          ChatItem.textMessage('모든 서류를 확인하셨네요! 👏\n이제 아래 버튼을 눌러 다음 단계로 진행해 주세요.'),
        );
      });
    }
  }

  void _handleConfirm() {
    if (_allChecked) {
      Navigator.pop(context, true); // 다음 단계로 진행
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '서류 확인',
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
              value: _currentStep / 2,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 3,
            ),
          ),
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
        color: const Color(0xFFFFF4E0),
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
                maxWidth: MediaQuery.of(context).size.width * 0.8,
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
      case ChatItemType.documents:
        return _buildDocumentsCard(item);
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

  Widget _buildDocumentsCard(ChatItem item) {
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
              Icon(Icons.folder_outlined, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                '펀드 설명서',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            title: '핵심상품설명서',
            isChecked: item.checkedCoreSummary!,
            onTap: () => item.onDocumentTap!('core'),
          ),
          const SizedBox(height: 10),
          _buildDocumentItem(
            title: '간이투자설명서',
            isChecked: item.checkedSimpleGuide!,
            onTap: () => item.onDocumentTap!('simple'),
          ),
          const SizedBox(height: 10),
          _buildDocumentItem(
            title: '투자설명서',
            isChecked: item.checkedFullGuide!,
            onTap: () => item.onDocumentTap!('full'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.gavel_outlined, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                '상품 이용 약관',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            title: '집합투자규약',
            isChecked: item.checkedTerms!,
            onTap: () => item.onDocumentTap!('terms'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.allChecked! ? item.onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: item.allChecked!
                    ? AppColors.primaryColor
                    : Colors.grey.shade200,
                foregroundColor: item.allChecked!
                    ? Colors.white
                    : Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                item.allChecked! ? '모두 확인했어요 ✓' : '모든 서류를 확인해 주세요',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isChecked ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primaryColor.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? AppColors.primaryColor.withOpacity(0.3) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.circle_outlined,
              color: isChecked ? AppColors.primaryColor : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isChecked ? AppColors.primaryColor : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isChecked ? AppColors.primaryColor : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ============== 데이터 클래스 ==============

enum ChatItemType {
  text,
  user,
  card,
  documents,
}

class ChatItem {
  final ChatItemType type;
  final bool isUser;
  final String? text;
  final String? title;
  final String? description;
  final void Function(String)? onDocumentTap;
  final bool? checkedCoreSummary;
  final bool? checkedSimpleGuide;
  final bool? checkedFullGuide;
  final bool? checkedTerms;
  final VoidCallback? onConfirm;
  final bool? allChecked;

  ChatItem({
    required this.type,
    this.isUser = false,
    this.text,
    this.title,
    this.description,
    this.onDocumentTap,
    this.checkedCoreSummary,
    this.checkedSimpleGuide,
    this.checkedFullGuide,
    this.checkedTerms,
    this.onConfirm,
    this.allChecked,
  });

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

  factory ChatItem.documentsCard({
    required void Function(String) onDocumentTap,
    required bool checkedCoreSummary,
    required bool checkedSimpleGuide,
    required bool checkedFullGuide,
    required bool checkedTerms,
    required VoidCallback onConfirm,
    required bool allChecked,
  }) {
    return ChatItem(
      type: ChatItemType.documents,
      onDocumentTap: onDocumentTap,
      checkedCoreSummary: checkedCoreSummary,
      checkedSimpleGuide: checkedSimpleGuide,
      checkedFullGuide: checkedFullGuide,
      checkedTerms: checkedTerms,
      onConfirm: onConfirm,
      allChecked: allChecked,
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

