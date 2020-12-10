import 'package:flutter/material.dart';

class PageSettings extends StatefulWidget{
  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.android),
          Text('v0.0.1'),
          Text('(又不是不能用版本)')
        ],
      ),),
    );
  }
}