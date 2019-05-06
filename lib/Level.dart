import 'CheckerInfo.dart';

class Level{
  String name;
  num id;
  List<CheckerInfo> info;
  Level.fromJson(jsonData) {
    name = jsonData['name'];
    id = jsonData['id'];
    info = <CheckerInfo>[];
    for(var checker in jsonData['data']){
      info.add(new CheckerInfo(
        x: checker['x'],
        y: checker['y'],
        width: checker['w'],
        height: checker['h'],
        isTarget: checker['T'] == 0?false:true
      ));
    }
  }
}