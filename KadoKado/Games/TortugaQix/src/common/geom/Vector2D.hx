package geom;

typedef Rect = {>Pt, w:Float, h:Float };

class Vector2D {
	public var start : Pt;
	public var end : Pt;
	public var delta : PVector;
	var rect : Rect;

	public function new( start:Pt, end:Pt ){
		this.start = start;
		this.end = end;
		compute();
	}

	public function compute(){
		if (delta == null)
			delta = new PVector();
		delta.x = end.x - start.x;
		delta.y = end.y - start.y;
		if (rect == null)
			rect = { x:0.0, y:0.0, w:0.0, h:0.0 };
		rect.x = Math.min(start.x, end.x);
		rect.y = Math.min(start.y, end.y);
		rect.w = Math.abs(delta.x);
		rect.h = Math.abs(delta.y);
	}

	public function normale() : PVector {
		var res = new PVector(delta.x, delta.y);
		res.normalize();
		return res;
	}

	public function rectangleContains( p:Pt ){
		return (rect.x <= p.x && rect.x + rect.w >= p.x) && (rect.y <= p.y && rect.y + rect.h >= p.y);
	}

	// >0 == same direction
	// <0 == reversed direction
	public static function dotProduct( v1:Vector2D, v2:Vector2D ) : Float {
		return v1.delta.x * v2.delta.x + v1.delta.y * v2.delta.y;
	}

	public static function project( v1:Vector2D, v2:Vector2D ) : PVector {
		var dotP = dotProduct(v1, v2);
		var pvect = new PVector(v2.delta.x, v2.delta.y);
		pvect.normalize();
		pvect.mult(dotP);
		return pvect;
	}

	public static function perProduct( v1:Vector2D, v2:Vector2D ) : PVector {
		var v3bx = v2.start.x - v1.start.x;
		var v3by = v2.start.y - v1.start.y;
		var perP1 = v3bx * v2.delta.y - v3by * v2.delta.x;
		var perP2 = v1.delta.x * v2.delta.y - v1.delta.y * v2.delta.x;
		if (perP2 == 0)
			return null;
		var ratio = perP1 / perP2;
		if (ratio > 1 || ratio < 0)
			return null;
		var cx = v1.start.x + v1.delta.x * ratio;
		var cy = v1.start.y + v1.delta.y * ratio;
		return new PVector(cx, cy);

	}


	inline static function ptstr(a:Pt){
		return "["+a.x+" : "+a.y+"]";
	}

	public function toString() : String {
		return ptstr(start)+" .. "+ptstr(end);
	}

	#if flash
	public function getShape( color:UInt) : flash.display.Shape {
		var result = new flash.display.Shape();
		result.graphics.lineStyle(2, color);
		result.graphics.moveTo(start.x, start.y);
		result.graphics.lineTo(end.x, end.y);
		return result;
	}
	#end
}

