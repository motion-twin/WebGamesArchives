package ;

/**
 * ...
 * @author de
 */

class Iota 
{
	//include first, exclude seconds
	public static function int_range( min, max)  : List<Int>
	{
		var list = new List<Int>();
		for(i in min...max)
			list.add(i);
		return list;
	}
	
	public static function splat( e , nb)
	{
		var a = [];
		for(i in 0...nb)
			a.push( e );
		return a;
	}
}