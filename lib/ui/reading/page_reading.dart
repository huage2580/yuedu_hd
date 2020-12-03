

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';

class PageReading extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    var args= ModalRoute.of(context).settings.arguments as Map;
    int bookId = args['bookId'];
    String initChapterName = args['initChapterName'];
    return Scaffold(
      body: Stack(
        children: [
          ReadingWidget(bookId, initChapterName),
        ],
      ),
    );
  }

}