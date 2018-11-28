import 'package:flutter/widgets.dart';

/// 下拉刷新顶部视图抽象类
/// 自定义视图需要实现此类中的方法

typedef Future OnRefreshing();
typedef Future OnRefreshed();
typedef Future OnHeaderHide();

abstract class RefreshHeader extends StatefulWidget {
  // 高度
  final double height;
  // 开始刷新回调方法
  final OnRefreshing onRefreshing;
  // 完成刷新回调方法
  final OnRefreshed onRefreshed;
  // 顶部视图隐藏回调方法
  final OnHeaderHide onHeaderHide;

  const RefreshHeader({
    Key key,
    @required this.height,
    this.onRefreshing,
    this.onRefreshed,
    this.onHeaderHide
  }) : super(key: key);

  // 回调开始刷新方法
  void callOnRefreshing() async {
    if (onRefreshing != null) {
      await onRefreshing();
    }
  }

  // 回调刷新完成方法
  void callOnRefreshed() async {
    if (onRefreshed != null) {
      await onRefreshed();
    }
  }

  // 回调顶部隐藏方法方法
  void callOnHeaderHide() async {
    if (onHeaderHide != null) {
      await onHeaderHide();
    }
  }
}