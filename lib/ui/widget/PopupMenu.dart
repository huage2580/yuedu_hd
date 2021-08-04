
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
typedef PopupMenuStateChanged = Function(bool isShow);


class PopupMenu {
  final double contentWidth;
  final double contentHeight;
  OverlayEntry? _entry;
  Widget? child;

  static var arrowHeight = 10.0;

  /// The left top point of this menu.
  Offset? _offset;

  /// Menu will show at above or under this rect
  Rect? _showRect;

  /// if false menu is show above of the widget, otherwise menu is show under the widget
  bool _isDown = true;

  /// callback
  VoidCallback? dismissCallback;
  PopupMenuStateChanged? stateChanged;

  Size? _screenSize; // 屏幕的尺寸

  /// Cannot be null
  static late BuildContext context;

  /// style
  Color? _backgroundColor;

  /// It's showing or not.
  bool _isShow = false;
  bool get isShow => _isShow;

  //if it's not full screen, set offset:
  double offsetX=0;

  PopupMenu(
      {double? offsetX,
        required this.contentWidth,
        required this.contentHeight,
        required BuildContext context,
        VoidCallback? onDismiss,
        Color? backgroundColor,
        Color? highlightColor,
        Color? lineColor,
        PopupMenuStateChanged? stateChanged,
        Widget? child}) {
    this.offsetX = offsetX ?? 0;
    this.dismissCallback = onDismiss;
    this.stateChanged = stateChanged;
    this.child = child;
    this._backgroundColor = backgroundColor ?? Color(0xff232323);
    if (context != null) {
      PopupMenu.context = context;
    }
  }

  void show({Rect? rect, GlobalKey? widgetKey, Widget? child}) {
    if (rect == null && widgetKey == null) {
      print("'rect' and 'key' can't be both null");
      return;
    }

    this.child = child ?? this.child;

    this._showRect = rect ?? PopupMenu.getWidgetGlobalRect(widgetKey!, offsetX);
    this._screenSize = window.physicalSize / window.devicePixelRatio;
    this.dismissCallback = dismissCallback;

    _calculatePosition(PopupMenu.context);

    _entry = OverlayEntry(builder: (context) {
      return buildPopupMenuLayout(_offset!);
    });

    Overlay.of(PopupMenu.context)?.insert(_entry!);
    _isShow = true;
    if (this.stateChanged != null) {
      this.stateChanged!(true);
    }
  }

  static Rect getWidgetGlobalRect(GlobalKey key, double offsetX) {
    RenderBox renderBox = (key.currentContext!.findRenderObject() as RenderBox);
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(offset.dx - offsetX, offset.dy, renderBox.size.width,
        renderBox.size.height);
  }

  void _calculatePosition(BuildContext context) {
//    _col = _calculateColCount();
//    _row = _calculateRowCount();
    _offset = _calculateOffset(PopupMenu.context);
  }

  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect!.left + _showRect!.width / 2.0 - menuWidth() / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + menuWidth() > _screenSize!.width && dx > 10.0) {
      double tempDx = _screenSize!.width - menuWidth() - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect!.top - menuHeight();
    if (dy <= MediaQuery.of(context).padding.top + 10) {
      // The have not enough space above, show menu under the widget.
      dy = arrowHeight + _showRect!.height + _showRect!.top;
      _isDown = false;
    } else {
      dy -= arrowHeight;
      _isDown = true;
    }

    return Offset(dx, dy);
  }

  double menuWidth() {
    return contentWidth;
  }

  // This height exclude the arrow
  double menuHeight() {
    return contentHeight;
  }

  LayoutBuilder buildPopupMenuLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          dismiss();
        },
//        onTapDown: (TapDownDetails details) {
//          dismiss();
//        },
        // onPanStart: (DragStartDetails details) {
        //   dismiss();
        // },
        // onVerticalDragStart: (DragStartDetails details) {
        //   dismiss();
        // },
        // onHorizontalDragStart: (DragStartDetails details) {
        //   dismiss();
        // },
        child: Container(
          child: Stack(
            children: <Widget>[
              // menu content
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Material(
                  elevation: 10,
                  shadowColor: Colors.black45,
                  child: Container(
                    width: menuWidth(),
                    height: menuHeight(),
                    child: Column(
                      children: <Widget>[
                        ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Container(
                              width: menuWidth(),
                              height: menuHeight(),
                              decoration: BoxDecoration(
                                  color: _backgroundColor,
                                  borderRadius: BorderRadius.circular(4.0)),
                              child: child,
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  double get screenWidth {
    double width = window.physicalSize.width;
    double ratio = window.devicePixelRatio;
    return width / ratio;
  }

  void dismiss() {
    if (!_isShow) {
      // Remove method should only be called once
      print("dont dismiss...");
      return;
    }

    print("dismiss...");

    _entry?.remove();
    _isShow = false;
    if (dismissCallback != null) {
      dismissCallback!();
    }

    if (this.stateChanged != null) {
      this.stateChanged!(false);
    }
  }
}
