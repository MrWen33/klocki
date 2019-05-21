import 'Level.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'Constants.dart';

class LevelLoader{

  factory LevelLoader() => _getInstance();

  static LevelLoader get instance => _getInstance();
  static LevelLoader _instance;
  static LevelLoader _getInstance(){
    if(_instance==null){
      _instance = LevelLoader.init();
    }
    return _instance;
  }

  LevelLoader.init();

  bool _loadFinish=false;
  bool get loadFinish => _loadFinish;
  List<Level> _levels = <Level>[];

  List<Level> get levels => _levels;


  loadFromAssets(String name) async {
    _loadFinish = false;
    var jsonString = await rootBundle.loadString(ASSETS_PATH.LEVELS_DIR+name);
    final jsonMap = json.decode(jsonString);
    var levels = <Level>[];
    for(var levelJson in jsonMap){
      levels.add(Level.fromJson(levelJson));
    }
    _levels = levels;
    _loadFinish = true;
    return _loadFinish;
  }
}