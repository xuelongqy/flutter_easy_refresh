import 'package:flutter/material.dart';

/// 简单列表项
class SampleListItem extends StatelessWidget {
  const SampleListItem({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          padding: EdgeInsets.all(15.0,),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 48.0,
                    height: 48.0,
                    margin: EdgeInsets.only(right: 20.0,),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: new BorderRadius.all(new Radius.circular(24.0)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        height: 15.0,
                        color: Colors.grey[300],
                      ),
                      Container(
                        width: 60.0,
                        height: 10.0,
                        margin: EdgeInsets.only(top: 8.0),
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Icon(Icons.star,
                    color: Colors.grey[300],
                  )
                ],
              ),
              SizedBox(height: 8.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 10.0,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 4.0,),
                  Container(
                    height: 10.0,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 4.0,),
                  Container(
                    height: 10.0,
                    width: 200.0,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}