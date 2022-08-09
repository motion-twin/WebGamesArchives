package en.mob.lock;

import mt.MLib;

class Movable extends en.mob.Lock {
	var superHitCd			: Int;
	var fallStartY			: Float;
	public function new(x,y) {
		super(x,y);

		fallStartY = yy;
		superHitCd = rseed.irange(0,2);

		sprite.set("lockMovable");
		initLife(25);
	}

	override function hit(ox,oy, d) {
		super.hit(ox,oy,d);

		cd.set("recentHit", Const.seconds(0.5));
		superHitCd--;
		var d = ox<xx ? 1 : -1;
		if( superHitCd<=0 ) {
			dx += rseed.range(0.10, 0.15) * d;
			dy += -rseed.range(0.1, 0.4);
			superHitCd = rseed.irange(1,4);
		}
		else
			dx += rseed.range(0.01, 0.03) * d;
	}

	override function onLand() {
		super.onLand();
		if( yy-fallStartY>=50 ) {
			var r = 60;
			fx.bombExplosion(xx,yy-15, r);
			for(e in en.Mob.ALL)
				if( atDistance(e, r) )
					e.hit(xx,yy, 5);

		}
	}


	override function update() {
		super.update();

		if( dy<=0 )
			fallStartY = yy;

		if( superHitCd>0 && !cd.has("recentHit") )
			superHitCd = 0;
	}
}


