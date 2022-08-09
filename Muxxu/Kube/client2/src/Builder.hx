import Common;
import Buffers;

class Builder {

	public static inline var CELL = 4;
	public static inline var CSIZE = 1<<CELL;

	static inline var MAX_TRI_SIZE = CSIZE * CSIZE * Const.ZSIZE * 6 * 2 * Shaders.DefShader.STRIDE * 4;

	static inline var MAX_SPECIALS = (CSIZE * CSIZE * Const.ZSIZE * 9) >> 4;
	
	static inline var TE = 0.999;

	static inline var Z = 0;
	static inline var X = Const.ZBITS;
	static inline var Y = Const.ZBITS + CELL + 2;
	static inline var DZ = 1 << Z;
	static inline var DX = 1 << X;
	static inline var DY = 1 << Y;

	static inline var LMAX = 10;
	static inline var LDELTA = CSIZE - LMAX;

	static inline var TAGBITS = 4;
	public static inline var TAGMASK = (1 << TAGBITS) - 1;

	static inline var TAGFULL = Type.enumIndex(BlockType.BTFull);

	static inline var MSIZE = 1024;

	public var cells : Array<CellBuffer>;
	public var cellStride : Int;
	public var bmanager : BufferManager;

	var kube : Kube;

	var currentTags : Level.LevelCell;

	var manager : VirtualBuffer.Manager;
	var tags : VirtualBuffer.VirtualBuffer0;
	var blocks : VirtualBuffer;
	var levelTags : VirtualBuffer;
	var blockInfos : BlockBuffer;
	var models : VirtualBuffer;
	var specials : VirtualBuffer;
	var tmp : VirtualBuffer;

	var deltaX : Int;
	var deltaY : Int;
	var bufferPos : Int;

	public function new(kube) {

		this.kube = kube;

		cells = [];
		cellStride = kube.planetSize >> CELL;
		for( y in 0...cellStride )
			for( x in 0...cellStride )
				cells.push(new CellBuffer(x, y));

		manager = new VirtualBuffer.Manager();
		tags = manager.allocFirst( CSIZE * CSIZE * Const.ZSIZE * 12 );
		blocks = manager.alloc( CSIZE * CSIZE * Const.ZSIZE * 2 );
		models = manager.alloc( MSIZE * 4 );
		specials = manager.alloc( MAX_SPECIALS * 4 );
		levelTags = manager.alloc( Const.TSIZE );
		blockInfos = BlockBuffer.alloc(manager, kube.level.blocks.length);
		tmp = manager.alloc(MAX_TRI_SIZE >> 1);
	}

	public function init(ctx) {
		bmanager = new BufferManager(ctx);
		bmanager.garbage = garbage;

		manager.select();
		var modelPos = 0;
		for( b in kube.level.blocks ) {
			if( b == null ) continue;
			function fshade(s) return Math.sqrt(s);
			var i = blockInfos.get(b.index);
			i.tag = Type.enumIndex(b.type);
			i.special = Type.enumIndex(b.special);
			i.shadeDown = fshade(b.shadeDown);
			i.shadeUp = fshade(b.shadeUp);
			i.shadeX = fshade(b.shadeX);
			i.shadeY = fshade(b.shadeY);
			i.tlr = b.tlr.index;
			i.tu = b.tu.index;
			i.td = b.td.index;
			if( b.model != null ) {
				i.modelPos = modelPos;
				i.modelSize = Std.int(b.model.length / Shaders.DefShader.STRIDE);
				for( v in b.model )
					models.setFloat(modelPos++, v);
			}
		}
		if( modelPos > MSIZE )
			throw "overflow " + modelPos;
	}
	
	function sortByFrame(c1:CellBuffer, c2:CellBuffer) {
		return c1.frame - c2.frame;
	}
	
	function garbage() {
		var alloc = [];
		for( c in cells )
			if( c.buffers.length > 0 ) {
				if( c.dirty )
					c.dispose();
				else
					alloc.push(c);
			}
		if( alloc.length == 0 )
			return;
		alloc.sort(sortByFrame);
		var f0 = alloc[0].frame;
		for( c in alloc )
			if( c.frame == f0 )
				c.dispose();
	}

