# 常见问题

## 1.Header和Footer在成功后出现跳动问题

这是因为你没有给Header和Footer设置key，因为EasyRefresh会更新Header和Footer的状态。
如果没有设置key，会导致无法记录状态而被被初始化，出现跳动的情况。

示例代码
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

## 2.CustomScrollView以及折叠头部使用的问题

如果你直接使用了CustomScrollView，可能会一直出现没有更多数据的提示，即使加载出了新的数据。
这是因为CustomScrollView不会自动维护semanticChildCount，所以我们需要自己去维护。
折叠头部在CustomScrollView中使用SliverAppBar即可。

示例代码，完整示例[SliverPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/sliver_page.dart)
~~~dart
  CustomScrollView(
    // 手动维护semanticChildCount,用于判断是否没有更多数据
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

## 3.使用flutter_swiper这类的库，出现滑动冲突

这是因为这些库中的UI组件会触发滑动事件，导致滑动冲突。使用RefreshSafeArea封装即可，这不会让你的界面有任何改变。

示例代码，完整示例[SwiperPage](https://github.com/xuelongqy/flutter_easyrefresh/blob/master/example/lib/page/swiper_page.dart)
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

## 4.刷新或加载立马结束

这是因为EasyRefresh会在onRefresh或者loadMore方法执行完后启动完成回调。如果在方法里面有异步操作，
则代表不会计算异步操作的时间，那么你需要加上await关键字。

示例代码
~~~dart
    onRefresh: () async {
      await Future.delayed(const Duration(seconds: 2), () {});
    },
    loadMore: () async {
      await Future.delayed(const Duration(seconds: 2), () {});
    },
~~~

## 5.暂不支持设置reverse

由于EasyRefresh的设计原理，目前暂时不支持reverse，我想你也不会经常用到

## 6.outerController并不是列表的ScrollController

outerController目前的作用是用来兼容NestedScrollView的，如果需要ScrollController，直接设置到列表里就可以了
