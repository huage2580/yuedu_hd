
import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'package:worker_manager/worker_manager.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/CountLock.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:reader_parser2/h_parser/h_eval_parser.dart';
import 'package:reader_parser2/h_parser/h_parser.dart';
import 'dart:developer' as developer;

import 'BookInfoBean.dart';
import 'utils.dart';

typedef void OnBookSearch(BookInfoBean data);
typedef void UpdateList();//批量更新列表，怕太卡了


///搜索书籍
///1.所有启用的书源
///2.构造请求
///3.解析结果
///4.存入数据库
///5.通知数据更新
///并发，可取消
class BookSearchHelper{
  static BookSearchHelper? _instance;
  static BookSearchHelper getInstance(){
    if(_instance==null){
      _instance = BookSearchHelper._init();
    }
    return _instance!;
  }

  var tokenList = ['none'];
  late Dio dio;
  var _countLocker = CountLock(8);

  BookSearchHelper._init(){
    //
    dio = Utils.createDioClient();
  }

  ///
  dynamic searchBookFromEnabledSource(String key,String cancelToken,{bool exactSearch = false,String? author,OnBookSearch? onBookSearch,UpdateList? updateList}) async{
    // await Executor().warmUp();

    var bookSources = await DatabaseHelper().queryAllBookSourceEnabled();
    if(tokenList.contains(cancelToken)){
      print('---***搜索结束[token重复]***---');
      return Future.value(-1);
    }
    tokenList.add(cancelToken);
    //不做分页了
    List<BookSourceBean> sourcesNotEmpty = [];
    for (var value1 in bookSources) {
      if(value1.searchUrl!=null&&value1.searchUrl!.isNotEmpty){
        sourcesNotEmpty.add(value1);
      }
    }
    var eparser = HEvalParser({'page':1,'key':key});
    var searchOptionList = sourcesNotEmpty.map((e){
      var bean = e.mapSearchUrlBean();
      if(bean == null){
        return null;
      }
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
      print('开启一轮搜索:本次剩余书源->${searchOptionList.length}');
      var b = searchOptionList.removeAt(0);
      if(b!=null){
        await _countLocker.request();
        request(b, onBookSearch,updateList).whenComplete(() => _countLocker.release());
      }
    }
    cancelSearch(cancelToken);
    await _countLocker.waitDone();
    print('---***搜索结束***---');
    return Future.value(0);
  }

  dynamic cancelSearch(String token){
    tokenList.remove(token);
    print('搜索企图终止->$token');
  }


  Future<dynamic> request(BookSearchUrlBean options,OnBookSearch? onBookSearch,UpdateList? updateList,{BookSourceBean? sourceBean}) async{
    var headers = Utils.buildHeaders(options.url!,ContentType.html.toString(), options.headers);
    Options requestOptions = Options(method: options.method,headers: headers,sendTimeout: 5000,receiveTimeout: 5000,followRedirects: true);
    if(options.charset == 'gbk'){
      options.url = UrlGBKEncode().encode(options.url);
      options.body = UrlGBKEncode().encode(options.body);
    }
    requestOptions.responseDecoder = Utils.gbkDecoder;
    try{

      dio.options.connectTimeout = 10000;
      print('搜索书籍:$options,$headers');
      var response = await dio.request(options.url!,options: requestOptions,data: options.body).timeout(Duration(seconds: 8));
      if(response.statusCode == 200){
        print('搜索请求成功[${options.url}]');
        await _parseResponse(response.data,options,onBookSearch,sourceBean: sourceBean);
        if(updateList!=null){
          updateList();//更新列表UI
        }
      }else{
        print('搜索错误:书源错误${response.statusCode}');
      }
    }catch(e){
      //POST导致的302重新处理
      if(e is DioError){
        var rsp = (e).response;
        if(rsp?.statusCode == 302){
          var location = rsp?.headers["location"];
          var linkRegexp = RegExp(r'http:.*\/');
          var sep = linkRegexp.stringMatch(options.url!);
          var nUrl = Utils.checkLink(sep??"", location?[0]);
          print("302 error 重构请求->$nUrl");
          options.url = nUrl;
          options.method = "GET";
          options.body = "";
          return request(options, onBookSearch,updateList,sourceBean: sourceBean);
        }
      }
      print('搜索错误[${options.url}]:$e');
    }

    return Future.value(0);
  }

  dynamic _parseResponse(String response,BookSearchUrlBean options, OnBookSearch? onBookSearch,{BookSourceBean? sourceBean}) async{
    BookSourceBean? source;
    int sourceId = -1;
    if(options.sourceId == null){//校验的时候
      source = sourceBean;
    }else{
      sourceId = options.sourceId!;
      source = await DatabaseHelper().queryBookSourceById(sourceId);
    }
    var tempTime = DateTime.now();
    print('解析搜索返回内容：$sourceId|$tempTime');
    var ruleBean = source!.mapSearchRuleBean();
    try{
      //填充需要传输的数据
      var kv = {
        'response':response,
        'baseUrl':options.url,
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
      print('解析搜索返回内容开始：$sourceId|${DateTime.now().difference(tempTime).inMilliseconds}');
      //用线程池执行解析，大概需要400ms
      var tmp = await Executor().execute(arg1:kv,fun1: _parse);
      print('解析搜索返回内容结束：$sourceId|${DateTime.now().difference(tempTime).inMilliseconds}');
      List<BookInfoBean> bookInfoList = [];
      for(var t in tmp){
        bookInfoList.add(BookInfoBean.fromMap(t));
      }
      print('解析搜索返回内容完成：$sourceId|${DateTime.now().difference(tempTime).inMilliseconds}');
      for (var bookInfo in bookInfoList) {
        //链接修正
        bookInfo.bookUrl = Utils.checkLink(options.url!, bookInfo.bookUrl);
        bookInfo.coverUrl = Utils.checkLink(options.url!, bookInfo.coverUrl);
        //-------关联到书源-------------
        if(sourceBean == null){
          bookInfo.source_id = source.id;
          bookInfo.sourceBean = source;
          if(bookInfo.name == null || bookInfo.author == null){
            continue;
          }
          if(bookInfo.bookUrl == null || bookInfo.bookUrl!.isEmpty){
            continue;
          }
          bookInfo.name = bookInfo.name!.trim();
          bookInfo.author = bookInfo.author!.trim();
          if(options.exactSearch){//精确搜索，要求书名和作者完全匹配
            if(bookInfo.name!=options.bookName || bookInfo.author!=options.bookAuthor){
              continue;
            }
          }
          var bookId = await DatabaseHelper().insertBookToDB(bookInfo);
          bookInfo.id = bookId;
        }
        onBookSearch!(bookInfo);
      }
    }catch(e){
      print('搜索解析错误[${source.bookSourceName},${source.bookSourceUrl}]:$e');
    }
    return Future.value(0);
  }





}



List<Map<String,dynamic>> _parse(Map map){
  String response = map['response'];
  String baseUrl = map['baseUrl'];
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

  print("搜索解析规则->[$ruleBean]");

  List<BookInfoBean> result = [];

  try{
    var hparser = HParser(response);

    var bId = hparser.parseRuleRaw(ruleBean.bookList!);
    var batchSize = hparser.queryBatchSize(bId);
    for (var i=0;i<batchSize;i++) {
      var bookInfo = BookInfoBean();

      bookInfo.name = hparser.parseRuleStringForParent(bId,ruleBean.name,i);
      bookInfo.author = hparser.parseRuleStringForParent(bId,ruleBean.author,i);
      var kinds = hparser.parseRuleStringForParent(bId,ruleBean.kind,i);
      bookInfo.kind = kinds==null?'':kinds.replaceAll('\n','|');
      bookInfo.intro = hparser.parseRuleStringForParent(bId,ruleBean.intro,i);
      bookInfo.lastChapter = hparser.parseRuleStringForParent(bId,ruleBean.lastChapter,i);
      bookInfo.wordCount = hparser.parseRuleStringForParent(bId,ruleBean.wordCount,i);
      var url = hparser.parseRuleStringsForParent(bId,ruleBean.bookUrl,i);
      bookInfo.bookUrl = url.isNotEmpty?url[0]:null;
      if(bookInfo.bookUrl == null){
        bookInfo.bookUrl = hparser.parseRuleStringForParent(bId,ruleBean.tocUrl,i);
      }
      var coverUrl = hparser.parseRuleStringsForParent(bId,ruleBean.coverUrl,i);
      bookInfo.coverUrl = coverUrl.isNotEmpty?coverUrl[0]:null;
      if(bookInfo.name == null || bookInfo.author == null || bookInfo.bookUrl == null){
        continue;
      }
      bookInfo.name = bookInfo.name!.trim();
      bookInfo.author = bookInfo.author!.trim();
      if(bookInfo.name!.isEmpty || bookInfo.author!.isEmpty|| bookInfo.bookUrl!.isEmpty){
        continue;
      }
      result.add(bookInfo);
    }

    hparser.destoryBatch(bId);
    hparser.destory();
  }catch(e){
    print('搜索解析错误:$e');
  }
  // jsCore.destroy();
  // objectCache.destroy();
  List<Map<String,dynamic>> temp = [];
  for (var value in result) {
    temp.add(value.toMap());
  }
  return temp;
}

