package fx;
import Protocole;
import mt.bumdum9.Lib;

class MagicPowder extends Fx {//}


	static public var MAX:mt.flash.Volatile<Int> = 0;
	static var LIST:Array<Part> = [];

	
	public function new(pow:Int) {
		super();
		var max = pow * 3;
		
		
		for( i in 0...max ) {
			var p = Part.get();
			p.sprite.setAnim( Gfx.fx.getAnim("spark_dust_pulse"));
			Stage.me.dm.add(p.sprite, Stage.DP_BG);
			p.launch( Math.random() * 6.28, 0.5 + Math.random() * 5, -(2+Math.random()*3)  );
			p.x = sn.x;
			p.y = sn.y;
			p.weight = 0.1 + Math.random() * 0.3;
			p.ray = 5;
			p.frict = 0.96;
			p.timer = 900 + Game.me.seed.random(900);
			p.sprite.anim.gotoRandom();
			LIST.push(p);
			MAX++;
		}
		
		
	}
	
	override function update() {
	
		var a = LIST.copy();
		for( p in a ) if( p.timer < 2 ) {
			LIST.remove(p);
			MAX--;
		}
		
		if( LIST.length == 0 ) kill();

	}
		
	
//{
}












