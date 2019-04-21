import 'package:flutter/material.dart';

class CheckerInfo{
  CheckerInfo({
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
    this.isTarget: false
  }
      );
  //横轴为X, 纵轴为Y
  int x;
  int y;
  //长宽(单位:格子)
  int width;
  int height;
  //是否是曹操
  bool isTarget;
}