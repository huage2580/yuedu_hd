import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:reader_parser2/h_parser/h_eval_parser.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_search_helper.dart';
import 'package:yuedu_hd/db/book_source_helper.dart';
import 'dart:developer' as developer;

import 'package:yuedu_hd/db/book_toc_helper.dart';

///校验书源
///
///
///

typedef void OnVerifyProgress(String progressText,bool done);

class SourceVerifyHelper{

  void importJsonUrl(String url,bool needCheck,OnVerifyProgress onVerifyProgress) async{
    List<BookSourceBean> sources = [];
    try{
      onVerifyProgress.call("请求网络...",false);
      var req = await Dio(BaseOptions(responseType: ResponseType.plain)).get(url);
      sources = await BookSourceHelper.getInstance().parseSourceString(req.data);
    }catch(e){
      onVerifyProgress.call("网络异常 $e",true);
      return;
    }

    if(sources.isEmpty){
      var log = BookSourceHelper.getInstance().getLog();
      onVerifyProgress.call("NULL 获取书源失败\n$log",true);
      return;
    }else if(sources.length > 1){
      //直接导入数据库
      await BookSourceHelper.getInstance().updateDataBases(sources);
      onVerifyProgress.call("批量导入成功...",true);
    }else{
      //看要不要校验
      if(!needCheck){
        //直接导入数据库
        await BookSourceHelper.getInstance().updateDataBases(sources);
        onVerifyProgress.call("导入成功...",true);
      }else{
        var verifyResult = await _verify(sources[0],onVerifyProgress).catchError((e){
          onVerifyProgress.call("可能不兼容书源(T_T)",true);
        });
        if(verifyResult==null){
          onVerifyProgress.call("出错了!可能不兼容书源(T_T)",true);
          return;
        }
        if(verifyResult){
          onVerifyProgress.call("校验成功...",false);
          await BookSourceHelper.getInstance().updateDataBases(sources);
          onVerifyProgress.call("导入成功...",true);
        }else{
          onVerifyProgress.call("校验失败,可能不兼容书源(T_T)",true);
        }
      }
    }

  }


  Future<bool?> _verify(BookSourceBean sourceBean,OnVerifyProgress onVerifyProgress) async{
    sourceBean.ruleSearch = jsonEncode(sourceBean.ruleSearch);
    sourceBean.ruleBookInfo = jsonEncode(sourceBean.ruleBookInfo);
    sourceBean.ruleToc = jsonEncode(sourceBean.ruleToc);
    sourceBean.ruleContent = jsonEncode(sourceBean.ruleContent);

    //搜索
    BookSearchUrlBean? searchUrlBean = sourceBean.mapSearchUrlBean();
    if(searchUrlBean == null){
      return Future.value(false);
    }
    var eparser = HEvalParser({'page':1,'key':"我的"});
    searchUrlBean.url = eparser.parse(searchUrlBean.url);
    searchUrlBean.body = eparser.parse(searchUrlBean.body);
    searchUrlBean.exactSearch = false;

    //搜索结果
    List<BookInfoBean> books = [];
    await BookSearchHelper.getInstance().request(searchUrlBean, (data) {
      books.add(data);
    }, () {

    },sourceBean: sourceBean);

    //二次搜索，使用长一点的关键词
    if(books.isEmpty){
      //搜索
      BookSearchUrlBean? searchUrlBean = sourceBean.mapSearchUrlBean();
      if(searchUrlBean == null){
        return Future.value(false);
      }
      var eparser = HEvalParser({'page':1,'key':"凡人修仙"});
      searchUrlBean.url = eparser.parse(searchUrlBean.url);
      searchUrlBean.body = eparser.parse(searchUrlBean.body);
      searchUrlBean.exactSearch = false;
      await BookSearchHelper.getInstance().request(searchUrlBean, (data) {
        books.add(data);
      }, () {

      },sourceBean: sourceBean);
    }
    if(books.isEmpty){
      onVerifyProgress.call("搜索书籍失败",false);
      developer.log("source import _verify books.isEmpty");
      return Future.value(false);
    }
    //目录
    BookInfoBean book = books[0];
    book.sourceBean = sourceBean;
    List<BookChapterBean> chapters = await BookTocHelper.getInstance().updateChapterList(-1, -1,bookBean: book,notUpdateDB: true);
    if(chapters.isEmpty){
      onVerifyProgress.call("目录解析失败",false);
      return Future.value(false);
    }
    //内容
    try{
      String? chapterUrl1 = chapters[0].url;
      String? chapterUrl2 = chapters[1].url;
      String content = await BookContentHelper.getInstance().fetchContentFromNetwork(-1, null,sourceBean: sourceBean,chapterUrl: chapterUrl1,nextChapterUrl: chapterUrl2);
      if(content.isEmpty){
        onVerifyProgress.call("解析正文失败",false);
        return Future.value(false);
      }
    }catch(e){
      onVerifyProgress.call("解析正文失败",false);
      developer.log("source _verify content error->$e");
      return Future.value(false);

    }
    onVerifyProgress.call("解析正文成功",false);
    sourceBean.ruleSearch = jsonDecode(sourceBean.ruleSearch??"");
    sourceBean.ruleBookInfo = jsonDecode(sourceBean.ruleBookInfo??"");
    sourceBean.ruleToc = jsonDecode(sourceBean.ruleToc??"");
    sourceBean.ruleContent = jsonDecode(sourceBean.ruleContent??"");
    return Future.value(true);
  }

}
