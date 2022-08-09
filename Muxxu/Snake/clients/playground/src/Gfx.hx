import Protocole;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import mt.bumdum9.Lib;


class GfxMain extends BitmapData { }
class GfxFruits extends BitmapData { }
class GfxFx extends BitmapData { }
class GfxFont extends BitmapData { }
class GfxPal extends BitmapData { }
class GfxBonus extends BitmapData { }
class GfxBrowser extends BitmapData { }
class GfxBrowserFront extends BitmapData { }
class GfxElements extends BitmapData { }
class Gfx500 extends BitmapData { }

class Gfx {//}
	// COLORS
	public static var BLACK = 			4278190080;
	public static var WHITE = 			4294967295;
	public static var BLUE = 			4283267837;
	public static var DARK_BLUE = 		4284492967;
	
	static public var el :				pix.Store;
	static public var bg :				pix.Store;
	static public var main :			pix.Store;
	static public var fruits :			pix.Store;
	static public var bonus :			pix.Store;
	static public var fx :				pix.Store;
	static public var browser :			pix.Store;
	static public var browserFront :	pix.Store;
	static public var tilesColor :		pix.Store;
	static public var tilesGrey :		pix.Store;
	static public var bg500 :			pix.Store;
	
	static public var fontA :		pix.Font;
	static public var fontB :		pix.Font;
	static public var fontC :		pix.Font;
	static public var fontD :		pix.Font;
	
	// MEM
	public static var bmpFx:BitmapData;
	
	// TEXT
	static public var textures :Array<BitmapData>;
	
	static public function init() {

		/// FRUITS ///
		var bmp = new GfxFruits(0, 0);
		makeTransp(bmp, WHITE );
		fruits = new pix.Store(bmp);
		fruits.addIndex("main");
		fruits.slice(0, 0, 32,32, 20, 16);
		
		// BONUS ///
		var bmp = new GfxBonus(0, 0);
		makeTransp(bmp, WHITE );
		bonus = new pix.Store(bmp);
		bonus.addIndex("main");
		bonus.slice(0, 0, 32, 32, 6, 6);
		
		//
		initMain();
		initFx();
		initElements();
		
		/// FONT ///
		var bmp = new GfxFont(0, 0);
		makeTransp(bmp, WHITE );
		fontA = new pix.Font(bmp,10,14, 0, 0, 11, 1);
		fontB = new pix.Font(bmp, 10, 14 , 0, 14, 11, 1);
		fontC = new pix.Font(bmp, 8, 10, 0, 28);
		fontD = new pix.Font(bmp, 5, 7, 0, 58, 10, 1);
		var a = [fontA, fontB];
		for ( font in a ) {
			font.setSpecialChar("-", 10);
		}
	
		// GFX 500
		var bmp = new Gfx500(0, 0);
		bg500 = new pix.Store(bmp);
		bg500.slice(0, 0, 500, 500);
	
		
		/// PAL ///
		initPal();
	}
	static function initFx() {
		var bmp = new GfxFx(0, 0);
		bmpFx = bmp;
		makeTransp(bmp, WHITE );
		fx = new pix.Store(bmp);
		/*
		fx.addIndex("blood");
		fx.slice(0, 0, 40, 40, 3);
		fx.addAnim("blood", [0, 0, 1, 1, 2]);
		*/
		
		fx.addIndex("bad_star");
		fx.slice(0, 0, 24, 24, 3);
		
		fx.addIndex("burn");
		fx.slice(48, 32, 16, 24, 8 );
		fx.addAnim("burn", [0, 1, 2, 3, 4, 5, 6, 7], [1, 1, 1, 2, 2, 2, 3, 3]);
		
		fx.addIndex("blood");
		fx.slice(0, 48, 32, 32);
		
		fx.addIndex("blood_trace");
		fx.slice(32, 66, 16, 12, 8);
		fx.addAnim("blood_trace", [0, 1, 2, 3, 4, 5, 6, 7], [3, 2, 1]);
		
		fx.addIndex("blood_mini_spot");
		fx.slice(0, 80, 16, 16);
		fx.slice(16, 80, 8, 8, 2, 2);
		
		fx.addIndex("slash");
		fx.slice(32, 56, 32, 8);
		
		fx.addIndex("bomb");
		fx.slice(32, 80, 16, 16, 3);
		fx.addAnim("bomb", [0, 1, 2], [4, 2, 4] );
		
		fx.addIndex("miniflame");
		fx.slice(64, 56, 8, 8, 9);
		fx.addAnim("miniflame", [0, 1, 2, 3, 4, 5, 6, 7, 8], [1, 1, 1, 1, 2] );
		
		fx.addIndex("record");
		fx.slice(80,80,29,5,1,2);
		fx.addAnim("record", [0, 1], [6] );
		
		fx.addIndex("onde");
		fx.slice(80,0,32,32,6);
		fx.addAnim("onde", [0, 1, 2, 3, 4, 5]);
		fx.addAnim("onde_slow", [0, 1, 2, 3, 4, 5],[2]);
		
		fx.addIndex("blood_drop");
		fx.slice(1, 62, 3, 3);
		
		fx.addIndex("body_explode");
		fx.slice(0, 96, 32, 32, 10);
		fx.addAnim("body_explode", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], [1, 1, 1, 2, 3, 4, 3, 2, 1]);
		
