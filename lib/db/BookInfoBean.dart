
import 'package:yuedu_hd/db/BookSourceBean.dart';

class BookInfoBean{
  int id;
  String name;
  String author;
  String bookUrl;
  String coverUrl;
  String intro;
  String kind;
  String lastChapter;
  String wordCount;
  String lastReadChapter;
  int groupId = -1;
  int inbookShelf = 0;
  int lastReadPage = 1;

  //关联的书源
  int source_id;
  BookSourceBean sourceBean;
  int sourceCount = 0;


  BookInfoBean();

  @override
  String toString() {
    return 'BookInfoBean{name: $name, author: $author, bookUrl: $bookUrl, coverUrl: $coverUrl, intro: $intro, kind: $kind, lastChapter: $lastChapter, wordCount: $wordCount}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookInfoBean &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          author == other.author;

  @override
  int get hashCode => name.hashCode ^ author.hashCode;


  Map<String,dynamic> toMap(){
    return{
      '_id':id,
      'name':name,
      'author':author,
      'bookUrl':bookUrl,
      'coverUrl':coverUrl,
      'intro':intro,
      'kind':kind,
      'lastChapter':lastChapter,
      'wordCount':wordCount
    };
  }


  BookInfoBean.fromMap(Map map){
    id = map['_id'];
    name = map['name'];
    author = map['author'];
    bookUrl = map['bookUrl'];
    coverUrl = map['coverUrl'];
    intro = map['intro'];
    kind = map['kind'];
    lastChapter = map['lastChapter'];
    wordCount = map['wordCount'];
    lastReadChapter = map['lastReadChapter'];
    groupId = map['groupId'];
    inbookShelf = map['inbookShelf'];
    lastReadPage = map['lastReadPage'];
  }

}