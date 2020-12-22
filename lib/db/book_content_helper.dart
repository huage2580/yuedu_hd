

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/db/utils.dart';
import 'dart:developer' as developer;
import 'package:yuedu_parser/h_parser/h_parser.dart';



///正文解析
class BookContentHelper{
  static BookContentHelper _instance;
  static BookContentHelper getInstance(){
    if(_instance == null){
      _instance = BookContentHelper._init();
    }
    return _instance;
  }
  BookContentHelper._init(){
    //pass
  }

  ///根据章节id获取内容，优先数据库获取，没有缓存从网络获取
  Future<String> getChapterContent(int chapterId) async{
    developer.log('企图获取章节内容 $chapterId');
    var contentFromDB = await DatabaseHelper().queryChapterContent(chapterId);
    if(contentFromDB != null && contentFromDB.isNotEmpty){
      return Future.value(contentFromDB);
    }
    return fetchContentFromNetwork(chapterId);

  }

  Future<String> fetchContentFromNetwork(int chapterId) async{
    var source = await DatabaseHelper().queryBookSourceByChapterId(chapterId);
    var bookUrl = await DatabaseHelper().queryChapterUrl(chapterId);
    var contentRule = source.mapContentRuleBean();
    //请求网络
    var charset = source.mapSearchUrlBean().charset;
    Options requestOptions = Options(contentType:ContentType.html.toString() ,sendTimeout: 10000,receiveTimeout: 5000);
    if(charset == 'gbk'){
      requestOptions.responseDecoder = Utils.gbkDecoder;
    }
    var content = "";
    try{
      while(bookUrl!=null){
        String htmlString = await _request(requestOptions, bookUrl);
        if(htmlString == null){
          throw Exception('正文请求失败m');
        }
        //解析内容
        String c = await Executor().execute(arg1: htmlString,arg2: contentRule,fun2: parseContent);
        developer.log('完成解析正文 $bookUrl');
        content += c;
        //解析下一页
        if(contentRule.nextContentUrl!=null && contentRule.nextContentUrl.isNotEmpty){
          String nextUrl = await Executor().execute(arg1: htmlString,arg2: contentRule.nextContentUrl,fun2: parseNextPage);
          if(nextUrl == null || nextUrl.trim().isEmpty){
            bookUrl = null;
          }else{
            bookUrl = Utils.checkLink(source.bookSourceUrl, nextUrl);
            developer.log('下一页链接 $bookUrl');
          }
        }else{
          bookUrl = null;
        }
      }
      await DatabaseHelper().updateChapterContent(chapterId, content);
      return Future.value(content);
    }catch(e){
      developer.log('正文获取异常 $e');
      return Future.error(e);
    }

    return Future.value(null);
  }

  Future<String> _request(Options requestOptions,String bookUrl) async{
    try{
      developer.log('正文请求 $bookUrl');
      var dio = Utils.createDioClient();
      dio.options.connectTimeout = 10000;
      var response = await dio.get(bookUrl,options: requestOptions);
      if(response.statusCode == 200) {
        return Future.value(response.data);
      }else{
        developer.log('正文请求失败[${response.statusCode}] $bookUrl');
      }
    }catch(e){
      developer.log('正文请求错误[$bookUrl]:$e');
    }
    return Future.value(null);
  }

}

String parseContent(String html,BookContentRuleBean rule){
  developer.log('开始解析正文 $rule');
  var content = HParser(html).parseRuleString(rule.content);
  if(rule.replaceRegex == null || rule.replaceRegex.isEmpty){
    return content;
  }
  return HParser(content).parseReplaceRule(rule.replaceRegex);
}

String parseNextPage(String html,String next){
  developer.log('解析下一页的链接');
  return HParser(html).parseRuleString(next);
}