## Next
- feat: Added EasyRefresh.isNested parameter to determine whether to handle NestedScrollView. In versions 3.4.0 and earlier, no setting is required.
- fix: Adjust the Flutter version, Flutter >=3.10.0.

## 3.4.0
- breaking: Flutter >=3.7.0, dart >=2.19.0. Remove some unnecessary compatibility, please update the Flutter version in time, or use the previous version.
- fix: Scroll bar adaptation for unknown platforms [#825](https://github.com/xuelongqy/flutter_easy_refresh/issues/825).
- feat: Add BoxDecoration to ClassicHeader and ClassicFooter, Thanks GiampaoloGabba for [PR#822](https://github.com/xuelongqy/flutter_easy_refresh/pull/822).
- fix: Compatible with Flutter3.22.0.

## 3.3.5+1
- fix: Indicator properties cannot be updated [#818](https://github.com/xuelongqy/flutter_easy_refresh/issues/818).

## 3.3.5
- fix: Material style performance optimization [#814](https://github.com/xuelongqy/flutter_easy_refresh/issues/814).
- fix: Issue during build when IndicatorStateListenable rebinds IndicatorNotifier [#607](https://github.com/xuelongqy/flutter_easy_refresh/issues/607).

## 3.3.4
- fix: EasyPaging.itemBuilder type inference [#762](https://github.com/xuelongqy/flutter_easy_refresh/issues/762).
- fix: Event notification after dispose [#726](https://github.com/xuelongqy/flutter_easy_refresh/issues/726). 
- fix: Using refreshOnStart, onRefresh may not be triggered [#789](https://github.com/xuelongqy/flutter_easy_refresh/issues/789).
- fix: Using refreshOnStart, scrolling to the bottom when the Header is visible cannot trigger loading [#787](https://github.com/xuelongqy/flutter_easy_refresh/issues/787). 

## 3.3.3+1
- fix: All styles are lost.

## 3.3.3
- fix: When start on refresh, interrupted by loading [#785](https://github.com/xuelongqy/flutter_easy_refresh/issues/785).
- feat: Use Flutter default scroll bar [#775](https://github.com/xuelongqy/flutter_easy_refresh/issues/775).

## 3.3.2+4
- fix: IndicatorNotifier._onCanProcess. Null check operator used on a null value [#782](https://github.com/xuelongqy/flutter_easy_refresh/issues/782), [#774](https://github.com/xuelongqy/flutter_easy_refresh/issues/774).

## 3.3.2+2
- feat: All kind of pointer device are supported by default [#777](https://github.com/xuelongqy/flutter_easy_refresh/issues/777).

## 3.3.2+1
- fix: Compatible with versions below Flutter3.10 [#722](https://github.com/xuelongqy/flutter_easy_refresh/issues/722).

## 3.3.2
- fix: BezierIndicator.spinBuilder doesn't work. 
- feat: Add BezierIndicator.spinInCenter.
- feat: Add BezierIndicator.onlySpin [#689](https://github.com/xuelongqy/flutter_easy_refresh/issues/689).
- feat: Add support for ScrollPhysics.toleranceFor.
- feat: After failure, continue to scroll to trigger the task [#718](https://github.com/xuelongqy/flutter_easy_refresh/issues/718).
- feat: [EasyRefresh] noMoreRefresh -> canRefreshAfterNoMore, noMoreLoad -> canRefreshAfterLoad
- fix: Use canRefreshAfterNoMore or canRefreshAfterLoad, abnormal NoMore status.
- feat: EasyRefreshController.finishRefresh and EasyRefreshController.finishLoad add force parameter.
- feat: Add EasyRefresh.triggerAxis, specifies the direction of the trigger.

## 3.3.1+2
- fix: Secondary click event hit area [#688](https://github.com/xuelongqy/flutter_easy_refresh/issues/688), Thanks notbucai for [PR#714](https://github.com/xuelongqy/flutter_easy_refresh/pull/714).

## 3.3.1+1
- fix: Increase the priority of ClassicIndicator.pullIconBuilder [#674](https://github.com/xuelongqy/flutter_easy_refresh/issues/674).
- fix: fit parameter is invalid [#708](https://github.com/xuelongqy/flutter_easy_refresh/issues/708).

## 3.3.1
- fix: Avoid an endless loop caused by multiple ListViews nested, Thanks LinXunFeng for [PR#681](https://github.com/xuelongqy/flutter_easy_refresh/pull/681).
- fix: FooterNotifier.callTask use callRefreshOverOffset, Thanks AWarmHug for [PR#680](https://github.com/xuelongqy/flutter_easy_refresh/pull/680).
- fix: NestedScrollView resize error [#666](https://github.com/xuelongqy/flutter_easy_refresh/issues/666).

## 3.3.0+1
- fix: Removed compatibility code for list height changes [#646](https://github.com/xuelongqy/flutter_easy_refresh/issues/646), [#671](https://github.com/xuelongqy/flutter_easy_refresh/issues/671).

## 3.3.0
- fix: Compatible with Flutter 3.7.

## 3.2.2+2
- fix: The indicator does not retract when the height of the list changes [#618](https://github.com/xuelongqy/flutter_easy_refresh/issues/618).

## 3.2.2+1
- fix: CupertinoActivityIndicator renamed to avoid conflicts.

## 3.2.2
- fix: Compatible with Flutter2.8.1 and below [#619](https://github.com/xuelongqy/flutter_easy_refresh/issues/619).
- perf: Pub scores.

## 3.2.1
- fix: Footer's maxOverOffset property does not work.
- fix: When maxOverOffset is 0, list scrolling loses inertia.
- fix: When there is no task, the mode still changes [#608](https://github.com/xuelongqy/flutter_easy_refresh/issues/608).
- fix: HapticFeedback does not work when triggerWhenReach is true.

## 3.2.0+1
- fix: When clamping, triggerWhenRelease is true causing the indicator to be stuck.
- feat: Material indicator support triggerWhenRelease.

## 3.2.0
- feat: EasyRefreshController add headerState, footerState [#635](https://github.com/xuelongqy/flutter_easy_refresh/issues/635).
- feat: Add triggerWhenRelease and triggerWhenReleaseNoWait [#593](https://github.com/xuelongqy/flutter_easy_refresh/issues/593).
- fix: Error when using NotLoadFooter with clamping. Thanks Pwuts for [PR#659](https://github.com/xuelongqy/flutter_easy_refresh/pull/659).
- feat: Add maxOverOffset [#590](https://github.com/xuelongqy/flutter_easy_refresh/issues/590).

## 3.1.0
- feat: Add paging widget [EasyPaging].

## 3.0.5+1
- fix: Clamping refresh, causing Material3 AppBar to change color.

## 3.0.5
- fix: [EasyRefreshController.callRefresh] and [EasyRefreshController.callLoad] add force [#633](https://github.com/xuelongqy/flutter_easy_refresh/issues/633) [#642](https://github.com/xuelongqy/flutter_easy_refresh/issues/642). Thanks percival888 for [PR#639](https://github.com/xuelongqy/flutter_easy_refresh/issues/639).
- fix: When the height changes when callTask causes the list not to rebound.
- feat: Add [EasyRefresh.scrollBehaviorBuilder] and [EasyRefresh.defaultScrollBehaviorBuilder]. Thanks laiiihz for [PR#614](https://github.com/xuelongqy/flutter_easy_refresh/pull/614).

## 3.0.4+4
- fix: Type 'SpringDescription' not found [#638](https://github.com/xuelongqy/flutter_easy_refresh/issues/638).

## 3.0.4+3
- feat: When the content of the list is not full, the infinite scroll does not cross the bounds [#588](https://github.com/xuelongqy/flutter_easy_refresh/issues/588).

## 3.0.4+2
- fix: [refreshOnStart] safe area [#586](https://github.com/xuelongqy/flutter_easy_refresh/issues/586).

## 3.0.4+1
- fix: [NestedScrollView.viewportDimension] should use outer's [#582](https://github.com/xuelongqy/flutter_easy_refresh/issues/582).
- fix: Notify UI to update when indicator property changes [#582](https://github.com/xuelongqy/flutter_easy_refresh/issues/582).

## 3.0.4
- fix: ScrollMetrics.minScrollExtent != 0.0, offset calculation error.
- feat: Supported [ScrollView.center] [#581](https://github.com/xuelongqy/flutter_easy_refresh/issues/581).

## 3.0.3+1
- docs: NestedScrollView example.

## 3.0.3
- fix: processedDuration == Duration.zero, can't rebound [#572](https://github.com/xuelongqy/flutter_easy_refresh/issues/572).
- fix: [clamping] may not have rebound animation.
- fix: Indicator overflow [#575](https://github.com/xuelongqy/flutter_easy_refresh/issues/575).
- fix: BezierCircleHeader drop overflow.
- feat: Supported NestedScrollView.
- feat: Supported ScrollController trigger events.

## 3.0.2+2
- fix: ClassicIndicator transition animation.
- fix: NotRefreshHeader and NotLoadFooter [position] causes tree structure changes.

## 3.0.2+1
- fix: [viewportDimension] changes may trigger loading.

## 3.0.2
- feat: Indicator add [triggerWhenReach] [#348](https://github.com/xuelongqy/flutter_easy_refresh/issues/348). Trigger immediately when reaching the [triggerOffset].
- feat: CupertinoIndicator support horizontal.

## 3.0.1+1
- fix: CupertinoActivityIndicator radius == 0.

## 3.0.1
- fix: Use notifyListeners after ChangeNotifier disposed. Thanks laiiihz for [PR#555](https://github.com/xuelongqy/flutter_easy_refresh/pull/555).
- feat: ClassicHeader、ClassicFooter add IconThemeData. Thanks Lay523 for [PR#562](https://github.com/xuelongqy/flutter_easy_refresh/pull/562).
- feat: ClassicIndicator add [progressIndicatorSize] and [progressIndicatorStrokeWidth].
- feat: Add CupertinoIndicator.
- fix: finishLoad asset [#563](https://github.com/xuelongqy/flutter_easy_refresh/issues/563).

## 3.0.0+3
- fix: dart >=2.13.0.  
- fix: The screen is not full, [infinite] can not reset.
- feat: HeaderLocator and FooterLocator add [clearExtent].
- feat: Add OverrideFooter and OverrideHeader.

## 3.0.0+2
- fix: Scores

## 3.0.0+1
- fix: .pubignore

## 3.0.0
> ### New version
> Framework rewrite, stronger refresh widget.
> - Supports all scrollable widgets.
> - Physics scope, no longer limited to child types.
> - Adjustable scroll parameters, infinite possibilities for the indicator.
> - Safe area support.
> - Indicator position setting.
