class ClearAnim  {

	var drawer : Drawer;
	var mc : flash.display.Sprite;
	var time : Float;
	var view : View;
	var circle : flash.display.Sprite;
	
	public function new( v : View, d : Drawer )
	{
		view = v;
		drawer = d;
		mc = drawer.makeView();
		view.m.world.add(mc, View.PLAN_ISLAND);
		view.m.world.under(mc);
		time = 10;
		var pt = view.m.curIsland.pts[view.m.curPos.pid];
		circle = new flash.display.Sprite();
		circle.x = pt.x * Drawer.SIZE;
		circle.y = pt.y * Drawer.SIZE;
		view.m.world.add(circle, View.PLAN_ISLAND);
		view.island.mask = circle;
		update();
	}
	
	public function update() {
		var g = circle.graphics;
		g.clear();
		g.beginFill(0, 0.5);
		g.drawCircle(0, 0, time);
		time *= 1.06;
		if( time > 400 ) {
			cleanup();
			return false;
		}
		return true;
	}
	
	public function cleanup() {
		view.island.mask = null;
		drawer.cleanup();
		mc.parent.removeChild(mc);
		circle.parent.removeChild(circle);
	}
	
}