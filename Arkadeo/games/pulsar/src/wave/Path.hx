package wave;
import Protocol;
import mt.bumdum9.Lib;


class Path extends fx.Wave {//}

	
	var gap:Int;
	var pos: { x:Int, y:Int };
	var angle:Float;
	var va:Float;

	public function new(data, gap ) {
		super(data);
		this.gap = gap;
		pos = Game.me.getRandomPointFarFromHero(80);
		angle = (rnd(100)/100) * 6.28;
		va = 0;
	}
	
	override function spawn(type) {
		
		new fx.Spawn(type,pos.x,pos.y);
		
		angle += va;
		va += ((rnd(100)/100) * 2 - 1) * 0.1;
		va *= 0.9;
		
		var dx = Math.cos(angle);
		var dy = Math.sin(angle);
		
		pos.x  += Std.int(dx*gap);
		pos.y  += Std.int(dy*gap);
		
		// BOUNCE
		var ma = Game.BORDER_X + gap;
		if ( pos.x < ma || pos.x > Game.WIDTH - ma ) {
			dx *= -1;
			angle = Math.atan2(dy,dx);
		}
		var ma = Game.BORDER_Y + gap;
		if ( pos.y < ma || pos.y > Game.HEIGHT - ma ) {
			dy *= -1;
			angle = Math.atan2(dy,dx);
		}
		
	}
	

	
	
//{
}












