import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KakaoAddressScreen extends StatefulWidget {
  const KakaoAddressScreen({super.key});

  @override
  State<KakaoAddressScreen> createState() => _KakaoAddressScreenState();
}

class _KakaoAddressScreenState extends State<KakaoAddressScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            //  JS → Flutter 데이터 수신
            if (request.url.startsWith('kakao://address')) {
              final uri = Uri.parse(request.url);

              Navigator.pop(context, {
                'zipCode': uri.queryParameters['zipCode'],
                'addr1': uri.queryParameters['addr1'],
              });

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
        _html,
        baseUrl: 'https://postcode.map.daum.net',
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주소 검색')),
      body: WebViewWidget(controller: _controller),
    );
  }

  ///  카카오 주소 API
  final String _html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>
<body style="margin:0">
  <div id="postcode" style="width:100%;height:100vh;"></div>

  <script>
    new daum.Postcode({
      oncomplete: function(data) {
        var zip = data.zonecode;
        var addr = data.roadAddress || data.jibunAddress;

        // 🔥 Flutter로 전달 (about:// 문제 완전 회피)
        location.href =
          'kakao://address?zipCode=' + zip + '&addr1=' + encodeURIComponent(addr);
      }
    }).embed(document.getElementById('postcode'));
  </script>
</body>
</html>
''';
}
