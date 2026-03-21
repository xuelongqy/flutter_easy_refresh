library;

import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' as physics;

/// Paging item builder.
typedef EasyPagingItemBuilder<ItemType> = Widget Function(
    BuildContext context, int index, ItemType item);

/// A flutter widget that convenient pagination.
abstract class EasyPaging<DataType, ItemType> extends StatefulWidget {
  /// When true, use [EasyRefresh];
  /// when false, use [EasyRefresh.builder].
  final bool useDefaultPhysics;

  /// EasyRefresh controller.
  final EasyRefreshController? controller;

  /// Overscroll behavior when [onRefresh] is null.
  /// Won't build widget.
  final NotRefreshHeader? notRefreshHeader;

  /// Overscroll behavior when [onLoad] is null.
  /// Won't build widget.
  final NotLoadFooter? notLoadFooter;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final physics.SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Refresh and load can be performed simultaneously.
  final bool simultaneously;

  /// Is it possible to refresh after there is no more.
  final bool canRefreshAfterNoMore;

  /// Is it loadable after no more.
  final bool canLoadAfterNoMore;

  /// Reset after refresh when no more deactivation is loaded.
  final bool resetAfterRefresh;

  /// Refresh on start.
  /// When the EasyRefresh build is complete, trigger the refresh.
  final bool refreshOnStart;

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

  /// Item builder.
  final EasyPagingItemBuilder<ItemType>? itemBuilder;

  /// Refresh on start widget builder.
  final WidgetBuilder? refreshOnStartWidgetBuilder;

  /// Empty widget builder.
  final WidgetBuilder? emptyWidgetBuilder;

  const EasyPaging({
    super.key,
    this.useDefaultPhysics = false,
    this.controller,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.refreshOnStartWidgetBuilder,
    this.emptyWidgetBuilder,
  })  : assert(callRefreshOverOffset > 0,
            'callRefreshOverOffset must be greater than 0.'),
        assert(callLoadOverOffset > 0,
            'callLoadOverOffset must be greater than 0.');

  @override
  EasyPagingState<DataType, ItemType, EasyPaging<DataType, ItemType>>
      createState();
}

