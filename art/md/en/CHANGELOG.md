# Change log

## V 1.0.0
>Add: Drop-down refresh and pull-up loading  
>Add: Rebound effect and halo effect  
>Add: Custom Headers and Footers  
>Add: Material and BallPulse style

## V 1.0.1
>Adjustment: Height of trigger loading  
>Add: BezierCircleHeader  
>Add: BezierHourGlassHeader  
>Add: BezierBounceFooter

## V 1.0.2
>Adjustment: Drag coefficient of pull-up loading  
>Fix: Problem of multiple pull-ups that may get stuck  
>Fix: Automatic triggering BallPulse without animation problems  

## V 1.0.3
>Fix: Using CustomScrollView load error  
>Fix: Partial view than SafeArea deviation  
>Add: CustomScrollView usage examples  

## V 1.0.4
>Modify: UserProfilePage  
>Add: limitScroll attribute (scrollable list during refresh or loading)  

## V 1.0.5
>Fix: Not setting onRefresh causes more problems without triggering load  

## V 1.0.6
>Add: RefreshSafeArea，resolved Sliding Conflict  

## V 1.0.7
>Fix: loadMore conflicts with autoLoad  
>Fix: Drag a list repeatedly triggers a cross-border event  

## V 1.0.8
>Add: Header and Footer listeners for quick and easy customization  
>Add: Header and Footer connectors for placing Header and Footer in any position  
>Add：Manual control load refresh finish  
>Fix: Trigger loading problem across borders  
>Fix: BallPulse animation problem  
>Fix: Exception when the refresh process exited  
>Add: ClassicHeader and ClassicFooter animation  
>Fix: Manually calling refresh or loading does not trigger callbacks  

## V 1.0.9
>Fix: Classic style arrow reverse  

## V 1.1.0
>Fix: Classic style arrows don't recover  
>Add: Cupertino style example  

## V 1.1.1
>Fix: Pulling down too fast triggers scrolling up and causing slow rebound  
>Add: Taurus and Phoenix style  

## V 1.1.2
>Add: Flare animation - Space  
>Add: Delivery animation  

## V 1.1.3
>Fix: ios repeatedly pull down, the distance becomes longer  
>Modify: Delivery animation height  

## V 1.1.4
>Fix: HeaderListener and FooterListener use both highly updated fusions  
>Adjustment: Delivery animation speed  
>Add: Close callback for Header and Footer  
>Add: First refresh  
>Add: Empty widget  

## V 1.1.5
>Fix: Pull down may get stuck  

## V 1.1.6
>Fix: BallPulse sometimes bounces  
>Fix:Footer float when the pullback list follows the move  
>Fix:Switch direction when Header floats, list moves slightly  
>Adjustment: MaterialFooter animation  
>Fix: callRefresh error  

## V 1.1.7
>Fix: Pullback control causes the list to slow down  
>Modify: Child to Widget type  
>Adjustment：ClassicsHeader style  

## V 1.1.9
>Fix: Pullback exception when loadMore or onRefresh is not set  

## V 1.2.0
>Fix: onNoMore callback is not accurate  
>Add: isRefreshing to determine if it is being refreshed or loaded  
>Add: Header and Footer status change callbacks  
>Add: Header and Footer height change callbacks  

## V 1.2.1
>Specification code to improve compatibility  
>Adjustment: part of the style  
>The library does not have its own space style, transfer to example  

## V 1.2.2
>Fix: header is null, onRefresh is not null error [#19](https://github.com/xuelongqy/flutter_easyrefresh/issues/19)  

## V 1.2.3
>Add: rebound effect when onRefresh and loadMore are null [#18](https://github.com/xuelongqy/flutter_easyrefresh/issues/18)  

## V 1.2.4
>Add: support for NestedScrollView [#7](https://github.com/xuelongqy/flutter_easyrefresh/issues/7),[#11](https://github.com/xuelongqy/flutter_easyrefresh/issues/11)  