import 'package:flutter/widgets.dart';

/// 滚动通知拦截器(用于拦截其他UI组件的滑动事件)
class ScrollNotificationInterceptor extends StatelessWidget {
  final Widget child;

  // 构造函数
  ScrollNotificationInterceptor({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        return true;
      },
      child: this.child,
    );
  }
}
