package iso.h;

import flash.display.MovieClip;

class Tizoc extends iso.Helper {
	public function new() {
		super(Einstein);
		defaultPos = {cx:4, cy:9, dir:1};
		init( cast new lib.Tizoc() );
	}
}

