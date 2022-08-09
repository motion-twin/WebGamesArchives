package en.mob;

class Big extends Walker {
	public static var COUNT = 0;

	public function new(x,y) {
		super(x,y);

		type = MT_Big;
		animBaseKey = "mob_c";
		slamImmune = true;
		speed*=0.3;
		radius = 17;
		initLife(20);
		barY -= 15;
		COUNT++;
	}

	override function unregister() {
		super.unregister();
		COUNT--;
	}

	override function loot() {
		dropGold(15);
	}
}

