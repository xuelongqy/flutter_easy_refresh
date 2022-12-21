import 'package:easy_refresh/easy_paging.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class PagingPage extends StatefulWidget {
  const PagingPage({Key? key}) : super(key: key);

  @override
  State<PagingPage> createState() => _PagingPageState();
}

class _PagingPageState extends State<PagingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paging example'.tr),
      ),
      body: CustomPaging(
        itemBuilder: <ItemType>(context, index, item) {
          return const SkeletonItem();
        },
      ),
    );
  }
}

class CustomPaging extends EasyPaging<List<String>, String> {
  const CustomPaging({
    Key? key,
    super.callLoadOverOffset,
    super.callRefreshOverOffset,
    super.clipBehavior,
    super.controller,
    super.fit,
    super.frictionFactor,
    super.noMoreLoad,
    super.noMoreRefresh,
    super.notLoadFooter,
    super.notRefreshHeader,
    super.refreshOnStart = true,
    super.resetAfterRefresh,
    super.simultaneously,
    super.spring,
    super.useDefaultPhysics,
    super.itemBuilder,
    super.refreshOnStartWidgetBuilder,
    super.emptyWidgetBuilder,
  }) : super(key: key);

  @override
  EasyPagingState<List<String>, String> createState() => CustomPagingState();
}

class CustomPagingState extends EasyPagingState<List<String>, String> {
  @override
  int get count => data?.length ?? 0;

  @override
  String getItem(int index) {
    return data![index];
  }

  @override
  int? page;

  @override
  int? total;

  @override
  int? totalPage;

  @override
  Widget? buildRefreshOnStartWidget() {
    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: SpinKitFadingCube(
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget? buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.only(bottom: 120),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitSpinningLines(
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text('No Data'.tr),
        ],
      ),
    );
  }

  Future<ResponseData> fetchData({
    required int page,
    int size = 10,
  }) async {
    const count = 45;
    await Future.delayed(const Duration(seconds: 2));
    int dataSize = size;
    if ((page - 1) * size >= count) {
      dataSize = 0;
    } else if ((page - 1) * size <= count - size) {
      dataSize = size;
    } else {
      dataSize = count - ((page - 1) * size);
    }
    return ResponseData(
      page: page,
      pageSize: size,
      total: count,
      data: List.filled(dataSize, ''),
    );
  }

  @override
  Future onRefresh() async {
    if (data == null) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        data = [];
        page = 0;
      });
      return;
    }
    final response = await fetchData(page: 1);
    setState(() {
      data = response.data.toList();
      total = response.total;
      page = response.page;
    });
  }

  @override
  Future onLoad() async {
    final response = await fetchData(page: page! + 1);
    setState(() {
      data!.addAll(response.data);
      total = response.total;
      page = response.page;
    });
  }
}

class ResponseData {
  final int page;
  final int pageSize;
  final int total;
  final List<String> data;

  ResponseData({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.data,
  });
}
