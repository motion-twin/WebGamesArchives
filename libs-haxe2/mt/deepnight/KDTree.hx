package mt.deepnight;

import flash.geom.Point;

typedef KDTreeNode = {
	p		: Point,
	left	: Null<KDTreeNode>,
	right	: Null<KDTreeNode>,
}

class KDTree {
	var tree			: KDTreeNode;
	public var points	: Array<Point>;
	public var iter		: Int;
	
	public function new() {
		points = new Array();
	}
	
	public inline function addPoint(pt:Point) {
		points.push(pt);
	}
	public inline function addPoints(pts:Array<Point>) {
		points = points.concat(pts);
	}

	public inline function build() { // à appeler après insertion des points
		tree = buildRecursion(points);
	}
	
	function buildRecursion(pts:Array<Point>, ?depth=0) : KDTreeNode {
		if(pts.length==0)
			return null;
		var axis = depth % 2;
		if(axis==0)
			pts.sort(function(pa,pb) { return Reflect.compare(pa.x, pb.x); });
		else
			pts.sort(function(pa,pb) { return Reflect.compare(pa.y, pb.y); });
			
		var median = pts[Std.int(pts.length/2)];
		var left = new Array();
		var right = new Array();
		for(p in pts)
			if(p!=median)
				if(axis==0)
					if(p.x<median.x)	left.push(p) else right.push(p);
				else
					if(p.y<median.y)	left.push(p) else right.push(p);
					
		var node : KDTreeNode = {
			p		: median,
			left	: buildRecursion(left, depth+1),
			right	: buildRecursion(right, depth+1),
		}
		return node;
	}
	
	function nearestRecursion(here:KDTreeNode, pt:Point, ?best:Point, ?depth=0) {
		if(here==null)
			return best;

		iter++;
		
		var bestd = 9999.9;
		
		if(best==null)
			best = here.p;
		else {
			bestd = distance(best,pt);
			var d = distance(here.p,pt);
			if( d < bestd ) {
				best = here.p;
				bestd = d;
			}
		}
		
		var axis = depth % 2;
		var branch = here.right;
		if(axis==0 && pt.x < here.p.x || axis==1 && pt.y < here.p.y)
			branch = here.left;
		best = nearestRecursion(branch, pt, best, depth+1);
				
		if(axis==0 && abs(here.p.x-pt.x) <= bestd || axis==1 && abs(here.p.y-pt.y) <= bestd ) {
			// il faut vérifier l'autre côté car une meilleure solution peut y exister
			var opposite = if(branch==here.left) here.right else here.left;
			best = nearestRecursion(opposite, pt, best, depth+1);
		}
		
		return best;
	}
	
	public inline function getNearest(pt:Point) {
		iter = 0;
		if( tree==null )
			throw "KDTree not builded";
		return nearestRecursion(tree, pt);
	}
	
	inline function distance(a:Point, b:Point) : Float {
		return Math.sqrt( (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y) );
	}
	
	inline function abs(n:Float) {
		return if(n<0) -n else n;
	}
}