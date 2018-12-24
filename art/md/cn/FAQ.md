# 常见问题

## 1.Header和Footer在成功后出现跳动问题

这是因为你没有给Header和Footer设置key，因为EasyRefresh会更新Header和Footer的状态。
如果没有设置key，会导致无法记录状态而被被初始化，出现跳动的情况。

## 2.CustomScrollView以及折叠头部使用的问题

如果你直接使用了CustomScrollView，可能会一直出现没有更多数据的提示，即使加载出了新的数据。
这是因为CustomScrollView不会自动维护semanticChildCount，所以我们需要自己去维护。
折叠头部在CustomScrollView中使用SliverAppBar即可。

## 3.使用flutter_swiper这类的库，出现滑动冲突

这是因为这些库中的UI组件会触发滑动事件，导致滑动冲突。使用RefreshSafeArea封装即可，不会让你的界面有任何改变
