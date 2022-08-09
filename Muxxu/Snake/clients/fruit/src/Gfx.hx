
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import mt.bumdum9.Lib;

class GfxFruits extends BitmapData { }
class GfxBg extends BitmapData { }

class Gfx {//}

	// COLORS
	public static var BLACK = 			4278190080;
	public static var WHITE = 			4294967295;
	public static var BLUE = 			4283267837;
	public static var DARK_BLUE = 		4284492967;
	
	static public var bg :			pix.Store;
	static public var fruits :		pix.Store;
	
	// TEXT
	static public var textures :Array<BitmapData>;
	
	static public function init() {

	
		/// FRUITS ///
		var bmp = new GfxFruits(0, 0);
		makeTransp(bmp, WHITE );
		fruits = new pix.Store(bmp);
		fruits.addIndex("main");
		fruits.slice(0, 0, 32, 32, 20, 16);
		
		/// BG ///
		var bmp = new GfxBg(0, 0);
		bg = new pix.Store(bmp);
		bg.addIndex("main");
		bg.slice(0, 0, Vig.WIDTH, Vig.HEIGHT);
		
		bg.addIndex("arrow");
		bg.slice(0,Vig.HEIGHT, 21, 12, 6);
	
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
	
	// TOOLS

//{
}



