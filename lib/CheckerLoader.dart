import './CheckerInfo.dart';

class CheckerLoader{
  /*
  加载默认关卡
   */
  static List<CheckerInfo> loadDefault(){
    var state = <CheckerInfo>[];
    //state.add(new CheckerInfo(x: 0, y: 0, width: 1, height: 1));
    //state.add(new CheckerInfo(x: 3, y: 0, width: 1, height: 1));
    //state.add(new CheckerInfo(x: 0, y: 1, width: 1, height: 2));
    //state.add(new CheckerInfo(x: 1, y: 1, width: 1, height: 1));
    //state.add(new CheckerInfo(x: 2, y: 1, width: 1, height: 1));
    //state.add(new CheckerInfo(x: 1, y: 2, width: 2, height: 1));
    //state.add(new CheckerInfo(x: 3, y: 1, width: 1, height: 2));
    //state.add(new CheckerInfo(x: 0, y: 3, width: 1, height: 2));
    state.add(new CheckerInfo(x: 1, y: 3, width: 2, height: 2, isTarget: true));
    //state.add(new CheckerInfo(x: 3, y: 3, width: 1, height: 2));
    return state;
  }

}