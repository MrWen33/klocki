class DIR{
  static const UP=0;
  static const DOWN=1;
  static const LEFT=2;
  static const RIGHT=3;
  static int reverse(int dir){
    switch(dir){
      case UP:
        return DOWN;
        break;
      case DOWN:
        return UP;
        break;
      case RIGHT:
        return LEFT;
        break;
      case LEFT:
        return RIGHT;
        break;
    }
  }
}

class ASSETS_PATH{
  static const String LEVELS_DIR = 'assets/levels/';
  static const String REPLAY_DIR = 'assets/replay/';
}