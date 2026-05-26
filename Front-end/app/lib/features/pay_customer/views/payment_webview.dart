import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym/api/gym_server_api.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

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
            if (request.url.contains(GymServerApi.returnPath)) {
              final uri = Uri.parse(request.url);
              final response = await http.get(uri);
              if (response.statusCode == 200) {
                final Map<String, dynamic> json = jsonDecode(response.body);

                final status = json['status'];
                if (context.mounted) {
                  Navigator.pop(context, {'status': status});
                }
              } else {
                if (context.mounted) {
                  Navigator.pop(context, {'status': 'FAILED'});
                }
              }
              return NavigationDecision.prevent;
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
      appBar: AppBar(title: const Text('Thanh toán VNPAY')),
      body: WebViewWidget(controller: _controller),
    );
  }
}