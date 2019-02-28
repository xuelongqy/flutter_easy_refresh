# FAQ

## 1.Header and Footer have jump problems after success

This is because you don't set keys for Headers and Footers, because EasyRefresh updates the status of Headers and Footers.
If the key is not set, the state cannot be recorded and initialized, resulting in a jump.

Sample code
~~~dart
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
  ....
    refreshHeader: MaterialHeader(
        key: _headerKey,
    ),
    refreshFooter: MaterialFooter(
        key: _footerKey,
    ),
  ....
~~~

## 2.CustomScrollView and the use of folded heads

If you use CustomScrollView directly, there may always be hints that no more data is available, even if new data is loaded.
This is because CustomScrollView does not automatically maintain semanticChildCount, so we need to maintain it ourselves.
Fold the head in Custom ScrollView using SliverAppBar.

Sample code, complete example[SliverPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sliver_page.dart)
~~~dart
  CustomScrollView(
    // Manual maintenance of semanticChildCount to determine whether there is no more data
    semanticChildCount: str.length,
    slivers: <Widget>[
      SliverAppBar(
        floating: false,
        pinned: true,
        expandedHeight: 180.0,
        flexibleSpace: FlexibleSpaceBar(
          title: Text("CustomScrollView"),
        ),
      ),
      SliverPadding(....)
    ]
  )
~~~

## 3.Using libraries such as flutter_swiper, sliding conflicts occur

This is because UI components in these libraries trigger sliding events, leading to sliding conflicts.
Use RefreshSafeArea encapsulation, which will not change your interface.

Sample code, complete example[SwiperPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/swiper_page.dart)
~~~dart
  RefreshSafeArea(
    child: Swiper(
      itemBuilder: (BuildContext context, int index) {
        return _createMarqueeCard(index);
      },
      itemCount: 5,
      viewportFraction: 0.8,
      scale: 0.9,
      autoplay: true,
    ),
  );
~~~

## 4.Refresh or load ends immediately

This is because EasyRefresh will start the completion callback after the onRefresh or loadMore methods are executed. If there is an asynchronous operation in the method,
It means that the asynchronous operation time will not be calculated, so you need to add the await keyword.

Sample code
~~~dart
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 2), () {});
    },
    loadMore: () async {
      await Future.delayed(const Duration(seconds: 2), () {});
    },
~~~

## 5.Setting reverse is not supported at this time

Due to the design principle of EasyRefresh, there is currently no support for reverse. I don't think you will use it often.

## 6.outerController is not a list of ScrollController

The outerController current role is to be compatible with the NestedScrollView. If you need a ScrollController, you can set it directly to the list.
