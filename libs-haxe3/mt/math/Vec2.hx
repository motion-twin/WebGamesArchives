package mt.math;

/**
 * A two-dimensional vector - a geometric object that has both a magnitude (or length) and direction.
 */
class Vec2
{
	public var x : Float;
	public var y : Float;
	
	/** Creates a vector with zero length. */
	public function new(?x = .0, ?y = .0)
	{
		this.x = x;
		this.y = y;
	}
	
	inline public function getAngle():Float
	{
		return Math.atan2(y, x);
	}
	
	public function redefine(mag:Float, ang:Float)
	{
		x = mag * Math.cos(ang);
		y = mag * Math.sin(ang);
	}
	
	inline public static function flip(x:Vec2):Void
	{
		x.x = -x.x;
		x.y = -x.y;
	}
	
	/** Creates and returns a copy of this object. */
	public function clone():Vec2
	{
		return new Vec2(x, y);
	}
	
	inline public function normSq() {
		return Vec2.dot2(this, this);
	}
	
	inline public function set( v ) {
		this.x = v.x;
		this.y = v.y;
	}
	
	inline public function set2( x, y ) {
		this.x = x;
		this.y = y;
	}
	
	inline static public function add(a:Vec2, b:Vec2, ?o:Vec2):Vec2 {
		if( o == null ) o = new Vec2();
		o.x = a.x + b.x;
		o.y = a.y + b.y;
		return o;
	}
	
	inline static public function sub(a:Vec2, b:Vec2, ?o:Vec2):Vec2 {
		if( o == null ) o = new Vec2();
		o.x = a.x - b.x;
		o.y = a.y - b.y;
		return o;
	}
	
	inline static public function add2(a:Vec2, x:Float, y:Float, ?o:Vec2):Vec2 {
		if( o == null ) o = new Vec2();
		o.x = a.x + x;
		o.y = a.y + y;
		return o;
	}
	
	inline static public function sub2(a:Vec2, x:Float, y:Float, ?o:Vec2):Vec2 {
		if( o == null ) o = new Vec2();
		o.x = a.x - x;
		o.y = a.y - y;
		return o;
	}
	
	/** CCW perp(<i>x</i>) operator. */
	inline public static function perpCCW(x:Vec2):Void
	{
		var t = x.y; x.y = -x.x; x.x = t;
	}
	
	/** CW perp(<i>x</i>) operator. */
	inline public static function perpCW(x:Vec2):Void
	{
		var t = x.y; x.y = x.x; x.x = -t;
	}
	
	/** Normalizes <i>x</i> and returns the length of <i>x</i>. */
	inline public static function unit(x:Vec2):Float
	{
		var t = Math.sqrt(Vec2.dot2(x, x));
		x.x /= t; x.y /= t;
		return t;
	}
	
	/** The length of <i>x</i>. */
	inline public static function norm(x:Vec2):Float
	{
		return Math.sqrt(Vec2.dot2(x, x));
	}
	
	/** The length of the vector (<i>x</i>,<i>y</i>). */
	inline public static function norm2(x:Float, y:Float):Float
	{
		return Math.sqrt(Vec2.dot4(x, y, x, y));
	}
	
	inline public static function truncate(x:Vec2, max:Float):Void
	{
		var tx = x.x;
		var ty = x.y;
		var len = Vec2.dot4(tx, ty, tx, ty);
		if( len > max * max)
		{
			len = Math.sqrt(len);
			x.x = (tx / len) * max;
			x.y = (ty / len) * max;
		}
	}

	inline public static function random(xmin:Float, xmax:Float, ymin:Float, ymax:Float):Vec2
	{
		return new Vec2(MLib.frandRange(xmin, xmax), MLib.frandRange(ymin, ymax));
	}
	
	/**  */
	inline public static function min(a:Vec2, b:Vec2, out:Vec2):Void
	{
		out.x = MLib.fmin(a.x, b.x);
		out.y = MLib.fmin(a.y, b.y);
	}
	
