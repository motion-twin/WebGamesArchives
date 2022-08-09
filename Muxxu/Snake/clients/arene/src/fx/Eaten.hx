package fx;
import Protocole;
import mt.bumdum9.Lib;

class Eaten extends Fx {//}

	var timer:Int;
	var fruit:pix.Element;
	var spc:Float;
	var coef:Float;
	var black:BlackSnake;
	
	public function new(f:Fruit, ?bs:BlackSnake) {
		black = bs;
		super();
		fruit = new pix.Element();
		fruit.drawFrame( Gfx.fruits.get(f.gid) );
		fruit.x = f.x;
		fruit.y = f.y;
		Stage.me.dm.add(fruit, Stage.DP_BG);
		coef = 0;
		spc = 0.1;
		if( black != null ) spc = 0.2;
		
	}
	
	override function update() {
		coef = Math.min(coef + 0.1, 1);
		
		var x = sn.x;
		var y = sn.y;
		if( black != null ) {
			x = black.x;
			y = black.y;
		}
		
		
		var dx = x - fruit.x;
		var dy = y - fruit.y;
		
		fruit.x += dx * coef;
		fruit.y += dy * coef;
		fruit.scaleX = fruit.scaleY = 1 - coef;
		
		if( coef == 1 ) {
			kill();
			fruit.kill();
		}
		
	}
	


	

	
	

		
	
//{
}
