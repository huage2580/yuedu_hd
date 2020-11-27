
class BookChapterBean{
  int id;
  String name;
  String url;
  String content;
  int hasRead;

  int bookId;
  int sourceId;

  @override
  String toString() {
    return 'BookChapterBean{id: $id, name: $name, url: $url, content: $content}';
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