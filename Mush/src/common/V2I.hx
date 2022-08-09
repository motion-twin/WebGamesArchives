

class V2I
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
	
	public inline function copy( xy : V2I ) : Void
	{
		x = xy.x;
		y = xy.y;
	}
	
	public inline function clone() : V2I
	{
		return new V2I(x, y);
	}
	
	public inline function isEq( v: V2I) : Bool
	{
		return v.x == x && v.y == y;
	}
	
	public inline function isEq2(vx,vy) : Bool
	{
		return vx == x && vy == y;
	}
	
	public inline function toV2D() 
	{
		return new V2D(x, y);
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
	
	
	public static inline function add( VOut : V2I, V0 : V2I, V1 :  V2I ) :  V2I
	{
		VOut.x = V0.x + V1.x;
		VOut.y = V0.y + V1.y;
		return VOut;
	}
	
	public static inline function incr( inOut : V2I , V1 :  V2I ) :  V2I
	{
		inOut.x += V1.x;
		inOut.y += V1.y;
		return inOut;
	}
	
	public static inline function decr( inOut : V2I, V1 :V2I ) :  V2I
	{
		inOut.x -= V1.x;
		inOut.y -= V1.y;
		return inOut;
	}
	
	//computes _V0 - _V1
	public static inline function sub( vOut : V2I, V0 : V2I, V1 :  V2I ) : V2I
	{
		vOut.x = V0.x - V1.x;
		vOut.y = V0.y - V1.y;
		return vOut;
	}
	
	public static inline function dist(v0: V2I,v1: V2I) : Float
	{
		return Math.sqrt( dist2(v0, v1) );
	}
	
	public static inline function dist2(v0: V2I,v1: V2I) : Int
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
		return 'V2I($x,$y)';
	}
	
	/**
	 * 
	 * @return [ TopLeft,BottomRight]
	 */
	public static inline function calcBBox( arr : Array<V2I> ) 
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
		
		return [new V2I( l,t),new V2I(r,b)];
	}
	
	public static var ZERO 		: V2I = new V2I(0, 0);
	public static var ONE 		: V2I = new V2I(1, 1);
}

