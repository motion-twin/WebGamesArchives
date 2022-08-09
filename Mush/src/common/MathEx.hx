
import Math;
class MathEx
{
	public static inline function clamp( a : Float, min : Float, max : Float ) : Float
	{
		return ( a < min ) ? min
		:		 ( a > max ) ? max :a;
	}
	
	public static inline function maxi( x : Int, y : Int ) : Int
	{
		return (x < y)? y : x;
	}
	
	//takes an index and a page count and returns the number of the page
	public static inline function page( i : Int, n : Int ) : Int
	{
		return Std.int(i / n);
	}
	
	//takes an index and a page count and returns the number of pages in the collection
	public static function nbPage( count : Int, pgSz : Int ) : Int
	{
		if ( count <= 0)
		{
			return 0;
		}
		else
		if ( count % pgSz == 0)
		{
			return Std.int(count / pgSz);
		}
		else
		return  1 +Std.int(count / pgSz);
	}
	
	
	public static inline function mini( x: Int, y : Int ) : Int
	{
		return (x < y)? x : y;
	}
	
	public static inline function nearesti( x:Float ) : Int
	{
		return Std.int(
							( x < 0)
						? 	(x - 0.5)
						: 	(x + 0.5) );
	}
	
	public static inline function absi( x: Int ) : Int
	{
		#if neko
		var sign = x >> 30;
		#else
		var sign = x >> 31;
		#end
		
		return (x ^ sign) - sign;
	}
	
	public static inline function clampi( a : Int, min : Int, max : Int ) : Int
	{
		return ( a < min ) ? min
		:		 ( a > max ) ? max :a;
	}
	
	public static inline function sqrI( a : Int ) : Int
	{
		return a * a;
	}
	
	public static inline function div( a : Int,b:Int ) : Int
	{
		return Std.int( a / b );
	}

	public static function countBits(x)
	{
		var res = 0;
		while( x != 0)
		{
			x >>= 1;
			if ( (x & 1) != 0)
			{
				res++;
			}
		}
		return res;
	}
	
	public static inline function eq(v0:Float,v1:Float)
	{
		return Math.abs( v0 - v1) < MathEx.EPSILON;
	}
	
	public static inline function lerpi(v0 : Int,v1: Int,t: Float) : Int
	{
		return Std.int((v1 - v0) * t + v0);
	}
	
	public static inline function lerp(v0 : Float,v1: Float,t: Float) : Float
	{
		return (v1 - v0) * t + v0;
	}
	
	public static inline function lerpEaseIn(v0 : Float,v1: Float,t: Float) : Float
	{
		var tt = t * t ;
		return (v1 - v0) * tt + v0;
	}
	
	public static inline function powi( v  : Int, p : Int ) : Int
	{
		return Std.int( Math.pow( v, p) );
	}
	
	public static inline function pow2i( v  : Int ) : Int
		return v * v;
		
	public static inline function pow2f( v  : Float ) : Float
		return v * v;
	
	public static inline function lerpEaseOut(v0 : Float,v1: Float,t: Float) : Float
	{
		var tt = t<=EPSILON ? 0 : Math.sqrt( t );
		return (v1 - v0) * tt + v0;
	}
	
	public static inline function normAngle( f:  Float)
	{
		while (f >= Math.PI * 2)
			f -= Math.PI * 2;
		while (f <= -Math.PI * 2)
			f += Math.PI * 2;
		return f;
	}
	
	public static inline function posMod( i :Int,m:Int )
	{
		var mod = i % m;
		return (mod >= 0)
		? mod
		: mod + m;
	}
	
	public static inline function trunk(v:Float, digit:Int) : Float
	{
		var hl = 10.0 * digit;
		return Std.int( v * hl ) / hl;
	}
	
	public static inline function squareSignal( t :Float , period :Float) : Bool
	{
		return (Std.int( t / period ) % 2 ) == 0;
	}
	
	public static inline function headingSign( v : Int ) : String
	{
		return
		( v > 0) ? ("+ " + v) : ("- "+MathEx.absi( v ));
	}
	
	public static inline function sameSign( f0:Float,f1:Float):Bool
	{
		return	((f0 < 0) && (f1 < 0)) || ((f0 > 0) && (f1 > 0));
	}
	
	public static inline var EPSILON : Float = 1e-06;
	public static inline var INT_MAX 	: Int = #if neko 1073741823 #else 2147483647  #end;
	public static inline var INT_MIN	: Int = #if neko -1073741824 #else -2147483648 #end;
	public static inline var INT_BIG_ENOUGH : Int = 118361256;
}