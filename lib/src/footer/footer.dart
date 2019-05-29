import 'package:flutter/widgets.dart';

/// Footer状态枚举
enum FooterStatus { idle, start, ready, loading, completed, noMore, failed }

/// Footer构造器
typedef FooterBuilder = Widget Function(
    BuildContext context, FooterState state);

/// Footer属性
class FooterState {
  // 状态
  FooterStatus status = FooterStatus.idle;
  // 高度
  double height = 0.0;
  // 是否浮动
  bool float = false;
  // 组件
  Widget widget;
}

/// Header
abstract class Footer {
  // 高度(超过这个高度出发刷新)
  final double triggerHeight;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Footer({
    this.triggerHeight = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context, FooterState state);
}

/// 通用Footer构造器
class CustomFooter extends Footer {

  // Footer构造函数
  final FooterBuilder footerBuilder;

  CustomFooter({
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    this.footerBuilder
  }): super(
    triggerHeight: triggerHeight,
    float: float,
    completeDuration: completeDuration
  ){
    assert(this.footerBuilder != null);
  }

  @override
  Widget builder(BuildContext context, FooterState state) {
    return this.footerBuilder(context, state);
  }
}