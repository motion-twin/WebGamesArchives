package mt.gx.math;

class Vec4
{
	public var x		: Float;
	public var y		: Float;
	public var z		: Float;
	public var w		: Float;
	
	public function new (x=0.0, y=0.0,z=0.0,w=0.0){
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	public function set( x=0.0, y=0.0 ,z=0.0, w=0.0 ) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
		return this;
	}
	
	public inline function copy( v : Vec4 ){
		x = v.x;
		y = v.y;
		z = v.z;
		w = v.w;
		return this;
	}
	
	public inline function dot( vin:Vec4 ) : Float {
		return  x * vin.x+ y * vin.y+ z * vin.z+ w * vin.w;
	}
	
	public inline function cross( vin:Vec4, ?vout:Vec4 )
	{
		mt.gx.Debug.assert(vout != this, "cant allow aliasing");
		
		if (vout == null) vout = new Vec4();
		
		var pxy = x * vin.y - vin.x * y;
		var pxz = x * vin.z - vin.x * z;
		var pxw = x * vin.w - vin.w * x;
		
		var pyz = y * vin.z - vin.y * z;
		var pyw = y * vin.w - vin.y * w;
		var pzw = z * vin.w - vin.z * w;
		
		return vout.set(
			y*pzw - z*pyw + w*pyz,   
			z*pxw - x*pzw - w*pxz,   
			x*pyw - y*pxw + w*pxy,
			y*pxz - x*pyz - z*pxy
		);
	}
	
	/**
	 * @return member wise product
	 */
	public inline function product( vin, ?vout ) : Vec4
	{
		mt.gx.Debug.assert(vout != this, "cant allow aliasing");
		if (vout == null) vout = new Vec4();
		vout.x = x * vin.x;
		vout.y = y * vin.y;
		vout.z = z * vin.z;
		vout.w = w * vin.w;
		return vout;
	}
	
	
	public inline function clone() : Vec4
	{
		return new Vec4( x, y ,z ,w);
	}
	
	public inline function len2()	{ return norm2();}
	public inline function len()	{ return norm(); }
	
	public inline function norm2() : Float
	{
		return x * x + y * y +z *z +w * w;
	}
	
	public inline function norm() : Float
	{
		return Math.sqrt( norm2() );
	}
	
	public function toString()
	{
		return Std.format("Vec4($x,$y,$z,$w)");
	}
	
	public static var ZERO 		: Vec4 = new Vec4();
	public static var ONE 		: Vec4 = new Vec4(1.0, 1.0,1.0,1.0);
	public static var HALF 		: Vec4 = new Vec4(0.5, 0.5,0.5,0.5);
}
