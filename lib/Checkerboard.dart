import 'package:flutter/material.dart';
import 'dart:core';
import './Checker.dart';
import './CheckerInfo.dart';

class Checkerboard extends StatefulWidget{
  Checkerboard({
    Key key,
    this.row: 5,
    this.column: 4,
    this.exitX: 1,
    this.exitY: 0,
    this.onWin,
    @required this.initState
  });

  final Function onWin;
  final int row;
  final int column;
  final int exitX;
  final int exitY;
  final List<CheckerInfo> initState;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    CheckerboardModel model = new CheckerboardModel(initState, row, column, exitX, exitY);
    model.registerWinCallback(this.onWin);
    var con = InputCheckerboardController(model);
    return con.getView();
  }
}

class DIR{
  static const UP=0;
  static const DOWN=1;
  static const LEFT=2;
  static const RIGHT=3;
}

abstract class ICheckerboardModel{
  void initialize();
  List<CheckerInfo> getBoardInfo();
  bool attemptMoveChess(int ID, int dir);

  registerBlockObserver(BlockObserver observer);
  removeBlockObserver(BlockObserver observer);
  registerWinCallback(Function callback);
  removeWinCallback(Function callback);
}

class CheckerboardModel implements ICheckerboardModel{
  var checkersStates = <CheckerInfo>[];
  var checkerMap = <CheckerInfo>[];//记录棋盘上的位置有方块占据或没有
  CheckerInfo targetChecker;

  int row;
  int column;
  int exitX;
  int exitY;

  var blockObservers = <BlockObserver>[];
  var winCallbacks = <Function>[];

  @override
  List<CheckerInfo> getBoardInfo(){
    return checkersStates;
  }

  registerBlockObserver(BlockObserver observer){
    blockObservers.add(observer);
  }
  removeBlockObserver(BlockObserver observer){
    blockObservers.remove(observer);
  }
  registerWinCallback(Function callback){
    winCallbacks.add(callback);
  }
  removeWinCallback(Function callback){
    winCallbacks.remove(callback);
  }

  notifyAllBlockObservers(){
    for(var o in blockObservers){
      o.notify();
    }
  }

  notifyAllWinObservers(){
    for(var f in winCallbacks){
      f();
    }
  }

  CheckerboardModel(List<CheckerInfo> initState, int row, int column, int exitX, int exitY){
    initCheckerMap(initState, row, column);
    this.exitX = exitX;
    this.exitY = exitY;
  }

  @override
  void initialize() {
  }

  int posToInd(int x, int y){
    return y*column+x;
  }

  void initCheckerMap(List<CheckerInfo> initState, int row, int column){
    this.row = row;
    this.column = column;
    checkersStates = initState;
    for(var i=0;i<row*column;++i){
      checkerMap.add(null);
    }
    for(var st in checkersStates){
      if(st.isTarget){
        targetChecker = st;
      }
      for(var i=0;i<st.width;++i){
        for(var j=0;j<st.height;++j){
          checkerMap[posToInd(st.x+i, st.y+j)] = st;
        }
      }
    }
  }

  bool isWin(){
    if(targetChecker!=null&&targetChecker.x==exitX&&targetChecker.y==exitY){
      return true;
    }
    return false;
  }

  CheckerInfo getChecker(int x, int y){
    if(x<0||x>=column||y<0||y>=row){
      return new CheckerInfo(x: 0, y: 0, width: 1, height: 1);
    }
    return checkerMap[posToInd(x, y)];
  }

  void setChecker(int x, int y, val){
    checkerMap[posToInd(x, y)] = val;
  }

  /*
   *   指定棋子是否能往指定方向移动
   *
   */
  bool canMove(CheckerInfo checker, int dir){
    var offset = [0,0];
    switch(dir){
      case DIR.UP:
      //向上移动
        offset = [0,1];
        break;
      case DIR.DOWN:
      //向下移动
        offset = [0,-1];
        break;
      case DIR.LEFT:
      //向左移动
        offset = [-1, 0];
        break;
      case DIR.RIGHT:
      //向右移动
        offset = [1, 0];
        break;
    }

    for(int i=0;i<checker.height;++i){
      var y = checker.y+i;
      for(int j=0;j<checker.width;++j){
        var x = checker.x+j;
        var curChecker = getChecker(x+offset[0], y+offset[1]);
        if(curChecker!=null&&curChecker!=checker){
          return false;
        }
      }
    }
    return true;
  }

  void setCheckerMapArea(int x, int y, int w, int h, val){
    for(var i=0;i<w;++i){
      for(var j=0;j<h;++j){
        setChecker(x+i, y+j, val);
      }
    }
  }

