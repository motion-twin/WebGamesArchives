package fx;

import mt.gx.MathEx;
/**
 * ...
 * @author de
 */

class Greyscale
{
	var cmf : flash.filters.ColorMatrixFilter;
	
	static var grayMatrix :Array<Float> = [
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0.3, 0.59, 0.11, 0, 0,
	  0,    0,    0,    1, 0];
	  
	public function new() 
	{
		cmf = new flash.filters.ColorMatrixFilter(grayMatrix);
	}
	
	public function get()
	{
		return cmf;
	}
	
	inline function l1v( v, r)
		return MathEx.lerp( 1, v, r)
	
	public function setStrengthBloom(f:Float)
	{
		var f = function( v ) return l1v(v, f);
			
		var fr = f(0.3);
		var fg = f(0.59);
		var fb = f(0.11);
		
		cmf.matrix = 
		[
			fr, fg, fb, 0, 0,
			fr, fg, fb, 0, 0,
			fr, fg, fb, 0, 0,
			0,    0, 0, 1, 0
		];
	}
	
	public function setStrengthWithPow(r:Float)
	{
		var f = function( v ) return l1v(v, r);
			
		var fr = f(0.3);
		var fg = f(0.59);
		var fb = f(0.11);
		
		cmf.matrix = 
		[
			fr,			fg * r	, fb * r, 0, 0,
			fr * r, 	fg		, fb * r, 0, 0,
			fr * r, 	fg * r	, fb, 0, 0,
			0,    0, 0, 1, 0
		];
	}
	
	public function setStrength(r:Float)
	{
		var f = function( v ) return l1v(v, r);
			
		var fr = (0.3);
		var fg = (0.59);
		var fb = (0.11);
		
		cmf.matrix = 
		[
			fr ,	fg	, fb , 0, 0,
			fr , 	fg	, fb , 0, 0,
			fr , 	fg	, fb , 0, 0,
			0,    0, 0, r, 0
		];
	}
	
	public function setStrengthBlood(f:Float)
	{
		var f = function( v ) return l1v(v, f);
			
		var fr = f(0.9);
		var fg = f(0.05);
		var fb = f(0.05);
		
		cmf.matrix = 
		[
			fr, fg, fb, 0, 0,
			fr, fg, fb, 0, 0,
			fr, fg, fb, 0, 0,
			0,    0, 0, 1, 0
		];
	}
}