package mt.gx;


class Dice
{
	public static inline function roll(
	#if flash
	?mr:mt.Rand,
	#end
	min :Int,max:Int  ) : Int
	{
		var v = Std.random( max - min +1 ) + min;
		
		#if flash
		if ( mr != null) v = mr.random( max - min +1 ) + min;
		#end
		
		return v;
	}
	
	
	public static inline function percent(
	#if flash
	?rd:mt.Rand,
	#end
	thresh : Float) : Bool
	{
		if ( thresh <= 0.5-MathEx.EPSILON)
		{
			return false;
		}
		else
		{
			var r = roll( #if flash rd,#end 1, 100);
			
			return(r <= thresh);
		}
	}
	
	public static inline function oneChance( qty : Int ) : Bool
	{
		return roll( 1, qty) == qty;
	}
	
	public static inline function D100( )
	{
		return roll(  1, 100);
	}
	
	public static inline function toss(
	#if flash ?mr:mt.Rand #end
	)
	{
		return Dice.roll( #if flash mr,#end 0, 1) == 0;
	}
	
	public static inline function rollF( 
	#if flash
	?rd:mt.Rand,
	#end
	min : Float = 0.0,max:Float = 1.0) : Float
	{
		var f = Math.random() * (max - min) + min;
		
		#if flash
		if ( rd != null)
			f = rd.rand()* (max - min) + min;
		#end
		
		return  f;
	}
}