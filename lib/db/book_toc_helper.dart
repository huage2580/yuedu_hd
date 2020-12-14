
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'dart:developer' as developer;
import 'package:yuedu_parser/h_parser/h_parser.dart';


import 'utils.dart';


typedef void OnChaptersLoad(List<BookChapterBean> chapters);

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
    //warmup
    List<BookChapterBean> result = List<BookChapterBean>();
    //1.拿到书源
    //2.书链接
    BookInfoBean book = await DatabaseHelper().queryBookInfoFromBookIdCombSourceId(bookId, sourceId);
    BookSourceBean sourceBean = book.sourceBean;
    BookTocRuleBean ruleBean = book.sourceBean.mapTocRuleBean();
    var charset = sourceBean.mapSearchUrlBean().charset;
    Options requestOptions = Options(contentType:ContentType.html.toString() ,sendTimeout: 10000,receiveTimeout: 5000);
    if(charset == 'gbk'){
      requestOptions.responseDecoder = Utils.gbkDecoder;
    }
    //3.请求网络
    try{
      developer.log('目录请求 ${book.bookUrl}');
      var dio = Dio();
      dio.options.connectTimeout = 10000;
      var response = await dio.get(book.bookUrl,options: requestOptions);
      if(response.statusCode == 200){
        developer.log('目录解析 ${book.bookUrl}');
        var chapters = await Executor().execute(arg1: response.data as String,arg2: ruleBean,fun2: _parseResponse);
        if(chapters.isEmpty){
          throw Exception('目录为空');
        }
        for (var chapter in chapters) {
          chapter.url = Utils.checkLink(sourceBean.bookSourceUrl, chapter.url);
          chapter.bookId = book.id;
          chapter.sourceId = book.source_id;
        }
        result.addAll(chapters);
        developer.log('目录解析完成 ${book.bookUrl},目录数量:${result.length}');
      }else{
        developer.log('目录解析错误:${book.bookUrl},网络错误${response.statusCode}');
        throw Exception('网络错误${response.statusCode}');
      }
    }catch(e){
      developer.log('${book.bookUrl} 目录解析错误[使用规则${ruleBean.toString()}]:$e');
      return Future.error(e);
    }
    if(result.isNotEmpty && !notUpdateDB){
      developer.log('目录插入开始 ${DateTime.now()}');
      await insertChapterToDB(result);
      developer.log('目录插入结束 ${DateTime.now()}');
      result = await DatabaseHelper().queryBookChapters(bookId);
      developer.log('目录二查结束 ${DateTime.now()}');
    }

    return Future.value(result);
  }

  ///从数据库读取数据,再从网络更新
  dynamic getChapterList(int bookId,OnChaptersLoad onChaptersLoad) async{
    List<BookChapterBean> chaptersFromDB = await DatabaseHelper().queryBookChapters(bookId);
    onChaptersLoad(chaptersFromDB);
    var chaptersFromNetWork = await updateChapterList(bookId,-1,notUpdateDB: false);
    onChaptersLoad(chaptersFromNetWork);
  }

  ///仅从数据库读取数据
  dynamic getChapterListOnlyDB(int bookId) async{
    return await DatabaseHelper().queryBookChapters(bookId);
  }

  dynamic insertChapterToDB(List<BookChapterBean> list) async{
    return await DatabaseHelper().updateToc(list);
  }

}

List<BookChapterBean> _parseResponse(String data, BookTocRuleBean ruleBean){
  var parser = HParser(data);
  var result = List<BookChapterBean>();
  var eles = parser.parseRuleElements(ruleBean.chapterList);
  developer.log('目录解析开始 ${DateTime.now()}');
  for (var ele in eles) {
    var chapterBean = BookChapterBean();
    var eParser = HParser(ele.outerHtml);
    chapterBean.name = eParser.parseRuleString(ruleBean.chapterName);
    chapterBean.url = eParser.parseRuleString(ruleBean.chapterUrl);
    if(chapterBean.name == null || chapterBean.name.isEmpty){
      continue;
    }
    result.add(chapterBean);
  }
  developer.log('目录解析结束 ${DateTime.now()}');
  if(result.isNotEmpty){
    if(result.lastIndexOf(result[0]) > 0){
      var subIndex = 0;
      for(var i=1; i<result.length;i++){
        var t = result[i];
        if(result.lastIndexOf(t) == i){
          subIndex = i;
          break;
        }
      }
      result = result.sublist(subIndex);
    }
  }
  // for(var t in result){
  //   developer.log(t.toString());
  // }
  developer.log('解析的总目录${result.length}');
  return result;
}