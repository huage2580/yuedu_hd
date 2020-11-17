
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/test_code/test_data.dart';

import 'PageBreaker.dart';


class CustomPageTest extends CustomPainter{
  List<YDPage> pagesList = List<YDPage>();
  int currPage = 0;


  CustomPageTest(this.currPage);

  @override
  void paint(Canvas canvas, Size size) {

    // final textStyle = TextStyle(
    //   color: Colors.black,
    //   fontSize: 20,
    // );
    // final textSpan = TextSpan(
    //   text: TestData.text1,
    //   style: textStyle,
    // );
    // final textPainter = TextPainter(
    //   text: textSpan,
    //   textDirection: TextDirection.ltr,
    // );
    // textPainter.layout(
    //   minWidth: 0,
    //   maxWidth: size.width,
    // );
    // final offset = Offset(0, 0);
    // textPainter.paint(canvas, offset);
    if(size.height == 0){
      return;
    }
    if(pagesList.isEmpty){
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 20,
      );

      final textSpan = TextSpan(
        text: TestData.text1,
        style: textStyle,
      );
      final textStyle2 = TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );
      final textSpan2 = TextSpan(
        text: "第一二三四章 测试文字很长的情况发生了什么",
        style: textStyle2,
      );
      var pageBreaker = PageBreaker(textSpan, textSpan2, size);
      pagesList = pageBreaker.splitPage();
    }
    var page = pagesList[currPage];
    var titleOffset = Offset(0, 0);
    if(page.titlePainter != null){
      page.titlePainter.paint(canvas, Offset.zero);
      titleOffset = Offset(0, page.titleOffset);
    }
    page.pagePainter.paint(canvas, titleOffset);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}