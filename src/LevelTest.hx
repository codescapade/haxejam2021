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
}

class LevelTest extends Script<LevelTestData> {
  static final TILE_SIZE = 32;

  static final TOUCH = hash('touch');

  override function init(self: LevelTestData) {
    Msg.post('.', GoMessages.acquire_input_focus);

    var bounds = Tilemap.get_bounds('#map');
    for (y in 3...bounds.h + 1) {
      for (x in 3...bounds.w + 1) {
        Tilemap.set_tile('#map', 'layer1', x, y, 1);
      }
    }

    self.currentTileIndex = 0;
  }

  override function final_(self: LevelTestData) {
    Msg.post('.', GoMessages.release_input_focus);
  }

  override function on_input(self: LevelTestData, action_id: Hash, action: ScriptOnInputAction): Bool {

    if (action_id == TOUCH) {
      if (action.pressed) {
        self.touchDown = true;
      } else if (action.released) {
        self.touchDown = false;
      }
    }
    if (!self.touchDown) {
      return true;
    }

    var worldPos = Camera.toWorld(action.x, action.y);
    trace(worldPos.x);
    var x = Math.ceil(worldPos.x / TILE_SIZE);
    var y = Math.ceil(worldPos.y / TILE_SIZE);

    if (y == 1) {
      self.currentTileIndex = Tilemap.get_tile('#map', 'layer1', x, y);
    } else if (inBounds(x, y)) {
      Tilemap.set_tile('#map', 'layer1', x, y, self.currentTileIndex);
    }

    return false;
  }

  function inBounds(x: Int, y: Int): Bool {
    var bounds = Tilemap.get_bounds('#map');
    return x > 2 && x < bounds.w && y > 3 && y < bounds.h;
  }
}