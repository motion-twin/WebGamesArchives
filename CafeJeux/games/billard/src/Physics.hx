interface PhysicObject<T> {

	// user/sim vars
	var x : Float;
	var y : Float;
	var r : Float;
	var dx : Float;
	var dy : Float;
	var mass : Float;
	function onCollide( ?obj : T ) : Void;

	// for computation
	var col : Float;
	var target : T;
	var sx : Float;
	var sy : Float;

}

class Physics<T : PhysicObject<T>> {//}

	public var friction : Float;
	public var objs : Array<T>;
	public var bounds : { xMin : Int, yMin : Int, xMax : Int, yMax : Int };
	public var bounceCoef : Float;

	public var energy : Float;
	var elapsed : Float;
	var nextCollision : T;

	public function new(friction,bounceCoef,?bounds) {
		objs = new Array();
		this.friction = friction;
		this.bounceCoef = bounceCoef;
		this.bounds = bounds;
		elapsed = 0;
	}

	public function start() {
		elapsed = 0;
		energy = null;
		nextCollision = null;
		compute();
		var nc = Math.POSITIVE_INFINITY;
		for( i in 0...objs.length ) {
			var o = objs[i];
			if( o.col < nc ) {
				nc = o.col;
				nextCollision = o;
			}
			o.sx = o.x;
			o.sy = o.y;
		}
	}

	public function update(t) {
		run(t);
	}

	public function stop() {
		updateSpeeds(elapsed);
	}
	public function stopAll(){
		stop();
		for(o in objs){
			o.dx = 0;
			o.dy = 0;
		}
	}

	public function getSpeed( o : T ) {
		var f = Math.pow(friction,elapsed);
		var dx = o.dx;
		var dy = o.dy;
		return Math.sqrt(dx*dx+dy*dy) * f;
	}

	public function getEnergy() {
		if( energy == null ) {
			energy = 0;
			for( o in objs )
				energy += Math.sqrt(o.dx*o.dx + o.dy * o.dy);
		}
		return energy * Math.pow(friction,elapsed);
	}

	function timeToDist( d : Float ) {
		var t = Math.log(d * (friction-1) + 1) / Math.log(friction);
		if( t < 0 || Math.isNaN(t) ) { // NaN = not reachable
			if( friction == 1 )
				return d;
			return null;
		}
		return t;
	}

	function test( o1 : T,o2 : T ) {
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

	function testBounds( o : T ) {
		if( o.dx < 0 ) {
			var c = timeToDist((bounds.xMin - o.x + o.r) / o.dx);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		} else if( o.dx > 0 ) {
			var c = timeToDist((bounds.xMax - o.x - o.r) / o.dx);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		}
		if( o.dy < 0 ) {
			var c = timeToDist((bounds.yMin - o.y + o.r) / o.dy);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		} else if( o.dy > 0 ) {
			var c = timeToDist((bounds.yMax - o.y - o.r) / o.dy);
			if( c < o.col ) {
				o.col = c;
				o.target = null;
			}
		}
	}

	function compute() {
		var inf = Math.POSITIVE_INFINITY;
		for( i in 0...objs.length )
			objs[i].col = inf;
		for( i in 0...objs.length ) {
			var o1 = objs[i];
			for( j in i+1...objs.length ) {
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
	}

	function updateSpeeds( dt ) {
		var f = Math.pow(friction,dt);
		for( i in 0...objs.length ) {
			var o = objs[i];
			o.dx *= f;
			o.dy *= f;
		}
	}

	function collideBounds(o : T) {
		var e = 1 / 100000;
		var x = 0;
		var y = 0;

		if( Math.abs(o.x - bounds.xMin - o.r) < e )
			x = 1;
		else if( Math.abs(o.x - bounds.xMax + o.r) < e )
			x = -1;
		else if( Math.abs(o.y - bounds.yMin - o.r) < e )
			y = 1;
		else if( Math.abs(o.y - bounds.yMax + o.r) < e )
			y = -1;
		else {
			// assert : stop all physics
			objs = null;
			return;
		}

		var d = (1 + bounceCoef) * (x * o.dx + y * o.dy);
		o.dx -= d * x;
		o.dy -= d * y;
	}

	function collide( o1 : T, o2 : T ) {
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

	function run(t) {
		var next = nextCollision;
		var t_sim = if( next == null ) t else Math.min(t,next.col - elapsed);
		var iscol = (next != null && next.col - elapsed == t_sim);
		elapsed += t_sim;
		var coef = (Math.pow(friction,elapsed) - 1) / (friction - 1);
		if( friction == 1 )
			coef = elapsed;
		for( i in 0...objs.length ) {
			var o = objs[i];
			o.x = o.sx + o.dx * coef;
			o.y = o.sy + o.dy * coef;
		}
		if( iscol ) {
			t -= t_sim;
			stop();
			if( next.target == null )
				collideBounds(next);
			else
				collide(next,next.target);
			next.onCollide(next.target);
			next.target.onCollide(next);
			start();
			update(t);
		}
	}

//{
}
