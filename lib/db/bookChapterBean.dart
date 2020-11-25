
class BookChapterBean{
  int id;
  String name;
  String url;
  String content;

  int bookId;
  int sourceId;

  @override
  String toString() {
    return 'BookChapterBean{id: $id, name: $name, url: $url, content: $content}';
  }
}