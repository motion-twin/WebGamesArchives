package fx;
import Protocole;
import mt.bumdum9.Lib;

class Tongue extends Fx {//}
	
	static var LENGTH_MAX = 80;
	
	var coef:Float;
	var fruits:Array<{fr:Fruit,fid:Int,tc:Float}>;
	public var x:Float;
	public var y:Float;

	public function new() {
		if ( Game.me.snake.tongue != null ) return;
		super();
		coef = 0;
		Game.me.snake.tongue = this;
		fruits = [];
		update();
	}
	
	public override function update() {
		
		var sn = Game.me.snake;
		if ( sn == null ) {	kill();	return;}
		//
		coef  = Math.min(coef + 0.05, 1);
		var length = Snk.sin(coef * 3.14) * LENGTH_MAX ;

		var ddx = Snk.cos(sn.angle) * length;
		var ddy = Snk.sin(sn.angle) * length;
		x = sn.x + ddx;
		y = sn.y + ddy;
		
		// SEEK FRUITS
		var max = 4;
		for ( i in 0...max) {
			var tc = 1 - i/max;
			for ( fr in Game.me.fruits ) {
				var tx = sn.x + ddx * tc;
				var ty = sn.y + ddy * tc;
				var dx = tx - fr.x;
				var dy = ty - fr.y;
				var lim = 14;
				if ( Math.sqrt(dx * dx + dy * dy) < lim && fr.z > -1  ) {
					fr.scoreCoef *= 2;
					fr.unregister();
					fruits.push({fr:fr,fid:fr.initId,tc:tc});
				}
			}
		}
		
		var a = fruits.copy();
		for ( o in a ) {
			if( o.fr.initId != o.fid || o.fr.death ) {
				fruits.remove(o);
				continue;
			}
			o.fr.x = sn.x + ddx * o.tc;
			o.fr.y = sn.y + ddy * o.tc;
			o.fr.updatePos();

		}
		if ( coef > 0.9 )
			while (fruits.length > 0)
				Game.me.snake.eat(fruits.pop().fr);
		
		
		if ( coef == 1 ) kill();
	}
	
	public override function kill() {
		Game.me.snake.tongue = null;
		super.kill();
		
	}
	
	
//{
}












