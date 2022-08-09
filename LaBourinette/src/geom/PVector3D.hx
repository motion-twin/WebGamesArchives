package geom;

class PVector3D {
	public static var ORIGIN = new PVector3D();

	public var x : Float;
	public var y : Float;
	public var z : Float;

	public function new( x_:Float=0.0, y_:Float=0.0, z_:Float=0.0 ){
		x = x_;
		y = y_;
		z = z_;
	}

	public function zero(){
		x = 0.0;
		y = 0.0;
		z = 0.0;
	}

	public inline function equals( v:Pt3D ) : Bool {
		return x == v.x && y == v.y && z == v.z;
	}

	public inline function set( v:Pt3D ) : PVector3D {
		x = v.x;
		y = v.y;
		z = v.z;
		return this;
	}

	public inline function add( v:Pt3D ) : PVector3D {
		x += v.x;
		y += v.y;
		z += v.z;
		return this;
	}

	public inline function sub( v:Pt3D ) : PVector3D {
		x -= v.x;
		y -= v.y;
		z -= v.z;
		return this;
	}

	public inline function div( v:Float ) : PVector3D {
		x /= v;
		y /= v;
		z /= v;
		return this;
	}

	public inline function mult( v:Float ) : PVector3D {
		x *= v;
		y *= v;
		z *= v;
		return this;
	}

	public inline function limit( l:Float ) : PVector3D {
		normalize();
		mult(l);
		return this;
	}

	public inline function unit() : PVector3D {
		normalize();
		return this;
	}

	public inline function normalize() : Float {
		var l = length();
		if (l != 0)
			div(l);
		return l;
	}

	public inline function lengthSquared() : Float {
		return (x * x + y * y + z * z);
	}

	public inline function length() : Float {
		return Math.sqrt(lengthSquared());
	}

	public inline function negate() : PVector3D {
		mult(-1);
		return this;
	}

	public inline function distanceSquared( v:Pt3D ) : Float {
		return (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y) + (v.z - z) * (v.z - z);
	}

	public inline function distance( v:Pt3D ) : Float {
		return Math.sqrt(distanceSquared(v));
	}

	public inline function clone() : PVector3D {
		return new PVector3D(x, y, z);
	}

	public inline function isNull() : Bool {
		return x == 0 && y == 0 && z == 0;
	}

	public inline function insideRectangle(a:Pt3D, b:Pt3D) : Bool {
		return x >= Math.min(a.x, b.x) && x <= Math.max(a.x, b.x)
			&& y >= Math.min(a.y, b.y) && y <= Math.max(a.y, b.y)
			&& z >= Math.min(a.z, b.z) && z <= Math.max(a.z, b.z);
	}

	// Rotates current point relatively to ORIGIN
	// return this
	public inline function rotateZ( a:Float ) : PVector3D {
		var cos = Math.cos(a);
		var sin = Math.sin(a);
		var rx = x * cos - y * sin;
		var ry = x * sin + y * cos;
		x = rx;
		y = ry;
		return this;
	}

	public inline function angleZ( ?v:Pt ) : Float {
		if (v == null)
			v = ORIGIN;
		return Math.atan2(y-v.y, x-v.x);
	}

	public function toString() : String {
		return "["+x+" : "+y+" : "+z+"]";
	}

	public static function doProduct( a:Pt3D, b:Pt3D ) : Float {
		return a.x * b.x + a.y * b.y + a.z * b.z;
	}

	public function moveToward( t:Pt3D, n:Float ) : PVector3D {
		var v = new PVector3D(t.x, t.y, t.z);
		v.sub(this);
		v.normalize();
		v.mult(n);
		add(v);
		return this;
	}

	public function moveAngle( a:Float, n:Float ) : PVector3D {
		var ap = new PVector3D(n, 0, 0);
		ap.rotateZ(a);
		add(ap);
		return this;
	}

	public static function getTangents( center:PVector3D, radius:Float, distantPoint:PVector3D ) : Array<PVector3D> {
		var pmc = distantPoint.clone().sub(center);
		var sqrLen = pmc.lengthSquared();
		var sqrRad = radius * radius;
		if (sqrLen <= sqrRad){
			// distantPoint inside circle, no tangent
			return [];
		}
		var invSqrLen = 1/sqrLen;
		var root = Math.sqrt(Math.abs(sqrLen - sqrRad));
		var t1 = new PVector3D(
			center.x + radius*(radius*pmc.x - pmc.y*root)*invSqrLen,
			center.y + radius*(radius*pmc.y + pmc.x*root)*invSqrLen,
			center.z
		);
		var t2 = new PVector3D(
			center.x + radius*(radius*pmc.x + pmc.y*root)*invSqrLen,
			center.y + radius*(radius*pmc.y - pmc.x*root)*invSqrLen,
			center.z
		);
		return [t1, t2];
	}

	public function toHex() : String {
		return "["+[
			tools.MyStringTools.doubleToHex(x),
			tools.MyStringTools.doubleToHex(y),
			tools.MyStringTools.doubleToHex(z)
		].join(", ")+"]";
	}
}