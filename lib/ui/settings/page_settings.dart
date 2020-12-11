

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/settings/MoreStyleSettingsMenu.dart';

class PageSettings extends StatefulWidget{
  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Text('阅读设置',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  MoreStyleSettingsMenu(),
                  Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Text('关于',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  AboutListTile(applicationName: '阅读HD',applicationVersion: 'ver 0.0.2',applicationLegalese: '开源地址\nhttps://github.com/huage2580/yuedu_hd',),
                  ListTile(title: Text('用户协议'),trailing: Icon(Icons.arrow_forward_ios_rounded),),
                  ListTile(title: Text('隐私协议'),trailing: Icon(Icons.arrow_forward_ios_rounded),),
                  ListTile(title: Text('免责声明'),trailing: Icon(Icons.arrow_forward_ios_rounded),),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}