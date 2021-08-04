

class BookShelfBean{
  late int bookId;
  late String bookName;
  late String bookAuthor;
  late String coverUrl;
  late String lastChapter;
  late String lastReadChapter;
  late int updatetime;
  //---章节相关---
  late int sourceId;
  int chaptersCount=0;
  int notReadChapterCount=0;
  int updateChapterCount=0;


  BookShelfBean.fromMap(Map map){
    bookId = map['bookid'];
    bookName = map['name'];
    bookAuthor = map['author'];
    coverUrl = map['coverUrl'];
    lastChapter = map['lastChapter'];
    lastReadChapter = map['lastReadChapter'];
    updatetime = map['updatetime'];
    sourceId = map['sourceid'];
  }

}