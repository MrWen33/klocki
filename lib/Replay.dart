import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Command> commands;
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

  Replay build(String name){
    if(!isIDSet){
      throw new Exception("ERROR::REPLAY ID NOT SET!");
    }
    return new Replay(ID, name, commands);
  }
}

class ReplayManager{
  static save(Replay rep) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var replist = prefs.getStringList('replays');
    if(replist==null){
      replist = <String>[];
    }
    replist.add(json.encode(rep));
    prefs.setStringList('replays', replist);
  }

  static loadAll(){

  }
}