  /*
   * 移动棋子并更新棋盘, 移动后检查是否胜利
   */
  void moveCheckerPos(CheckerInfo checker, int x, int y){
      setCheckerMapArea(checker.x, checker.y, checker.width, checker.height, null);
      checker.x = x;
      checker.y = y;
      setCheckerMapArea(checker.x, checker.y, checker.width, checker.height, checker);
    if(isWin()){
      notifyAllWinObservers();
    }
  }

  void moveCheckerDir(CheckerInfo checker, int dir){
    switch(dir){
      case DIR.UP:
        moveCheckerPos(checker, checker.x, checker.y+1);
        break;
      case DIR.DOWN:
        moveCheckerPos(checker, checker.x, checker.y-1);
        break;
      case DIR.LEFT:
        moveCheckerPos(checker, checker.x-1, checker.y);
        break;
      case DIR.RIGHT:
        moveCheckerPos(checker, checker.x+1, checker.y);
        break;
    }
  }

  bool attemptMoveCheckerDir(CheckerInfo checker, int dir){
    if(canMove(checker, dir)){
      moveCheckerDir(checker, dir);
      notifyAllBlockObservers();
      return true;
    }else{
      return false;
    }
  }

  @override
  bool attemptMoveChess(int ID, int dir) {
    return attemptMoveCheckerDir(checkersStates[ID], dir);
  }

}

abstract class BlockObserver{
  notify();
}

abstract class WinObserver{
  onWin();
}

class CheckerboardView extends State<Checkerboard> with BlockObserver{

  ICheckerboardModel model;
  ICheckerboardController controller;

  Offset dragDownPos;//按下时的位置

  CheckerboardView(ICheckerboardController controller, ICheckerboardModel model){
    initialize(controller, model);
  }

  initialize(ICheckerboardController controller, ICheckerboardModel model) {
    this.controller = controller;
    this.model = model;
    model.registerBlockObserver(this);
  }

  @override
  notify() {
    setState((){});
  }

  getWidthPx(){
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if(width/super.widget.column*super.widget.row<height){
      return width;
    }else{
      return height/super.widget.row*super.widget.column;
    }
  }

  getHeightPx(){
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    if(width/super.widget.column*super.widget.row<height){
      return width/super.widget.column*super.widget.row;
    }else{
      return height;
    }
  }

  getBlockWidthPx(){
    return getWidthPx()/super.widget.column;
  }

  @override
  Widget build(BuildContext context) {
    var checkersStates = model.getBoardInfo();
    var blockWidth = getBlockWidthPx();
    var children = <Widget>[];
    int ind = 0;
    checkersStates.forEach((st){
      var left = st.x*blockWidth;
      var bottom = st.y*blockWidth;
      int id = ind;
      children.add(
          new Positioned(
            left: left,
            bottom: bottom,
            child: new Checker(
              blockWidth: blockWidth, width: st.width, height: st.height,
              onDragDown: (DragDownDetails info){
                dragDownPos = info.globalPosition;
              },
              onDragUpdate: (DragUpdateDetails detail){
                //print("drag"+id.toString());
                var curPos = detail.globalPosition;
                var offset = curPos-dragDownPos;
                var sensitiveLength = getBlockWidthPx()/2;//水平/竖直方向移动多长后触发棋子移动
                if(offset.dx.abs()>offset.dy.abs()&&offset.dx.abs()>sensitiveLength){
                  if(offset.dx>0){
                    if(controller.attemptMoveChess(id, DIR.RIGHT))
                      dragDownPos+=Offset(getBlockWidthPx(), 0);
                  }else{
                    if(controller.attemptMoveChess(id, DIR.LEFT))
                      dragDownPos-=Offset(getBlockWidthPx(), 0);
                  }
                }else if(offset.dy.abs()>sensitiveLength){
                  if(offset.dy<0){
                    if(controller.attemptMoveChess(id, DIR.UP))
                      dragDownPos-=Offset(0, getBlockWidthPx());
                  }else{
                    if(controller.attemptMoveChess(id, DIR.DOWN))
                      dragDownPos+=Offset(0, getBlockWidthPx());
                  }
                }
              },
            ),
          )
      );
      ++ind;
    });

    return Container(
        decoration: new BoxDecoration(
            border: new Border.all(
                width: 2,
                color: Colors.brown
            )
        ),
        height: getHeightPx(),

        child: Stack(
          children: children,
        )
    );
  }
}

abstract class ICheckerboardController{
  bool attemptMoveChess(int ID, int dir);
  CheckerboardView getView();
}

class InputCheckerboardController implements ICheckerboardController{
  CheckerboardView view;
  ICheckerboardModel model;

  InputCheckerboardController(ICheckerboardModel model){
    this.model = model;
    view = new CheckerboardView(this, model);
  }

  @override
  CheckerboardView getView() {
    return view;
  }

  @override
  bool attemptMoveChess(int ID, int dir) {
    return model.attemptMoveChess(ID, dir);
  }
}