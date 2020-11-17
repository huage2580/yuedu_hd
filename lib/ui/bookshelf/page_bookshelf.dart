
import 'package:flutter/material.dart';

class PageBookShelf extends StatefulWidget{
  @override
  _PageBookShelfState createState() => _PageBookShelfState();
}

class _PageBookShelfState extends State<PageBookShelf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('书架'),),
    );
  }
}