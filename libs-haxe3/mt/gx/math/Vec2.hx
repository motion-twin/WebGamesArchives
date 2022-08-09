package mt.gx.math;

class Vec2
{
	public var x		: Float;
	public var y		: Float;
	
	public inline function new (x=0.0, y=0.0)
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function set( x=0.0, y=0.0) : Void
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function copy( xy : Vec2 ) : Void
	{
		x = xy.x;
		y = xy.y;
	}
	
	public inline function clone(  ) : Vec2
	{
		return new Vec2( x, y );
	}
	
	public inline function norm2() : Float
	{
		return x * x + y * y;
	}
	
	public inline function length() : Float 	return norm();
	public inline function length2() : Float 	return norm2();
	public inline function norm() : Float		return Math.sqrt( norm2() );
	
	public static inline function scale2(vOut : Vec2, xy: Vec2) : Vec2{
		vOut.x *= xy.x;
		vOut.y *= xy.y;
		return vOut;
	}
	
	/**
	 *
	 * @param	v0
	 * @param	v1
	 * @return signed aread of v1 v0, signed as in signed angle
	 */
	public static inline function cross(v0: Vec2, v1:Vec2) : Float
		return v0.x * v1.y - v0.y * v1.y;
	
	public static inline function scale(vOut : Vec2,f:Float,?vIn:Vec2) : Vec2{
		if( vIn == null) vIn = vOut;
		vOut.x = vIn.x * f;
		vOut.y = vIn.y * f;
		return vOut;
	}
	
	public inline function add( v :  Vec2, ?vOut : Vec2 ) :  Vec2{
		if ( vOut == null ) vOut = this;
		vOut.x = x + v.x;
		vOut.y = y + v.y;
		return vOut;
	}
	
	public inline function incr( v :  Vec2, ?vOut : Vec2 ) :  Vec2{
		if ( vOut == null ) vOut = this;
		vOut.x = x + v.x;
		vOut.y = y + v.y;
		return vOut;
	}
	
	public inline function decr( v :  Vec2, ?vOut : Vec2 ) :  Vec2{
		if ( vOut == null ) vOut = this;
		vOut.x = x - v.x;
		vOut.y = y - v.y;
		return vOut;
	}
	
	public inline function sub( v :  Vec2, ?vOut : Vec2 ) : Vec2
		return sub2( v.x, v.y , vOut );
	
	public inline function sub2( vx : Float, vy : Float, ?vOut : Vec2 ) : Vec2{
		if ( vOut == null ) vOut = this;
		vOut.x = x - vx;
		vOut.y = y - vy;
		return vOut;
	}
	
	public inline function normalize() : Vec2{
		var invLen = 1.0 / norm();
		
		x *= invLen;
		y *= invLen;
		
		return this;
	}
	
	public function rot0( a : Float, out : Vec2 ) : Vec2{
		mt.gx.Debug.assert( out != this );
		var ca = Math.cos(a);
		var sa = Math.sin(a);
		out.x = ca * x - sa * y ;
		out.y = sa * x + ca * y ;
		return out;
	}
	
	public inline function safeNormalize( dflt : Vec2 = null ) : Vec2{
		if ( dflt == null ) dflt = Vec2.ZERO;
		var norm :Float = norm();
		if( norm > 0.00001 ){
			var invLen = 1.0 / norm;
			
			x *= invLen;
			y *= invLen;
		}
		else
			copy( dflt );
		
		return this;
	}

	public function toString() 			return 'Vec2($x,$y)';
	
	
	public static inline function dist2( v0 : Vec2, v1 :  Vec2 ) : Float
		return ( (v1.x - v0.x) * (v1.x - v0.x) ) + ( (v1.y - v0.y) * (v1.y - v0.y) );
	
	
	public inline function isNear( v0 : Vec2, r : Float = 10e-3 )
		return dist( this, v0 ) <= r;
	
	public static inline function dist( v0 : Vec2, v1 :  Vec2 ) : Float
		return Math.sqrt( dist2( v0 , v1 ) );
	
	public static inline function unit( angle :Float )
		return new Vec2( Math.cos( angle ), Math.sin( angle ) );
	
	public static inline function travel( x : Float, y : Float, speed : Vec2, proc : Float -> Float -> Void) {
		//inline bug
		var ax = x;
		var ay = y;
		var l = speed.length();
		var il = 1.0 / l;
		var ox = ax; var oy = ay;
		for ( i in 0...Std.int(l)) {
			ax += speed.x * il;
			ay += speed.y * il;
			proc(ax,ay);
		}
		ax = ox + speed.x;
		ay = oy + speed.y;
		proc(ax,ay);
	}
	
	public static var ZERO 		: Vec2 = new Vec2(0, 0);
	public static var ONE 		: Vec2 = new Vec2(1, 1);
	public static var HALF 		: Vec2 = new Vec2(0.5, 0.5);
}
