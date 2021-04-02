import 'package:flutter/material.dart';

/// 简单列表项
class SampleListItem extends StatelessWidget {
  /// 方向
  final Axis direction;

  /// 宽度
  final double width;

  const SampleListItem({
    Key? key,
    this.direction = Axis.vertical,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return direction == Axis.vertical
        ? Card(
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                        padding: EdgeInsets.all(
                          10.0,
                        ),
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 120.0,
                                      height: 15.0,
                                      color: Colors.grey[200],
                                    ),
                                    Container(
                                      width: 60.0,
                                      height: 10.0,
                                      margin: EdgeInsets.only(top: 8.0),
                                      color: Colors.grey[200],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.grey[200],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 10.0,
                                  color: Colors.grey[200],
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Container(
                                  height: 10.0,
                                  color: Colors.grey[200],
                                ),
                                SizedBox(
                                  height: 4.0,
                                ),
                                Container(
                                  height: 10.0,
                                  width: 150.0,
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          )
        : Card(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100.0,
                    width: width,
                    color: Colors.grey[200],
                  ),
                  Container(
                    width: width,
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 80.0,
                                  height: 15.0,
                                  color: Colors.grey[200],
                                ),
                                Container(
                                  width: 60.0,
                                  height: 10.0,
                                  margin: EdgeInsets.only(top: 8.0),
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.grey[200],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 10.0,
                              color: Colors.grey[200],
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Container(
                              height: 10.0,
                              color: Colors.grey[200],
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Container(
                              height: 10.0,
                              width: 100.0,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
