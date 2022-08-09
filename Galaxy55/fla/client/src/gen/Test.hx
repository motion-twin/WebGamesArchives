package gen;
import Common;

typedef K = flash.ui.Keyboard;

class Test {
	
	static var SEED = Std.random(50000);
	static var BIOME = 0;
	
	static function generate() {
		haxe.Log.clear();
		haxe.Log.setColor(0xFF0000);
		
		trace( { biome : BIOME, seed : SEED } );
		
		var size = Const.SIZE * 2;
		var g = new gen.BiomeGenerator(size, SEED);
		g.fast = true;
		var b = Type.createEnumIndex(BiomeKind,BIOME);
		g.startGenerate(b);
		var t0 = flash.Lib.getTimer();
		while( g.process() ) {
		}
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
				BIOME++;
				generate();
			case K.NUMPAD_SUBTRACT:
				BIOME--;
				generate();
			default:
			}
		});
	}
	
}