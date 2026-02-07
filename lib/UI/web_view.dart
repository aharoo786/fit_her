import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';

/// Payment WebView. Loads [url] (e.g. Payin PWA or Stripe).
/// If [successPlanId] is set (Direct Pay flow), intercepts fither://payment/success
/// and fither://payment/failed to close and optionally update plan status.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({
    super.key,
    required this.url,
    this.successPlanId,
  });
  final String url;
  /// For Direct Pay: planId to pass to updateUserPlanStatus on success redirect
  final String? successPlanId;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? controller;

  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            final uri = request.url;
            if (uri.startsWith('fither://')) {
              _handleDirectPayRedirect(uri);
              return NavigationDecision.prevent;
            }
            if (uri.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  void _handleDirectPayRedirect(String uri) {
    if (!mounted) return;
    final parsed = Uri.parse(uri);
    if (parsed.host == 'payment' && parsed.pathSegments.contains('success')) {
      final planId = parsed.queryParameters['planId'] ?? widget.successPlanId;
      if (planId != null && planId.isNotEmpty) {
        try {
          Get.find<HomeController>().updateUserPlanStatus(planId);
        } catch (_) {}
      }
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Payment"),
      body: WebViewWidget(controller: controller!),
    );
  }
}
