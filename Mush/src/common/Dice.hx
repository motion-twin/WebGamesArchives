package ;

#if neko
	import db.Ship;
	import db.ShipLog;
	import Protocol;
#end

/**
 * ...
 * @author de
 */

class Dice
{
	public static inline var LOG_ROLL = false;
	
	public static inline function roll( min :Int,max:Int ) : Int
	{
		var i = Std.random( max - min +1 ) + min;
		return i;
	}
	
	public static inline function roll2(min,max)
	{
		var d = roll(min, max) + roll(min, max);
		d >>= 1;
		return d;
	}
	
	public static inline function percent2( thresh : Float) : Bool
	{
		var r = roll2( 1, 100);
		return(r <= thresh);
	}
	
	public static inline function percent( thresh : Float) : Bool
	{
		var r = roll( 1, 100);
		return(r <= thresh);
	}
	
	public static inline function oneChance( qty : Int ) : Bool
	{
		return roll( 1, qty) == qty;
	}
	
	public static inline function D100( )
	{
		return roll(  1, 100);
	}
	
	public static inline function toss()
	{
		return Std.random( 2 ) == 0;
	}
	
	public static inline function rollF( min : Float,max:Float ) : Float
	{
		return  Math.random() * (max - min) + min;
	}
}