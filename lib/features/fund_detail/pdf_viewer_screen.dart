import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
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
  bool _isDownloading = false;
  bool _isLoading = true;
  String? _localFilePath; // 다운로드한 PDF 파일의 로컬 경로
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  /// PDF 다운로드 및 로드
  Future<void> _loadPdf() async {
    // 로컬 경로가 이미 있으면 바로 사용
    if (widget.documentPath != null && widget.documentPath!.isNotEmpty) {
      setState(() {
        _localFilePath = widget.documentPath;
        _isLoading = false;
      });
      return;
    }

    // URL이 있으면 다운로드
    if (widget.documentUrl != null && widget.documentUrl!.isNotEmpty) {
      try {
        setState(() {
          _isDownloading = true;
          _isLoading = true;
        });
        
        print('PDF 다운로드 시작: ${widget.documentUrl}');
        
        // 1. 임시 디렉토리 가져오기
        final directory = await getTemporaryDirectory();
        final fileName = widget.documentUrl!.split('/').last;
        final filePath = '${directory.path}/$fileName';

        print('PDF 저장 경로: $filePath');

        // 2. Dio로 PDF 다운로드
        final dio = Dio();
        await dio.download(
          widget.documentUrl!,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              print('PDF 다운로드 진행률: $progress%');
            }
          },
        );

        // 3. 파일이 제대로 다운로드되었는지 확인
        final file = File(filePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          print('PDF 다운로드 완료: $filePath (크기: $fileSize bytes)');
          
          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
            _isDownloading = false;
          });
        } else {
          throw Exception('PDF 파일 다운로드 실패: 파일이 생성되지 않았습니다.');
        }
      } catch (e) {
        print('PDF 다운로드 오류: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isDownloading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF를 불러올 수 없습니다.\n${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      // URL이나 경로가 없는 경우
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // PDFViewController는 dispose 메서드가 없으므로 null로 설정만 함
    _pdfViewController = null;
    super.dispose();
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
    // 다운로드 중이면 진행률 표시
    if (_isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'PDF 다운로드 중...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // 로컬 파일 경로가 있으면 PDF 표시
    if (_localFilePath != null && _localFilePath!.isNotEmpty) {
      print('PDF 뷰어 표시: $_localFilePath');
      return PDFView(
        filePath: _localFilePath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
        onViewCreated: (PDFViewController pdfViewController) {
          _pdfViewController = pdfViewController;
        },
        onError: (error) {
          print('PDF 로드 에러: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF를 불러올 수 없습니다.\n${error.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        onPageError: (page, error) {
          print('PDF 페이지 에러: $page - $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('페이지를 불러올 수 없습니다: $page'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        onRender: (pages) {
          print('PDF 렌더링 완료: 총 $pages 페이지');
        },
        onPageChanged: (int? page, int? total) {
          if (page != null && total != null) {
            print('PDF 페이지 변경: $page / $total');
          }
        },
        onLinkHandler: (String? uri) {
          print('PDF 링크 클릭: $uri');
        },
      );
    }
    
    // 파일이 없는 경우 에러 메시지
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
            '문서 URL 또는 경로가 제공되지 않았습니다.',
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

