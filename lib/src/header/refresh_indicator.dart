// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class _EasyRefreshSliverRefresh extends SingleChildRenderObjectWidget {
  const _EasyRefreshSliverRefresh({
    Key key,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    this.enableInfiniteRefresh = false,
    this.headerFloat = false,
    this.axisDirectionNotifier,
    @required this.infiniteRefresh,
    Widget child,
  })  : assert(refreshIndicatorLayoutExtent != null),
        assert(refreshIndicatorLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  // The amount of space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  final double refreshIndicatorLayoutExtent;

  // _RenderEasyRefreshSliverRefresh will paint the child in the available
  // space either way but this instructs the _RenderEasyRefreshSliverRefresh
  // on whether to also occupy any layoutExtent space or not.
  final bool hasLayoutExtent;

  /// 是否开启无限刷新
  final bool enableInfiniteRefresh;

  /// 无限加载回调
  final VoidCallback infiniteRefresh;

  /// Header浮动
  final bool headerFloat;

  /// 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  @override
  _RenderEasyRefreshSliverRefresh createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
      enableInfiniteRefresh: enableInfiniteRefresh,
      infiniteRefresh: infiniteRefresh,
      headerFloat: headerFloat,
      axisDirectionNotifier: axisDirectionNotifier,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderEasyRefreshSliverRefresh renderObject) {
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent
      ..enableInfiniteRefresh = enableInfiniteRefresh
      ..headerFloat = headerFloat;
  }
}

