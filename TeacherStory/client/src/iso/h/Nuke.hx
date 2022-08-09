package iso.h;

import flash.display.MovieClip;

class Nuke extends iso.Helper {
	public function new() {
		super(Skeleton);
		defaultPos = {cx:6, cy:1, dir:-1}
		hotspot.y = 9;
		init( cast new lib.Nuke() );
	}
	
	override function arrival() {
		super.arrival();
		man.cm.chainToLast({
			say(Tx.Duke);
		});
	}
}

