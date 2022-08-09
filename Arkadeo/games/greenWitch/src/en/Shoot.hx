package en;

import mt.deepnight.Lib;

class Shoot extends Entity {
	public function new(x:Float, y:Float) {
		super();
		
		frict = 1;
		speed = 0.4;
		collides = false;
		weight = 0;
		cd.set("duration", 30);
		
		xx = x;
		yy = y;
		updateFromScreenCoords();
	}
	
	function onTimeOut() {
		destroy();
	}
	
	
	public override function update() {
		super.update();
		
		if( !cd.has("duration") )
			onTimeOut();
	}
}