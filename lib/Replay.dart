import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Checkerboard.dart';

class Command{
  Command(this.ID, this.dir);
  int ID;
  int dir;
  Map<String, dynamic> toJson() =>{
    'ID': ID,
    'dir': dir
  };
}

abstract class CommandReceiver{
  bool execute(Command cmd);
  bool undo(Command cmd);
}

class Replay{
  final int ID;
  final String name;
  List<Command> _commands;

  int _curInd = 0;
  Replay(this.ID, this.name, List<Command> commands){
    _commands = commands;
  }

  Map<String, dynamic> toJson() => {
    'ID': ID,
    'name': name,
    'commands': _commands
  };

  /*
  向前执行指令, 若到底则返回false
   */
  bool forward(CommandReceiver receiver){
    if(_curInd>=_commands.length){
      return false;
    }
    receiver.execute(_commands[_curInd]);
    _curInd++;
    return true;
  }

  /*
  回退指令, 若到头则返回false
   */
  bool back(CommandReceiver receiver){
    var backInd = _curInd-1;
    if(backInd<0){
      return false;
    }
    receiver.undo(_commands[backInd]);
    _curInd = backInd;
    return true;
  }
}

class ReplayBuilder{
  List<Command> commands = <Command>[];
  int ID = -1;
  String name = 'Player';
  bool isIDSet = false;

  ReplayBuilder setID(int ID){
    this.ID = ID;
    isIDSet = true;
    return this;
  }

  ReplayBuilder setName(String name){
    this.name = name;
  }

  ReplayBuilder append(Command cmd){
    commands.add(cmd);
    return this;
  }

  Replay build(){
    if(!isIDSet){
      throw new Exception("ERROR::REPLAY ID NOT SET!");
    }
    return new Replay(ID, name, commands);
  }
}

class ReplayManager{
  static const SAVE_NAME = 'replays';
  static save(Replay rep) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var repList = prefs.getStringList(SAVE_NAME);
    if(repList==null){
      repList = <String>[];
    }
    repList.add(json.encode(rep));
    prefs.setStringList(SAVE_NAME, repList);
  }

  static loadAll(){

  }
}

class ReplayRecorder implements BlockObserver{
  ReplayBuilder _replayBuilder = ReplayBuilder();
  ICheckerboardModel _model;

  ReplayRecorder(ICheckerboardModel model, int levelID){
    _replayBuilder.setID(levelID);
    _model = model;
    model.registerBlockObserver(this);
  }

  /*
   *  记录一步
   */
  record(int ID, int dir){
    _replayBuilder.append(Command(ID, dir));
  }

  @override
  notify(int ID, int dir) {
    record(ID, dir);
  }

  Replay save(String name){
    _model.removeBlockObserver(this);
    _replayBuilder.setName(name);
    return _replayBuilder.build();
  }
}