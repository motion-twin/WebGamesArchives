class Boot {
	public static var man = null;

	static function main() {
		haxe.Log.setColor(0xFFFF00);

		if( flash.external.ExternalInterface.call("eval","1") != 1 ) {
			trace("Failed to run JS");
			haxe.Timer.delay(main,1000);
			return;
		}

		var root : flash.MovieClip = flash.Lib.current;
		var mc : flash.MovieClip = root.createEmptyMovieClip("mroot", 1);
		man = new Manager(mc);
		mc.onEnterFrame = man.main;
	}
}

