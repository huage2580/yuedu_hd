
import 'package:bot_toast/bot_toast.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';

typedef DownLoadCallBack = Function();

class BookDownloader{
  static BookDownloader _downloader;
  static BookDownloader getInstance(){

    if(_downloader == null){
      _downloader = BookDownloader._();
    }
    return _downloader;
  }

  BookDownloader._(){
    //pass
  }
  List<BookChapterBean> chapters = List<BookChapterBean>();
  BookInfoBean bookInfoBean;
  DownLoadCallBack downLoadCallBack = (){};

  /// 先查询章节列表，过滤有缓存的
  void startDownload(int bookId) async{
    if(chapters.isNotEmpty){
      BotToast.showText(text:"已经有缓存任务...");
      return;
    }
    bookInfoBean = await DatabaseHelper().queryBookById(bookId);
    chapters = await BookTocHelper.getInstance().getChapterListOnlyDB(bookId);
    //过滤已有缓存的内容
    chapters.removeWhere((element) => element.length!=null && element.length > 1);
    var contentHelper = BookContentHelper.getInstance();
    await Future.doWhile(() async{
      var task = chapters.removeAt(0);
      await contentHelper.fetchContentFromNetwork(task.id);
      downLoadCallBack();
      return Future.value(chapters.isNotEmpty);
    });
    bookInfoBean = null;
    downLoadCallBack();
  }

  void stop(){
    chapters.clear();
    bookInfoBean = null;
    downLoadCallBack();
  }

}