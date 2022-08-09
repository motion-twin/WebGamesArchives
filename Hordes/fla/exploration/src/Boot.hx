
class Boot {
	public static var man = null;

	static function main() {
		if( haxe.Firebug.detect() )
			haxe.Firebug.redirectTraces();
		var rootMc = flash.Lib.current;
		var mc = rootMc.createEmptyMovieClip("mroot", 1);
		man = new Manager(mc);
		mc.onEnterFrame = man.main;
		Reflect.setField(flash.Lib._global, "api", FlashExplo);
	}
}
