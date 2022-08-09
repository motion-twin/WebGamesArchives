import flash.geom.Point;

class CPath {
	// center point for this path point
	public var center : Point;
	// ray of the circle
	public var ray : Float;
	// the sprite must join this angle
	public var rdvAngle : Float;
	// then will then rotate around the center in this direction
	public var direction : Int; // ltor or rtol
	// the sprite will rotate for this amount of angle (from rdvRadian)
	public var byeAngle : Float;
	// when bye angle is reached, move to next CPath
	public var next : CPath;
	// first cpath linked (for custruction purpose)
	public var first : CPath;

	var rdv : Point;

	public function new( p:Point, r:Float, rdvA:Float, bye:Float, d:Int=1 ){
		center = p;
		ray = r;
		rdvAngle = rdvA;
		byeAngle = bye;
		direction = d;
		rdv = new flash.geom.Point(
			center.x + ray * Math.cos(rdvAngle),
			center.y + ray * Math.sin(rdvAngle)
		);
		next = this;
		first = this;
	}

	public function parts() : Array<CPath> {
		var result = [];
		var n = first;
		do {
			result.push(n);
			n = n.next;
		}
		while (n != first);
		return result;
	}

	public function size() : Int {
		var r = 0;
		var n = first;
		do {
			r++;
			n = n.next;
		}
		while (n != first);
		return r;
	}

	public function translate( x:Float, y:Float ){
		center.x += x;
		center.y += y;
		rdv.x += x;
		rdv.y += y;
		if (next != first)
			next.translate(x, y);
	}
	
	public function clone() : CPath {
		var r : CPath = null;
		var n = first;
		do {
			var newp = new CPath(n.center.clone(), n.ray, n.rdvAngle, n.byeAngle, n.direction);
			r = if (r == null) newp else r.link(newp);
			n = n.next;
		}
		while (n != first);
		return r.first;
	}

	public function getRendezVousPoint() : Point {
		return rdv;
	}

	public function link( p:CPath ) : CPath {
		next = p;
		p.next = first;
		p.first = first;
		return p;
	}

	/* ---------------------- */
	static var pad = - Math.PI * 2 / 16;
	public static var PATHES : Array<CPath> = [
		// 8 inclined path, foe should start on initial rdv point
		new CPath(new Point(200,200), 180,             0, 7/4 * Math.PI, -1)
		.link(new CPath(new Point(400,400), 180, Math.PI * 3/2, 7/4 * Math.PI,  1))
		,

		// 88 path
		new CPath(new Point(200,200), 100, Math.PI *   0, 6/4 * Math.PI, -1)
		.link(new CPath(new Point(400,200), 100, Math.PI * 2/4, 6/4 * Math.PI, -1))
		.link(new CPath(new Point(400,400), 100, Math.PI * 4/4, 6/4 * Math.PI, -1))
		.link(new CPath(new Point(200,400), 100, Math.PI * 6/4, 6/4 * Math.PI, -1))
		,
			
		// 88 X path
		new CPath(new Point(200,200), 100, Math.PI *   0, 6/4 * Math.PI,  1)
		.link(new CPath(new Point(400,200), 100, Math.PI * 2/4, 6/4 * Math.PI,  1))
		.link(new CPath(new Point(400,400), 100, Math.PI * 4/4, 6/4 * Math.PI,  1))
		.link(new CPath(new Point(200,400), 100, Math.PI * 6/4, 6/4 * Math.PI,  1))
		,
			
		// large 88 tissed
		new CPath(new Point(100,300), 50, pad + Math.PI *   0, 8/4 * Math.PI + pad*2, -1)
		.link(new CPath(new Point(300,100), 50, pad + Math.PI * 2/4, 8/4 * Math.PI + pad*2, -1))
		.link(new CPath(new Point(500,300), 50, pad + Math.PI * 4/4, 8/4 * Math.PI + pad*2, -1))
		.link(new CPath(new Point(300,500), 50, pad + Math.PI * 6/4, 8/4 * Math.PI + pad*2, -1))
	];
}