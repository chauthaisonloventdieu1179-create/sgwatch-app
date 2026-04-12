import 'package:flutter/material.dart';
import 'package:sgwatch_app/core/theme/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BannerWebViewScreen extends StatefulWidget {
  final String url;

  const BannerWebViewScreen({super.key, required this.url});

  @override
  State<BannerWebViewScreen> createState() => _BannerWebViewScreenState();
}

class _BannerWebViewScreenState extends State<BannerWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        shadowColor: const Color(0x1A000000),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.black),
        ),
        title: Text(
          widget.url,
          style: const TextStyle(fontSize: 13, color: AppColors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
