import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'BookInfoBean.dart';
import 'BookSourceBean.dart';
import 'bookChapterBean.dart';

class DatabaseHelper {
  static const DB_PATH = "yuedu.db";
  static const TABLE_SOURCE = 'book_sources';
  static const TABLE_BOOK = 'book';
  static const TABLE_BOOK_COMB_SOURCE = 'book_comb_source';
  static const TABLE_CHAPTER = 'book_chapter';

  static const _SQL_CREATE_BOOK_SOURCES = '''
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

  static const _SQL_CREATE_BOOK = '''
  CREATE TABLE "book" (
  "_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "name" TEXT NOT NULL,
  "author" TEXT NOT NULL,
  "coverUrl" TEXT,
  "intro" TEXT,
  "kind" TEXT,
  "lastChapter" TEXT,
  "wordCount" TEXT,
  "inbookShelf" integer,
  "groupId" INTEGER,
  "updatetime" integer,
  "lastReadChapter" TEXT
);

CREATE INDEX "book_id_index"
ON "book" (
  "_id"
);

CREATE INDEX "book_name_author_index"
ON "book" (
  "name",
  "author"
);
  ''';
  static const _SQL_CREATE_BOOK_COMB_SOURCE = '''
  CREATE TABLE "book_comb_source" (
  "_id" integer NOT NULL PRIMARY KEY AUTOINCREMENT,
  "bookid" INTEGER NOT NULL,
  "sourceid" INTEGER NOT NULL,
  "bookurl" TEXT NOT NULL,
  "used" integer DEFAULT 0,
  FOREIGN KEY ("bookid") REFERENCES "book" ("_id") ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY ("sourceid") REFERENCES "book_sources" ("_id") ON DELETE NO ACTION ON UPDATE NO ACTION
);
  
  ''';
  static const _SQL_CREATE_CHAPTER ='''
  CREATE TABLE "book_chapter" (
  "_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  "bookId" INTEGER,
  "sourceId" INTEGER,
  "name" TEXT,
  "url" TEXT, 
  "content" TEXT,
  "hasRead" integer DEFAULT 0
);

CREATE INDEX "chapter_id_index"
ON "book_chapter" (
  "_id"
);

CREATE UNIQUE INDEX "chapter_url_index"
ON "book_chapter" (
  "url"
);
  ''';


  //----------------------------------------------------------------------
  static DatabaseHelper _instance;

  Database _database;

  static _getInstance() {
    if (_instance == null) {
      _instance = DatabaseHelper._internal();
    }
    return _instance;
  }

  factory DatabaseHelper() => _getInstance();

  DatabaseHelper._internal() {
    //nothing
    withDB().then((value) => print("数据库:${value.path},${value.isOpen}"));
  }

  Future<Database> withDB() async {
    if (_database != null) {
      return Future.value(_database);
    }
    return await openDatabase(DB_PATH, version: 1,
        onCreate: (Database db, int version) async {
      await _executeMultiSQL(db, _SQL_CREATE_BOOK_SOURCES);
      await _executeMultiSQL(db, _SQL_INDEX_SOURCE);
      await _executeMultiSQL(db, _SQL_CREATE_BOOK);
      await _executeMultiSQL(db, _SQL_CREATE_BOOK_COMB_SOURCE);
      await _executeMultiSQL(db, _SQL_CREATE_CHAPTER);
    });
  }

  Future<int> _executeMultiSQL(Database db, String sql) async {
    var list = sql.split(';');
    for (var each in list) {
      if (each.trim().isNotEmpty) {
        await db.execute(each);
      }
    }
    return Future.value(0);
  }

  //------书源管理----------

  ///没记录插入，有记录更新数据库,通过书源url索引
  Future<int> insertOrUpdateBookSource(BookSourceBean input) async {
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
    ''', [
      input.id,
      input.bookSourceName,
      input.bookSourceGroup,
      input.bookSourceUrl,
      input.bookUrlPattern,
      input.bookSourceType,
      input.enabled ? 1 : 0,
      input.enabledExplore ? 1 : 0,
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

    db.update(
        DatabaseHelper.TABLE_SOURCE,
        {
          "bookSourceName": input.bookSourceName,
          "bookSourceGroup": input.bookSourceGroup,
          "bookSourceUrl": input.bookSourceUrl,
          "bookUrlPattern": input.bookUrlPattern,
          "bookSourceType": input.bookSourceType,
          "enabled": input.enabled ? 1 : 0,
          "enabledExplore": input.enabledExplore ? 1 : 0,
          "header": input.header,
          "loginUrl": input.loginUrl,
          "bookSourceComment": input.bookSourceComment,
          "lastUpdateTime": input.lastUpdateTime,
          "weight": input.weight,
          "exploreUrl": input.exploreUrl,
          "ruleExplore": input.ruleExplore,
          "searchUrl": input.searchUrl,
          "ruleSearch": input.ruleSearch,
          "ruleBookInfo": input.ruleBookInfo,
          "ruleToc": input.ruleToc,
          "ruleContent": input.ruleContent
        },
        where: "bookSourceUrl = ?",
        whereArgs: [input.bookSourceUrl]);
    return Future.value(update);
  }

