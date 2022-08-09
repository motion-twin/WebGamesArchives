package geom;

class PVector {
	static var ORIGIN = new PVector();

	public var x : Float;
	public var y : Float;

	public function new( x_:Float=0.0, y_:Float=0.0 ){
		x = x_;
		y = y_;
	}

	public inline function equals( v:Pt ) : Bool {
		return x == v.x && y == v.y;
	}

	public inline function set( v:Pt ){
		x = v.x;
		y = v.y;
	}

	public inline function add( v:Pt ){
		x += v.x;
		y += v.y;
	}

	public inline function sub( v:Pt ){
		x -= v.x;
		y -= v.y;
	}

	public inline function div( v:Float ){
		x /= v;
		y /= v;
	}

	public inline function mult( v:Float ){
		x *= v;
		y *= v;
	}

	public inline function limit( l:Float ){
		normalize();
		mult(l);
	}

	public inline function normalize(){
		var l = length();
		if (l != 0)
			div(l);
		return l;
	}

	public inline function lengthSquared() : Float {
		return x * x + y * y;
	}

	public inline function length() : Float {
		return Math.sqrt(x * x + y * y);
	}

	public inline function negate(){
		x *= -1;
		y *= -1;
	}

	public inline function distanceSquared( v:Pt ) : Float {
		return (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y);
	}

	public inline function distance( v:Pt ) : Float {
		return Math.sqrt((v.x - x) * (v.x - x) + (v.y - y) * (v.y - y));
	}

	public inline function clone() : PVector {
		return new PVector(x, y);
	}


	// Rotates current point relatively to ORIGIN
	// return this
	public inline function rotate( a:Float ) : PVector {
		var cos = Math.cos(a);
		var sin = Math.sin(a);
		var rx = x * cos - y * sin;
		var ry = x * sin + y * cos;
		x = rx;
		y = ry;
		return this;
	}

	public inline function angle( ?v:Pt ) : Float {
		if (v == null)
			v = ORIGIN;
		return Math.atan2(y-v.y, x-v.x);
	}

	public inline function pangle( ?v:Pt ) : Float {
		if (v == null)
			v = ORIGIN;
		return -Math.atan2(v.x - x, v.y - y);
	}

	public inline function xangle( ?v:Pt ) : Float {
		if (v == null)
			v = ORIGIN;
		return -Math.atan2(v.x - x, v.y - y) - Math.PI/2;
	}

	public function toString() : String {
		return "["+x+" : "+y+"]";
	}

	public function toHex() : String {
		return "["+tools.MyStringTools.doubleToHex(x)+" : "+tools.MyStringTools.doubleToHex(y)+"]";
	}
}