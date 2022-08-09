package fx;
import Protocole;

class Soap extends Fx {//}
	
	public static var ACTIVE = false;
	
	public static var speedCoef:Float;
	var coef:Float;


	public function new() {
		
		if( ACTIVE ) return;
		super();
		
		ACTIVE = true;
		coef = 0;
		speedCoef = 1.0;
		
	
	}

	override function update() {
		super.update();
		
		coef = Math.min(coef + 0.1, 1);
		speedCoef = 1 + Snk.sin(coef*3.14)*2;
		
		//
		var ray = 4;
		var p = Stage.me.getPart("soap");
		Stage.me.dm.add(p.sprite, Stage.DP_UNDER_FX);
		p.x = sn.x + (Math.random() * 2 - 1) * ray;
		p.y = sn.y + (Math.random() * 2 - 1) * ray;
		p.randMirror();
		p.updatePos();
	
		//
		if( coef == 1 || sn.dead ) kill();
	}
	
	override function kill() {
		super.kill();
		ACTIVE = false;
	}
	

	
//{
}












