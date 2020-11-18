

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yuedu_hd/db/book_source_helper.dart';

void main(){
  test('book source parser Test', ()async{
    var  helper= BookSourceHelper.getInstance();
    expect(helper == BookSourceHelper.getInstance(),true);
    var data = r'''
    [
  {
    "bookSourceComment": "",
    "bookSourceGroup": "🎉 精品",
    "bookSourceName": "🎉 大熊猫",
    "bookSourceType": 0,
    "bookSourceUrl": "https://www.dxmwx.net",
    "bookUrlPattern": "",
    "customOrder": -2066,
    "enabled": true,
    "enabledExplore": true,
    "exploreUrl": "玄幻::/dxmlist/%E7%8E%84%E5%B9%BB_{{page}}.html\n奇幻::/dxmlist/%E5%A5%87%E5%B9%BB_{{page}}.html\n武侠::/dxmlist/%E6%AD%A6%E4%BE%A0_{{page}}.html\n仙侠::/dxmlist/%E4%BB%99%E4%BE%A0_{{page}}.html\n都市::/dxmlist/%E9%83%BD%E5%B8%82_{{page}}.html\n言情::/dxmlist/%E8%A8%80%E6%83%85_{{page}}.html\n历史::/dxmlist/%E5%8E%86%E5%8F%B2_{{page}}.html\n军事::/dxmlist/%E5%86%9B%E4%BA%8B_{{page}}.html\n游戏::/dxmlist/%E6%B8%B8%E6%88%8F_{{page}}.html\n竞技::/dxmlist/%E7%AB%9E%E6%8A%80_{{page}}.html\n科幻::/dxmlist/%E7%A7%91%E5%B9%BB_{{page}}.html\n灵异::/dxmlist/%E7%81%B5%E5%BC%82_{{page}}.html\n悬疑::/dxmlist/%E6%82%AC%E7%96%91_{{page}}.html\n现实::/dxmlist/%E7%8E%B0%E5%AE%9E_{{page}}.html\n次元::/dxmlist/%E4%BA%8C%E6%AC%A1%E5%85%83_{{page}}.html",
    "lastUpdateTime": 1605181787435,
    "loginUrl": "",
    "ruleBookInfo": {
      "author": "[property=\"og:novel:author\"]@content",
      "coverUrl": "[property=\"og:image\"]content",
      "intro": "[property=\"og:description\"]@content",
      "kind": "[property=\"og:novel:category\"]@content&&[property=\"og:novel:status\"]@content&&[property=\"og:novel:update_time\"]@content",
      "lastChapter": "[property=\"og:novel:latest_chapter_name\"]@content",
      "name": "[property=\"og:novel:book_name\"]@content",
      "tocUrl": "class.White@tag.a.0@href",
      "wordCount": ""
    },
    "ruleContent": {
      "content": "class.book-article@html",
      "imageStyle": "0",
      "replaceRegex": "##.*大家读书院|小提示：在搜索.*|第.*章.*"
    },
    "ruleExplore": {},
    "ruleSearch": {
      "author": "tag.a.1@text",
      "bookList": "class.shu_one",
      "bookUrl": "tag.a@href",
      "coverUrl": "tag.img@src",
      "intro": "class.book_info@textNodes",
      "kind": "tag.a.2@text&&tag.a.3@text",
      "lastChapter": "tag.a.4@text##最新章节",
      "name": "class.book_h@text##\\s.*",
      "wordCount": "tag.span.2@text"
    },
    "ruleToc": {
      "chapterList": "class.chapterlist@tag.td",
      "chapterName": "tag.a@text",
      "chapterUrl": "tag.a@href"
    },
    "searchUrl": "https://www.dxmwx.net/dxmlist/{{key}}.html",
    "weight": 0
  },
  {
    "bookSourceComment": "",
    "bookSourceGroup": "🎉 精品",
    "bookSourceName": "🎉 斋书苑",
    "bookSourceType": 0,
    "bookSourceUrl": "https://www.zhaishuyuan.com",
    "bookUrlPattern": "",
    "customOrder": -2065,
    "enabled": true,
    "enabledExplore": true,
    "exploreUrl": "【玄幻奇幻】::/shuku/1_3_0_0_0_{{page}}_0_1\n东方玄幻::/shuku/1_3_0_1_0_{{page}}_0_1\n异世大陆::/shuku/1_3_0_2_0_{{page}}_0_1\n史诗奇幻::/shuku/1_3_0_3_0_{{page}}_0_1\n高武世界::/shuku/1_3_0_4_0_{{page}}_0_1\n剑与魔法::/shuku/1_3_0_5_0_{{page}}_0_1\n【武侠仙侠】::/shuku/2_3_0_0_0_{{page}}_0_1\n古典仙侠::/shuku/2_3_0_1_0_{{page}}_0_1\n修真文明::/shuku/2_3_0_2_0_{{page}}_0_1\n现代修真::/shuku/2_3_0_3_0_{{page}}_0_1\n神话修真::/shuku/2_3_0_4_0_{{page}}_0_1\n武侠幻想::/shuku/2_3_0_5_0_{{page}}_0_1\n幻想修仙::/shuku/2_3_0_6_0_{{page}}_0_1\n【都市青春】::/shuku/3_3_0_0_0_{{page}}_0_1\n都市生活::/shuku/3_3_0_1_0_{{page}}_0_1\n官场沉浮::/shuku/3_3_0_2_0_{{page}}_0_1\n娱乐明星::/shuku/3_3_0_3_0_{{page}}_0_1\n异术超能::/shuku/3_3_0_4_0_{{page}}_0_1\n【历史军事】::/shuku/4_3_0_0_0_{{page}}_0_1\n架空历史::/shuku/4_3_0_1_0_{{page}}_0_1\n秦汉三国::/shuku/4_3_0_2_0_{{page}}_0_1\n两晋隋唐::/shuku/4_3_0_3_0_{{page}}_0_1\n两宋元明::/shuku/4_3_0_4_0_{{page}}_0_1\n清史民国::/shuku/4_3_0_5_0_{{page}}_0_1\n外国历史::/shuku/4_3_0_6_0_{{page}}_0_1\n军事战争::/shuku/4_3_0_7_0_{{page}}_0_1\n抗战烽火::/shuku/4_3_0_8_0_{{page}}_0_1\n【科幻灵异】::/shuku/5_3_0_0_0_{{page}}_0_1\n星际文明::/shuku/5_3_0_1_0_{{page}}_0_1\n超级科技::/shuku/5_3_0_2_0_{{page}}_0_1\n时空穿梭::/shuku/5_3_0_3_0_{{page}}_0_1\n进化变异::/shuku/5_3_0_4_0_{{page}}_0_1\n末世危机::/shuku/5_3_0_5_0_{{page}}_0_1\n灵异鬼怪::/shuku/5_3_0_6_0_{{page}}_0_1\n侦探推理::/shuku/5_3_0_7_0_{{page}}_0_1\n寻墓探险::/shuku/5_3_0_8_0_{{page}}_0_1\n【游戏竞技】::/shuku/6_3_0_0_0_{{page}}_0_1\n虚拟网游::/shuku/6_3_0_1_0_{{page}}_0_1\n游戏异界::/shuku/6_3_0_2_0_{{page}}_0_1\n体育竞技::/shuku/6_3_0_3_0_{{page}}_0_1\n游戏生涯::/shuku/6_3_0_4_0_{{page}}_0_1\n电子竞技::/shuku/6_3_0_5_0_{{page}}_0_1\n【女生言情】::/shuku/9_3_0_0_0_{{page}}_0_1\n豪门总裁::/shuku/9_3_0_1_0_{{page}}_0_1\n都市青春::/shuku/9_3_0_2_0_{{page}}_0_1\n星际科幻::/shuku/9_3_0_3_0_{{page}}_0_1\n灵异推理::/shuku/9_3_0_4_0_{{page}}_0_1\n婚恋情缘::/shuku/9_3_0_5_0_{{page}}_0_1\n穿越架空::/shuku/9_3_0_6_0_{{page}}_0_1\n玄幻仙侠::/shuku/9_3_0_7_0_{{page}}_0_1\n宫闱宅斗::/shuku/9_3_0_8_0_{{page}}_0_1\n【二の次元】::/shuku/20_3_0_0_0_{{page}}_0_1\n动漫同人::/shuku/20_3_0_1_0_{{page}}_0_1\n小说同人::/shuku/20_3_0_2_0_{{page}}_0_1\n影视同人::/shuku/20_3_0_3_0_{{page}}_0_1\n原生幻想::/shuku/20_3_0_4_0_{{page}}_0_1\n搞笑吐槽::/shuku/20_3_0_5_0_{{page}}_0_1\n默认::/shuku/11_3_0_0_0_{{page}}_0_1\n新添::/shuku/11_3_0_0_8_{{page}}_0_1\n点击::/shuku/11_3_0_0_5_{{page}}_0_1\n推荐::/shuku/11_3_0_0_7_{{page}}_0_1\n收藏::/shuku/11_3_0_0_3_{{page}}_0_1\n字数::/shuku/11_3_0_0_9_{{page}}_0_1",
    "header": "",
    "lastUpdateTime": 1605010148745,
    "loginUrl": "",
    "ruleBookInfo": {
      "author": "[property=\"og:novel:author\"]@content",
      "coverUrl": "[property=\"og:image\"]@content",
      "init": "",
      "intro": "[property=\"og:description\"]@content",
      "kind": "[property=\"og:novel:category\"]@content&&[property=\"og:novel:status\"]@content&&[property=\"og:novel:update_time\"]@content##\\s.*",
      "lastChapter": "[property=\"og:novel:latest_chapter_name\"]@content",
      "name": "[property=\"og:novel:book_name\"]@content",
      "tocUrl": "class.motion@tag.a.0@href",
      "wordCount": "@css:.count li:eq(3)>span@text@js:parseInt(result/10000) + '万字'"
    },
    "ruleContent": {
      "content": "<js>\na=org.jsoup.Jsoup.parse(String(result).match(/id=\"content\">([\\s\\S]*?)\\s<\\/div>/)[1]).html();\n//取屏蔽段落\nvar content=String(result.match(/function\\s*getDecode\\(\\)\\{(.*)\\}/)[1]);\n//还原屏蔽段落\ncontent=content.replace(/\\\\/g,\"/\")\n.replace(/[A-Z]=~.*?\\('/g,\"\")\n.replace(/#.*?\\('/g,\"\")\n.replace(/'\\).*/g,\"\")\n.replace(/\\+|\"/g,\"\")\n.replace(/[A-Z]\\.\\$__\\$/g,\"9\")\n.replace(/[A-Z]\\.\\$___/g,\"8\")\n.replace(/[A-Z]\\.\\$\\$\\$/g,\"7\")\n.replace(/[A-Z]\\.\\$\\$_/g,\"6\")\n.replace(/[A-Z]\\.\\$_\\$/g,\"5\")\n.replace(/[A-Z]\\.\\$__/g,\"4\")\n.replace(/[A-Z]\\._\\$\\$/g,\"3\")\n.replace(/[A-Z]\\._\\$_/g,\"2\")\n.replace(/[A-Z]\\.__\\$/g,\"1\")\n.replace(/[A-Z]\\.___/g,\"0\")\n.replace(/\\/\\/74\\/{2,3}160\\/\\/76/g,\"\\n\")\n//大写字母\n.replace(/\\/\\/132/g,\"Z\")\n.replace(/\\/\\/131/g,\"Y\")\n.replace(/\\/\\/130/g,\"X\")\n.replace(/\\/\\/127/g,\"W\")\n.replace(/\\/\\/126/g,\"V\")\n.replace(/\\/\\/125/g,\"U\")\n.replace(/\\/\\/124/g,\"T\")\n.replace(/\\/\\/123/g,\"S\")\n.replace(/\\/\\/122/g,\"R\")\n.replace(/\\/\\/121/g,\"Q\")\n.replace(/\\/\\/120/g,\"P\")\n.replace(/\\/\\/117/g,\"O\")\n.replace(/\\/\\/116/g,\"N\")\n.replace(/\\/\\/115/g,\"M\")\n.replace(/\\/\\/114/g,\"L\")\n.replace(/\\/\\/113/g,\"K\")\n.replace(/\\/\\/112/g,\"J\")\n.replace(/\\/\\/111/g,\"I\")\n.replace(/\\/\\/110/g,\"H\")\n.replace(/\\/\\/107/g,\"G\")\n.replace(/\\/\\/106/g,\"F\")\n.replace(/\\/\\/105/g,\"E\")\n.replace(/\\/\\/104/g,\"D\")\n.replace(/\\/\\/103/g,\"C\")\n.replace(/\\/\\/102/g,\"B\")\n.replace(/\\/\\/101/g,\"A\")\n.replace(/\\/\\/100/g,\"@\")\n//小写字母\n.replace(/5\\_​/g,\"a\")\n.replace(/5\\$/g,\"b\")\n.replace(/6\\_​/g,\"c\")\n.replace(/6\\$/g,\"d\")\n.replace(/7\\_​/g,\"e\")\n.replace(/7\\$/g,\"f\")\n.replace(/\\/\\/147/g,\"g\")\n.replace(/\\/\\/150/g,\"h\")\n.replace(/\\/\\/151/g,\"i\")\n.replace(/\\/\\/152/g,\"j\")\n.replace(/\\/\\/153/g,\"k\")\n.replace(/\\(\\!\\[\\]\\)\\[2\\]/g,\"l\")\n.replace(/\\/\\/155/g,\"m\")\n.replace(/\\/\\/156/g,\"n\")\n.replace(/[A-Z]\\._\\$/g,\"o\")\n.replace(/\\/\\/160/g,\"p\")\n.replace(/\\/\\/161/g,\"q\")\n.replace(/\\/\\/162/g,\"r\")\n.replace(/\\/\\/163/g,\"s\")\n.replace(/[A-Z].__/g,\"t\")\n.replace(/[A-Z]._/g,\"u\")\n.replace(/\\/\\/166/g,\"v\")\n.replace(/\\/\\/167/g,\"w\")\n.replace(/\\/\\/170/g,\"x\")\n.replace(/\\/\\/171/g,\"y\")\n.replace(/\\/\\/172/g,\"z\")\n//英文符号\n.replace(/\\/\\/72/g,\":\")\n.replace(/\\/\\/73/g,\" \")\n.replace(/\\/\\/77/g,\"?\")\n.replace(/\\/\\/\\/\\/u(.{4})/g,\"%u$1\");\n密文=unescape(content)\n//放回原位\nresult=String(a);\nresult=result.replace(/自动加载/,密文)\n//分隔符\n.replace(/防采集(，|)/g,\"\")\n.replace(/失败.*?(阅读模式！|浏览器！)/g,\"\")\n.replace(/禁止转码.*?请退出阅读模式！/g,\"\")\n.replace(/chapter_c\\(\\)\\;/g,\"\")\n</js>",
      "imageStyle": "0",
      "nextContentUrl": "",
      "sourceRegex": "",
      "webJs": ""
    },
    "ruleExplore": {
      "author": "tag.a.2@text",
      "bookList": "id.sitebox@tag.dl",
      "bookUrl": "tag.a@href",
      "coverUrl": "tag.img@_src",
      "intro": "tag.dd.2@text",
      "kind": "tag.span.2@text&&tag.span.3@text&&tag.span.0@text&&class.book_other.2@tag.a@text##\\s.*",
      "lastChapter": "tag.a.3@text##(求.*)",
      "name": "tag.a.1@text",
      "wordCount": ""
    },
    "ruleSearch": {
      "author": "tag.span.1@text",
      "bookList": "id.sitembox@tag.dl",
      "bookUrl": "tag.a.1@href",
      "coverUrl": "tag.img@_src",
      "intro": "tag.dd.2@text",
      "kind": "tag.span.2@text&&tag.span.3@text&&tag.span.5@text##\\s.*",
      "lastChapter": "tag.a.2@text##(求.*)",
      "name": "tag.a.1@text",
      "wordCount": "tag.span.4@text@js:parseInt(result/10000) + '万字'"
    },
    "ruleToc": {
      "chapterList": "+@js:\ndoc=org.jsoup.Jsoup.parse(result);\nhtml=\"\";\nif(result.match(/data-id=\"(\\d+)\"/)){\nnum=result.match(/查看隐藏章节\\((\\d+)\\)/)[1];\np=parseInt(num/900);\nfor(var j=1;j<=p+1;j++){\nbid=result.match(/data-bid=\"(\\d+)\"/)[1];\npage=j;\nurl=\"https://www.zhaishuyuan.com/api/\";\nbody=\"action=list&bid=\"+bid+\"&page=\"+page;\noption={\n\"method\":\"POST\",\n\"body\":String(body)\n}\njson=JSON.parse(java.ajax(url+\",\"+JSON.stringify(option))).data;\nfor(var i=0; i<json.length; i++){ \t\t\t\t\nhtml += '<li><a href=\"/chapter/'+bid+'/'+(json[i].id - bid)+'\" target=\"_blank\">'+json[i].cN+'</a> '+json[i].uT+'</li>';\n}\n}\ndoc.select(\"#more-chapter\").before(html).remove();}\ndoc.select(\"#readerlist li\")",
      "chapterName": "tag.a@text##（修）|【.*】",
      "chapterUrl": "tag.a@href",
      "isVip": "",
      "nextTocUrl": "",
      "updateTime": "text##.*\\s"
    },
    "searchUrl": "/search/,{\n  \"charset\": \"gbk\",\n  \"method\": \"POST\",\n  \"body\": \"key={{key}}&page={{page}}\"\n}",
    "weight": 0
  },
  {
    "bookSourceComment": "",
    "bookSourceGroup": "🎉 精品",
    "bookSourceName": "🎉 稻草人",
    "bookSourceType": 0,
    "bookSourceUrl": "https://www.daocaorenshuwu.com",
    "bookUrlPattern": "",
    "customOrder": -2064,
    "enabled": true,
    "enabledExplore": true,
    "exploreUrl": "玄幻::/xuanhuan<,{{page}}>.html\n奇幻::/qihuan<,{{page}}>.html\n武侠::/wuxia<,{{page}}>.html\n仙侠::/xianxia<,{{page}}>.html\n都市::/dushi<,{{page}}>.html\n轻改::/qing<,{{page}}>.html\n历史::/lishi<,{{page}}>.html\n军事::/junshi<,{{page}}>.html\n游戏::/youxi<,{{page}}>.html\n科幻::/kehuan<,{{page}}>.html\n灵异::/lingyi<,{{page}}>.html\n言情::/yanqing<,{{page}}>.html\n耽美::/danmei<,{{page}}>.html\n当代::/dangdai<,{{page}}>.html\n侦探::/zhentan<,{{page}}>.html\n儿童::/ertong<,{{page}}>.html\n名著::/mingzhu<,{{page}}>.html\n励志::/lizhi<,{{page}}>.html\n悬疑::/xuanyi<,{{page}}>.html\n经管::/jingguan<,{{page}}>.html\n同人::/tongren<,{{page}}>.html\n传记::/zhuanji<,{{page}}>.html\n散文::/sanwen<,{{page}}>.html\n外国::/waiguo<,{{page}}>.html\n畅销::/chuban<,{{page}}>.html\n杂志::/zazhi<,{{page}}>.html\n漫画::/manhua<,{{page}}>.html\n纪实::/jishi<,{{page}}>.html\n幽默::/youmo<,{{page}}>.html\n健康::/health<,{{page}}>.html\n诗集::/poetry<,{{page}}>.html\n学习::/xuexi<,{{page}}>.html\n心理::/xinli<,{{page}}>.html\n宗教::/foxue<,{{page}}>.html\n哲学::/zhexue<,{{page}}>.html\n旅游::/travel<,{{page}}>.html\n科普::/kepu<,{{page}}>.html\n育儿::/yuer<,{{page}}>.html\n女性::/woman<,{{page}}>.html\n文化::/culture<,{{page}}>.html\n官场::/guanchang<,{{page}}>.html\n青春::/youth<,{{page}}>.html\n网络::/net<,{{page}}>.html\n国学::/guoxue<,{{page}}>.html\n逻辑::/logic<,{{page}}>.html\n创业::/chuangye<,{{page}}>.html\n次元::/erciyuan<,{{page}}>.html\n英文::/english<,{{page}}>.html\n其他::/other<,{{page}}>.html",
    "header": "<js>\n(()=>{\n\tvar ua = \"navigator.userAgent.toLowerCase(); \t\t\treturn { \t\t\t\t'mobile': !!(ua.match(/applewebkit.*mobile.*/) || ua.match(/iemobile/) || ua.match(/windows phone/) || ua.match(/android/) || ua.match(/iphone/) || ua.match(/ipad/)), \t\t\t\t'weixin': ua.indexOf('micromessenger') > -1 \t\t\t};\";\n\tvar heders = {\"User-Agent\": ua};\n\treturn JSON.stringify(heders);\n})()\n</js>",
    "lastUpdateTime": 1604501864230,
    "loginUrl": "",
    "ruleBookInfo": {
      "author": "[property=\"og:novel:author\"]@content",
      "coverUrl": "[property=\"og:image\"]@content",
      "intro": "class.book-detail@textNodes",
      "kind": "[property=\"og:novel:category\"]@content&&[property=\"og:novel:status\"]@content&&[property=\"og:novel:update_time\"]@content##\\s.*",
      "lastChapter": "[property=\"og:novel:latest_chapter_name\"]@content",
      "name": "[property=\"og:novel:book_name\"]@content",
      "wordCount": ""
    },
    "ruleContent": {
      "content": "id.cont-text@html||class.img-body@html##src.*\\\"\n@js:result.replace(/data-original/g,\"src\")",
      "imageStyle": "FULL",
      "nextContentUrl": "class.col-md-6@tag.a.-1@href"
    },
    "ruleExplore": {
      "author": "",
      "bookList": "class.col-md-12",
      "bookUrl": "tag.a.1@href",
      "coverUrl": "tag.img@data-original",
      "intro": "class.media-info@text",
      "name": "tag.a.1@text"
    },
    "ruleSearch": {
      "author": "tag.td.1@text",
      "bookList": "tbody@tag.tr",
      "bookUrl": "tag.a.0@href",
      "coverUrl": "",
      "kind": "",
      "name": "tag.a.0@text##\\《|\\》"
    },
    "ruleToc": {
      "chapterList": "id.all-chapter@tag.a",
      "chapterName": "text",
      "chapterUrl": "href"
    },
    "searchUrl": "/plus/search.php?q={{key}}",
    "weight": 0
  }
  ]
    ''';
    var req = await Dio().get('https://gitee.com/vpq/codes/9ji1mged7v54brhspz3of71/raw?blob_name=sy.json');
    var jsonStr = req.data;
    var sources = await helper.parseSourceString(data);
    helper.updateDataBase(sources[0]);
    print(helper.getLog());
  });
}