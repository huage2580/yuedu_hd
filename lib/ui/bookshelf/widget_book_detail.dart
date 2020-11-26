import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/widget/space.dart';



class BookDetailWidget extends StatefulWidget {
  final int bookId;

  BookDetailWidget(this.bookId):super(key: ValueKey(bookId));

  @override
  State<StatefulWidget> createState() {
    return BookDetailState();
  }

}

class BookDetailState extends State<BookDetailWidget> {
  BookInfoBean bookDetail;

  @override
  void initState() {
    super.initState();
    _fetchDetail(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return bookDetail == null ? _buildEmpty() : _buildDetail(context);
  }

  Widget _buildEmpty() {
    return Container(
      child: Text('${widget.bookId}'),
    );
  }

  Column _buildDetail(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      height: 80,
                      width: double.maxFinite,
                      child: CustomPaint(painter: _ArcPainter(context),),
                      )),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    height: 120,
                    width: 96,
                    child: Image.network(bookDetail.coverUrl)),
              ),
            ],
          ),
        ),
        Expanded(child: Container(
          width: double.maxFinite,
          color: theme.cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(bookDetail.name,style: theme.textTheme.headline6,),
              VSpace(8),
              _buildTags(context),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTags(BuildContext context){
    var theme = Theme.of(context);
    var tags = bookDetail.kind.split('|');
    return Wrap(
      spacing: 8,
      children: [
        for (var tag in tags)
          Container(
            padding: EdgeInsets.only(left: 4,right: 4),
            decoration: BoxDecoration(color: theme.primaryColor,borderRadius: BorderRadius.all(Radius.circular(2))),
              child: Text(tag,style: TextStyle(color: theme.accentColor,fontSize: 13),),
          )
      ],
    );
  }

  void _fetchDetail(int bookId) async {
    if(bookId <= 0){
      return;
    }
    bookDetail = await DatabaseHelper().queryBookById(bookId);
    setState(() {});
    var chapterList = await BookTocHelper.getInstance().updateChapterList(bookId, -1);
    for (var value in chapterList) {
      print(value.toString());
    }
    print('done!');
  }
}

class _ArcPainter extends CustomPainter{

  Paint _mPaint;


  @override
  void paint(Canvas canvas, Size size) {
    var rectDraw = Rect.fromLTWH(0, 0, size.width, size.height);
    var rect = Rect.fromLTWH(0, 0, size.width, size.height*2);
    canvas.clipRect(rectDraw);
    canvas.drawOval(rect, _mPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  _ArcPainter(BuildContext context){
    _mPaint = Paint();
    _mPaint.color = Theme.of(context).cardColor;
  }

}
