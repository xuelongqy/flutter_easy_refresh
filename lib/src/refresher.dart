import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'header/header.dart';
import 'footer/footer.dart';
import 'behavior/behavior.dart';
import 'scrollPhysics/scroll_physics.dart';

typedef Future<void> OnRefresh();
typedef Future<void> LoadMore();
typedef void HeaderStatusChanged(HeaderStatus status);
typedef void FooterStatusChanged(FooterStatus status);
typedef void HeaderHeightChanged(double height);
typedef void FooterHeightChanged(double height);
typedef Widget TransitionBuilder(
    BuildContext context, Widget child, ScrollController scrollController);
typedef void AnimationStateChanged(AnimationStates animationStates,
    RefreshBoxDirectionStatus refreshBoxDirectionStatus);

enum RefreshBoxDirectionStatus {
  // 上拉加载的状态 分别为 闲置 上拉  下拉
  IDLE,
  PUSH,
  PULL
}

/// Header状态
enum HeaderStatus { START, READY, REFRESHING, REFRESHED, RESTORE, END, CLOSE }

/// Footer状态
enum FooterStatus {
  START,
  READY,
  LOADING,
  LOADED,
  NO_MORE,
  RESTORE,
  END,
  CLOSE
}

enum AnimationStates {
  // 未达到刷新高度
  DragAndRefreshNotEnabled,
  // 达到刷新高度
  DragAndRefreshEnabled,
  // 开始加载
  StartLoadData,
  // 加载完成
  LoadDataEnd,
  // 视图消失
  RefreshBoxIdle
}

class EasyRefresh extends StatefulWidget {
  // 加载刷新回调
  final OnRefresh onRefresh;
  final LoadMore loadMore;
  // 滚动视图
  final Widget child;
  // 滚动视图光晕
  final ScrollBehavior behavior;
  // 顶部和底部视图
  final RefreshHeader refreshHeader;
  final RefreshFooter refreshFooter;
  // 首次刷新视图
  final Widget firstRefreshWidget;
  // 空视图
  final Widget emptyWidget;
  // 状态改变回调
  final AnimationStateChanged animationStateChangedCallback;
  // Header和Footer改变回调
  final HeaderStatusChanged headerStatusChanged;
  final FooterStatusChanged footerStatusChanged;
  // Header和Footer高度改变回调
  final HeaderHeightChanged headerHeightChanged;
  final FooterHeightChanged footerHeightChanged;
  // 自动加载(滑动到底部时)
  final bool autoLoad;
  // 限制滚动
  final bool limitScroll;
  // 自动控制(用于刷新和加载完成)
  final bool autoControl;
  // 首次刷新
  final bool firstRefresh;
  // 滚动控制器
  final ScrollController outerController;
  // 列表构建器
  final TransitionBuilder builder;

  EasyRefresh(
      {GlobalKey<EasyRefreshState> key,
      this.behavior,
      this.refreshHeader,
      this.refreshFooter,
      this.firstRefreshWidget,
      this.emptyWidget,
      this.animationStateChangedCallback,
      this.headerStatusChanged,
      this.footerStatusChanged,
      this.headerHeightChanged,
      this.footerHeightChanged,
      this.onRefresh,
      this.loadMore,
      this.autoLoad: false,
      this.limitScroll: false,
      this.autoControl: true,
      this.firstRefresh: false,
      this.outerController,
      this.builder,
      @required this.child})
      : super(key: key) {
    assert(child != null);
  }

  // 获取键
  GlobalKey<EasyRefreshState> getKey() {
    return this.key;
  }

  @override
  EasyRefreshState createState() {
    return new EasyRefreshState();
  }
}

