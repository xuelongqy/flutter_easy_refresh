# easy_paging

Pagination widgets built on top of easy_refresh.

## Requirements and dependencies

For Flutter >=3.47 and Dart ^3.13. The example uses these direct dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  easy_paging: ^4.0.0
  easy_refresh: ^4.0.0
  material_ui: ^1.5.0
```

## What it provides

- `EasyPaging<DataType, ItemType>` and `EasyPagingState<DataType, ItemType, PagingWidget>`.
- Refresh replacement, load append, initial and empty-state views.
- End-of-list calculation using total first, otherwise page/totalPage.
- Custom items, slivers and Header/Footer styles.
- Internal controller ownership or a caller-owned external controller.

## Complete example

Return null after a successful load to use the base class's noMore calculation;
an explicit IndicatorResult takes precedence. Requests commit data and page only
after success, so failed loads retry the same page. The caller owns the supplied
controller. Refresh resets the Footer only on success.

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

## AI agent skill

[Pagination usage](skills/easy-paging-usage/SKILL.md) covers subclassing, completion,
layout customization, empty states, failures and controller lifetime.
Run this in your app after adding the package:

```sh
dart run skills@ get
```
