import 'Level.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'Constants.dart';

class LevelLoader{

  static Future<Level> loadFromAssets(String name) async {
    var jsonString = await rootBundle.loadString(ASSETS_PATH.LEVELS_DIR+name);
    final jsonMap = json.decode(jsonString);
    return Level.fromJson(jsonMap);
  }

}