	/**  */
	inline public static function max(a:Vec2, b:Vec2, out:Vec2):Void
	{
		out.x = MLib.fmax(a.x, b.x);
		out.y = MLib.fmax(a.y, b.y);
	}
	
	/** Computes the dot product */
	inline public static function dot2(a:Vec2, b:Vec2):Float
	{
		return dot4(a.x, a.y, b.x, b.y);
	}
	
	/** Computes the dot product  */
	inline public static function dot4(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}
	
	/**
	 * Computes the unit length vector
	 */
	inline public static function dir2(a:Vec2, b:Vec2, q:Vec2):Float
	{
		return dir4(a.x, a.y, b.x, b.y, q);
	}
	
	/**
	 * Computes the unit length vector
	 */
	inline public static function dir4(ax:Float, ay:Float, bx:Float, by:Float, q:Vec2):Float
	{
		var dx = bx - ax;
		var dy = by - ay;
		var len = Math.sqrt(dx * dx + dy * dy);
		q.x = dx / len;
		q.y = dy / len;
		return len;
	}
	
	/** Vector reflection */
	inline public static function reflect2(v:Vec2, n:Vec2, q:Vec2):Void
	{
		reflect4(v.x, v.y, n.x, n.y, q);
	}
	
	/** Vector reflection */
	inline public static function reflect4(vx:Float, vy:Float, nx:Float, ny:Float, q:Vec2):Void
	{
		var t = dot4(vx, vy, nx, ny);
		q.x = vx - (2 * t) * nx;
		q.y = vy - (2 * t) * ny;
	}
	
	/** Computes the angle between segments formed by the vector <i>a</i> and <i>b</i>. */
	inline public static function angle2(a:Vec2, b:Vec2):Float
	{
		return Math.atan2(Vec2.perpDot2(a, b), Vec2.dot2(a, b));
	}
	
	/** Computes the angle between segments formed by the vector (<i>ax</i>,<i>ay</i>) and (<i>bx</i>,<i>by</i>). */
	inline public static function angle4(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return Math.atan2(Vec2.perpDot4(ax, ay, bx, by), Vec2.dot4(ax, ay, bx, by));
	}
	
	/** Rotates <i>v</i> about <i>angle</i> (radians). */
	inline public static function rotate(v:Vec2, angle:Float):Void
	{
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		var x = v.x;
		var y = v.y;
		v.x = x * c - y * s;
		v.y = x * s + y * c;
	}
	
	/** The signed triangle area formed by the vertices A, B and C */
	inline public static function signedTriArea(a:Vec2, b:Vec2, c:Vec2):Float
	{
		return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
	}
	
	/**
	 * Tests if a point is left, on or right of an infinite line.
	 * >0 for <i>c</i> left of the line through <i>a</i> and <i>b</i>
	 * =0 for <i>c</i> on the line
	 * <0 for <i>c</i> right of the line
	 */
	inline public static function isLeft3(a:Vec2, b:Vec2, c:Vec2):Float
	{
		return isLeft6(a.x, a.y, b.x, b.y, c.x,  c.y);
	}
	
	/**
	 * Tests if a point is left, on or right of an infinite line.
	 * >0 for <i>c</i> left of the line through <i>a</i> and <i>b</i>
	 * =0 for <i>c</i> on the line
	 * <0 for <i>c</i> right of the line
	 */
	inline public static function isLeft6(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float):Float
	{
		return (bx - ax) * (cy - ay) - (cx - ax) * (by - ay);
	}
	
	/** Computes the midpoint */
	inline public static function mid2(a:Vec2, b:Vec2, q:Vec2):Void
	{
		mid4(a.x, a.y, b.x, b.y, q);
	}
	
	/** Computes the midpoint  */
	inline public static function mid4(ax:Float, ay:Float, bx:Float, by:Float, q:Vec2):Void
	{
		q.x = ax + (bx - ax) * .5;
		q.y = ay + (by - ay) * .5;
	}
}
