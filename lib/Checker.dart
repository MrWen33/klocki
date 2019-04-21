import 'package:flutter/material.dart';

class Checker extends StatelessWidget{
  const Checker({
    Key key,
    this.color: Colors.black12,
    @required this.blockWidth,
    @required this.width,
    @required this.height,
    this.onTap,
    this.onDragDown,
    this.onDragEnd,
    this.onDragCancel,
    this.onDragUpdate
  }): super(key: key);

  final Function onTap;
  final Function onDragDown;
  final Function onDragEnd;
  final Function onDragCancel;
  final Function onDragUpdate;

  final Color color;
  final int width;
  final int height;
  final double blockWidth;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var checker = new Container(
      decoration: new BoxDecoration(
        color: this.color,
        border: new Border.all(width: 2, color: Colors.black12)
      ),
      width: this.width*this.blockWidth,
      height: this.height*this.blockWidth,
    );
    return new GestureDetector(
      onTap: this.onTap,
      onHorizontalDragDown: onDragDown,
      onVerticalDragDown: onDragDown,
      onHorizontalDragCancel: onDragCancel,
      onVerticalDragCancel: onDragCancel,
      onHorizontalDragEnd: onDragEnd,
      onVerticalDragEnd: onDragEnd,
      onVerticalDragUpdate: onDragUpdate,
      onHorizontalDragUpdate: onDragUpdate,
      child: checker,
    );
  }
}