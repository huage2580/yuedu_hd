

class BookShelfBean{
  int bookId;
  String bookName;
  String bookAuthor;
  String coverUrl;
  String lastChapter;
  String lastReadChapter;
  int updatetime;
  //---章节相关---
  int sourceId;
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