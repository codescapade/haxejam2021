import renderer.RenderHelper;
import defold.Go;
import defold.Camera.CameraMessages;
import defold.Vmath;
import defold.types.Vector3;
import defold.Render.RenderMessages;
import defold.Go.GoMessages;
import defold.Msg;
import defold.types.Hash;
import defold.support.ScriptOnInputAction;
import defold.support.Script;
import Defold.hash;


class Camera extends Script<{}> {
  static var zoom: Float;

  static final WHEEL_DOWN = hash('wheel_down');
  static final WHEEL_UP = hash('wheel_up');

  static final MIN_ZOOM = 0.5;
  static final MAX_ZOOM = 2;

  public static function toWorld(x: Float, y: Float): Vector3 {
    var pos = Go.get_position('cam');
    var worldPos = RenderHelper.instance.screenToWorld(x, y);

    return Vmath.vector3(worldPos.x + pos.x, worldPos.y + pos.y, 0);
  }

  override function init(self: {}) {
    Msg.post('#camera', CameraMessages.acquire_camera_focus);
    Msg.post('.', GoMessages.acquire_input_focus);   
    zoom = 1;
  }

  override function final_(self: {}) {
    Msg.post('.', GoMessages.release_input_focus);
  }

  override function on_input(self: {}, action_id: Hash, action: ScriptOnInputAction): Bool {
    if (action_id == WHEEL_DOWN) {
      if (zoom < MAX_ZOOM) {
        zoom += 0.05;
        RenderHelper.instance.zoom = zoom;
      }
    } else if (action_id == WHEEL_UP) {
      if (zoom > MIN_ZOOM) {
        zoom -= 0.05;
        RenderHelper.instance.zoom = zoom;
      }
    }

    return false;
  }
}