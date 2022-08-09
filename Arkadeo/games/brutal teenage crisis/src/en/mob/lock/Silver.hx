package en.mob.lock;

import mt.MLib;

class Silver extends en.mob.Lock {
	var fixedPos		: {cx:Int, cy:Int};

	public function new(x,y) {
		super(x,y);

		sprite.set("lockSilver");
		initLife(12);

		fixedPos = { cx:cx, cy:cy };
		frictX = frictY = 0.8;
		repelOnHit = true;
	}

	override function update() {
		var s = 0.03;
		var fx = ( fixedPos.cx+0.5 ) * Const.GRID;
		var fy = ( fixedPos.cy+1 ) * Const.GRID;

		dx += (fx-xx)*s;
		dy += (fy-yy)*s;

		super.update();
	}

}


