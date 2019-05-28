import 'package:flutter/widgets.dart';

/// Header状态枚举
enum HeaderStatus { idle, start, ready, refreshing, completed, noMore, failed }

/// Header属性
class HeaderState {
  // 状态
  HeaderStatus status = HeaderStatus.idle;
  // 高度
  double height = 0.0;

  HeaderState({this.status, this.height});
}

/// Header
abstract class Header {
  // 高度(超过这个高度出发刷新)
  final double height;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Header({
    this.height = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context);
}