

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';

class PageReading extends StatelessWidget{
  final int bookId;
  final String initChapterName;


  PageReading(this.bookId, this.initChapterName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ReadingWidget(bookId, initChapterName),
        ],
      ),
    );
  }

}