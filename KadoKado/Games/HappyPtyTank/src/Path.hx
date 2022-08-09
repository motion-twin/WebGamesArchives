import flash.geom.Point;

class Path {
	public var point : Point;
	public var next : Path;
	public var first : Path;
	public var isInterestingSpawnPoint : Bool;

	public function new( p:Point, ?spawnPoint:Bool=false ){
		point = p;
		next = this;
		first = this;
		isInterestingSpawnPoint = spawnPoint;
	}

	public function getSpawns() : Array<Path> {
		var result = [];
		var n = first;
		do {
			if (n.isInterestingSpawnPoint)
				result.push(n);
			n = n.next;
		}
		while (n != first);
		return result;
	}
	
	public function parts() : Array<Path> {
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
		point.x += x;
		point.y += y;
		if (next != first)
			next.translate(x, y);
	}
	
	public function clone() : Path {
		var r : Path = null;
		var n = first;
		do {
			var newp = new Path(n.point.clone(), n.isInterestingSpawnPoint);
			r = if (r == null) newp else r.link(newp);
			n = n.next;
		}
		while (n != first);
		return r.first;
	}

	public function link( p:Path ) : Path {
		next = p;
		p.next = first;
		p.first = first;
		return p;
	}

	/* -------------------- */

	public static var PATHES : Array<Path> = [
		// quadrillage
		new Path(new Point(100,100), true)
		.link(new Path(new Point(500,100)))
		.link(new Path(new Point(500,150)))
	    .link(new Path(new Point(100,150)))
		.link(new Path(new Point(100,200)))
		.link(new Path(new Point(500,200), true))
		.link(new Path(new Point(500,250)))
		.link(new Path(new Point(100,250)))
		.link(new Path(new Point(100,300)))
		.link(new Path(new Point(500,300), true))
		.link(new Path(new Point(500,350)))
		.link(new Path(new Point(100,350)))
		.link(new Path(new Point(100,400)))
		.link(new Path(new Point(500,400), true))
		.link(new Path(new Point(500,450)))
		.link(new Path(new Point(100,450)))
		.link(new Path(new Point(100,500)))
		.link(new Path(new Point(500,500)))
		,

		// collimaçon
		new Path(new Point(50,50), true)
		.link(new Path(new Point(550,50)))
		.link(new Path(new Point(550,550)))
		.link(new Path(new Point(50,550)))
		.link(new Path(new Point(50,100)))
		.link(new Path(new Point(500,100)))
		.link(new Path(new Point(500,500), true))
		.link(new Path(new Point(100,500)))
		.link(new Path(new Point(100,150)))
		.link(new Path(new Point(450,150), true))
		.link(new Path(new Point(450,450)))
		.link(new Path(new Point(150,450)))
		.link(new Path(new Point(150,200)))
		.link(new Path(new Point(400,200)))
		.link(new Path(new Point(400,400), true))
		.link(new Path(new Point(200,400)))
		.link(new Path(new Point(200,250)))
		.link(new Path(new Point(350,250)))
		.link(new Path(new Point(350,350)))
		.link(new Path(new Point(250,350)))
		.link(new Path(new Point(250,300)))
		.link(new Path(new Point(300,300), true))
		,
	];	
}