  /// 全部书源
  Future<List<BookSourceBean>> queryAllBookSource({String title}) async {
    var db = await withDB();
    var result = await db.query(TABLE_SOURCE,
        where: title != null ? "bookSourceName LIKE '%$title%'" : null);
    var beanList = result.map((e) => BookSourceBean.fromJson(e));
    return Future.value(beanList.toList());
  }

  /// 全部启用书源
  Future<List<BookSourceBean>> queryAllBookSourceEnabled() async {
    var db = await withDB();
    var result = await db.query(TABLE_SOURCE,
        where: 'enabled == 1');
    var beanList = result.map((e) => BookSourceBean.fromJson(e));
    return Future.value(beanList.toList());
  }

  Future<BookSourceBean> queryBookSourceById(int id) async{
    return await withDB().then((db) => db.query(TABLE_SOURCE,where: '_id = $id').then((value){
      if(value.isEmpty){return null;}
      return BookSourceBean.fromJson(value[0]);
    }));
  }

  /// 删除书源
  dynamic deleteBookSourceByIds(List<int> ids) async {
    var args = ids.fold(
        '0',
            (previousValue, element) =>
        previousValue += (',' + element.toString()));

    return await withDB()
        .then((db) => db.delete(TABLE_SOURCE, where: '_id in ($args)'));
  }
  /// 启用or禁用
  dynamic updateBookSourceStateById(int id,bool enabled) async{
    return await withDB().then((db) => db.update(TABLE_SOURCE, {'enabled':enabled?1:0},where: '_id = $id'));
  }
  /// 启用 or 禁用
  dynamic updateBookSourceStateByIds(List<int> ids,bool enabled) async{
    var args = ids.fold(
        '0',
            (previousValue, element) =>
        previousValue += (',' + element.toString()));
    return await withDB().then((db) => db.update(TABLE_SOURCE, {'enabled':enabled?1:0},where: '_id in ($args)'));
  }
  //-------------书籍管理-----------------
  dynamic insertBookToDB(BookInfoBean infoBean) async{

    return await withDB().then((db) => db.transaction((txn) async{
      //1书表插数据
      var bookCheck = await txn.query(TABLE_BOOK,columns: ['_id'],where: 'name=? and author=?',whereArgs: [infoBean.name??'none',infoBean.author??'none']);
      if(bookCheck.isEmpty){
        //插入数据
        await txn.insert(TABLE_BOOK, {
          'name':infoBean.name,
          'author':infoBean.author,
          'coverUrl':infoBean.coverUrl,
          'intro':infoBean.intro,
          'kind':infoBean.kind ?? '',
          'lastChapter':infoBean.lastChapter,
          'wordCount':infoBean.wordCount,
          'inbookShelf':0,
          'groupId':0,
          'updatetime':DateTime.now().millisecondsSinceEpoch,
        });
      }
      bookCheck = await txn.query(TABLE_BOOK,columns: ['_id','lastChapter','wordCount','coverUrl','intro'],where: 'name=? and author=?',whereArgs: [infoBean.name??'none',infoBean.author??'none']);
      if(bookCheck.isEmpty){
        throw Exception('书表插入异常!');
      }
      var bookBean = bookCheck[0];
      var id = bookBean['_id'];
      //check need Update
      var updateKV = Map<String,dynamic>();
      if(infoBean.lastChapter != null && infoBean.lastChapter.isNotEmpty){
        updateKV['lastChapter'] = infoBean.lastChapter;
      }
      if(infoBean.wordCount != null && infoBean.wordCount.isNotEmpty){
        updateKV['wordCount'] = infoBean.wordCount;
      }
      if(bookBean['coverUrl'] == null || bookBean['coverUrl'].isEmpty){
        updateKV['coverUrl'] = infoBean.coverUrl;
      }
      if(bookBean['intro'] == null || bookBean['intro'].isEmpty){
        updateKV['intro'] = infoBean.intro;
      }

      if(updateKV.isNotEmpty){
        await txn.update(TABLE_BOOK, updateKV,where: '_id = ?',whereArgs: [id]);
      }
      //2关联表插数据
      var bookCombCheck = await txn.query(TABLE_BOOK_COMB_SOURCE,where: 'bookid = ? and sourceid = ?',whereArgs: [id,infoBean.source_id]);

      if(bookCombCheck.isEmpty){
        await txn.insert(TABLE_BOOK_COMB_SOURCE, {
          'bookid':id,
          'sourceid ':infoBean.source_id,
          'bookurl':infoBean.bookUrl,
          'used':0,
        });
      }
      return Future.value(id);
    }));
  }

