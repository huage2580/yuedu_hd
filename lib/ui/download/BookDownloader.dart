
import 'package:bot_toast/bot_toast.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/CountLock.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';

typedef DownLoadCallBack = Function();

class BookDownloader{
  static BookDownloader? _downloader;
  static BookDownloader getInstance(){

    if(_downloader == null){
      _downloader = BookDownloader._();
    }
    return _downloader!;
  }

  var _locker = CountLock(5);
  BookDownloader._(){
    //pass
  }
  List<BookChapterBean> chapters = [];
  BookInfoBean? bookInfoBean;
  DownLoadCallBack downLoadCallBack = (){};

  /// 先查询章节列表，过滤有缓存的
  void startDownload(int bookId,{int? from,int? limit,bool needToast = true}) async{
    if(chapters.isNotEmpty){
      BotToast.showText(text:"已经有缓存任务...");
      return;
    }
    bookInfoBean = await DatabaseHelper().queryBookById(bookId);
    chapters = await BookTocHelper.getInstance().getChapterListOnlyDB(bookId,from: from??-1,limit: limit??999999);
    //过滤已有缓存的内容
    chapters.removeWhere((element) => element.length!=null && element.length! > 1);
    var contentHelper = BookContentHelper.getInstance();
    if(chapters.isEmpty){
      BotToast.showText(text:"全部已缓存");
      return;
    }

    while(chapters.isNotEmpty){
      await _locker.request();
      var task = chapters.removeAt(0);
      //下面不采取await，为了并发
      contentHelper.fetchContentFromNetwork(task.id,null).whenComplete((){
        _locker.release();
        downLoadCallBack();
      });
    }
    BotToast.showText(text:"缓存任务结束~");

    bookInfoBean = null;
    downLoadCallBack();
  }

  void stop(){
    chapters.clear();
    bookInfoBean = null;
    downLoadCallBack();
  }

}