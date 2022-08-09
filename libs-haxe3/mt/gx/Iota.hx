package mt.gx;

/**
 * ...
 * @author de
 */

@:keep
class Iota
{
	public static function range( max)  : IntIterator {
		return new IntIterator(0,max);
	}
	
	
	//include first, exclude seconds
	public static function int_range( min, max)  : List<Int>
	{
		var list = new List<Int>();
		for(i in min...max)
			list.add(i);
		return list;
	}
	
	public static function int_rangeA( min, max)  : Array<Int>
	{
		var list = new Array<Int>();
		for(i in min...max)
			list.push(i);
		return list;
	}
	
	public static function splat( e , nb)
	{
		var a = [];
		for(i in 0...nb)
			a.push( e );
		return a;
	}
	
	public static inline function rangeMinMax(min:Int,max:Int){
		var a = [];
		for ( i in min...max)
			a.push(i);
		return a;
	}
	
	
	//inclusive inclusive
	public static function iter( a:Int, b:Int) : Iterable<Int> {
		
		return 
		{
			iterator:function()
			{
				return 
				if ( a < b )
				{
					var c = a;
					{
					hasNext: function() return c <= b,
					next: function() return c++,
					}
				}
				else if ( a > b )
				{
					var c = a;
					{
					hasNext: function() return c >= b,
					next: function() return c--,
					}
				}
				else
				{
					var c = a;
					{
					hasNext: function() return false,
					next: function() return c,
					}
				}
			}
		}
	}
}