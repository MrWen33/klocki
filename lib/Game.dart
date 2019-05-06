import 'package:flutter/material.dart';
import './CheckerLoader.dart';
import './Checkerboard.dart';
import 'dart:async';

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
        state.changeState(new ActiveState(state));
      }, child: new Text('Game Start'),),
    );
  }

  @override
  onExit() {
    // TODO: implement onExit
    return null;
  }
}

//TODO: class ACTIVE
class ActiveState extends GameStateHandler{
  ActiveState(GameState state):super(state);
  
  @override
  onEnter() {
    // TODO: implement onEnter
    return null;
  }

  @override
  Widget handle() {
    return new Center(
      child: Checkerboard(initState: CheckerLoader.loadDefault(), onWin: (){
        state.changeState(new WinState(state));
      },),
    );
  }
  @override
  onExit() {
    // TODO: implement onExit
    return null;
  }
}

//TODO: class WIN
class WinState extends GameStateHandler{
  WinState(GameState state):super(state);
  
  @override
  onEnter() {
    new Timer(new Duration(seconds: 3), (){
      state.changeState(MenuState(state));
    });
  }
  
  @override
  onExit() {

  }
  
  @override
  Widget handle() {
    // TODO: implement handle
    return new Center(
      child: Text("You Win"),
    );
  }
}