import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // syncfusion은 네트워크에서 직접 로드하므로 다운로드 불필요
    // 로컬 경로가 있으면 바로 사용, URL이 있으면 네트워크에서 로드
    if (widget.documentPath != null && widget.documentPath!.isNotEmpty) {
      setState(() => _isLoading = false);
    } else if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      setState(() => _isLoading = false);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '문서 URL 또는 경로가 제공되지 않았습니다.';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    if (widget.documentUrl == null || widget.documentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('다운로드할 문서 URL이 없습니다.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: 실제 다운로드 로직 구현
    // 예: url_launcher를 사용하여 브라우저에서 열기
    // 또는 Dio를 사용하여 파일로 저장
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.documentTitle} 다운로드 기능은 준비 중입니다.'),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
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
            icon: const Icon(Icons.download_outlined, color: Colors.black87),
            onPressed: _downloadPdf,
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
    // 로컬 경로가 있으면 로컬 파일 표시
    if (widget.documentPath != null && widget.documentPath!.isNotEmpty) {
      print('PDF 로컬 파일 표시: ${widget.documentPath}');
      final file = File(widget.documentPath!);
      return SfPdfViewer.file(
        file,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          print('PDF 로드 실패: ${details.error}');
          if (mounted) {
            setState(() {
              _errorMessage = 'PDF를 불러올 수 없습니다.\n${details.error}';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF를 불러올 수 없습니다.\n${details.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    }

    // URL이 있으면 네트워크에서 직접 로드 (스트리밍)
    if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      print('PDF 네트워크 로드: ${widget.documentUrl}');
      return SfPdfViewer.network(
        widget.documentUrl!,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          print('PDF 로드 실패: ${details.error}');
          print('PDF 로드 실패 상세: ${details.description}');
          if (mounted) {
            setState(() {
              _errorMessage = 'PDF를 불러올 수 없습니다.\n${details.error}';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF를 불러올 수 없습니다.\n${details.error}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    }
    
    // URL이나 경로가 없는 경우 에러 메시지
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '문서 URL 또는 경로가 제공되지 않았습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
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

