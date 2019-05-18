import 'package:flutter/material.dart';
import './LevelLoader.dart';
import './Checkerboard.dart';
import 'dart:async';
import 'Level.dart';
import 'Replay.dart';

class Game extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new GameState();
  }
}

class GameState extends State<Game>{
  //States:
  static const int MENU = 0;
  static const int ACTIVE = 1;
  static const int WIN = 2;


  GameStateHandler curState;


  double opacity = 1.0;
  int duration = 300; //淡入淡出间隔(毫秒)

  @override
  void initState() {
    super.initState();
    curState = MenuState(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget body = curState.handle();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('klocki'),
      ),
      body: new AnimatedOpacity(
        opacity: this.opacity,
        duration: new Duration(milliseconds: duration),
        child: body,
      ),
    );
  }

  void changeState(GameStateHandler newState){
    //淡入淡出效果
    setState(() {
      this.opacity = 0.0;
      curState.onExit();
    });
    new Timer(new Duration(milliseconds: duration), (){
      setState(() {
        curState = newState;
        newState.onEnter();
        this.opacity = 1.0;
      });
    });
  }
}

abstract class GameStateHandler{
  GameState state;

  GameStateHandler(GameState _state){
    this.state = _state;
  }
  onEnter();
  Widget handle();
  onExit();
}

class MenuState extends GameStateHandler{
  MenuState(GameState _state):super(_state);

  @override
  onEnter() {
    return null;
  }

  @override
  Widget handle(){
    return new Center(
      child: new RaisedButton(onPressed: (){
          state.changeState(LevelChooseState(state));
      }, child: new Text('Game Start'),),
    );
  }

  @override
  onExit() {
    return null;
  }
}

class LevelChooseState extends GameStateHandler{
  LevelChooseState(GameState state):super(state);

  List<Level> levels = <Level>[];

  @override
  Widget handle() {
    levels.sort((level1, level2)=>level1.id.compareTo(level2.id));
    var columnNum = 4;
    var row = <Widget>[];
    var rows = <TableRow>[];
    var i = 0 ;
    for(var level in levels){
      if(i%columnNum==0&&i!=0){
        rows.add(TableRow(children: row));
        row = <Widget>[];
      }
      row.add(btnFromLevel(level));
      i++;
    }
    while(row.length<columnNum){
      row.add(Container());
    }
    rows.add(TableRow(children: row));
    return Table(
      border: new TableBorder.all(width: 5.0, color: Colors.transparent),
      children: rows,
    );
  }

  Widget btnFromLevel(Level level){
    return RaisedButton(
      onPressed: ()=>state.changeState(new ActiveState(state, level)),
      child: new Text(level.id.toString()),
    );
  }

  @override
  onEnter() {
    LevelLoader.loadFromAssets('level1.json').then(
        (levelList){
          state.setState(
              ()=>levels = levelList
          );
        }
    );
    return null;
  }

  @override
  onExit() {
    return null;
  }

}

class ActiveState extends GameStateHandler{
  ActiveState(GameState state, this.level):super(state);

  Level level;

  @override
  onEnter() {
    return null;
  }

  @override
  Widget handle() {
    var checkerboard = Checkerboard(initState: this.level.info, levelID: this.level.id, onWin: ()=>state.changeState(new WinState(state)));
    return new Center(
      child: checkerboard,
    );
  }
  @override
  onExit() {
    return null;
  }
}

class WinState extends GameStateHandler{
  WinState(GameState state):super(state);
  
  @override
  onEnter() {}
  
  @override
  onExit() {}
  
  @override
  Widget handle() {
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You Win"),
          RaisedButton(
            onPressed: ()=>state.changeState(MenuState(state)),
            child: Text("Home"),
          )
        ],
      ),
    );
  }
}

//TODO: ReplayState implement
class ReplayState extends GameStateHandler{
  ReplayState(GameState state) : super(state);

  @override
  Widget handle() {
    // TODO: implement handle
    return null;
  }

  @override
  onEnter() {
    // TODO: implement onEnter
    return null;
  }

  @override
  onExit() {
    // TODO: implement onExit
    return null;
  }

}