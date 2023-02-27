import 'dart:math' as math;

import 'package:example/page/sample/user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _listenable = IndicatorStateListenable();
  late final TextEditingController _inputController;

  bool _shrinkWrap = false;
  double? _viewportDimension;

  final List<MessageEntity> _messages = [
    MessageEntity(
      own: true,
      msg: "It's good!",
    ),
    MessageEntity(
      own: false,
      img: 'assets/image/user_head.jpg',
      msg: "EasyRefresh",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _inputController.addListener(() {
      setState(() {});
    });
    _listenable.addListener(_onHeaderChange);
  }

  @override
  void dispose() {
    _listenable.removeListener(_onHeaderChange);
    _inputController.dispose();
    super.dispose();
  }

  void _onHeaderChange() {
    final state = _listenable.value;
    if (state != null) {
      final position = state.notifier.position;
      _viewportDimension ??= position.viewportDimension;
      final shrinkWrap = state.notifier.position.maxScrollExtent == 0;
      if (_shrinkWrap != shrinkWrap &&
          _viewportDimension == position.viewportDimension) {
        setState(() {
          _shrinkWrap = shrinkWrap;
        });
      }
    }
  }

  void _onSend() {
    if (_inputController.text.isEmpty) {
      return;
    }
    setState(() {
      _messages.insert(
          0,
          MessageEntity(
            own: true,
            msg: _inputController.text,
          ));
    });
    _inputController.clear();
    Future(() {
      PrimaryScrollController.of(context).jumpTo(0);
    });
  }

  Widget _buildMessageItem(int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final themeData = Theme.of(context);
        final message = _messages[index];
        final maxWidth = math.min(constraints.maxWidth - 124, 400.0);
        Widget? imgWidget;
        Widget? msgWidget;
        bool continuously =
            index != 0 && _messages[index - 1].own == message.own;
        if (message.img != null) {
          imgWidget = LayoutBuilder(
            builder: (context, c) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeData.colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Image.asset(message.img!),
              );
            },
          );
        }
        if (message.msg != null) {
          msgWidget = Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: message.own
                  ? themeData.colorScheme.primaryContainer
                  : themeData.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft:
                    Radius.circular(message.own || continuously ? 24 : 8),
                bottomRight:
                    Radius.circular(message.own && !continuously ? 8 : 24),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Text(message.msg!),
          );
        }
        Widget contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imgWidget != null) imgWidget,
            if (imgWidget != null && msgWidget != null)
              const SizedBox(
                height: 8,
              ),
            if (msgWidget != null) msgWidget,
          ],
        );
        return Container(
          margin: EdgeInsets.only(
              top: 8, bottom: continuously ? 0 : 8, left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.own) const Spacer(),
              if (!message.own)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipOval(
                    child: continuously
                        ? const SizedBox(
                            width: 36,
                          )
                        : InkWell(
                            onTap: () {
                              Get.to(() => const UserProfilePage());
                            },
                            child: Image.asset(
                              'assets/image/user_head.jpg',
                              height: 36,
                              width: 36,
                            ),
                          ),
                  ),
                ),
              contentWidget,
              if (!message.own) const Spacer(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Codiss'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Get.to(() => const UserProfilePage());
              },
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: EasyRefresh(
                clipBehavior: Clip.none,
                onRefresh: () {},
                onLoad: () {
                  return Future.delayed(const Duration(seconds: 2), () {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _messages.addAll([
                        MessageEntity(
                          own: true,
                          msg: "It's good!",
                        ),
                        MessageEntity(
                          own: false,
                          img: 'assets/image/user_head.jpg',
                          msg: "EasyRefresh",
                        ),
                      ]);
                    });
                  });
                },
                header: ListenerHeader(
                  listenable: _listenable,
                  triggerOffset: 100000,
                  clamping: false,
                ),
                footer: BuilderFooter(
                    triggerOffset: 40,
                    clamping: false,
                    position: IndicatorPosition.above,
                    infiniteOffset: null,
                    processedDuration: Duration.zero,
                    builder: (context, state) {
                      return Stack(
                        children: [
                          SizedBox(
                            height: state.offset,
                            width: double.infinity,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: 40,
                              child: SpinKitCircle(
                                size: 24,
                                color: themeData.colorScheme.primary,
                              ),
                            ),
                          )
                        ],
                      );
                    }),
                child: CustomScrollView(
                  reverse: true,
                  shrinkWrap: _shrinkWrap,
                  clipBehavior: Clip.none,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildMessageItem(index);
                        },
                        childCount: _messages.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: themeData.colorScheme.onInverseSurface,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      color: themeData.colorScheme.primary,
                      icon: const Icon(Icons.add_circle_outline),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      onPressed: () {},
                      color: themeData.colorScheme.primary,
                      icon: const Icon(Icons.tag_faces),
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _inputController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: themeData.colorScheme.surfaceVariant,
                            prefixIcon: const Icon(Icons.abc),
                            suffixIcon: IconButton(
                              onPressed: () {
                                if (_inputController.text.isNotEmpty) {
                                  _onSend();
                                }
                              },
                              icon: Icon(_inputController.text.isNotEmpty
                                  ? Icons.send
                                  : Icons.keyboard_voice_outlined),
                            ),
                          ),
                          onSubmitted: (_) => _onSend(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageEntity {
  bool own;
  String? msg;
  String? img;

  MessageEntity({
    required this.own,
    required this.msg,
    this.img,
  });
}
