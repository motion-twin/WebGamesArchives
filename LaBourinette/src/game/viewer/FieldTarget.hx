package game.viewer;

/*
 * For debug purpose, represents the ball destination while the ball is flying.
 */
class FieldTarget extends flash.display.Shape {
	public function new( ?color=0xFFFF00 ){
		super();
		graphics.lineStyle(1, color);
		graphics.moveTo(0, -1);
		graphics.lineTo(0, 1);
		graphics.moveTo(-1, 0);
		graphics.lineTo(1, 0);
		alpha = 0.8;
		filters = [
			new flash.filters.DropShadowFilter(1, 0, 0x000000, 1, 0, 0, 10)
		];
		if (!Viewer.DRAW_EXTRA)
			visible = false;
	}

	public function update( dest:geom.Pt, v:Bool ){
		visible = Viewer.DRAW_EXTRA && dest != null;
		if (dest != null){
			x = dest.x;
			y = dest.y;
		}
	}
}