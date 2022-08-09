package wave;
import Protocol;
import mt.bumdum9.Lib;


class Border extends fx.Wave {
	
	override function spawn(type) {
		
		var bp = Game.me.getRandomBorderPos();
		var pos = Game.me.borderToPos(bp.di, bp.n);
		var e = new fx.Spawn(type, pos.x, pos.y);
		e.borderPos = bp;
	}

}

