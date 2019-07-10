import 'package:flutter/widgets.dart';

/// 滚动事件监听器
class ScrollNotificationListener extends StatefulWidget {
  const ScrollNotificationListener({
    Key key,
    @required this.child,
    this.onNotification,
  }) : super(key: key);

  final Widget child;

  final NotificationListenerCallback<ScrollNotification> onNotification;

  @override
  ScrollNotificationListenerState createState() {
    return ScrollNotificationListenerState();
  }
}
class ScrollNotificationListenerState extends State<ScrollNotificationListener> {
  @override
  Widget build(BuildContext context) => NotificationListener<ScrollNotification>(
    onNotification: (ScrollNotification notification) {
      return widget.onNotification == null
          ? true : widget.onNotification(notification);
    },
    child: widget.child,
  );
}