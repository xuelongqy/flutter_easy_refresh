import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'header/header.dart';
import 'footer/footer.dart';

typedef Future OnRefresh();
typedef Future LoadMore();
typedef ScrollPhysicsChanged(ScrollPhysics physics);
typedef AnimationStateChanged(AnimationStates animationStates,RefreshBoxDirectionStatus refreshBoxDirectionStatus);

enum  RefreshBoxDirectionStatus {
  //  上拉加载的状态 分别为 闲置 上拉  下拉
  IDLE, PUSH, PULL
}

enum  AnimationStates {
  ///RefreshBox高度没有达到50，上下拉刷新不可用（此状态下RefreshBox会自动弹回去）；RefreshBox height not reached 50，the function of load data is not available（In this state RefreshBox Will automatically bounce back）
  DragAndRefreshNotEnabled,
  ///RefreshBox高度达到50,上下拉刷新可用;RefreshBox height reached 50，the function of load data is  available
  DragAndRefreshEnabled,
  ///抬起手指后。RefreshBox 弹回到50的高度；After lifting your finger，RefreshBox bounce back to the height of 50，
  //ReboundToBoxHeight,
  ///开始加载数据时；When loading data starts
  StartLoadData,
  ///加载完数据时；RefreshBox会留在屏幕2秒，并不马上消失，After loading the data，RefreshBox will stay on the screen for 2 seconds, not disappearing immediately
  LoadDataEnd,
  ///开始消失时；RefreshBox begins to disappear
  //BoxStartDisappear,
  RefreshBoxIdle
}

class EasyRefresh extends StatefulWidget{

  final OnRefresh onRefresh;
  final LoadMore loadMore;
  final ScrollPhysicsChanged scrollPhysicsChanged;
  final ScrollView child;
  // 去掉过度滑动时ListView顶部的蓝色光晕效果
  final bool isShowLeadingGlow;
  final bool isShowTrailingGlow;

  final Color defaultRefreshBoxBackgroundColor;
  final String defaultRefreshBoxTipText;
  final Color defaultRefreshBoxTextColor;//defaultRefreshBox
  final Color glowColor;
  final RefreshHeader refreshHeader;
  final RefreshFooter refreshFooter;

  final AnimationStateChanged animationStateChangedCallback;

  EasyRefresh({
    @required this.scrollPhysicsChanged,
    this.defaultRefreshBoxBackgroundColor:Colors.grey,
    this.defaultRefreshBoxTipText:"松手即可刷新",
    this.isShowLeadingGlow : false,
    this.isShowTrailingGlow : false,
    this.defaultRefreshBoxTextColor:Colors.white,
    this.glowColor:Colors.blue,
    this.refreshHeader,
    this.refreshFooter,
    this.animationStateChangedCallback,
    this.onRefresh,
    this.loadMore,
    @required this.child}
  ):assert(child != null);

  @override
  EasyRefreshState createState() {
    return new EasyRefreshState();
  }
}

class EasyRefreshState extends State<EasyRefresh> with TickerProviderStateMixin<EasyRefresh>{

  double topItemHeight = 0.0;
  double bottomItemHeight = 0.0;

  Animation<double> animation;
  AnimationController animationController;
  double shrinkageDistance = 0.0;
  final double _refreshHeight = 50.0;
  RefreshBoxDirectionStatus states = RefreshBoxDirectionStatus.IDLE;
  RefreshBoxDirectionStatus lastStates = RefreshBoxDirectionStatus.IDLE;
  AnimationStates animationStates = AnimationStates.RefreshBoxIdle;

  AnimationController animationControllerWait;

  bool isReset=false;
  bool isPulling=false;

  // 顶部视图
  RefreshHeader _refreshHeader;
  // 底部视图
  RefreshFooter _refreshFooter;

