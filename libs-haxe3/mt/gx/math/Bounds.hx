package mt.gx.math;

class Bounds {
	
	public var xMin : Float;
	public var yMin : Float;

	public var xMax : Float;
	public var yMax : Float;
	
	public var x(get,null) : Float;
	public var y(get, null) : Float;
	
	public var width(get,null) : Float;
	public var height(get,null) : Float;
	
	public inline function new() {
		empty();
	}
	
	inline function get_x() 	return xMin;
	inline function get_y() 	return yMin;
	
	inline function get_width() 	return xMax - xMin;
	inline function get_height() 	return yMax - yMin;
	
	public var left(get, null) 		: Float; 	inline function get_left()		return xMin;
	public var right(get,null) 		: Float;	inline function get_right() 	return xMax;
	public var top(get,null) 		: Float;	inline function get_top() 		return yMin;
	public var bottom(get,null) 	: Float;	inline function get_bottom() 	return yMax;
	
	public inline function collides( b : Bounds ) {
		return !(xMin > b.xMax || yMin > b.yMax || xMax < b.xMin || yMax < b.yMin);
	}
	
	public inline function includes( p : Vec2 ) {
		return p.x >= xMin && p.x < xMax && p.y >= yMin && p.y < yMax;
	}
	
	public inline function includes2( px:Float, py:Float) {
		return px >= xMin && px < xMax && py >= yMin && py < yMax;
	}
	
	/**
	 * http://stackoverflow.com/questions/401847/circle-rectangle-collision-detection-intersection
	 */
	public inline function testCircle( px,py ,r) {
		var closestX = MathEx.clamp(px, xMin, xMax);
		var closestY = MathEx.clamp(py, yMin, yMax);
		
		var distX = px - closestX;
		var distY = py - closestY;
		
		var distSq = distX * distX + distY * distY;
		return distSq < r * r;
	}
	
	public inline function add( b : Bounds ) {
		if( b.xMin < xMin ) xMin = b.xMin;
		if( b.xMax > xMax ) xMax = b.xMax;
		if( b.yMin < yMin ) yMin = b.yMin;
		if( b.yMax > yMax ) yMax = b.yMax;
	}
	
	/**
	 * set the bounding box with 4 floats
	 */
	public inline function add4( x:Float, y:Float, w:Float, h:Float ) {
		var ixMin = x;
		var iyMin = y;
		
		var ixMax = x+w;
		var iyMax = y+h;
		
		if( ixMin < xMin ) xMin = ixMin;
		if( ixMax > xMax ) xMax = ixMax;
		if( iyMin < yMin ) yMin = iyMin;
		if( iyMax > yMax ) yMax = iyMax;
	}

	public inline function addPoint( p : Vec2 ) {
		if( p.x < xMin ) xMin = p.x;
		if( p.x > xMax ) xMax = p.x;
		if( p.y < yMin ) yMin = p.y;
		if( p.y > yMax ) yMax = p.y;
	}
	
	public inline function addPoint2( px:Float,py:Float ) {
		if( px < xMin ) xMin = px;
		if( px > xMax ) xMax = px;
		if( py < yMin ) yMin = py;
		if( py > yMax ) yMax = py;
	}
	
	public inline function setMin( p : Vec2 ) {
		xMin = p.x;
		yMin = p.y;
	}

	public inline function setMax( p : Vec2 ) {
		xMax = p.x;
		yMax = p.y;
	}
	
	public inline function load( b : Bounds ) {
		xMin = b.xMin;
		yMin = b.yMin;
		xMax = b.xMax;
		yMax = b.yMax;
	}
	
	public inline function scaleCenter( v : Float ) {
		var dx = (xMax - xMin) * 0.5 * v;
		var dy = (yMax - yMin) * 0.5 * v;
		var mx = (xMax + xMin) * 0.5;
		var my = (yMax + yMin) * 0.5;
		xMin = mx - dx * v;
		yMin = my - dy * v;
		xMax = mx + dx * v;
		yMax = my + dy * v;
	}
	
	public inline function offset( dx : Float, dy : Float ) {
		xMin += dx;
		xMax += dx;
		yMin += dy;
		yMax += dy;
	}
	
	public inline function getMin() {
		return new Vec2(xMin, yMin);
	}
	
	public inline function getCenter() {
		return new Vec2((xMin + xMax) * 0.5, (yMin + yMax) * 0.5);
	}

	public inline function getSize() {
		return new Vec2(xMax - xMin, yMax - yMin);
	}
	
	public inline function getMax() {
		return new Vec2(xMax, yMax);
	}
	
	public inline function empty() {
		xMin = 1e20;
		yMin = 1e20;
		xMax = -1e20;
		yMax = -1e20;
	}

	public inline function all() {
		xMin = -1e20;
		yMin = -1e20;
		xMax = 1e20;
		yMax = 1e20;
	}
	
	public inline function clone() {
		var b = new Bounds();
		b.xMin = xMin;
		b.yMin = yMin;
		b.xMax = xMax;
		b.yMax = yMax;
		return b;
	}
	
	public inline function translate(x, y) {
		xMin += x;
		xMax += x;
		
		yMin += y;
		yMax += y;
	}
		
	public function toString() {
		return "{" + getMin() + "," + getMax() + "}";
	}

	public static inline function fromValues( x : Float, y : Float, width : Float, height : Float ) {
		var b = new Bounds();
		b.xMin = x;
		b.yMin = y;
		b.xMax = x + width;
		b.yMax = y + height;
		return b;
	}
	
	public static inline function fromPoints( min : Vec2, max : Vec2 ) {
		var b = new Bounds();
		b.setMin(min);
		b.setMax(max);
		return b;
	}
	
}