  ///id获取书籍信息
  dynamic queryBookById(int bookId) async{
    var map = await withDB().then((db) => db.query(TABLE_BOOK,where: '_id = $bookId'));
    return Future.value(BookInfoBean.fromMap(map[0]));
  }

  ///书籍信息，完整关联
  ///[sourceId] <=0 表示使用当前指定的书源,没有的话默认一个
  dynamic queryBookInfoFromBookIdCombSourceId(int bookId,int sourceId) async{
    var db = await withDB();
    return await db.transaction((txn) async{
      var bookInfoQuery = await txn.query(TABLE_BOOK,where: '_id = $bookId');
      var bookInfo = BookInfoBean.fromMap(bookInfoQuery[0]);
      var usedSourceId = sourceId;
      if(usedSourceId <= 0){//未指定书源，先查出所有能用的书源
        var bookComb = await txn.query(TABLE_BOOK_COMB_SOURCE,where: 'bookid = $bookId');
        for (var value in bookComb) {
          if(value['used'] == 1){
            bookInfo.bookUrl = value['bookurl'];
            usedSourceId = value['sourceid'];
            break;
          }
        }
        //没有指定默认书源
        if(bookInfo.bookUrl == null){
          var comb = bookComb[0];
          usedSourceId = comb['sourceid'];
          var combId = comb['_id'];
          await txn.update(TABLE_BOOK_COMB_SOURCE, {'used':1},where: '_id = ?',whereArgs: [combId]);
          bookInfo.bookUrl = comb['bookurl'];
        }
      }//check sources
      var sourceList = await txn.query(TABLE_SOURCE,where: '_id = $usedSourceId').then((list) => list.map((e) => BookSourceBean.fromJson(e)).toList());
      bookInfo.source_id = usedSourceId;
      bookInfo.sourceBean = sourceList[0];
      return Future.value(bookInfo);
    });
  }

  dynamic updateToc(List<BookChapterBean> chapterList) async{
    return await withDB().then((db) => db.transaction((txn) async{
      for (var chapter in chapterList) {
        await txn.rawInsert('''
        INSERT OR REPLACE INTO $TABLE_CHAPTER(
        name,url,bookId,sourceId
        )
        VALUES(?,?,?,?)
        ''',[chapter.name,chapter.url,chapter.bookId,chapter.sourceId]);
      }
    }));
  }

}
