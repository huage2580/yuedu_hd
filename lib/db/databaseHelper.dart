

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'BookSourceBean.dart';

class DatabaseHelper{
  static const DB_PATH = "yuedu.db";
  static const TABLE_SOURCE = 'book_sources';

  static const _SQL_CREATE_BOOK_SOURCES= '''
  CREATE TABLE "book_sources" (
	"_id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	"bookSourceName"	TEXT NOT NULL,
	"bookSourceGroup"	TEXT,
	"bookSourceUrl"	TEXT,
	"bookUrlPattern"	TEXT,
	"bookSourceType" INTEGER NOT NULL DEFAULT 0,
	"customOrder"	INTEGER DEFAULT 0,
	"enabled"	INTEGER NOT NULL DEFAULT 0,
	"enabledExplore"	INTEGER NOT NULL DEFAULT 0,
	"header"	TEXT,
	"loginUrl"	TEXT,
	"bookSourceComment"	TEXT,
	"lastUpdateTime"	REAL,
	"weight"	INTEGER NOT NULL DEFAULT 0,
	"exploreUrl"	TEXT,
	"ruleExplore"	TEXT,
	"searchUrl"	TEXT,
	"ruleSearch"	TEXT,
	"ruleBookInfo"	TEXT,
	"ruleToc"	TEXT,
	"ruleContent"	TEXT
);
  ''';

  static const _SQL_INDEX_SOURCE = '''
  CREATE UNIQUE INDEX "sources_id_index" ON "book_sources" (
	"_id");
	CREATE UNIQUE INDEX "sources_url_index" ON "book_sources" (
	"bookSourceUrl");
  ''';

  static DatabaseHelper _instance;

  Database _database;

  static _getInstance(){
    if(_instance == null){
      _instance = DatabaseHelper._internal();
    }
    return _instance;
  }
  factory DatabaseHelper() => _getInstance();

  DatabaseHelper._internal(){
    //nothing
    withDB().then((value) => print("数据库:${value.path},${value.isOpen}"));
  }

  Future<Database> withDB() async{
    if(_database!=null){
      return Future.value(_database);
    }
    return await openDatabase(DB_PATH,version: 1,onCreate: (Database db, int version) async {
      await _executeMultiSQL(db,_SQL_CREATE_BOOK_SOURCES);
      await _executeMultiSQL(db,_SQL_INDEX_SOURCE);
    });
  }

  Future<int> _executeMultiSQL(Database db,String sql) async{
    var list = sql.split(';');
    for(var each in list){
      if(each.trim().isNotEmpty){
        await db.execute(each);
      }
    }
    return Future.value(0);
  }

  //------书源管理----------

  ///没记录插入，有记录更新数据库,通过书源url索引
  Future<int> insertOrUpdateBookSource(BookSourceBean input) async{
    var db = await withDB();
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

  /// 全部书源
  Future<List<BookSourceBean>> queryAllBookSource({String title}) async{
    var db = await withDB();
    var result = await db.query(TABLE_SOURCE,
        where: title!=null?"bookSourceName LIKE '%$title%'":null
    );
    var beanList = result.map((e) => BookSourceBean.fromJson(e));
    return Future.value(beanList.toList());
  }





}