import 'dart:async';

import 'package:example/page/sample/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 聊天界面示例
class ChatPage extends StatefulWidget {
  @override
  ChatPageState createState() {
    return ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  // 信息列表
  List<MessageEntity> _msgList;

  // 输入框
  TextEditingController _textEditingController;
  // 滚动控制器
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _msgList = [
      MessageEntity(true, "It's good!"),
      MessageEntity(false, 'EasyRefresh'),
    ];
    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      setState(() {});
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
  }

  // 发送消息
  void _sendMsg(String msg) {
    setState(() {
      _msgList.insert(0, MessageEntity(true, msg));
    });
    _scrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KnoYo'),
        centerTitle: false,
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return UserProfilePage();
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          Divider(
            height: 0.5,
          ),
          Expanded(
            flex: 1,
            child: EasyRefresh.custom(
              scrollController: _scrollController,
              reverse: true,
              footer: CustomFooter(
                  enableInfiniteLoad: true,
                  extent: 40.0,
                  triggerDistance: 50.0,
                  footerBuilder: (context,
                      loadState,
                      pulledExtent,
                      loadTriggerPullDistance,
                      loadIndicatorExtent,
                      axisDirection,
                      float,
                      completeDuration,
                      enableInfiniteLoad,
                      success,
                      noMore) {
                    return Stack(
                      children: <Widget>[
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            child: SpinKitCircle(
                              color: Colors.green,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildMsg(_msgList[index]);
                    },
                    childCount: _msgList.length,
                  ),
                ),
              ],
              onLoad: () async {
                await Future.delayed(Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _msgList.addAll([
                        MessageEntity(true, "It's good!"),
                        MessageEntity(false, 'EasyRefresh'),
                      ]);
                    });
                  }
                });
              },
            ),
          ),
          SafeArea(
            child: Container(
              color: Colors.grey[100],
              padding: EdgeInsets.only(
                left: 15.0,
                right: 15.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                          4.0,
                        )),
                      ),
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                            top: 2.0,
                            bottom: 2.0,
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          if (_textEditingController.text.isNotEmpty) {
                            _sendMsg(_textEditingController.text);
                            _textEditingController.text = '';
                          }
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_textEditingController.text.isNotEmpty) {
                        _sendMsg(_textEditingController.text);
                        _textEditingController.text = '';
                      }
                    },
                    child: Container(
                      height: 30.0,
                      width: 60.0,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        left: 15.0,
                      ),
                      decoration: BoxDecoration(
                        color: _textEditingController.text.isEmpty
                            ? Colors.grey
                            : Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(
                          4.0,
                        )),
                      ),
                      child: Text(
                        S.of(context).send,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建消息视图
  Widget _buildMsg(MessageEntity entity) {
    if (entity == null || entity.own == null) {
      return Container();
    }
    if (entity.own) {
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  S.of(context).me,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  child: Text(
                    entity.msg ?? '',
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
            Card(
              margin: EdgeInsets.only(
                left: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child: Image.asset('assets/image/head.jpg'),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.all(
          10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              margin: EdgeInsets.only(
                right: 10.0,
              ),
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              elevation: 0.0,
              child: Container(
                height: 40.0,
                width: 40.0,
                child: Image.asset('assets/image/head_knoyo.jpg'),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'KnoYo',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13.0,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 5.0,
                  ),
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                      4.0,
                    )),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: 200.0,
                  ),
                  child: Text(
                    entity.msg ?? '',
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }
}

/// 信息实体
class MessageEntity {
  bool own;
  String msg;

  MessageEntity(this.own, this.msg);
}
