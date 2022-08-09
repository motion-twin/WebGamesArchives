package en.mob;

class Bleuarg extends en.Mob {
	public function new(x,y) {
		super(x,y);
		
		baseScore = 25;
		setSpeed(0.8);
		weight = 8;
		radius = 14;
		initLife(15);
		strength = 2;
		
		setShadow(true);
		
		sprite.swap("bleuarg");
		sprite.setCenter(0.5, 1);
	}

	override function getLoot() { return api.AKApi.const(2); }
	override function getXp() { return api.AKApi.const(4); }

	
	override function hit(d) {
		super.hit(d);
		//play3dSound( S.BANK.hit05(), 0.2 );
	}
	override function onDie() {
		super.onDie();
		play3dSound( S.BANK.explode01() );
	}
}

