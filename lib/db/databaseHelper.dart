

import 'dart:async';

import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  static const DB_PATH = "yuedu.db";
  static const TABLE_SOURCE = 'book_sources';

  static const SQL_CREATE_BOOK_SOURCES= '''
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

  static const SQL_INDEX_SOURCE = '''
  CREATE UNIQUE INDEX "sources_id_index" ON "book_sources" (
	"_id");
	CREATE UNIQUE INDEX "sources_url_index" ON "book_sources" (
	"bookSourceUrl");
  ''';

  static DatabaseHelper _instance;

  Database database;

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
    if(database!=null){
      return Future.value(database);
    }
    return await openDatabase(DB_PATH,version: 1,onCreate: (Database db, int version) async {
      await executeMultiSQL(db,SQL_CREATE_BOOK_SOURCES);
      await executeMultiSQL(db,SQL_INDEX_SOURCE);
    });
  }

  Future<int> executeMultiSQL(Database db,String sql) async{
    var list = sql.split(';');
    for(var each in list){
      if(each.trim().isNotEmpty){
        await db.execute(each);
      }
    }
    return Future.value(0);
  }




}