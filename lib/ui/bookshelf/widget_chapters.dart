import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';

typedef ItemCallback = void Function(BookChapterBean chapterBean);

///先从数据库读取，再从网络获取
class ChaptersWidget extends StatefulWidget {
  final int bookId;
  final ItemCallback onTap;

  ChaptersWidget(this.bookId, this.onTap) : super(key: ValueKey(bookId));

  @override
  _ChaptersWidgetState createState() => _ChaptersWidgetState();
}

class _ChaptersWidgetState extends State<ChaptersWidget> {
  var chaptersList = List<BookChapterBean>();
  var tocHelper = BookTocHelper.getInstance();
  var _showLoading = true;
  var _scrollController = ScrollController();

  @override
  void initState() {
    _fetchBookInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      child: Container(
        color: theme.cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Visibility(
                visible: _showLoading,
                child: LinearProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.primaryColorDark),
                )),
            Expanded(
              child: DraggableScrollbar.semicircle(
                  controller: _scrollController,
                  child: ListView.separated(
                    itemBuilder: (ctx, index) =>
                        _buildChapterItem(ctx, chaptersList[index]),
                    separatorBuilder: (ctx, index) => Divider(
                      height: 0.5,
                      thickness: 0.5,
                    ),
                    itemCount: chaptersList.length,
                    controller: _scrollController,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterItem(BuildContext context, BookChapterBean bean) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){
        widget.onTap(bean);
        Navigator.of(context).pop(bean.name);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(child: Text('${bean.name}')),
            if(bean.length != null)
              Icon(Icons.cloud_done,size: 16,color: Colors.grey,)
          ],
        ),
      ),
    );
  }

  void _fetchBookInfo() async {
    await _fetchChapters();
  }

  dynamic _fetchChapters() async {
    await tocHelper.getChapterList(widget.bookId, (chapters) {
      chaptersList.clear();
      chaptersList.addAll(chapters);
      setState(() {
        if(chaptersList.isNotEmpty){
          _showLoading = false;
        }
      });
    });
  }
}