	function computeTags( c : Level.LevelCell ) {
		var tmp = tmp;
		var blockInfos = blockInfos;
		var levelTags = levelTags;
		var specials = new flash.utils.ByteArray();
		manager.copy(c.t, 0, tmp, Const.TSIZE * 2);
		
		var i = 0;
		for( y in 0...Const.SIZE )
			for( x in 0...Const.SIZE )
				for( z in 0...Const.ZSIZE ) {
					var bt = tmp.getUI16(i);
					var b = blockInfos.get(bt);
					levelTags.setByte(i, b.tag);
					if( b.special > 0 ) {
						specials.writeByte(x);
						specials.writeByte(y);
						specials.writeByte(z);
						specials.writeByte(b.special);
					}
					i++;
				}

		c.tags = new flash.utils.ByteArray();
		c.tags.writeBytes(manager.bytes, levelTags.getPos(), Const.TSIZE);
		c.specials = specials;
		currentTags = c;
	}

	inline function addr(x, y, z) {
		return (x << X) | (y << Y) | (z << Z);
	}

	public inline function getCell(x, y) {
		return cells[x + y * cellStride];
	}

	public function updateKube(x, y, z,b:Level.Block) {
		var cx = x >> CELL;
		var cy = y >> CELL;
		getCell(cx, cy).dirty = true;
		
		var lchange = LMAX; // TODO : calculate light change power

		var rx = x - (cx << CELL);
		var ry = y - (cy << CELL);
		if( rx == 0 || rx < lchange )
			getCell(creal(cx - 1), cy).dirty = true;
		if( ry == 0 || ry < lchange )
			getCell(cx, creal(cy - 1)).dirty = true;
		if( rx == CSIZE - 1 || CSIZE-1-rx < lchange )
			getCell(creal(cx + 1), cy).dirty = true;
		if( ry == CSIZE - 1 || CSIZE-1-ry < lchange )
			getCell(cx, creal(cy + 1)).dirty = true;
		if( lchange > 0 ) {
			if( rx + ry + 1 < lchange )
				getCell(creal(cx - 1), creal(cy - 1)).dirty = true;
			if( rx + (CSIZE-ry) < lchange )
				getCell(creal(cx - 1), creal(cy + 1)).dirty = true;
			if( (CSIZE-rx) + ry < lchange )
				getCell(creal(cx + 1), creal(cy - 1)).dirty = true;
			if( (CSIZE-rx) + (CSIZE-ry) - 1 < lchange )
				getCell(creal(cx + 1), creal(cy + 1)).dirty = true;
		}
	
		var cx = x >> Const.BITS;
		var cy = y >> Const.BITS;
		if( currentTags != null && currentTags.x == cx && currentTags.y == cy )
			currentTags = null;
	}
	
