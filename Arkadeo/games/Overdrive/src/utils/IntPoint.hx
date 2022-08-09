package utils;

/**
 * ...
 * @author 01101101
 */

class IntPoint {
	
	public var x:Int;
	public var y:Int;
	
	public function new (x:Int = 0, y:Int = 0) {
		this.x = x;
		this.y = y;
	}
	
	public function clone () :IntPoint {
		return new IntPoint(this.x, this.y);
	}
	
	public function toString () :String {
		return "[IntPoint] { x:" + x + ", y:" + y + " }";
	}
	
}