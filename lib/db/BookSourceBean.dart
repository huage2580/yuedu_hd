
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

  BookSourceBean.fromJson(Map<String,dynamic> map){
    //导入兼容2.0的书源,重新做一次映射
    if(map['ruleSearchUrl']!=null){//2.0的书源，转换兼容
      map['enabled'] = true;
      map['enabledExplore'] = true;
      map['bookSourceType'] = 0;
      map['bookUrlPattern'] = map['ruleBookUrlPattern'];
      map['header'] = '';
      map['loginUrl'] = '';
      map['bookSourceComment'] = '';
      String searchUrl = map['ruleSearchUrl'];
      //POST方式的转换
      searchUrl = searchUrl.replaceAll('searchKey', '{{key}}');
      var temp = searchUrl.split('@');
      var xurl = temp[0];
      if(temp.length >1){//POST方式
        xurl +=',{ "method": "POST","body": "${temp[1]}"}';
      }
      map['searchUrl'] = xurl;
      map['ruleExplore'] = {

      };
      map['ruleSearch'] = {
        'name':map['ruleSearchName'],
        'author':map['ruleSearchAuthor'],
        'bookList':map['ruleSearchList'],
        'bookUrl':map['ruleSearchNoteUrl'],
        'coverUrl':map['ruleSearchCoverUrl'],
        'intro':map['ruleIntroduce'],
        'kind':map['ruleSearchKind'],
        'lastChapter':map['ruleSearchLastChapter'],
        'wordCount':'',
      };
      map['ruleBookInfo'] = {
        'coverUrl' : map['ruleCoverUrl'],
        'tocUrl' : map['ruleChapterUrl'],
        'intro' : map['ruleIntroduce'],
      };
      map['ruleToc'] = {
        'chapterList':map['ruleChapterList'],
        'chapterName':map['ruleChapterName'],
        'chapterUrl':map['ruleContentUrl'],
        'nextTocUrl':map['ruleChapterUrlNext'],

      };
      map['ruleContent'] = {
        'content':map['ruleBookContent'],
        'nextContentUrl':map['ruleContentUrlNext'],
        'replaceRegex':'',
      };

    }




    //---------------------------------------
    id = map['_id'];
    bookSourceName = map['bookSourceName'];
    bookSourceGroup = map['bookSourceGroup'];
    bookSourceUrl = map['bookSourceUrl'];
    bookUrlPattern = map['bookUrlPattern']??'';
    bookSourceType = map['bookSourceType']??0;

    header = map['header'];
    loginUrl = map['loginUrl'];
    bookSourceComment = map['bookSourceComment'];
    weight = map['weight']??0;
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
    var tenabledExplore = map['enabledExplore']??0;
    if(tenabledExplore is int){
      enabledExplore = tenabledExplore == 1;
    }else{
      enabledExplore = tenabledExplore;
    }
  }


  BookSearchUrlBean mapSearchUrlBean(){
    if(searchUrl == null || searchUrl.isEmpty){
      return null;
    }
    var bean = BookSearchUrlBean();
    bean.sourceId = id;
    var index = searchUrl.indexOf(',');
    var temp = [searchUrl];
    if(index > 0){
      temp[0] = searchUrl.substring(0,index);
      temp.add(searchUrl.substring(index+1));
    }
    bean.url = temp[0];
    if(!bean.url.startsWith('http')){
      bean.url = bookSourceUrl + bean.url;
    }
    bean.method = 'GET';
    bean.charset = 'utf8';
    bean.headers = {};

    if(temp.length == 2){
      var map = jsonDecode(temp[1]);
      bean.method = map['method']==null?'GET':map['method'];
      try{
        bean.headers = map['headers']==null?{}:jsonDecode(map['headers']);
        if(bean.method == 'POST' && bean.headers.isEmpty){
          bean.headers = {'content-type':r"application/x-www-form-urlencoded"};
        }
      }catch(e){
        //pass 有些headers没有双引号，不兼容
      }
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

  BookSearchRuleBean mapSearchRuleBean(){
    BookSearchRuleBean bean = BookSearchRuleBean();
    var map = jsonDecode(jsonDecode(ruleSearch));
    bean.name = map['name'];
    bean.author = map['author'];
    bean.bookList = map['bookList'];
    bean.bookUrl = map['bookUrl'];
    bean.coverUrl = map['coverUrl'];
    bean.intro = map['intro'];
    bean.kind = map['kind'];
    bean.lastChapter = map['lastChapter'];
    bean.wordCount = map['wordCount'];
    return bean;
  }

  BookTocRuleBean mapTocRuleBean(){
    BookTocRuleBean bean = BookTocRuleBean();
    var map = jsonDecode(jsonDecode(ruleToc));
    bean.chapterList = map['chapterList'];
    bean.chapterName = map['chapterName'];
    bean.chapterUrl = map['chapterUrl'];
    bean.nextTocUrl = map['nextTocUrl'];
    return bean;
  }

  BookContentRuleBean mapContentRuleBean(){
    BookContentRuleBean bean = BookContentRuleBean();
    var map = jsonDecode(jsonDecode(ruleContent));
    bean.content = map['content'];
    bean.nextContentUrl = map['nextContentUrl'];
    bean.replaceRegex = map['replaceRegex'];
    return bean;
  }

  BookInfoRuleBean mapInfoRuleBean(){
    BookInfoRuleBean bean = BookInfoRuleBean();
    var map = jsonDecode(jsonDecode(ruleBookInfo));
    bean.coverUrl = map['coverUrl'];
    bean.tocUrl = map['tocUrl'];
    bean.intro = map['intro'];
    return bean;
  }

}

class BookSearchUrlBean{
  String url;
  Map<String,String> headers;
  String method;
  String body;
  String charset;
  int sourceId;

  //参数
  bool exactSearch = false;
  String bookName;
  String bookAuthor;

  @override
  String toString() {
    return 'BookSearchUrlBean{url: $url, headers: $headers, method: $method, body: $body, charset: $charset}';
  } //gbk gb2312,utf8


}


class BookSearchRuleBean{
  String name;
  String author;
  String bookList;
  String bookUrl;
  String coverUrl;
  String intro;
  String kind;
  String lastChapter;
  String wordCount;
  String tocUrl;

  @override
  String toString() {
    return 'BookSearchRuleBean{name: $name, author: $author, bookList: $bookList, bookUrl: ${bookUrl??tocUrl}, coverUrl: $coverUrl, intro: $intro, kind: $kind, lastChapter: $lastChapter, wordCount: $wordCount}';
  }
}

class BookTocRuleBean{
  String chapterList;
  String chapterName;
  String chapterUrl;
  String nextTocUrl;

  @override
  String toString() {
    return 'BookTocRuleBean{chapterList: $chapterList, chapterName: $chapterName, chapterUrl: $chapterUrl,nextTocUrl:$nextTocUrl}';
  }
}


class BookContentRuleBean{
  String content;
  String nextContentUrl;
  String replaceRegex;

  @override
  String toString() {
    return 'BookContentRuleBean{content: $content, nextContentUrl: $nextContentUrl, replaceRegex: $replaceRegex}';
  }
}

class BookInfoRuleBean{
  String intro;
  String coverUrl;
  String tocUrl;

  @override
  String toString() {
    return 'BookInfoRuleBean{intro: $intro, coverUrl: $coverUrl, tocUrl: $tocUrl}';
  }
}