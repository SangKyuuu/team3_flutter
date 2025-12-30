import 'package:flutter/material.dart';
import '../../data/service/api_client.dart';
import '../home/constants/app_colors.dart';
import '../subscription/fund_subscription_screen.dart';
import '../fund_detail/pdf_viewer_screen.dart';

class TermsAgreementScreen extends StatefulWidget {
  final String fundTitle;
  final String? fundCode;  // 펀드 코드 추가
  final String badge;
  final String yieldText;

  const TermsAgreementScreen({
    super.key,
    required this.fundTitle,
    this.fundCode,  // 선택적으로 받음
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

  // 문서 확인 상태 (3개로 변경)
  bool _checkedCoreAndFull = false; // 핵심상품설명서 및 투자설명서
  bool _checkedSimpleGuide = false; // 간이 투자설명서
  bool _checkedTerms = false; // 약관

  bool get _allChecked =>
      _checkedCoreAndFull &&
      _checkedSimpleGuide &&
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
        checkedCoreAndFull: _checkedCoreAndFull,
        checkedSimpleGuide: _checkedSimpleGuide,
        checkedTerms: _checkedTerms,
        onConfirm: _handleConfirm,
        allChecked: _allChecked,
      ),
    );
    setState(() => _currentStep = 1);
  }

  void _handleDocumentTap(String documentType) {
    // 체크된 문서를 클릭하면 체크 해제, 체크 안 된 문서는 상세 보기
    final isChecked = _isDocumentChecked(documentType);
    if (isChecked) {
      // 체크 해제
      _toggleDocumentCheck(documentType);
    } else {
      // 문서 상세 보기 (바텀시트로 표시)
      _showDocumentDetail(documentType);
    }
  }

  bool _isDocumentChecked(String documentType) {
    switch (documentType) {
      case 'coreAndFull':
        return _checkedCoreAndFull;
      case 'simple':
        return _checkedSimpleGuide;
      case 'terms':
        return _checkedTerms;
      default:
        return false;
    }
  }

  /// 문서 URL 생성
  /// 관리자 페이지와 동일한 경로 형식 사용
  /// 경로: /upload/{type}/{fundCode}_{한글명}.pdf
  /// - 약관: /upload/terms/{fundCode}_약관.pdf
  /// - 투자설명서: /upload/invest/{fundCode}_투자설명서.pdf
  /// - 간이투자설명서: /upload/summary/{fundCode}_간이투자설명서.pdf
  String? _buildDocumentUrl(String documentType) {
    if (widget.fundCode == null || widget.fundCode!.isEmpty) {
      return null;
    }

    final fundCode = widget.fundCode!;
    // ApiClient의 baseUrl 사용 (http://10.0.2.2:8080/bnk)
    final baseUrl = ApiClient.dio.options.baseUrl;
    String relativePath;

    switch (documentType) {
      case 'coreAndFull':
        // 투자설명서 - 관리자 페이지와 동일: /upload/invest/{fundCode}_투자설명서.pdf
        relativePath = '/upload/invest/${fundCode}_투자설명서.pdf';
        break;
      case 'simple':
        // 간이투자설명서 - 관리자 페이지와 동일: /upload/summary/{fundCode}_간이투자설명서.pdf
        relativePath = '/upload/summary/${fundCode}_간이투자설명서.pdf';
        break;
      case 'terms':
        // 약관 - 관리자 페이지와 동일: /upload/terms/{fundCode}_약관.pdf
        relativePath = '/upload/terms/${fundCode}_약관.pdf';
        break;
      default:
        return null;
    }

    // 전체 URL 생성: http://10.0.2.2:8080/bnk/upload/invest/{fundCode}_투자설명서.pdf
    return '$baseUrl$relativePath';
  }

  void _showDocumentDetail(String documentType) {
    String title;

    switch (documentType) {
      case 'coreAndFull':
        title = '투자설명서';
        break;
      case 'simple':
        title = '간이 투자설명서';
        break;
      case 'terms':
        title = '약관';
        break;
      default:
        title = '문서';
    }

    // 문서 URL 생성
    final documentUrl = _buildDocumentUrl(documentType);

    if (documentUrl == null) {
      // fundCode가 없거나 문서 타입이 잘못된 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title 문서를 불러올 수 없습니다.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 디버깅: 생성된 URL 확인
    print('문서 URL 생성: $documentUrl');

    // PDF 뷰어 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          documentTitle: title,
          documentUrl: documentUrl,
          documentType: documentType,
          onDocumentViewed: () {
            // 문서 확인 시 체크 처리
            _markDocumentAsRead(documentType);
          },
        ),
      ),
    );
  }

  Widget _buildDocumentBottomSheet(String title, String content, String documentType) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
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
          // 헤더 (PDF 뷰어 스타일)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: AppColors.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // 툴바 (PDF 뷰어 스타일)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, size: 20),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.zoom_in, size: 20),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.fullscreen, size: 20),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.download_outlined, size: 20),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // PDF 뷰어 영역
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 문서 헤더
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.description, color: AppColors.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 문서 내용 (PDF처럼 보이도록)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.8,
                            color: Colors.grey.shade800,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 하단 툴바
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 24),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 16),
                Text(
                  '1 / 1',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 24),
                  onPressed: () {},
                  color: Colors.grey.shade700,
                ),
              ],
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
    // 문서 확인 시 체크
    _toggleDocumentCheck(documentType, forceCheck: true);
  }

  void _toggleDocumentCheck(String documentType, {bool forceCheck = false}) {
    setState(() {
      switch (documentType) {
        case 'coreAndFull':
          _checkedCoreAndFull = forceCheck ? true : !_checkedCoreAndFull;
          break;
        case 'simple':
          _checkedSimpleGuide = forceCheck ? true : !_checkedSimpleGuide;
          break;
        case 'terms':
          _checkedTerms = forceCheck ? true : !_checkedTerms;
          break;
      }

      // 채팅 리스트에서 마지막 documentsCard 업데이트
      for (int i = _chatItems.length - 1; i >= 0; i--) {
        if (_chatItems[i].type == ChatItemType.documents) {
          _chatItems[i] = ChatItem.documentsCard(
            onDocumentTap: _handleDocumentTap,
            checkedCoreAndFull: _checkedCoreAndFull,
            checkedSimpleGuide: _checkedSimpleGuide,
            checkedTerms: _checkedTerms,
            onConfirm: _handleConfirm,
            allChecked: _allChecked,
          );
          break;
        }
      }
    });

    // 모두 체크했으면 축하 메시지 (체크 해제 시에는 메시지 제거)
    if (_allChecked && !forceCheck) {
      // 체크 해제 시에는 메시지 추가 안 함
      return;
    }
    
    if (_allChecked && forceCheck) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _addBotMessage(
            ChatItem.cta(
              text: '모든 서류를 확인하셨네요! 👏\n아래 버튼을 눌러 다음 단계로 진행해 주세요.',
              buttonText: '모두 확인했어요 ✓',
              onConfirm: _handleConfirm,
            ),
          );
        }
      });
    }
  }

  void _handleConfirm() {
    if (_allChecked) {
      // 펀드 가입 화면으로 이동 (pop하지 않고 push)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FundSubscriptionScreen(
            fundTitle: widget.fundTitle,
            fundCode: widget.fundCode,  // fundCode 전달
            badge: widget.badge,
            yieldText: widget.yieldText,
          ),
        ),
      );
    }
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
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
      case ChatItemType.cta:
        return _buildCtaBubble(item);
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

  Widget _buildCtaBubble(ChatItem item) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.text ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: item.onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                item.buttonText ?? '다음으로',
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
                '펀드 설명서 및 약관',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            title: '투자설명서',
            isChecked: item.checkedCoreAndFull!,
            onTap: () => item.onDocumentTap!('coreAndFull'),
          ),
          const SizedBox(height: 10),
          _buildDocumentItem(
            title: '간이 투자설명서',
            isChecked: item.checkedSimpleGuide!,
            onTap: () => item.onDocumentTap!('simple'),
          ),
          const SizedBox(height: 10),
          _buildDocumentItem(
            title: '약관',
            isChecked: item.checkedTerms!,
            onTap: () => item.onDocumentTap!('terms'),
          ),
          const SizedBox(height: 20),
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
      onTap: onTap, // 체크된 상태에서도 클릭 가능
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
  cta,
}

