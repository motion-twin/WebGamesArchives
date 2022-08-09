package en.mob;

class Kamikaze extends en.Mob {
	static var SUICIDE_SLOW = api.AKApi.const(25);
	static var SUICIDE_FAST = api.AKApi.const(15);
	var range			: Int;
	
	public function new(x,y) {
		super(x,y);
		
		range = 100;
		setSpeed(0.85);
		weight = 3.5;
		strength = 1;
		baseScore = 60;
		radius = 14;
		initLife(10);
		barOffsetY = 32;
		
		setShadow(true);
		
		sprite.swap(game.char, "kamikaze");
		sprite.setCenter(0.5, 1);
	}
	
	override function getLoot() { return api.AKApi.const(1); }
	override function getXp() { return api.AKApi.const(2); }

	function suicide() {
		var victims : Array<Entity> = [game.hero];
		if( game.hero.turret!=null )
			victims.push(game.hero.turret);
		victims = victims.concat( cast en.Prop.ALL );
		for(e in victims) {
			var d = distance(e);
			if( d<=range ) {
				e.stun(30);
				e.cd.unset("shield");
				e.hit(3);
				var a = Math.atan2(e.yy-yy, e.xx-xx);
				e.dx+=Math.cos(a)*2 * (1-d/range);
				e.dy+=Math.sin(a)*2 * (1-d/range);
				e.lookDir = e.xx>xx ? -1 : 1;
				e.cd.set("lookLock", e.cd.get("stun"));
			}
		}
		fx.kamikazeExplosion(xx,yy, range);
		destroy();
	}
	
	public override function update() {
		super.update();
		
		if( cd.has("suicide") ) {
			if( game.time%2==0 )
				sprite.filters = [];
			else
				sprite.filters = [ new flash.filters.GlowFilter(0xFFFF00,1, 2,2, 5) ];
		}
		
		if( !killed && !cd.has("suicide") )
			if( game.time%3==0 && distance(game.hero)<=range*0.45 ) {
				if( sightCheck(hero) ) {
					var d = game.isLeague() || game.isProgression() && game.asProgression().level>=12 ? SUICIDE_FAST.get() : SUICIDE_SLOW.get();
					cd.set("suicide", d);
					cd.onComplete("suicide", suicide);
					maxPathLen = 0;
					stop();
				}
			}
	}
}
