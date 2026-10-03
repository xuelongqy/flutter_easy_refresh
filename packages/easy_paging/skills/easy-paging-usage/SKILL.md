---
name: easy-paging-usage
description: >-
  Implement pagination with easy_paging EasyPaging and EasyPagingState, including
  refresh replacement, load append, end-of-list calculation, empty and initial
  states, custom items, and controller ownership. Use for this package's
  subclass-based pagination rather than a hand-written EasyRefresh list.
---

# EasyPaging usage

For easy_paging 4.x with easy_refresh 4.x, Flutter >=3.47 and Dart ^3.13.
Declare `easy_paging: ^4.0.0` and `easy_refresh: ^4.0.0`. The Material example
also requires `material_ui: ^1.5.0`. Import both package entrypoints: easy_refresh
does not export the separate paging package.

## Implement the actual subclass contract

- Extend `EasyPaging<DataType, ItemType>` and return
  `EasyPagingState<DataType, ItemType, YourPagingWidget>` from createState.
  Implement `count`, `getItem`, `page`, `total`, `totalPage`, and `buildItem`.
- Refresh replaces data; load appends it. Await the request before committing
  data and page counters. On failure return `IndicatorResult.fail` without
  advancing the page, so the next load retries the same page.
- `isNoMore` is false while data is null. If total is non-null it uses
  `count >= total`; otherwise it compares page and totalPage when both exist.
  Without either source of metadata, override isNoMore or return noMore when
  the API explicitly reports the end. An empty response alone is not inferred
  as noMore by the base class.
- On successful load, return null to let the base class compute noMore/success.
  An explicit IndicatorResult, including success, takes precedence over that
  calculation. After automatic refresh, the base class also sets the Footer
  to noMore when the refreshed dataset is already complete.
- An internally created controller is disposed by EasyPagingState. A supplied
  controller belongs to the caller. Manual completion flags still require
  explicit finish calls; the example uses automatic completion throughout.

## Complete pagination example

The in-memory API returns 20, 20, then 5 items. Replace fetchPage with the real
repository request; its failures leave data and page unchanged. Pull again to
retry load, or press Refresh to retry initial loading. The outer owner keeps
and disposes the supplied controller. Successful refresh alone resets noMore.

```dart
import 'package:easy_paging/easy_paging.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MaterialApp(home: PagingExample()));

Future<List<String>> fetchPage(int page) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  final start = (page - 1) * 20;
  return [
    for (var index = start; index < start + 20 && index < 45; index++)
      'Item $index',
  ];
}

class PagingExample extends StatefulWidget {
  const PagingExample({super.key});

  @override
  State<PagingExample> createState() => _PagingExampleState();
}

class _PagingExampleState extends State<PagingExample> {
  final _controller = EasyRefreshController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Paged items'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => _controller.callRefresh(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ItemsPaging(controller: _controller),
  );
}

class ItemsPaging extends EasyPaging<List<String>, String> {
  const ItemsPaging({super.key, required EasyRefreshController controller})
    : super(
        controller: controller,
        refreshOnStart: true,
        resetAfterRefresh: false,
      );

  @override
  EasyPagingState<List<String>, String, ItemsPaging> createState() =>
      _ItemsPagingState();
}

class _ItemsPagingState
    extends EasyPagingState<List<String>, String, ItemsPaging> {
  @override
  int? page;

  @override
  int get total => 45;

  @override
  int get totalPage => 3;

  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) => data![index];

  @override
  bool get enableLoad => data != null && !isEmpty;

  @override
  Header buildHeader() => const ClassicHeader(showMessage: false);

  @override
  Footer buildFooter() => const ClassicFooter(noMoreText: 'All items loaded');

  @override
  Widget buildEmptyWidget() => const Center(child: Text('No items'));

  @override
  Widget buildRefreshOnStartWidget() =>
      const Center(child: CircularProgressIndicator());

  @override
  Widget buildItem(BuildContext context, int index, String item) =>
      ListTile(title: Text(item));

  @override
  Future<IndicatorResult?> onRefresh() async {
    try {
      final firstPage = await fetchPage(1);
      if (!mounted) return IndicatorResult.fail;
      setState(() {
        data = firstPage;
        page = 1;
      });
      widget.controller?.resetFooter();
      return null;
    } catch (_) {
      return IndicatorResult.fail;
    }
  }

  @override
  Future<IndicatorResult?> onLoad() async {
    final nextPage = (page ?? 0) + 1;
    try {
      final items = await fetchPage(nextPage);
      if (!mounted) return IndicatorResult.fail;
      setState(() {
        data = [...?data, ...items];
        page = nextPage;
      });
      return null;
    } catch (_) {
      return IndicatorResult.fail;
    }
  }
}
```

`isEmpty` requires non-null data and zero count, distinguishing an empty result
from a request that has not succeeded. For an API total, store the returned
total/totalPage instead of the demo constants. Page numbering follows the API;
this example is one-based.

## Custom items, layout and initial UI

Override buildItem for each row. The widget-level itemBuilder does not remove
that abstract requirement: implement buildItem by calling buildItemByBuilder
only when an itemBuilder is supplied. Override buildSliver for a grid or other
sliver layout, and buildHeader/buildFooter for styles. Locator indicators are
inserted by the base sliver construction; do not duplicate them.

`useDefaultPhysics: false` (default) uses EasyRefresh.builder with explicit
physics. `true` uses EasyRefresh with scoped physics. The default builder path
constructs the scroll view internally; do not assume overriding buildScrollView
changes that path. Prefer buildSliver/buildItem for ordinary layout changes.
For widget-supplied empty/initial views, use emptyWidgetBuilder and
refreshOnStartWidgetBuilder instead of overriding the corresponding methods.

Keep simultaneous loading disabled unless the data layer handles competing
refresh/load responses. Verify initial success/failure, empty results, totals
and page-count termination, final short page, failed append then retry, refresh
after noMore, and disposal while fetching.
