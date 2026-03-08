part of '../easy_refresh.dart';

/// EasyRefresh child builder.
/// Provide [ScrollPhysics], and use it in your [ScrollView].
/// [ScrollPhysics] will not be scoped.
typedef ERChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics);

typedef ERScrollBehaviorBuilder = ScrollBehavior Function(
    ScrollPhysics? physics);

/// EasyRefresh needs to share data
class EasyRefreshData {
  /// Header status data and responsive
  final HeaderNotifier headerNotifier;

  /// Footer status data and responsive
  final FooterNotifier footerNotifier;

  /// Whether the user scrolls and responsive
  final ValueNotifier<bool> userOffsetNotifier;

  const EasyRefreshData({
    required this.headerNotifier,
    required this.footerNotifier,
    required this.userOffsetNotifier,
  });
}

/// EasyRefresh inherited widget.
class _InheritedEasyRefresh extends InheritedWidget {
  final EasyRefreshData data;

  const _InheritedEasyRefresh({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedEasyRefresh oldWidget) =>
      data != oldWidget.data;
}

/// A flutter widget that provides pull-down refresh and pull-up load.
class EasyRefresh extends StatefulWidget {
  /// Try to avoid including multiple ScrollViews.
  /// Or set separate ScrollPhysics for other ScrollView.
  /// Otherwise use [EasyRefresh.builder].
  final Widget? child;

  /// EasyRefresh controller.
  final EasyRefreshController? controller;

  /// Header indicator.
  final Header? header;

  /// Footer indicator.
  final Footer? footer;

  /// Overscroll behavior when [onRefresh] is null.
  /// Won't build widget.
  final NotRefreshHeader? notRefreshHeader;

  /// Overscroll behavior when [onLoad] is null.
  /// Won't build widget.
  final NotLoadFooter? notLoadFooter;

  /// EasyRefresh child builder.
  /// Provide [ScrollPhysics], and use it in your [ScrollView].
  /// [ScrollPhysics] will not be scoped.
  final ERChildBuilder? childBuilder;

  /// Refresh callback.
  /// Triggered on refresh.
  /// When null, disable refresh.
  /// The Header current state is [IndicatorMode.processing].
  /// More see [IndicatorNotifier._onTask].
  /// The return value can be [IndicatorResult],
  /// the default processing result is [IndicatorResult.success],
  /// and [IndicatorResult.fail] when an exception occurs.
  /// When [EasyRefreshController.controlFinishRefresh] is true,
  /// the return value is invalid.
  final FutureOr Function()? onRefresh;

  /// Load callback.
  /// Triggered on load.
  /// When null, disable load.
  /// The Footer current state is [IndicatorMode.processing].
  /// More see [IndicatorNotifier._onTask].
  /// The return value can be [IndicatorResult],
  /// the default processing result is [IndicatorResult.success],
  /// and [IndicatorResult.fail] when an exception occurs.
  /// When [EasyRefreshController.controlFinishLoad] is true,
  /// the return value is invalid.
  final FutureOr Function()? onLoad;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final physics.SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Refresh and load can be performed simultaneously.
  final bool simultaneously;

  /// Is it possible to refresh after there is no more.
  final bool canRefreshAfterNoMore;

  /// Is it possible to load after there is no more.
  final bool canLoadAfterNoMore;

  /// Reset after refresh when no more deactivation is loaded.
  final bool resetAfterRefresh;

  /// Refresh on start.
  /// When the EasyRefresh build is complete, trigger the refresh.
  final bool refreshOnStart;

  /// Header for refresh on start.
  /// Use [header] when null.
  final Header? refreshOnStartHeader;

  /// Offset beyond trigger offset when calling refresh.
  /// Used when refreshOnStart is true and [EasyRefreshController.callRefresh].
  final double callRefreshOverOffset;

  /// Offset beyond trigger offset when calling load.
  /// Used when [EasyRefreshController.callLoad].
  final double callLoadOverOffset;

  /// See [Stack.StackFit]
  final StackFit fit;

  /// See [Stack.clipBehavior].
  final Clip clipBehavior;

  /// Use [ERScrollBehavior] by default.
  ///
  /// example:
  /// ```dart
  /// EasyRefresh(
  ///   scrollBehaviorBuilder: (ScrollPhysics? physics) {
  ///     return YourCustomScrollBehavior(physics);
  ///   }
  /// )
  /// ```
  final ERScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// When the position cannot be determined, such as [NestedScrollView].
  /// Mainly used to trigger events.
  /// NOTE: You also need to bind this to your [Scrollable.controller].
  final ScrollController? scrollController;

  /// Direction of execution.
  /// Other scroll directions will not show indicators and perform task.
  final Axis? triggerAxis;

  /// Use false by default.
  /// When true, EasyRefresh handles NestedScrollView.
  /// In versions 3.4.0 and earlier, no setting is required.
  /// Because of automatic judgment, it will add burden to scenes that do not
  /// need NestedScrollView.
  final bool isNested;

  /// Default header indicator.
  static Header Function() defaultHeaderBuilder = _defaultHeaderBuilder;

