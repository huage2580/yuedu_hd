
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:worker_manager/worker_manager.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_parser/h_parser/h_eval_parser.dart';
import 'package:yuedu_parser/h_parser/h_parser.dart';
import 'dart:developer' as developer;

import 'BookInfoBean.dart';
import 'utils.dart';

typedef void OnBookSearch(BookInfoBean data);


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
  dynamic searchBookFromEnabledSource(String key,String cancelToken,{bool exactSearch = false,String author,OnBookSearch onBookSearch}) async{
    await Executor().warmUp();

    var bookSources = await DatabaseHelper().queryAllBookSourceEnabled();
    if(tokenList.contains(cancelToken)){
      developer.log('---***搜索结束[token重复]***---');
      return Future.value(-1);
    }
    tokenList.add(cancelToken);
    //不做分页了
    var sourcesNotEmpty = List<BookSourceBean>();
    for (var value1 in bookSources) {
      if(value1.searchUrl!=null&&value1.searchUrl.isNotEmpty){
        sourcesNotEmpty.add(value1);
      }
    }
    var eparser = HEvalParser({'page':1,'key':key});
    var searchOptionList = sourcesNotEmpty.map((e){
      var bean = e.mapSearchUrlBean();
      bean.url = eparser.parse(bean.url);
      bean.body = eparser.parse(bean.body);
      //精确搜索
      bean.exactSearch = exactSearch;
      if(bean.exactSearch){
        bean.bookName = key;
        bean.bookAuthor = author;
      }
      return bean;
    }).toList();
    while(tokenList.contains(cancelToken) && searchOptionList.isNotEmpty){
      developer.log('开启一轮搜索:本次剩余书源->${searchOptionList.length}');
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
      requestOptions.responseDecoder = Utils.gbkDecoder;
    }
    try{
      var dio = Dio();
      dio.options.connectTimeout = 5000;
      var response = await dio.request(options.url,options: requestOptions,data: options.body);
      if(response.statusCode == 200){
        await _parseResponse(response.data,options,onBookSearch);
      }else{
        developer.log('搜索错误:书源错误${response.statusCode}');
      }
    }catch(e){
      developer.log('搜索错误:$e');
    }

    return Future.value(0);
  }

  dynamic _parseResponse(String response,BookSearchUrlBean options, OnBookSearch onBookSearch) async{
    int sourceId = options.sourceId;
    developer.log('解析搜索返回内容：$sourceId|${DateTime.now()}');
    BookSourceBean source = await DatabaseHelper().queryBookSourceById(sourceId);
    var ruleBean = source.mapSearchRuleBean();
    try{
      //填充需要传输的数据
      var kv = {
        'response':response,
        'rule_bookList':ruleBean.bookList,
        'rule_name':ruleBean.name,
        'rule_author':ruleBean.author,
        'rule_kind':ruleBean.kind,
        'rule_intro':ruleBean.intro,
        'rule_lastChapter':ruleBean.lastChapter,
        'rule_wordCount':ruleBean.wordCount,
        'rule_bookUrl':ruleBean.bookUrl,
        'rule_tocUrl':ruleBean.tocUrl,
        'rule_coverUrl':ruleBean.coverUrl,
      };
      //用线程池执行解析，大概需要400ms
      var str = await Executor().execute(arg1:kv,fun1: _parse);
      var tmp = jsonDecode(str);
      List<BookInfoBean> bookInfoList = List<BookInfoBean>();
      for(var t in tmp){
        bookInfoList.add(BookInfoBean.fromMap(t));
      }
      developer.log('解析搜索返回内容完成：$sourceId|${DateTime.now()}');
      for (var bookInfo in bookInfoList) {
        //链接修正
        bookInfo.bookUrl = Utils.checkLink(source.bookSourceUrl, bookInfo.bookUrl);
        bookInfo.coverUrl = Utils.checkLink(source.bookSourceUrl, bookInfo.coverUrl);
        //-------关联到书源-------------
        bookInfo.source_id = source.id;
        bookInfo.sourceBean = source;
        if(bookInfo.name == null || bookInfo.author == null){
          continue;
        }
        bookInfo.name = bookInfo.name.trim();
        bookInfo.author = bookInfo.author.trim();
        if(options.exactSearch){//精确搜索，要求书名和作者完全匹配
          if(bookInfo.name!=options.bookName || bookInfo.author!=options.bookAuthor){
            continue;
          }
        }
        var bookId = await DatabaseHelper().insertBookToDB(bookInfo);
        bookInfo.id = bookId;
        onBookSearch(bookInfo);
      }
    }catch(e){
      developer.log('搜索解析错误[${source.bookSourceName},${source.bookSourceUrl}]:$e');
    }
    return Future.value(0);
  }





}



String _parse(Map map){
  String response = map['response'];
  BookSearchRuleBean ruleBean = BookSearchRuleBean();
  ruleBean.bookList = map['rule_bookList'];
  ruleBean.name = map['rule_name'];
  ruleBean.author = map['rule_author'];
  ruleBean.kind = map['rule_kind'];
  ruleBean.intro = map['rule_intro'];
  ruleBean.lastChapter = map['rule_lastChapter'];
  ruleBean.wordCount = map['rule_wordCount'];
  ruleBean.bookUrl = map['rule_bookUrl'];
  ruleBean.tocUrl = map['rule_tocUrl'];
  ruleBean.coverUrl = map['rule_coverUrl'];


  List<BookInfoBean> result = List<BookInfoBean>();
  try{
    var bookList = HParser(response).parseRuleElements(ruleBean.bookList);
    for (var bookElement in bookList) {
      var bookInfo = BookInfoBean();
      var bookParser = HParser(bookElement.outerHtml);
      bookInfo.name = bookParser.parseRuleString(ruleBean.name);
      bookInfo.author = bookParser.parseRuleString(ruleBean.author);
      var kinds = bookParser.parseRuleStrings(ruleBean.kind);
      bookInfo.kind = kinds==null?'':kinds.join('|');
      bookInfo.intro = bookParser.parseRuleString(ruleBean.intro);
      bookInfo.lastChapter = bookParser.parseRuleString(ruleBean.lastChapter);
      bookInfo.wordCount = bookParser.parseRuleString(ruleBean.wordCount);
      bookInfo.bookUrl = bookParser.parseRuleString(ruleBean.bookUrl);
      if(bookInfo.bookUrl == null){
        bookInfo.bookUrl = bookParser.parseRuleString(ruleBean.tocUrl);
      }
      bookInfo.coverUrl = bookParser.parseRuleString(ruleBean.coverUrl);
      if(bookInfo.name == null || bookInfo.author == null){
        continue;
      }
      bookInfo.name = bookInfo.name.trim();
      bookInfo.author = bookInfo.author.trim();
      result.add(bookInfo);
    }
  }catch(e){
    developer.log('搜索解析错误:$e');
  }
  var temp = List<Map<String,dynamic>>();
  for (var value in result) {
    temp.add(value.toMap());
  }
  return jsonEncode(temp);
}

