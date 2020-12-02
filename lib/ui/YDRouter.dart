
import 'package:flutter/material.dart';

class YDRouter{
  static const String READING_PAGE = 'reading';//{'bookId':bean.bookId,'chapterId':-1}

  static const String BOOKSHELF = "bookshelf";
  static const String EXPLORE = "explore";
  static const String SETTINGS = "settings";


  static const String BOOK_SOURCE_LIST = "source_list";
  static const String BOOK_SOURCE_ADD = "source_add";

  static const String BOOK_ADD = "book_add";

  static var mainRouter = GlobalKey<NavigatorState>();
}