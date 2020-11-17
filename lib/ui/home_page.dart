import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/book_source/page_source_add.dart';
import 'package:yuedu_hd/ui/book_source/page_source_list.dart';
import 'package:yuedu_hd/ui/bookshelf/page_bookshelf.dart';
import 'package:yuedu_hd/ui/explore/page_explore.dart';
import 'package:yuedu_hd/ui/settings/page_settings.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  static const PAGE_BOOK = 0;
  static const PAGE_EXPLORE = 1;
  static const PAGE_SOURCE = 2;
  static const PAGE_SETTINGS = 3;

  int currPage = 0;
  var homeContainerKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: themeData.backgroundColor,
      body: Row(
        children: [
          Container(
            width: 180,
            decoration: BoxDecoration(
                color: themeData.cardColor,
                // boxShadow: <BoxShadow>[
                //   BoxShadow(
                //     color: themeData.shadowColor,
                //     offset: Offset(-1, 1),
                //     blurRadius: 8.0,
                //   ),
                // ],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: _buildMenu(context),
          ),
          Expanded(child: _buildHomeContainer(context))
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Column(
      children: [
        VSpace(16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "阅读",
                style: themeData.textTheme.headline4,
              ),
              HSpace(4),
              Text(
                "HD",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
        VSpace(40),
        _HomeMenuItem(
          Icons.book_outlined,
          "书架",
          isSelected: currPage == PAGE_BOOK,
          onTap: () {
            switchPageTo(PAGE_BOOK);
          },
        ),
        _HomeMenuItem(
          Icons.explore_outlined,
          "发现",
          isSelected: currPage == PAGE_EXPLORE,
          onTap: () {
            switchPageTo(PAGE_EXPLORE);
          },
        ),
        _HomeMenuItem(
          Icons.cloud_circle_outlined,
          "书源",
          isSelected: currPage == PAGE_SOURCE,
          onTap: () {
            switchPageTo(PAGE_SOURCE);
          },
        ),
        Spacer(),
        _HomeMenuItem(
          Icons.settings_outlined,
          "设置",
          isSelected: currPage == PAGE_SETTINGS,
          onTap: () {
            switchPageTo(PAGE_SETTINGS);
          },
        ),
        VSpace(16)
      ],
    );
  }

  void switchPageTo(int target) {
    if (currPage == target) {
      return;
    }
    currPage = target;
    switch(target){
      case PAGE_BOOK:
        setState(() {
          homeContainerKey.currentState.pushReplacementNamed(YDRouter.BOOKSHELF);
        });
        break;
      case PAGE_SOURCE:
        setState(() {
          homeContainerKey.currentState.pushReplacementNamed(YDRouter.BOOK_SOURCE_LIST);
        });
        break;
      case PAGE_EXPLORE:
        setState(() {
          homeContainerKey.currentState.pushReplacementNamed(YDRouter.EXPLORE);
        });
        break;
      case PAGE_SETTINGS:
        setState(() {
          homeContainerKey.currentState.pushReplacementNamed(YDRouter.SETTINGS);
        });
        break;


    }

  }
  ///右边的内容区域
  Widget _buildHomeContainer(BuildContext ctx) {
    return Container(
      child: MaterialApp(
        navigatorKey: homeContainerKey,
        theme: Theme.of(ctx),
        initialRoute: YDRouter.BOOKSHELF,
        routes: <String,WidgetBuilder>{
          YDRouter.BOOKSHELF:(context)=>PageBookShelf(),
          YDRouter.BOOK_SOURCE_LIST:(context)=>PageSourceList(),
          YDRouter.BOOK_SOURCE_ADD:(context)=>PageSourceAdd(),
          YDRouter.EXPLORE:(context)=>PageExplore(),
          YDRouter.SETTINGS:(context)=>PageSettings(),
        },
      ),
    );
  }
}

class _HomeMenuItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String text;
  final Function onTap;

  const _HomeMenuItem(
    this.icon,
    this.text, {
    Key key,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
        margin: EdgeInsets.only(left: 8, right: 8, top: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: themeData.primaryColorLight,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? themeData.primaryColor : null,
            ),
            HSpace(4),
            Expanded(
                child: Text(
              text,
              style: TextStyle(
                  fontSize: themeData.textTheme.headline5.fontSize,
                  color: isSelected ? themeData.primaryColor : null),
            )),
          ],
        ),
      ),
    );
  }
}
