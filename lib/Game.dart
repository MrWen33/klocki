import 'package:flutter/material.dart';
import './LevelLoader.dart';
import './Checkerboard.dart';
import 'dart:async';
import 'Level.dart';
import 'Replay.dart';
import 'LevelPlayerInfo.dart';
import 'Constants.dart';

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
  LevelPlayerInfo info;


  double opacity = 1.0;
  int duration = 300; //淡入淡出间隔(毫秒)

  @override
  void initState() {
    super.initState();
    LevelLoader.instance.loadFromAssets('level1.json').then((_)=>setState((){}));
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
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(onPressed: (){
            state.changeState(LevelChooseState(state, false));
          }, child: new Text('Game Start'),),
          new RaisedButton(onPressed: (){
              state.changeState(LevelChooseState(state, true));
            }, child: Text('Replay'),)
        ]
    ));
  }

  @override
  onExit() {
    return null;
  }
}

class LevelChooseState extends GameStateHandler{
  LevelChooseState(GameState state, this.isRep):super(state);

  List<Level> levels = <Level>[];
  bool isRep;

  @override
  Widget handle() {
    levels = LevelLoader.instance.levels;
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
      onPressed: (){
          if(isRep){
            state.changeState(ReplayChooseState(state, level));
          }else {
            state.changeState(new ActiveState(state, level));
          }
        },
      child: new Text(level.id.toString()),
    );
  }

  @override
  onEnter() {
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
    var checkerboard = Checkerboard(initState: this.level.info, levelID: this.level.id,
        controller: InputCheckerboardController(),
        onWin: (info){
          state.info = info;
          state.changeState(
            new WinState(state));
        });
    return new Center(
      child: checkerboard,
    );
  }
  @override
  onExit() {
    var rep = ReplayBuilder()
        .append(Command(0, DIR.DOWN))
        .append(Command(0, DIR.DOWN))
        .append(Command(0, DIR.DOWN))
        .setName('ss')
        .setID(level.id)
        .build();
    ReplayManager.instance.save(rep);
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
          Text("Time:"+state.info.playTime.toString()+"s"),
          RaisedButton(
            onPressed: ()=>state.changeState(MenuState(state)),
            child: Text("Home"),
          )
        ],
      ),
    );
  }
}

/* 显示某关的所有rep供选择 */
class ReplayChooseState extends GameStateHandler{
  ReplayChooseState(GameState state, this._level) : super(state);

  Level _level;
  @override
  Widget handle() {

    return Center(
      child: RaisedButton(onPressed: ()=>state.changeState(ReplayState(
          state,
          //Test rep object
          ReplayBuilder()
              .append(Command(0, DIR.DOWN))
              .append(Command(0, DIR.DOWN))
              .append(Command(0, DIR.DOWN))
              .setName('ss')
              .setID(_level.id)
              .build(),
          _level))),
    );
  }

  @override
  onEnter() {
    return null;
  }

  @override
  onExit() {
    return null;
  }

}

//TODO: ReplayState implement
class ReplayState extends GameStateHandler{
  ReplayState(GameState state, this._replay, this._level) : super(state);

  Replay _replay;
  Level _level;

  @override
  Widget handle() {
    var controller = ReplayCheckerboardController();
    var checkerboard = Checkerboard(initState: this._level.info, levelID: _replay.ID,
        controller: controller,
        onWin: (info){});
    return new Center(
      child: Column(children: <Widget>[
        checkerboard,
        Row(
          children: <Widget>[
            RaisedButton(
              onPressed: ()=>_replay.back(controller),
              child: Text("<"),
            ),
            RaisedButton(
              onPressed: ()=>_replay.forward(controller),
              child: Text(">"),
            )
          ],
        )
      ],)
    );
  }

  @override
  onEnter() {
    return null;
  }

  @override
  onExit() {
    return null;
  }

}