package mt.gx.math;

class Vec2i
{
	public var x		: Int;
	public var y		: Int;
	
	public function new ( x=0, y=0 )
	{
		this.x = x;
		this.y = y;
	}
	
	public function set( x , y ) : Void
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function copy( xy : Vec2i ) : Void
	{
		x = xy.x;
		y = xy.y;
	}
	
	public inline function clone() : Vec2i
	{
		return new Vec2i(x, y);
	}
	
	public inline function isEq( v: Vec2i) : Bool
	{
		return v.x == x && v.y == y;
	}
	
	public inline function isEq2(vx,vy) : Bool
	{
		return vx == x && vy == y;
	}
	
	
	public inline function norm() : Float
	{
		return Math.sqrt(norm2());
	}
	
	public inline function norm2() : Int
	{
		return x * x + y * y;
	}
	
	public inline function manh() : Float
	{
		return x + y;
	}
	
	
	public static inline function add( VOut : Vec2i, V0 : Vec2i, V1 :  Vec2i ) :  Vec2i
	{
		VOut.x = V0.x + V1.x;
		VOut.y = V0.y + V1.y;
		return VOut;
	}
	
	public static inline function incr( inOut : Vec2i , V1 :  Vec2i ) :  Vec2i
	{
		inOut.x += V1.x;
		inOut.y += V1.y;
		return inOut;
	}
	
	public static inline function decr( inOut : Vec2i, V1 :Vec2i ) :  Vec2i
	{
		inOut.x -= V1.x;
		inOut.y -= V1.y;
		return inOut;
	}
	
	
	
	//computes _V0 - _V1
	public static inline function sub( vOut : Vec2i, V0 : Vec2i, V1 :  Vec2i ) : Vec2i
	{
		vOut.x = V0.x - V1.x;
		vOut.y = V0.y - V1.y;
		return vOut;
	}
	
	public static inline function dist(v0: Vec2i,v1: Vec2i) : Float
	{
		return Math.sqrt( dist2(v0, v1) );
	}
	
	public static inline function dist2(v0: Vec2i,v1: Vec2i) : Int
	{
		var dx = v1.x - v0.x;
		var dy = v1.y - v0.y;
		return 	dx * dx + dy * dy;
	}
	
	public static inline function distm(v0,v1) : Int
	{
		return MathEx.absi((v1.x - v0.x) + (v1.y - v0.y));
	}
	
	public function toString()
	{
		return Std.format("Vec2i($x,$y)");
	}
	
	/**
	 *
	 * @return [ TopLeft,BottomRight]
	 */
	public static function calcBBox( arr : Iterable<Vec2i> )
	{
		var t = MathEx.INT_MAX;
		var l = MathEx.INT_MAX;
		var b = MathEx.INT_MIN;
		var r = MathEx.INT_MIN;
		
		for(v in arr)
		{
			t = MathEx.mini( t , v.y);
			l = MathEx.mini( l , v.x);
			b = MathEx.maxi( b , v.y);
			r = MathEx.maxi( r , v.x);
		}
		
		return [new Vec2i( l,t),new Vec2i(r,b)];
	}
	
	public static var ZERO 		: Vec2i = new Vec2i(0, 0);
	public static var ONE 		: Vec2i = new Vec2i(1, 1);
}

