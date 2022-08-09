// -------------------------------------------------------------------------//
// Resources : 
//		http://www.gamasutra.com/features/20000208/lander_01.htm
//		http://www.gamasutra.com/features/20020118/vandenhuevel_01.htm
// -------------------------------------------------------------------------//
class Physics {

	var friction : float;
	var objs : Array<PhysicObj>;
	var bounds : {
		xmin : float,
		ymin : float,
		xmax : float,
		ymax : float,
		coef : float
	};

	var next_col : float;
	var elapsed : float;
	var next_obj : PhysicObj;

	function new(o,f,b) {
		objs = o;
		friction = f;
		bounds = b;
		elapsed = 0;
	}

	function stop() {
		updateSpeeds(elapsed);
	}

	function start() {		
		compute();
	}

	function speed(o) {
		var f = Math.pow(friction,elapsed);
		var dx = o.dx * f;
		var dy = o.dy * f;
		return Math.sqrt(dx*dx+dy*dy);
	}

	function updateSpeeds(t) {
		var i;
		var f = Math.pow(friction,t);
		for(i=0;i<objs.length;i++) {
			var o = objs[i];
			o.dx *= f;
			o.dy *= f;
		}
	}

	function timeToDist(d) {
		var t = Math.log(d * (friction-1) + 1) / Math.log(friction);
		if( t < 0 || Std.isNaN(t) ) // NaN = not reachable
			return null;
		return t;
	}

	function test(o1,o2) {
		var dx = o2.x - o1.x;
		var dy = o2.y - o1.y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var r = o1.r + o2.r;

		// relative movement
		var mx = o1.dx - o2.dx;
		var my = o1.dy - o2.dy;
		var md = Math.sqrt(mx*mx+my*my);
		
		mx /= md;
		my /= md;

		// if negative dot product, they are moving different way
		var d = mx * dx + my * dy;
		if( d <= 0 )
			return null;

		var f = dist * dist - d * d;
		var rr = r * r;
		// minimal distance will still not collide 
		if( f >= rr )
			return null;

		var col_dist = d - Math.sqrt(rr - f);		
		
		// translate into time units
		return timeToDist(col_dist / md);
	}

	function testBounds(o) {
		if( o.dx < 0 ) {			
			var c = timeToDist((bounds.xmin - o.x + o.r) / o.dx);			
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		} else if( o.dx > 0 ) {
			var c = timeToDist((bounds.xmax - o.x - o.r) / o.dx);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		}
		if( o.dy < 0 ) {
			var c = timeToDist((bounds.ymin - o.y + o.r) / o.dy);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		} else if( o.dy > 0 ) {
			var c = timeToDist((bounds.ymax - o.y - o.r) / o.dy);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		}
	}

	function compute() {
		var i,j;
		for(i=0;i<objs.length;i++)
			objs[i].col = 1 / 0;
		for(i=0;i<objs.length;i++) {
			var o1 = objs[i];
			for(j=i+1;j<objs.length;j++) {
				var o2 = objs[j];
				var c = test(o1,o2);
				if( c != null ) {
					if( c < o1.col ) {
						o1.col = c;
						o1.target = o2;
					}
					o2.col = c;
					o2.target = o1;
				}
			}
			if( bounds != null )
				testBounds(o1);
		}

		elapsed = 0;
		next_col = 1 / 0;
		next_obj = null;
		for(i=0;i<objs.length;i++) {
			var o = objs[i];	
			if( o.col < next_col ) {
				next_col = o.col;
				next_obj = o;
			}
			o.sx = o.x;
			o.sy = o.y;
		}
	}

	function collideBounds(o : PhysicObj) {
		var e = 1 / 100000;
		var x = 0;
		var y = 0;

		if( Math.abs(o.x - bounds.xmin - o.r) < e )
			x = 1;			
		else if( Math.abs(o.x - bounds.xmax + o.r) < e )
			x = -1;			
		else if( Math.abs(o.y - bounds.ymin - o.r) < e )			
			y = 1;
		else if( Math.abs(o.y - bounds.ymax + o.r) < e )			
			y = -1;
		else {
			Log.trace("NO COLLIDE FOUND ! "+o.x+","+o.y);
			return;
		}

		var d = (1 + bounds.coef) * (x * o.dx + y * o.dy);
		o.dx -= d * x;
		o.dy -= d * y;
	}

	function collide(o1,o2) {
		var dx = o1.x - o2.x;
		var dy = o1.y - o2.y;
		var dist = Math.sqrt(dx*dx+dy*dy);

		dx /= dist;
		dy /= dist;

		var a1 = o1.dx * dx + o1.dy * dy;
		var a2 = o2.dx * dx + o2.dy * dy;

		var p = (2 * (a1 - a2)) / (o1.mass + o2.mass);

		o1.dx -= p * o2.mass * dx;
		o1.dy -= p * o2.mass * dy;

		o2.dx += p * o1.mass * dx;
		o2.dy += p * o1.mass * dy;
	}	

	function update(t : float) {
		var i;
		var t_sim = Math.min(t,next_col);
		var iscol = (next_col <= t);
		elapsed += t_sim;
		next_col -= t_sim;
		var coef = (Math.pow(friction,elapsed) - 1) / (friction - 1);
		for(i=0;i<objs.length;i++) {
			var o = objs[i];
			o.x = o.sx + o.dx * coef;
			o.y = o.sy + o.dy * coef;
			if( !iscol && (o.x < bounds.xmin + o.r || o.y < bounds.ymin + o.r) )
				Log.trace("OUT-BOUNDS ! "+next_col+" "+o.col);
		}		
		if( iscol ) {
			t -= t_sim;
			stop();
			if( next_obj.target == null )
				collideBounds(next_obj);
			else
				collide(next_obj,next_obj.target);
			next_obj.onCollide(next_obj.target);
			next_obj.target.onCollide(next_obj);
			start();
			update(t);
		}
	}

}