  static Header _defaultHeaderBuilder() => const ClassicHeader();

  static Header get _defaultHeader => defaultHeaderBuilder.call();

  /// Default footer indicator.
  static Footer Function() defaultFooterBuilder = _defaultFooterBuilder;

  static Footer _defaultFooterBuilder() => const ClassicFooter();

  static Footer get _defaultFooter => defaultFooterBuilder.call();

  /// Default ScrollBehavior builder.
  static ScrollBehavior Function(ScrollPhysics? physics)
      defaultScrollBehaviorBuilder = _defaultScrollBehaviorBuilder;

  static ScrollBehavior _defaultScrollBehaviorBuilder(ScrollPhysics? physics) =>
      ERScrollBehavior(physics);

  const EasyRefresh({
    super.key,
    required this.child,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
  })  : childBuilder = null,
        assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  const EasyRefresh.builder({
    super.key,
    required this.childBuilder,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
  })  : child = null,
        assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  @override
  State<StatefulWidget> createState() => _EasyRefreshState();

  static EasyRefreshData of(BuildContext context) {
    final inheritedEasyRefresh =
        context.dependOnInheritedWidgetOfExactType<_InheritedEasyRefresh>();
    assert(inheritedEasyRefresh != null,
        'Please use it in the scope of EasyRefresh!');
    return inheritedEasyRefresh!.data;
  }
}

/// EasyRefresh widget state.
class _EasyRefreshState extends State<EasyRefresh>
    with TickerProviderStateMixin {
  /// [ScrollPhysics] use it in EasyRefresh.
  late _ERScrollPhysics _physics;

  /// Needs to share data.
  late EasyRefreshData _data;

  /// User triggered notifier.
  /// Record user triggers and releases.
  ValueNotifier<bool> get _userOffsetNotifier => _data.userOffsetNotifier;

  /// Header indicator notifier.
  HeaderNotifier get _headerNotifier => _data.headerNotifier;

  /// Footer indicator notifier.
  FooterNotifier get _footerNotifier => _data.footerNotifier;

  /// Whether the current is refresh on start.
  bool _isRefreshOnStart = false;

  /// Indicator waiting for refresh task to complete.
  bool get _waitRefreshResult =>
      !(widget.controller?.controlFinishRefresh ?? false);

  /// Indicator waiting for load task to complete.
  bool get _waitLoadResult => !(widget.controller?.controlFinishLoad ?? false);

  /// Use [EasyRefresh._defaultHeader] without [EasyRefresh.header].
  /// Use [NotRefreshHeader] when [EasyRefresh.onRefresh] is null.
  Header get _header {
    if (widget.onRefresh == null) {
      if (widget.notRefreshHeader != null) {
        return widget.notRefreshHeader!;
      } else {
        final h = widget.header ?? EasyRefresh._defaultHeader;
        return NotRefreshHeader(
          clamping: h.clamping,
          position: h.position,
          spring: h.spring,
          frictionFactor: h.frictionFactor,
          hitOver: h.hitOver,
          maxOverOffset: h.maxOverOffset,
        );
      }
    } else {
      Header h = widget.header ?? EasyRefresh._defaultHeader;
      if (_isRefreshOnStart) {
        h = OverrideHeader(
          header: widget.refreshOnStartHeader ?? h,
          triggerWhenReach: true,
        );
      }
      return h;
    }
  }

  /// Use [EasyRefresh._defaultFooter] without [EasyRefresh.footer].
  /// Use [NotLoadFooter] when [EasyRefresh.onLoad] is null.
  Footer get _footer {
    if (widget.onLoad == null) {
      if (widget.notLoadFooter != null) {
        return widget.notLoadFooter!;
      } else {
        final f = widget.footer ?? EasyRefresh._defaultFooter;
        return NotLoadFooter(
          clamping: f.clamping,
          position: f.position,
          spring: f.spring,
          frictionFactor: f.frictionFactor,
          hitOver: f.hitOver,
          maxOverOffset: f.maxOverOffset,
        );
      }
    } else {
      return widget.footer ?? EasyRefresh._defaultFooter;
    }
  }

  @override
  void initState() {
    super.initState();
    // Refresh on start.
    if (widget.refreshOnStart && widget.onRefresh != null) {
      _isRefreshOnStart = true;
      Future(() {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _callRefresh(
            overOffset: widget.callRefreshOverOffset,
            duration: null,
          );
        });
      });
    }
    _initData();
    widget.controller?._bind(this);
  }

  @override
  void didUpdateWidget(covariant EasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update header and footer.
    _headerNotifier._update(
      indicator: _header,
      canProcessAfterNoMore: widget.canRefreshAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: _onRefresh,
      waitTaskRefresh: _waitRefreshResult,
      isNested: widget.isNested,
    );
    _footerNotifier._update(
      indicator: _footer,
      canProcessAfterNoMore: widget.canLoadAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: widget.onLoad,
      waitTaskRefresh: _waitLoadResult,
      isNested: widget.isNested,
    );
    // Update controller.
    if (widget.controller != null &&
        oldWidget.controller != widget.controller) {
      widget.controller?._bind(this);
    }
  }

  @override
  void dispose() {
    _headerNotifier.dispose();
    _footerNotifier.dispose();
    _userOffsetNotifier.dispose();
    super.dispose();
  }

  /// Initialize [EasyRefreshData].
  void _initData() {
    final userOffsetNotifier = ValueNotifier<bool>(false);
    _data = EasyRefreshData(
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: HeaderNotifier(
        header: _header,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onRefresh: _onRefresh,
        canProcessAfterNoMore: widget.canRefreshAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitRefreshResult: _waitRefreshResult,
        onCanRefresh: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_footerNotifier._processing;
          }
        },
      ),
      footerNotifier: FooterNotifier(
        footer: _footer,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onLoad: widget.onLoad,
        canProcessAfterNoMore: widget.canLoadAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitLoadResult: _waitLoadResult,
        onCanLoad: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_headerNotifier._processing && !_isRefreshOnStart;
          }
        },
      ),
    );
    _physics = _ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
    );
  }

  /// Refresh on start listener.
  /// From [IndicatorMode.processing] to [IndicatorMode.inactive].
  /// When back to inactive, end listening.
  void _refreshOnStartListener() {
    if (_headerNotifier._mode == IndicatorMode.inactive) {
      _isRefreshOnStart = false;
      _headerNotifier.removeListener(_refreshOnStartListener);
      _headerNotifier._update(
        indicator: _header,
        task: _onRefresh,
      );
    }
  }

  /// Refresh callback.
  /// Handle [EasyRefresh.resetAfterRefresh].
  FutureOr Function()? get _onRefresh {
    if (widget.onRefresh == null) {
      return null;
    }
    return () async {
      // Start listening on refresh.
      if (_isRefreshOnStart) {
        _headerNotifier.addListener(_refreshOnStartListener);
      }
      final res = await Future.sync(widget.onRefresh!);
      // Reset Footer state.
      if (widget.resetAfterRefresh) {
        _footerNotifier._reset();
      }
      return res;
    };
  }

  /// Automatically trigger refresh.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future _callRefresh({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    return _headerNotifier.callTask(
      overOffset: overOffset ?? widget.callRefreshOverOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController ?? widget.scrollController,
      force: force,
    );
  }

  /// Automatically trigger load.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future _callLoad({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    return _footerNotifier.callTask(
      overOffset: overOffset ?? widget.callLoadOverOffset,
      duration: duration,
      curve: curve,
      scrollController: scrollController ?? widget.scrollController,
      force: force,
    );
  }

  /// Build Header widget.
  /// When the Header [Indicator.position] is
  /// [IndicatorPosition.above] or [IndicatorPosition.above].
  Widget _buildHeaderView() {
    return ValueListenableBuilder(
      valueListenable: _headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // Physics is not initialized.
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // Axis and direction.
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // Set safe area offset.
        final safePadding = MediaQuery.of(context).padding;
        _headerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                ? safePadding.top
                : safePadding.bottom
            : axisDirection == AxisDirection.right
                ? safePadding.left
                : safePadding.right;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          child: _headerNotifier._build(context),
        );
      },
    );
  }

  /// Build Footer widget.
  /// When the Footer [Indicator.position] is
  /// [IndicatorPosition.above] or [IndicatorPosition.above].
  Widget _buildFooterView() {
    return ValueListenableBuilder(
      valueListenable: _footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // Physics is not initialized.
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // Axis and direction.
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // Set safe area offset.
        final safePadding = MediaQuery.of(context).padding;
        _footerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                ? safePadding.bottom
                : safePadding.top
            : axisDirection == AxisDirection.right
                ? safePadding.right
                : safePadding.left;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          child: _footerNotifier._build(context),
        );
      },
    );
  }

  // a builder of scroll behavior
  ERScrollBehaviorBuilder get _scrollBehaviorBuilder =>
      widget.scrollBehaviorBuilder ?? EasyRefresh.defaultScrollBehaviorBuilder;

  /// Build content widget.
  Widget _buildContent() {
    Widget child;
    if (widget.childBuilder != null) {
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(null),
        child: widget.childBuilder!(context, _physics),
      );
    } else {
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(_physics),
        child: widget.child!,
      );
    }
    return _InheritedEasyRefresh(
      data: _data,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentWidget = _buildContent();
    final List<Widget> children = [];
    final hPosition = _headerNotifier.iPosition;
    final fPosition = _footerNotifier.iPosition;
    // Set the position of widgets.
    if (hPosition == IndicatorPosition.behind) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.behind) {
      children.add(_buildFooterView());
    }
    children.add(contentWidget);
    if (hPosition == IndicatorPosition.above) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.above) {
      children.add(_buildFooterView());
    }
    if (children.length == 1) {
      children.clear();
      return contentWidget;
    }
    return ClipPath(
      clipBehavior: widget.clipBehavior,
      child: Stack(
        clipBehavior: Clip.none,
        fit: widget.fit,
        children: children,
      ),
    );
  }
}