// RenderSliver object that gives its child RenderBox object space to paint
// in the overscrolled gap and may or may not hold that overscrolled gap
// around the RenderBox depending on whether [layoutExtent] is set.
//
// The [layoutExtentOffsetCompensation] field keeps internal accounting to
// prevent scroll position jumps as the [layoutExtent] is set and unset.
class _RenderEasyRefreshSliverRefresh extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderEasyRefreshSliverRefresh({
    @required double refreshIndicatorExtent,
    @required bool hasLayoutExtent,
    @required bool enableInfiniteRefresh,
    @required this.infiniteRefresh,
    @required bool headerFloat,
    @required this.axisDirectionNotifier,
    RenderBox child,
  })  : assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _enableInfiniteRefresh = enableInfiniteRefresh,
        _hasLayoutExtent = hasLayoutExtent,
        _headerFloat = headerFloat {
    this.child = child;
  }

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;
  set refreshIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  /// 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  // The child box will be laid out and painted in the available space either
  // way but this determines whether to also occupy any
  // [SliverGeometry.layoutExtent] space or not.
  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;
  set hasLayoutExtent(bool value) {
    assert(value != null);
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  /// 是否开启无限刷新
  bool get enableInfiniteRefresh => _enableInfiniteRefresh;
  bool _enableInfiniteRefresh;
  set enableInfiniteRefresh(bool value) {
    assert(value != null);
    if (value == _enableInfiniteRefresh) return;
    _enableInfiniteRefresh = value;
    markNeedsLayout();
  }

  /// Header是否浮动
  bool get headerFloat => _headerFloat;
  bool _headerFloat;
  set headerFloat(bool value) {
    assert(value != null);
    if (value == _headerFloat) return;
    _headerFloat = value;
    markNeedsLayout();
  }

  /// 无限加载回调
  final VoidCallback infiniteRefresh;
  // 触发无限刷新
  bool _triggerInfiniteRefresh = false;
  // 获取子组件大小
  double get childSize =>
      constraints.axis == Axis.vertical ? child.size.height : child.size.width;

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [refreshIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  double get centerOffsetAdjustment {
    // Header浮动时去掉越界
    if (headerFloat) {
      final RenderViewportBase renderViewport = parent;
      return max(0.0, -renderViewport.offset.pixels);
    }
    return super.centerOffsetAdjustment;
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    // Header浮动时保持刷新
    if (headerFloat) {
      final RenderViewportBase renderViewport = parent;
      super.layout(
          (constraints as SliverConstraints)
              .copyWith(overlap: min(0.0, renderViewport.offset.pixels)),
          parentUsesSize: true);
    } else {
      super.layout(constraints, parentUsesSize: parentUsesSize);
    }
  }

  @override
  void performLayout() {
    // Only pulling to refresh from the top is currently supported.
    // 注释以支持reverse
    // assert(constraints.axisDirection == AxisDirection.down);
    axisDirectionNotifier.value = constraints.axisDirection;
    assert(constraints.growthDirection == GrowthDirection.forward);

    // 判断是否触发无限刷新
    if (enableInfiniteRefresh &&
        constraints.scrollOffset < _refreshIndicatorExtent &&
        constraints.userScrollDirection != ScrollDirection.idle) {
      if (!_triggerInfiniteRefresh) {
        _triggerInfiniteRefresh = true;
        infiniteRefresh();
      }
    } else {
      if (constraints.scrollOffset > _refreshIndicatorExtent) {
        if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
          _triggerInfiniteRefresh = false;
        } else {
          SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
            _triggerInfiniteRefresh = false;
          });
        }
      }
    }

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent || enableInfiniteRefresh ? 1.0 : 0.0) *
            _refreshIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    // 如果Header浮动则不用过渡
    if (!headerFloat) {
      if (layoutExtent != layoutExtentOffsetCompensation) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
        );
        layoutExtentOffsetCompensation = layoutExtent;
        // Return so we don't have to do temporary accounting and adjusting the
        // child's constraints accounting for this one transient frame using a
        // combination of existing layout extent, new layout extent change and
        // the overlap.
        return;
      }
    }
    final bool active = constraints.overlap < 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
        constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;
    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    // Header浮动时不用layoutExtent,不然会有跳动
    if (headerFloat) {
      child.layout(
        constraints.asBoxConstraints(
          maxExtent: _hasLayoutExtent
              ? overscrolledExtent > _refreshIndicatorExtent
                  ? overscrolledExtent
                  // 如果为double.infinity则占满列表
                  : _refreshIndicatorExtent == double.infinity
                      ? constraints.viewportMainAxisExtent
                      : _refreshIndicatorExtent
              : overscrolledExtent,
        ),
        parentUsesSize: true,
      );
    } else {
      child.layout(
        constraints.asBoxConstraints(
          maxExtent: layoutExtent
              // Plus only the overscrolled portion immediately preceding this
              // sliver.
              +
              overscrolledExtent,
        ),
        parentUsesSize: true,
      );
    }
    if (active) {
      // 判断Header是否浮动
      if (headerFloat) {
        geometry = SliverGeometry(
          scrollExtent: 0.0,
          paintOrigin: 0.0,
          paintExtent: childSize,
          maxPaintExtent: childSize,
          layoutExtent: max(-constraints.scrollOffset, 0.0),
          visible: true,
          hasVisualOverflow: true,
        );
      } else {
        geometry = SliverGeometry(
          scrollExtent: layoutExtent,
          paintOrigin: -overscrolledExtent - constraints.scrollOffset,
          paintExtent: min(
              max(
                // Check child size (which can come from overscroll) because
                // layoutExtent may be zero. Check layoutExtent also since even
                // with a layoutExtent, the indicator builder may decide to not
                // build anything.
                max(childSize, layoutExtent) - constraints.scrollOffset,
                0.0,
              ),
              constraints.remainingPaintExtent),
          maxPaintExtent: max(
            max(childSize, layoutExtent) - constraints.scrollOffset,
            0.0,
          ),
          layoutExtent: max(layoutExtent - constraints.scrollOffset, 0.0),
        );
      }
    } else {
      // If we never started overscrolling, return no geometry.
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.overlap < 0.0 || constraints.scrollOffset + childSize > 0) {
      paintContext.paintChild(child, offset);
    }
  }

  // Nothing special done here because this sliver always paints its child
  // exactly between paintOrigin and paintExtent.
  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}

/// The current state of the refresh control.
///
/// Passed into the [RefreshControlBuilder] builder function so
/// users can show different UI in different modes.
enum RefreshMode {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  inactive,

  /// While being overscrolled but not far enough yet to trigger the refresh.
  drag,

  /// Dragged far enough that the onRefresh callback will run and the dragged
  /// displacement is not yet at the final refresh resting state.
  armed,

  /// While the onRefresh task is running.
  refresh,

  /// 刷新完成
  refreshed,

  /// While the indicator is animating away after refreshing.
  done,
}

