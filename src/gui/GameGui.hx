package gui;

import defold.Go;
import defold.Vmath;
import defold.Factory;
import defold.Gui;
import defold.Msg;
import defold.Go.GoMessages;
import defold.types.Hash;
import defold.support.ScriptOnInputAction;
import defold.support.GuiScript;
import Defold.hash;

typedef GameGuiData = {

}

class GameGui extends GuiScript<GameGuiData> {
  static final TOUCH = hash('touch');

  override function init(self: GameGuiData) {
    Msg.post('.', GoMessages.acquire_input_focus);
  }

  override function final_(self: GameGuiData) {
    Msg.post('.', GoMessages.release_input_focus);
  }

  override function on_input(self: GameGuiData, action_id: Hash, action: ScriptOnInputAction): Bool {
    if (action_id == TOUCH && action.pressed) {
      var baseButton = Gui.get_node('base');
      var towerButton = Gui.get_node('tower');
      var mine = Gui.get_node('mine');
      var barracks = Gui.get_node('barracks');
      var wall = Gui.get_node('wall');

      if (Gui.pick_node(baseButton, action.x, action.y)) {
        Msg.post('/map', Messages.buildBase);
      } else if (Gui.pick_node(towerButton, action.x, action.y)) {
        Msg.post('/map', Messages.buildTower);
      } else if (Gui.pick_node(mine, action.x, action.y)) {
        Msg.post('/map', Messages.buildMine);
      } else if (Gui.pick_node(barracks, action.x, action.y)) {
        Msg.post('/map', Messages.buildBarracks);
      } else if (Gui.pick_node(wall, action.x, action.y)) {
        trace('pressed wall');
      }
    }

    return false;
  }
}