import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:collection';

class YuanShenWebView extends StatefulWidget {
  const YuanShenWebView({super.key});

  @override
  State<YuanShenWebView> createState() => _YuanShenWebViewState();
}

class _YuanShenWebViewState extends State<YuanShenWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  double progress = 0;

  _progressBar(double progress, BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Colors.white70.withOpacity(0),
      minHeight: 1.5,
      value: progress == 1.0 ? 0 : progress,
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUsageDialog();
    });
  }

  void _showUsageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("本工具使用方法"),
          content: const Text(
              "登录云原神并打开游戏，然后在抽卡祈福界面打开历史记录，程序就会自动推断出抽卡记录分析地址了\n\n注：\n本工具属于第三方工具，但是访问的是官方云原神网站，不采集任何信息\n仅供学习和交流使用，请在24小时内删除\n开发者:https://github.com/InTheClodus\n\n点击OK继续"),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("截获到的地址"),
          content: Text(url),
          actions: <Widget>[
            TextButton(
              child: const Text('复制到剪贴板'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("成功复制到剪贴板")),
                );
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "原神Webview",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          child: _progressBar(progress, context),
          preferredSize: const Size.fromHeight(3.0),
        ),
      ),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(
            url: WebUri.uri(Uri.parse("https://ys.mihoyo.com/cloud/m/#/"))),
        initialUserScripts: UnmodifiableListView<UserScript>([]),
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          if (url != null &&
              url.toString().startsWith(
                  "https://webstatic.mihoyo.com/hk4e/event/e20190909gacha-v3/index.html")) {
            _showUrlDialog(url.toString());
          }
        },
        onLoadStop: (controller, url) {
          pullToRefreshController?.endRefreshing();
        },
        onProgressChanged: (controller, progress) {
          setState(() {
            this.progress = progress / 100;
          });
          if (progress == 100) {
            pullToRefreshController?.endRefreshing();
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
