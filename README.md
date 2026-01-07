# 🏦 부산은행 모바일 앱 - Flutter Client

부산은행 모바일 애플리케이션의 **Flutter 클라이언트**입니다.  
펀드 조회, 투자 성향 조사, 펀드 가입 등 다양한 금융 서비스를 모바일 환경에서 제공합니다.

---

## 📱 프로젝트 소개

본 프로젝트는 부산은행의 **모바일 금융 서비스 플랫폼**으로,  
고객이 스마트폰을 통해 펀드 상품을 조회하고, 투자 성향을 파악하며,  
안전하게 펀드에 가입할 수 있도록 설계되었습니다.

Flutter를 활용한 크로스 플랫폼 모바일 앱으로,  
실제 금융 서비스 흐름을 고려한 UI/UX와 보안 기능을 구현하는 것을 목표로 합니다.

---

## 🌟 주요 특징
- 🎨 직관적이고 모던한 UI/UX
- 🔐 전자서명을 통한 안전한 거래 처리
- 📊 실시간 펀드 수익률 그래프 제공
- 🤖 AI 기반 투자 성향 조사
- 📄 PDF 문서 뷰어 제공 (투자설명서, 약관 등)

---

## ✨ 주요 기능

### 1️⃣ 인증
- 회원가입 / 로그인
- JWT 토큰 기반 인증
- 안전한 토큰 저장 및 관리

---

### 2️⃣ 펀드 조회 및 관리
- 펀드 상품 목록 조회
- 카테고리별 펀드 필터링 (수익률 BEST, 추천 등)
- 펀드 상세 정보 조회
- 수익률 그래프 제공 (1개월 / 3개월 / 6개월 / 12개월)
- 내 펀드 관리 (가입 현황, 매도 등)

---

### 3️⃣ 투자 성향 조사
- 10문항 투자 성향 설문
- 실시간 성향 분석  
  (안정형, 안정추구형, 위험중립형, 적극투자형, 공격투자형)
- 일일 1회 제한 설문
- 전자서명 연동

---

### 4️⃣ 펀드 가입
- 투자 성향 조사 결과 연동
- 약관 동의 (투자설명서, 약관 PDF 확인)
- 전자서명을 통한 안전한 가입 처리
- 실시간 가입 완료 확인

---

### 5️⃣ 마이페이지
- 전체 메뉴 화면
- 개인정보 조회 및 수정
- 내 펀드 관리 (가입 현황, 투자 내역)
- 투자 현황 확인 (매수 / 매도 내역)
- 계좌 정보 관리

---

### 6️⃣ 고객센터
- FAQ 조회
- 1:1 문의 등록
- AI 챗봇 상담
- 공지사항 확인

---

### 7️⃣ 모의 투자
- 가상 계좌 생성
- 모의 투자 대시보드
- AI 기반 투자 진단 리포트 제공

---

## 🛠 기술 스택

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **HTTP Client**: Dio 5.4.0
- **상태 관리**: StatefulWidget, setState
- **보안 저장소**: flutter_secure_storage 9.0.0
- **차트**: fl_chart 0.69.0
- **PDF 뷰어**: syncfusion_flutter_pdfviewer 28.1.37
- **암호화**: crypto 3.0.3 (전자서명)
- **기타 라이브러리**
  - google_fonts: 폰트 적용
  - intl: 숫자 및 통화 포맷팅
  - url_launcher: 외부 링크 연결
  - image_picker: 이미지 선택

---

## 📋 환경 구성

### 필수 요구사항
- Flutter SDK 3.9.2 이상
- Dart SDK 3.9.2 이상
- Android Studio 또는 VS Code
- Android SDK (Android 빌드용)
- Xcode (iOS 빌드용, macOS 전용)

---

### 서버
- **Base URL**: `http://34.50.37.11:8080/bnk`


---

## 📂 프로젝트 구조 (Flutter Client)

```text
lib/
└── features/
    ├── splash/
    │   └── splash_screen.dart                 # 스플래시 화면
    ├── auth/                                  # 인증
    │   ├── login_screen.dart                  # 로그인
    │   └── signup_screen.dart                 # 회원가입
    ├── home/                                  # 홈 & 메뉴
    │   ├── home_screen.dart                   # 홈 화면
    │   ├── menu_screen.dart                   # 전체 메뉴 (마이페이지 진입)
    │   ├── fund_list_screen.dart              # 펀드 목록
    │   ├── fund_detail_screen.dart            # 펀드 상세 (간략)
    │   ├── fund_management_screen.dart        # 내 펀드 관리
    │   ├── investment_screen.dart             # 투자 진행
    │   ├── withdrawal_screen.dart             # 환매 / 철회
    │   ├── customized_fund_search_screen.dart # 맞춤형 펀드 검색
    │   ├── personal_info_screen.dart          # 개인정보 조회
    │   ├── personal_info_edit_screen.dart     # 개인정보 수정
    │   └── widgets/                           # 공통 위젯
    ├── fund_detail/                           # 펀드 상세 (확장)
    │   ├── fund_detail_screen.dart
    │   └── pdf_viewer_screen.dart             # 투자설명서 / 약관 PDF 뷰어
    ├── investment_propensity/                 # 투자 성향 조사
    │   └── investment_propensity_screen.dart
    ├── terms_agreement/                       # 약관 동의
    │   └── terms_agreement_screen.dart
    ├── subscription/                          # 펀드 가입
    │   ├── fund_subscription_screen.dart
    │   ├── widgets/
    │   │   └── password_input_dialog.dart     # 비밀번호 입력 다이얼로그
    │   └── services/
    │       └── signature_service.dart         # 전자서명 로직
    ├── cs/                                    # 고객센터
    │   ├── cs_main_screen.dart
    │   ├── cs_chatbot_screen.dart             # AI 챗봇
    │   ├── cs_faq_list_screen.dart
    │   ├── cs_notice_screen.dart
    │   └── cs_one_on_one_inquiry_screen.dart  # 1:1 문의
    └── mock_investment/                       # 모의 투자
        └── screens/
            ├── mock_dashboard_screen.dart     # 모의 투자 대시보드
            ├── mock_ai_report_screen.dart     # AI 투자 리포트
            ├── mock_diagnosis_result_screen.dart
            └── mock_account_create_screen.dart

---


