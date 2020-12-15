import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:yuedu_hd/db/BookShelfBean.dart';
import 'package:yuedu_hd/ui/reading/DisplayConfig.dart';

import 'BookInfoBean.dart';
import 'BookSourceBean.dart';
import 'BookSourceCombBean.dart';
import 'bookChapterBean.dart';

class DatabaseHelper {
  static const DB_PATH = "yuedu.db";
  static const TABLE_SOURCE = 'book_sources';
  static const TABLE_BOOK = 'book';
  static const TABLE_BOOK_COMB_SOURCE = 'book_comb_source';
  static const TABLE_CHAPTER = 'book_chapter';
  static const TABLE_CONFIG = 'display_config';


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
  "lastReadChapter" TEXT,
  "lastReadPage" INTEGER NOT NULL DEFAULT 1
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

  static const _SQL_CREATE_CONFIG='''
  CREATE TABLE "display_config" (
    "_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "isSinglePage" integer NOT NULL DEFAULT 0,
    "isVertical" integer NOT NULL DEFAULT 0,
    "marginLeft" REAL NOT NULL DEFAULT 20,
    "marginTop" REAL NOT NULL DEFAULT 20,
    "marginRight" REAL NOT NULL DEFAULT 20,
    "marginBottom" REAL NOT NULL DEFAULT 20,
    "backgroundColor" integer NOT NULL,
    "inSizeMargin" REAL NOT NULL,
    "textSize" REAL NOT NULL,
    "textColor" integer NOT NULL,
    "titleSize" REAL NOT NULL,
    "titleColor" integer NOT NULL,
    "titleMargin" REAL NOT NULL,
    "spaceParagraph" integer NOT NULL DEFAULT 4,
    "lineSpace" REAL NOT NULL,
    "isTitleBold" integer NOT NULL DEFAULT 1,
    "isTextBold" integer NOT NULL DEFAULT 0
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
      //配置项
      await _executeMultiSQL(db, _SQL_CREATE_CONFIG);
      await db.insert(TABLE_CONFIG, DisplayConfig.getDefault().toMap());
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
  Future<int> insertOrUpdateBookSource(BookSourceBean input,Transaction txn) async {
    //被迫采用这种方式
    var update = await txn.rawInsert('''
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

