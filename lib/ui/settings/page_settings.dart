import 'package:flutter/material.dart';

class PageSettings extends StatefulWidget{
  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('设置'),),
    );
  }
}