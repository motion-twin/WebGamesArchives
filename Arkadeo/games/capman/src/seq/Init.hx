package seq;
import mt.bumdum9.Lib;
import Protocol;

class Init  extends mt.fx.Sequence {//}

	static var SPEED = 0.05;
	
	public function new() {
		super();
		//Game.me.gstep = 1;

		var mcw = Cs.WIDTH + 4;
		
		if( Game.me.level != null ) {
			var e = new mt.fx.Tween(Game.me.level,-mcw, 0, SPEED);
			e.curveInOut();
			e.onFinish = Game.me.level.kill;
			Game.me.level = null;
		}
		
		Game.me.initLevel();
		var level = Game.me.level;
		Game.me.level.x = mcw;
		var e = new mt.fx.Tween(Game.me.level, 0, 0,SPEED);
		e.curveInOut();
		e.onFinish = end;
	}
	
	
	public function end() {
		Game.me.gstep = 0;
		kill();
	}


}












