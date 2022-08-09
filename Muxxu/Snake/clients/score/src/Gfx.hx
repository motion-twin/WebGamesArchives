
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import Main;
import mt.bumdum9.Lib;

class GfxArts extends BitmapData { }
class GfxBg extends BitmapData { }
class GfxPal extends BitmapData { }

class Gfx {//}

	// COLORS
	public static var BLACK = 			4278190080;
	public static var WHITE = 			4294967295;
	public static var BLUE = 			4283267837;
	public static var DARK_BLUE = 		4284492967;
	
	static public var bg :		pix.Store;
	static public var arts :		pix.Store;
	
	// TEXT
	static public var textures :Array<BitmapData>;
	
	static public function init() {

		initPal();
		
		// ARTS
		var bmp = new GfxArts(0, 0);
		mt.flash.DecodeBitmap.run(bmp);
		arts = new pix.Store(bmp);
		var ww = 10;
		var hh = Math.ceil(Data.getCardMax() / ww);
		arts.slice(0, 0, 37, 43, ww, hh);
		
		// BG
		var bmp = new GfxBg(0, 0);
		bmp.threshold(bmp, bmp.rect, new PT(0, 0), "==", 0xFFFF00FF, 0x00FFFFFF );
		bg = new pix.Store(bmp);
		bg.slice(0, 0, 40, Vig.HEIGHT);
		bg.slice(0, 22, 20, 20, 2);
		bg.slice(40, 22, 20, 22, 2);
		bg.slice(40, 22, 20, 22, 2);
		
		bg.addIndex("but_replay");
		bg.slice(40, 0, 20, 22, 2);
		
		bg.addIndex("but_scroll");
		bg.slice(80, 0, 44, 44, 3);
		
		bg.addIndex("but_scroll_fast");
		bg.slice(0, 44, 44, 20, 3);
		
		bg.addIndex("prize");
		bg.slice(220, 0, 20,20, 2, 2);
		
		
	}
	
	// PAL
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
			"snake_0","snake_1","snake_2","blue_0","blue_1","blue_2",
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
			
	//
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
	
	// TOOLS

//{
}



