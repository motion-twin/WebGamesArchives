package iso.h;

import flash.display.MovieClip;

class Director extends iso.Helper {
	public function new() {
		super(Director);
		init( cast new lib.Muzot() );
	}
}

