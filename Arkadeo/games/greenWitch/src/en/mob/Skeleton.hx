package en.mob;

class Skeleton extends en.Mob {
	public function new(x,y) {
		super(x,y);
		
		maxPathLen = 15;
		setSpeed(0.6);
		radius = 8;
		initLife(2);
		
		sprite.swap("skel"+irnd(1,3));
		sprite.setCenter(0.5, 1);
		setShadow(true);
	}
	
	override function getLoot() { return null; }
	override function getXp() { return api.AKApi.const(0); }
	
	override public function onDie() {
		super.onDie();
		if( !hero.dead )
			if( Std.random(3)==0 )
				play3dSound( S.BANK.mobHit01(), mt.deepnight.Lib.rnd(0.3, 0.5) );
			else
				play3dSound( S.BANK.mobHit02(), mt.deepnight.Lib.rnd(0.3, 0.5) );
	}
	
	override function splat() {
		fx.death(xx,yy,0xCFC7AD);
		fx.bones(xx,yy);
	}
}
