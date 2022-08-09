package mt.m3d;
import mt.m3d.T;

class Polygon {

	public var points : Array<Vector>;
	public var normals : Array<Vector>;
	public var tangents : Array<Vector>;
	public var tcoords : Array<UV>;
	public var idx : Array<UInt>;
	
	public var ibuf : IBuf;
	public var vbuf : VBuf;
	
	public function new( points, ?idx ) {
		this.points = points;
		if( idx == null ) {
			idx = new Array<UInt>();
			for( i in 0...points.length )
				idx[i] = i;
		}
		this.idx = idx;
	}
	
	public function dispose() {
		if( ibuf != null ) { ibuf.dispose(); ibuf = null; }
		if( vbuf != null ) { vbuf.dispose(); vbuf = null; }
	}
	
	public function alloc( c : Context ) {
		dispose();
		ibuf = c.createIndexBuffer(idx.length);
		ibuf.uploadFromVector(flash.Vector.ofArray(idx), 0, idx.length);
		var size = 3;
		if( normals != null )
			size += 3;
		if( tcoords != null )
			size += 2;
		vbuf = c.createVertexBuffer(points.length, size);
		var buf = new flash.Vector<Float>();
		var i = 0;
		for( k in 0...points.length ) {
			var p = points[k];
			buf[i++] = p.x;
			buf[i++] = p.y;
			buf[i++] = p.z;
			if( normals != null ) {
				var n = normals[k];
				buf[i++] = n.x;
				buf[i++] = n.y;
				buf[i++] = n.z;
			}
			if( tangents != null ) {
				var t = tangents[k];
				buf[i++] = t.x;
				buf[i++] = t.y;
				buf[i++] = t.z;
			}
			if( tcoords != null ) {
				var t = tcoords[k];
				buf[i++] = t.u;
				buf[i++] = t.v;
			}
		}
		vbuf.uploadFromVector(buf, 0, points.length);
	}
	
	public function unindex() {
		if( points.length != idx.length ) {
			var p = [], id : Array<UInt> = [];
			for( i in idx ) {
				id.push(p.length);
				p.push(points[i]);
			}
			points = p;
			idx = id;
		}
	}

	public function translate( dx, dy, dz ) {
		for( p in points ) {
			p.x += dx;
			p.y += dy;
			p.z += dz;
		}
	}

	public function scale( s : Float ) {
		for( p in points ) {
			p.x *= s;
			p.y *= s;
			p.z *= s;
		}
	}
	
	public function addNormals() {
		// make per-point normal
		normals = new Array();
		for( i in 0...points.length )
			normals[i] = new Vector();
		var pos = 0;
		for( i in 0...triCount() ) {
			var i0 = idx[pos++], i1 = idx[pos++], i2 = idx[pos++];
			var p0 = points[i0];
			var p1 = points[i1];
			var p2 = points[i2];
			// this is the per-face normal
			var n = p1.sub(p0).cross(p2.sub(p0));
			// add it to each point
			normals[i0].x += n.x; normals[i0].y += n.y; normals[i0].z += n.z;
			normals[i1].x += n.x; normals[i1].y += n.y; normals[i1].z += n.z;
			normals[i2].x += n.x; normals[i2].y += n.y; normals[i2].z += n.z;
		}
		// normalize all normals
		for( n in normals )
			n.normalize();
	}

	public function addTCoords() {
		throw "Not implemented for this polygon";
	}
	
	public function triCount() {
		return Std.int(idx.length / 3);
	}

}
