package en.mob;

class Rabbit extends en.Mob {
	
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 0;
		setSpeed(0.3);
		radius = 8;
		initLife(1);
		strength = 0;
		
		sprite.swap("rabbit");
		sprite.setCenter(0.5, 0.95);
		var f = rnd(0, 0.1);
		var c = mt.deepnight.Color.randomColor(rseed.rand(), 1, 1);
		sprite.filters = [ mt.deepnight.Color.getColorizeMatrixFilter(c, f, 1-f) ];
		setShadow(true);
	}
	
	override function getLoot() { return api.AKApi.const(0); }
	override function getXp() { return api.AKApi.const(1); }
	
	override function defaultAI() {
		if( !cd.has("sawHero") ) {
			var d = distance(hero);
			if( d<100 || d<200 && sightCheck(hero) )
				cd.set("sawHero", 60);
		}
		
		if( cd.has("sawHero") ) {
			gotoDumb(hero.xx, hero.yy);
			decisionCD(20);
		}
		else {
			wander();
			decisionCD(30);
		}
	}
}
