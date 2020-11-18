

import 'dart:collection';
import 'dart:convert';

import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_parser/h_parser/regexp_rule.dart';

class BookSourceHelper{
  static BookSourceHelper _instance;
  static BookSourceHelper getInstance(){
    if(_instance == null){
      _instance = BookSourceHelper._init();
    }
    return _instance;
  }

  BookSourceHelper._init(){
    //
  }

  StringBuffer _log = StringBuffer();

  Future<List<BookSourceBean>> parseSourceString(String jsonStr) async{
    _log.clear();
    _log.write('---解析---\n');
    var result = List<BookSourceBean>();

    var sourceList = jsonDecode(jsonStr);
    for(var item in sourceList){
      if(!_checkCompatible(item)){
        _log.writeln('[x不兼容过滤]->${item['bookSourceUrl']}');
        continue;
      }
      result.add(_mapJson(item));
      _log.writeln('[兼容]->【${item['bookSourceName']} 】${item['bookSourceUrl']}');
    }
    _log.writeln('---解析结束---');
    return Future.value(result);
  }


  Future<int> updateDataBases(List<BookSourceBean> beanList) async{
    _log.writeln("准备更新数据库:数量${beanList.length}");
    var result = 0;
    for(var i in beanList){
      try{
        await updateDataBase(i);
        result += 1;
        _log.writeln("更新数据:${i.bookSourceUrl}");
      }catch(e){
        _log.writeln(e.toString());
        break;
      }
    }
    _log.writeln("更新数据库结束:更新数量$result");
    return Future.value(result);
  }

  ///没记录插入，有记录更新数据库
  Future<int> updateDataBase(BookSourceBean input) async{
    var db = await DatabaseHelper().withDB();
    //被迫采用这种方式
    var update = await db.rawInsert('''
      INSERT OR IGNORE INTO book_sources(
      _id,
      bookSourceName,
      bookSourceGroup,
      bookSourceUrl,
      bookUrlPattern,
      bookSourceType,
      enabled,
      enabledExplore,
      header,
      loginUrl,
      bookSourceComment,
      lastUpdateTime,
      weight,
      exploreUrl,
      ruleExplore,
      searchUrl,
      ruleSearch,
      ruleBookInfo,
      ruleToc,
      ruleContent
      )
      VALUES
      (
      ?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?
      )
    ''',[
      input.id,
      input.bookSourceName,
      input.bookSourceGroup,
      input.bookSourceUrl,
      input.bookUrlPattern,
      input.bookSourceType,
      input.enabled?1:0,
      input.enabledExplore?1:0,
      input.header,
      input.loginUrl,
      input.bookSourceComment,
      input.lastUpdateTime,
      input.weight,
      input.exploreUrl,
      input.ruleExplore,
      input.searchUrl,
      input.ruleSearch,
      input.ruleBookInfo,
      input.ruleToc,
      input.ruleContent
    ]);

    db.update(DatabaseHelper.TABLE_SOURCE, {
      "bookSourceName":input.bookSourceName,
      "bookSourceGroup":input.bookSourceGroup,
      "bookSourceUrl":input.bookSourceUrl,
      "bookUrlPattern":input.bookUrlPattern,
      "bookSourceType":input.bookSourceType,
      "enabled":input.enabled?1:0,
      "enabledExplore":input.enabledExplore?1:0,
      "header":input.header,
      "loginUrl":input.loginUrl,
      "bookSourceComment":input.bookSourceComment,
      "lastUpdateTime":input.lastUpdateTime,
      "weight":input.weight,
      "exploreUrl":input.exploreUrl,
      "ruleExplore":input.ruleExplore,
      "searchUrl":input.searchUrl,
      "ruleSearch":input.ruleSearch,
      "ruleBookInfo":input.ruleBookInfo,
      "ruleToc":input.ruleToc,
      "ruleContent":input.ruleContent
    },where: "bookSourceUrl = ?",whereArgs: [input.bookSourceUrl]);
    return Future.value(update);
  }


  ///过滤不兼容的书源
  bool _checkCompatible(LinkedHashMap item){
    var itemStr = item.toString();
    if(RegExp(RegexpRule.PARSER_TYPE_JS).hasMatch(itemStr)){
      return false;
    }
    if(RegExp(RegexpRule.EXPRESSION_JS_TOKEN).hasMatch(itemStr)){
      return false;
    }
    if(RegExp(RegexpRule.PARSER_TYPE_JSON).hasMatch(itemStr)){
      return false;
    }
    return true;
  }

  BookSourceBean _mapJson(LinkedHashMap map){
    BookSourceBean bean = BookSourceBean();
    bean.bookSourceName = map['bookSourceName'];
    bean.bookSourceGroup = map['bookSourceGroup'];
    bean.bookSourceUrl = map['bookSourceUrl'];
    bean.bookUrlPattern = map['bookUrlPattern'];
    bean.bookSourceType = map['bookSourceType'];
    bean.enabled = map['enabled'];
    bean.enabledExplore = map['enabledExplore'];
    bean.header = map['header'];
    bean.loginUrl = map['loginUrl'];
    bean.bookSourceComment = map['bookSourceComment'];
    bean.weight = map['weight'];
    bean.exploreUrl = map['exploreUrl'];
    bean.searchUrl = map['searchUrl'];

    bean.ruleExplore = jsonEncode(map['ruleExplore']);
    bean.ruleSearch = jsonEncode(map['ruleSearch']);
    bean.ruleBookInfo = jsonEncode(map['ruleBookInfo']);
    bean.ruleToc = jsonEncode(map['ruleToc']);
    bean.ruleContent = jsonEncode(map['ruleContent']);

    return bean;
  }

  String getLog(){
    return _log.toString();
  }

}