/// Signature for a builder that can create a different widget to show in the
/// refresh indicator space depending on the current state of the refresh
/// control and the space available.
///
/// The `refreshTriggerPullDistance` and `refreshIndicatorExtent` parameters are
/// the same values passed into the [EasyRefreshSliverRefreshControl].
///
/// The `pulledExtent` parameter is the currently available space either from
/// overscrolling or as held by the sliver during refresh.
typedef RefreshControlBuilder = Widget Function(
    BuildContext context,
    RefreshMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
    AxisDirection axisDirection,
    bool float,
    Duration completeDuration,
    bool enableInfiniteRefresh,
    bool success,
    bool noMore);

/// A callback function that's invoked when the [EasyRefreshSliverRefreshControl] is
/// pulled a `refreshTriggerPullDistance`. Must return a [Future]. Upon
/// completion of the [Future], the [EasyRefreshSliverRefreshControl] enters the
/// [RefreshMode.done] state and will start to go away.
typedef OnRefreshCallback = Future<void> Function();

/// 结束刷新
/// success 为是否成功(为false时，noMore无效)
/// noMore 为是否有更多数据
typedef FinishRefresh = void Function({
  bool success,
  bool noMore,
});

/// 绑定刷新指示剂
typedef BindRefreshIndicator = void Function(
    FinishRefresh finishRefresh, VoidCallback resetRefreshState);

