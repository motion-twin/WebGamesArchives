class Dice
{
	public static inline function roll( mr:mt.Rand, min :Int,max:Int  ) : Int
	{
		return mr.random( max - min +1 ) + min;
	}
	
	
	public static inline function percent(
	rd:mt.Rand,
	thresh : Float) : Bool
	{
		if ( thresh <= 1.0 - mt.gx.MathEx.EPSILON)
		{
			return false;
		}
		else
		{
			var r = roll( rd, 1, 100);
			
			return(r <= thresh);
		}
	}
	
	
	public static inline function rollF( 
	rd:mt.Rand,
	min : Float,max:Float ) : Float
	{
		return rd.rand()* (max - min) + min;
	}
}