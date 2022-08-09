package en.it;

class MegaBomb extends en.Item {
	public function new(x,y) {
		super(x,y);
		setDuration(30);

		sprite.a.playAndLoop("concussion");
		addGlow("glow_concussion");
	}

	override function onPick() {
		super.onPick();
		fx.flashBang(0xFFFF00, 1);
		fx.rocks();
		for(e in en.Mob.ALL) {
			if( !e.canBeHit )
				continue;

			e.hit(xx,yy, 1);
			if( !e.slamImmune )
				e.ignoreFloors(2);
		}
	}
}
