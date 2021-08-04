
class BookChapterBean{
  int id=0;
  String? name;
  String? url;
  String? content;
  int hasRead=0;

  int bookId=0;
  int sourceId=0;

  int length=0;

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