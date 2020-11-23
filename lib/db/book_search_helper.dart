
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_parser/h_parser/h_eval_parser.dart';
import 'package:yuedu_parser/h_parser/h_parser.dart';
import 'dart:developer' as developer;

import 'BookInfoBean.dart';


typedef void OnBookSearch(dynamic data);


///搜索书籍
///1.所有启用的书源
///2.构造请求
///3.解析结果
///4.存入数据库
///5.通知数据更新
///并发，可取消
class BookSearchHelper{
  static BookSearchHelper _instance;
  static BookSearchHelper getInstance(){
    if(_instance==null){
      _instance = BookSearchHelper._init();
    }
    return _instance;
  }

  var tokenList = ['none'];

  BookSearchHelper._init(){
    //
  }

  ///
  dynamic searchBookFromEnabledSource(String key,String cancelToken,{OnBookSearch onBookSearch}) async{
    var bookSources = await DatabaseHelper().queryAllBookSourceEnabled();
    if(tokenList.contains(cancelToken)){
      developer.log('---***搜索结束[token重复]***---');
      return Future.value(-1);
    }
    tokenList.add(cancelToken);
    //不做分页了
    var eparser = HEvalParser({'page':1,'key':key});
    var searchOptionList = bookSources.takeWhile((value) => value.searchUrl!=null&&value.searchUrl.isNotEmpty).map((e){
      var bean = e.mapSearchUrlBean();
      bean.url = eparser.parse(bean.url);
      bean.body = eparser.parse(bean.body);
      return bean;
    }).toList();
    while(tokenList.contains(cancelToken) && searchOptionList.isNotEmpty){
      developer.log('开启一轮搜索:${tokenList.length}');
      var c = 0;
      var batchList = List<BookSearchUrlBean>();
      while(searchOptionList.isNotEmpty && c < 10){// 10个书源一批
        var b = searchOptionList.removeAt(0);
        batchList.add(b);
        c += 1;
      }
      if(batchList.isEmpty){
        break;
      }
      await _batchSearch(batchList, onBookSearch);
    }
    cancelSearch(cancelToken);
    developer.log('---***搜索结束***---');
    return Future.value(0);
  }

  dynamic cancelSearch(String token){
    tokenList.remove(token);
    developer.log('搜索企图终止->$token');
  }

  ///单次循环，n个书源
  dynamic _batchSearch(List<BookSearchUrlBean> options,OnBookSearch onBookSearch) async{
    var requests = options.map((e) => _request(e, onBookSearch));
    return Future.wait(requests);
  }

  Future<dynamic> _request(BookSearchUrlBean options,OnBookSearch onBookSearch) async{
    var contentType = options.headers['content-type'];
    Options requestOptions = Options(method: options.method,headers: options.headers,contentType:contentType ,sendTimeout: 5000,receiveTimeout: 5000);
    if(options.charset == 'gbk'){
      requestOptions.responseDecoder = _gbkDecoder;
    }
    try{
      var dio = Dio();
      dio.options.connectTimeout = 5000;
      var response = await dio.request(options.url,options: requestOptions,data: options.body);
      if(response.statusCode == 200){
        await _parseResponse(response.data,options.sourceId,onBookSearch);
      }else{
        developer.log('搜索错误:书源错误${response.statusCode}');
      }
    }catch(e){
      developer.log('搜索错误:$e');
    }

    return Future.value(0);
  }

  dynamic _parseResponse(String response, int sourceId, OnBookSearch onBookSearch) async{
    developer.log('解析搜索返回内容：$sourceId');
    BookSourceBean source = await DatabaseHelper().queryBookSourceById(sourceId);
    var ruleBean = source.mapSearchRuleBean();
    try{
      var bookList = HParser(response).parseRuleElements(ruleBean.bookList);
      for (var bookElement in bookList) {
        var bookInfo = BookInfoBean();
        var bookParser = HParser(bookElement.innerHtml);
        bookInfo.name = bookParser.parseRuleString(ruleBean.name);
        bookInfo.author = bookParser.parseRuleString(ruleBean.author);
        bookInfo.kind = bookParser.parseRuleStrings(ruleBean.kind);
        bookInfo.intro = bookParser.parseRuleString(ruleBean.intro);
        bookInfo.lastChapter = bookParser.parseRuleString(ruleBean.lastChapter);
        bookInfo.wordCount = bookParser.parseRuleString(ruleBean.wordCount);
        bookInfo.bookUrl = bookParser.parseRuleString(ruleBean.bookUrl);
        if(bookInfo.bookUrl == null){
          bookInfo.bookUrl = bookParser.parseRuleString(ruleBean.tocUrl);
        }
        bookInfo.coverUrl = bookParser.parseRuleString(ruleBean.coverUrl);
        //链接修正
        bookInfo.bookUrl = _checkLink(source.bookSourceUrl, bookInfo.bookUrl);
        bookInfo.coverUrl = _checkLink(source.bookSourceUrl, bookInfo.coverUrl);
        //-------关联到书源-------------
        bookInfo.source_id = source.id;
        bookInfo.sourceBean = source;
        onBookSearch(bookInfo);
      }
    }catch(e){
      developer.log('搜索解析错误[${source.bookSourceName},${source.bookSourceUrl}]:$e');
    }
    return Future.value(0);
  }

  String _gbkDecoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
    return gbk_bytes.decode(responseBytes);
  }

  String _checkLink(String host,String input){
    if(input == null || input.isEmpty){
      return "";
    }
    if(input.startsWith('http')){
      return input;
    }else{
      return host + input;
    }
  }

}

