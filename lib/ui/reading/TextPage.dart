
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/ui/reading/PageBreaker.dart';

/// 显示文字的页面，单页，已分页
class TextPage extends StatelessWidget{
  final YDPage ydPage;

  TextPage({this.ydPage}) : super(key: ValueKey(ydPage));
  @override
  Widget build(BuildContext context) {
    if(ydPage == null){
      return Center(child: Text(''),);
    }
    return CustomPaint(painter: YDPainter(ydPage),);
  }
}
class YDPainter extends CustomPainter{
  final YDPage ydPage;

  YDPainter(this.ydPage);

  @override
  void paint(Canvas canvas, Size size) {
    var page = ydPage;
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