package mt.gx.math;
import mt.gx.math.Vec3;

TODO test me
class Catmull3 {
	public var points : Array<Vec3>;
	
	public function new( ?points ) {
		if ( points != null ) this.points = points;
		else points = [];
	}
	
	/*
	 * Sample linearly and create a point buffer
	*/
	public function buildLineLinear( startIdx=0,endIdx=-1, tstep=0.01) : Array<Vec3>{
		if (endIdx == -1) {
			endIdx  = points.length;
		}
		
		var res = [];
		var p = new Vec3();
		var cur = 0;
		var steps = 1.0 / tstep;
		var cstep = 0.0;
		for ( i in startIdx...endIdx) {
			var p0 = get(i-1);
			var p1 = get(i);
			var p2 = get(i+1);
			var p3 = get(i+2);
			cstep = 0.0;
			for (s in 0...steps ) {
				var r = (res[cur++] = new Vec3());
				
				r.x = catmull(p0.x, p1.x, p2.x, p3.x, cstep);
				r.y = catmull(p0.y, p1.y, p2.y, p3.y, cstep);
				r.z = catmull(p0.z, p1.z, p2.z, p3.z, cstep);
				
				cstep += steps;
			}
		}
		return res;
	}
	
	public inline function catmull(p0 : Float , p1 : Float , p2 : Float , p3 : Float , t) : Float {
		var q = 2.0 * p1;
		var t2 = t * t;
		
		q += ( -p0 + p2) * t;
		q += (2.0*p0 -5.0*p1 +4*p2-p3) * t2;
		q += (-p0+3*p1-3*p2+p3) * t2 * t;
		
		return 0.5 * q;
	}
}





