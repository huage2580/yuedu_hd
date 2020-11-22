
import 'dart:convert';

class BookSourceBean{

  int id;
  String bookSourceName;
  String bookSourceGroup;
  String bookSourceUrl;
  String bookUrlPattern;
  int bookSourceType;
  bool enabled;
  bool enabledExplore;
  String header;
  String loginUrl;
  String bookSourceComment;
  num lastUpdateTime;
  int weight;
  String exploreUrl;
  String ruleExplore;//json
  String searchUrl;
  String ruleSearch;//json
  String ruleBookInfo;//json
  String ruleToc;//json
  String ruleContent;//json

  //--------
  bool localSelect = false;

  @override
  String toString() {
    return 'BookSourceBean{_id: $id, bookSourceName: $bookSourceName, bookSourceGroup: $bookSourceGroup, bookSourceUrl: $bookSourceUrl, bookUrlPattern: $bookUrlPattern, bookSourceType: $bookSourceType, enabled: $enabled, enabledExplore: $enabledExplore, header: $header, loginUrl: $loginUrl, bookSourceComment: $bookSourceComment, lastUpdateTime: $lastUpdateTime, weight: $weight, exploreUrl: $exploreUrl, ruleExplore: $ruleExplore, searchUrl: $searchUrl, ruleSearch: $ruleSearch, ruleBookInfo: $ruleBookInfo, ruleToc: $ruleToc, ruleContent: $ruleContent}';
  } //json

  BookSourceBean.fromJson(Map map){
    id = map['_id'];
    bookSourceName = map['bookSourceName'];
    bookSourceGroup = map['bookSourceGroup'];
    bookSourceUrl = map['bookSourceUrl'];
    bookUrlPattern = map['bookUrlPattern'];
    bookSourceType = map['bookSourceType'];

    header = map['header'];
    loginUrl = map['loginUrl'];
    bookSourceComment = map['bookSourceComment'];
    weight = map['weight'];
    exploreUrl = map['exploreUrl'];
    searchUrl = map['searchUrl'];
    ruleExplore = jsonEncode(map['ruleExplore']);
    ruleSearch = jsonEncode(map['ruleSearch']);
    ruleBookInfo = jsonEncode(map['ruleBookInfo']);
    ruleToc = jsonEncode(map['ruleToc']);
    ruleContent = jsonEncode(map['ruleContent']);

    var tenabled = map['enabled'];
    if(tenabled is int){
      enabled = tenabled == 1;
    }else{
      enabled = tenabled;
    }
    var tenabledExplore = map['enabledExplore'];
    if(tenabledExplore is int){
      enabledExplore = tenabledExplore == 1;
    }else{
      enabledExplore = tenabledExplore;
    }
  }


  BookSearchUrlBean mapUrlBean(){
    var bean = BookSearchUrlBean();
    var temp = searchUrl.split(',');
    bean.url = temp[0];
    if(!bean.url.startsWith('http')){
      bean.url = bookSourceUrl + bean.url;
    }
    if(temp.length == 2){
      var map = jsonDecode(temp[1]);
      bean.headers = map['headers'];
      bean.method = map['method']==null?'GET':map['method'];
      bean.body = map['body'];
      bean.charset = map['charset']==null?'utf8':map['charset'];
      if(bean.charset.startsWith('gb')){
        bean.charset = 'gbk';
      }else{
        bean.charset = 'utf8';
      }
    }

    return bean;
  }



}

class BookSearchUrlBean{
  String url;
  Map<String,String> headers;
  String method;
  String body;
  String charset;//gbk gb2312,utf8
}