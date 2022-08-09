package en;

import mt.deepnight.Lib;

class Turret extends Entity {
	public var absorbDamageRange	: Int;
	
	public function new(tcx,tcy) {
		super();

		absorbDamageRange = 0;
		collides = true;
		weight = 2;
		side = 0;
		
		cx = tcx;
		cy = tcy;
		updateScreenCoords();
		barOffsetY = -2;

		sprite.swap("turret");
		sprite.setCenter(0.5, 0.8);
		setShadow(true);
		fx.spawnSmoke(this);
	}
	
	public override function destroy() {
		super.destroy();
		if( game.hero.turret==this )
			game.hero.turret = null;
	}

	override function popDamage(d) {
		//fx.pop(xx,yy, -d, 0xFF0000);
	}
	
	public function explode() {
		fx.turretExplosion(xx,yy, 0x70DF00);
		destroy();
	}
	
	public override function onDie() {
		super.onDie();
		fx.turretExplosion(xx,yy, 0x70DF00);
	}

	//override public function hit(d:Int) {
		//super.hit(d);
		//if( !cd.has("shield") )
			//cd.set("shield", 30);
	//}
}