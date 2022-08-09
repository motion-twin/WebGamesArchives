package mt.gx;
/* 
 * Copyright Motion Twin 2014
 * 	AS3
	Copyright 2007 Sphex LLP.
	
	This work is licensed under the Creative Commons Attribution 2.0 UK: England & Wales License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by/2.0/uk/ or send a 
	letter to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.

*/
	
import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.geom.Rectangle;
import haxe.ds.Vector;
import mt.fx.Flash;
	
/**
 * Beware the scale does not perform that well for heavy alpha textures since the alpha channel is partly lost in flash ( premultiplication )
 */
class Scaler  {
	var bmd : flash.display.BitmapData;
	var width(get, null):Int; inline function get_width() return bmd.width;
	var height(get, null):Int; inline function get_height() return bmd.height;
	
	var Rmdx = new haxe.ds.Vector(4);
	var Rdyn = new haxe.ds.Vector(4);
	
	public function new( bmd : flash.display.BitmapData ) {
		this.bmd = bmd;
	}
	 
   /**
	  Computes the value of a pixel that is not on a pixel boundary.
	  @param x The sub-pixel precision x-coordinate.
	  @param y The sub-pixel precision y-coordinate.
   */
	@:noDebug
	public function getPixelBicubic(x:Float, y:Float) : Int {
		if ( x < 0 )
			x = 0;
		if ( y < 0 )
			y = 0;
		if ( x >= width )
			x = width-1;
		if ( y >= height )
			y = height - 1;
			
		var i : Int = Std.int(x);
		var j : Int = Std.int(y);

		var dx:Float = x - i;
		var dy:Float = y - j;
		var rsum:Float = 0.0;
		var gsum:Float = 0.0;
		var bsum:Float = 0.0;
		var asum:Float = 0.0;

		for(m in -1...3)
			Rmdx[m + 1] = A(m - dx);
		for(n in -1...3)
			Rdyn[n + 1] = A(dy - n);

		var rgb : UInt;
		var rv:Int;	
		var gv:Int;		
		var bv:Int;		
		var av:Int;
		var Rres;
		
		for(m in -1...3)
		for(n in -1...3)
		{
			rgb = getPixel(i + m, j + n);
			rv 	= r(rgb);
			gv	= g(rgb);
			bv	= b(rgb);
			av	= al(rgb);
				
			Rres = Rmdx[m + 1] * Rdyn[n + 1];
			
			rsum += rv * Rres;
			gsum += gv * Rres;
			bsum += bv * Rres;
			asum += av * Rres;
		}

		//todo convert to satadd ? 
		var red = Std.int(rsum + 0.5);
		if(red < 0)
			red = 0;
		else if(red > 255)
			red = 255;
			
		var green = Std.int(gsum + 0.5);
		if(green < 0)
			green = 0;
		else if(green > 255)
			green = 255;
			
		var blue = Std.int(bsum + 0.5);
		if(blue < 0)
			blue = 0;
		else if(blue > 255)
			blue = 255;
		 
		var alpha = Std.int(asum + 0.5);
		if (alpha < 0)
			alpha = 0;
		else if(alpha > 255)
			alpha = 255;
			
		return (red << 16) | (green << 8) | (blue << 0) | (alpha <<24);
   }
	   
	
   /**
	  Computes the value of a pixel that is not on a pixel boundary.

	  @param theX The sub-pixel precision x-coordinate.
	  @param theY The sub-pixel precision y-coordinate.
   */
	  @:noDebug
	public function getPixelBilinear(theX:Float, theY:Float): Int {
		
		var x:Int;
		var y:Int;
		var x_ratio:Float;
		var y_ratio:Float;
		var y_opposite:Float;
		var x_opposite:Float;
		var a:Int;
		var be:Int;
		var c:Int;
		var d:Int;
		
		var red;
		var green;
		var blue;
		var alpha;
		
		x = Math.floor(theX);
		y = Math.floor(theY);
		
		if((x < 1) || (y < 1) || ((x + 2) >= width) || ((y + 2) >= height))
			return getPixel(x, y);
		
		x_ratio = theX - x;
		y_ratio = theY - y;
		x_opposite = 1 - x_ratio;
		y_opposite = 1 - y_ratio;
					
		a = getPixel(x, y);
		be =getPixel(x + 1, y);
		c = getPixel(x, y + 1);
		d = getPixel(x + 1, y + 1);
		
		red 	= (r(a)  	* x_opposite  + r(be)   * x_ratio) * y_opposite 	+ (r(c) * x_opposite  + r(d) * x_ratio) * y_ratio;
		green 	= (g(a)  	* x_opposite  + g(be)   * x_ratio) * y_opposite 	+ (g(c) * x_opposite  + g(d) * x_ratio) * y_ratio;
		blue 	= (b(a)  	* x_opposite  + b(be)   * x_ratio) * y_opposite 	+ (b(c) * x_opposite  + b(d) * x_ratio) * y_ratio;
		alpha 	= (al(a) 	* x_opposite  + al(be)  * x_ratio) * y_opposite		+ (al(c) * x_opposite + al(d) * x_ratio) * y_ratio;
			
		if(red < 0)
			red = 0;
		else if(red > 255)
			red = 255;
		if(green < 0)
			green = 0;
		else if(green > 255)
			green = 255;
		if(blue < 0)
			blue = 0;
		else if(blue > 255)
			blue = 255;
			
		if(alpha < 0)
			alpha = 0;
		else if(alpha > 255)
			alpha = 255;
			
		return (Math.round(red) << 16) | (Math.round(green) << 8) | (Math.round(blue) << 0) | (Math.round( alpha )<< 24 );
	}

