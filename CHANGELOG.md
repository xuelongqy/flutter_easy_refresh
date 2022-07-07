# Change log

## V 2.2.2
>！！！v2 will no longer be maintained, please upgrade to [v3](https://pub.dev/packages/easy_refresh)  
>Add: flutter3 supports  

## V 2.2.1
>Fix: firstRefresh is true, and firstRefreshWidget is null to report an error [issues#457](https://github.com/xuelongqy/flutter_easyrefresh/issues/457)  

## V 2.2.0
>Add：iOS example supports Chinese  
>Add：null safety. If you don't need, please use a version 2.1.8 version  

## V 2.1.8
>Fix: loading does not disappear [issues#392](https://github.com/xuelongqy/flutter_easyrefresh/issues/392)  

## V 2.1.7
>Fix: taskNotifier reported an error when disposed [issues#382](https://github.com/xuelongqy/flutter_easyrefresh/issues/382)  
>Fix: NestedScrollViewPage, TabBar list scrolling affects other lists [pull#357](https://github.com/xuelongqy/flutter_easyrefresh/pull/357)  

## V 2.1.6
>Fix: refresh will not end [issues#355](https://github.com/xuelongqy/flutter_easyrefresh/issues/355)  
>Remove: cupertino_icons dependency [issues#373](https://github.com/xuelongqy/flutter_easyrefresh/issues/373)  

## V 2.1.5
>Fix：firstRefresh error [issues#341](https://github.com/xuelongqy/flutter_easyrefresh/issues/341)  
>Add: safeArea and padding parameters of Footer [issues#332](https://github.com/xuelongqy/flutter_easyrefresh/issues/332)  

## V 2.1.4
>Fix：When infinite loading, onLoad cannot be triggered if the list is not full yet [issues#377](https://github.com/xuelongqy/flutter_easyrefresh/issues/337)  

## V 2.1.2
>Modify: emptyWidget is not displayed when customizing firstRefreshWidget  
>Remove: Internationalization support  
>Add: Header and Footer set rebound in case of infinite scroll (overScroll)  
>Fix: callRefresh in NestedScrollView collapsed [issues#172](https://github.com/xuelongqy/flutter_easyrefresh/issues/172)  
>Fix：Header is not retracted, calling callRefresh again will not trigger refresh [issues#313](https://github.com/xuelongqy/flutter_easyrefresh/issues/313)  

## V 2.1.1
>Fix: BezierCircleHeader progress bar is occasionally not hidden  
>Update: TaurusHeader add backgroundColor parameter [issues#269](https://github.com/xuelongqy/flutter_easyrefresh/issues/269)   
>Add: key and EasyRefresh.custom listKey [issues#273](https://github.com/xuelongqy/flutter_easyrefresh/issues/273)   

## V 2.1.0
>Fix: After using firstRefreshWidget, pull down refresh does not take effect [issues#250](https://github.com/xuelongqy/flutter_easyrefresh/issues/250),[issues#256](https://github.com/xuelongqy/flutter_easyrefresh/issues/256)  

## V 2.0.9
>Fix: EmptyView size does not change after ScrollView size changes [issues#241](https://github.com/xuelongqy/flutter_easyrefresh/issues/241)  
>Fix: Animation throws exception when dispose [issues#233](https://github.com/xuelongqy/flutter_easyrefresh/issues/233)  
>Fix: Flare animation throws exception [issues#245](https://github.com/xuelongqy/flutter_easyrefresh/issues/245)  
>Add: Header and Footer display independently  
>Fix: When the list is empty, infinite loading has no effect  

## V 2.0.8
>Fix: Compatible with Flutter 1.9 and previous versions  

## V 2.0.7
>Fixed: Type error after setting text in classic style [issues#217](https://github.com/xuelongqy/flutter_easyrefresh/issues/217)  

## V 2.0.6
>Support: Flutter v1.12 and above  
>Add: Globalization  
>Fix: success setting to false in case of infinite loading  

## V 2.0.5
>Fix: 5 ball cross-border [issues#156](https://github.com/xuelongqy/flutter_easyrefresh/issues/156)  
>Fix: The background color of the ball pulse does not take effect pull#202  
>Fix: MaterialHeader, animation error after dispose [issues#199](https://github.com/xuelongqy/flutter_easyrefresh/issues/199)  
>Add: Notifier Header and Footer [issues#177](https://github.com/xuelongqy/flutter_easyrefresh/issues/177),[issues#186](https://github.com/xuelongqy/flutter_easyrefresh/issues/186)  
>Add: Custom style support gesture [issues#207](https://github.com/xuelongqy/flutter_easyrefresh/issues/207)  
>Fix: List height is not greater than indicator height, Footer reverse [issues#160](https://github.com/xuelongqy/flutter_easyrefresh/issues/160)  

## V 2.0.4
>Fix: No delay using setState error   
>Fix: When the dwell height and the trigger height are the same, the pullback height is fixed issues #149   
>Fix: Trigger refresh bounce   

## V 2.0.3
>Fix: Quick rebound after list refresh or load [issues#130](https://github.com/xuelongqy/flutter_easyrefresh/issues/130)   
>Fix: ClassicalFooter set bgColor is invalid [issues#138](https://github.com/xuelongqy/flutter_easyrefresh/issues/138)   
>Fix: success is not reset when reset state   
>Fix: When onRefresh is null, empty attempt to report error issue#140   
>Fix: When no more, the icon still loading [issues#137](https://github.com/xuelongqy/flutter_easyrefresh/issues/137),[issues#142](https://github.com/xuelongqy/flutter_easyrefresh/issues/142)   

## V 2.0.2
>Optimization: Trigger refresh and load   
>Optimization: Infinite load trigger   
>Support: Child is SingleChildScrollView type  

## V 2.0.1
>Fix: RefreshCallback naming conflict issue [issues#120](https://github.com/xuelongqy/flutter_easyrefresh/issues/120)   
>Modify: Some styles have no more status   
>Fix: Height is 0 after infinite loading is completed [issues#123](https://github.com/xuelongqy/flutter_easyrefresh/issues/123),[issues#121](https://github.com/xuelongqy/flutter_easyrefresh/issues/121)  

## V 2.0.0
>Framework refactoring: modify the refresh loading principle, improve compatibility, and more in line with the Flutter specification   
>Add: List reverse support   
>Add: List horizontal support     
