## Next
> fix: [NestedScrollView.viewportDimension] should use outer's [#582](https://github.com/xuelongqy/flutter_easy_refresh/pull/582).  

## V 3.0.4
> fix: ScrollMetrics.minScrollExtent != 0.0, offset calculation error.  
> feat: Supported [ScrollView.center] [#581](https://github.com/xuelongqy/flutter_easy_refresh/pull/581).  

## V 3.0.3+1
> docs: NestedScrollView example.   

## V 3.0.3
> fix: processedDuration == Duration.zero, can't rebound [#572](https://github.com/xuelongqy/flutter_easy_refresh/pull/572).   
> fix: [clamping] may not have rebound animation.   
> fix: Indicator overflow [#575](https://github.com/xuelongqy/flutter_easy_refresh/pull/575).  
> fix: BezierCircleHeader drop overflow.   
> feat: Supported NestedScrollView.  
> feat: Supported ScrollController trigger events.  

## V 3.0.2+2
> fix: ClassicIndicator transition animation.  
> fix: NotRefreshHeader and NotLoadFooter [position] causes tree structure changes.  

## V 3.0.2+1
> fix: [viewportDimension] changes may trigger loading.  

## V 3.0.2
> feat: Indicator add [triggerWhenReach] [#348](https://github.com/xuelongqy/flutter_easy_refresh/pull/348). Trigger immediately when reaching the [triggerOffset].  
> feat: CupertinoIndicator support horizontal.  

## V 3.0.1+1
> fix: CupertinoActivityIndicator radius == 0.  

## V 3.0.1
> fix: Use notifyListeners after ChangeNotifier disposed. Thanks laiiihz for [PR#555](https://github.com/xuelongqy/flutter_easy_refresh/pull/555).  
> feat: ClassicHeader、ClassicFooter add IconThemeData. Thanks Lay523 for [PR#562](https://github.com/xuelongqy/flutter_easy_refresh/pull/562).  
> feat: ClassicIndicator add [progressIndicatorSize] and [progressIndicatorStrokeWidth].  
> feat: Add CupertinoIndicator.  
> fix: finishLoad asset [#563](https://github.com/xuelongqy/flutter_easy_refresh/pull/563).

## V 3.0.0+3
> fix: dart >=2.13.0.  
> fix: The screen is not full, [infinite] can not reset.  
> feat: HeaderLocator and FooterLocator add [clearExtent].  
> feat: Add OverrideFooter and OverrideHeader.  

## V 3.0.0+2
> fix: Scores

## V 3.0.0+1
> fix: .pubignore

## V 3.0.0
> ### New version
> Framework rewrite, stronger refresh widget.  
> - Supports all scrollable widgets.  
> - Physics scope, no longer limited to child types.  
> - Adjustable scroll parameters, infinite possibilities for the indicator.  
> - Safe area support.  
> - Indicator position setting.  
