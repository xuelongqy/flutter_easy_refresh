// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class _EasyRefreshSliverLoad extends SingleChildRenderObjectWidget {
  const _EasyRefreshSliverLoad({
    Key key,
    this.loadIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    this.enableInfiniteLoad = true,
    this.footerFloat = false,
    this.axisDirectionNotifier,
    @required this.infiniteLoad,
    @required this.extraExtentNotifier,
    Widget child,
  })  : assert(loadIndicatorLayoutExtent != null),
        assert(loadIndicatorLayoutExtent >= 0.0),
        assert(hasLayoutExtent != null),
        super(key: key, child: child);

  // The amount of space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  final double loadIndicatorLayoutExtent;

  // _RenderEasyRefreshSliverLoad will paint the child in the available
  // space either way but this instructs the _RenderEasyRefreshSliverLoad
  // on whether to also occupy any layoutExtent space or not.
  final bool hasLayoutExtent;

  /// 是否开启无限加载
  final bool enableInfiniteLoad;

  /// 无限加载回调
  final VoidCallback infiniteLoad;

  /// Footer浮动
  final bool footerFloat;

  /// 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  // 列表为占满时多余长度
  final ValueNotifier<double> extraExtentNotifier;

  @override
  _RenderEasyRefreshSliverLoad createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverLoad(
      loadIndicatorExtent: loadIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
      enableInfiniteLoad: enableInfiniteLoad,
      infiniteLoad: infiniteLoad,
      extraExtentNotifier: extraExtentNotifier,
      footerFloat: footerFloat,
      axisDirectionNotifier: axisDirectionNotifier,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderEasyRefreshSliverLoad renderObject) {
    renderObject
      ..loadIndicatorLayoutExtent = loadIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent
      ..enableInfiniteLoad = enableInfiniteLoad
      ..footerFloat = footerFloat;
  }
}

