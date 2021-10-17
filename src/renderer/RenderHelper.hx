package renderer;

import defold.Vmath;
import defold.types.Vector3;

class RenderHelper {
  public static var instance = new RenderHelper();

  public var xOffset = 0.0;

  public var yOffset = 0.0;

  public var zoom = 1.0;

  public var viewWidth = 0.0;

  public var viewHeight = 0.0;

  public function new() {}

   public function screenToWorld(x: Float, y: Float, ?out: Vector3): Vector3 {
    if (out != null) {
      out.x = xOffset + x / zoom;
      out.y = yOffset + y / zoom;
      out.z = 0;

      return out;
    }
    
    return Vmath.vector3(xOffset + x / zoom, yOffset + y / zoom, 0);
  }
}