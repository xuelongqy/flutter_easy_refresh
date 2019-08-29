# 更新日志

## V 2.0.0
>框架重构：修改刷新加载原理，提高兼容性，更符合Flutter规范  
>添加：列表反向支持  
>添加：列表横向支持  

## V 2.0.1
>解决：RefreshCallback命名冲突问题 issues#120  
>修改：部分样式没有更多状态  
>修复：无限加载完成后高度为0 issues#123,issues#121  

## V 2.0.2
>优化：触发刷新与加载   
>优化：无限加载触发   
>支持：child为SingleChildScrollView类型   

## V 2.0.3
>修复：列表刷新或加载时快速回弹 issues#130   
>修复：ClassicalFooter设置bgColor无效 issues#138   
>修复：重置状态时success未重置   
>修复：在onRefresh为null时,空试图报错 issues#140   
>修复：没有更多时,图标依然为加载 issues#137,issues#142   

## V 2.0.4
>修复：无延时使用setState报错   
>修复：停留高度和触发高度一致时，回拉高度固定 issues#149   
>修复：触发刷新跳动问题   