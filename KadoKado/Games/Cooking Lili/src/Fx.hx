class Fx {
	var game			: Game;
	public var mc		: flash.MovieClip;

	public function new(g) {
		game = g;
	}

	public function destroy() {
		mc.removeMovieClip();
		mc = null;
	}

	public function update() {
	}
}