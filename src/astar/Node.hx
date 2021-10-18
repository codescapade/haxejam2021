package astar;

class Node {
  public var parent: Node;

  public var value: Int;

  public var cost: Int;

  public var x(default, null): Int;

  public var y(default, null): Int;

  public var weight(default, null): Int;

  public var tileIndex(default, null): Int;

  public function new(x: Int, y: Int, tileIndex: Int, weight = 1) {
    this.x = x;
    this.y = y;
    this.tileIndex = tileIndex;
    this.weight = weight;
  }

  public function compare(other: Node): Int {
    return value - other.value;
  }

  public function equalsXY(other: Node): Bool {
    return x == other.x && y == other.y;
  }
}