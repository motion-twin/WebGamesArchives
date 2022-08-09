package data;

class DelPoint {
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public function new(x,y) {
		this.x = x;
		this.y = y;
	}
}

class DelTriangle {
	public var p1 : DelPoint;
	public var p2 : DelPoint;
	public var p3 : DelPoint;
	public function new(p1,p2,p3) {
		this.p1 = p1;
		this.p2 = p2;
		this.p3 = p3;
	}
}

class Delaunay {

	public function new() {
	}

	inline function edge( p1 : DelPoint, p2 : DelPoint ) {
		return { p1 : p1, p2 : p2 };
	}

	public function make( pl : Array<DelPoint> ) {
		var nv = pl.length;
		var xmin = pl[0].x;
		var ymin = pl[0].y;
		var xmax = xmin;
		var ymax = ymin;
		var id = 0;
		for( p in pl ) {
			p.id = id++;
			if( p.x < xmin ) xmin = p.x;
			if( p.y < ymin ) ymin = p.y;
			if( p.x > xmax ) xmax = p.x;
			if( p.y > ymax ) ymax = p.y;
		}
		var dx = xmax - xmin;
		var dy = ymax - ymin;
		var dmax = (dx > dy) ? dx : dy;
		var xmid = (xmin + xmax + 1) >> 1;
		var ymid = (ymin + ymax + 1) >> 1;
		var p1 = new DelPoint(xmid - 2 * dmax,ymid - dmax);
		var p2 = new DelPoint(xmid,ymid + 2 * dmax);
		var p3 = new DelPoint(xmid + 2 * dmax,ymid - dmax);
		p1.id = id++;
		p2.id = id++;
		p3.id = id++;
		pl.push(p1);
		pl.push(p2);
		pl.push(p3);

		var triangles = new List();
		triangles.add(new DelTriangle(p1,p2,p3));

		for( i in 0...nv ) {
			var cur = pl[i];
			var edges = new Array();
			for( t in triangles )
				if( inCircle(cur,t.p1,t.p2,t.p3) ) {
					edges.push(edge(t.p1,t.p2));
					edges.push(edge(t.p2,t.p3));
					edges.push(edge(t.p3,t.p1));
					triangles.remove(t);
				}
			var j = edges.length - 2;
			while( j >= 0 ) {
				var k = edges.length - 1;
				while( k >= j + 1 ) {
					var e1 = edges[j];
					var e2 = edges[k];
					if( (e1.p1 == e2.p1 && e1.p2 == e2.p2) || (e1.p1 == e2.p2 && e1.p2 == e2.p1) ) {
						edges.splice(k,1);
						edges.splice(j,1);
						k-=2;
						continue;
					}
					k--;
				}
				j--;
			}
			for( e in edges )
				triangles.add(new DelTriangle(e.p1,e.p2,cur));
		}
		for( t in triangles )
			if( t.p1.id >= nv || t.p2.id >= nv || t.p3.id >= nv )
				triangles.remove(t);
		pl.pop();
		pl.pop();
		pl.pop();
		return triangles;
	}

	function inCircle( p : DelPoint, p1 : DelPoint, p2 : DelPoint, p3 : DelPoint ) {
		if( p1.y == p2.y && p2.y == p3.y )
			return false;

		var m1, m2;
		var mx1, mx2;
		var my1, my2;
		var xc, yc;

		if( p2.y == p1.y ) {
			m2 = -(p3.x - p2.x) / (p3.y - p2.y);
			mx2 = (p2.x + p3.x) * 0.5;
			my2 = (p2.y + p3.y) * 0.5;
			//Calculate CircumCircle center (xc,yc)
			xc = (p2.x + p1.x) * 0.5;
			yc = m2 * (xc - mx2) + my2;
		} else if( p3.y == p2.y ) {
			m1 = -(p2.x - p1.x) / (p2.y - p1.y);
			mx1 = (p1.x + p2.x) * 0.5;
			my1 = (p1.y + p2.y) * 0.5;
			//Calculate CircumCircle center (xc,yc)
			xc = (p3.x + p2.x) >> 1;
			yc = m1 * (xc - mx1) + my1;
		} else {
			m1 = -(p2.x - p1.x) / (p2.y - p1.y);
			m2 = -(p3.x - p2.x) / (p3.y - p2.y);
			mx1 = (p1.x + p2.x) * 0.5;
			mx2 = (p2.x + p3.x) * 0.5;
			my1 = (p1.y + p2.y) * 0.5;
			my2 = (p2.y + p3.y) * 0.5;
			//Calculate CircumCircle center (xc,yc)
			xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
			yc = m1 * (xc - mx1) + my1;
		}
		var dx = p2.x - xc;
		var dy = p2.y - yc;
		var rsqr = dx * dx + dy * dy;
		dx = p.x - xc;
		dy = p.y - yc;
		var drsqr = dx * dx + dy * dy;
		return ( drsqr <= rsqr );
	}

}
