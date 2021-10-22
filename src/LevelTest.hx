import defold.Go;
import defold.Vmath;
import defold.Factory;
import defold.types.Message;
import defold.types.Url;
import astar.PathFinding;
import astar.Point;
import defold.Go.GoMessages;
import defold.Msg;
import defold.types.Hash;
import defold.support.ScriptOnInputAction;
import defold.Tilemap;
import defold.support.Script;
import lua.Math;
import Defold.hash;

typedef LevelTestData = {
  var currentTileIndex: Int;
  var touchDown: Bool;

  var start: Point;
  var goal: Point;
  var pathfinding: PathFinding;

  var newBuilding: Hash;
  var base: Bool;
}

class LevelTest extends Script<LevelTestData> {
  static final TILE_SIZE = 32;

  static final TOUCH = hash('touch');

  static final walkable = [1, 3, 4, 5];

  override function init(self: LevelTestData) {
    Msg.post('.', GoMessages.acquire_input_focus);

    var grid: Array<Array<Int>> = [];
    var bounds = Tilemap.get_bounds('#map');
    for (y in 3...bounds.h + 1) {
      var row: Array<Int> = [];
      for (x in 3...bounds.w + 1) {
        row.push(1);
        Tilemap.set_tile('#map', 'layer1', x, y, 1);
      }
      grid.push(row);
    }

    self.pathfinding = new PathFinding(grid, walkable);
    self.currentTileIndex = 0;
    self.start = null;
    self.goal = null;
  }

  override function final_(self: LevelTestData) {
    Msg.post('.', GoMessages.release_input_focus);
  }

  override function on_message<TMessage>(self: LevelTestData, message_id: Message<TMessage>, message: TMessage,
      sender: Url) {
    switch (message_id) {
      case Messages.buildBase:
        self.newBuilding = Factory.create('/factories#basefactory', Vmath.vector3(0, 0, 0.1));
        self.base = true;

      case Messages.buildTower:
        self.newBuilding = Factory.create('/factories#towerfactory', Vmath.vector3(0, 0, 0.1));
    }
  }

  override function on_input(self: LevelTestData, action_id: Hash, action: ScriptOnInputAction): Bool {
    if (action_id == null && self.newBuilding != null) {
        var worldPos = Camera.toWorld(action.x, action.y);
        var x = Math.ceil(worldPos.x / TILE_SIZE);
        var y = Math.ceil(worldPos.y / TILE_SIZE);

        if (self.base) {
          Go.set_position(Vmath.vector3(x * 32, y * 32, 0.1), self.newBuilding);
        } else {
          Go.set_position(Vmath.vector3(x * 32 - 16, y * 32 - 16, 0.1), self.newBuilding);
        }
    }

    if (action_id == TOUCH && action.pressed && self.newBuilding != null) {
      self.newBuilding = null;
      self.base = false;
    }

    // if (self.start != null && self.goal != null && (self.currentTileIndex == 4 || self.currentTileIndex == 5)) {
    //   var bounds = Tilemap.get_bounds('#map');
    //   for (y in 3...bounds.h + 1) {
    //     for (x in 3...bounds.w + 1) {
    //       var index = Tilemap.get_tile('#map', 'layer1', x, y);
    //       if (index > 2) {
    //         Tilemap.set_tile('#map', 'layer1', x, y, 1);
    //       }
    //     }
    //   }
    //   self.start = null;
    //   self.goal = null;
    // }

    // var worldPos = Camera.toWorld(action.x, action.y);
    // var x = Math.ceil(worldPos.x / TILE_SIZE);
    // var y = Math.ceil(worldPos.y / TILE_SIZE);

    // if (y == 1) {
    //   self.currentTileIndex = Tilemap.get_tile('#map', 'layer1', x, y);
    // } else if (inBounds(x, y)) {
    //   if (self.currentTileIndex == 4) {
    //     self.start = new Point(x - 3, y - 3);
    //   } else if (self.currentTileIndex == 5) {
    //     self.goal = new Point(x - 3, y - 3);
    //   }
    //   self.pathfinding.updateTile(x - 3, y - 3, self.currentTileIndex);
    //   Tilemap.set_tile('#map', 'layer1', x, y, self.currentTileIndex);
    // }

    // if (self.start != null && self.goal != null) {
    //   var path = self.pathfinding.findPath(self.start, self.goal);
    //   trace(path.length);
    //   for (i in 1...path.length - 1) {
    //     Tilemap.set_tile('#map', 'layer1', path[i].x + 3, path[i].y + 3, 3);
    //   }
    // }


    return false;
  }

  function inBounds(x: Int, y: Int): Bool {
    var bounds = Tilemap.get_bounds('#map');
    return x > 1 && x <= bounds.w && y > 2 && y <= bounds.h;
  }
}