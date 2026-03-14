import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  const PaymentWebView({super.key, required this.paymentUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains("/api/payment/return")) {
              final uri = Uri.parse(request.url);
              final response = await http.get(uri);

              if (response.statusCode == 200) {
                // Parse JSON trả về từ backend
                final Map<String, dynamic> json = jsonDecode(response.body);
                final status = json['status']; // Lấy trực tiếp từ backend

                // Trả dữ liệu về màn trước
                Navigator.pop(context, {'status': status});
              } else {
                print('Request failed with status: ${response.statusCode}');
                Navigator.pop(context, {'status': 'FAILED'});
              }

              return NavigationDecision.prevent; // Dừng WebView load URL
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán VNPAY")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
