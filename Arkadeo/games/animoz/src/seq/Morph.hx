package seq;
import Protocol;

private typedef MorphDir = { type:BallType, score:Int };

class Morph extends mt.fx.Sequence {

	public function new(b:ent.Ball) {
		super();
		
		var a:Array<MorphDir> = [];
		for( di in 0...4  ) {
			var ball = b.getNeiBall(di);
			if( ball == null ) continue;
			var o:MorphDir = null;
			for( md in a )
				if( md.type == ball.type )
					o = md;
			
			if( o == null ) {
				o = { type:ball.type, score:1 };
				a.push(o);
			}
			
			while( true ) {
				ball = ball.getNeiBall(di);
				if( ball == null ) break;
				if( ball.type != o.type ) break;
				o.score++;
			}
		}
		
		var score = -1;
		var best = null;
		for( o in a ) {
			if(o.score > score ) {
				score = o.score;
				best  = o.type;
			}
		}
		
		if( best != null && best != BallType._CHAMELEON ) {
			b.setType(best);
			var e = new mt.fx.Flash(b.root,0.05);
		}
	}
	
	override function update() {
		super.update();
		if( timer == 10 ) kill();
	}
}
