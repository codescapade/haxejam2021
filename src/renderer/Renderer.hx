package renderer;

import defold.types.Message;
import defold.types.Url;
import defold.Vmath;
import defold.Sys;
import lua.Table;
import lua.Lua.tonumber;
import defold.Render;
import defold.types.Matrix4;
import defold.types.Vector4;
import defold.Render.RenderPredicate;
import defold.types.Vector3;
import defold.Render.RenderClearBuffers;
import defold.support.RenderScript;
import math.Size;

typedef RendererData = {
  var clearData: RenderClearBuffers;
  var designWidth: Int;
  var designHeight: Int;
  var currentSize: Size;
  var projectedSize: Size;
  var offset: Vector3;

  var tilePred: RenderPredicate;
  var guiPred: RenderPredicate;
  var textPred: RenderPredicate;
  var particlePred: RenderPredicate;
  var clearColor: Vector4;
  var view: Matrix4;
}

class Renderer extends RenderScript<RendererData> {

   override function init(self: RendererData) {
    self.tilePred = Render.predicate(Table.create(['tile']));
    self.guiPred = Render.predicate(Table.create(['gui']));
    self.textPred = Render.predicate(Table.create(['text']));
    self.particlePred = Render.predicate(Table.create(['particle']));

    self.clearColor = Vmath.vector4(0, 0, 0, 0);
    self.clearColor.x = tonumber(Sys.get_config('render.clear_color_red', '0'));
    self.clearColor.y = tonumber(Sys.get_config('render.clear_color_green', '0'));
    self.clearColor.z = tonumber(Sys.get_config('render.clear_color_blue', '0'));
    self.clearColor.w = tonumber(Sys.get_config('render.clear_color_alpha', '0'));

    self.view = Vmath.matrix4();

    self.clearData = Table.create();
    Table.insert(self.clearData, BUFFER_COLOR_BIT, self.clearColor);
    Table.insert(self.clearData, BUFFER_DEPTH_BIT, 1);
    Table.insert(self.clearData, BUFFER_STENCIL_BIT, 0);

    self.designWidth = 960;
    self.designHeight = 640;
    self.currentSize = { width: 0, height: 0 };
    self.projectedSize = { width: 0, height: 0 };
    self.offset = Vmath.vector3(0, 0, 0);
  }

  override function update(self: RendererData, dt: Float) {
    Render.set_depth_mask(true);
    self.clearData[BUFFER_COLOR_BIT] = self.clearColor;
    Render.clear(self.clearData);

    self.currentSize.width = Render.get_window_width();
    self.currentSize.height = Render.get_window_height();

    Render.set_viewport(0, 0, Std.int(self.currentSize.width), Std.int(self.currentSize.height));
    Render.set_view(self.view);

    Render.set_depth_mask(false);
    Render.disable_state(STATE_DEPTH_TEST);
    Render.disable_state(STATE_STENCIL_TEST);
    Render.enable_state(STATE_BLEND);
    Render.set_blend_func(BLEND_SRC_ALPHA, BLEND_ONE_MINUS_SRC_ALPHA);
    Render.disable_state(STATE_CULL_FACE);

    var zoom = RenderHelper.instance.zoom;
    self.projectedSize.width = Math.floor(self.currentSize.width / zoom);
    self.projectedSize.height = Math.floor(self.currentSize.height / zoom);
    self.offset.x = -(self.projectedSize.width - Render.get_width()) * 0.5;
    self.offset.y = -(self.projectedSize.height - Render.get_height()) * 0.5;

    Render.set_projection(Vmath.matrix4_orthographic(self.offset.x, self.offset.x + self.projectedSize.width,
        self.offset.y, self.offset.y + self.projectedSize.height, -1, 1));

    // Update the render helper to get correct mouse / touch positions on the screen.
    RenderHelper.instance.xOffset = self.offset.x;
    RenderHelper.instance.yOffset = self.offset.y;
    RenderHelper.instance.viewWidth = self.projectedSize.width;
    RenderHelper.instance.viewHeight = self.projectedSize.height;

    Render.draw(self.tilePred);
    Render.draw(self.particlePred);
    Render.draw_debug3d();

    Render.set_view(Vmath.matrix4());
    Render.set_projection(Vmath.matrix4_orthographic(0, self.currentSize.width, 0, self.currentSize.height, -1, 1));

    Render.enable_state(STATE_STENCIL_TEST);
    Render.draw(self.guiPred);
    Render.draw(self.textPred);
    Render.disable_state(STATE_STENCIL_TEST);

    Render.set_depth_mask(false);
  }

  override function on_message<TMessage>(self:RendererData, message_id:Message<TMessage>, message:TMessage, sender:Url) {
    switch (message_id) {
      case RenderMessages.clear_color:
        self.clearColor = message.color;
      case RenderMessages.set_view_projection:
        self.view = message.view;
    }
  }
}