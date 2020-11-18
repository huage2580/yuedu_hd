
class BookSourceBean{

  BookSourceBean();

  int id;
  String bookSourceName;
  String bookSourceGroup;
  String bookSourceUrl;
  String bookUrlPattern;
  int bookSourceType;
  bool enabled;
  bool enabledExplore;
  String header;
  String loginUrl;
  String bookSourceComment;
  num lastUpdateTime;
  int weight;
  String exploreUrl;
  String ruleExplore;//json
  String searchUrl;
  String ruleSearch;//json
  String ruleBookInfo;//json
  String ruleToc;//json
  String ruleContent;//json

  @override
  String toString() {
    return 'BookSourceBean{_id: $id, bookSourceName: $bookSourceName, bookSourceGroup: $bookSourceGroup, bookSourceUrl: $bookSourceUrl, bookUrlPattern: $bookUrlPattern, bookSourceType: $bookSourceType, enabled: $enabled, enabledExplore: $enabledExplore, header: $header, loginUrl: $loginUrl, bookSourceComment: $bookSourceComment, lastUpdateTime: $lastUpdateTime, weight: $weight, exploreUrl: $exploreUrl, ruleExplore: $ruleExplore, searchUrl: $searchUrl, ruleSearch: $ruleSearch, ruleBookInfo: $ruleBookInfo, ruleToc: $ruleToc, ruleContent: $ruleContent}';
  } //json



}