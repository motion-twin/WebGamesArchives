package game.viewer;

/*
 * A shadow below players and ball.
 * Soooo beautifull!
 */
class Shadow extends flash.display.Shape {
	public function new(line, size){
		super();
		graphics.lineStyle(line, 0x777777, 0.8);
		graphics.beginFill(0x777777, 0.8);
		graphics.drawCircle(0, 0, size);
		graphics.endFill();
		filters = [ new flash.filters.DropShadowFilter(4, 45, 0x000033, 0.9, 3, 3) ];
	}

	public function update(x:Float, y:Float){
		this.x = x;
		this.y = y;
		var c = new geom.PVector3D(100, 50);
		var p = new geom.PVector3D(x, y);
		var dist = 1 + 4 * 1 - (Math.min(30, p.distance(c))/30);
		var angle = ((Math.PI/2) + c.angleZ(p)) * 360 / (Math.PI*2);
		filters = [
			new flash.filters.DropShadowFilter(dist, angle, 0x000033, 0.9, 3, 3)
		];
	}
}