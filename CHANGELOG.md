# Change log

## V 2.0.0
>Framework refactoring: modify the refresh loading principle, improve compatibility, and more in line with the Flutter specification   
>Add: List reverse support   
>Add: List horizontal support   

## V 2.0.1
>Fix: RefreshCallback naming conflict issue issues#120   
>Modify: Some styles have no more status   
>Fix: Height is 0 after infinite loading is completed issues#123,issues#121   

## V 2.0.2
>Optimization: Trigger refresh and load   
>Optimization: Infinite load trigger   
>Support: Child is SingleChildScrollView type   

## V 2.0.3
>Fix: Quick rebound after list refresh or load issues#130   
>Fix: ClassicalFooter set bgColor is invalid issues#138   
>Fix: success is not reset when reset state   
>Fix: When onRefresh is null, empty attempt to report error issue#140   
>Fix: When no more, the icon still loading issues#137, issues#142   

## V 2.0.4
>Fix: No delay using setState error   
>Fix: When the dwell height and the trigger height are the same, the pullback height is fixed issues #149   
>Fix: Trigger refresh bounce

## V 2.0.5
>Fix: 5 ball cross-border issues#156  
>Fix: The background color of the ball pulse does not take effect pull#202  
>Fix: MaterialHeader, animation error after dispose issues#199  
>Add: Notifier Header and Footer issues#177,issues#186  
>Add: Custom style support gesture issues#207  
>Fix: List height is not greater than indicator height, Footer reverse issues#160  

## V 2.0.6
>Support: Flutter v1.12 and above  
>Add: Globalization  
>Fix: success setting to false in case of infinite loading  

## V 2.0.7
>Fixed: Type error after setting text in classic style issues#217  

## V 2.0.8
>Fix: Compatible with Flutter 1.9 and previous versions  

## Next
>Fix: EmptyView size does not change after ScrollView size changes issues#241  
>Fix: Animation throws exception when dispose issues#233  
>Fix: Flare animation throws exception issues#245  
>Add: Header and Footer display independently  
