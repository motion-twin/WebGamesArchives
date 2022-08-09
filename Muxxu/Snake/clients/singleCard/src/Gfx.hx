
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import mt.bumdum9.Lib;

class GfxPal extends BitmapData { }
class GfxMain extends BitmapData { }

class Gfx {//}

	// COLORS
	public static var BLACK = 			4278190080;
	public static var WHITE = 			4294967295;
	public static var BLUE = 			4283267837;
	public static var DARK_BLUE = 		4284492967;
	
	static public var main :		pix.Store;
	
	// TEXT
	static public var textures :Array<BitmapData>;
	
	static public function init() {

		initPal();
		
		// MAIN
		var bmp = new GfxMain(0, 0);
		makeTransp(bmp, WHITE);
		main = new pix.Store(bmp);
		main.addIndex("cards");
		main.slice(0, 0, 43, 62, 2);
		main.addIndex("icon_play");
		main.slice(88, 72, 8, 8, 2);
		main.addIndex("icon_flash");
		main.slice(128, 72, 8, 8 );
		main.addIndex("icon_freq");
		main.slice(136, 72, 3, 3, 3 );
		
		main.addIndex("token");
		main.slice(16, 96, 9, 9);
	}
		
	static function makeTransp( bmp:BitmapData, color:Float ) {
		for ( x in 0...bmp.width ) {
			for ( y in 0...bmp.height ) {
				if ( bmp.getPixel32(x, y) == color ) {
					bmp.setPixel32(x, y, 0 );
				}
			}
		}
	}
	static function replaceCol( bmp, a:Float, b:Float ) {
		for ( x in 0...bmp.width ) {
			for ( y in 0...bmp.height ) {
				if ( bmp.getPixel32(x, y) == a ) {
					bmp.setPixel32(x, y, cast b );
				}
			}
		}
		return bmp;
	}
	
	static public var pal: Hash<Int>;
	static function initPal() {
		
		//
		var bmp = new GfxPal(0, 0);
		var b = [];
		var size = 10;
		var patch = 4;
		for ( i in 0...100 ) {
			var x = (i % size) * patch;
			var y = Std.int(i / size) * patch;
			var col = bmp.getPixel( x, y );
			b.push(col);
		}
		//
		var a = [
			"green_0", "green_1", "green_2", "red_0", "red_1", "red_2","or_0","or_1","or_2","or_3",
			"snake_0","snake_1","snake_2",
		];
		//
		pal = new Hash<Int>();
		for ( i in 0...a.length ) {
			var label = a[i];
			pal.set(label, b[i]);
		}
		
	}
	static public function col(key) {
		return pal.get(key);
	}
		

//{
}



