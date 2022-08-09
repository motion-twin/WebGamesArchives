package en.mob;

class Classic extends Walker {
	public function new(x,y) {
		super(x,y);

		type = MT_Classic;
		animBaseKey = "mob_b";
		speed *= 0.5 + 0.15 * Math.min(1, mode.diff/200);
		radius = 12;
	}

	override function resetIgnoreLadder() {
		super.resetIgnoreLadder();
		if( mode.isProgression() )
			cd.set("ignoreLadder", Const.seconds( rnd(0, 2) ));
	}

	override function loot() {
		dropGold(4);
	}

	override function update() {
		super.update();
	}
}

