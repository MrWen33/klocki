import 'package:flutter/material.dart';
import './LevelLoader.dart';
import './Checkerboard.dart';
import 'dart:async';
import 'Level.dart';
import 'Replay.dart';
import 'LevelPlayerInfo.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    var scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('klocki'),
      ),
      body: new AnimatedOpacity(
        opacity: this.opacity,
        duration: new Duration(milliseconds: duration),
        child: body,
      ),
    );
    return WillPopScope(
        child: scaffold,
        onWillPop: ()=>curState.onPop(),
    );
  }

  void showMessage(String msg){

    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
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

  onPop();
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

  @override
  onPop() {
    //do nothing
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
            ReplayManager.instance.loadAll().then(
                    (reps){
                      if(reps.containsKey(level.id)) {
                        state.changeState(
                            ReplayChooseState(state, level, reps[level.id]));
                      }else{
                        state.showMessage("No Replay");
                      }
                    });
          }else {
            state.changeState(new ActiveState(state, level));
          }
        },
      child: new Text(level.id.toString()),
    );
  }


  @override
  onEnter() {
  }

  @override
  onExit() {
    return null;
  }

  @override
  onPop() {
    state.changeState(MenuState(state));
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

    return null;
  }

  @override
  onPop() {
    state.changeState(LevelChooseState(state, false));
  }
}

class WinState extends GameStateHandler{
  WinState(GameState state):super(state);
  
  @override
  onEnter() {}
  
  @override
  onExit() {}

  @override
  onPop() {
    state.changeState(MenuState(state));
  }

  @override
  Widget handle() {
    String rep_name = "player_replay";
    TextEditingController _controller = TextEditingController.fromValue(TextEditingValue(
      text: rep_name
    ));
    TextField nameText = TextField(
      onChanged: (input_str)=>rep_name=input_str,
      controller: _controller,
    );
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You Win"),
          Text("Time:"+state.info.playTime.toString()+"s"),
          RaisedButton(
            child: Text("Save replay"),
            onPressed: ()=>showDialog(
              context: state.context,
              builder: (context)=>Dialog(

                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Enter replay name"),
                        nameText,
                        Row(
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: ()=>Navigator.pop(context),
                              child: Text("Cancel"),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                ReplayManager.instance.save(
                                    state.info.recorder.save(rep_name)
                                );
                                Navigator.pop(context);
                              },
                              child: Text("Save"),
                            )
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,)

                      ],
                    ),
                  ),
              )
            )
          ),
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
  ReplayChooseState(GameState state, this._level, this._replays) : super(state);

  Level _level;
  List<Replay> _replays;
  @override
  Widget handle() {
    var btns = <Widget>[];
    for(var rep in _replays){
      btns.add(RaisedButton(
        child: Text(rep.name),
          onPressed: ()=>state.changeState(ReplayState(state, rep, _level),
          )));
    }
    return Center(
      child: ListView(
        children: btns,
      )
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

  @override
  onPop() {
    state.changeState(LevelChooseState(state, true));
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
    var repPlayer = ReplayPlayer(_replay);
    return new Center(
      child: Column(children: <Widget>[
        checkerboard,
        Row(
          children: <Widget>[
            RaisedButton(
              onPressed: ()=>repPlayer.back(controller),
              child: Text("<"),
            ),
            RaisedButton(
              onPressed: ()=>repPlayer.forward(controller),
              child: Text(">"),
            )
            ,
            Center()
            ,RaisedButton(
              onPressed: ()=>state.changeState(MenuState(state)),
              child: Text("return to menu"),
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

  @override
  onPop() {
    state.changeState(LevelChooseState(state, true));
  }
}