package ;

/**
 * ...
 * @author de
 */

class V3D
{
	public var x		: Float;
	public var y		: Float;
	public var z		: Float;
	
	public inline function new ( x:Float=0, y:Float=0,z:Float=0 )
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public inline function set( x:Float=0, y:Float=0,z:Float=0 )
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	public function clone() : V3D
	{
		return new V3D( x, y, z);
	}

	public inline function add(  V0 : V3D, V1 :  V3D ) :  V3D
	{
		x = V0.x + V1.x;
		y = V0.y + V1.y;
		z = V0.z + V1.z;
		return this;
	}
	
	public inline function incr(  V1 :  V3D ) :  V3D
	{
		x += V1.x;
		y += V1.y;
		z += V1.z;
		return this;
	}
	
	public inline function decr( V1 :V3D ) :  V3D
	{
		x -= V1.x;
		y -= V1.y;
		z -= V1.z;
		return this;
	}
	
	//computes _V0 - _V1
	public inline function sub(  V0 : V3D, V1 :  V3D ) : V3D
	{
		x = V0.x - V1.x;
		y = V0.y - V1.y;
		z = V0.z - V1.z;
		return this;
	}
	
	public inline function scale1(  f : Float ) : V3D
	{
		x *= f;
		y *= f;
		z *= f;
		return this;
	}
	
	public inline function eq( v : V3D )
	{
		return MathEx.eq(x, v.x) && MathEx.eq( y, v.y) && MathEx.eq( z, v.z);
	}
	
	public inline function isZero()
	{
		return MathEx.eq(x, 0) && MathEx.eq( y, 0) && MathEx.eq( z, 0);
	}
	
	public inline function scale3( x : Float,y: Float,z:Float ) : V3D
	{
		x *= x;
		y *= y;
		z *= z;
		return this;
	}
	
	public static var ZERO = new V3D();
	
}