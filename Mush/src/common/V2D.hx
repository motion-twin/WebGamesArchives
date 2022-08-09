
class V2D
{
	public var x		: Float;
	public var y		: Float;
	
	public function new (x=0.0, y=0.0)
	{
		this.x = x;
		this.y = y;
	}
	
	public function set( x , y ) : Void
	{
		this.x = x;
		this.y = y;
	}
	
	public inline function copy( xy : V2D ) : Void
	{
		x = xy.x;
		y = xy.y;
	}
	
	public inline function clone(  ) : V2D
	{
		return new V2D( x, y );
	}
	
	public inline function norm2() : Float
	{
		return x * x + y * y;
	}
	
	public inline function norm() : Float
	{
		return Math.sqrt( norm2() );
	}
	
	public static inline function scale2(vOut : V2D, xy: V2D) : V2D
	{
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
	public static inline function cross(v0: V2D, v1:V2D) : Float
	{
		return v0.x * v1.y - v0.y * v1.y;
	}
	
	public static inline function scale(vOut : V2D,f:Float,vIn:V2D) : V2D
	{
		vOut.x = vIn.x * f;
		vOut.y = vIn.y * f;
		return vOut;
	}
	
	public static inline function add( VOut : V2D, V0 : V2D, V1 :  V2D ) :  V2D
	{
		VOut.x = V0.x + V1.x;
		VOut.y = V0.y + V1.y;
		return VOut;
	}
	
	public static inline function incr( inOut : V2D, V1 :  V2D ) :  V2D
	{
		inOut.x += V1.x;
		inOut.y += V1.y;
		return inOut;
	}
	
	public static inline function decr( inOut : V2D, V2D, V1 :  V2D ) :  V2D
	{
		inOut.x -= V1.x;
		inOut.y -= V1.y;
		return inOut;
	}
	
	public static inline function sub( vOut : V2D, V0 : V2D, V1 :  V2D ) : V2D
	{
		vOut.x = V0.x - V1.x;
		vOut.y = V0.y - V1.y;
		return vOut;
	}
	
	
	public static inline function normalize( inOut : V2D ) : V2D
	{
		var invLen = 1.0 / inOut.norm();
		
		inOut.x *= invLen;
		inOut.y *= invLen;
		
		return inOut;
	}
	
	public static inline function safeNormalize( inOut : V2D , dflt : V2D ) : V2D
	{
		var norm :Float = inOut.norm();
		if( norm > MathEx.EPSILON )
		{
			var invLen = 1.0 / norm;
			
			inOut.x *= invLen;
			inOut.y *= invLen;
		}
		else
		{
			inOut.copy( dflt);
		}
		
		return inOut;
	}

	public function toString()
	{
		return 'V2D($x,$y)';
	}
	
	public static inline function dist2( v0 : V2D, v1 :  V2D ) : Float
	{
		return ( (v1.x - v0.x) * (v1.x - v0.x) ) + ( (v1.y - v0.y) * (v1.y - v0.y) );
	}
	
	public inline function isNear( v0 : V2D, r : Float = 10e-3 )
	{
		return dist( this, v0 ) <= r;
	}
	
	public static inline function dist( v0 : V2D, v1 :  V2D ) : Float
	{
		return Math.sqrt( dist2( v0 , v1 ) );
	}
	
	public static inline function unit( angle :Float )
	{
		return new V2D( Math.cos( angle ), Math.sin( angle ) );
	}
	
	public static var ZERO 		: V2D 		= new V2D(0, 0);
	public static var ONE 		: V2D 		= new V2D(1, 1);
	public static var HALF 		: V2D 		= new V2D(0.5, 0.5);
}
