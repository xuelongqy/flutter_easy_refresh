import 'package:flutter/widgets.dart';

/// Header状态枚举
enum HeaderStatus { idle, start, ready, refreshing, completed, noMore, failed }

/// Header构造器
typedef HeaderBuilder = Widget Function(
    BuildContext context, HeaderState state);

/// Header属性
class HeaderState {
  // 状态
  HeaderStatus status = HeaderStatus.idle;
  // 高度
  double height = 0.0;
  // 是否浮动
  bool float = false;
  // 组件
  Widget widget;
}

/// Header
abstract class Header {
  // 高度(超过这个高度出发刷新)
  final double triggerHeight;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Header({
    this.triggerHeight = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context, HeaderState state);
}

/// 通用Header构造器
class CustomHeader extends Header {

  // Header构造函数
  final HeaderBuilder headerBuilder;

  CustomHeader({
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    this.headerBuilder
  }): super(
    triggerHeight: triggerHeight,
    float: float,
    completeDuration: completeDuration
  ){
    assert(this.headerBuilder != null);
  }

  @override
  Widget builder(BuildContext context, HeaderState state) {
    return this.headerBuilder(context, state);
  }
}