// RenderSliver object that gives its child RenderBox object space to paint
// in the overscrolled gap and may or may not hold that overscrolled gap
// around the RenderBox depending on whether [layoutExtent] is set.
//
// The [layoutExtentOffsetCompensation] field keeps internal accounting to
// prevent scroll position jumps as the [layoutExtent] is set and unset.
class _RenderEasyRefreshSliverLoad extends RenderSliver
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderEasyRefreshSliverLoad({
    @required double loadIndicatorExtent,
    @required bool hasLayoutExtent,
    @required bool enableInfiniteLoad,
    @required this.infiniteLoad,
    @required this.extraExtentNotifier,
    @required this.axisDirectionNotifier,
    @required bool footerFloat,
    RenderBox child,
  })  : assert(loadIndicatorExtent != null),
        assert(loadIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _loadIndicatorExtent = loadIndicatorExtent,
        _enableInfiniteLoad = enableInfiniteLoad,
        _hasLayoutExtent = hasLayoutExtent,
        _footerFloat = footerFloat {
    this.child = child;
  }

  /// 列表方向
  final ValueNotifier<AxisDirection> axisDirectionNotifier;

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get loadIndicatorLayoutExtent => _loadIndicatorExtent;
  double _loadIndicatorExtent;
  set loadIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _loadIndicatorExtent) return;
    _loadIndicatorExtent = value;
    markNeedsLayout();
  }

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

  /// 是否开启无限加载
  bool get enableInfiniteLoad => _enableInfiniteLoad;
  bool _enableInfiniteLoad;
  set enableInfiniteLoad(bool value) {
    assert(value != null);
    if (value == _enableInfiniteLoad) return;
    _enableInfiniteLoad = value;
    markNeedsLayout();
  }

  /// Header是否浮动
  bool get footerFloat => _footerFloat;
  bool _footerFloat;
  set footerFloat(bool value) {
    assert(value != null);
    if (value == _footerFloat) return;
    _footerFloat = value;
    markNeedsLayout();
  }

  /// 无限加载回调
  final VoidCallback infiniteLoad;

  // 列表为占满时多余长度
  final ValueNotifier<double> extraExtentNotifier;

  // 触发无限加载
  bool _triggerInfiniteLoad = false;

  // 获取子组件大小
  double get childSize =>
      constraints.axis == Axis.vertical ? child.size.height : child.size.width;

  // This keeps track of the previously applied scroll offsets to the scrollable
  // so that when [loadIndicatorLayoutExtent] or [hasLayoutExtent] changes,
  // the appropriate delta can be applied to keep everything in the same place
  // visually.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {
    // 判断列表是否未占满,去掉未占满高度
    double extraExtent = 0.0;
    if (constraints.precedingScrollExtent <
        constraints.viewportMainAxisExtent) {
      extraExtent = constraints.viewportMainAxisExtent -
          constraints.precedingScrollExtent;
    }
    extraExtentNotifier.value = extraExtent;

    // Only pulling to refresh from the top is currently supported.
    // 注释以支持reverse
    // assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    // 判断是否触发无限加载
    if (enableInfiniteLoad &&
        constraints.remainingPaintExtent > 1.0
        //&& constraints.userScrollDirection != ScrollDirection.idle
        &&
        extraExtentNotifier.value == 0.0) {
      if (!_triggerInfiniteLoad) {
        _triggerInfiniteLoad = true;
        infiniteLoad();
      }
    } else {
      if (constraints.remainingPaintExtent <= 1.0 || extraExtent > 0.0) {
        if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
          _triggerInfiniteLoad = false;
        } else {
          SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
            _triggerInfiniteLoad = false;
          });
        }
      }
    }

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent || enableInfiniteLoad ? 1.0 : 0.0) *
            _loadIndicatorExtent;
    // If the new layoutExtent instructive changed, the SliverGeometry's
    // layoutExtent will take that value (on the next performLayout run). Shift
    // the scroll offset first so it doesn't make the scroll position suddenly jump.
    /*if (layoutExtent != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = layoutExtent;
      // Return so we don't have to do temporary accounting and adjusting the
      // child's constraints accounting for this one transient frame using a
      // combination of existing layout extent, new layout extent change and
      // the overlap.
      return;
    }*/
    final bool active = (constraints.remainingPaintExtent > 1.0 ||
        layoutExtent > (enableInfiniteLoad ? 1.0 : 0.0) * _loadIndicatorExtent);
    final double overscrolledExtent = constraints.remainingPaintExtent > 0.0
        ? constraints.remainingPaintExtent.abs()
        : 0.0;
    // 是否反向
    bool isReverse = constraints.axisDirection == AxisDirection.up ||
        constraints.axisDirection == AxisDirection.left;
    axisDirectionNotifier.value = constraints.axisDirection;
    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: isReverse
            ? overscrolledExtent
            : _hasLayoutExtent || enableInfiniteLoad
                ? _loadIndicatorExtent > overscrolledExtent
                    ? _loadIndicatorExtent
                    : overscrolledExtent
                : overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: constraints.scrollOffset,
        paintExtent: max(
          // Check child size (which can come from overscroll) because
          // layoutExtent may be zero. Check layoutExtent also since even
          // with a layoutExtent, the indicator builder may decide to not
          // build anything.
          min(max(childSize, layoutExtent), constraints.remainingPaintExtent) -
              constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          min(max(childSize, layoutExtent), constraints.remainingPaintExtent) -
              constraints.scrollOffset,
          0.0,
        ),
        layoutExtent: min(max(layoutExtent - constraints.scrollOffset, 0.0),
            constraints.remainingPaintExtent),
      );
    } else {
      // If we never started overscrolling, return no geometry.
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext paintContext, Offset offset) {
    if (constraints.remainingPaintExtent > 0.0 ||
        constraints.scrollOffset + childSize > 0) {
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
/// Passed into the [LoadControlBuilder] builder function so
/// users can show different UI in different modes.
enum LoadMode {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  inactive,

  /// While being overscrolled but not far enough yet to trigger the refresh.
  drag,

  /// Dragged far enough that the onLoad callback will run and the dragged
  /// displacement is not yet at the final refresh resting state.
  armed,

  /// While the onLoad task is running.
  load,

  /// 刷新完成
  loaded,

  /// While the indicator is animating away after refreshing.
  done,
}

/// Signature for a builder that can create a different widget to show in the
/// refresh indicator space depending on the current state of the refresh
/// control and the space available.
///
/// The `loadTriggerPullDistance` and `loadIndicatorExtent` parameters are
/// the same values passed into the [EasyRefreshSliverLoadControl].
///
/// The `pulledExtent` parameter is the currently available space either from
/// overscrolling or as held by the sliver during refresh.
typedef LoadControlBuilder = Widget Function(
    BuildContext context,
    LoadMode loadState,
    double pulledExtent,
    double loadTriggerPullDistance,
    double loadIndicatorExtent,
    AxisDirection axisDirection,
    bool float,
    Duration completeDuration,
    bool enableInfiniteLoad,
    bool success,
    bool noMore);

/// A callback function that's invoked when the [EasyRefreshSliverLoadControl] is
/// pulled a `loadTriggerPullDistance`. Must return a [Future]. Upon
/// completion of the [Future], the [EasyRefreshSliverLoadControl] enters the
/// [LoadMode.done] state and will start to go away.
typedef OnLoadCallback = Future<void> Function();

/// 结束加载
/// success 为是否成功(为false时，noMore无效)
/// noMore 为是否有更多数据
typedef FinishLoad = void Function({
  bool success,
  bool noMore,
});

/// 绑定加载指示剂
typedef BindLoadIndicator = void Function(
    FinishLoad finishLoad, VoidCallback resetLoadState);

/// A sliver widget implementing the iOS-style pull to refresh content control.
///
/// When inserted as the first sliver in a scroll view or behind other slivers
/// that still lets the scrollable overscroll in front of this sliver (such as
/// the [CupertinoSliverNavigationBar], this widget will:
///
///  * Let the user draw inside the overscrolled area via the passed in [builder].
///  * Trigger the provided [onLoad] function when overscrolled far enough to
///    pass [loadTriggerPullDistance].
///  * Continue to hold [loadIndicatorExtent] amount of space for the [builder]
///    to keep drawing inside of as the [Future] returned by [onLoad] processes.
///  * Scroll away once the [onLoad] [Future] completes.
///
/// The [builder] function will be informed of the current [LoadMode]
/// when invoking it, except in the [LoadMode.inactive] state when
/// no space is available and nothing needs to be built. The [builder] function
/// will otherwise be continuously invoked as the amount of space available
/// changes from overscroll, as the sliver scrolls away after the [onLoad]
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
///    [EasyRefreshSliverLoadControl] is part of the scrollable and actively occupies
///    scrollable space.
class EasyRefreshSliverLoadControl extends StatefulWidget {
  /// Create a new refresh control for inserting into a list of slivers.
  ///
  /// The [loadTriggerPullDistance] and [loadIndicatorExtent] arguments
  /// must not be null and must be >= 0.
  ///
  /// The [builder] argument may be null, in which case no indicator UI will be
  /// shown but the [onLoad] will still be invoked. By default, [builder]
  /// shows a [CupertinoActivityIndicator].
  ///
  /// The [onLoad] argument will be called when pulled far enough to trigger
  /// a refresh.
  const EasyRefreshSliverLoadControl({
    Key key,
    this.loadTriggerPullDistance = _defaultLoadTriggerPullDistance,
    this.loadIndicatorExtent = _defaultLoadIndicatorExtent,
    @required this.builder,
    this.completeDuration,
    this.onLoad,
    this.focusNotifier,
    this.taskNotifier,
    this.callLoadNotifier,
    this.taskIndependence,
    this.bindLoadIndicator,
    this.enableControlFinishLoad = false,
    this.enableInfiniteLoad = true,
    this.enableHapticFeedback = false,
    this.footerFloat = false,
  })  : assert(loadTriggerPullDistance != null),
        assert(loadTriggerPullDistance > 0.0),
        assert(loadIndicatorExtent != null),
        assert(loadIndicatorExtent >= 0.0),
        assert(
            loadTriggerPullDistance >= loadIndicatorExtent,
            'The refresh indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'),
        super(key: key);

  /// The amount of overscroll the scrollable must be dragged to trigger a reload.
  ///
  /// Must not be null, must be larger than 0.0 and larger than
  /// [loadIndicatorExtent]. Defaults to 100px when not specified.
  ///
  /// When overscrolled past this distance, [onLoad] will be called if not
  /// null and the [builder] will build in the [LoadMode.armed] state.
  final double loadTriggerPullDistance;

  /// The amount of space the refresh indicator sliver will keep holding while
  /// [onLoad]'s [Future] is still running.
  ///
  /// Must not be null and must be positive, but can be 0.0, in which case the
  /// sliver will start retracting back to 0.0 as soon as the refresh is started.
  /// Defaults to 60px when not specified.
  ///
  /// Must be smaller than [loadTriggerPullDistance], since the sliver
  /// shouldn't grow further after triggering the refresh.
  final double loadIndicatorExtent;

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
  final LoadControlBuilder builder;

  /// Callback invoked when pulled by [loadTriggerPullDistance].
  ///
  /// If provided, must return a [Future] which will keep the indicator in the
  /// [LoadMode.refresh] state until the [Future] completes.
  ///
  /// Can be null, in which case a single frame of [LoadMode.armed]
  /// state will be drawn before going immediately to the [LoadMode.done]
  /// where the sliver will start retracting.
  final OnLoadCallback onLoad;

  /// 完成延时
  final Duration completeDuration;

  /// 绑定加载指示器
  final BindLoadIndicator bindLoadIndicator;

  /// 是否开启控制结束
  final bool enableControlFinishLoad;

  /// 是否开启无限加载
  final bool enableInfiniteLoad;

  /// 开启震动反馈
  final bool enableHapticFeedback;

  /// 滚动状态
  final ValueNotifier<bool> focusNotifier;

  /// 任务状态
  final ValueNotifier<bool> taskNotifier;
  // 触发加载状态
  final ValueNotifier<bool> callLoadNotifier;

  /// 是否任务独立
  final bool taskIndependence;

  /// Footer浮动
  final bool footerFloat;

  static const double _defaultLoadTriggerPullDistance = 100.0;
  static const double _defaultLoadIndicatorExtent = 60.0;

  /// Retrieve the current state of the EasyRefreshSliverLoadControl. The same as the
  /// state that gets passed into the [builder] function. Used for testing.
  @visibleForTesting
  static LoadMode state(BuildContext context) {
    final _EasyRefreshSliverLoadControlState state =
        context.ancestorStateOfType(
            const TypeMatcher<_EasyRefreshSliverLoadControlState>());
    return state.loadState;
  }

  @override
  _EasyRefreshSliverLoadControlState createState() =>
      _EasyRefreshSliverLoadControlState();
}

class _EasyRefreshSliverLoadControlState
    extends State<EasyRefreshSliverLoadControl> {
  // Reset the state from done to inactive when only this fraction of the
  // original `loadTriggerPullDistance` is left.
  static const double _inactiveResetOverscrollFraction = 0.1;

  LoadMode loadState;
  // [Future] returned by the widget's `onLoad`.
  Future<void> _loadTask;
  Future<void> get loadTask => _loadTask;
  bool get hasTask {
    return widget.taskIndependence
        ? _loadTask != null
        : widget.taskNotifier.value;
  }

  set loadTask(Future<void> task) {
    _loadTask = task;
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
  // 列表为占满时多余长度
  ValueNotifier<double> extraExtentNotifier;
  // 列表方向
  ValueNotifier<AxisDirection> _axisDirectionNotifier;

  // 初始化
  @override
  void initState() {
    super.initState();
    loadState = LoadMode.inactive;
    extraExtentNotifier = ValueNotifier<double>(0.0);
    _axisDirectionNotifier = ValueNotifier<AxisDirection>(AxisDirection.down);
    // 绑定加载指示器
    if (widget.bindLoadIndicator != null) {
      widget.bindLoadIndicator(finishLoad, resetLoadState);
    }
  }

  // 销毁
  @override
  void dispose() {
    super.dispose();
    extraExtentNotifier.dispose();
  }

  // 完成刷新
  void finishLoad({
    bool success = true,
    bool noMore = false,
  }) {
    _success = success;
    _noMore = _success == false ? false : noMore;
    if (widget.enableControlFinishLoad && loadTask != null) {
      if (widget.enableInfiniteLoad) {
        loadState = LoadMode.inactive;
      }
      setState(() => loadTask = null);
      loadState = transitionNextState();
    }
  }

  // 恢复状态
  void resetLoadState() {
    if (mounted) {
      setState(() {
        _success = true;
        _noMore = false;
        loadState = LoadMode.inactive;
        hasSliverLayoutExtent = false;
      });
    }
  }

  // 无限加载
  void _infiniteLoad() {
    if (!hasTask &&
        widget.enableInfiniteLoad &&
        _noMore != true &&
        !widget.callLoadNotifier.value) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        loadState = LoadMode.load;
        loadTask = widget.onLoad()
          ..then((_) {
            if (mounted && !widget.enableControlFinishLoad) {
              loadState = LoadMode.load;
              setState(() => loadTask = null);
              // Trigger one more transition because by this time, BoxConstraint's
              // maxHeight might already be resting at 0 in which case no
              // calls to [transitionNextState] will occur anymore and the
              // state may be stuck in a non-inactive state.
              loadState = transitionNextState();
            }
          });
        setState(() => hasSliverLayoutExtent = true);
      });
    }
  }

  // A state machine transition calculator. Multiple states can be transitioned
  // through per single call.
  LoadMode transitionNextState() {
    LoadMode nextState;

    // 判断是否没有更多
    if (_noMore == true && widget.enableInfiniteLoad) {
      return loadState;
    } else if (_noMore == true &&
        loadState != LoadMode.load &&
        loadState != LoadMode.loaded &&
        loadState != LoadMode.done) {
      return loadState;
    } else if (widget.enableInfiniteLoad && loadState == LoadMode.done) {
      return LoadMode.inactive;
    }

    // 完成
    void goToDone() {
      nextState = LoadMode.done;
      loadState = LoadMode.done;
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

    // 结束
    LoadMode goToFinish() {
      // 判断加载完成
      LoadMode state = LoadMode.loaded;
      // 添加延时
      if (widget.completeDuration == null || widget.enableInfiniteLoad) {
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

    switch (loadState) {
      case LoadMode.inactive:
        if (latestIndicatorBoxExtent <= 0 ||
            (!_focus && !widget.callLoadNotifier.value)) {
          return LoadMode.inactive;
        } else {
          nextState = LoadMode.drag;
        }
        continue drag;
      drag:
      case LoadMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return LoadMode.inactive;
        } else if (latestIndicatorBoxExtent <= widget.loadTriggerPullDistance) {
          // 如果未触发加载则取消固定高度
          if (hasSliverLayoutExtent && !hasTask) {
            SchedulerBinding.instance
                .addPostFrameCallback((Duration timestamp) {
              setState(() => hasSliverLayoutExtent = false);
            });
          }
          return LoadMode.drag;
        } else {
          // 提前固定高度，防止列表回弹
          SchedulerBinding.instance
              .addPostFrameCallback((Duration timestamp) {
            setState(() => hasSliverLayoutExtent = true);
          });
          if (widget.onLoad != null && !hasTask) {
            if (!_focus) {
              if (widget.callLoadNotifier.value) {
                widget.callLoadNotifier.value = false;
              }
              if (widget.enableHapticFeedback) {
                HapticFeedback.mediumImpact();
              }
              // 触发加载任务
              SchedulerBinding.instance
                  .addPostFrameCallback((Duration timestamp) {
                loadTask = widget.onLoad()
                  ..then((_) {
                    if (mounted && !widget.enableControlFinishLoad) {
                      if (widget.enableInfiniteLoad) {
                        loadState = LoadMode.inactive;
                      }
                      setState(() => loadTask = null);
                      if (!widget.enableInfiniteLoad)
                        loadState = transitionNextState();
                    }
                  });
              });
              return LoadMode.armed;
            }
            return LoadMode.drag;
          }
          return LoadMode.drag;
        }
        // Don't continue here. We can never possibly call onLoad and
        // progress to the next state in one [computeNextState] call.
        break;
      case LoadMode.armed:
        if (loadState == LoadMode.armed && !hasTask) {
          // 结束
          var state = goToFinish();
          if (state != null) return state;
          continue done;
        }

        if (latestIndicatorBoxExtent > widget.loadIndicatorExtent) {
          return LoadMode.armed;
        } else {
          nextState = LoadMode.load;
        }
        continue refresh;
      refresh:
      case LoadMode.load:
        if (loadTask != null) {
          return LoadMode.load;
        } else {
          // 结束
          var state = goToFinish();
          if (state != null) return state;
        }
        continue done;
      done:
      case LoadMode.done:
        // Let the transition back to inactive trigger before strictly going
        // to 0.0 since the last bit of the animation can take some time and
        // can feel sluggish if not going all the way back to 0.0 prevented
        // a subsequent pull-to-refresh from starting.
        if (latestIndicatorBoxExtent >
            widget.loadTriggerPullDistance * _inactiveResetOverscrollFraction) {
          return LoadMode.done;
        } else {
          nextState = LoadMode.inactive;
        }
        break;
      case LoadMode.loaded:
        nextState = loadState;
        break;
      default:
        break;
    }

    return nextState;
  }

  @override
  Widget build(BuildContext context) {
    return _EasyRefreshSliverLoad(
      loadIndicatorLayoutExtent: widget.loadIndicatorExtent,
      hasLayoutExtent: hasSliverLayoutExtent,
      enableInfiniteLoad: widget.enableInfiniteLoad,
      infiniteLoad: _infiniteLoad,
      extraExtentNotifier: extraExtentNotifier,
      footerFloat: widget.footerFloat,
      axisDirectionNotifier: _axisDirectionNotifier,
      // A LayoutBuilder lets the sliver's layout changes be fed back out to
      // its owner to trigger state changes.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // 是否为垂直方向
          bool isVertical =
              _axisDirectionNotifier.value == AxisDirection.down ||
                  _axisDirectionNotifier.value == AxisDirection.up;
          // 是否反向
          bool isReverse = _axisDirectionNotifier.value == AxisDirection.up ||
              _axisDirectionNotifier.value == AxisDirection.left;
          latestIndicatorBoxExtent =
              (isVertical ? constraints.maxHeight : constraints.maxWidth) -
                  extraExtentNotifier.value;
          loadState = transitionNextState();
          // 列表未占满时恢复一下状态
          if (extraExtentNotifier.value > 0.0 &&
              loadState == LoadMode.loaded &&
              loadTask == null) {
            loadState = LoadMode.inactive;
          }
          if (widget.builder != null && latestIndicatorBoxExtent >= 0) {
            Widget child = widget.builder(
              context,
              loadState,
              latestIndicatorBoxExtent,
              widget.loadTriggerPullDistance,
              widget.loadIndicatorExtent,
              _axisDirectionNotifier.value,
              widget.footerFloat,
              widget.completeDuration,
              widget.enableInfiniteLoad,
              _success ?? true,
              _noMore ?? false,
            );
            // 顶出列表未占满多余部分
            return isVertical
                ? Column(
                    children: <Widget>[
                      isReverse
                          ? SizedBox()
                          : Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                      Container(
                        height: latestIndicatorBoxExtent,
                        child: child,
                      ),
                      !isReverse
                          ? SizedBox()
                          : Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                    ],
                  )
                : Row(
                    children: <Widget>[
                      isReverse
                          ? SizedBox()
                          : Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                      Container(
                        width: latestIndicatorBoxExtent,
                        child: child,
                      ),
                      !isReverse
                          ? SizedBox()
                          : Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                    ],
                  );
          }
          return Container();
        },
      ),
    );
  }
}
