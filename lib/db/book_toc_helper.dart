
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'dart:developer' as developer;
import 'package:yuedu_parser/h_parser/h_parser.dart';


import 'utils.dart';

///目录更新!
class BookTocHelper{
  static BookTocHelper _instance;
  static BookTocHelper getInstance(){
    if(_instance == null){
      _instance = BookTocHelper._init();
    }
    return _instance;
  }
  BookTocHelper._init(){
    //
  }

  Future<List<BookChapterBean>> updateChapterList(int bookId,int sourceId,{bool notUpdateDB = false}) async{
    List<BookChapterBean> result = List<BookChapterBean>();
    //1.拿到书源
    //2.书链接
    BookInfoBean book = await DatabaseHelper().queryBookInfoFromBookIdCombSourceId(bookId, sourceId);
    BookSourceBean sourceBean = book.sourceBean;
    BookTocRuleBean ruleBean = book.sourceBean.mapTocRuleBean();
    var charset = sourceBean.mapSearchUrlBean().charset;
    Options requestOptions = Options(contentType:ContentType.html.toString() ,sendTimeout: 5000,receiveTimeout: 5000);
    if(charset == 'gbk'){
      requestOptions.responseDecoder = Utils.gbkDecoder;
    }
    //3.请求网络
    try{
      developer.log('目录请求 ${book.bookUrl}');
      var dio = Dio();
      dio.options.connectTimeout = 5000;
      var response = await dio.get(book.bookUrl,options: requestOptions);
      if(response.statusCode == 200){
        developer.log('目录解析 ${book.bookUrl}');
        var chapters = await _parseResponse(response.data,ruleBean);
        if(chapters.isEmpty){
          throw Exception('目录为空');
        }
        for (var chapter in chapters) {
          chapter.url = Utils.checkLink(sourceBean.bookSourceUrl, chapter.url);
          chapter.bookId = book.id;
          chapter.sourceId = book.source_id;
        }
        result.addAll(chapters);
        developer.log('目录解析完成 ${book.bookUrl}');
      }else{
        developer.log('目录解析错误:${book.bookUrl},网络错误${response.statusCode}');
      }
    }catch(e){
      developer.log('${book.bookUrl} 目录解析错误[使用规则${ruleBean.toString()}]:$e');
      return Future.error(e);
    }
    if(result.isNotEmpty && !notUpdateDB){
      await DatabaseHelper().updateToc(result);
    }

    return Future.value(result);
  }

  ///从数据库读取数据,没章节的话从网络获取
  Future<List<BookChapterBean>> getChapterList(int bookId,int sourceId) async{

  }

  dynamic insertChapterToDB(List<BookChapterBean> list) async{
    return await DatabaseHelper().updateToc(list);

  }



  Future<List<BookChapterBean>> _parseResponse(String data, BookTocRuleBean ruleBean) async{
    var parser = HParser(data);
    var result = List<BookChapterBean>();
    var eles = parser.parseRuleElements(ruleBean.chapterList);
    for (var ele in eles) {
      var chapterBean = BookChapterBean();
      var eParser = HParser(ele.outerHtml);
      chapterBean.name = eParser.parseRuleString(ruleBean.chapterName);
      chapterBean.url = eParser.parseRuleString(ruleBean.chapterUrl);
      result.add(chapterBean);
    }
    return Future.value(result);
  }


}