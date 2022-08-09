package fx;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import api.AKApi;
import api.AKProtocol;
import Protocol;

class GoBack extends mt.fx.Sequence {

	var ball:ent.Ball;
	var vx:Float;
	var acc:Float;
	var wait:Int;

	public function new(b:ent.Ball,wait=0) {
		super();
		ball = b;
		vx = 0;
		acc = 0.25 + Math.random() * 0.4;
		this.wait = wait;
	}

	override function update() {
		super.update();
		vx -= acc;
		ball.x += vx;
		ball.updatePos();
		
		if( ball.x  < - Cs.SQ ) {
			ball.kill();
			kill();
		}
	}
}
