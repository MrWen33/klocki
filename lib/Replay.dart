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
  Command.fromJson(jsonData):this.ID=jsonData['ID'], this.dir=jsonData['dir'];
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

  Replay.fromJson(jsonData): this.ID=(jsonData['ID']), this.name = jsonData['name']{
    this._commands = <Command>[];
    for(var data in jsonData['commands']){
      this._commands.add(Command.fromJson(data));
    }
  }

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
    return this;
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
  factory ReplayManager() => _getInstance();

  static ReplayManager _instance;
  static ReplayManager get instance => _getInstance();
  static ReplayManager _getInstance(){
    if(_instance==null){
      _instance = ReplayManager._init();
    }
    return _instance;
  }

  ReplayManager._init();


  bool isDirty = true;
  Map<int, List<Replay>> _rep_maps;

  static const SAVE_NAME = 'replays';
  save(Replay rep) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var repList = prefs.getStringList(SAVE_NAME);
    if(repList==null){
      repList = <String>[];
    }
    var jsonStr = json.encode(rep);
    print("repjsonstr:"+jsonStr);
    repList.add(jsonStr);
    prefs.setStringList(SAVE_NAME, repList);
    isDirty = true;
  }

  Future<Map<int, List<Replay>>> loadAll() async{
    if(!isDirty){
      return _rep_maps;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var repStrList = prefs.getStringList(SAVE_NAME);
    var repMap = Map<int, List<Replay>>();
    for(var repStr in repStrList){
      final jsonMap = json.decode(repStr);
      var rep = Replay.fromJson(jsonMap);
      if(!repMap.containsKey(rep.ID)){
        repMap[rep.ID] = <Replay>[];
      }
      repMap[rep.ID].add(rep);
    }
    isDirty = false;
    _rep_maps = repMap;
    return repMap;
  }
}

class ReplayRecorder implements BlockObserver{
  ReplayBuilder _replayBuilder = ReplayBuilder();
  ReplayRecorder(ICheckerboardModel model, int levelID){
    _replayBuilder.setID(levelID);
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
    _replayBuilder.setName(name);
    return _replayBuilder.build();
  }
}