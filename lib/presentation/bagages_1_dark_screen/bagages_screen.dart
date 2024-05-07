import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArcGISMapScreen extends StatefulWidget {
  const ArcGISMapScreen({Key? key}) : super(key: key);

  @override
  _ArcGISMapScreenState createState() => _ArcGISMapScreenState();
}

class _ArcGISMapScreenState extends State<ArcGISMapScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // Permission is granted, do something
    } else {
      // Permission is denied, handle it accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Bagages Perdus"),
        ),
        body: SizedBox(
          width: double.infinity,
          child: WebView(
            initialUrl: 'https://arcg.is/a84uX',
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
