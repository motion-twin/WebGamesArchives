import Common;

class CraftEngine {

	static inline var B = 4;
	static inline var SIZE = 1 << B;
	static inline var MASK = SIZE - 1;
	static inline var Z = 0;
	static inline var X = B;
	static inline var Y = B + B;
	static inline var DZ = 1 << Z;
	static inline var DX = 1 << X;
	static inline var DY = 1 << Y;
	
	var blocks : Array<BlockKind>;
	var width : Int;
	var height : Int;
	var curZ : Int;
	var maxZ : Int;
	var matched : Array<Bool>;
	var constraint : { x : Int, y : Int, w : Int, h : Int };
	var blockCounts : IntHash<Int>;
	
	public function new() {
		clear();
	}
	
	static inline function addr(x, y, z) {
		return (x << X) | (y << Y) | (z << Z);
	}
	
	public function clear() {
		blocks = [];
		blockCounts = new IntHash();
		width = 0;
		height = 0;
		maxZ = 0;
	}
	
	public function remove( x, y, z ) {
		var a = addr(x, y, z);
		var b = blocks[a];
		if( b == null )
			return;
		var index = Type.enumIndex(b);
		var n = blockCounts.get(index) - 1;
		if( n == 0 ) blockCounts.remove(index) else blockCounts.set(index, n);
		blocks[a] = null;
	}
	
	public function getBlocks( pos ) {
		var b = [];
		for( k in blockCounts.keys() )
			b.push( { b : Block.all[k], n : blockCounts.get(k), pos : [] } );
		if( pos )
			for( b in b ) {
				var k = b.b.k;
				for( i in 0...blocks.length )
					if( blocks[i] == k )
						b.pos.push( { x : (i >> X) & MASK, y : (i >> Y) & MASK, z : (i >> Z) & MASK } );
			}
		return b;
	}
	
	function count( b : BlockKind ) : Int {
		return blockCounts.get(Type.enumIndex(b));
	}
	
	public function add( b : Block, x : Int, y : Int, z : Int ) {
		if( b == null ) {
			blocks[addr(x, y, z)] = null;
			return;
		}
		b = b.getMain();
		blocks[addr(x, y, z)] = b.k;
		if( width <= x ) width = x + 1;
		if( height <= y ) height = y + 1;
		if( z >= maxZ ) maxZ = z + 1;
		var c = blockCounts.get(b.index);
		if( c == null ) c = 0;
		blockCounts.set(b.index, c + 1);
	}
	
	inline function get(x, y) {
		return blocks[addr(x, y, curZ)];
	}
	
	function mark(x, y) {
		matched[addr(x, y, curZ)] = true;
	}
	
	function match(x, y, b) {
		if( get(x, y) == b ) {
			mark(x, y);
			return true;
		}
		return false;
	}
	
	function matchRect( x, y, w, h, b ) {
		for( dx in 0...w )
			for( dy in 0...h )
				if( get(x + dx, y + dy) != b )
					return false;
		for( dx in 0...w )
			for( dy in 0...h )
				mark(x + dx, y + dy);
		return true;
	}
	
	function checkSchema( s : CraftSchema ) {
		/*
			all structures are centered around the first defined constraint or the last base
			in case of even size, we can check for up to 4 symmetries
		*/
		switch( s ) {
		case CSSingle(b):
			if( constraint == null ) {
				for( x in 0...width )
					for( y in 0...height )
						if( match(x, y, b) ) {
							constraint = { x : x, y : y, w : 1, h : 1 };
							return true;
						}
			} else {
				var px = [constraint.x + (constraint.w >> 1)];
				var py = [constraint.y + (constraint.h >> 1)];
				if( constraint.w & 1 == 0 )
					px.push(px[0] - 1);
				if( constraint.h & 1 == 0 )
					py.push(py[0] - 1);
				for( x in px )
					for( y in py )
						if( match(x, y, b) )
							return true;
			}
		case CSBase(b, size):
			if( constraint == null ) {
				for( x in 0...width-size+1 )
					for( y in 0...height - size+1 ) {
						if( get(x, y) != b ) continue;
						if( matchRect(x, y, size, size, b) ) {
							constraint = { x : x, y : y, w : size, h : size };
							return true;
						}
					}
			} else {
				var dx = constraint.w - size;
				var dy = constraint.h - size;
				// do not support asymetry
				if( dx & 1 == 1 || dy & 1 == 1  ) return false;
				dx >>= 1;
				dy >>= 1;
				if( constraint.x + dx < 0 || constraint.y + dy < 0 )
					return false;
				if( matchRect(constraint.x + dx, constraint.y + dy, size, size, b) ) {
					constraint.x += dx;
					constraint.y += dy;
					constraint.w = constraint.h = size;
					return true;
				}
			}
		case CSLine(b, len):
			if( constraint == null ) {
				for( x in 0...width )
					for( y in 0...height ) {
						if( get(x, y) != b ) continue;
						if( x <= width - len && matchRect(x, y, len, 1, b) ) {
							constraint = { x : x, y : y, w : len, h : 1 };
							return true;
						}
						if( y <= height - len && matchRect(x, y, 1, len, b) ) {
							constraint = { x : x, y : y, w : 1, h : len };
							return true;
						}
					}
			} else {
				if( constraint.w == len ) {
					var py = [constraint.y + (constraint.h >> 1)];
					if( constraint.h & 1 == 0 ) py.push(py[0] - 1);
					for( y in py )
						if( matchRect(constraint.x, y, len, 1, b) )
							return true;
				}
				if( constraint.h == len ) {
					var px = [constraint.x + (constraint.w >> 1)];
					if( constraint.w & 1 == 0 ) px.push(px[0] - 1);
					for( x in px )
						if( matchRect(x, constraint.y, 1, len, b) )
							return true;
				}
			}
		}
		return false;
	}
	
	static var RINFOS = [];
	public static function getRuleInfos( r : CraftRule ) {
		var i = RINFOS[r.id];
		if( i != null )
			return i;
		i = {
			z : r.schema.length,
			blocks : [],
		};
		RINFOS[r.id] = i;
		function add(b, n) {
			for( c in i.blocks )
				if( c.b == b ) {
					c.n += n;
					return;
				}
			i.blocks.push( { b : b, n : n } );
		}
		for( s in r.schema )
			switch( s ) {
			case CSSingle(b): add(b, 1);
			case CSBase(b, s): add(b, s * s);
			case CSLine(b, l): add(b, l);
			}
		return i;
	}
	
	public function check( r : CraftRule ) {
		var infos = getRuleInfos(r);
		if( infos.z > maxZ )
			return false;
		for( b in infos.blocks )
			if( count(b.b) != b.n )
				return false;
		constraint = null;
		matched = [];
		curZ = 0;
		for( s in r.schema ) {
			if( !checkSchema(s) )
				return false;
			curZ++;
		}
		for( a in 0...blocks.length )
			if( blocks[a] != null && !matched[a] )
				return false;
		return true;
	}
	
	public function checkAll() {
		for( r in Data.CRAFT )
			if( check(r) )
				return r;
		return null;
	}
	
}