/// A sliver widget implementing the iOS-style pull to refresh content control.
///
/// When inserted as the first sliver in a scroll view or behind other slivers
/// that still lets the scrollable overscroll in front of this sliver (such as
/// the [CupertinoSliverNavigationBar], this widget will:
///
///  * Let the user draw inside the overscrolled area via the passed in [builder].
///  * Trigger the provided [onRefresh] function when overscrolled far enough to
///    pass [refreshTriggerPullDistance].
///  * Continue to hold [refreshIndicatorExtent] amount of space for the [builder]
///    to keep drawing inside of as the [Future] returned by [onRefresh] processes.
///  * Scroll away once the [onRefresh] [Future] completes.
///
/// The [builder] function will be informed of the current [RefreshMode]
/// when invoking it, except in the [RefreshMode.inactive] state when
/// no space is available and nothing needs to be built. The [builder] function
/// will otherwise be continuously invoked as the amount of space available
/// changes from overscroll, as the sliver scrolls away after the [onRefresh]
/// task is done, etc.
///
/// Only one refresh can be triggered until the previous refresh has completed
/// and the indicator sliver has retracted at least 90% of the way back.
///
/// Can only be used in downward-scrolling vertical lists that overscrolls. In
/// other words, refreshes can't be triggered with lists using
/// [ClampingScrollPhysics].
///
/// In a typical application, this sliver should be inserted between the app bar
/// sliver such as [CupertinoSliverNavigationBar] and your main scrollable
/// content's sliver.
///
/// See also:
///
///  * [CustomScrollView], a typical sliver holding scroll view this control
///    should go into.
///  * <https://developer.apple.com/ios/human-interface-guidelines/controls/refresh-content-controls/>
///  * [RefreshIndicator], a Material Design version of the pull-to-refresh
///    paradigm. This widget works differently than [RefreshIndicator] because
///    instead of being an overlay on top of the scrollable, the
///    [EasyRefreshSliverRefreshControl] is part of the scrollable and actively occupies
///    scrollable space.
class EasyRefreshSliverRefreshControl extends StatefulWidget {
  /// Create a new refresh control for inserting into a list of slivers.
  ///
  /// The [refreshTriggerPullDistance] and [refreshIndicatorExtent] arguments
  /// must not be null and must be >= 0.
  ///
  /// The [builder] argument may be null, in which case no indicator UI will be
  /// shown but the [onRefresh] will still be invoked. By default, [builder]
  /// shows a [CupertinoActivityIndicator].
  ///
  /// The [onRefresh] argument will be called when pulled far enough to trigger
  /// a refresh.
  const EasyRefreshSliverRefreshControl({
    Key key,
    this.refreshTriggerPullDistance = _defaultRefreshTriggerPullDistance,
    this.refreshIndicatorExtent = _defaultRefreshIndicatorExtent,
    @required this.builder,
    this.completeDuration,
    this.onRefresh,
    this.focusNotifier,
    this.taskNotifier,
    this.callRefreshNotifier,
    this.taskIndependence,
    this.bindRefreshIndicator,
    this.enableControlFinishRefresh = false,
    this.enableInfiniteRefresh = false,
    this.enableHapticFeedback = false,
    this.headerFloat = false,
  })  : assert(refreshTriggerPullDistance != null),
        assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent != null),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
            headerFloat || refreshTriggerPullDistance >= refreshIndicatorExtent,
            'The refresh indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  /// The amount of overscroll the scrollable must be dragged to trigger a reload.
  ///
  /// Must not be null, must be larger than 0.0 and larger than
  /// [refreshIndicatorExtent]. Defaults to 100px when not specified.
  ///
  /// When overscrolled past this distance, [onRefresh] will be called if not
  /// null and the [builder] will build in the [RefreshMode.armed] state.
  final double refreshTriggerPullDistance;

  /// The amount of space the refresh indicator sliver will keep holding while
  /// [onRefresh]'s [Future] is still running.
  ///
  /// Must not be null and must be positive, but can be 0.0, in which case the
  /// sliver will start retracting back to 0.0 as soon as the refresh is started.
  /// Defaults to 60px when not specified.
  ///
  /// Must be smaller than [refreshTriggerPullDistance], since the sliver
  /// shouldn't grow further after triggering the refresh.
  final double refreshIndicatorExtent;

  /// A builder that's called as this sliver's size changes, and as the state
  /// changes.
  ///
  /// A default simple Twitter-style pull-to-refresh indicator is provided if
  /// not specified.
  ///
  /// Can be set to null, in which case nothing will be drawn in the overscrolled
  /// space.
  ///
  /// Will not be called when the available space is zero such as before any
  /// overscroll.
  final RefreshControlBuilder builder;

  /// Callback invoked when pulled by [refreshTriggerPullDistance].
  ///
  /// If provided, must return a [Future] which will keep the indicator in the
  /// [RefreshMode.refresh] state until the [Future] completes.
  ///
  /// Can be null, in which case a single frame of [RefreshMode.armed]
  /// state will be drawn before going immediately to the [RefreshMode.done]
  /// where the sliver will start retracting.
  final OnRefreshCallback onRefresh;

  /// 完成延时
  final Duration completeDuration;

  /// 绑定刷新指示器
  final BindRefreshIndicator bindRefreshIndicator;

  /// 是否开启控制结束
  final bool enableControlFinishRefresh;

  /// 是否开启无限刷新
  final bool enableInfiniteRefresh;

  /// 开启震动反馈
  final bool enableHapticFeedback;

  /// 滚动状态
  final ValueNotifier<bool> focusNotifier;

  /// 触发刷新状态
  final ValueNotifier<bool> callRefreshNotifier;

  /// 任务状态
  final ValueNotifier<bool> taskNotifier;

  /// 是否任务独立
  final bool taskIndependence;

  /// Header浮动
  final bool headerFloat;

  static const double _defaultRefreshTriggerPullDistance = 100.0;
  static const double _defaultRefreshIndicatorExtent = 60.0;

  /// Retrieve the current state of the EasyRefreshSliverRefreshControl. The same as the
  /// state that gets passed into the [builder] function. Used for testing.
  @visibleForTesting
  static RefreshMode state(BuildContext context) {
    final _EasyRefreshSliverRefreshControlState state =
        context.ancestorStateOfType(
            const TypeMatcher<_EasyRefreshSliverRefreshControlState>());
    return state.refreshState;
  }

  @override
  _EasyRefreshSliverRefreshControlState createState() =>
      _EasyRefreshSliverRefreshControlState();
}

