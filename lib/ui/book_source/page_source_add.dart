
import 'package:flutter/material.dart';

class PageSourceAdd extends StatefulWidget{
  @override
  _PageSourceAddState createState() => _PageSourceAddState();
}

class _PageSourceAddState extends State<PageSourceAdd> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(child: Text('添加书源'),),
      ),
    );
  }
}