  @override
  void initState() {
    super.initState();
    //这个是刷新时控件旋转的动画，用来使刷新的Icon动起来
    animationControllerWait=new AnimationController(duration: const Duration(milliseconds: 1000*100), vsync: this);

    animationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    animation = new Tween(begin: 1.0, end: 0.0).animate(animationController)
      ..addListener(() {
        //因为animationController reset()后，addListener会收到监听，导致再执行一遍setState topItemHeight和bottomItemHeight会异常 所以用此标记
        //判断是reset的话就返回避免异常
        if(isReset){
          return;
        }
        //根据动画的值逐渐减小布局的高度，分为4种情况
        // 1.上拉高度超过_refreshHeight    2.上拉高度不够50   3.下拉拉高度超过_refreshHeight  4.下拉拉高度不够50
        setState(() {
          if(topItemHeight>_refreshHeight){
            //shrinkageDistance*animation.value是由大变小的，模拟出弹回的效果
            topItemHeight=_refreshHeight+shrinkageDistance*animation.value;
          }else if(bottomItemHeight>_refreshHeight){
            bottomItemHeight=_refreshHeight+shrinkageDistance*animation.value;
            //高度小于50时↓
          }else if(topItemHeight<=_refreshHeight&&topItemHeight>0){
            topItemHeight=shrinkageDistance*animation.value;
          }else if(bottomItemHeight<=_refreshHeight&&bottomItemHeight>0){
            bottomItemHeight=shrinkageDistance*animation.value;
          }
        });
      });


    animation.addStatusListener((animationStatus){
      if(animationStatus==AnimationStatus.completed){
        //动画结束时首先将animationController重置
        isReset=true;
        animationController.reset();
        isReset=false;
        //动画完成后只有2种情况，高度是50和0，如果是高度》=50的，则开始刷新或者加载操作，如果是0则恢复ListView
        setState(() {
          if(topItemHeight>=_refreshHeight){
            topItemHeight=_refreshHeight;
            _refreshStart(RefreshBoxDirectionStatus.PULL);
          }else if(bottomItemHeight>=_refreshHeight){
            bottomItemHeight=_refreshHeight;
            _refreshStart(RefreshBoxDirectionStatus.PUSH);
            //动画结束，高度回到0，上下拉刷新彻底结束，ListView恢复正常
          }else if(states==RefreshBoxDirectionStatus.PUSH){
            topItemHeight=0.0;
            widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
            states=RefreshBoxDirectionStatus.IDLE;
            _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          }else if(states==RefreshBoxDirectionStatus.PULL){
            bottomItemHeight=0.0;
            widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
            states=RefreshBoxDirectionStatus.IDLE;
            isPulling=false;
            _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          }
        });
      }else if(animationStatus==AnimationStatus.forward){
        //动画开始时根据情况计算要弹回去的距离
        if(topItemHeight>_refreshHeight){
          shrinkageDistance=topItemHeight-_refreshHeight;
        }else if(bottomItemHeight>_refreshHeight){
          shrinkageDistance=bottomItemHeight-_refreshHeight;
          //这里必须有个动画，不然上拉加载时  ListView不会自动滑下去，导致ListView悬在半空
          widget.child.controller.animateTo(widget.child.controller.position.maxScrollExtent, duration: new Duration(milliseconds: 250), curve: Curves.linear);
        }else if(topItemHeight<=_refreshHeight&&topItemHeight>0.0){
          shrinkageDistance=topItemHeight;
          states=RefreshBoxDirectionStatus.PUSH;
        }else if(bottomItemHeight<=_refreshHeight&&bottomItemHeight>0.0){
          shrinkageDistance=bottomItemHeight;
          states=RefreshBoxDirectionStatus.PULL;
        }
      }
    });
  }

  // 生成底部栏
  Widget _getFooter(){
    if(widget.loadMore != null) {
      if (this._refreshFooter != null) return this._refreshFooter;
      if(widget.refreshFooter == null){
        this._refreshFooter = __classicsFooterBuilder();
      }else{
        this._refreshFooter = widget.refreshFooter;
      }
      return this._refreshFooter;
    }else{
      return new Container();
    }
  }

  // 默认底部栏
  Widget __classicsFooterBuilder() {
    return new ClassicsFooter();
  }