class _EasyRefreshSliverRefreshControlState
    extends State<EasyRefreshSliverRefreshControl> {
  // Reset the state from done to inactive when only this fraction of the
  // original `refreshTriggerPullDistance` is left.
  static const double _inactiveResetOverscrollFraction = 0.1;

  RefreshMode refreshState;
  // [Future] returned by the widget's `onRefresh`.
  Future<void> _refreshTask;
  Future<void> get refreshTask => _refreshTask;
  bool get hasTask {
    return widget.taskIndependence
        ? _refreshTask != null
        : widget.taskNotifier.value;
  }

  set refreshTask(Future<void> task) {
    _refreshTask = task;
    if (!widget.taskIndependence) widget.taskNotifier.value = task != null;
  }

  // The amount of space available from the inner indicator box's perspective.
  //
  // The value is the sum of the sliver's layout extent and the overscroll
  // (which partially gets transferred into the layout extent when the refresh
  // triggers).
  //
  // The value of latestIndicatorBoxExtent doesn't change when the sliver scrolls
  // away without retracting; it is independent from the sliver's scrollOffset.
  double latestIndicatorBoxExtent = 0.0;
  bool hasSliverLayoutExtent = false;

  // 滚动焦点
  bool get _focus => widget.focusNotifier.value;
  // 刷新完成
  bool _success;
  // 没有更多数据
  bool _noMore;

  // 列表方向
  ValueNotifier<AxisDirection> _axisDirectionNotifier;

  // 初始化
  @override
  void initState() {
    super.initState();
    refreshState = RefreshMode.inactive;
    _axisDirectionNotifier = ValueNotifier<AxisDirection>(AxisDirection.down);
    // 绑定刷新指示器
    if (widget.bindRefreshIndicator != null) {
      widget.bindRefreshIndicator(finishRefresh, resetRefreshState);
    }
  }

  // 销毁
  @override
  void dispose() {
    super.dispose();
  }

  // 完成刷新
  void finishRefresh({
    bool success,
    bool noMore,
  }) {
    _success = success;
    _noMore = _success == false ? false : noMore;
    if (widget.enableControlFinishRefresh && refreshTask != null) {
      if (widget.enableInfiniteRefresh) {
        refreshState = RefreshMode.inactive;
      }
      setState(() => refreshTask = null);
      refreshState = transitionNextState();
    }
  }

  // 恢复状态
  void resetRefreshState() {
    if (mounted) {
      setState(() {
        _success = true;
        _noMore = false;
        refreshState = RefreshMode.inactive;
        hasSliverLayoutExtent = false;
      });
    }
  }

  // 无限刷新
  void _infiniteRefresh() {
    if (!hasTask &&
        widget.enableInfiniteRefresh &&
        _noMore != true &&
        !widget.callRefreshNotifier.value) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        refreshState = RefreshMode.refresh;
        refreshTask = widget.onRefresh()
          ..then((_) {
            if (mounted && !widget.enableControlFinishRefresh) {
              refreshState = RefreshMode.refresh;
              setState(() => refreshTask = null);
              // Trigger one more transition because by this time, BoxConstraint's
              // maxHeight might already be resting at 0 in which case no
              // calls to [transitionNextState] will occur anymore and the
              // state may be stuck in a non-inactive state.
              refreshState = transitionNextState();
            }
          });
        setState(() => hasSliverLayoutExtent = true);
      });
    }
  }

  // A state machine transition calculator. Multiple states can be transitioned
  // through per single call.
  RefreshMode transitionNextState() {
    RefreshMode nextState;

    // 判断是否没有更多
    if (_noMore == true && widget.enableInfiniteRefresh) {
      return refreshState;
    } else if (_noMore == true &&
        refreshState != RefreshMode.refresh &&
        refreshState != RefreshMode.refreshed &&
        refreshState != RefreshMode.done) {
      return refreshState;
    } else if (widget.enableInfiniteRefresh &&
        refreshState == RefreshMode.done) {
      return RefreshMode.inactive;
    }

    // 结束
    void goToDone() {
      nextState = RefreshMode.done;
      refreshState = RefreshMode.done;
      // Either schedule the RenderSliver to re-layout on the next frame
      // when not currently in a frame or schedule it on the next frame.
      if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        setState(() => hasSliverLayoutExtent = false);
      } else {
        SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
          setState(() => hasSliverLayoutExtent = false);
        });
      }
    }

    // 完成
    RefreshMode goToFinish() {
      // 判断刷新完成
      RefreshMode state = RefreshMode.refreshed;
      // 添加延时
      if (widget.completeDuration == null || widget.enableInfiniteRefresh) {
        goToDone();
        return null;
      } else {
        Future.delayed(widget.completeDuration, () {
          if (mounted) {
            goToDone();
          }
        });
        return state;
      }
    }

    switch (refreshState) {
      case RefreshMode.inactive:
        if (latestIndicatorBoxExtent <= 0 ||
            (!_focus && !widget.callRefreshNotifier.value)) {
          return RefreshMode.inactive;
        } else {
          if (widget.callRefreshNotifier.value) {
            widget.callRefreshNotifier.value = false;
          }
          nextState = RefreshMode.drag;
        }
        continue drag;
      drag:
      case RefreshMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return RefreshMode.inactive;
        } else if (latestIndicatorBoxExtent <=
            widget.refreshTriggerPullDistance) {
          // 如果未触发刷新则取消固定高度
          if (hasSliverLayoutExtent && !hasTask) {
            SchedulerBinding.instance
                .addPostFrameCallback((Duration timestamp) {
              setState(() => hasSliverLayoutExtent = false);
            });
          }
          return RefreshMode.drag;
        } else {
          // 提前固定高度，防止列表回弹
          SchedulerBinding.instance
              .addPostFrameCallback((Duration timestamp) {
            if (!hasSliverLayoutExtent) {
              setState(() => hasSliverLayoutExtent = true);
            }
          });
          if (widget.onRefresh != null && !hasTask) {
            if (!_focus) {
              if (widget.callRefreshNotifier.value) {
                widget.callRefreshNotifier.value = false;
              }
              if (widget.enableHapticFeedback) {
                HapticFeedback.mediumImpact();
              }
              // 触发刷新任务
              SchedulerBinding.instance
                  .addPostFrameCallback((Duration timestamp) {
                refreshTask = widget.onRefresh()
                  ..then((_) {
                    if (mounted && !widget.enableControlFinishRefresh) {
                      if (widget.enableInfiniteRefresh) {
                        refreshState = RefreshMode.inactive;
                      }
                      setState(() => refreshTask = null);
                      if (!widget.enableInfiniteRefresh)
                        refreshState = transitionNextState();
                    }
                  });
              });
              return RefreshMode.armed;
            }
            return RefreshMode.drag;
          }
          return RefreshMode.drag;
        }
        // Don't continue here. We can never possibly call onRefresh and
        // progress to the next state in one [computeNextState] call.
        break;
      case RefreshMode.armed:
        if (refreshState == RefreshMode.armed && !hasTask) {
          // 完成
          var state = goToFinish();
          if (state != null) return state;
          continue done;
        }

        if (latestIndicatorBoxExtent != widget.refreshIndicatorExtent) {
          return RefreshMode.armed;
        } else {
          nextState = RefreshMode.refresh;
        }
        continue refresh;
      refresh:
      case RefreshMode.refresh:
        if (refreshTask != null) {
          return RefreshMode.refresh;
        } else {
          // 完成
          var state = goToFinish();
          if (state != null) return state;
        }
        continue done;
      done:
      case RefreshMode.done:
        // Let the transition back to inactive trigger before strictly going
        // to 0.0 since the last bit of the animation can take some time and
        // can feel sluggish if not going all the way back to 0.0 prevented
        // a subsequent pull-to-refresh from starting.
        if (latestIndicatorBoxExtent >
            widget.refreshTriggerPullDistance *
                _inactiveResetOverscrollFraction) {
          return RefreshMode.done;
        } else {
          nextState = RefreshMode.inactive;
        }
        break;
      case RefreshMode.refreshed:
        nextState = refreshState;
        break;
      default:
        break;
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return _EasyRefreshSliverRefresh(
      refreshIndicatorLayoutExtent: widget.refreshIndicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      enableInfiniteRefresh: widget.enableInfiniteRefresh,
      infiniteRefresh: _infiniteRefresh,
      headerFloat: widget.headerFloat,
      axisDirectionNotifier: _axisDirectionNotifier,
      // A LayoutBuilder lets the sliver's layout changes be fed back out to
      // its owner to trigger state changes.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 是否为垂直方向
          bool isVertical =
              _axisDirectionNotifier.value == AxisDirection.down ||
                  _axisDirectionNotifier.value == AxisDirection.up;
          latestIndicatorBoxExtent =
              isVertical ? constraints.maxHeight : constraints.maxWidth;
          refreshState = transitionNextState();
          if (widget.builder != null && latestIndicatorBoxExtent >= 0) {
            return widget.builder(
              context,
              refreshState,
              latestIndicatorBoxExtent,
              widget.refreshTriggerPullDistance,
              widget.refreshIndicatorExtent,
              _axisDirectionNotifier.value,
              widget.headerFloat,
              widget.completeDuration,
              widget.enableInfiniteRefresh,
              _success ?? true,
              _noMore ?? false,
            );
          }
          return Container();
        },
      ),
    );
  }
}
