package mt.kiroukou.math;

import mt.MLib;
/**
 * <p>A 3D vector.</p>
 * <p>A geometric object that has both a magnitude (or length) and direction.</p>
 */
class Vec3
{
	/**
	 * Creates a new <code>Vec3</code> object from the values of <code>src</code>.
	 */
	inline public static function of(src:Vec3):Vec3
	{
		return new Vec3(src.x, src.y, src.z);
	}

	inline public static function add(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.x + b.x;
		output.y = a.y + b.y;
		output.z = a.z + b.z;
		return output;
	}
	
	inline public static function sub(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.x - b.x;
		output.y = a.y - b.y;
		output.z = a.z - b.z;
		return output;
	}

	inline public static function cross(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.y * b.z - a.z * b.y;
		output.y = a.z * b.x - a.x * b.z;
		output.z = a.x * b.y - a.y * b.x;
		return output;
	}
	
	inline public static function distance(a:Vec3, b:Vec3):Float
	{
		var dx = a.x - b.x;
		var dy = a.y - b.y;
		var dz = a.z - b.z;
		return Math.sqrt( dx * dx + dy * dy + dz * dz );
	}

	/**
	 * The x-component.
	 */
	public var x:Float;

	/**
	 * The y-component.
	 */
	public var y:Float;

	/**
	 * The z-component.
	 */
	public var z:Float;

	public function new(x = .0, y = .0, z = .0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	inline public function add3( x = .0, y = .0, z = .0 )
	{
		this.x += x; this.y += y; this.z += z;
	}
	
	inline public function zero():Vec3
	{
		x = y = z = 0;
		return this;
	}

	inline public function flip():Vec3
	{
		x = -x; y = -y; z = -z;
		return this;
	}

	inline public function scale(v:Float):Vec3
	{
		x *= v; y *= v; z *= v;
		return this;
	}

	public function normalize():Vec3
	{
		var k = length();
		if (k < MLib.EPS) k = 0 else k = 1. / k;
		x *= k;
		y *= k;
		z *= k;
		return this;
	}

	inline public function length():Float
	{
		return Math.sqrt(lengthSq());
	}

	inline public function lengthSq():Float
	{
		return x * x + y * y + z * z;
	}


	/** Assigns the values of <code>other</code> to this. */
	inline public function set(other:Vec3):Vec3
	{
		x = other.x;
		y = other.y;
		z = other.z;
		return this;
	}

	public function clone():Vec3
	{
		return new Vec3(x, y, z);
	}

	public function toString():String
	{
		return "x:"+x+", y:"+y+", z:"+z;
	}
}