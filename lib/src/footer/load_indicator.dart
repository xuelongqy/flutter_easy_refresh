// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../listener/scroll_notification_listener.dart';

class _EasyRefreshSliverLoad extends SingleChildRenderObjectWidget {
  const _EasyRefreshSliverLoad({
    Key key,
    this.loadIndicatorLayoutExtent = 0.0,
    this.hasLayoutExtent = false,
    Widget child,
  }) : assert(loadIndicatorLayoutExtent != null),
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

  @override
  _RenderEasyRefreshSliverLoad createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverLoad(
      loadIndicatorExtent: loadIndicatorLayoutExtent,
      hasLayoutExtent: hasLayoutExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _RenderEasyRefreshSliverLoad renderObject) {
    renderObject
      ..loadIndicatorLayoutExtent = loadIndicatorLayoutExtent
      ..hasLayoutExtent = hasLayoutExtent;
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
    RenderBox child,
  }) : assert(loadIndicatorExtent != null),
        assert(loadIndicatorExtent >= 0.0),
        assert(hasLayoutExtent != null),
        _loadIndicatorExtent = loadIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  // The amount of layout space the indicator should occupy in the sliver in a
  // resting state when in the refreshing mode.
  double get loadIndicatorLayoutExtent => _loadIndicatorExtent;
  double _loadIndicatorExtent;
  set loadIndicatorLayoutExtent(double value) {
    assert(value != null);
    assert(value >= 0.0);
    if (value == _loadIndicatorExtent)
      return;
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
    if (value == _hasLayoutExtent)
      return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

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
    // Only pulling to refresh from the top is currently supported.
    // 注释以支持reverse
    // assert(constraints.axisDirection == AxisDirection.down);
    assert(constraints.growthDirection == GrowthDirection.forward);

    // The new layout extent this sliver should now have.
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _loadIndicatorExtent;
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

    final bool active = constraints.remainingPaintExtent > 0.0 || layoutExtent > 0.0;
    final double overscrolledExtent =
    constraints.remainingPaintExtent > 0.0 ? constraints.remainingPaintExtent.abs() : 0.0;
    // Layout the child giving it the space of the currently dragged overscroll
    // which may or may not include a sliver layout extent space that it will
    // keep after the user lets go during the refresh process.
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: overscrolledExtent,
      ),
      parentUsesSize: true,
    );
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: layoutExtent,
        paintOrigin: - constraints.scrollOffset,
        paintExtent: max(
          // Check child size (which can come from overscroll) because
          // layoutExtent may be zero. Check layoutExtent also since even
          // with a layoutExtent, the indicator builder may decide to not
          // build anything.
          min(max(childSize, layoutExtent),
              constraints.remainingPaintExtent) - constraints.scrollOffset,
          0.0,
        ),
        maxPaintExtent: max(
          min(max(childSize, layoutExtent),
              constraints.remainingPaintExtent) - constraints.scrollOffset,
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
  void applyPaintTransform(RenderObject child, Matrix4 transform) { }
}

/// The current state of the refresh control.
///
/// Passed into the [LoadControlIndicatorBuilder] builder function so
/// users can show different UI in different modes.
enum LoadIndicatorMode {
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

  /// 没有数据
  nodata,

