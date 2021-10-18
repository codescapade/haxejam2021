package astar;

class Point {

  public var x: Int;

  public var y: Int;

  public function new(x = 0, y = 0) {
    this.x = x;
    this.y = y;
  }

  public function equals(other: Point): Bool {
    return x == other.x && y == other.y;
  }
}