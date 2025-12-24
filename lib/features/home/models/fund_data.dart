class FundData {
  const FundData({
    required this.title,
    this.subtitle,
    required this.rankLabel,
    required this.badge,
    this.badge2,
    required this.yieldText,
  });

  final String title;
  final String? subtitle;
  final String rankLabel;
  final String badge;
  final String? badge2;
  final String yieldText;

  // JSON에서 FundData로 변환
  // 스프링 JSON 형식과 Flutter 형식 모두 지원
  factory FundData.fromJson(Map<String, dynamic> json) {
    // 스프링 JSON 형식 처리
    if (json.containsKey('fundNm')) {
      // 스프링에서 온 데이터
      final investgrade = json['investgrade'] as String? ?? '';
      final perf3M = json['perf3M'];
      
      // 위험 등급 매핑
      String badge;
      if (investgrade.contains('매우 낮은') || investgrade.contains('낮은')) {
        badge = '낮은위험';
      } else if (investgrade.contains('높은')) {
        badge = '높은위험';
      } else if (investgrade.contains('중간')) {
        badge = '중간위험';
      } else {
        badge = investgrade.isNotEmpty ? investgrade : '—';
      }
      
      // 수익률 포맷팅 (perf3M이 숫자인 경우)
      String yieldText = '—';
      if (perf3M != null) {
        if (perf3M is num) {
          yieldText = '${perf3M.toStringAsFixed(2)}%';
        } else if (perf3M is String) {
          yieldText = perf3M;
        }
      }
      
      return FundData(
        title: json['fundNm'] as String? ?? '',
        subtitle: json['overview'] as String?,
        rankLabel: '', // 스프링 데이터에는 순위 정보가 없음
        badge: badge,
        badge2: null,
        yieldText: yieldText,
      );
    } else {
      // 기존 Flutter 형식 (title, badge 등 직접 필드명 사용)
      return FundData(
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
        rankLabel: json['rankLabel'] as String? ?? '',
        badge: json['badge'] as String? ?? '',
        badge2: json['badge2'] as String?,
        yieldText: json['yieldText'] as String? ?? '—',
      );
    }
  }

  // FundData를 JSON으로 변환 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'rankLabel': rankLabel,
      'badge': badge,
      'badge2': badge2,
      'yieldText': yieldText,
    };
  }
}

