package en.mob;

class Horde extends en.Mob {
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 15;
		setSpeed(0.6);
		radius = 8;
		initLife(2);
		
		sprite.swap("horde"+irnd(1,2));
		sprite.setCenter(0.5, 0.7);
		setShadow(false);
	}
	
	override function getLoot() { return api.AKApi.const(0); }
	override function getXp() { return api.AKApi.const(1); }


	override public function onDie() {
		super.onDie();
		if( !hero.dead )
			if( Std.random(3)==0 )
				play3dSound( S.BANK.mobHit01(), mt.deepnight.Lib.rnd(0.3, 0.5) );
			else
				play3dSound( S.BANK.mobHit02(), mt.deepnight.Lib.rnd(0.3, 0.5) );
	}
}
