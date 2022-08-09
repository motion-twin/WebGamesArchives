package seq;
import Protocol;
import mt.bumdum9.Lib;

class Convert extends mt.fx.Sequence {

	public function new(b:ent.Ball) {
		super();
		
		var a = b.square.nei;
		Arr.shuffle(a, Game.me.seed);
		
		for( nsq in a ) {
			var ball = nsq.getBall();
			if( ball == null || ball.type == BallType._PIOUZ ) continue;
			ball.setType(BallType._PIOUZ);
			var e = new mt.fx.Flash(ball.root);
			return;
		}
	}
	
	override function update() {
		super.update();
		if( timer == 10 ) kill();
	}
}
