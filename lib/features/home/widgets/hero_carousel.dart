import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _controller = PageController();
  final List<String> _images = const [
    'assets/images/팝업1.png',
    'assets/images/슬라이드2.png',
    'assets/images/치이카와1.webp',
  ];
  final List<String> _labels = const ['팝업 1', '팝업 2', '팝업 3'];
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controller.hasClients) {
        final nextPage = (_current + 1) % _images.length;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                // 세 번째 슬라이드 (치이카와1): 전체 이미지 + 흰색 배경
                if (index == 2) {
                  return Container(
                    color: Colors.white,
                    child: Image.asset(
                      _images[index],
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.15),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                // 두 번째 슬라이드 (팝업2): 모의 투자 안내 - 문구 왼쪽, 이미지 오른쪽
                if (index == 1) {
                  return Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        // 왼쪽: 텍스트
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 0, top: 8.0, bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '실제 투자 전,',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  '모의투자로',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const Text(
                                  '먼저 연습하세요',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '모의 투자 시작하기 >',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 오른쪽: 이미지
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0, top: 6.0, right: 8.0, bottom: 4.0),
                            child: Image.asset(
                              _images[index],
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 160,
                                  color: Colors.grey.withOpacity(0.2),
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // 첫 번째 슬라이드 (팝업1): BEST 펀드
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      // 왼쪽: 이미지 (50%)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            _images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.withOpacity(0.2),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 36,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // 오른쪽: 텍스트 (50%)
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 16.0, top: 20.0, bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'BEST 수익률/판매량',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '지금 제일',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const Text(
                                '잘나가는 펀드',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _images.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _current == i ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _current == i
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

