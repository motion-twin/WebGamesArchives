package seq;
import Protocol;
import fx.MoveBall;

class Magnet extends mt.fx.Sequence {

	var count:Int;
	
	public function new(bsq:Square) {
		super();
		
		count = 0;
		for( di in 0...4 ) {
			var sq = bsq;
			var path = [];
			for( n in 0...12 ) {
				if( sq == null ) continue;
				sq = sq.dnei[di];
				path.push(sq);
				if( sq == null ) break;
				if( sq.isFree() ) continue;
				var b = sq.getBall();
				if( b != null ) {
					if( b.type == BallType._GNU && n > 0){
						var e = new fx.MoveBall(b,path,MFX_MAGNET_LINK(bsq.getBall()));
						e.onFinish = function() { count--; };
						count++;
					}
					break;
				}
			}
		}
	}
	
	override function update() {
		super.update();
		if( count == 0) kill();
	}
}