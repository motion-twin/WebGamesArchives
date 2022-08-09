package en.mob.lock;

import mt.MLib;

class Golden extends Silver {
	public function new(x,y) {
		super(x,y);

		sprite.set("lockGold");
		initLife(40);
	}
}


