import 'package:flutter/widgets.dart';

/// Footer状态枚举
enum FooterStatus { idle, start, ready, loading, completed, noMore, failed }

/// Footer属性
class FooterState {
  // 状态
  FooterStatus status = FooterStatus.idle;
  // 高度
  double height = 0.0;

  FooterState({this.status, this.height});
}

/// Header
abstract class Footer {
  // 高度(超过这个高度出发刷新)
  final double height;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Footer({
    this.height = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context);
}