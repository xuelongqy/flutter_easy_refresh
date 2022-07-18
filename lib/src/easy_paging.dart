part of easy_paging;

/// A flutter widget that convenient pagination.
abstract class EasyPaging<DataType, ItemType> extends StatefulWidget {
  /// When true, use [EasyRefresh];
  /// when false, use [EasyRefresh.builder].
  final bool useDefaultPhysics;

  const EasyPaging({
    Key? key,
    this.useDefaultPhysics = false,
  }) : super(key: key);

  @override
  EasyPagingState<DataType, ItemType> createState();
}

abstract class EasyPagingState<DataType, ItemType> extends State<EasyPaging> {
  /// All data.
  DataType? data;

  /// Total page.
  int? get totalPage;

  /// Current page.
  int? get page;

  /// Total count.
  int? get totalCount;

  /// Current items count.
  int get count;

  /// Get item.
  ItemType getItem(int index);

  /// Check if there is no data.
  bool get isEmpty => count == 0;

  /// Check if there are no more.
  bool get isNoMore => false;

  /// Enable refresh.
  bool get enableRefresh => true;

  /// Enable load.
  bool get enableLoad => true;

  /// Refresh callback.
  /// Triggered on refresh.
  Future onRefresh() async {}

  Future _onRefresh() async {
    final result = await onRefresh();
    if (result is IndicatorResult) {
      return result;
    }
  }

  /// Load callback.
  /// Triggered on load.
  Future onLoad() async {}

  Future _onLoad() async {
    final result = await onLoad();
    if (result is IndicatorResult) {
      return result;
    }
    if (isNoMore) {
      return IndicatorResult.noMore;
    }
    return IndicatorResult.success;
  }

  /// Empty widget.
  Widget? buildEmptyWidget() => null;

  /// Build header.
  Header buildHeader() => EasyRefresh.defaultHeaderBuilder();

  /// Build footer.
  Footer buildFooter() => EasyRefresh.defaultFooterBuilder();

  /// Build scroll view.
  Widget buildScrollView([ScrollPhysics? physics]) {
    return CustomScrollView(
      physics: physics,
      slivers: buildSlivers(),
    );
  }

  /// Build slivers.
  List<Widget> buildSlivers() {
    final header = buildHeader();
    final footer = buildFooter();
    Widget? emptyWidget;
    if (isEmpty) {
      emptyWidget = buildEmptyWidget();
    }
    return [
      if (header.position == IndicatorPosition.locator)
        const HeaderLocator.sliver(),
      if (emptyWidget != null)
        SliverToBoxAdapter(
          child: emptyWidget,
        ),
      buildSliver(),
      if (footer.position == IndicatorPosition.locator)
        const FooterLocator.sliver(),
    ];
  }

  /// Build sliver.
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

  /// Build item widget.
  Widget buildItem(BuildContext context, int index, ItemType item);

  @override
  Widget build(BuildContext context) {
    final header = buildHeader();
    final footer = buildFooter();
    if (widget.useDefaultPhysics) {
      return EasyRefresh(
        resetAfterRefresh: true,
        header: header,
        footer: footer,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        child: buildScrollView(),
      );
    }
    return EasyRefresh.builder(
      resetAfterRefresh: true,
      header: header,
      footer: footer,
      onRefresh: _onRefresh,
      onLoad: _onLoad,
      childBuilder: (context, physics) {
        return buildScrollView(physics);
      },
    );
  }
}
