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