
import 'package:dio/dio.dart';
import 'package:gbk_codec/gbk_codec.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_parser/h_parser/h_eval_parser.dart';

///搜索书籍
///1.所有启用的书源
///2.构造请求
///3.解析结果
///4.存入数据库
///5.通知数据更新
///并发，可取消
class BookSearchHelper{
  static BookSearchHelper _instance;
  static getInstance(){
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
  dynamic searchBookFromEnabledSource(String key,String cancelToken,SearchCallBack searchCallBack) async{
    var bookSources = await DatabaseHelper().queryAllBookSourceEnabled();
    tokenList.add(cancelToken);
    //不做分页了
    var eparser = HEvalParser({'page':1,'key':key});
    var searchOptionList = bookSources.map((e){
      var bean = e.mapUrlBean();
      bean.url = eparser.eval(bean.url);
      bean.body = eparser.eval(bean.body);
    }).toList();
    while(searchOptionList.isNotEmpty && tokenList.contains(cancelToken)){
      var batch = searchOptionList.take(4).toList();
      await _batchSearch(batch, searchCallBack);
    }
    print('搜索结束');
  }

  dynamic cancelSearch(String token){
    tokenList.remove(token);
  }

  ///单次循环，n个书源
  dynamic _batchSearch(List<BookSearchUrlBean> options,SearchCallBack searchCallBack) async{
    var requests = options.map((e) => _request(e, searchCallBack));
    return Future.wait(requests);
  }

  dynamic _request(BookSearchUrlBean options,SearchCallBack searchCallBack) async{
    Options requestOptions = Options(method: options.method,headers: options.headers);
    if(options.charset == 'gbk'){
      requestOptions.responseDecoder = _gbkDecoder;
    }
    var response = await Dio().request(options.url,options: requestOptions,data: options.body);
    var bookBean = _parseResponse(response.data);
    searchCallBack.onBookSearch(bookBean);
  }

  dynamic _parseResponse(String response){

  }

  String _gbkDecoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
    return gbk_bytes.decode(responseBytes);
  }

}

abstract class SearchCallBack{
  void onBookSearch(dynamic bookBean);
}