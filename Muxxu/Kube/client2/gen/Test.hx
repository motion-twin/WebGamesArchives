package gen;
import Common;

typedef K = flash.ui.Keyboard;

class Test {
	
	static var SEED = Std.random(50000);
	static var CLIMATE = 0;
	
	static function generate() {
		haxe.Log.clear();
		haxe.Log.setColor(0xFF0000);
		
		trace( { climate : CLIMATE, seed : SEED } );
		
		var size = 128 * 3;
		var g = new gen.Generator(size, Const.ZSIZE, SEED);
		g.fast = true;
		g.generate(CLIMATE);
		
		var bmp = g.getBitmap();
		flash.Lib.current.addChild(new flash.display.Bitmap(bmp));
		var b2 = new flash.display.Bitmap(bmp);
		b2.x = size + 1;
		flash.Lib.current.addChild(b2);
		var b2 = new flash.display.Bitmap(bmp);
		b2.y = size + 1;
		flash.Lib.current.addChild(b2);
		var b2 = new flash.display.Bitmap(bmp);
		b2.x = b2.y = size + 1;
		flash.Lib.current.addChild(b2);
	}
	
	
	public static function main() {
		generate();
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(k:flash.events.KeyboardEvent) {
			switch( k.keyCode ) {
			case 0x20:
				SEED++;
				generate();
			case K.NUMPAD_ADD:
				CLIMATE++;
				generate();
			case K.NUMPAD_SUBTRACT:
				CLIMATE--;
				generate();
			default:
			}
		});
	}
	
}