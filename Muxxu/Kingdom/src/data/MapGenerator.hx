package data;
import data.Delaunay;

class Place {
	public var id : Int;
	public var x : Int;
	public var y : Int;
	public var links : List<Place>;
	public var city : Bool;
	public var group : Array<Place>;
	public var tag : Float;
	public function new(id,x,y) {
		this.id = id;
		this.x = x;
		this.y = y;
		links = new List();
	}
	public inline function dist( p : Place ) {
		var dx = p.x - x;
		var dy = p.y - y;
		return dx*dx + dy*dy;
	}
	public function toString() {
		return "#"+id+"("+x+","+y+")";
	}
}

class MapGenerator {

	public var width : Int;
	public var height : Int;
	public var places : List<Place>;

	public function new() {
	}

	inline function DIST(x) return x * x

	function distance( p : Place, p1 : Place, p2 : Place ) {
		var dx = p2.x - p1.x;
		var dy = p2.y - p1.y;
		var r = ((p.x - p1.x) * dx + (p.y - p1.y) * dy) / (dx * dx + dy * dy);
		if( r < 0 || r > 1 ) return 1000000.;
		var px = p.x - (p1.x + dx * r);
		var py = p.y - (p1.y + dy * r);
		return px * px + py * py;
	}

	public function generate(w,h) {
		width = w;
		height = h;
		places = new List();
		for( p in 0...Std.int(width * height / 30) ) {
			var x = Std.random(width-10) + 5;
			var y = Std.random(height-10) + 5;
			places.push(new Place(0,x,y));
		}
		// remove points which are too much near
		for( p1 in places )
			for( p2 in places )
				if( p1 != p2 && p1.dist(p2) < DIST(10) ) {
					places.remove(p1);
					break;
				}
		// triangulate
		var aplaces = Lambda.array(places);
		var triangles = new Delaunay().make(Lambda.array(places.map(function(p) return new DelPoint(p.x,p.y))));
		for( t in triangles ) {
			var p1 = aplaces[t.p1.id];
			var p2 = aplaces[t.p2.id];
			var p3 = aplaces[t.p3.id];
			p2.links.remove(p1);
			p3.links.remove(p2);
			p1.links.remove(p3);
			p1.links.add(p2);
			p2.links.add(p3);
			p3.links.add(p1);
		}
		// remove long edges
		for( p in places )
			for( l in p.links ) {
				var dx = l.x - p.x;
				var dy = l.y - p.y;
				if( dx*dx > DIST(30) || dy*dy > DIST(24) )
					p.links.remove(l);
			}
		// make mirror edges
		for( p in places )
			for( l in p.links ) {
				l.links.remove(p);
				l.links.add(p);
			}
		// remove edges too much near from some point
		for( p in places ) {
			for( p1 in places ) {
				if( p == p1 ) continue;
				for( p2 in p1.links ) {
					if( p == p2 || p1.id > p2.id ) continue;
					if( distance(p,p1,p2) < DIST(8) ) {
						p1.links.remove(p2);
						p2.links.remove(p1);
					}
				}
			}
		}
		// remove long edges
		for( p in places ) {
			if( p.links.length <= 2 )
				continue;
			for( p2 in p.links ) {
				if( p == p2 || p2.links.length <= 2 )
					continue;
				if( p.dist(p2) > DIST(30) && Std.random(4) > 0 ) {
					p.links.remove(p2);
					p2.links.remove(p);
					if( p.links.length <= 2 )
						break;
				}
			}
		}
		// remove extra edges
		for( p in places ) {
			while( p.links.length > 4 ) {
				var found = null;
				for( p2 in p.links )
					if( p2.links.length >= 2 ) {
						found = p2;
						break;
					}
				if( found == null )
					found = p.links.first();
				found.links.remove(p);
				p.links.remove(found);
			}
		}

		// create groups
		var groups = new Array();
		for( p in places )
			if( p.group == null ) {
				var g = new Array();
				groups.push(g);
				buildGroupRec(p,g);
			}

		// keep only main groups
		groups.sort(function(g1,g2) return g2.length - g1.length);
		groups.shift();
		for( g in groups )
			for( p in g )
				places.remove(p);

		// choose cities and give ids
		var id = 0;
		for( p in places ) {
			p.id = id++;
			if( p.links.length >= 3 ) {
				var ok = true;
				for( n in p.links ) {
					if( n.city ) {
						ok = false;
						break;
					}
					for( n2 in n.links )
						if( n2.city && Std.random(4) != 0 ) {
							ok = false;
							break;
						}
				}
				if( ok )
					p.city = true;
			}
		}
	}

	function buildGroupRec( p : Place, g : Array<Place> ) {
		if( p.group != null )
			return;
		p.group = g;
		g.push(p);
		for( l in p.links )
			buildGroupRec(l,g);
	}

	function nbits( v ) {
		var n = 0;
		v--;
		while( v > 0 ) {
			n++;
			v >>= 1;
		}
		return n;
	}

	public function serialize() {
		var c = new mt.BitCodec(null,true);
		var xbits = nbits(width);
		var ybits = nbits(height);
		var idbits = nbits(places.length);
		c.write(16,width);
		c.write(16,height);
		c.write(16,places.length);
		for( p in places ) {
			c.write(xbits,p.x);
			c.write(ybits,p.y);
			c.write(1,p.city ? 1 : 0);
		}
		for( p in places ) {
			c.write(2,p.links.length - 1);
			for( p in p.links )
				c.write(idbits,p.id);
		}
		return c.toString() + c.crcStr();
	}

	public function unserialize( str ) {
		var c = new mt.BitCodec(str,true);
		width = c.read(16);
		height = c.read(16);
		var nplaces = c.read(16);
		var xbits = nbits(width);
		var ybits = nbits(height);
		var idbits = nbits(nplaces);
		var places = new Array();
		for( i in 0...nplaces ) {
			var x = c.read(xbits);
			var y = c.read(ybits);
			var p = new Place(i,x,y);
			p.city = c.read(1) == 1;
			places.push(p);
		}
		for( p in places )
			for( i in 0...c.read(2) + 1 )
				p.links.push(places[c.read(idbits)]);
		this.places = Lambda.list(places);
		var crc = c.crcStr();
		if( crc != str.substr(str.length - crc.length, crc.length) )
			throw "Invalid CRC";
	}

}