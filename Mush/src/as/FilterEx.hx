package ;

/**
 * ...
 * @author de
 */

class FilterEx
{

	public static function outline( mc: flash.display.DisplayObject, col :UInt, sz=2,a=1.0,str=255 ) : flash.filters.GlowFilter
	{
		Debug.ASSERT( mc.width < 1000);
		Debug.ASSERT( mc.height < 1000);
		mc.filters  = [];
		var f = new flash.filters.GlowFilter();
		f.color = col;
		f.blurX = sz;
		f.blurY = sz;
		f.alpha = a;
		f.strength = str;
		mc.filters = [ f ];
		return f;
	}
	
}