  // 生成顶部栏
  Widget _getHeader(){
    if(widget.onRefresh != null) {
      if (this._refreshHeader != null) return this._refreshHeader;
      if(widget.refreshHeader == null){
        this._refreshHeader = _classicsHeaderBuilder();
      }else{
        this._refreshHeader = widget.refreshHeader;
      }
      return this._refreshHeader;
    }else{
      return new Container();
    }
  }

  // 默认顶部栏
  Widget _classicsHeaderBuilder(){
    return ClassicsHeader();
  }

  void _refreshStart (RefreshBoxDirectionStatus refreshBoxDirectionStatus) async{
    _checkStateAndCallback(AnimationStates.StartLoadData,refreshBoxDirectionStatus);
    if(refreshBoxDirectionStatus==RefreshBoxDirectionStatus.PULL && this._refreshHeader == null && widget.onRefresh != null){
      //开始加载等待的动画
      animationControllerWait.forward();
    }else if(refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PUSH && this._refreshFooter == null && widget.loadMore != null){
      //开始加载等待的动画
      animationControllerWait.forward();
    }

    // 这里我们开始加载数据 数据加载完成后，将新数据处理并开始加载完成后的处理
    if (topItemHeight > bottomItemHeight) {
      if (widget.onRefresh != null) {
        // 调用刷新回调
        await widget.onRefresh();
      }
    }else {
      if (widget.loadMore != null) {
        // 调用加载更多
        await widget.loadMore();
      }
    }
    if (!mounted) return;

    if(animationControllerWait.isAnimating){
      //结束加载等待的动画
      animationControllerWait.stop();
    }
    _checkStateAndCallback(AnimationStates.LoadDataEnd,refreshBoxDirectionStatus);
    await Future.delayed(new Duration(seconds: 1));
    //开始将加载（刷新）布局缩回去的动画
    animationController.forward();

    if(refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PULL && this._refreshHeader == null && widget.onRefresh != null){
      // 结束加载等待的动画
      animationControllerWait.reset();
    }else if(refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PUSH && this._refreshFooter == null && widget.loadMore != null){
      // 结束加载等待的动画
      animationControllerWait.reset();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    animationControllerWait.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 更新高度
    if (this._refreshHeader != null) {
      this._refreshHeader.getKey().currentState.updateHeight(topItemHeight);
    }
    if (this._refreshFooter != null) {
      this._refreshFooter.getKey().currentState.updateHeight(bottomItemHeight);
    }
    return new Container(
      child:new Column(
        children: <Widget>[
          _getHeader(),
          new Expanded(
            flex:1,
            child: new NotificationListener(
              onNotification: (ScrollNotification  notification){
                ScrollMetrics metrics=notification.metrics;
                if(notification is ScrollUpdateNotification){

                  _handleScrollUpdateNotification(notification);

                }else if(notification is ScrollEndNotification){

                  _handleScrollEndNotification();

                }else if(notification is UserScrollNotification){

                  _handleUserScrollNotification(notification);

                }else if(metrics.atEdge&& notification is OverscrollNotification){

                  _handleOverScrollNotification(notification);

                }
                return true;
              },
              child:ScrollConfiguration(
                behavior: MyBehavior(widget.isShowLeadingGlow,widget.isShowTrailingGlow,widget.glowColor),
                child: widget.child,
              ),
            ),
          ),
          _getFooter(),
        ],
      ),
    );
  }

  void _handleScrollUpdateNotification(ScrollUpdateNotification notification){
    //此处同上
    if(notification.dragDetails==null){
      return;
    }
    //Header刷新的布局可见时，且当手指反方向拖动（由下向上），notification 为 ScrollUpdateNotification，这个时候让头部刷新布局的高度+delta.dy(此时dy为负数)
    // 来缩小头部刷新布局的高度，当完全看不见时，将scrollPhysics设置为RefreshAlwaysScrollPhysics，来保持ListView的正常滑动
    if(topItemHeight>0.0){
      setState(() {
        //  如果头部的布局高度<0时，将topItemHeight=0；并恢复ListView的滑动
        if(topItemHeight+notification.dragDetails.delta.dy/2<=0.0){
          _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          topItemHeight=0.0;
          widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
        }else {
          //当刷新布局可见时，让头部刷新布局的高度+delta.dy(此时dy为负数)，来缩小头部刷新布局的高度
          topItemHeight = topItemHeight + notification.dragDetails.delta.dy / 2;
        }
        // 如果小于50.0则恢复下拉刷新
        if (topItemHeight < 50.0) {
          _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,RefreshBoxDirectionStatus.PULL);
        }
      });
    }else if(bottomItemHeight>0.0){
      //底部的布局可见时 ，且手指反方向拖动（由上向下），这时notification 为 ScrollUpdateNotification，这个时候让底部加载布局的高度-delta.dy(此时dy为正数数)
      //来缩小底部加载布局的高度，当完全看不见时，将scrollPhysics设置为RefreshAlwaysScrollPhysics，来保持ListView的正常滑动

      //当上拉加载时，不知道什么原因，dragDetails可能会为空，导致抛出异常，会发生很明显的卡顿，所以这里必须判空
      if(notification.dragDetails==null){
        return ;
      }
      setState(() {
        //如果底部的布局高度<0时，bottomItemHeight=0；并恢复ListView的滑动
        if(bottomItemHeight-notification.dragDetails.delta.dy/2<=0.0) {
          _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          bottomItemHeight=0.0;
          widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
        }else{
          if(notification.dragDetails.delta.dy>0){
            //当加载的布局可见时，让上拉加载布局的高度-delta.dy(此时dy为正数数)，来缩小底部的加载布局的高度
            bottomItemHeight = bottomItemHeight - notification.dragDetails.delta.dy / 2;
          }
        }
        // 如果小于50.0则恢复加载
        if (bottomItemHeight < 50.0) {
          _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,RefreshBoxDirectionStatus.PUSH);
        }
      });
    }
  }

  void _handleScrollEndNotification(){
    //如果滑动结束后（手指抬起来后），判断是否需要启动加载或者刷新的动画
    if((topItemHeight>0||bottomItemHeight>0)){
      if(isPulling){
        return ;
      }
      //这里在动画开始时，做一个标记，表示上拉加载正在进行，因为在超出底部和头部刷新布局的高度后，高度会自动弹回，ListView也会跟着运动，
      //返回结束时，ListView的运动也跟着结束，会触发ScrollEndNotification，导致再次启动动画，而发生BUG
      if(bottomItemHeight>0){
        isPulling=true;
      }
      //启动动画后，ListView不可滑动
      widget.scrollPhysicsChanged(new NeverScrollableScrollPhysics());
      animationController.forward();
    }
  }

  void _handleUserScrollNotification(UserScrollNotification notification){
    if(bottomItemHeight>0.0&&notification.direction==ScrollDirection.forward){
      //底部加载布局出现反向滑动时（由上向下），将scrollPhysics置为RefreshScrollPhysics，只要有2个原因。1 减缓滑回去的速度，2 防止手指快速滑动时出现惯性滑动
      widget.scrollPhysicsChanged(new RefreshScrollPhysics());
    }else if(topItemHeight>0.0&&notification.direction==ScrollDirection.reverse){
      //头部刷新布局出现反向滑动时（由下向上）
      widget.scrollPhysicsChanged(new RefreshScrollPhysics());
    }else if(bottomItemHeight>0.0&&notification.direction==ScrollDirection.reverse){
      //反向再反向（恢复正向拖动）
      widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());

    }
  }

  void _handleOverScrollNotification(OverscrollNotification notification){
    //OverScrollNotification 和 metrics.atEdge 说明正在下拉或者 上拉
    //此处同上
    if(notification.dragDetails==null){
      return;
    }

    //如果notification.overScroll<0.0 说明是在下拉刷新，这里根据拉的距离设定高度的增加范围-->小于50时  是拖动速度的1/2，高度在50-90时 是
    //拖动速度的1/4  .........若果超过150，结束拖动，自动开始刷新，拖过刷新布局高度小于0，恢复ListView的正常拖动
    //当Item的数量不能铺满全屏时  上拉加载会引起下拉布局的出现，所以这里要判断下bottomItemHeight<0.5
    if(notification.overscroll<0.0&&bottomItemHeight<0.5 && widget.onRefresh != null){
      setState(() {
        if(notification.dragDetails.delta.dy/2+topItemHeight<=0.0){
          //Refresh回弹完毕，恢复正常ListView的滑动状态
          _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          topItemHeight=0.0;
          widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
        }else{
          if(topItemHeight>150.0){
            widget.scrollPhysicsChanged(new NeverScrollableScrollPhysics());
            animationController.forward();
          }else if(topItemHeight>90.0){
            topItemHeight=notification.dragDetails.delta.dy/6+topItemHeight;
          }else if(topItemHeight>50.0){
            _checkStateAndCallback(AnimationStates.DragAndRefreshEnabled,RefreshBoxDirectionStatus.PULL);
            topItemHeight=notification.dragDetails.delta.dy/4+topItemHeight;
          }else {
            _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,RefreshBoxDirectionStatus.PULL);
            topItemHeight=notification.dragDetails.delta.dy/2+topItemHeight;
          }
        }
      });
    }else if(topItemHeight<0.5 && widget.loadMore != null){
      setState(() {
        if(-notification.dragDetails.delta.dy/2+bottomItemHeight<=0.0){
          //Refresh回弹完毕，恢复正常ListView的滑动状态
          _checkStateAndCallback(AnimationStates.RefreshBoxIdle,RefreshBoxDirectionStatus.IDLE);
          bottomItemHeight=0.0;
          widget.scrollPhysicsChanged(new RefreshAlwaysScrollPhysics());
        }else{
          if(bottomItemHeight>75.0){
            if(isPulling){
              return;
            }
            isPulling=true;
            widget.scrollPhysicsChanged(new NeverScrollableScrollPhysics());
            animationController.forward();
          }else if(bottomItemHeight>60.0){
            bottomItemHeight=-notification.dragDetails.delta.dy/6+bottomItemHeight;
          }else if(bottomItemHeight>50.0){
            _checkStateAndCallback(AnimationStates.DragAndRefreshEnabled,RefreshBoxDirectionStatus.PUSH);
            bottomItemHeight=-notification.dragDetails.delta.dy/4+bottomItemHeight;
          }else {
            _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,RefreshBoxDirectionStatus.PUSH);
            bottomItemHeight=-notification.dragDetails.delta.dy/2+bottomItemHeight;
          }
        }
      });
    }
  }

  void _checkStateAndCallback(AnimationStates currentState,RefreshBoxDirectionStatus refreshBoxDirectionStatus){
    if(animationStates != currentState){
      // 下拉刷新回调
      if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PULL) {
        // 释放刷新
        if (currentState == AnimationStates.DragAndRefreshEnabled) {
          this._refreshHeader.getKey().currentState.onRefreshReady();
        }
        // 刷新数据
        else if (currentState == AnimationStates.StartLoadData) {
          this._refreshHeader.getKey().currentState.onRefreshing();
        }
        // 刷新完成
        else if (currentState == AnimationStates.LoadDataEnd) {
          this._refreshHeader.getKey().currentState.onRefreshed();
        }
        // 刷新重置
        else if (currentState == AnimationStates.DragAndRefreshNotEnabled) {
          this._refreshHeader.getKey().currentState.onRefreshReset();
        }
      }
      // 上拉加载
      else if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PUSH) {
        // 释放加载
        if (currentState == AnimationStates.DragAndRefreshEnabled) {
          this._refreshFooter.getKey().currentState.onLoadReady();
        }
        // 加载数据
        else if (currentState == AnimationStates.StartLoadData) {
          this._refreshFooter.getKey().currentState.onLoading();
        }
        // 加载完成
        else if (currentState == AnimationStates.LoadDataEnd) {
          this._refreshFooter.getKey().currentState.onLoaded();
        }
        // 刷新重置
        else if (currentState == AnimationStates.DragAndRefreshNotEnabled) {
          this._refreshFooter.getKey().currentState.onLoadReset();
        }
      }
      else if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.IDLE) {
        // 重置
        if (currentState == AnimationStates.RefreshBoxIdle) {
          if (lastStates == RefreshBoxDirectionStatus.PULL) {
            this._refreshHeader.getKey().currentState.onRefreshReset();
          }
          else if (lastStates == RefreshBoxDirectionStatus.PUSH) {
            this._refreshFooter.getKey().currentState.onLoadReset();
          }
        }
      }
      animationStates = currentState;
      lastStates = refreshBoxDirectionStatus;
      if(widget.animationStateChangedCallback != null){
        widget.animationStateChangedCallback(animationStates, refreshBoxDirectionStatus);
      }
    }
  }
}