abstract class EasyPagingState<DataType, ItemType,
        PagingWidget extends EasyPaging<DataType, ItemType>>
    extends State<PagingWidget> {
  /// All data.
  DataType? data;

  /// Total page.
  int? get totalPage;

  /// Current page.
  int? get page;

  /// All items count.
  int? get total;

  /// Current items count.
  int get count;

  /// Get item.
  ItemType getItem(int index);

  /// Check if there is no data.
  bool get isEmpty => data != null && count == 0;

  /// Check if there are no more.
  bool get isNoMore {
    if (data == null) {
      return false;
    }
    if (total != null) {
      return count >= total!;
    }
    if (page != null && totalPage != null) {
      return page! >= totalPage!;
    }
    return false;
  }

  /// Enable refresh.
  bool get enableRefresh => true;

  /// Enable load.
  bool get enableLoad => true;

  /// Refresh callback.
  /// Triggered on refresh.
  FutureOr<IndicatorResult?> onRefresh() => null;

  Future<IndicatorResult?> _onRefresh() async {
    final result = await onRefresh();
    if (!_refreshController.controlFinishRefresh && isNoMore) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          _refreshController.finishLoad(IndicatorResult.noMore, true);
        }
      });
    }
    if (result is IndicatorResult) {
      return result;
    }
    return null;
  }

  /// Load callback.
  /// Triggered on load.
  FutureOr<IndicatorResult?> onLoad() => null;

  Future<IndicatorResult?> _onLoad() async {
    final result = await onLoad();
    if (result is IndicatorResult) {
      return result;
    }
    if (isNoMore) {
      return IndicatorResult.noMore;
    }
    return IndicatorResult.success;
  }

  /// EasyRefresh controller.
  late EasyRefreshController _refreshController;
  bool _ownsRefreshController = false;

  @override
  void initState() {
    super.initState();
    _updateRefreshController();
  }

  @override
  void didUpdateWidget(covariant PagingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _updateRefreshController();
    }
  }

  @override
  void dispose() {
    if (_ownsRefreshController) {
      _refreshController.dispose();
    }
    super.dispose();
  }

  void _updateRefreshController() {
    if (_ownsRefreshController) {
      _refreshController.dispose();
    }
    final controller = widget.controller;
    _ownsRefreshController = controller == null;
    _refreshController = controller ?? EasyRefreshController();
  }

  /// Empty widget.
  @protected
  Widget? buildEmptyWidget() {
    return widget.emptyWidgetBuilder?.call(context);
  }

  /// Refresh on start widget.
  @protected
  Widget? buildRefreshOnStartWidget() {
    return widget.refreshOnStartWidgetBuilder?.call(context);
  }

  /// Build header.
  @protected
  Header buildHeader() => EasyRefresh.defaultHeaderBuilder();

  /// Build footer.
  @protected
  Footer buildFooter() => EasyRefresh.defaultFooterBuilder();

  /// Build scroll view.
  @protected
  Widget buildScrollView([ScrollPhysics? physics]) {
    final header = buildHeader();
    final footer = buildFooter();
    return _buildScrollView(
      header: header,
      footer: footer,
      physics: physics,
    );
  }

  @protected
  Widget _buildScrollView({
    required Header header,
    required Footer footer,
    ScrollPhysics? physics,
  }) {
    return CustomScrollView(
      physics: physics,
      slivers: _buildSlivers(
        header: header,
        footer: footer,
      ),
    );
  }

  /// Build slivers.
  @protected
  List<Widget> buildSlivers() {
    final header = buildHeader();
    final footer = buildFooter();
    return _buildSlivers(
      header: header,
      footer: footer,
    );
  }

  @protected
  List<Widget> _buildSlivers({
    required Header header,
    required Footer footer,
  }) {
    Widget? emptyWidget;
    if (isEmpty) {
      emptyWidget = buildEmptyWidget();
    }
    return [
      if (header.position == IndicatorPosition.locator)
        const HeaderLocator.sliver(),
      if (emptyWidget != null)
        SliverFillViewport(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return emptyWidget;
            },
            childCount: 1,
          ),
        ),
      buildSliver(),
      if (footer.position == IndicatorPosition.locator)
        const FooterLocator.sliver(),
    ];
  }

  /// Build sliver.
  @protected
  Widget buildSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return buildItem(context, index, getItem(index));
        },
        childCount: count,
      ),
    );
  }

  /// Build item widget with [widget.itemBuilder].
  ///
  /// Subclasses should call this helper explicitly if they choose to expose
  /// the widget-level [EasyPaging.itemBuilder] convenience.
  @protected
  Widget buildItemByBuilder(BuildContext context, int index, ItemType item) {
    final itemBuilder = widget.itemBuilder;
    assert(
      itemBuilder != null,
      'Either override buildItem with a custom implementation or provide '
      'itemBuilder before calling buildItemByBuilder.',
    );
    if (itemBuilder == null) {
      throw FlutterError(
        'Either override buildItem with a custom implementation or provide '
        'itemBuilder before calling buildItemByBuilder.',
      );
    }
    return itemBuilder(context, index, item);
  }

  /// Build item widget.
  @protected
  Widget buildItem(BuildContext context, int index, ItemType item);

  @override
  Widget build(BuildContext context) {
    final header = buildHeader();
    final footer = buildFooter();
    Header? startHeader;
    Widget? startWidget = buildRefreshOnStartWidget();
    if (startWidget != null) {
      startHeader = BuilderHeader(
        triggerOffset: 70,
        clamping: true,
        position: IndicatorPosition.above,
        processedDuration: Duration.zero,
        builder: (ctx, state) {
          if (state.mode == IndicatorMode.inactive ||
              state.mode == IndicatorMode.done) {
            return const SizedBox();
          }
          return SizedBox(
            width: state.axis == Axis.vertical
                ? double.infinity
                : state.viewportDimension,
            height: state.axis == Axis.horizontal
                ? double.infinity
                : state.viewportDimension,
            child: startWidget,
          );
        },
      );
    }
    if (widget.useDefaultPhysics) {
      return EasyRefresh(
        header: header,
        footer: footer,
        refreshOnStartHeader: startHeader,
        onRefresh: enableRefresh ? _onRefresh : null,
        onLoad: enableLoad ? _onLoad : null,
        controller: _refreshController,
        spring: widget.spring,
        frictionFactor: widget.frictionFactor,
        notRefreshHeader: widget.notRefreshHeader,
        notLoadFooter: widget.notLoadFooter,
        simultaneously: widget.simultaneously,
        canRefreshAfterNoMore: widget.canRefreshAfterNoMore,
        canLoadAfterNoMore: widget.canLoadAfterNoMore,
        resetAfterRefresh: widget.resetAfterRefresh,
        refreshOnStart: widget.refreshOnStart,
        callRefreshOverOffset: widget.callRefreshOverOffset,
        callLoadOverOffset: widget.callLoadOverOffset,
        fit: widget.fit,
        clipBehavior: widget.clipBehavior,
        child: buildScrollView(),
      );
    }
    return EasyRefresh.builder(
      header: header,
      footer: footer,
      refreshOnStartHeader: startHeader,
      onRefresh: enableRefresh ? _onRefresh : null,
      onLoad: enableLoad ? _onLoad : null,
      controller: _refreshController,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
      notRefreshHeader: widget.notRefreshHeader,
      notLoadFooter: widget.notLoadFooter,
      simultaneously: widget.simultaneously,
      canRefreshAfterNoMore: widget.canRefreshAfterNoMore,
      canLoadAfterNoMore: widget.canLoadAfterNoMore,
      resetAfterRefresh: widget.resetAfterRefresh,
      refreshOnStart: widget.refreshOnStart,
      callRefreshOverOffset: widget.callRefreshOverOffset,
      callLoadOverOffset: widget.callLoadOverOffset,
      fit: widget.fit,
      clipBehavior: widget.clipBehavior,
      childBuilder: (context, physics) {
        return _buildScrollView(
          header: header,
          footer: footer,
          physics: physics,
        );
      },
    );
  }
}
