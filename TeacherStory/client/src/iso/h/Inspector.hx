package iso.h;

import flash.display.MovieClip;

class Inspector extends iso.Helper {
	public function new() {
		super(Inspector);
		init( cast new lib.Sherlock() );
	}
}

