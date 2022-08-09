package fx;
import Protocole;
import mt.bumdum9.Lib;

class FruitJumpTo extends Fx {//}

	var coef:Float;
	var spc:Float;
	var fr:Fruit;
	var tw:Tween;
	
	public function new(fr:Fruit,tx:Float,ty:Float) {
		
		super();
		this.fr = fr;		
		
		tw = new Tween(fr.x, fr.y, tx, ty);
		coef = 0;
		fr.dummy = true;
		
		
		var speed = 4;
		spc = speed / tw.getDist();
		
		Stage.me.dm.over(fr.sprite);
		
	}
	
	override function update() {
		super.update();
		

		coef = Math.min(coef + spc, 1);
		var p = tw.getPos(coef);
		fr.setPos(p.x, p.y);

		var hh = 20 + 1 / spc;		
		fr.z = -Math.sin(coef * 3.14)*hh;
		
		if ( coef == 1 ) {
			fr.dummy = false;			
			kill();
		}
		
	}
	

	// Game.me.seed.rand()
	//RND()

	
	

		
	
//{
}
