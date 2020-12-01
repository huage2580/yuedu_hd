
class BookChapterBean{
  int id;
  String name;
  String url;
  String content;
  int hasRead;

  int bookId;
  int sourceId;

  int length;

  @override
  String toString() {
    return 'BookChapterBean{id: $id, name: $name, url: $url, content: $content}';
  }


  BookChapterBean();

  BookChapterBean.fromJson(Map map){
    id = map['_id'];
    name = map['name'];
    url = map['url'];
    content = map['content'];
    hasRead = map['hasRead'];
    length = map['length'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookChapterBean &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}