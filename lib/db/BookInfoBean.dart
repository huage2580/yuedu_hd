
import 'package:yuedu_hd/db/BookSourceBean.dart';

class BookInfoBean{
  String name;
  String author;
  String bookUrl;
  String coverUrl;
  String intro;
  List<String> kind;
  String lastChapter;
  String wordCount;
  //关联的书源
  int source_id;
  BookSourceBean sourceBean;

  @override
  String toString() {
    return 'BookInfoBean{name: $name, author: $author, bookUrl: $bookUrl, coverUrl: $coverUrl, intro: $intro, kind: ${kind.fold('', (previousValue, element) => previousValue+element+',')}, lastChapter: $lastChapter, wordCount: $wordCount}';
  }
}