	public inline function getPixelNearest(x:Float,y:Float) {
		return getPixel(Math.round(x), Math.round(y));
	}
	
   /**
	  Support function for bicubic interpolation.
   */
   static inline function A(x:Float):Float
   {
	  var p0 = ((x + 2) > 0) ? (x + 2) : 0;
	  var p1 = ((x + 1) > 0) ? (x + 1) : 0;
	  var p2 = (x > 0) ? x : 0;
	  var p3 = ((x - 1) > 0) ? (x - 1) : 0;

	  return (1 / 6) * (p0 * p0 * p0 - 4 * (p1 * p1 * p1) + 6 * (p2 * p2 * p2) -
		 4 * (p3 * p3 * p3));
   }

   /**
	  Support function for bicubic interpolation.
   */
   static inline function P(x:Float):Float
   {
	  return (x > 0) ? x : 0;
   }

	/**
	*	RGB convenience methods	
	*/

   static inline function r(rgb:Int):Int {
		return (rgb >> 16) & 0xFF;
	}

	static inline function g(rgb:Int):Int {
		return (rgb >> 8) & 0xFF;
	}

	static inline function b(rgb:Int):Int {
		return rgb & 0xFF;
	}

	static inline function al(rgb:Int):Int {
		return (rgb >> 24) & 0xFF;
	}
	
	////
	static inline function r2(rgb:Int):Int {
		return  Math.round( ((rgb >> 16) & 0xFF) / (al(rgb)/255.0));
	}

	static inline function g2(rgb:Int):Int {
		return Math.round( ((rgb >> 8) & 0xFF) / (al(rgb)/255.0));
	}

	static inline function b2(rgb:Int):Int {
		return Math.round( (rgb & 0xFF) / (al(rgb)/255.0));
	}

	inline function getPixel(x:Int,y:Int) {
		return bmd.getPixel32(x, y);
	}
	
	public static function premultiply(source : flash.display.BitmapData) {
		var one255 = 1.0 / 255.0;
		
		for ( y in 0...source.height)
			for ( x in 0...source.width) {
				var p = source.getPixel32( x, y);
				
				var a = p >>> 24;
				var av = a * one255;
				
				var rv = r(p) * one255 * av * 255.0;
				var gv = g(p) * one255 * av * 255.0;
				var bv = b(p) * one255 * av * 255.0;
				
				var r = Math.round( rv ) & 255;
				var g = Math.round( gv ) & 255;
				var b = Math.round( bv ) & 255;
				source.setPixel32( x,y, (a << 24 | r << 16 | g << 8 | b) );
			}
	}
	
	public static function alphaToColor(source : flash.display.BitmapData) {
		for ( y in 0...source.height)
			for ( x in 0...source.width) {
				var p = source.getPixel32( x, y);
				var a = al( p );
				source.setPixel32( x,y, ( (0xFF<<24) | (a << 16) | (a << 8) | a) );
			}
		return source;
	}
	
	public static function removeAlpha(source : flash.display.BitmapData) {
		for ( y in 0...source.height)
			for ( x in 0...source.width) {
				var p = source.getPixel( x, y);
				source.setPixel32( x,y, (0xFF<<24 | p) );
			}
		return source;
	}
	
	public static function resize( source : flash.display.BitmapData , targetWidth, targetHeight) {
		var t = new flash.display.BitmapData(targetWidth, targetHeight, true, 0x0);
		var i = new mt.gx.Scaler( source );
		var widthFactor = source.width / targetWidth;
		var heightFactor = source.height / targetHeight;
		for ( y in 0...targetHeight)
			for ( x in 0...targetWidth) 
				t.setPixel32( x, y, i.getPixelBicubic( x * widthFactor, y * heightFactor) );
		return t;
	}
	
	public static function resizeAt( 
		dest : flash.display.BitmapData, 	targetX:Int,targetY:Int, targetWidth:Int, targetHeight:Int,
		source : flash.display.BitmapData, 	sourceX:Int,sourceY:Int, sourceWidth:Int, sourceHeight:Int) {
			
		var t = dest;
		var i = new mt.gx.Scaler( source );
		var widthFactor = sourceWidth / targetWidth;
		var heightFactor = sourceHeight / targetHeight;
		for ( y in 0...targetHeight)
			for ( x in 0...targetWidth) 
				t.setPixel32( x + targetX, y + targetY, i.getPixelBicubic( sourceX + x * widthFactor, sourceY + y * heightFactor) );
		return t;
	}
}