		fx.addIndex("smiley");
		fx.slice(192, 32, 32, 32 );
		
		fx.addIndex("pin");
		fx.slice(112, 80, 16, 16 );
		fx.slice(112, 80, 16, 16, 1, 1, true );
		
		fx.addIndex("spark_onde");
		fx.slice(128, 80, 8, 8, 2, 2);
		fx.addAnim("spark_onde", [0, 1, 2, 3 ], [1, 2, 3, 4]);
		
		fx.addIndex("volt");
		fx.slice(144, 80, 8, 8, 2, 2);
		fx.addAnim("volt", [0, 1, 2, 3 ], [2]);
		
		fx.addIndex("soap");
		fx.slice(160, 64, 16, 16, 8, 1);
		fx.addAnim("soap",[0,1,2,3,4,5,6,7],[2]);
		
		fx.addIndex("pink_ribbon");
		fx.slice(224, 32, 32, 32 );
		
		fx.addIndex("tennis_ball");
		fx.slice(160, 80, 8, 8, 3 , 2 );
		fx.addAnim("tennis_ball",[0,1,2,3,4,5],[2]);
		
		fx.addIndex("big_shield");
		fx.slice(256,32,32,32 );
	
		fx.addIndex("crane");
		fx.slice(0, 128, 16, 24, 12 );
		fx.addAnim("crane", [0, 1, 2, 3, 3, 4, 4, 4, 5, 5, 6, 7, 8, 9, 10, 11]);
		
		fx.addIndex("pulse");
		fx.slice(192, 128, 32, 32, 3 );
		fx.addAnim("pulse", [0, 1, 2], [1]);
		
		fx.addIndex("spark_dust");
		fx.slice(184, 80, 8, 8, 4, 2);
		fx.addAnim("spark_dust", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 2, 3, 3], [1]);
		fx.addAnim("spark_dust_fast", [0, 1, 0, 1, 0, 1, 2, 3, 3], [1]);
		fx.addAnim("spark_dust_blow", [4, 5, 6, 0], [1]);
		fx.addAnim("spark_dust_pulse", [0, 0, 0, 2], [2]);
		
		fx.addIndex("grain");
		fx.slice(216, 80, 8, 8, 5);

		fx.addIndex("snake_parts");
		fx.slice(216, 88,  8, 8, 6 );
		
		fx.addIndex("bubble");
		fx.slice(0, 152,  16, 16, 5 );
		fx.addAnim("bubble", [0, 1, 2, 3, 4], [2,2,8,2,2]);
		
		
		
		
	}
	static function initMain() {
		var bmp = new GfxMain(0,0);
		makeTransp(bmp, WHITE );
		main = new pix.Store(bmp);
		main.addIndex("cards");
		main.slice(0, 0, 43, 62, 2);
		
		main.addIndex("frutibar");
		main.slice(0, 64,  12, 9, 2 );
		main.addIndex("frutibar_bg");
		main.slice(24, 64,  12, 8 );
		
		main.addIndex("key");
		main.slice(0, 80, 16 , 16);
		
		main.addIndex("round_key");
		main.slice(48, 80, 16 , 16);
		
		main.addIndex("card_dark");
		main.slice(86, 0, 43, 62, 2);
		
		main.addIndex("shield");
		main.slice(88, 64, 6, 8, 10);
		
		main.addIndex("checkbox");
		main.slice(48, 80, 8, 8, 2);
		
		main.addIndex("mojo");
		main.slice(172, 0, 76, 62, 2);
		
		main.addIndex("loading_bar");
		main.slice(64, 80, 60, 5, 1, 5);
		main.addAnim("loading_bar", [0, 1, 2, 3, 4], [2]);
		
		main.addIndex("icon_play");
		main.slice(88, 72, 8, 8, 2);
		
		main.addIndex("icon_skull");
		main.slice(112, 72, 8, 8 );
		
		main.addIndex("icon_star");
		main.slice(120, 72, 8, 8 );
		
		main.addIndex("icon_flash");
		main.slice(128, 72, 8, 8 );
		
		main.addIndex("art_control");
		main.slice(0, 128, 96, 64, 3 );
		main.slice(0, 128, 192, 64 );
		
	}
	
	static function initElements() {
		var bmp = new GfxElements(0, 0);
		makeTransp(bmp, WHITE );
		el = new pix.Store(bmp);
		el.addIndex("title");
		el.slice(0, 55, 161, 32);
		
		el.addIndex("stars");
		el.slice(80, 40, 8, 8, 3);
		el.addAnim("stars", [0, 1, 2, 1], [12, 2, 2, 2]);
		
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
	public static function replaceCol( bmp:BitmapData, a:Float, b:Float ) {
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



