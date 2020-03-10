# 更新日志

## V 2.1.0
>修复：使用firstRefreshWidget后，下拉刷新不生效 [issues#250](https://github.com/xuelongqy/flutter_easyrefresh/issues/250),[issues#256](https://github.com/xuelongqy/flutter_easyrefresh/issues/256)  

## V 2.0.9
>修复：ScrollView大小改变后EmptyView大小不改变 [issues#241](https://github.com/xuelongqy/flutter_easyrefresh/issues/241)  
>修复：dispose时动画抛出异常 [issues#233](https://github.com/xuelongqy/flutter_easyrefresh/issues/233)  
>修复：Flare动画报错 [issues#245](https://github.com/xuelongqy/flutter_easyrefresh/issues/245)  
>添加：Header和Footer独立显示  
>修复：无内容时，无限加载不生效  

## V 2.0.8
>修复：兼容Flutter1.9及其以前版本  

## V 2.0.7
>修复：经典样式设置文字后类型错误 [issues#217](https://github.com/xuelongqy/flutter_easyrefresh/issues/217)  

## V 2.0.6
>支持：Flutter v1.12及其以上版本  
>添加：国际化  
>修复：无限加载情况下，success设置为false无效  

## V 2.0.5
>修复：5个小球越界问题 [issues#156](https://github.com/xuelongqy/flutter_easyrefresh/issues/156)  
>修复：球脉冲背景色不生效 [pull#202](https://github.com/xuelongqy/flutter_easyrefresh/pull/202)  
>修复：MaterialHeader，dispose后动画报错 [issues#199](https://github.com/xuelongqy/flutter_easyrefresh/issues/199)  
>添加：通知器Header和Footer [issues#177](https://github.com/xuelongqy/flutter_easyrefresh/issues/177),[issues#186](https://github.com/xuelongqy/flutter_easyrefresh/issues/186) 
>添加：自定义样式支持手势 [issues#207](https://github.com/xuelongqy/flutter_easyrefresh/issues/207)  
>修复：列表高度不大于指示器高度，Footer反向问题 [issues#160](https://github.com/xuelongqy/flutter_easyrefresh/issues/160)   

## V 2.0.4
>修复：无延时使用setState报错   
>修复：停留高度和触发高度一致时，回拉高度固定 [issues#149](https://github.com/xuelongqy/flutter_easyrefresh/issues/149)   
>修复：触发刷新跳动问题   

## V 2.0.3
>修复：列表刷新或加载时快速回弹 [issues#130](https://github.com/xuelongqy/flutter_easyrefresh/issues/130)   
>修复：ClassicalFooter设置bgColor无效 [issues#138](https://github.com/xuelongqy/flutter_easyrefresh/issues/138)   
>修复：重置状态时success未重置   
>修复：在onRefresh为null时,空试图报错 [issues#140](https://github.com/xuelongqy/flutter_easyrefresh/issues/140)   
>修复：没有更多时,图标依然为加载 [issues#137](https://github.com/xuelongqy/flutter_easyrefresh/issues/137),[issues#142](https://github.com/xuelongqy/flutter_easyrefresh/issues/142)   

## V 2.0.2
>优化：触发刷新与加载   
>优化：无限加载触发   
>支持：child为SingleChildScrollView类型   

## V 2.0.1
>解决：RefreshCallback命名冲突问题 [issues#120](https://github.com/xuelongqy/flutter_easyrefresh/issues/120)  
>修改：部分样式没有更多状态  
>修复：无限加载完成后高度为0 [issues#123](https://github.com/xuelongqy/flutter_easyrefresh/issues/123),[issues#121](https://github.com/xuelongqy/flutter_easyrefresh/issues/121)  

## V 2.0.0
>框架重构：修改刷新加载原理，提高兼容性，更符合Flutter规范  
>添加：列表反向支持  
>添加：列表横向支持  
