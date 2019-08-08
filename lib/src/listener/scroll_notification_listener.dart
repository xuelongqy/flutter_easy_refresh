import 'package:flutter/widgets.dart';

/// 滚动焦点回调
/// focus为是否存在焦点(手指按下放开状态)
typedef ScrollFocusCallback = void Function(bool focus);

/// 滚动事件监听器
class ScrollNotificationListener extends StatefulWidget {
  const ScrollNotificationListener({
    Key key,
    @required this.child,
    this.onNotification,
    this.onFocus,
  }) : super(key: key);

  final Widget child;

  // 通知回调
  final NotificationListenerCallback<ScrollNotification> onNotification;

  // 滚动焦点回调
  final ScrollFocusCallback onFocus;

  @override
  ScrollNotificationListenerState createState() {
    return ScrollNotificationListenerState();
  }
}

class ScrollNotificationListenerState
    extends State<ScrollNotificationListener> {
  // 焦点状态
  bool _focusState = false;
  set _focus(bool focus) {
    _focusState = focus;
    if (widget.onFocus != null) widget.onFocus(_focusState);
  }

  // 处理滚动通知
  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        _focus = true;
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_focusState && notification.dragDetails == null) _focus = false;
    } else if (notification is ScrollEndNotification) {
      if (_focusState) _focus = false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          _handleScrollNotification(notification);
          return widget.onNotification == null
              ? true
              : widget.onNotification(notification);
        },
        child: widget.child,
      );
}