class ChatItem {
  final ChatItemType type;
  final bool isUser;
  final String? text;
  final String? title;
  final String? description;
  final void Function(String)? onDocumentTap;
  final bool? checkedCoreAndFull;
  final bool? checkedSimpleGuide;
  final bool? checkedTerms;
  final VoidCallback? onConfirm;
  final bool? allChecked;
  final String? buttonText;

  ChatItem({
    required this.type,
    this.isUser = false,
    this.text,
    this.title,
    this.description,
    this.onDocumentTap,
    this.checkedCoreAndFull,
    this.checkedSimpleGuide,
    this.checkedTerms,
    this.onConfirm,
    this.allChecked,
    this.buttonText,
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
    required bool checkedCoreAndFull,
    required bool checkedSimpleGuide,
    required bool checkedTerms,
    required VoidCallback onConfirm,
    required bool allChecked,
  }) {
    return ChatItem(
      type: ChatItemType.documents,
      onDocumentTap: onDocumentTap,
      checkedCoreAndFull: checkedCoreAndFull,
      checkedSimpleGuide: checkedSimpleGuide,
      checkedTerms: checkedTerms,
      onConfirm: onConfirm,
      allChecked: allChecked,
    );
  }

  factory ChatItem.cta({
    required String text,
    required String buttonText,
    required VoidCallback onConfirm,
  }) {
    return ChatItem(
      type: ChatItemType.cta,
      text: text,
      buttonText: buttonText,
      onConfirm: onConfirm,
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

