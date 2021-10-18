package astar;

import haxe.ds.List;

class PathFinding {
  var queue: List<Node>;

  var walkableTiles: Array<Int>;

  var pointsToAvoid: Array<Array<Int>>;

  var grid: Array<Array<Node>>;

  var directions = [new Point(-1, 0), new Point(1, 0), new Point(0, -1), new Point(0, 1)];


  public function new(grid: Array<Array<Int>>, walkableTiles: Array<Int>) {

    pointsToAvoid = [];
    for (y in 0...grid.length) {
      var row: Array<Int> = [];
      for (x in 0...grid[0].length) {
        row.push(0);
      }
      pointsToAvoid.push(row);
    }
    this.walkableTiles = walkableTiles;
    updateGrid(grid);
    queue = new List<Node>();
  }

  public function updateGrid(grid: Array<Array<Int>>) {
    this.grid = [];
    for (y in 0...grid.length) {
      var row: Array<Node> = [];
      for (x in 0...grid[0].length) {
        row.push(new Node(x, y, grid[y][x]));
      }
      this.grid.push(row);
    }
  }

  public function updateTile(x: Int, y: Int, index: Int) {
    grid[y][x] = new Node(x, y, index);
  }

  public function findPath(start: Point, goal: Point): Array<Point> {
    if (!isWalkable(start.x, start.y) || !isWalkable(goal.x, goal.y)) {
      return [];
    }

    for (y in 0...grid.length) {
      for (x in 0...grid[0].length) {
        grid[y][x].parent = null;
        grid[y][x].value = 0;
        grid[y][x].cost = 0;
      }
    }

    var startNode = grid[start.y][start.x];
    var goalNode = grid[goal.y][goal.x];

    queue.clear();
    queue.add(startNode);

    while (queue.length > 0) {
      var currentNode = queue.first();
      queue.remove(currentNode);

      for (neighbor in getNeighbors(currentNode)) {
        var newCost = currentNode.cost + neighbor.weight;
        if (neighbor.parent == null || newCost < neighbor.cost) {
          neighbor.cost = newCost;
          neighbor.value = newCost + heuristics(goalNode, neighbor);
          neighbor.parent = currentNode;
          queue.add(neighbor);
        }
      }

      if (currentNode.equalsXY(goalNode)) {
        break;
      }
    }

    return reconstructPath(startNode, goalNode);
  }

  public function addPointToAvoid(x: Int, y: Int) {
    if (inBounds(x, y)) {
      pointsToAvoid[y][x] = 1;
    }
  }

  public function removePointToAvoid(x: Int, y: Int) {
    if (inBounds(x, y)) {
      pointsToAvoid[y][x] = 0;
    }
  }

  public function resetPointsToAvoid() {
    for (y in 0...pointsToAvoid.length) {
      for (x in 0...pointsToAvoid[0].length) {
        pointsToAvoid[y][x] = 0;
      }
    }
  }

  function isWalkable(x: Int, y: Int): Bool {
    return walkableTiles.contains(grid[y][x].tileIndex);
  }

  function getNeighbors(node: Node): Array<Node> {
    var neighbors: Array<Node> = [];

    for (direction in directions) {
      var x = direction.x + node.x;
      var y = direction.y + node.y;

      if (inBounds(x, y)) {
        var neighbor = grid[y][x];
        if (neighbor.value == 0 && isWalkable(x, y) && pointsToAvoid[y][x] == 0) {
          neighbors.push(neighbor);
        }
      }
    }

    return neighbors;
  }

  function reconstructPath(start: Node, goal: Node): Array<Point> {
    var path: Array<Point> = [];
    var current = goal;
    path.push(new Point(current.x, current.y));
    while (!current.equalsXY(start)) {
      current = current.parent;
      if (current != null) {
        path.push(new Point(current.x, current.y));
      } else {
        break;
      }
    }

    return path;
  }

  function inBounds(x: Int, y: Int): Bool {
    return x >= 0 && x < grid[0].length && y >= 0 && y < grid.length;
  }

  function heuristics(current: Node, target: Node): Int {
    return Std.int(Math.abs(current.x - target.x) + Math.abs(current.y - target.y));
  }
}