  /// 刷新失败
  failed,

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
typedef LoadControlIndicatorBuilder = Widget Function(
    BuildContext context,
    LoadIndicatorMode loadState,
    double pulledExtent,
    double loadTriggerPullDistance,
    double loadIndicatorExtent,
    );

/// A callback function that's invoked when the [EasyRefreshSliverLoadControl] is
/// pulled a `loadTriggerPullDistance`. Must return a [Future]. Upon
/// completion of the [Future], the [EasyRefreshSliverLoadControl] enters the
/// [LoadIndicatorMode.done] state and will start to go away.
typedef LoadCallback = Future<void> Function();

/// 结束加载
/// success 为是否成功(为false时，nodata无效)
/// nodata 为是否有更多数据
typedef FinishLoad = void Function({
  bool success,
  bool nodata,
});

/// 绑定加载指示剂
typedef BindLoadIndicator = void Function(FinishLoad finishLoad,
    ScrollFocusCallback onFocus);

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
/// The [builder] function will be informed of the current [LoadIndicatorMode]
/// when invoking it, except in the [LoadIndicatorMode.inactive] state when
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
    this.loadTriggerPullDistance = _defaultloadTriggerPullDistance,
    this.loadIndicatorExtent = _defaultloadIndicatorExtent,
    @required this.builder,
    this.completeDuration,
    this.onLoad,
    this.bindLoadIndicator,
    this.enableControlFinishLoad = false,
    this.enableHapticFeedback = false,
  }) : assert(loadTriggerPullDistance != null),
        assert(loadTriggerPullDistance > 0.0),
        assert(loadIndicatorExtent != null),
        assert(loadIndicatorExtent >= 0.0),
        assert(
        loadTriggerPullDistance >= loadIndicatorExtent,
        'The refresh indicator cannot take more space in its final state '
            'than the amount initially created by overscrolling.'
        ),
        super(key: key);

  /// The amount of overscroll the scrollable must be dragged to trigger a reload.
  ///
  /// Must not be null, must be larger than 0.0 and larger than
  /// [loadIndicatorExtent]. Defaults to 100px when not specified.
  ///
  /// When overscrolled past this distance, [onLoad] will be called if not
  /// null and the [builder] will build in the [LoadIndicatorMode.armed] state.
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
  final LoadControlIndicatorBuilder builder;

  /// Callback invoked when pulled by [loadTriggerPullDistance].
  ///
  /// If provided, must return a [Future] which will keep the indicator in the
  /// [LoadIndicatorMode.refresh] state until the [Future] completes.
  ///
  /// Can be null, in which case a single frame of [LoadIndicatorMode.armed]
  /// state will be drawn before going immediately to the [LoadIndicatorMode.done]
  /// where the sliver will start retracting.
  final LoadCallback onLoad;
  
  /// 完成延时
  final Duration completeDuration;

  /// 绑定加载指示器
  final BindLoadIndicator bindLoadIndicator;

  /// 是否开启控制结束
  final enableControlFinishLoad;

  /// 开启震动反馈
  final enableHapticFeedback;

  static const double _defaultloadTriggerPullDistance = 100.0;
  static const double _defaultloadIndicatorExtent = 60.0;

  /// Retrieve the current state of the EasyRefreshSliverLoadControl. The same as the
  /// state that gets passed into the [builder] function. Used for testing.
  @visibleForTesting
  static LoadIndicatorMode state(BuildContext context) {
    final _EasyRefreshSliverLoadControlState state
    = context.ancestorStateOfType(const TypeMatcher<_EasyRefreshSliverLoadControlState>());
    return state.loadState;
  }

  @override
  _EasyRefreshSliverLoadControlState createState() => _EasyRefreshSliverLoadControlState();
}

class _EasyRefreshSliverLoadControlState extends State<EasyRefreshSliverLoadControl> {
  // Reset the state from done to inactive when only this fraction of the
  // original `loadTriggerPullDistance` is left.
  static const double _inactiveResetOverscrollFraction = 0.1;

  LoadIndicatorMode loadState;
  // [Future] returned by the widget's `onLoad`.
  Future<void> refreshTask;
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
  bool _focus = false;
  // 刷新完成
  bool _success;
  // 没有更多数据
  bool _nodata;

  @override
  void initState() {
    super.initState();
    loadState = LoadIndicatorMode.inactive;
    // 绑定加载指示器
    if (widget.bindLoadIndicator != null) {
      widget.bindLoadIndicator(finishLoad, onFocus);
    }
  }

  // 完成刷新
  void finishLoad({
    bool success = true,
    bool nodata = false,
  }) {
    _success = success;
    _nodata = nodata;
    if (widget.enableControlFinishLoad) {
      setState(() => refreshTask = null);
      loadState = transitionNextState();
    }
  }

  // 滚动焦点变化
  void onFocus(bool focus) {
    _focus = focus;
  }

