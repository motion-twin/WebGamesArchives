package en.mob;

class Simple extends Walker {
	public function new(x,y) {
		super(x,y);
		speed*=0.25;
		initLife(2);
		type = MT_Simple;

		animBaseKey = "mob_b";
		radius = 12;

		sprite.filters = [ mt.deepnight.Color.getColorizeFilter(0x64979B, 0.5, 0.5) ];
	}

	override function loot() {
		dropGold(2);
	}
}

