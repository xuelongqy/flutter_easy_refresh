import 'package:flutter/material.dart';

/// 指示器状态
enum IndicatorState {
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
  @protected
  final double triggerOffset;

  /// 用户触发通知器
  @protected
  final ValueNotifier<bool> userOffsetNotifier;

  /// 偏移量
  double offset = 0;

  /// 状态
  IndicatorState state = IndicatorState.inactive;

  /// 列表越界范围
  double get overExtent {
    if ((this.state == IndicatorState.armed && !userOffsetNotifier.value) ||
        this.state == IndicatorState.processing ||
        this.state == IndicatorState.processed) {
      return triggerOffset;
    }
    return 0;
  }

  IndicatorNotifier(this.triggerOffset, this.userOffsetNotifier);

  /// 计算偏移量
  double calculateOffset(ScrollMetrics position, double value);

  /// 更新
  void update(ScrollMetrics position, double value) {
    // 如果没有越界则不操作
    double nextOffset = calculateOffset(position, value);
    if (nextOffset == 0 && this.offset == 0) {
      return;
    }
    // 更新偏移量
    this.offset = nextOffset;
    // 更新状态(任务执行中和任务完成中不更新)
    if (this.state != IndicatorState.processing &&
        this.state != IndicatorState.processed) {
      if (this.offset == 0) {
        this.state = IndicatorState.inactive;
      } else if (this.offset < 70) {
        this.state = IndicatorState.drag;
      } else if (this.offset == 70) {
        // 如果是用户在滑动(未释放则不执行任务)
        this.state = userOffsetNotifier.value
            ? IndicatorState.armed
            : IndicatorState.processing;
      } else if (this.offset > 70) {
        this.state = IndicatorState.armed;
      }
    }
    notifyListeners();
  }

  /// 更新状态
  void updateState(IndicatorState state) {
    this.state = state;
    notifyListeners();
  }
}

/// Header通知器
class HeaderNotifier extends IndicatorNotifier {
  HeaderNotifier(double triggerOffset, ValueNotifier<bool> userOffsetNotifier)
      : super(triggerOffset, userOffsetNotifier);

  @override
  double calculateOffset(ScrollMetrics position, double value) {
    if (value >= position.minScrollExtent && offset != 0) {
      return 0;
    }
    return value > position.minScrollExtent ? 0 : value.abs();
  }
}

/// Footer通知器
class FooterNotifier extends IndicatorNotifier {
  FooterNotifier(double triggerOffset, ValueNotifier<bool> userOffsetNotifier)
      : super(triggerOffset, userOffsetNotifier);

  @override
  double calculateOffset(ScrollMetrics position, double value) {
    if (value <= position.maxScrollExtent && offset != 0) {
      return 0;
    }
    return value < position.maxScrollExtent
        ? 0
        : value - position.maxScrollExtent;
  }
}
