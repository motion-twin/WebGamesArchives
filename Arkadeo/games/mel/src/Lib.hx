import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFormat;

typedef Prof = mt.gx.Profiler;


class Lib
{
	public static inline var sw = 600;
	public static inline var sh = 480;
	
	public static function ph() : Int
		return nbch() << ch_shift
		
	public static function h() : Int
		return sh-20
	
	public static function w() : Int
		return sw
		
	public static function nbch() : Int
		return (sh-20) >> ch_shift ///16
	
	public static function nbcw() : Int
		return sw >> cw_shift
		
	public static var cw : Int = 16;
	public static var cw_shift : Int = 4;
	
	public static var ch : Int = 16;
	public static var ch_shift : Int = 4;
	
	public static function cacheFrames( mc : flash.display.MovieClip ) : IntHash<flash.display.Bitmap>
	{
		var h = new IntHash();
		for ( i in 1...mc.totalFrames + 1)
		{
			mc.gotoAndStop( i );
			h.set( i , mt.deepnight.Lib.flatten( mc ) );
		}
		return h;
	}
	
	public static function getTf(txt,sz=10) : TextField
	{
		var word = new TextField();
		word.text = txt;
		
		var tf = new TextFormat("galaxy", sz);
		tf.color = 0xff8200;
		word.embedFonts = true;
		word.setTextFormat( word.defaultTextFormat = tf );
		word.filters = [Data.getOrangeFilter(), Data.getOuterBlackFilter()];
		word.selectable  = false;
		word.cacheAsBitmap = true; 
		return word;
	}
	
	//returns true whether we are on location
	public static function goto( 
	mx : Float, my: Float, 
	x: Float, y: Float,
	
	speed: Float,eps=0.1 ) : Null<{nx:Float,ny:Float}> 
	{
		//if ( Math.abs((x - mx) + (y - my )) < eps)	
		//	return {nx:mx,ny:my};
			
		var diffX = x - mx;
		var diffY = y - my;
		
		var len = diffX * diffX + diffY * diffY;
		if ( len <= eps*eps ) return {nx:x,ny:y};
		
		if ( len < speed )	//yet on more frame to strive
		{
			mx = x;
			my = y;
		}
		else
		{
			var il = 1.0 / len;
			var dx = diffX *il;
			var dy = diffY *il;
			
			mx += dx * speed;
			my += dy * speed;
		}
		return {nx:mx,ny:my};
	}

	public static inline var WALL_ID = 0xAA;
}