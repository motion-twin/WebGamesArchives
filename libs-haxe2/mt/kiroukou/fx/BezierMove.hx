package mt.kiroukou.fx;
import flash.display.DisplayObject;
import flash.geom.Point;
import mt.MLib;

#if flash
typedef Movable = DisplayObject;
#else
typedef Movable = { 
	var x:Float;
	var y:Float;
}
#end

class BezierMove<T:Movable>
{
	var target:T;
	var p0: Point;
	var p1: Point;
	var p2: Null<Point>;
	var p3: Null<Point>;

	/**
	 * Pass point/tangent
	 */
	public function new(target:T, from:{p:Point,t:Point}, to:{p:Point,t:Point}) 
	{
		this.target = target;
		this.p0 = from.p.clone();
		this.p1 = from.t.clone();
		this.p2 = to.p.clone();
		this.p3 = to.t.clone();
	}
	
	/**
	 * Cubic Hermite Spline:http://en.wikipedia.org/wiki/Cubic_Hermite_spline
	 * @param progress a Progress float between 0 and 1
	 */
	public function update(p_progress:Float)
	{
		var t =  p_progress;
		var t2 = t * t;
		var t3 = t2 * t;
		var t2_3 = 3 * t2;
		var t3_2 = 2 * t3;
		
		var a = t3_2 - t2_3 + 1;
		var b = t3 - 2 * t2 + t;
		var c = t2_3 - t3_2;
		var d = t3 - t2;
		
		target.x = 	a * p0.x +
				b * p1.x + 
				c * p2.x +
				d * p3.x;
				
		target.y = 	a * p0.y +
				b * p1.y + 
				c * p2.y +
				d * p3.y;
	}
}