package mt.fx;

class Shake extends Fx{//}

	var mc:flash.display.DisplayObject;
	var friction:Float;
	var bx:Float;
	var by:Float;
	var ddx:Float;
	var ddy:Float;
	var timer:Int;
	var mod:Int;
	public var timeLimit:Int;
	
	public var fitPix:Bool;
	
	public function new(mc, dx, dy, frict=0.75, mod=2) {
		
		super();
		this.mod = mod;
		this.mc = mc;
		friction = frict;
		bx = mc.x;
		by = mc.y;
		init(dx,dy);
		timeLimit = -1;
		timer = 0;
		fitPix = false;
		update();
	}
	
	public function init(dx, dy) {
		ddx = dx;
		ddy = dy;
	}
	
	override function update() {
		timer ++;
		if( timer % mod != 0 ) return;
		
		ddx *= -friction;
		ddy *= -friction;
		mc.x = bx + ddx;
		mc.y = by + ddy;
		if( fitPix ) {
			mc.x = Std.int(mc.x);
			mc.y = Std.int(mc.y);
		}
		if( Math.abs(ddx) + Math.abs(ddy) < 1 || timer == timeLimit) {
			kill();
		}

		
		
	}
	
	override function kill() {
		mc.x = bx;
		mc.y = by;
		super.kill();
	}
	
//{
}