	function relight() {
		var outPos = tmp.getPos();

		var lmax = kube.sunPower << TAGBITS;
		var light = (kube.sunPower - 1) << TAGBITS;
		
		// fill sun light
		for( y in LDELTA...CSIZE*3-LDELTA )
			for( x in LDELTA...CSIZE*3-LDELTA ) {
				var z = Const.ZSIZE - 1;
				var addr = addr(x,y,z);
				while( true ) {
					var t = flash.Memory.getByte(addr) & TAGMASK;
					if( t != 0 ) {
						if( t != TAGFULL ) {
							flash.Memory.setByte(addr, t | light);
							flash.Memory.setByte(outPos++, x);
							flash.Memory.setByte(outPos++, y);
							flash.Memory.setByte(outPos++, z);
						}
						break;
					}
					flash.Memory.setByte(addr, lmax);
					// propagate our light to previous blocks
					if( x > LDELTA ) {
						var bt = flash.Memory.getByte(addr - DX);
						if( bt < TAGFULL ) {
							flash.Memory.setByte(addr - DX, bt | light);
							flash.Memory.setByte(outPos++, x - 1);
							flash.Memory.setByte(outPos++, y);
							flash.Memory.setByte(outPos++, z);
						}
					}
					if( y > LDELTA ) {
						var bt = flash.Memory.getByte(addr - DY);
						if( bt < TAGFULL ) {
							flash.Memory.setByte(addr - DY, bt | light);
							flash.Memory.setByte(outPos++, x);
							flash.Memory.setByte(outPos++, y - 1);
							flash.Memory.setByte(outPos++, z);
						}
					}
					z--;
					addr -= DZ;
				}
				while( z > 0 ) {
					// propagate previous blocks light to current block
					var t = flash.Memory.getByte(addr) & TAGMASK;
					if( t != TAGFULL && (flash.Memory.getByte(addr - DX) == lmax || flash.Memory.getByte(addr - DY) == lmax) ) {
						flash.Memory.setByte(addr, t | light);
						flash.Memory.setByte(outPos++, x);
						flash.Memory.setByte(outPos++, y);
						flash.Memory.setByte(outPos++, z);
					}
					z--;
					addr -= DZ;
				}
			}

		light -= 1 << TAGBITS;
		processLight(kube.sunPower - 2, outPos);
		
		// process specials
		var pos = 0;
		var light = LMAX + 3;
		outPos = tmp.getPos();
		while( true ) {
			var x = specials.getByte(pos++);
			if( x == 0xFF ) break;
			var y = specials.getByte(pos++);
			var z = specials.getByte(pos++);
			var b = specials.getByte(pos++);
			switch( b ) {
			case Type.enumIndex(BSLight):
				var addr = addr(x, y, z);
				flash.Memory.setByte(addr, (flash.Memory.getByte(addr)&TAGMASK) | (light << TAGBITS));
				flash.Memory.setByte(outPos++, x);
				flash.Memory.setByte(outPos++, y);
				flash.Memory.setByte(outPos++, z);
			default:
			}
		}
		processLight(light - 1, outPos);
	}
	
