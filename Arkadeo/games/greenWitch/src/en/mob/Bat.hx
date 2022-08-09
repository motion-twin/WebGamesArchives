package en.mob;

class Bat extends en.Mob {
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 15;
		weight = 0.5;
		baseScore = 15;
		
		setSpeed(1.2);
		radius = 8;
		initLife(1);
		strength = 0;
		
		sprite.swap("bat");
		sprite.setCenter(0.5, 1.2);
		setShadow(true);
	}
	
	override function getLoot() { return null; }
	override function getXp() { return api.AKApi.const(1); }

	override public function onTouchEntity(e:Entity) {
		super.onTouchEntity(e);
		if( e==game.hero && !game.hero.dead ) {
			if( !e.cd.has("slow") ) {
				fx.pop(e.xx, e.yy, Lang.SlowedDown, 0x1DE276);
				S.BANK.debuff01().play(0.5);
			}
			e.slowDown(25);
		}
	}
	
	override function hit(d) {
		super.hit(d);
		mt.deepnight.Sfx.playOne([S.BANK.die04, S.BANK.die05], mt.deepnight.Lib.rnd(0.1, 0.3));
	}
}
