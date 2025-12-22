import 'package:flutter/material.dart';
import '../home/constants/app_colors.dart';

/// PDF 뷰어 화면
/// 나중에 PDF 라이브러리(예: flutter_pdfview, syncfusion_flutter_pdfviewer 등)를 연동할 수 있도록 구조화
class PdfViewerScreen extends StatefulWidget {
  final String documentTitle;
  final String? documentUrl; // 나중에 PDF URL을 받을 수 있도록
  final String? documentPath; // 나중에 로컬 PDF 경로를 받을 수 있도록
  final String documentType; // 'core', 'simple', 'full', 'terms'
  final VoidCallback? onDocumentViewed; // 문서 확인 시 호출될 콜백

  const PdfViewerScreen({
    super.key,
    required this.documentTitle,
    this.documentUrl,
    this.documentPath,
    required this.documentType,
    this.onDocumentViewed,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isDownloading = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 나중에 PDF 로드 로직이 들어갈 위치
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    // TODO: PDF 로드 로직
    // 예: 
    // if (widget.documentUrl != null) {
    //   await _loadPdfFromUrl(widget.documentUrl!);
    // } else if (widget.documentPath != null) {
    //   await _loadPdfFromPath(widget.documentPath!);
    // }
    
    // 임시로 로딩 완료 처리
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      // TODO: PDF 다운로드 로직
      // 예:
      // final directory = await getApplicationDocumentsDirectory();
      // final file = File('${directory.path}/${widget.documentTitle}.pdf');
      // final response = await http.get(Uri.parse(widget.documentUrl!));
      // await file.writeAsBytes(response.bodyBytes);
      // await _showDownloadSuccess();

      // 임시로 다운로드 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.documentTitle} 다운로드가 완료되었습니다.'),
            backgroundColor: AppColors.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _handleConfirm() {
    // 확인 버튼 클릭 시 문서 확인 처리
    if (widget.onDocumentViewed != null) {
      widget.onDocumentViewed!();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () {
            // 뒤로가기 시 체크하지 않고 그냥 닫기
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.documentTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // 다운로드 버튼
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                  )
                : const Icon(Icons.download_outlined, color: Colors.black87),
            onPressed: _isDownloading ? null : _downloadPdf,
            tooltip: '다운로드',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : _buildPdfViewer(),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 16,
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
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleConfirm,
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
            ),
    );
  }

  Widget _buildPdfViewer() {
    // TODO: 실제 PDF 뷰어 위젯으로 교체
    // 예: 
    // if (widget.documentUrl != null) {
    //   return SfPdfViewer.network(widget.documentUrl!);
    // } else if (widget.documentPath != null) {
    //   return SfPdfViewer.asset(widget.documentPath!);
    // }
    
    // 임시로 PDF 뷰어 영역 표시
    return Column(
      children: [
        // PDF 뷰어 툴바 (줌, 페이지 네비게이션 등)
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 페이지 정보
              Text(
                '1 / 1',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              // 줌 컨트롤
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out, size: 20),
                    onPressed: () {
                      // TODO: 줌 아웃
                    },
                    color: Colors.grey.shade700,
                  ),
                  Text(
                    '100%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, size: 20),
                    onPressed: () {
                      // TODO: 줌 인
                    },
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
        // PDF 뷰어 영역
        Expanded(
          child: Container(
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF 뷰어 영역',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '나중에 PDF 라이브러리를 연동하면\n여기에 PDF 내용이 표시됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 임시 PDF 정보 표시
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '문서 정보',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('문서명', widget.documentTitle),
                        const SizedBox(height: 8),
                        _buildInfoRow('문서 타입', widget.documentType),
                        if (widget.documentUrl != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('URL', widget.documentUrl!),
                        ],
                        if (widget.documentPath != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('경로', widget.documentPath!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

