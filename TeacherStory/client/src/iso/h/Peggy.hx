package iso.h;

import flash.display.MovieClip;

class Peggy extends iso.Helper {
	public function new() {
		super(Peggy);
		headY+=10;
		defaultPos = {cx:8, cy:Const.EXIT.y, dir:-1}
		init( cast new lib.Peggy() );
	}
}