/// 切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
/// 出现反向滑动时用此ScrollPhysics
class RefreshScrollPhysics extends ScrollPhysics {
  const RefreshScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  //重写这个方法为了减缓ListView滑动速度
  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if(offset<0.0){
      return 0.00000000000001;
    }
    if(offset==0.0){
      return 0.0;
    }
    return offset/2;
  }


  //此处返回null时为了取消惯性滑动
  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    return  null;
  }
}

///可去掉过度滑动时ListView顶部的蓝色光晕效果
class MyBehavior extends ScrollBehavior {

  final bool isShowLeadingGlow;
  final bool isShowTrailingGlow;
  final Color _kDefaultGlowColor;

  MyBehavior(this.isShowLeadingGlow,this.isShowTrailingGlow,this._kDefaultGlowColor);

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {

    //如果头部或底部有一个 不需要 显示光晕时 返回GlowingOverScrollIndicator
    if(!isShowLeadingGlow||!isShowTrailingGlow){
      return new  GlowingOverscrollIndicator(
        showLeading: isShowLeadingGlow,
        showTrailing: isShowTrailingGlow,
        child: child,
        axisDirection: axisDirection,
        color: _kDefaultGlowColor,
      );
    }else {
      //都需要光晕时  返回系统默认
      return super.buildViewportChrome(context, child, axisDirection);
    }
  }
}

