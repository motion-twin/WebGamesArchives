package ;

/**
 * Bitmap cacheable Sprite
 */

class Cacheable extends flash.display.Sprite
{

	var mc : flash.display.Sprite;	/* original mc */
	var bmp : flash.display.Bitmap;	/* cached version */
	var bmpd : flash.display.BitmapData;
	public var isCache : Bool;
	
	/**
	 *
	 * @param	_mc		original MC
	 * @param	_cache=false	do bitmap cache
	 */
	public function new(_mc,_cache=false)
	{
		super();
		mc = _mc;
		addChild(mc);
		setCache(_cache);
	}
	
	
	public function setCache(on = true) {
		isCache = on;
		if(bmp == null) {
			bmpd = new flash.display.BitmapData(Std.int(mc.width) + 1, Std.int(mc.height) + 1, true, Std.random(0xFFFFFF));
			var bounds = mc.getBounds(mc);
			bmpd.draw(mc,new flash.geom.Matrix(1,0,0,1,-bounds.x,-bounds.y));
			bmp = new flash.display.Bitmap(bmpd,flash.display.PixelSnapping.NEVER,false);
			bmp.x = bounds.x;
			bmp.y = bounds.y;
		}
		
		
		if(on) {
			if(mc.parent!=null) removeChild(mc);
			addChild(bmp);
		}else {
			addChild(mc);
			if(bmp.parent!=null) removeChild(bmp);
		}
		
	}
	
}