  // A state machine transition calculator. Multiple states can be transitioned
  // through per single call.
  LoadIndicatorMode transitionNextState() {
    LoadIndicatorMode nextState;

    void goToDone() {
      nextState = LoadIndicatorMode.done;
      loadState = LoadIndicatorMode.done;
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

    switch (loadState) {
      case LoadIndicatorMode.inactive:
        if (latestIndicatorBoxExtent <= 0 || !_focus) {
          return LoadIndicatorMode.inactive;
        } else {
          nextState = LoadIndicatorMode.drag;
        }
        continue drag;
      drag:
      case LoadIndicatorMode.drag:
        if (latestIndicatorBoxExtent == 0) {
          return LoadIndicatorMode.inactive;
        } else if (latestIndicatorBoxExtent < widget.loadTriggerPullDistance) {
          return LoadIndicatorMode.drag;
        } else {
          if (widget.onLoad != null) {
            if (!_focus) {
              if (widget.enableHapticFeedback) {
                HapticFeedback.mediumImpact();
              }
              // Call onLoad after this frame finished since the function is
              // user supplied and we're always here in the middle of the sliver's
              // performLayout.
              SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
                refreshTask = widget.onLoad()..then((_) {
                  if (mounted && !widget.enableControlFinishLoad) {
                    setState(() => refreshTask = null);
                    // Trigger one more transition because by this time, BoxConstraint's
                    // maxHeight might already be resting at 0 in which case no
                    // calls to [transitionNextState] will occur anymore and the
                    // state may be stuck in a non-inactive state.
                    loadState = transitionNextState();
                  }
                });
                setState(() => hasSliverLayoutExtent = true);
              });
              return LoadIndicatorMode.armed;
            }
            return LoadIndicatorMode.drag;
          }
        }
        // Don't continue here. We can never possibly call onLoad and
        // progress to the next state in one [computeNextState] call.
        break;
      case LoadIndicatorMode.armed:
        if (loadState == LoadIndicatorMode.armed && refreshTask == null) {
          // 判断加载完成
          LoadIndicatorMode state;
          if (_success != false && _nodata == true) {
            state = LoadIndicatorMode.nodata;
          } else if (_success == false) {
            state = LoadIndicatorMode.failed;
          } else {
            state = LoadIndicatorMode.loaded;
          }
          // 添加延时
          if (widget.completeDuration == null) {
            // 记录一个状态
            widget.builder(
              context,
              state,
              latestIndicatorBoxExtent,
              widget.loadTriggerPullDistance,
              widget.loadIndicatorExtent,
            );
            goToDone();
          } else {
            Future.delayed(widget.completeDuration, (){
              if (mounted) {
                goToDone();
              }
            });
            return state;
          }
          continue done;
        }

        if (latestIndicatorBoxExtent > widget.loadIndicatorExtent) {
          return LoadIndicatorMode.armed;
        } else {
          nextState = LoadIndicatorMode.load;
        }
        continue refresh;
      refresh:
      case LoadIndicatorMode.load:
        if (refreshTask != null) {
          return LoadIndicatorMode.load;
        } else {
          // 判断加载完成
          LoadIndicatorMode state;
          if (_success != false && _nodata == true) {
            state = LoadIndicatorMode.nodata;
          } else if (_success == false) {
            state = LoadIndicatorMode.failed;
          } else {
            state = LoadIndicatorMode.loaded;
          }
          // 添加延时
          if (widget.completeDuration == null) {
            // 记录一个状态
            widget.builder(
              context,
              state,
              latestIndicatorBoxExtent,
              widget.loadTriggerPullDistance,
              widget.loadIndicatorExtent,
            );
            goToDone();
          } else {
            Future.delayed(widget.completeDuration, (){
              if (mounted) {
                goToDone();
              }
            });
            return state;
          }
        }
        continue done;
      done:
      case LoadIndicatorMode.done:
      // Let the transition back to inactive trigger before strictly going
      // to 0.0 since the last bit of the animation can take some time and
      // can feel sluggish if not going all the way back to 0.0 prevented
      // a subsequent pull-to-refresh from starting.
        if (latestIndicatorBoxExtent >
            widget.loadTriggerPullDistance * _inactiveResetOverscrollFraction) {
          return LoadIndicatorMode.done;
        } else {
          nextState = LoadIndicatorMode.inactive;
        }
        break;
      case LoadIndicatorMode.loaded:
        nextState = loadState;
        break;
      case LoadIndicatorMode.nodata:
        nextState = loadState;
        break;
      case LoadIndicatorMode.failed:
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
      // A LayoutBuilder lets the sliver's layout changes be fed back out to
      // its owner to trigger state changes.
      child: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              latestIndicatorBoxExtent = orientation == Orientation.landscape
                  ? constraints.maxHeight : constraints.maxWidth;
              loadState = transitionNextState();
              if (widget.builder != null && latestIndicatorBoxExtent > 0) {
                return widget.builder(
                  context,
                  loadState,
                  latestIndicatorBoxExtent,
                  widget.loadTriggerPullDistance,
                  widget.loadIndicatorExtent,
                );
              }
              return Container();
            },
          );
        },
      ),
    );
  }
}