///切记 继承ScrollPhysics  必须重写applyTo，，在NeverScrollableScrollPhysics类里面复制就可以
///此类用来控制IOS过度滑动出现弹簧效果
class RefreshAlwaysScrollPhysics extends AlwaysScrollableScrollPhysics {
  const RefreshAlwaysScrollPhysics({ ScrollPhysics parent }) : super(parent: parent);

  @override
  RefreshAlwaysScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new RefreshAlwaysScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }

  /// 防止ios设备上出现弹簧效果
  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    assert(() {
      if (value == position.pixels) {
        throw FlutterError(
            '$runtimeType.applyBoundaryConditions() was called redundantly.\n'
                'The proposed new position, $value, is exactly equal to the current position of the '
                'given ${position.runtimeType}, ${position.pixels}.\n'
                'The applyBoundaryConditions method should only be called when the value is '
                'going to actually change the pixels, otherwise it is redundant.\n'
                'The physics object in question was:\n'
                '  $this\n'
                'The position object in question was:\n'
                '  $position\n'
        );
      }
      return true;
    }());
    if (value < position.pixels && position.pixels <= position.minScrollExtent) // underScroll
      return value - position.pixels;
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) // overScroll
      return value - position.pixels;
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) // hit top edge
      return value - position.minScrollExtent;
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) // hit bottom edge
      return value - position.maxScrollExtent;
    return 0.0;
  }

  /// 防止ios设备出现卡顿
  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = this.tolerance;
    if (position.outOfRange) {
      double end;
      if (position.pixels > position.maxScrollExtent)
        end = position.maxScrollExtent;
      if (position.pixels < position.minScrollExtent)
        end = position.minScrollExtent;
      assert(end != null);
      return ScrollSpringSimulation(
          spring,
          position.pixels,
          position.maxScrollExtent,
          math.min(0.0, velocity),
          tolerance: tolerance
      );
    }
    if (velocity.abs() < tolerance.velocity)
      return null;
    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent)
      return null;
    if (velocity < 0.0 && position.pixels <= position.minScrollExtent)
      return null;
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }
}