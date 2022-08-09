package mt.kiroukou.math;

import mt.kiroukou.math.MLib;

class Range<T:(Int,Float)>
{
	public var min : T;
	public var max : T;
	
	public function new(min:T, max:T)
	{
		this.min = min;
		this.max = max;
	}
	
	inline public function intersects( range : Range<T> ) : Bool
	{
		return	(range.min <= min && range.max >= max) ||
				MLib.inRange( range.min, min, max ) ||
				MLib.inRange( range.max, min, max );
	}
	
	inline public function isIn( v : T ) : Bool 
	{
		return MLib.inRange( v, min, max );
	}
	
	inline public function isLeft( v : T ) : Bool
	{
		return v < min;
	}
	
	inline public function isRight( v : T ) : Bool
	{
		return v > max;
	}
	
	inline public function random( rnd : T->T ) : T
	{
		var interval = max - min;
		var v = rnd(interval);
		return min + v;
	}
}
