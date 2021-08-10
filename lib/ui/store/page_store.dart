
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yuedu_hd/ui/store/dialog_import_source.dart';

class PageStore extends StatefulWidget{
  @override
  _PageStoreState createState() => _PageStoreState();
}

class _PageStoreState extends State<PageStore> {

  late TextEditingController _textEditingController;
  late NavigationDelegate _navigationDelegate;
  WebViewController? _controller;
  String showUrl = "";
  var showLoading = true;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _textEditingController = TextEditingController();
    _navigationDelegate = (request){
      // 判断URL
      if (request.url.startsWith('yuedu')||request.url.startsWith('legado')) {
        print(request.url);
        var urlMatch = RegExp('src=([^&]*)');
        var matchResult = urlMatch.firstMatch(request.url);
        var jsonUrl = matchResult?.group(1);
        _importJsonUrl(jsonUrl);
        return NavigationDecision.prevent;
      }
      if(request.url.endsWith('.json')){
        _importJsonUrl(request.url);
        return NavigationDecision.navigate;
      }
      if(request.url.startsWith('http')){
        return NavigationDecision.navigate;
      }
      if(request.url.startsWith('ftp')){
        return NavigationDecision.navigate;
      }
      return NavigationDecision.prevent;
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Container(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(onPressed: (){
                  _controller?.canGoBack().then((value){
                    if(value){_controller?.goBack();}
                  });
                }, icon: Icon(Icons.arrow_back_ios_new)),
                Expanded(child: _buildLinkInput(theme)),
              ],
            ),
          ),
          Expanded(
              child: _buildWebView(context),
          ),
        ],),
      ),
    );
  }


  Container _buildLinkInput(ThemeData theme) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(left: 8,right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: theme.canvasColor,
      ),
      child: Center(
        child: TextField(
          controller: _textEditingController,
          maxLines: 1,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.all(0),
            hintText: '输入网址访问',
            border: InputBorder.none,
            suffixIconConstraints: BoxConstraints(minWidth: 30, maxHeight: 30),
            suffixIcon: showLoading?CupertinoActivityIndicator():null,
          ),
          onSubmitted: (text){
            showUrl = text;
            _controller?.loadUrl(showUrl);
          },
          textInputAction: TextInputAction.go,
        ),
      ),
    );
  }

  WebView _buildWebView(context){
    /**
     * iOS
        我们需要在 IOS 模块的 Runner 中的 info.plist 文件中添加如下字段：

        <key>NSAppTransportSecurity</key>
        <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
        </dict>
     */
    return WebView(
      // initialUrl: "http://yck.mumuceo.com/yuedu/shuyuan/index.html",
      initialUrl: "http://47.107.39.107/",
      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true,
      navigationDelegate: _navigationDelegate,
      onWebViewCreated: (WebViewController webViewController) {
        _controller = webViewController;
      },
      onPageStarted: (url){
        print("onPageStarted $url");
        showUrl = url;
        setState(() {
          _textEditingController.text = showUrl;
        });
      },
      onProgress: (i){
        setState(() {
          showLoading = i!=100;
        });
      },
    );
  }

  void _importJsonUrl(String? url) async{
    if(url == null){
      return;
    }
    print("webView import: $url");
    var select = await showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("导入书源"),
        content: Text("$url \n\n 请选择是否校验导入。(只有单个书源才能校验，多个书源不校验直接导入)"),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop('not');
          }, child: Text('直接导入')),
          TextButton(onPressed: (){
            Navigator.of(context).pop('check');
          }, child: Text('校验')),
        ],
      );
    });
    if(select == "not"){
      _showImportDialog(url, false);
    }else if(select == "check"){
      _showImportDialog(url, true);
    }
  }

  void _showImportDialog(String url,bool needCheck){
    showDialog(context: context, builder: (context){
      return DialogImportSource(url: url, needCheck: needCheck);
    });
  }


}