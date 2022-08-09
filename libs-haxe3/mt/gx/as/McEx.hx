package mt.gx.as;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

class McEx
{
	/**disposes/frees all children
	 * detachment should be done separately
	 */
	
	public static inline function freeOne(o : DisplayObject) {
		if ( Reflect.hasField( o, "dispose" ) && Reflect.isFunction( Reflect.getProperty( o , "dispose" )))
			Reflect.callMethod( o, "dispose", [] );
			
		if( Std.is( o,flash.display.Bitmap ))
		{
			var bmp = (cast o);
			bmp.bitmapData.dispose();
			bmp.bitmapData = null;
		}
			
		mt.gx.as.Lib.detach(o);
	}
	
	/**
	 * Calls dispose recursively and remove everything
	 */
	public static function free( mc : DisplayObject )
	{
		if (Std.is( mc, DisplayObjectContainer )) {
			var doc = cast mc;
			for ( i in 0...doc.numChildren ) {
				var o = doc.getChildAt( 0 );
				if(Std.is( o,DisplayObjectContainer ))	free( cast o );
				else 									freeOne( o );
			}
		}
		
		freeOne(mc);
	}
	
	public static function cacheAllAsBitmap(mc : flash.display.DisplayObjectContainer) : DisplayObjectContainer {
		if ( mc == null ) return null;
		
		for ( i in 0...mc.numChildren ) {
			var o = mc.getChildAt( i );
			if( Std.is( o, flash.display.DisplayObjectContainer))
				cacheAllAsBitmap( cast o );
			else 
				o.cacheAsBitmap = true;
		}
		
		mc.cacheAsBitmap = true;
		return mc;
	}
	
	//TODO trash me
	public static function removeChildren( mc: DisplayObjectContainer)
	{
		while ( mc.numChildren > 0)
			mc.removeChildAt(0);
	}
	
	/**
	 * Switch to gray scales
	 * @param	mc		Target DisplayObject
	 * @param	?c
	 * @param	?inc
	 * @param	?o
	 * @param	?m1
	 */
	static public function grey( mc:flash.display.DisplayObject, ?c:Float, ?inc:Int, ?o:{r:Int,g:Int,b:Int}, ?m1 ){
		if(c==null)	c = 1;
		if(inc==null)	inc = 0;
		if(o==null)	o = {r:0,g:0,b:0};

		var m0 = [
			1,	0,	0,	0,	0,
			0,	1,	0,	0,	0,
			0,	0,	1,	0,	0,
			0,	0,	0,	1,	0
		];

		if(m1==null){
			/*
			var r = 0.25;
			var g = 0.15;
			var b = 0.6;
			*/
			var r = 0.35;
			var g = 0.45;
			var b = 0.2;

			m1 = [
				r,	g,	b,	0,	o.r+inc,
				r,	g,	b,	0,	o.g+inc,
				r,	g,	b,	0,	o.b+inc,
				0,	0,	0,	1,	0,
			];
		}

		var m = [];
		for( i in 0...m0.length ){
			m[i] = m0[i]*(1-c) + m1[i]*c;
		}

		var fl = new flash.filters.ColorMatrixFilter(m);

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
	}
	
	/**
	 * Make blur
	 * @param	mc		Target DisplayObject
	 * @param	?blx	Blur X
	 * @param	?bly	Blur Y
	 */
	static public function blur(mc:flash.display.DisplayObject,?blx:Float,?bly:Float){
		if(blx==null)blx = 0;
		if(bly==null)bly = 0;

		var fl = new flash.filters.BlurFilter();
		fl.blurX = blx;
		fl.blurY = bly;

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
	}
	
	/**
	 * 
	 * @param	mc sprite to glow
	 * @param 	?col
	 * @param	?alpha 
	 * @param	?size size of the glow
	 * @param	?str strength of the glow
	 * @param	?inner is glow propagated inward
	 */
	static public function glow(mc:flash.display.DisplayObject,
		?col:Int = 0xfefefe, 
		?alpha = 1.0,
		?size:Float = 2.0, 
		?str:Float = 10.0, 
		?inner = false
	) {
		var fl = new flash.filters.GlowFilter(col,1.0,size,size,str,1,inner);

		var a = mc.filters;
		a.push(fl);
		mc.filters = a;
	}
	
	static public function unfilter<T>( mc:flash.display.DisplayObject ) {
		mc.filters = [];
	}
}