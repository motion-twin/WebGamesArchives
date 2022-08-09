package fx;
import Protocole;
import mt.bumdum9.Lib;
import Snake;

class Brandy extends Fx {//}
	
	public static var DECAL = { x:0.0, y:0.0 };
	public static var TIME = 80;
	
	var turn:Float;
	var timer:Int;

	public function new() {
		super();
		timer = TIME;
		turn = 0;
		new Reduce(50, 5);
		
	}

	override function update() {
		super.update();
		
		
		switch(Game.me.controlType) {
			case CT_MOUSE :
				var coef = 1 - timer / TIME;
				var ray = Math.sin(coef * 3.14)*60;
				var angle = (timer * 20) % 628;
				DECAL.x = Math.cos(angle*0.01) * ray;
				DECAL.y = Math.sin(angle*0.01) * ray;
			
			default :
				/*
				turn += (Game.me.seed.rand() * 2 - 1) * 0.02;
				turn *= 0.95;
				sn.angle += turn;
				*/
		}
		//
		turn += (Game.me.seed.rand() * 2 - 1) * 0.02;
		turn *= 0.95;
		sn.angle += turn;
		
		
		if( Game.me.gtimer % 4 == 0 ) {
			var p = Stage.me.getPart("bubble");
			p.x = sn.x + Std.random(11)-5;
			p.y = sn.y + Std.random(11)-8;
			p.weight = -0.2;
			p.vy = -1;
			p.frict = 0.92;
		}
		if ( timer-- < 0 ) kill();
		
		
		

	}
	
	override function kill() {
		super.kill();
		DECAL.x = 0;
		DECAL.y = 0;
	}
	
	
	
	
//{
}












