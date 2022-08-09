package en.it;

import api.AKProtocol;
import api.AKConst;

class KPoint extends en.Item {
	public static var ALL : Array<KPoint> = [];
	public var kp		: SecureInGamePrizeTokens;
	var active			: Bool;
	var lockStep		: Int;

	public function new(x,y,kp) {
		super(x,y-2);
		lockStep = 0;
		this.kp = kp;
		setDuration(60);
		sprite.visible = active = false;

		var id = switch( kp.frame ) {
			case 1 : "kado1Pk";
			case 2 : "kado5Pk";
			case 3 : "kado10Pk";
			case 4 : "kado20Pk";
			default : null;
		}
		if( id!=null )
			sprite.a.playAndLoop(id);
		addGlow("glow_bomb");
		ALL.push(this);
	}

	public static function spawn(oneLockRemain:Bool) {
		var inactives = ALL.filter( function(e) return !e.active );
		if( inactives.length<=0 )
			return;

		var rseed = Mode.ME.rseed;
		var n = oneLockRemain ? inactives.length : rseed.irange(-1, inactives.length);

		if( n<=0 )
			return;

		var spots = Mode.ME.level.getGroundSpotsAround(Mode.ME.hero.cx, Mode.ME.hero.cy, 3, 7);
		while( n>0 && spots.length>0 ) {
			var pt = spots.splice(rseed.random(spots.length),1)[0];
			var e = ALL.splice(rseed.random(ALL.length),1)[0];
			e.activate(pt.cx, pt.cy);
			n--;
		}
	}

	override function destroy() {
		super.destroy();
		ALL.remove(this);
	}

	public function activate(x,y) {
		if( active )
			return;

		setPos(x,y);
		active = true;
		fx.spawnKP(this);
		sprite.visible = true;
		cd.set("pickKP", Const.seconds(0.2));
	}

	override function onPick() {
		if( !active || cd.has("pickKP") )
			return;

		super.onPick();

		fx.pickKP(this);
		api.AKApi.takePrizeTokens(kp);
		destroy();

		// Explosion
		//var r = 100;
		//for(e in en.Mob.ALL)
			//if( atDistance(e, r) ) {
				//e.hit(xx,yy, 5);
				//e.ignoreFloors(1);
			//}
	}

	override function update() {
		super.update();

		if( !active && api.AKApi.getScore()>kp.score.get() ) {
			var pt = mode.level.getRandomSpotFar();
			activate(pt.cx, pt.cy);
		}
		if( glow!=null )
			glow.alpha*=0.3;
	}
}
