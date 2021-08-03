import 'dart:math';

import 'package:flutter/material.dart';

/// 指示器状态
enum IndicatorMode {
  /// 默认状态，不具备任何触发条件
  /// 此时[Header]或者[Footer]不显示
  /// 刷新完成后回归此状态
  inactive,

  /// 超出列表但未达到触发任务距离
  /// 此状态松开，列表复原
  drag,

  /// 超出列表并达到触发任务距离
  /// 此状态松开，列表触发任务
  armed,

  /// 超出列表并达到触发任务距离
  /// 此状态表示用户已经松开
  ready,

  /// 任务执行中
  /// 进行中，直到完成任务
  processing,

  /// 任务完成
  /// 任务结束，但整个过程并未完成
  /// 设置结束的动画，将在此状态后进行
  processed,

  /// 整个刷新过程完成
  /// 结束后，回到[inactive]
  done,
}

/// 指示通知器
abstract class IndicatorNotifier extends ChangeNotifier {
  /// 触发偏移量
  final double triggerOffset;

  /// 用户触发通知器
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// 定住让列表不越界
  final bool clamping;

  /// 方向
  Axis? axis;
  AxisDirection? axisDirection;

  /// 偏移量
  double offset = 0;

  /// 位置
  late ScrollMetrics position;

  /// 状态
  IndicatorMode mode = IndicatorMode.inactive;

  /// 列表越界范围
  double get overExtent {
    if (this.mode == IndicatorMode.ready ||
        this.mode == IndicatorMode.processing ||
        this.mode == IndicatorMode.processed) {
      return triggerOffset;
    }
    return 0;
  }

  /// 指示器范围
  double get extent {
    return offset;
  }

  IndicatorNotifier({
    required this.triggerOffset,
    required this.clamping,
    required this.userOffsetNotifier,
  });

  /// 计算偏移量
  double calculateOffset(ScrollMetrics position, double value);

  /// 模拟器更新
  void updateBySimulation(ScrollMetrics position) {
    this.position = position;
    // 更新方向
    if (this.axis != position.axis && axisDirection != position.axisDirection) {
      axis = position.axis;
      axisDirection = position.axisDirection;
    }
    this.updateOffset(position, position.pixels, true);
  }

  /// 更新偏移量
  void updateOffset(ScrollMetrics position, double value, bool bySimulation) {
    this.position = position;
    // 记录旧状态
    final oldOffset = this.offset;
    final oldMode = this.mode;
    // 更新偏移量
    this.offset = calculateOffset(position, value);
    // 如果没有越界则不操作
    if (oldOffset == 0 && this.offset == 0) {
      return;
    }
    // 更新状态(任务执行中和任务完成中不更新)
    if (this.mode != IndicatorMode.processing &&
        this.mode != IndicatorMode.processed) {
      if (this.offset == 0) {
        this.mode = IndicatorMode.inactive;
      } else if (this.offset < this.triggerOffset) {
        this.mode = IndicatorMode.drag;
      } else if (this.offset == this.triggerOffset) {
        // 必须超过才能触发任务
        this.mode = this.mode != IndicatorMode.ready
            ? IndicatorMode.armed
            : IndicatorMode.processing;
      } else if (this.offset > this.triggerOffset) {
        // 如果是用户在滑动(未释放则不执行任务)
        this.mode = userOffsetNotifier.value
            ? IndicatorMode.armed
            : IndicatorMode.ready;
      }
    }
    // 是否需要通知
    if (oldOffset == this.offset && oldMode == this.mode) {
      return;
    }
    // 避免绘制过程中setState()
    if (bySimulation) {
      return;
    }
    notifyListeners();
  }

  /// 更新状态
  void updateMode(IndicatorMode mode) {
    if (this.mode == mode) {
      return;
    }
    final oldMode = this.mode;
    this.mode = mode;
    notifyListeners();
    if (oldMode == IndicatorMode.processing &&
        position is ScrollActivityDelegate) {
      (position as ScrollActivityDelegate).goBallistic(0);
    }
  }
}

/// Header通知器
class HeaderNotifier extends IndicatorNotifier {
  HeaderNotifier({
    required double triggerOffset,
    required bool clamping,
    required ValueNotifier<bool> userOffsetNotifier,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          userOffsetNotifier: userOffsetNotifier,
        );

  @override
  double calculateOffset(ScrollMetrics position, double value) {
    if (value >= position.minScrollExtent && offset != 0) {
      return 0;
    }
    print(value);
    return value >= position.minScrollExtent
        ? 0
        : value.abs() + (this.clamping ? this.offset : 0);
  }
}

/// Footer通知器
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier({
    required double triggerOffset,
    required bool clamping,
    required ValueNotifier<bool> userOffsetNotifier,
  }) : super(
          triggerOffset: triggerOffset,
          clamping: clamping,
          userOffsetNotifier: userOffsetNotifier,
        );

  @override
  double calculateOffset(ScrollMetrics position, double value) {
    if (value <= position.maxScrollExtent && offset != 0) {
      return 0;
    }
    return value <= position.maxScrollExtent
        ? 0
        : value - position.maxScrollExtent + (this.clamping ? this.offset : 0);
  }
}