	function processLight( light : Int, outPos : Int ) {
	
		light <<= TAGBITS;
	
		var curPos = tmp.getPos();
		var t;

		while( light > 0 ) {
			var endPos = outPos;
			while( curPos < endPos ) {
				var x = flash.Memory.getByte(curPos++);
				var y = flash.Memory.getByte(curPos++);
				var z = flash.Memory.getByte(curPos++);
				var addr = this.addr(x, y, z);

				if( x > LDELTA && (t=flash.Memory.getByte(addr - DX)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr - DX, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x - 1);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z);
				}
				if( x < CSIZE*3-LDELTA-1 && (t=flash.Memory.getByte(addr + DX)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr + DX, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x + 1);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z);
				}
				if( y > LDELTA && (t=flash.Memory.getByte(addr - DY)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr - DY, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y - 1);
					flash.Memory.setByte(outPos++, z);
				}
				if( y < CSIZE*3-LDELTA-1 && (t=flash.Memory.getByte(addr + DY)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr + DY, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y + 1);
					flash.Memory.setByte(outPos++, z);
				}
				if( z > 0 && (t=flash.Memory.getByte(addr - DZ)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr - DZ, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z - 1);
				}
				if( z < Const.ZSIZE-1 && (t=flash.Memory.getByte(addr + DZ)) < light && t&TAGMASK != TAGFULL ) {
					flash.Memory.setByte(addr + DZ, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z + 1);
				}
			}
			light -= 1 << TAGBITS;
		}
	}


	public inline function addVertex(t, shade, x, y, z, tu, tv) {
		var tu = ((t & 15) + tu * TE) * (1 / 16);
		var tv = ((t >> 4) + tv * TE) * (1 / 16);
		flash.Memory.setFloat(bufferPos, x + deltaX);	bufferPos += 4;
		flash.Memory.setFloat(bufferPos, y + deltaY);	bufferPos += 4;
		flash.Memory.setFloat(bufferPos, z);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, tu);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, tv);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, shade);		bufferPos += 4;
	}

	inline function addTri( t, lum, lum2, lum3, sx, sy, sz, dx1, dy1, dz1, dx2, dy2, dz2, tu, tv, tu1, tv1, tu2, tv2 ) {
		addVertex(t, lum, sx, sy, sz, tu, tv);
		addVertex(t, lum2, sx + dx1, sy + dy1, sz + dz1, tu1, tv1);
		addVertex(t, lum3, sx + dx2, sy + dy2, sz + dz2, tu2, tv2);
	}

	inline function addQuad( addr : Int, t : Int, shade : Float, sx, sy, sz, dx, dy, dz, side : Bool ) {
		var delta = (1 - dx) * DX * (side?1:-1) + (1 - dy) * DY * (side?1:-1) + (1 - dz) * DZ * (side?1:-1);
		var ldx = (1 - dx) * DY * (side?-1:1) + (1 - dy) * DX * (side?1:-1) + (1 - dz) * DY;
		var ldy = -(1 - dx) * DZ + -(1 - dy) * DZ - (1 - dz) * DX;
		var light = getLight(addr + delta);

		var lightL = getLight(addr + delta - ldx);
		var lightR = getLight(addr + delta + ldx);
		var lightT = getLight(addr + delta - ldy);
		var lightB = getLight(addr + delta + ldy);
		var lightTL = getLight(addr + delta - ldx - ldy);
		var lightTR = getLight(addr + delta + ldx - ldy);
		var lightBL = getLight(addr + delta - ldx + ldy);
		var lightBR = getLight(addr + delta + ldx + ldy);

		var lumTL = (light + lightL + lightT + lightTL) * shade * (0.25 / LMAX);
		var lumTR = (light + lightR + lightT + lightTR) * shade * (0.25 / LMAX);
		var lumBL = (light + lightL + lightB + lightBL) * shade * (0.25 / LMAX);
		var lumBR = (light + lightR + lightB + lightBR) * shade * (0.25 / LMAX);

		if( dx == 0 ) {
			if( side ) {
				addTri(t, lumBL, lumTL, lumBR, sx, sy + dy, sz, 0, 0, dz, 0, -dy, 0, 0, 1, 0, 0, 1, 1);
				addTri(t, lumTR, lumBR, lumTL, sx, sy, sz + dz, 0, 0, -dz, 0, dy, 0, 1, 0, 1, 1, 0, 0);
			} else {
				addTri(t, lumBL, lumTL, lumBR, sx, sy, sz, 0, 0, dz, 0, dy, 0, 0, 1, 0, 0, 1, 1);
				addTri(t, lumTR, lumBR, lumTL, sx, sy + dy, sz + dz, 0, 0, -dz, 0, -dy, 0, 1, 0, 1, 1, 0, 0);
			}
		} else if( dy == 0 ) {
			if( side ) {
				addTri(t, lumBL, lumTL, lumBR, sx, sy, sz, 0, 0, dz, dx, 0, 0, 0, 1, 0, 0, 1, 1);
				addTri(t, lumTR, lumBR, lumTL, sx + dx, sy, sz + dz, 0, 0, -dz, -dx, 0, 0, 1, 0, 1, 1, 0, 0);
			} else {
				addTri(t, lumBL, lumTL, lumBR, sx + dx, sy, sz, 0, 0, dz, -dx, 0, 0, 0, 1, 0, 0, 1, 1);
				addTri(t, lumTR, lumBR, lumTL, sx, sy, sz + dz, 0, 0, -dz, dx, 0, 0, 1, 0, 1, 1, 0, 0);
			}
		} else {
			if( side ) {
				addTri(t, lumBL, lumTL, lumBR, sx, sy, sz, dx, 0, 0, 0, dy, 0, 0, 1, 0, 0, 1, 1);
				addTri(t, lumTR, lumBR, lumTL, sx + dx, sy + dy, sz, -dx, 0, 0, 0, -dy, 0, 1, 0, 1, 1, 0, 0);
			} else {
				// flip vertex order
				addTri(t, lumBL, lumBR, lumTL, sx, sy, sz, 0, dy, 0, dx, 0, 0, 0, 1, 1, 1, 0, 0);
				addTri(t, lumTR, lumTL, lumBR, sx + dx, sy + dy, sz, 0, -dy, 0, -dx, 0, 0, 1, 0, 0, 0, 1, 1);
			}
		}
	}

	inline function getLight( addr : Int ) {
		return tags.getByte(addr) >> TAGBITS;
	}

	inline function isTransparent( addr : Int ) {
		return tags.getByte(addr)&TAGMASK != TAGFULL;
	}

	inline function isTransparentNotWater( addr : Int ) {
		return tags.getByte(addr)&TAGMASK < Type.enumIndex(BTWater);
	}

	inline function isNotWater( addr : Int ) {
		return tags.getByte(addr)&TAGMASK != Type.enumIndex(BTWater);
	}
	
	function allocBuffer() {
		var nfloats = (bufferPos - tmp.getPos()) >> 2;
		var nvect = Std.int(nfloats / Shaders.DefShader.STRIDE);
		if( nvect == 0 ) return null;
		return bmanager.alloc(manager.bytes, tmp.getPos(), nvect);
	}

	function makeVertexes( c : CellBuffer ) {
		var blocks = blocks;
		var blockInfos = blockInfos;
		var tagBits = 0;

		this.deltaX = (c.x - 1) << CELL;
		this.deltaY = (c.y - 1) << CELL;
		this.bufferPos = tmp.getPos();

		for( cy in 0...CSIZE )
			for( cx in 0...CSIZE ) {
				var x = cx + CSIZE;
				var y = cy + CSIZE;
				var p = addr(x, y, 0);
				var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

				for( z in 0...Const.ZSIZE ) {
					var bt = tags.getByte(p) & TAGMASK;
					if( bt == 0 ) {
						p += DZ;
						continue;
					}
					if( bt != TAGFULL ) {
						tagBits |= 1 << bt;
						p += DZ;
						continue;
					}
					var kind = blocks.getUI16(p + pdelta);
					var block = blockInfos.get(kind);
					// z-top
					if( isTransparent(p + DZ) )
						addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
					// left
					if( isTransparent(p - DX) )
						addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
					// up
					if( isTransparent(p - DY) )
						addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
					// right
					if( isTransparent(p + DX) )
						addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
					// down
					if( isTransparent(p + DY) )
						addQuad(p, block.tlr, block.shadeY, x, y+1, z, 1, 0, 1, true);
					// z-bottom
					if( z > 0 && isTransparent(p - DZ) )
						addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
					p += DZ;
				}
			}

		for( tagGroup in [[BTFull], [BTTransp,BTModel], [BTAlpha], [BTWater]] ) {

			for( tag in tagGroup ) {

				var itag = Type.enumIndex(tag);
				if( tagBits & (1 << itag) == 0 )
					continue;

				switch( tag ) {
				case BTModel:
					var first = true;
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;
							var dx : Float = x + deltaX;
							var dy : Float = y + deltaY;

							for( z in 0...Const.ZSIZE ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								var model = block.modelPos;
								var shade = getLight(p) * (1 / LMAX);

								for( i in 0...block.modelSize ) {
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dx);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dy);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + z);		bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) );		bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) );		bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) * shade);	bufferPos += 4;
								}
								p += DZ;
							}
						}
					continue;
				case BTWater:
					var anim = kube.animWater != null;
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...Const.ZSIZE ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								// z-top
								if( anim ) {
									if( isNotWater(p+DZ) )
										addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								} else {
									if( isTransparentNotWater(p + DZ) )
										addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								}
								// left
								if( isTransparentNotWater(p - DX) )
									addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
								// up
								if( isTransparentNotWater(p - DY) )
									addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
								// right
								if( isTransparentNotWater(p + DX) )
									addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
								// down
								if( isTransparentNotWater(p + DY) )
									addQuad(p, block.tlr, block.shadeY, x, y + 1, z, 1, 0, 1, true);
								// bottom
								if( isTransparentNotWater(p - DZ) )
									addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
								p += DZ;
							}
						}
					continue;
				default:
				}

				for( cy in 0...CSIZE )
					for( cx in 0...CSIZE ) {
						var x = cx + CSIZE;
						var y = cy + CSIZE;
						var p = addr(x, y, 0);
						var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

						for( z in 0...Const.ZSIZE ) {
							var bt = tags.getByte(p) & TAGMASK;
							if( bt != itag ) {
								p += DZ;
								continue;
							}
							var kind = blocks.getUI16(p + pdelta);
							var block = blockInfos.get(kind);
							// z-top
							if( isTransparent(p + DZ) )
								addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
							// left
							if( isTransparent(p - DX) )
								addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
							// up
							if( isTransparent(p - DY) )
								addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
							// right
							if( isTransparent(p + DX) )
								addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
							// down
							if( isTransparent(p + DY) )
								addQuad(p, block.tlr, block.shadeY, x, y+1, z, 1, 0, 1, true);
							// z-bottom
							if( z > 0 && isTransparent(p - DZ) )
								addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
							p += DZ;
						}
					}
			}

			c.buffers[Type.enumIndex(tagGroup[0])] = allocBuffer();
			bufferPos = tmp.getPos();
		}
	}

	inline function creal( v : Int ) {
		return (v + cellStride) % cellStride;
	}

	public function rebuild( c : CellBuffer ) {
		manager.select();

		// check if all necessary cells are available
		var lcells = kube.level.cells;
		for( dx in 0...3 )
			for( dy in 0...3 ) {
				var c = lcells[ (creal(c.x + dx - 1) << CELL) >> Const.BITS ][ (creal(c.y + dy - 1) << CELL) >> Const.BITS ];
				if( c.t == null )
					return false;
				if( c.tags == null )
					computeTags(c);
			}

		// copy tags from level cell to our manager memory
		var levelTags = levelTags;
		var tags = tags;
		var specpos = 0;
		for( dx in 0...3 )
			for( dy in 0...3 ) {
				var cx = creal(c.x + dx - 1);
				var cy = creal(c.y + dy - 1);
				var lc = lcells[cx >> (Const.BITS - CELL)][cy >> (Const.BITS - CELL)];
				if( lc != currentTags ) {
					currentTags = lc;
					manager.copy(lc.tags, 0, levelTags, Const.TSIZE);
				}
				// write specials in current coordinates
				if( lc.specials.length > 0 ) {
					manager.bytes.position = specpos + specials.getPos();
					manager.bytes.writeBytes(lc.specials);
					var i = specpos;
					var max = specpos + lc.specials.length;
					while( i < max ) {
						var x = specials.getByte(i++) - ((cx << CELL) & Const.MASK);
						var y = specials.getByte(i++) - ((cy << CELL) & Const.MASK);
						var z = specials.getByte(i++);
						var b = specials.getByte(i++);
						if( (x|y)>>>CELL != 0 ) continue;
						specials.setByte(specpos++, x + (dx << CELL));
						specials.setByte(specpos++, y + (dy << CELL));
						specials.setByte(specpos++, z);
						specials.setByte(specpos++, b);
					}
				}
				var read = levelTags.getPos() + (((cx<<CELL)&Const.MASK)<<Const.X) + (((cy<<CELL)&Const.MASK)<<Const.Y);
				var write = tags.getPos() + addr(dx<<CELL,dy<<CELL,0);
				for( y in 0...CSIZE ) {
					var read = read + (y << Const.Y);
					var write = write + (y << Y);
					for( p in 0...(CSIZE * Const.ZSIZE) >> 2 ) {
						flash.Memory.setI32(write, flash.Memory.getI32(read));
						read += 4;
						write += 4;
					}
				}
			}
			
		// mark end of list of specials
		if( specpos >= MAX_SPECIALS * 4 ) specpos = (MAX_SPECIALS - 1) * 4;
		specials.setByte(specpos++, 0xFF);

		// copy blocks from level cell to our manager memory
		var cellBlocks = lcells[c.x >> (Const.BITS - CELL)][c.y >> (Const.BITS - CELL)].t;
		var cellX = (c.x << CELL) & Const.MASK;
		var cellY = (c.y << CELL) & Const.MASK;
		manager.bytes.position = blocks.getPos();
		for( y in 0...CSIZE ) {
			var read = (cellX << Const.X) | ((cellY + y) << Const.Y);
			manager.bytes.writeBytes(cellBlocks, read<<1, CSIZE * Const.ZSIZE * 2);
		}

		// relight our buffer
		relight();

		c.dispose();

		// build vertexes
		makeVertexes(c);

		// done
		c.dirty = false;
		return true;
	}

}