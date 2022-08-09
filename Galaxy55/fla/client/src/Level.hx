import Common;

class LevelCell {
	
	public var posX : Int;
	public var posY : Int;
	public var posZ : Int;
	public var collideEmpty : Bool;
	
	public var x : Int;
	public var y : Int;
	public var zMax : Int;
	public var t : flash.utils.ByteArray;
	public var tags : flash.utils.ByteArray;
	public var specials : flash.utils.ByteArray;
	public var light : flash.utils.ByteArray;
	public var loading : Bool;
	
	public function new(x, y) {
		this.x = x;
		this.y = y;
		collideEmpty = true;
	}
	
	public function init(t) {
		this.t = t;
		tags = null;
		t.endian = flash.utils.Endian.LITTLE_ENDIAN;
	}

}

class Level {

	public var size(default, null) : Int;
	public var cells : Array<Array<LevelCell>>;
	public var extra : LevelCell;
	var bl : flash.Vector<Block>;
	public var collideEmpty : Bool;

	public function new(size) {
		this.size = size;
		collideEmpty = true;
		cells = new Array();
		bl = Block.all;
		for( x in 0...size ) {
			cells[x] = [];
			for( y in 0...size )
				cells[x][y] = new LevelCell(x, y);
		}
		extra = new LevelCell(0, 0);
	}

	public inline function has(x, y, z) {
		return getInt(x,y,z) > 0;
	}
	
	public function collide(x:Float, y:Float, z:Float) {
		var ix = Math.floor(x), iy = Math.floor(y), iz = Std.int(z);
		var b = getInt(ix, iy, iz);
		if( b == -1 ) return true;
		if( b == 0 ) return false;
		var block = bl[b];
		if( !block.collide )
			return false;
		if( block.size == null )
			return true;
		z -= iz;
		return z >= block.size.z1 && z < block.size.z2;
	}
	
	public function get(x, y, z) {
		var i = getInt(x, y, z);
		return i <= 0 ? null : bl[i];
	}

	function real(v) {
		v %= size << Const.BITS;
		if( v < 0 ) v += size << Const.BITS;
		return v;
	}
	
	function getInt(x, y, z) : Int {
		var c;
		if( z & Const.ZMASK != z ) {
			x = real(x - extra.posX);
			y = real(y - extra.posY);
			z -= extra.posZ;
			if( z & Const.ZMASK != z ) return 0;
			c = extra;
		} else {
			x = real(x);
			y = real(y);
			c = cells[x >> Const.BITS][y >> Const.BITS];
		}
		if( c.t == null )
			return collideEmpty && c.collideEmpty ? -1 : 0;
		c.t.position = addr(x&Const.MASK,y&Const.MASK,z) << 1;
		return c.t.readUnsignedShort();
	}
	
	public function getLightAt(x:Float, y:Float, z:Float, max) : Float {
		var ix = Math.floor(x), iy = Math.floor(y), iz = Std.int(z);
		var rx = real(ix), ry = real(iy);
		var c;
		if( iz & Const.ZMASK == iz )
			c = cells[rx >> Const.BITS][ry >> Const.BITS];
		else {
			x -= extra.posX;
			y -= extra.posY;
			z -= extra.posZ;
			ix -= extra.posX;
			iy -= extra.posY;
			iz -= extra.posZ;
			rx = real(ix);
			ry = real(iy);
			c = extra;
		}
		if( c.light == null ) return max;
		if( iz & Const.ZMASK != iz || iz > c.zMax ) return max;
		var tag = c.light[addr(rx & Const.MASK, ry & Const.MASK, iz)];
		var l = (tag >> r3d.Builder.TAGBITS) / r3d.Builder.LBASE;
		// inside a block
		if( tag & r3d.Builder.TAGMASK != 0 && max >= 0 ) {
			// look at nearest face
			var dx, distX = x - ix;
			if( distX < 0.5 )
				dx = -1;
			else {
				distX = 1 - distX;
				dx = 1;
			}
			var dy, distY = y - iy;
			if( distY < 0.5 )
				dy = -1;
			else {
				distY = 1 - distY;
				dy = 1;
			}
			var dz, distZ = z - iz;
			var block = get(ix, iy, iz);
			var zSize = block == null ? 1.0 : block.getHeight();
			if( distZ < zSize * 0.5 )
				dz = -1;
			else {
				distZ = zSize - distZ;
				dz = 1;
			}
			var x2 = ix, y2 = iy, z2 = iz;
			if( distX < distY ) {
				if( distX < distZ )
					x2 += dx;
				else
					z2 += dz;
			} else if( distY < distZ )
				y2 += dy;
			else
				z2 += dz;
			var l2 = getLightAt(x2, y2, z2, -1);
			if( l2 > l )
				l = l2;
		}
		return l;
	}
	
	public function set(x, y, z, b:Block) {
		var c;
		if( z & Const.MASK == z )
			c = cells[x >> Const.BITS][y >> Const.BITS];
		else {
			x = real(x - extra.posX);
			y = real(y - extra.posY);
			z -= extra.posZ;
			c = extra;
		}
		// not yet loaded
		if( c.t == null ) return;
		x &= Const.MASK;
		y &= Const.MASK;
		var a = addr(x, y, z);
		c.t.position = a << 1;
		c.t.writeShort( b == null ? 0 : b.index );
		if( c.tags != null ) {
			var old = c.tags[a] & r3d.Builder.TAGMASK;
			var tag = b == null ? 0 : b.renderTag;
			c.tags[a] = tag;
			if( b != null && z > c.zMax )
				c.zMax = z;
			if( b != null && b.special != null ) {
				c.specials.writeByte(x);
				c.specials.writeByte(y);
				c.specials.writeByte(z);
				c.specials.writeByte(Type.enumIndex(b.special));
			} else if( b == null ) {
				var i = 0;
				var max : Int = c.specials.length;
				while( i < max ) {
					if( c.specials[i] == x && c.specials[i + 1] == y && c.specials[i + 2] == z ) {
						c.specials.position = i;
						c.specials.writeBytes(c.specials, i + 4);
						c.specials.length = max - 4;
						break;
					}
					i += 4;
				}
			}
		}
	}
		
	public function add(cx, cy, t) {
		cells[cx][cy].init(t);
	}
	
	inline function addr(x,y,z) {
		return (x<<Const.X)|(y<<Const.Y)|(z<<Const.Z);
	}

	
	// almost flat
	function freePlace(x, y, z) {
		var count = 0;
		for( dx in -1...2 )
			for( dy in -1...2 )
				if( has(x + dx, y + dy, z) )
					count++;
		z--;
		for( dx in -1...2 )
			for( dy in -1...2 )
				if( !has(x + dx, y + dy, z) )
					count++;
		return count < 3;
	}

	public function getStartPlace( planet : PlanetInfos ) {
		var binf = Data.getBiome(planet.biome);
		var water = planet.waterLevel, soil = Block.get(binf.soils[1]);
		var x, y, z, ntry = 10000;
		var through = [];
		for( b in binf.startThrough )
			through[Block.get(b).index] = true;
		while( --ntry > 0 ) {
			x = Std.random(Const.SIZE * size - 2) + 1;
			y = Std.random(Const.SIZE * size - 2) + 1;
			z = Const.ZSIZE - 1;
			while( z > water ) {
				var b = get(x, y, z);
				if( b != null && !through[b.index] )
					break;
				z--;
			}
			if( z <= water )
				continue;
			if( !get(x, y, z).isSame(soil) )
				continue;
			z++;
			if( !freePlace(x, y, z) )
				continue;
			return { x : x, y : y, z : z };
		}
		return null;
	}
	
}