

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:worker_manager/worker_manager.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/db/utils.dart';
import 'dart:developer' as developer;
import 'package:reader_parser2/h_parser/h_parser.dart';



///正文解析
class BookContentHelper{
  static BookContentHelper? _instance;
  static BookContentHelper getInstance(){
    if(_instance == null){
      _instance = BookContentHelper._init();
    }
    return _instance!;
  }
  BookContentHelper._init(){
    //pass
  }

  ///根据章节id获取内容，优先数据库获取，没有缓存从网络获取 [nextChapterId]用来判断内容分页，有些下一页就是下一章节
  Future<String> getChapterContent(int chapterId,int? nextChapterId) async{
    developer.log('企图获取章节内容 $chapterId');
    var contentFromDB = await DatabaseHelper().queryChapterContent(chapterId);
    if(contentFromDB.isNotEmpty){
      return Future.value(contentFromDB);
    }
    return fetchContentFromNetwork(chapterId,nextChapterId);

  }

  Future<String> fetchContentFromNetwork(int chapterId,int? nextChapterId) async{
    var source = await DatabaseHelper().queryBookSourceByChapterId(chapterId);
    String? bookUrl = await DatabaseHelper().queryChapterUrl(chapterId);
    String? nextBookUrl;
    if(nextChapterId!=null){
      nextBookUrl = await DatabaseHelper().queryChapterUrl(nextChapterId);
    }
    var contentRule = source.mapContentRuleBean();
    //请求网络
    var charset = source.mapSearchUrlBean()!.charset;
    Options requestOptions = Options(contentType:ContentType.html.toString() ,sendTimeout: 10000,receiveTimeout: 5000);
    if(charset == 'gbk'){
      requestOptions.responseDecoder = Utils.gbkDecoder;
    }
    var content = "";
    try{
      var counter = 0;
      while(bookUrl!=null){
        counter ++;
        if(counter > 10){
          throw Exception('正文分页超过十页');
        }
        String? htmlString = await _request(requestOptions, bookUrl);
        if(htmlString == null || htmlString.isEmpty){
          throw Exception('正文请求失败 null');
        }
        //解析内容
        String? c = await Executor().execute(arg1: bookUrl,arg2: htmlString,arg3: contentRule,fun3: parseContent);
        String cNotEmpty = c??"";
        developer.log('完成解析正文 $bookUrl -> ${cNotEmpty.substring(0,min(100, cNotEmpty.length))}...');
        content += cNotEmpty;
        //解析下一页
        if(contentRule.nextContentUrl!=null && contentRule.nextContentUrl!.isNotEmpty){
          String? nextUrl = await Executor().execute(arg1: bookUrl,arg2: htmlString,arg3: contentRule.nextContentUrl!,fun3: parseNextPage);
          if(nextUrl == null || nextUrl.trim().isEmpty){
            bookUrl = null;
          }else{
            bookUrl = Utils.checkLink(bookUrl, nextUrl);
            developer.log('下一页链接 $bookUrl');
            //下一页就是下一章，不获取数据
            if(bookUrl == nextBookUrl){
              bookUrl = null;
            }
          }
        }else{
          bookUrl = null;
        }
      }
      if(content==null || content.isEmpty){
        throw Exception('正文请求成功 解析失败');
      }
      await DatabaseHelper().updateChapterContent(chapterId, content);
      return Future.value(content);
    }catch(e){
      developer.log('正文获取异常 $e');
      return Future.error(e);
    }

    return Future.value(null);
  }

  Future<String?> _request(Options requestOptions,String bookUrl) async{
    try{
      var headers = Map<String,dynamic>();
      headers["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36";
      if(requestOptions.headers!=null){
        requestOptions.headers!.addAll(headers);
      }else{
        requestOptions.headers = headers;
      }
      developer.log('正文请求 $bookUrl');
      var dio = Utils.createDioClient();
      var response = await dio.get(bookUrl,options: requestOptions);
      if(response.statusCode == 200) {
        return Future.value(response.data);
      }else{
        developer.log('正文请求失败[${response.statusCode}] $bookUrl');
        return Future.error(Exception('正文请求失败[${response.statusCode}] $bookUrl'));
      }
    }catch(e){
      developer.log('正文请求错误[$bookUrl]:$e');
      return Future.error(Exception('正文请求错误[$bookUrl]:$e'));
    }
    return Future.value(null);
  }

}

String? parseContent(String url,String html,BookContentRuleBean rule){
  developer.log('开始解析正文 $rule');
  var parser = HParser(html);
  var content = parser.parseRuleString(rule.content);
  if(rule.replaceRegex == null || rule.replaceRegex!.isEmpty){
    parser.destory();
    return content??"";
  }
  parser.destory();
  return HParser.parseReplaceRule(content??"",rule.replaceRegex!);
}

String? parseNextPage(String url,String html,String next){
  developer.log('解析下一页的链接');
  var parser = HParser(html);
  var result = parser.parseRuleStrings(next);
  parser.destory();
  return result.isNotEmpty?result[0]:null;
}