    txn.update(
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
  Future<BookInfoBean> queryBookById(int bookId) async{
    var map = await withDB().then((db) => db.query(TABLE_BOOK,where: '_id = $bookId'));
    return Future.value(BookInfoBean.fromMap(map[0]));
  }

  ///id移除书架
  Future<void> removeBookshelfById(int bookId) async{
    await withDB().then((db) => db.update(TABLE_BOOK,{'inbookShelf':0},where: '_id = $bookId'));
    return Future.value();
  }

  ///查询在书架的书籍[sortType]/0添加顺序，1上次阅读时间
  Future<List<BookShelfBean>> queryBookInBookShelf(int sortType) async{
    return await withDB().then((db) => db.transaction((txn) async{
      var bookList = await txn.rawQuery('''
      SELECT
      	book.name,
      	book.author,
      	book.coverUrl,
      	book.lastChapter,
      	book.lastReadChapter,
      	book.updatetime,
      	book_comb_source.bookid,
      	book_comb_source.sourceid
      FROM
      	"book"
      	JOIN book_comb_source ON book._id = book_comb_source.bookid 
      WHERE
      	book.inbookShelf = 1 
      	AND book_comb_source.used = 1
      
      ${sortType == 1?"ORDER BY updatetime DESC":"ORDER BY book._id"}
      ''').then((value) => value.map((e) => BookShelfBean.fromMap(e)).toList());
      //章节信息补充
      for (var book in bookList) {
        var count = await txn.rawQuery('''
        SELECT COUNT(*) AS chaptersCount FROM "book_chapter" WHERE book_chapter.bookId = ${book.bookId} AND book_chapter.sourceId = ${book.sourceId}
        ''');
        book.chaptersCount = count[0]['chaptersCount'];
        var notReadCount = await txn.rawQuery('''
        SELECT COUNT(*) AS notReadChapterCount FROM "book_chapter" WHERE book_chapter.bookId = ${book.bookId} AND book_chapter.sourceId = ${book.sourceId} AND _id > (SELECT _id FROM book_chapter WHERE book_chapter.name LIKE '%${book.lastReadChapter??''}%' LIMIT 1)
        ''');
        book.notReadChapterCount = notReadCount[0]['notReadChapterCount'];
      }
      return Future.value(bookList);
    })
    );

  }

  ///更新阅读时间
  dynamic updateBookReadTime(int bookId){
    withDB().then((db)=>db.update(TABLE_BOOK, {'updatetime':DateTime.now().millisecondsSinceEpoch,},where: '_id = $bookId'));
  }


  ///书籍信息，完整关联
  ///[sourceId] <=0 表示使用当前指定的书源,没有的话默认一个
  dynamic queryBookInfoFromBookIdCombSourceId(int bookId,int sourceId) async{
    var db = await withDB();
    return await db.transaction((txn) async{
      var bookInfoQuery = await txn.query(TABLE_BOOK,where: '_id = $bookId');
      var bookInfo = BookInfoBean.fromMap(bookInfoQuery[0]);
      var usedSourceId = sourceId;
      var bookComb = await txn.query(TABLE_BOOK_COMB_SOURCE,where: 'bookid = $bookId');
      if(usedSourceId <= 0){//未指定书源，先查出所有能用的书源
        for (var value in bookComb) {
          if(value['used'] == 1){
            bookInfo.bookUrl = value['bookurl'];
            usedSourceId = value['sourceid'];
            break;
          }
        }
        //没有指定默认书源,先把第一个指定成默认书源
        if(bookInfo.bookUrl == null){
          var comb = bookComb[0];
          usedSourceId = comb['sourceid'];
          var combId = comb['_id'];
          await txn.update(TABLE_BOOK_COMB_SOURCE, {'used':1},where: '_id = ?',whereArgs: [combId]);
          bookInfo.bookUrl = comb['bookurl'];
        }
      }//check sources
      else{//指定了书源
        var query = await txn.query(TABLE_BOOK_COMB_SOURCE,where: 'sourceid = $usedSourceId and bookid = $bookId');
        bookInfo.bookUrl = query[0]['bookurl'];
      }

      var sourceList = await txn.query(TABLE_SOURCE,where: '_id = $usedSourceId').then((list) => list.map((e) => BookSourceBean.fromJson(e)).toList());
      bookInfo.source_id = usedSourceId;
      bookInfo.sourceBean = sourceList[0];
      return Future.value(bookInfo);
    });
  }


  ///更新章节目录
  dynamic updateToc(List<BookChapterBean> chapterList) async{
    return await withDB().then((db) => db.transaction((txn) async{
      for (var chapter in chapterList) {
        await txn.execute('''
        INSERT OR IGNORE INTO $TABLE_CHAPTER(
        name,url,bookId,sourceId
        )
        VALUES('${chapter.name}','${chapter.url}',${chapter.bookId},${chapter.sourceId})
        ''');
      }
      //更新书籍最新章节
      if(chapterList.isNotEmpty){
        var c = chapterList.last;
        await txn.update(TABLE_BOOK, {'lastChapter':c.name},where: '_id = ${c.bookId}');
      }
    }));
  }

  ///查询书籍关联可用的所有书源
  dynamic queryAllEnabledSource(int bookId) async{
    var queryResult = await withDB().then((db){
      return db.rawQuery('''
      SELECT
      	book_comb_source.*,
      	book_sources.bookSourceName,
      	book_sources.bookSourceUrl,
      	book_sources.enabled,
      	book_sources.header,
      	book_sources.searchUrl,
      	book_sources.ruleToc 
      FROM
      	"book_comb_source"
      	JOIN book_sources ON book_comb_source.sourceid = book_sources._id 
      WHERE
      	book_comb_source.bookid = $bookId
      	AND book_sources.enabled = 1
      ''');
    } );
    var result = List<BookSourceCombBean>();
    for (var data in queryResult) {
      var info = BookSourceCombBean.fromMap(data);
      info.sourceBean = BookSourceBean.fromJson(data);//id会出错,不能使用里面的id
      result.add(info);
    }
    return Future.value(result);
  }

  ///切换书源
  dynamic switchUsedSource(int bookId,int sourceId) async{
    return await withDB().then((db) => db.transaction((txn) async{
      await txn.update(TABLE_BOOK_COMB_SOURCE, {'used':0},where: 'bookid = $bookId');
      await txn.update(TABLE_BOOK_COMB_SOURCE, {'used':1},where: 'bookid = $bookId and sourceid = $sourceId');
    }));
  }

  ///查询所有章节目录
  Future<List<BookChapterBean>> queryBookChapters(int bookId) async{
    return await withDB().then((db) => db.transaction((txn) async{
      var usedSource = await txn.query(TABLE_BOOK_COMB_SOURCE,where: 'bookid = $bookId and used = 1');
      var usedSourceId = usedSource[0]['sourceid'];
      var query = await txn.query(TABLE_CHAPTER,columns: [
        '_id',
        'name',
        'url',
        'hasRead',
        'LENGTH(content) as length',
      ],where: 'bookId = $bookId and sourceId = $usedSourceId');
      var beanList = query.map((e) => BookChapterBean.fromJson(e)).toList();
      return Future.value(beanList);
    }));
  }

  dynamic addToBookShelf(int bookId) async{
    return await withDB().then((db) => db.update(TABLE_BOOK, {'inbookShelf':1},where: '_id = $bookId'));
  }

  ///查询章节内容
  Future<String> queryChapterContent(int chapterId) async{
    return await withDB().then((db) => db.query(TABLE_CHAPTER,columns: ['content'],where: '_id = $chapterId')).then((value){
      if(value.isEmpty){
        return null;
      }
      return value[0]['content'];
    });
  }

  ///查询章节解析用的书源
  Future<BookSourceBean> queryBookSourceByChapterId(int chapterId) async{
    return await withDB().then((db) => db.rawQuery('''
    SELECT
    	* 
    FROM
    	book_sources 
    WHERE
    	_id = ( SELECT sourceid FROM book_chapter WHERE book_chapter._id = $chapterId )
    ''')).then((value) => BookSourceBean.fromJson(value[0]));
  }


  ///查询章节的地址
  Future<String> queryChapterUrl(int chapterId) async{
    return withDB().then((db) => db.query(TABLE_CHAPTER,columns: ['url'],where: '_id = $chapterId'))
        .then((value) => value[0]['url']);
  }

  ///更新章节内容
  dynamic updateChapterContent(int chapterId,String content) async{
    return withDB().then((db) => db.update(TABLE_CHAPTER, {'content':content},where: '_id = $chapterId'));
  }

  ///更新阅读的章节
  dynamic updateLastReadChapter(int bookId,String chapterName,int lastReadPage){
    return withDB().then((db) => db.update(TABLE_BOOK, {'lastReadChapter':chapterName,'lastReadPage':lastReadPage},where: '_id = $bookId'));
  }

  ///保存配置项
  dynamic saveConfig(DisplayConfig config) async{
    return withDB().then((db) => db.update(TABLE_CONFIG
        , config.toMap(),where: '_id = 1'));
  }

  ///加载配置
  Future<DisplayConfig> loadConfig() async{
    return withDB().then((db) => db.query(TABLE_CONFIG)).then((value) => DisplayConfig.fromMap(value[0]));
  }

}
