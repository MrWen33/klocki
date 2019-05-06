import 'Level.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

class LevelLoader{

  static Future<Level> loadFromAssets(String name) async {
    var jsonString = await rootBundle.loadString('assets/levels/'+name);
    final jsonMap = json.decode(jsonString);
    return Level.fromJson(jsonMap);
  }

}