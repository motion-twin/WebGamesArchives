import mt.bumdum9.Lib;
import Protocol;
import api.AKApi;
import api.AKProtocol;

using Lambda;
using mt.Std;
class Queue extends SP {

	public var balls:Array<ent.Ball>;
	public var size:Int;
	
	public function new() {
		super();
		size = Cs.WAVE_SIZE;
		balls = [];
	}
	
	public function next() {
		for( n in Cs.SIZE_UP_INTERVAL ) {
			if( Game.me.turns == n.get() ) {
				size++;
			}
		}
		switch( api.AKApi.getGameMode() ) {
			case GM_LEAGUE : 
				for( n in Cs.POOL_UP_INTERVAL ) {
					if( Game.me.turns == n.get() ) {
						var all = ent.Ball.DATA.map(function(data) return data.id ).array();
						for( p in Game.me.pool ) all.remove(p);
						for( p in Cs.DISABLED_POOL ) all.remove(p);
						all.shuffle(Game.me.seed.random);
						Game.me.pool.push( all.first() );
					}
				}
			case GM_PROGRESSION :
				for( n in Cs.POOL_UP_INTERVAL ) {
					if( Game.me.turns == n.get() ) {
						var all = Game.me.completePool.copy();
						for( p in Game.me.pool ) all.remove(p);
						for( p in Cs.DISABLED_POOL ) all.remove(p);
						if( all.length > 0 ) {
							all.shuffle(Game.me.seed.random);
							Game.me.pool.push( all.first() );
						}
					}
				}
		}
		//
		var by = (Cs.HEIGHT - (size - 1) * Cs.SQ) >> 1;
		for( i in 0...size ) {
			var b = new ent.Ball(Game.me.getPoolType());
			b.x = -Cs.SQ;
			b.y = by;
			b.updatePos();
			balls.push(b);
			var e = new fx.TweenEnt(b, 60, b.y, 0 );
			e.curveInOut();
			new mt.fx.Sleep(e, null, i * 4);
			by += Cs.SQ;
		}
	}
	
	// TODO
	public function destroyUntil(last) {
		while( balls.length > last ) {
			var b = balls.pop();
			var fx = new fx.GoBack(b, 10);
		}
	}
}
