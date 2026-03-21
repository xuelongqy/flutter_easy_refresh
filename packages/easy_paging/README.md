# easy_paging

Pagination widgets built on top of `easy_refresh`.

## Install

[![Pub](https://img.shields.io/pub/v/easy_paging)](https://pub.dev/packages/easy_paging)

## Import

```dart
import 'package:easy_paging/easy_paging.dart';
import 'package:easy_refresh/easy_refresh.dart';
```

## What It Provides

- `EasyPaging<DataType, ItemType>`
- `EasyPagingState<DataType, ItemType>`
- Automatic integration with `EasyRefresh` refresh/load lifecycle
- `isNoMore` calculation by `total` or `page/totalPage`
- Optional locator-mode slivers through the underlying `easy_refresh` indicators

## Minimal Example

```dart
class CustomPaging extends EasyPaging<List<String>, String> {
  const CustomPaging({super.key});

  @override
  EasyPagingState<List<String>, String, CustomPaging> createState() =>
      _CustomPagingState();
}

class _CustomPagingState
    extends EasyPagingState<List<String>, String, CustomPaging> {
  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) => data![index];

  @override
  int? page;

  @override
  int? total;

  @override
  int? totalPage;

  @override
  Widget buildItem(BuildContext context, int index, String item) {
    return ListTile(title: Text(item));
  }

  @override
  Future onRefresh() async {
    setState(() {
      data = List.generate(10, (index) => 'Item $index');
      total = 30;
      page = 1;
    });
  }

  @override
  Future onLoad() async {
    final nextPage = page! + 1;
    setState(() {
      data!.addAll(List.generate(10, (index) => 'Item ${data!.length + index}'));
      page = nextPage;
    });
  }
}
```

## Example

- Workspace demo: `example/lib/page/sample/paging_page.dart`