class EasyRefreshState extends State<EasyRefresh>
    with TickerProviderStateMixin<EasyRefresh> {
  // 滚动控制器
  ScrollController _scrollController;
  // 滚动形式
  ScrollPhysics _scrollPhysics;
  NeverScrollableScrollPhysics _neverScrollableScrollPhysics;
  // 顶部栏和底部栏高度
  double _topItemHeight = 0.0;
  double _bottomItemHeight = 0.0;
  // 动画控制
  Animation<double> _animation;
  AnimationController _animationController;
  double _shrinkageDistance = 0.0;
  // 触发刷新和加载动画
  Animation<double> _callRefreshAnimation;
  AnimationController _callRefreshAnimationController;
  Animation<double> _callLoadAnimation;
  AnimationController _callLoadAnimationController;
  // 超过边界动画
  Animation<double> _scrollOverAnimation;
  AnimationController _scrollOverAnimationController;
  // 出发刷新和加载的高度
  double _refreshHeight = 70.0;
  double _loadHeight = 70.0;
  // 刷新和加载的状态
  RefreshBoxDirectionStatus _states = RefreshBoxDirectionStatus.IDLE;
  RefreshBoxDirectionStatus _lastStates = RefreshBoxDirectionStatus.IDLE;
  AnimationStates _animationStates = AnimationStates.RefreshBoxIdle;
  // 刷新的状态记录
  bool _isReset = false;
  bool _isPulling = false;
  bool _isRefresh = false;
  // 记录子类条目(触发刷新和加载时记录)
  int _itemCount = 0;
  // 顶部视图
  RefreshHeader _refreshHeader;
  // 底部视图
  RefreshFooter _refreshFooter;
  // 默认顶部和底部视图
  RefreshHeader _defaultHeader = ClassicsHeader(
    key: new GlobalKey<RefreshHeaderState>(),
  );
  RefreshFooter _defaultFooter =
      ClassicsFooter(key: new GlobalKey<RefreshFooterState>());
  // 滑动速度(ms)为单位
  double scrollSpeed = 0.0;
  double lastPixels = 0.0;
  int lastTimeStamp = new DateTime.now().millisecondsSinceEpoch;
  // 是否拉出底部
  bool _isPushBottom = false;
  // 记录是否在拖动
  bool _isDrag = false;
  // 记录上一次滚动事件
  ScrollNotification _lastScrollNotification;
  // 首次刷新
  bool _firstRefresh;
  bool _firstRefreshCall = false;
  GlobalKey<RefreshHeaderState> _firstRefreshHeaderKey =
      new GlobalKey<RefreshHeaderState>();
  // 加载完成(用于判断是否有更多数据)
  bool _loaded = false;
  // 等待State回调列表
  final List<VoidCallback> _waitStateCallBackList = List();

  // 等待state更新完成
  void waitState(VoidCallback done) {
    _waitStateCallBackList.add(done);
  }

  // 触发等待state回调
  void _triggerWaitStateCallBack() {
    if (_waitStateCallBackList.isEmpty) return;
    for (var done in _waitStateCallBackList) {
      done();
    }
    _waitStateCallBackList.clear();
    // 稍作延时设置列表滚动属性
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollPhysics is RefreshAlwaysScrollPhysics) {
        setState(() {
          _scrollPhysics = _neverScrollableScrollPhysics;
        });
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            if (_isRefresh) {
              _scrollPhysics = RefreshAlwaysScrollPhysics(
                  scrollOverListener: _getScrollOverListener(),
                  headerPullBackRecord: false,
                  footerPullBackRecord: false);
            } else {
              _scrollPhysics = RefreshAlwaysScrollPhysics(
                  scrollOverListener: _getScrollOverListener(),
                  headerPullBackRecord: widget.onRefresh != null,
                  footerPullBackRecord: widget.loadMore != null);
            }
          });
        });
      }
    });
  }

  // 触发刷新
  void callRefresh() async {
    if (_isRefresh || widget.onRefresh == null) return;
    _isRefresh = true;
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: new Duration(milliseconds: 200), curve: Curves.ease);
    _callRefreshAnimationController.forward();
    _refreshHeader.getKey().currentState.onRefreshStart();
    _onHeaderStatusChanged(HeaderStatus.START);
    _refreshHeader.getKey().currentState.onRefreshReady();
    _onHeaderStatusChanged(HeaderStatus.READY);
  }

  // 触发加载
  void callLoadMore() async {
    if (_isRefresh || widget.loadMore == null) return;
    _isRefresh = true;
    _callLoadAnimationController.forward();
    _refreshFooter.getKey().currentState.onLoadStart();
    _onFooterStatusChanged(FooterStatus.START);
    _refreshFooter.getKey().currentState.onLoadReady();
    _onFooterStatusChanged(FooterStatus.READY);
  }

  // 刷新完成
  void callRefreshFinish() async {
    if (!widget.autoControl &&
        _animationStates == AnimationStates.StartLoadData) {
      if (!mounted) return;
      _checkStateAndCallback(AnimationStates.LoadDataEnd, _lastStates);
      if (_lastStates == RefreshBoxDirectionStatus.PULL) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshHeader.finishDelay));
      } else if (_lastStates == RefreshBoxDirectionStatus.PUSH) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshFooter.finishDelay));
      }
      // 开始将加载（刷新）布局缩回去的动画
      _animationController.forward();
    }
  }

  // 加载完成
  void callLoadMoreFinish() async {
    if (!widget.autoControl &&
        _animationStates == AnimationStates.StartLoadData) {
      if (!mounted) return;
      _checkStateAndCallback(AnimationStates.LoadDataEnd, _lastStates);
      if (_lastStates == RefreshBoxDirectionStatus.PULL) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshHeader.finishDelay));
      } else if (_lastStates == RefreshBoxDirectionStatus.PUSH) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshFooter.finishDelay));
      }
      // 开始将加载（刷新）布局缩回去的动画
      _animationController.forward();
    }
  }

  // 是否正在刷新
  bool get isRefreshing => _isRefresh;

  // Header和Footer状态改变回调
  void _onHeaderStatusChanged(HeaderStatus status) {
    if (widget.headerStatusChanged != null) {
      widget.headerStatusChanged(status);
    }
  }

  void _onFooterStatusChanged(FooterStatus status) {
    if (widget.footerStatusChanged != null) {
      widget.footerStatusChanged(status);
    }
  }

  // Header和Footer高度改变回调
  void _onHeaderHeightChanged(double height) {
    if (widget.headerHeightChanged != null) {
      widget.headerHeightChanged(height);
    }
  }

  void _onFooterHeightChanged(double height) {
    if (widget.footerHeightChanged != null) {
      widget.footerHeightChanged(height);
    }
  }

  // 顶部超出边界
  void _topOver() async {
    if (_isRefresh || widget.onRefresh == null) return;
    // 如果用户正在拖动则不执行
    if (_isDrag) return;
    if (widget.behavior is ScrollOverBehavior) {
      int time = (_refreshHeight * 0.9 / scrollSpeed).floor();
      if (time > 150) return;
      _scrollOverAnimationController = new AnimationController(
          duration: Duration(milliseconds: time), vsync: this);
      _scrollOverAnimation = new Tween(begin: 0.0, end: _refreshHeight * 0.9)
          .animate(_scrollOverAnimationController)
            ..addListener(() {
              if (_scrollOverAnimation.value == 0.0) return;
              setState(() {
                _setTopItemHeight(_scrollOverAnimation.value);
              });
            });
      _scrollOverAnimation.addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          setState(() {
            _setTopItemHeight(_refreshHeight * 0.9);
            _scrollPhysics = _neverScrollableScrollPhysics;
          });
          _animationController.forward();
        }
      });
      if (!_scrollOverAnimationController.isAnimating) {
        _scrollOverAnimationController.forward();
      }
    }
  }

  // 底部超出边界
  void _bottomOver() async {
    if (_isRefresh || widget.loadMore == null) return;
    // 如果用户正在拖动则不执行
    if (_isDrag) return;
    // 判断是否滑动到底部并自动加载
    if (widget.autoLoad) {
      callLoadMore();
      return;
    }
    if (!_isPushBottom && widget.behavior is ScrollOverBehavior) {
      int time = (_loadHeight * 0.9 / (-scrollSpeed)).floor();
      if (time > 150) return;
      time = time > 20 ? time : 20;
      _scrollOverAnimationController = new AnimationController(
          duration: Duration(milliseconds: time), vsync: this);
      _scrollOverAnimation = new Tween(begin: 0.0, end: _loadHeight * 0.9)
          .animate(_scrollOverAnimationController)
            ..addListener(() {
              if (_scrollOverAnimation.value == 0.0) return;
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
              _setBottomItemHeight(_scrollOverAnimation.value);
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            });
      _scrollOverAnimation.addStatusListener((animationStatus) {
        if (animationStatus == AnimationStatus.completed) {
          setState(() {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
            _bottomItemHeight = _loadHeight * 0.9;
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
            _scrollPhysics = _neverScrollableScrollPhysics;
          });
          _shrinkageDistance = _loadHeight * 0.9;
          _animationController.forward();
        }
      });
      if (!_scrollOverAnimationController.isAnimating) {
        _scrollOverAnimationController.forward();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 初始化首次刷新
    _firstRefresh = widget.firstRefresh;
    _neverScrollableScrollPhysics = NeverScrollableScrollPhysics();
    // 初始化滚动控制器
    if (widget.outerController == null) {
      _scrollController = widget.child is ScrollView &&
              (widget.child as ScrollView).controller != null
          ? (widget.child as ScrollView).controller
          : new ScrollController();
    } else {
      _scrollController = widget.outerController;
    }
    // 初始化滚动形式
    _scrollPhysics = RefreshAlwaysScrollPhysics(
        scrollOverListener: _getScrollOverListener(),
        headerPullBackRecord: widget.onRefresh != null,
        footerPullBackRecord: widget.loadMore != null);
    // 初始化刷新高度
    if (_firstRefresh && widget.firstRefreshWidget is RefreshHeader) {
      _refreshHeight =
          (widget.firstRefreshWidget as RefreshHeader).refreshHeight;
    } else {
      _refreshHeight = widget.refreshHeader == null
          ? 70.0
          : widget.refreshHeader.refreshHeight;
    }
    _loadHeight =
        widget.refreshFooter == null ? 70.0 : widget.refreshFooter.loadHeight;
    // 顶部栏和底部栏动画控制
    _animationController = new AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _animation = new Tween(begin: 1.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        //因为_animationController reset()后，addListener会收到监听，导致再执行一遍setState _topItemHeight和_bottomItemHeight会异常 所以用此标记
        //判断是reset的话就返回避免异常
        if (_isReset) {
          return;
        }
        // 根据动画的值逐渐减小布局的高度，分为4种情况
        // 1.上拉高度超过_refreshHeight    2.上拉高度不够_refreshHeight   3.下拉拉高度超过_bottomItemHeight  4.下拉拉高度不够_bottomItemHeight
        setState(() {
          if (_topItemHeight > _refreshHeight) {
            //_shrinkageDistance*animation.value是由大变小的，模拟出弹回的效果
            _setTopItemHeight(
                _refreshHeight + _shrinkageDistance * _animation.value);
          } else if (_bottomItemHeight > _loadHeight) {
            _setBottomItemHeight(
                _loadHeight + _shrinkageDistance * _animation.value);
            //高度小于50时↓
          } else if (_topItemHeight <= _refreshHeight && _topItemHeight > 0) {
            _setTopItemHeight(_shrinkageDistance * _animation.value);
          } else if (_bottomItemHeight <= _loadHeight &&
              _bottomItemHeight > 0) {
            // 如果不是加载完成或者列表底部就不用跳转到列表底部
            if (_animationStates != AnimationStates.LoadDataEnd &&
                widget.outerController == null) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            } else {
              if (_scrollController.offset -
                          _scrollController.position.maxScrollExtent <
                      _loadHeight &&
                  _scrollController.offset -
                          _scrollController.position.maxScrollExtent >
                      0.0) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            }
            // 设置底部高度
            _setBottomItemHeight(_shrinkageDistance * _animation.value);
            // 同上
            if (_animationStates != AnimationStates.LoadDataEnd &&
                widget.outerController == null) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            } else {
              if (_scrollController.offset -
                          _scrollController.position.maxScrollExtent <
                      _loadHeight &&
                  _scrollController.offset -
                          _scrollController.position.maxScrollExtent >
                      0.0) {
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              }
            }
          }
        });
      });
    _animation.addStatusListener((animationStatus) {
      if (animationStatus == AnimationStatus.completed) {
        // 还原拉出底部状态
        _isPushBottom = false;
        //动画结束时首先将_animationController重置
        _isReset = true;
        _animationController.reset();
        _isReset = false;
        //动画完成后只有2种情况，高度是50和0，如果是高度》=50的，则开始刷新或者加载操作，如果是0则恢复ListView
        setState(() {
          if (_topItemHeight >= _refreshHeight) {
            _setTopItemHeight(_refreshHeight);
            _refreshStart(RefreshBoxDirectionStatus.PULL);
          } else if (_bottomItemHeight >= _loadHeight) {
            _setBottomItemHeight(_loadHeight);
            _refreshStart(RefreshBoxDirectionStatus.PUSH);
            //动画结束，高度回到0，上下拉刷新彻底结束，ListView恢复正常
          } else if (_states == RefreshBoxDirectionStatus.PUSH) {
            _setTopItemHeight(0.0);
            _triggerWaitStateCallBack();
            setState(() {
              _scrollPhysics = RefreshAlwaysScrollPhysics(
                  scrollOverListener: _getScrollOverListener(),
                  headerPullBackRecord: widget.onRefresh != null,
                  footerPullBackRecord: widget.loadMore != null);
            });
            _states = RefreshBoxDirectionStatus.IDLE;
            _checkStateAndCallback(
                AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
            // 刷新关闭
            this._refreshHeader.getKey().currentState.onRefreshClose();
            _triggerWaitStateCallBack();
            _onHeaderStatusChanged(HeaderStatus.CLOSE);
            if (_firstRefresh) {
              setState(() {
                _firstRefresh = false;
                // 恢复刷新高度
                _refreshHeight = widget.refreshHeader == null
                    ? 70.0
                    : widget.refreshHeader.refreshHeight;
              });
            }
          } else if (_states == RefreshBoxDirectionStatus.PULL) {
            _setBottomItemHeight(0.0);
            _triggerWaitStateCallBack();
            setState(() {
              _scrollPhysics = RefreshAlwaysScrollPhysics(
                  scrollOverListener: _getScrollOverListener(),
                  headerPullBackRecord: widget.onRefresh != null,
                  footerPullBackRecord: widget.loadMore != null);
            });
            _states = RefreshBoxDirectionStatus.IDLE;
            _isPulling = false;
            _checkStateAndCallback(
                AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
            // 加载关闭
            this._refreshFooter.getKey().currentState.onLoadClose();
            _triggerWaitStateCallBack();
            _onFooterStatusChanged(FooterStatus.CLOSE);
          }
        });
      } else if (animationStatus == AnimationStatus.forward) {
        //动画开始时根据情况计算要弹回去的距离
        if (_topItemHeight > _refreshHeight) {
          _shrinkageDistance = _topItemHeight - _refreshHeight;
        } else if (_bottomItemHeight > _loadHeight) {
          _shrinkageDistance = _bottomItemHeight - _loadHeight;
          //这里必须有个动画，不然上拉加载时  ListView不会自动滑下去，导致ListView悬在半空
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: new Duration(milliseconds: 250),
              curve: Curves.linear);
        } else if (_topItemHeight <= _refreshHeight && _topItemHeight > 0.0) {
          _shrinkageDistance = _topItemHeight;
          _states = RefreshBoxDirectionStatus.PUSH;
        } else if (_bottomItemHeight <= _loadHeight &&
            _bottomItemHeight > 0.0) {
          _shrinkageDistance = _bottomItemHeight;
          _states = RefreshBoxDirectionStatus.PULL;
        }
      }
    });
    // 触发刷新动画
    _callRefreshAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _callRefreshAnimation =
        new Tween(begin: 0.0, end: 1.0).animate(_callRefreshAnimationController)
          ..addListener(() {
            if (_callRefreshAnimation.value == 0.0 &&
                _callRefreshAnimation.status != AnimationStatus.forward) return;
            setState(() {
              // 判断是否为首次刷新
              if (_firstRefreshCall) {
                _refreshHeader.getKey().currentState.onRefreshStart();
                _onHeaderStatusChanged(HeaderStatus.START);
                _refreshHeader.getKey().currentState.onRefreshReady();
                _onHeaderStatusChanged(HeaderStatus.READY);
                _firstRefreshCall = false;
              }
              _setTopItemHeight(
                  (_refreshHeight + 20.0) * _callRefreshAnimation.value);
            });
          });
    _callRefreshAnimation.addStatusListener((animationStatus) {
      if (animationStatus == AnimationStatus.completed) {
        _callRefreshAnimationController.reset();
        setState(() {
          _scrollPhysics = _neverScrollableScrollPhysics;
        });
        _animationController.forward();
      }
    });
    // 触发加载动画
    _callLoadAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    _callLoadAnimation = new Tween(begin: 0.0, end: 1.0).animate(
        _callLoadAnimationController)
      ..addListener(() {
        if (_callLoadAnimation.value == 0.0 &&
            _callLoadAnimation.status != AnimationStatus.forward) return;
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        setState(() {
          _setBottomItemHeight((_loadHeight + 20.0) * _callLoadAnimation.value);
        });
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    _callLoadAnimation.addStatusListener((animationStatus) {
      if (animationStatus == AnimationStatus.completed) {
        _callLoadAnimationController.reset();
        setState(() {
          _scrollPhysics = _neverScrollableScrollPhysics;
        });
        _animationController.forward();
      }
    });

    // 判断是否需要首次刷新
    if (_firstRefresh) {
      if (widget.onRefresh == null) return;
      _firstRefreshCall = true;
      _isRefresh = true;
      _callRefreshAnimationController.forward();
    }
  }

  // 获取越界监听
  ScrollOverListener _getScrollOverListener() {
    return ScrollOverListener(
        topOver: _topOver,
        bottomOver: _bottomOver,
        justScrollOver: widget.behavior is ScrollOverBehavior,
        refresh: widget.onRefresh != null,
        loadMore: widget.loadMore != null);
  }

  // 生成底部栏
  Widget _getFooter() {
    if (widget.loadMore != null) {
      if (widget.refreshFooter == null) {
        this._refreshFooter = _defaultFooter;
      } else {
        this._refreshFooter = widget.refreshFooter;
      }
      return this._refreshFooter;
    } else {
      return new Container();
    }
  }

  // 生成顶部栏
  Widget _getHeader() {
    if (widget.onRefresh != null) {
      if (_firstRefresh && widget.firstRefreshWidget != null) {
        if (widget.firstRefreshWidget is RefreshHeader) {
          this._refreshHeader = widget.firstRefreshWidget;
        } else {
          this._refreshHeader = FirstRefreshHeader(
              key: _firstRefreshHeaderKey, child: widget.firstRefreshWidget);
        }
      } else {
        if (widget.refreshHeader == null) {
          this._refreshHeader = _defaultHeader;
        } else {
          this._refreshHeader = widget.refreshHeader;
        }
      }
      return this._refreshHeader;
    } else {
      return new Container();
    }
  }

  void _refreshStart(
      RefreshBoxDirectionStatus refreshBoxDirectionStatus) async {
    this._isRefresh = true;
    _checkStateAndCallback(
        AnimationStates.StartLoadData, refreshBoxDirectionStatus);
    // 是否限制滚动
    setState(() {
      if (widget.limitScroll) {
        _scrollPhysics = _neverScrollableScrollPhysics;
      } else {
        _scrollPhysics = RefreshAlwaysScrollPhysics(
            scrollOverListener: _getScrollOverListener(),
            headerPullBackRecord: false,
            footerPullBackRecord: false);
      }
    });
    // 这里我们开始加载数据 数据加载完成后，将新数据处理并开始加载完成后的处理
    if (_topItemHeight > _bottomItemHeight) {
      if (widget.onRefresh != null) {
        // 调用刷新回调
        await widget.onRefresh();
        // 稍作延时(等待列表加载完成,用于界面修改数据)
        await new Future.delayed(const Duration(milliseconds: 100), () {});
      }
    } else {
      if (widget.loadMore != null) {
        // 调用加载更多
        await widget.loadMore();
        // 稍作延时(等待列表加载完成,用于界面修改数据以及判断前后条数差异)
        //await new Future.delayed(const Duration(milliseconds: 100), () {});
      }
    }
    // 判断是否自动控制
    if (widget.autoControl) {
      if (!mounted) return;
      _checkStateAndCallback(
          AnimationStates.LoadDataEnd, refreshBoxDirectionStatus);
      if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PULL) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshHeader.finishDelay));
      } else if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PUSH) {
        await Future.delayed(
            new Duration(milliseconds: this._refreshFooter.finishDelay));
      }
      if (!this.mounted) return;
      // 开始将加载（刷新）布局缩回去的动画
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _callRefreshAnimationController.dispose();
    _callLoadAnimationController.dispose();
    if (_scrollOverAnimationController != null) {
      _scrollOverAnimationController.dispose();
    }
    super.dispose();
  }

  // 设置Header和Footer的拉动高度
  void _setTopItemHeight(double height) {
    setState(() {
      _topItemHeight = height;
      if (this._refreshHeader != null) {
        this._refreshHeader.getKey().currentState.updateHeight(_topItemHeight);
        _onHeaderHeightChanged(_topItemHeight);
      }
    });
  }

  void _setBottomItemHeight(double height) {
    setState(() {
      _bottomItemHeight = height;
      if (this._refreshFooter != null) {
        this
            ._refreshFooter
            .getKey()
            .currentState
            .updateHeight(_bottomItemHeight);
        _onFooterHeightChanged(_bottomItemHeight);
      }
    });
  }

  // 计算滑动速度
  void computeScrollSpeed(double pixels) async {
    int nowTimeStamp = new DateTime.now().millisecondsSinceEpoch;
    int time = nowTimeStamp - lastTimeStamp;
    if (time != 0) {
      double nowScrollSpeed = (lastPixels - pixels) / time;
      if (nowScrollSpeed != 0) {
        scrollSpeed = nowScrollSpeed;
      }
    }
    lastPixels = pixels;
    lastTimeStamp = nowTimeStamp;
  }

  // 滚动更新通知
  void _handleScrollUpdateNotification(ScrollUpdateNotification notification) {
    // 当上拉加载时，不知道什么原因，dragDetails可能会为空，导致抛出异常，会发生很明显的卡顿，所以这里必须判空
    if (notification.dragDetails == null) {
      // 解决下拉过快触发向上滚动导致回弹变慢问题
      if (_lastScrollNotification is OverscrollNotification &&
          _isDrag &&
          (_topItemHeight > 0.0)) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        _handleScrollEndNotification();
      }
      _isDrag = false;
      return;
    }
    _isDrag = true;
    // Header刷新的布局可见时，且当手指反方向拖动（由下向上），notification 为 ScrollUpdateNotification，这个时候让头部刷新布局的高度+delta.dy(此时dy为负数)
    // 来缩小头部刷新布局的高度，当完全看不见时，将scrollPhysics设置为RefreshAlwaysScrollPhysics，来保持ListView的正常滑动
    if (_topItemHeight > 0.0) {
      setState(() {
        //  如果头部的布局高度<0时，将_topItemHeight=0；并恢复ListView的滑动
        if (_topItemHeight + notification.dragDetails.delta.dy / 2 <= 0.0) {
          _checkStateAndCallback(
              AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
          _setTopItemHeight(0.0);
          setState(() {
            _scrollPhysics = RefreshAlwaysScrollPhysics(
                scrollOverListener: _getScrollOverListener(),
                headerPullBackRecord: widget.onRefresh != null,
                footerPullBackRecord: widget.loadMore != null);
          });
        } else {
          // 当刷新布局可见时，让头部刷新布局的高度+delta.dy(此时dy为负数)，来缩小头部刷新布局的高度
          _setTopItemHeight(
              _topItemHeight + notification.dragDetails.delta.dy / 2);
        }
        // 如果小于刷新高度则恢复下拉刷新
        if (_topItemHeight < _refreshHeight) {
          _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,
              RefreshBoxDirectionStatus.PULL);
        }
      });
    } else if (_bottomItemHeight > 0.0) {
      // 底部的布局可见时 ，且手指反方向拖动（由上向下），这时notification 为 ScrollUpdateNotification，这个时候让底部加载布局的高度-delta.dy(此时dy为正数数)
      // 来缩小底部加载布局的高度，当完全看不见时，将scrollPhysics设置为RefreshAlwaysScrollPhysics，来保持ListView的正常滑动
      setState(() {
        //如果底部的布局高度<0时，_bottomItemHeight=0；并恢复ListView的滑动
        if (_bottomItemHeight - notification.dragDetails.delta.dy / 2 <= 0.0) {
          _checkStateAndCallback(
              AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
          _setBottomItemHeight(0.0);
          setState(() {
            _scrollPhysics = RefreshAlwaysScrollPhysics(
                scrollOverListener: _getScrollOverListener(),
                headerPullBackRecord: widget.onRefresh != null,
                footerPullBackRecord: widget.loadMore != null);
          });
        } else {
          if (notification.dragDetails.delta.dy > 0) {
            //当加载的布局可见时，让上拉加载布局的高度-delta.dy(此时dy为正数数)，来缩小底部的加载布局的高度
            _setBottomItemHeight(
                _bottomItemHeight - notification.dragDetails.delta.dy / 2);
          }
        }
        // 如果小于加载高度则恢复加载
        if (_bottomItemHeight < _loadHeight) {
          _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,
              RefreshBoxDirectionStatus.PUSH);
        }
      });
    }
  }

  // 结束滚动通知
  void _handleScrollEndNotification() {
    // 如果滑动结束后（手指抬起来后），判断是否需要启动加载或者刷新的动画
    if ((_topItemHeight > 0 || _bottomItemHeight > 0)) {
      if (_isPulling) {
        return;
      }
      // 这里在动画开始时，做一个标记，表示上拉加载正在进行，因为在超出底部和头部刷新布局的高度后，高度会自动弹回，ListView也会跟着运动，
      // 返回结束时，ListView的运动也跟着结束，会触发ScrollEndNotification，导致再次启动动画，而发生BUG
      if (_bottomItemHeight > 0) {
        _isPulling = true;
      }
      if (!_animationController.isAnimating) {
        // 启动动画后，ListView不可滑动
        _scrollPhysics = _neverScrollableScrollPhysics;
        _animationController.forward();
      }
    }
  }

  // 手势变换通知
  void _handleUserScrollNotification(UserScrollNotification notification) {
    if (_bottomItemHeight > 0.0 &&
        notification.direction == ScrollDirection.forward) {
      // 底部加载布局出现反向滑动时（由上向下），将scrollPhysics置为RefreshScrollPhysics，只要有2个原因。1 减缓滑回去的速度，2 防止手指快速滑动时出现惯性滑动
      setState(() {
        _scrollPhysics = RefreshScrollPhysics(
            _refreshFooter == null ? false : _refreshFooter.isFloat);
      });
    } else if (_topItemHeight > 0.0 &&
        notification.direction == ScrollDirection.reverse) {
      // 头部刷新布局出现反向滑动时（由下向上）
      setState(() {
        _scrollPhysics = RefreshScrollPhysics(
            _refreshFooter == null ? false : _refreshFooter.isFloat);
      });
    } else if (_bottomItemHeight > 0.0 &&
        notification.direction == ScrollDirection.reverse) {
      // 反向再反向（恢复正向拖动）
      setState(() {
        _scrollPhysics = RefreshAlwaysScrollPhysics(
            scrollOverListener: _getScrollOverListener(),
            headerPullBackRecord: widget.onRefresh != null,
            footerPullBackRecord: widget.loadMore != null);
      });
    }
  }

  // 超出边界通知
  void _handleOverScrollNotification(OverscrollNotification notification) {
    //OverScrollNotification 和 metrics.atEdge 说明正在下拉或者 上拉
    // 此处同上
    if (notification.dragDetails == null) {
      _isDrag = false;
      return;
    }
    _isDrag = true;
    // 如果notification.overScroll<0.0 说明是在下拉刷新，这里根据拉的距离设定高度的增加范围-->刷新高度时  是拖动速度的1/2，高度在刷新高度及大于40时 是
    // 拖动速度的1/4  .........若果超过100+刷新高度，结束拖动，自动开始刷新，拖过刷新布局高度小于0，恢复ListView的正常拖动
    // 当Item的数量不能铺满全屏时  上拉加载会引起下拉布局的出现，所以这里要判断下_bottomItemHeight<0.5
    if (notification.overscroll < 0.0 &&
        _bottomItemHeight < 0.5 &&
        widget.onRefresh != null) {
      setState(() {
        if (notification.dragDetails.delta.dy / 2 + _topItemHeight <= 0.0) {
          // Refresh回弹完毕，恢复正常ListView的滑动状态
          _checkStateAndCallback(
              AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
          _setTopItemHeight(0.0);
          setState(() {
            _scrollPhysics = RefreshAlwaysScrollPhysics(
                scrollOverListener: _getScrollOverListener(),
                headerPullBackRecord: widget.onRefresh != null,
                footerPullBackRecord: widget.loadMore != null);
          });
        } else {
          if (_topItemHeight > 1000.0 + _refreshHeight) {
            setState(() {
              _scrollPhysics = _neverScrollableScrollPhysics;
            });
            _animationController.forward();
          } else if (_topItemHeight > 40.0 + _refreshHeight) {
            _setTopItemHeight(
                notification.dragDetails.delta.dy / 6 + _topItemHeight);
          } else if (_topItemHeight > _refreshHeight) {
            _checkStateAndCallback(AnimationStates.DragAndRefreshEnabled,
                RefreshBoxDirectionStatus.PULL);
            _setTopItemHeight(
                notification.dragDetails.delta.dy / 4 + _topItemHeight);
          } else {
            _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,
                RefreshBoxDirectionStatus.PULL);
            _setTopItemHeight(
                notification.dragDetails.delta.dy / 2 + _topItemHeight);
          }
        }
      });
    } else if (_topItemHeight < 0.5 && widget.loadMore != null) {
      setState(() {
        if (-notification.dragDetails.delta.dy / 2 + _bottomItemHeight <= 0.0) {
          // Refresh回弹完毕，恢复正常ListView的滑动状态
          _checkStateAndCallback(
              AnimationStates.RefreshBoxIdle, RefreshBoxDirectionStatus.IDLE);
          _setBottomItemHeight(0.0);
          setState(() {
            _scrollPhysics = RefreshAlwaysScrollPhysics(
                scrollOverListener: _getScrollOverListener(),
                headerPullBackRecord: widget.onRefresh != null,
                footerPullBackRecord: widget.loadMore != null);
          });
        } else {
          // 拉出底部
          _isPushBottom = true;
          if (_bottomItemHeight > 500.0 + _loadHeight &&
              widget.outerController == null) {
            if (_isPulling) {
              return;
            }
            _isPulling = true;
            // 如果是触发刷新则设置延时，等待列表高度渲染完成
            if (_isRefresh) {
              new Future.delayed(const Duration(milliseconds: 200), () async {
                if (!this.mounted) return;
                setState(() {
                  _scrollPhysics = _neverScrollableScrollPhysics;
                });
                _animationController.forward();
              });
            } else {
              setState(() {
                _scrollPhysics = _neverScrollableScrollPhysics;
              });
              _animationController.forward();
            }
          } else if (_bottomItemHeight > 30.0 + _loadHeight) {
            _setBottomItemHeight(
                -notification.dragDetails.delta.dy / 4 + _bottomItemHeight);
          } else if (_bottomItemHeight > _loadHeight) {
            _checkStateAndCallback(AnimationStates.DragAndRefreshEnabled,
                RefreshBoxDirectionStatus.PUSH);
            _setBottomItemHeight(
                -notification.dragDetails.delta.dy / 3 + _bottomItemHeight);
          } else {
            _checkStateAndCallback(AnimationStates.DragAndRefreshNotEnabled,
                RefreshBoxDirectionStatus.PUSH);
            _setBottomItemHeight(
                -notification.dragDetails.delta.dy / 2 + _bottomItemHeight);
          }
        }
      });
    }
  }

  // 状态变更
  void _checkStateAndCallback(AnimationStates currentState,
      RefreshBoxDirectionStatus refreshBoxDirectionStatus) {
    if (_animationStates != currentState) {
      // 下拉刷新回调
      if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PULL) {
        // 释放刷新
        if (currentState == AnimationStates.DragAndRefreshEnabled) {
          this._refreshHeader.getKey().currentState.onRefreshReady();
          _onHeaderStatusChanged(HeaderStatus.READY);
        }
        // 刷新数据
        else if (currentState == AnimationStates.StartLoadData) {
          this._refreshHeader.getKey().currentState.onRefreshing();
          _onHeaderStatusChanged(HeaderStatus.REFRESHING);
        }
        // 刷新完成
        else if (currentState == AnimationStates.LoadDataEnd) {
          this._refreshHeader.getKey().currentState.onRefreshed();
          _onHeaderStatusChanged(HeaderStatus.REFRESHED);
          _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: new Duration(milliseconds: 200),
              curve: Curves.ease);
        } else if (currentState == AnimationStates.DragAndRefreshNotEnabled) {
          if (_animationStates == AnimationStates.RefreshBoxIdle) {
            // 开始刷新
            this._refreshHeader.getKey().currentState.onRefreshStart();
            _onHeaderStatusChanged(HeaderStatus.START);
          } else {
            // 刷新重置
            this._refreshHeader.getKey().currentState.onRefreshRestore();
            _onHeaderStatusChanged(HeaderStatus.RESTORE);
          }
        }
      }
      // 上拉加载
      else if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.PUSH) {
        // 释放加载
        if (currentState == AnimationStates.DragAndRefreshEnabled) {
          this._refreshFooter.getKey().currentState.onLoadReady();
          _onFooterStatusChanged(FooterStatus.READY);
        }
        // 加载数据
        else if (currentState == AnimationStates.StartLoadData) {
          this._refreshFooter.getKey().currentState.onLoading();
          _onFooterStatusChanged(FooterStatus.LOADING);
          if (widget.child is ScrollView) {
            // 记录当前条数
            if ((widget.child as ScrollView).semanticChildCount == null &&
                widget.child is CustomScrollView) {
              this._itemCount =
                  (widget.child as CustomScrollView).slivers.length;
            } else {
              this._itemCount = (widget.child as ScrollView).semanticChildCount;
            }
          } else {
            this._itemCount = 1;
          }
        }
        // 加载完成
        else if (currentState == AnimationStates.LoadDataEnd) {
          setState(() {
            _loaded = true;
          });
          // 判断是否加载出更多数据
//          int currentItemCount = 0;
//          if (widget.child is ScrollView) {
//            if ((widget.child as ScrollView).semanticChildCount == null && widget.child is CustomScrollView) {
//              currentItemCount = (widget.child as CustomScrollView).slivers.length;
//            }else {
//              currentItemCount = (widget.child as ScrollView).semanticChildCount;
//            }
//            if (currentItemCount > this._itemCount) {
//              this._refreshFooter.getKey().currentState.onLoaded();
//            }else {
//              this._refreshFooter.getKey().currentState.onNoMore();
//            }
//            this._itemCount = currentItemCount;
//          }else {
//            this._itemCount = 1;
//            this._refreshFooter.getKey().currentState.onLoaded();
//          }
        } else if (currentState == AnimationStates.DragAndRefreshNotEnabled) {
          if (_animationStates == AnimationStates.RefreshBoxIdle) {
            // 开始加载
            this._refreshFooter.getKey().currentState.onLoadStart();
            _onFooterStatusChanged(FooterStatus.START);
          } else {
            // 加载重置
            this._refreshFooter.getKey().currentState.onLoadRestore();
            _onFooterStatusChanged(FooterStatus.RESTORE);
          }
        }
      } else if (refreshBoxDirectionStatus == RefreshBoxDirectionStatus.IDLE) {
        _isRefresh = false;
        // 重置
        if (currentState == AnimationStates.RefreshBoxIdle) {
          if (_lastStates == RefreshBoxDirectionStatus.PULL) {
            this._refreshHeader.getKey().currentState.onRefreshEnd();
            _onHeaderStatusChanged(HeaderStatus.END);
          } else if (_lastStates == RefreshBoxDirectionStatus.PUSH) {
            this._refreshFooter.getKey().currentState.onLoadEnd();
            _onFooterStatusChanged(FooterStatus.END);
          }
        }
      }
      _animationStates = currentState;
      _lastStates = refreshBoxDirectionStatus;
      if (widget.animationStateChangedCallback != null) {
        widget.animationStateChangedCallback(
            _animationStates, refreshBoxDirectionStatus);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 更新刷新高度
    if (_firstRefresh && widget.firstRefreshWidget is RefreshHeader) {
      _refreshHeight =
          (widget.firstRefreshWidget as RefreshHeader).refreshHeight;
    } else {
      _refreshHeight = widget.refreshHeader == null
          ? 70.0
          : widget.refreshHeader.refreshHeight;
    }
    _loadHeight =
        widget.refreshFooter == null ? 70.0 : widget.refreshFooter.loadHeight;
    // 获取Header和Footer
    Widget header = _getHeader();
    Widget footer = _getFooter();
    List<Widget> slivers;
    Widget body = widget.child;
    if (body is ScrollView) {
      // ignore: invalid_use_of_protected_member
      slivers = new List.from(body.buildSlivers(context), growable: true);
      // 是否添加空视图
      if (widget.emptyWidget != null && body.semanticChildCount == 0) {
        slivers.add(SliverList(
            delegate: SliverChildListDelegate(<Widget>[widget.emptyWidget])));
      }
      // 判断是否为加载更多
      if (_loaded) {
        if (body.semanticChildCount == null) {
          new Future.delayed(const Duration(milliseconds: 100), () {
            this._refreshFooter.getKey().currentState.onLoaded();
            _onFooterStatusChanged(FooterStatus.LOADED);
          });
        } else if (body.semanticChildCount > this._itemCount) {
          new Future.delayed(const Duration(milliseconds: 100), () {
            this._refreshFooter.getKey().currentState.onLoaded();
            _onFooterStatusChanged(FooterStatus.LOADED);
          });
        } else {
          new Future.delayed(const Duration(milliseconds: 100), () {
            this._refreshFooter.getKey().currentState.onNoMore();
            _onFooterStatusChanged(FooterStatus.NO_MORE);
          });
        }
        _loaded = false;
      }
      // 记录列表项
      this._itemCount = body.semanticChildCount;
    } else {
      slivers = new List<Widget>();
      slivers
          .add(SliverList(delegate: SliverChildListDelegate(<Widget>[body])));
    }
    // 构建列表
    var listChild = CustomScrollView(
      semanticChildCount: widget.child is ScrollView
          ? (widget.child as ScrollView).semanticChildCount
          : 1,
      controller: widget.outerController == null ? _scrollController : null,
      physics: _scrollPhysics,
      slivers: new List.from(slivers, growable: true),
    );
    var listWidget = widget.builder == null
        ? listChild
        : widget.builder(
            context,
            listChild,
            widget.outerController == null
                ? _scrollController
                : widget.outerController);
    return new Container(
      child: Stack(
        children: <Widget>[
          new Column(
            children: <Widget>[
              widget.onRefresh == null || !(header as RefreshHeader).isFloat
                  ? header
                  : new Container(),
              new Expanded(
                flex: 1,
                child: new NotificationListener(
                  onNotification: (ScrollNotification notification) {
                    // 判断是否正在加载
                    if (_isRefresh) return true;
                    ScrollMetrics metrics = notification.metrics;
                    computeScrollSpeed(metrics.pixels);
                    if (notification is ScrollStartNotification) {
                      if (notification.dragDetails != null) {
                        _isDrag = true;
                      }
                    } else if (notification is ScrollUpdateNotification) {
                      _handleScrollUpdateNotification(notification);
                    } else if (notification is ScrollEndNotification) {
                      _handleScrollEndNotification();
                    } else if (notification is UserScrollNotification) {
                      _handleUserScrollNotification(notification);
                      // } else if (metrics.atEdge && notification is OverscrollNotification) { // 加上metrics.atEdge验证，多次滑动会导致加载卡住
                    } else if (notification is OverscrollNotification) {
                      _handleOverScrollNotification(notification);
                    }
                    _lastScrollNotification = notification;
                    return false;
                  },
                  child: ScrollConfiguration(
                    behavior: widget.behavior ?? new RefreshBehavior(),
                    child: listWidget,
                  ),
                ),
              ),
              widget.loadMore == null || !(footer as RefreshFooter).isFloat
                  ? footer
                  : new Container(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: widget.onRefresh != null && (header as RefreshHeader).isFloat
                ? header
                : new Container(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: widget.loadMore != null && (footer as RefreshFooter).isFloat
                ? footer
                : new Container(),
          ),
        ],
      ),
    );
  }
}
