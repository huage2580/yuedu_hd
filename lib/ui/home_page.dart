import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: themeData.backgroundColor,
      body: Row(
        children: [
          Container(
            width: 100,
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
                style: themeData.textTheme.subtitle1,
              ),
              HSpace(4),
              Text(
                "HD",
                style: TextStyle(fontSize: 8),
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
    setState(() {
      homeContainerKey.currentState.pushReplacementNamed("测试页面$currPage");
    });
  }

  MaterialApp _buildHomeContainer(BuildContext ctx) {
    return MaterialApp(
      navigatorKey: homeContainerKey,
      theme: Theme.of(ctx),
      onGenerateRoute: (RouteSettings settings){
        return MaterialPageRoute(builder: (ctx){
          return Scaffold(
            body: Center(child: Text(settings.name),),
          );
        });
      },
      home: Scaffold(
        body: Placeholder(),
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
      child: Container(
        padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
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
              size: 16,
              color: isSelected ? themeData.primaryColor : null,
            ),
            HSpace(4),
            Expanded(
                child: Text(
              text,
              style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? themeData.primaryColor : null),
            )),
          ],
        ),
      ),
    );
  }
}
