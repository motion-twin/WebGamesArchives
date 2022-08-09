package game;

/*
  Unless specified otherwise everything is radian.
 */
class Point {
	public static var ORIGIN = new Point(0.0, 0.0);
	public var x : Float;
	public var y : Float;

	public function new( x:Float, y:Float ){
		this.x = x;
		this.y = y;
	}

	public inline function copy() : Point {
		return new Point(x,y);
	}

	public inline function magnitude() : Float {
		return Math.sqrt(squareMagnitude());
	}

	public inline function squareMagnitude() : Float {
		return x*x + y*y;
	}

	public function normalize() : Point {
		var m = magnitude();
		if (m != 0)
			div(m);
		return this;
	}

	public function set( p:Point ){
		x = p.x;
		y = p.y;
	}

	public function add( p:Point ) : Point {
		x += p.x;
		y += p.y;
		return this;
	}

	public function del( p:Point ) : Point {
		x -= p.x;
		y -= p.y;
		return this;
	}

	public function mult( f:Float ) : Point {
		x *= f;
		y *= f;
		return this;
	}

	public function div( f:Float ) : Point {
		x /= f;
		y /= f;
		return this;
	}

	public function insideRectangle( a:Point, b:Point ){
		return x >= Math.min(a.x, b.x) && x <= Math.max(a.x, b.x)
			&& y >= Math.min(a.y, b.y) && y <= Math.max(a.y, b.y);
	}

	public inline function squareDistance( ?p:Point ) : Float {
		if (p == null)
			return squareMagnitude();
		else
			return (p.x - x) * (p.x - x) + (p.y - y) * (p.y - y);
	}

	public inline function distance( ?p:Point ) : Float {
		return Math.sqrt(squareDistance(p));
	}

	public inline function moveAngle( angle:Float, speed:Float ){
		// angle = angle + Math.PI/2; // FIX for bourinette (Math.PI/2) rotation
		x += speed * Math.cos(angle);
		y += speed * Math.sin(angle);
		return this;
	}

	/* Move towards specified destination at specified teleport speed and return this. */
	public function moveToward( dest:Point, speed:Float ){
		return moveAngle(angle(dest), speed);
	}

	public inline function angle( ?p:Point ) : Float {
		if (p == null)
			p = ORIGIN;
		return Math.atan2(p.y-y, p.x-x);
		// There is a repair rotation, y and x are reversed to compute angles
		// return -Math.atan2(p.x-x, p.y-y);
	}

	/* Rotate current point and return this. */
	public inline function rotate( angle:Float ) : Point {
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		var rx = x * cos - y * sin;
		var ry = x * sin + y * cos;
		x = rx;
		y = ry;
		return this;
	}

	public function toString() : String {
		return "["+Math.round(x*1000)/1000+" : "+Math.round(y*1000)/1000+"]";
	}

	public function perp() : Point {
		return new Point(-y, x);
	}
}

class XGeom {
	public static function getTangents(center:Point, radius:Float, distantPoint:Point){
		var pmc = distantPoint.copy().del(center);
		var sqrLen = pmc.squareDistance();
		var sqrRad = radius * radius;
		if (sqrLen <= sqrRad){
			// distantPoint inside circle, no tangent
			return [];
		}
		var invSqrLen = 1/sqrLen;
		var root = Math.sqrt(Math.abs(sqrLen - sqrRad));
		var t1 = new Point(
			center.x + radius*(radius*pmc.x - pmc.y*root)*invSqrLen,
			center.y + radius*(radius*pmc.y + pmc.x*root)*invSqrLen
		);
		var t2 = new Point(
			center.x + radius*(radius*pmc.x + pmc.y*root)*invSqrLen,
			center.y + radius*(radius*pmc.y - pmc.x*root)*invSqrLen
		);
		return [t1, t2];
	}
}