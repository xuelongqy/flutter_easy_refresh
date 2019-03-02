# 更新日志

## V 1.0.0
>添加：下拉刷新和上拉加载  
>添加：回弹效果以及光晕效果  
>添加：自定义Header和Footer  
>添加：Material和BallPulse视图

## V 1.0.1
>调整：触发加载的高度  
>添加：BezierCircleHeader  
>添加：BezierHourGlassHeader  
>添加：BezierBounceFooter

## V 1.0.2
>调整：上拉加载阻力系数  
>修复：多次上拉有可能卡住的问题  
>修复：自动触发BallPulse没有动画问题  

## V 1.0.3
>修复：使用CustomScrollView加载报错问题  
>修复：部分视图在非SafeArea中偏移问题  
>添加：CustomScrollView使用示例  

## V 1.0.4
>修改：个人中心示例  
>添加：limitScroll属性(刷新或加载过程中列表是否可滚动)  

## V 1.0.5
>修复：不设置onRefresh导致不触发加载更多问题  

## V 1.0.6
>添加：RefreshSafeArea，解决滑动冲突问题  

## V 1.0.7
>修复：loadMore与autoLoad冲突问题  
>修复：反复拖动触发越界事件  

## V 1.0.8
>添加：Header和Footer监听器，方便快速自定义  
>添加：Header和Footer连接器，实现将Header和Footer放置在任何位置  
>添加：手动控制加载刷新结束  
>修复：越过边界触发加载问题  
>修复：BallPulse动画问题  
>修复：刷新过程退出时出现异常  
>添加：ClassicHeader和ClassicFooter动画  
>修复：手动调用刷新或加载不触发回调的问题  

## V 1.0.9
>修复：经典样式箭头反向问题  

## V 1.1.0
>修复：经典样式箭头不复原问题  
>添加：Cupertino风格示例  

## V 1.1.1
>修复：下拉过快触发向上滚动导致回弹变慢问题  
>添加：金色校园和冲上云霄样式  

## V 1.1.2
>添加：Flare动画 - 星空  
>添加：Delivery动画 - 气球快递  

## V 1.1.3
>修复：ios反复下拉,距离变长的问题  
>修改：Delivery动画高度  

## V 1.1.4
>修复：HeaderListener和FooterListener同时使用高度更新融合问题  
>调整：Delivery动画运动速度  
>添加：Header和Footer的close回调  
>添加：首次刷新  
>添加：空视图  

## V 1.1.5
>修复：下拉可能卡住的问题  

## V 1.1.6
>修复：BallPulse有时出现跳动的问题  
>修复：Footer浮动时回拉列表跟随移动问题  
>修复：Header浮动时切换方向，列表小幅度移动  
>调整：MaterialFooter动画  
>修复：callRefresh报错问题  

## V 1.1.7
>修复：回拉控制导致列表速度变慢  
>修改：Child为Widget类型  
>调整：ClassicsHeader样式  

## V 1.1.9
>修复：不设置loadMore或者onRefresh时，回拉异常的问题  

## V 1.2.0
>修复：onNoMore回调不准确问题  
>添加：isRefreshing用于判断是否正在刷新或加载中  
>添加：Header和Footer状态改变回调  
>添加：Header和Footer高度改变回调  

## V 1.2.1
>规范代码，提高兼容性  
>调整：部分样式  
>库中不在自带星空样式，转移至example  

## V 1.2.2
>修复：header为null，onRefresh不为null报错的问题 [#19](https://github.com/xuelongqy/flutter_easyrefresh/issues/19)  

## V 1.2.3
>添加：onRefresh和loadMore为null时的回弹效果 [#18](https://github.com/xuelongqy/flutter_easyrefresh/issues/18)  

## V 1.2.4
>添加：NestedScrollView支持 [#7](https://github.com/xuelongqy/flutter_easyrefresh/issues/7),[#11](https://github.com/xuelongqy/flutter_easyrefresh/issues/11)  

## V 1.2.5
>修复：CustomScrollView不维护semanticChildCount报错问题 [#24](https://github.com/xuelongqy/flutter_easyrefresh/issues/24),[#25](https://github.com/xuelongqy/flutter_easyrefresh/issues/25)  
>修复：CustomScrollView刷新或加载导致emptyWidget多次添加问题,感谢hwh97 [#29](https://github.com/xuelongqy/flutter_easyrefresh/pull/29)  

## V 1.2.6
>修复：NotificationListener无效问题 [#30](https://github.com/xuelongqy/flutter_easyrefresh/issues/30)  
>去除：到达一定高度触发刷新或加载   
>修复：刷新或加载结束后无法修改提示文字 [#22](https://github.com/xuelongqy/flutter_easyrefresh/issues/22)   

## V 1.2.7
>添加：builder属性，用于添加额外组件，例如滚动条 [#39](https://github.com/xuelongqy/flutter_easyrefresh/issues/39)  
>添加：滚动条示例   
>添加：淘宝二楼示例 [#26](https://github.com/xuelongqy/flutter_easyrefresh/issues/26)   