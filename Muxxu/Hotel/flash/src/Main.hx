import flash.Lib;

class Main {
	static function main() {
		flash.system.Security.allowDomain("hotel.local.muxxu.com");
		flash.system.Security.allowDomain("hotel.muxxu.com");
		flash.system.Security.allowDomain("hotel.es.muxxu.com");
		flash.system.Security.allowDomain("hotel.en.muxxu.com");
		flash.system.Security.allowDomain("hotel.de.muxxu.com");
		var mc = new flash.display.MovieClip();
		Lib.current.addChild(mc);
		var game = new Game( mc );
	}
}

