import 'package:flutter/cupertino.dart';

/// Refresher安全区域(用于拦截其他UI组件的滑动事件)
class RefreshSafeArea extends StatelessWidget {
  final Widget child;

  // 构造函数
  RefreshSafeArea({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        return true;
      },
      child: this.child,
    );
  }
}
