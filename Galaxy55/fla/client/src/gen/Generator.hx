package gen;
import Common;

private class CavePoint {
	public var x : Int;
	public var y : Int;
	public var z : Int;
	public var size : Int;
	public var dist : Int;
	public var links : Int;
	public var next : Array<CavePoint>;
	public function new(x, y, z, size) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.size = size;
		next = [];
	}
}

private class Model {
	public var sx : Int;
	public var sy : Int;
	public var sz : Int;
	public var bytes : haxe.io.Bytes;
	public var blocks : Array<BlockKind>;
	public function new(sx, sy, sz, bytes) {
		this.sx = sx;
		this.sy = sy;
		this.sz = sz;
		this.bytes = bytes;
	}
}

class Generator {

	static inline var EMPTY = 0;
	static inline var BEDROCK = 1;
	static inline var WATER = 2;
	
	static inline var TMP = 128;
	static inline var TMASK = 127;
	static inline var CAVE = 128;
	
	static inline var MINERAL_COM = 3;
	static inline var MINERAL_RARE = 4;
	static inline var ROCK = 5;
	static inline var SOIL = 6;

	static inline var HBITS = Const.ZBITS;
	static inline var HEIGHT = Const.ZSIZE;

	public var size(default,null) : Int;
	var seed : Int;
	var genStep : Int;
	var rnd : mt.Rand;
	
	var perlin : FPerlin;
	var globalScale : Float;
	var curScale : Float;
	var realHeightMin : Float;
	var realHeightScale : Float;
	
	var outHeight : Int;
	var outPos : Int;
	var spentTime : Int;
	public var totalTime : Int;
	public var maxTime : Int;
	public var fast : Bool;
	
	var steps : Array<{ f : Void->Void, p : haxe.PosInfos }>;
	var curPosition : Int;
	
	var maxHeight : Int;
	var waterLevel : Int;
	var waterLimit : Int;
	var waterTotal : Int;
	
	public var progress : Float;
	
	public var blocks : Array<Block>;
	public var hblocks : IntHash<Int>;
	public var btrans : Array<Bool>;
	var models : Hash<Model>;
	
	public function new(size,seed) {
		this.size = size;
		this.seed = seed;
		genStep = 0;
		models = new Hash();
		perlin = new FPerlin(size);
		outHeight = perlin.buf.length;
		perlin.buf.length += size * size;
		outPos = perlin.buf.length;
		perlin.buf.length += size * size << HBITS;
		blocks = [];
		btrans = [];
		steps = [];
		hblocks = new IntHash();
		alloc(BEmpty);
		alloc(BBedrock);
	}
	
	public inline function initStep() {
		genStep++;
		rnd.initSeed(seed+genStep);
	}
	
	public function forceBlock( b : BlockKind ) {
		hblocks.remove(Type.enumIndex(b));
	}
	
	public function alloc( b : BlockKind ) {
		var bid = Type.enumIndex(b);
		var id = hblocks.get(bid);
		if( id != null ) return id;
		id = blocks.length;
		var b = Block.all[bid];
		blocks.push(b);
		btrans.push( b.type != BTFull && b.type != BTAlpha);
		hblocks.set(bid, id);
		// load other blocks
		if( b.covered != null ) {
			var id2 = alloc(b.covered.k);
			addStep(callback(addCover, id, id2));
		}
		if( b.propagate != null ) {
			var tid = 0;
			addStep(function() addPropagate(id, tid, b.hasFlag(BFFallCopy) ? id : tid));
			tid = alloc(b.propagate.k);
		}
		return id;
	}
	
	public function getKind(bid:Int) {
		return null;
	}
	
	function randMineral() {
		return rnd.random(5) == 0 ? MINERAL_RARE : MINERAL_COM;
	}
	
	public function getWaterInfos() {
		return { level : waterLevel, total : waterTotal };
	}

	inline function addr(x, y, z) {
		return ((x + y * size) << HBITS) | z;
	}
	
	inline function fset(addr, v) {
		flash.Memory.setByte(addr + outPos, v);
	}

	inline function set(x, y, z, v) {
		if( z > 0 && z < HEIGHT )
			fset(((real(x) + real(y) * size) << HBITS) | z, v);
	}
	
	function get(x, y, z) {
		if( z < 0 ) return BEDROCK;
		if( z >= HEIGHT ) return EMPTY;
		return fget(((real(x) + real(y) * size) << HBITS) | z);
	}
	
	function oset(x, y, z, v) {
		if( z > 0 && z < HEIGHT ) {
			var addr = ((real(x) + real(y) * size) << HBITS) | z;
			if( fget(addr) == EMPTY ) {
				fset(addr, v);
				return true;
			}
		}
		return false;
	}
	
	inline function fget(addr) {
		return flash.Memory.getByte(addr + outPos);
	}
	
	inline function hval(addr) {
		return flash.Memory.getByte(addr + outHeight);
	}
	
	inline function height(x, y) {
		return hval(real(x) + real(y) * size);
	}

	inline function setHeight(x, y, v) {
		flash.Memory.setByte(real(x) + real(y) * size + outHeight, v);
	}
	
	inline function hash(n) {
		for( i in 0...3 ) {
			n ^= (n << 7) & 0x2b5b2500;
			n ^= (n << 15) & 0x1b8b0000;
			n ^= n >>> 16;
			n &= 0x3FFFFFFF;
			var h = 5381 + perlin.seed;
			h = (h << 5) + h + (n & 0xFF);
			h = (h << 5) + h + ((n >> 8) & 0xFF);
			h = (h << 5) + h + ((n >> 16) & 0xFF);
			h = (h << 5) + h + (n >> 24);
			n = h & 0x3FFFFFFF;
		}
		return n & 0x1FFFFFFF;
	}
	
	inline function realHeight(p) {
		return flash.Memory.getDouble(perlin.outOffset + (p << 3));
	}
	
	function setRealHeight(x, y, v) {
		var p = real(x) + real(y) * size;
		flash.Memory.setDouble(perlin.outOffset + (p << 3), v);
	}
	
	inline function real(v) {
		if( v < 0 ) v += size;
		if( v >= size ) v -= size;
		return v;
	}
	
	function initPerlin( scale : Float ) {
		perlin.seed++;
		curScale = perlin.initScale(globalScale * scale);
	}
	
	inline function perlin2D( x : Float, y : Float ) {
		return perlin.gradient2DAt(x * curScale, y * curScale);
	}

	inline function perlin3D( x : Float, y : Float, z : Float ) {
		return perlin.gradient3DAt(x * curScale, y * curScale, z * curScale);
	}
	
	public function startGenerate(biome) {
		spentTime = 0;
		maxTime = 0;
		totalTime = 0;
		progress = 0;
		rnd = new mt.Rand(seed);
		perlin.init(seed, 0, 0);
		var finalSteps = steps;
		steps = [];
		initBiome(biome);
		addStep(addDetails);
		addStep(addBonus);
		for( s in finalSteps )
			steps.push(s);
		addStep(checkWater);
		addStep(fillBedrock);
		globalScale *= 1 / 180;
	}
	
	function addDetails() {
	}

	function addCaveDetails() {
	}
	
	function addBonus() {
	}
	
	function addHeightDetails() {
	}
	
	function addStep(f #if genDebug, ?p : haxe.PosInfos #end ) {
		#if !genDebug var p = null; #end
		steps.push( { f : function() { initStep(); f(); }, p : p } );
	}
	
	#if genDebug
	public function getCurrentStep() {
		var s = steps[curPosition];
		if( s == null ) return null;
		return s.p;
	}
	#end
	
	function stepRetry() {
		curPosition--;
	}
	
	function initBiome(biome:BiomeKind) {
	}
	
	function addCover( bid : Int, bid2 : Int ) {
		perlin.select();
		var transp = btrans;
		var addr = 0;
		for( y in 0...size )
			for( x in 0...size ) {
				addr += HEIGHT - 1;
				var over = EMPTY;
				for( z in 1...HEIGHT ) {
					var b = fget(addr);
					if( b == bid && (over == EMPTY || transp[over])  )
						fset(addr, bid2);
					over = b;
					addr--;
				}
				addr += HEIGHT;
			}
	}
	
	function addPropagate( bid : Int, bid2 : Int, fallId : Int ) {
		perlin.select();
		var addr = 0;
		for( y in 0...size )
			for( x in 0...size ) {
				addr += HEIGHT;
				for( z in 0...HEIGHT ) {
					var b = fget(--addr);
					if( b == bid ) {
						if( z < HEIGHT - 1 && (fget(addr - 1) == 0 || fget(addr-1) == fallId) )
							fset(addr - 1, fallId);
						else if( bid2 != bid ) {
							if( fget(addr + HEIGHT * minusOne(x)) == 0 )
								fset(addr + HEIGHT * minusOne(x), bid2);
							if( fget(addr + HEIGHT * plusOne(x)) == 0 )
								fset(addr + HEIGHT * plusOne(x), bid2);
							if( fget(addr + HEIGHT * minusOne(x)) == 0 )
								fset(addr + HEIGHT * minusOne(x), bid2);
							if( fget(addr + HEIGHT * size * plusOne(y)) == 0 )
								fset(addr + HEIGHT * size * plusOne(y), bid2);
							if( fget(addr + HEIGHT * size * minusOne(y)) == 0 )
								fset(addr + HEIGHT * size * minusOne(y), bid2);
						}
					}
				}
				addr += HEIGHT;
			}
	}
	
	public function process( maxTimeSlice = 100 ) {
		var t0 = flash.Lib.getTimer();
		perlin.select();
		if( curPosition >= steps.length ) {
			return false;
		}
		while( true ) {
			var t = flash.Lib.getTimer();
			var cur = steps[curPosition];
			curPosition++;
			cur.f();
			var t2 = flash.Lib.getTimer();
			spentTime += t2 - t;
			var dt = t2 - t0;
			if( dt > maxTime ) maxTime = dt;
			var p = curPosition / steps.length;
			progress = p;
			if( dt >= maxTimeSlice || curPosition >= steps.length ) {
				totalTime += dt;
				break;
			}
		}
		return true;
	}
	
	inline function minusOne(v) {
		return v == 0 ? size - 1 : -1;
	}

	inline function plusOne(v) {
		return v == size-1 ? 1-size : 1;
	}
	
	inline function addHeight( scale : Float, power : Float ) {
		perlin.add(scale * globalScale, power);
		return power;
	}
	
	inline function addMulHeight( add : Float, mul : Float ) {
		perlin.addMul(add, mul);
	}
	
	function adjustHeight( scale : Float, delta : Float ) {
		perlin.adjust(scale * globalScale, delta);
	}
	
	function fillHeight( levels : Array<{ v : Float, h : Int }> ) {
		var wh = waterLevel;
		var heights = new flash.Vector<Int>();
		maxHeight = 0;
		var hmin = levels[0].v;
		var hmax = levels[levels.length - 1].v;
		var hscale = 65535 / (hmax - hmin);
		this.realHeightMin = hmin;
		this.realHeightScale = hscale;
		var pos = 0;
		var prev = levels[0];
		var lastHeight = 0;
		for( h in levels ) {
			var target = Std.int((h.v - hmin) * hscale);
			if( target > pos ) {
				var cur = 0.;
				var dt = 1. / (target - pos);
				while( pos < target ) {
					var h = Std.int(prev.h * (1 - cur) + h.h * cur + wh);
					if( h >= HEIGHT ) h = HEIGHT - 1;
					if( h > maxHeight ) maxHeight = h;
					lastHeight = h;
					heights[pos++] = h;
					cur += dt;
				}
			}
			prev = h;
		}
		while( pos < 65536 )
			heights[pos++] = lastHeight;
	
		waterLimit = 65536;
		for( i in 0...65536 )
			if( heights[i] > wh+1 ) {
				waterLimit = i-1;
				break;
			}
				
		for( p in 0...size * size ) {
			var fh = Std.int((realHeight(p) - realHeightMin) * realHeightScale);
			if( fh < 0 ) fh = 0 else if( fh > 0xFFFF ) fh = 0xFFFF;
			flash.Memory.setByte(outHeight + p, heights[fh]);
		}
	}
	
	inline function removeBlock( b : BlockKind ) {
		replaceBlock(alloc(b), EMPTY);
	}
	
	function replaceBlock( b : Int, by : Int ) {
		for( i in 0...size * size * HEIGHT )
			if( fget(i) == b )
				fset(i, by);
	}
	
	function replaceSomeBlocks( b:BlockKind, by:BlockKind, pctChance:Int ) {
		var b = alloc(b);
		var by = alloc(by);
		for( i in 0...size * size * HEIGHT )
			if( fget(i) == b && rnd.random(100)<pctChance )
				fset(i, by);
	}
	
	function around(x, y, z, b) {
		return get(x - 1, y, z) == b || get(x + 1, y, z) == b || get(x, y - 1, z) == b || get(x, y + 1, z) == b || get(x, y, z - 1) == b || get(x, y, z + 1) == b;
	}
	
	function free(x, y, z, dx, dy, dz) {
		for( dx in 0...dx )
			for( dy in 0...dy )
				for( dz in 0...dz )
					if( get(x + dx, y + dy, z + dz) != EMPTY )
						return false;
		return true;
	}

	
	function fillSoil( minWater : Float ) {
		addHeightDetails();
		var wh = waterLevel;
		// fill soil
		initPerlin(4);
		var hscale = 0.9 * (maxHeight - wh);
		var p = -1;
		var water = 0;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = hval(++p);
				var rnd = perlin2D(x, y);
				var rock = h - Std.int((rnd + hscale / h) * 4);
				if( rock < 0 ) rock = 0;
				if( rock > h ) rock = h;
				var addr = p << HBITS;
				for( i in 0...rock )
					fset(addr++, ROCK);
				for( i in rock...h )
					fset(addr++, SOIL);
				if( (realHeight(p) - realHeightMin) * realHeightScale < waterLimit )
					for( i in h...wh+1 ) {
						fset(addr++, WATER);
						water++;
					}
			}
		var w = water / (size * size);
		if( w < minWater && size > 128 ) {
			// change perlin seed
			perlin.seed = hash(perlin.seed);
			for( i in 0...size * size * HEIGHT )
				fset(i, 0);
			curPosition = 0;
		}
	}

	function addHoles( hsize : Float, levels : Array<{ h : Int, v : Float }>, ?block=EMPTY ) {
		initPerlin(hsize);
		var heights = new flash.Vector<Float>();
		var cur = 0;
		var prev = { h : 0, v : -1. };
		var hmax = 0;
		for( h in 0...255 ) {
			var l = levels[cur];
			var v = prev.v + (l.v - prev.v) * ((h - prev.h) / (l.h - prev.h));
			if( l == prev ) v = prev.v;
			heights.push(v);
			if( v > -1 )
				hmax = h;
			while( l.h <= h ) {
				prev = l;
				if( cur == levels.length - 1 )
					break;
				l = levels[++cur];
			}
		}
		var hstart = levels[0].h;
		for( y in 0...size )
			for( x in 0...size ) {
				var p = x + y * size;
				var h = height(x, y);
				if( h < hstart || h > hmax )
					continue;
				var h = hval(p);
				var min = hstart + 1;
				var addr = (p << HBITS) + min;
				for( z in min...h ) {
					if( fget(addr) == EMPTY )
						continue;
					var g = perlin3D(x, y, z);
					if( g < heights[z] )
						fset(addr, block);
					addr++;
				}
			}
	}
	
	var blobsStep : Int;
	
	function removeBlobs() {
		if( blobsStep == 0 ) {
			for( y in 0...size )
				for( x in 0...size ) {
					var addr = (x + y * size) << HBITS;
					for( z in 0...HEIGHT ) {
						var b = fget(addr++);
						if( b == CAVE )
							fset(addr-1,EMPTY);
						else if( b != EMPTY )
							continue;
						// mark upper part as to-do
						for( i in z + 1...HEIGHT ) {
							var b = fget(addr);
							if( b == CAVE )
								fset(addr, EMPTY);
							else if( b != EMPTY )
								fset(addr, b | TMP);
							addr++;
						}
						break;
					}
				}
			blobsStep++;
			stepRetry();
		} else if( blobsStep > 0 ) {
			var count = 0, match = 0;
			for( y in 0...size )
				for( x in 0...size ) {
					var addr = (x + y * size) << HBITS;
					for( z in 0...HEIGHT ) {
						var b = fget(addr);
						if( b & TMP != 0 ) {
							match++;
							count += removeBlobRec(x,y,z,addr,30);
						}
						addr++;
					}
				}
			if( count == 0 )
				blobsStep = -1;
			else
				blobsStep++;
			stepRetry();
		} else {
			for( addr in 0...size * size * HEIGHT ) {
				var b = fget(addr);
				if( b & TMP != 0 )
					fset(addr, EMPTY);
			}
			blobsStep = 0;
		}
	}
	
	function smoothHeight() {
		var addr = 0;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = (hval(addr) << 2) + (hval(addr + minusOne(x)) + hval(addr + plusOne(x)) + hval(addr + minusOne(y) * size) + hval(addr + plusOne(y)*size)) * 3;
				flash.Memory.setByte(outHeight + addr, (h + 7) >> 4);
				addr++;
			}
	}
	
	function removeBlobRec(x, y, z, addr, depth ) {
		var count = 0;
		if( fget(addr + (minusOne(x) << HBITS)) - 1 & TMP == 0 || fget(addr + (plusOne(x) << HBITS)) - 1 & TMP == 0 ||
			fget(addr + (minusOne(y) << HBITS) * size) - 1 & TMP == 0 || fget(addr + (plusOne(y) << HBITS) * size) - 1 & TMP == 0 ||
			(z > 0 && fget(addr - 1)-1 & TMP == 0) || (z < HEIGHT-1 && fget(addr + 1)-1 & TMP == 0) ) {
			fset(addr, fget(addr) & TMASK);
			count++;
			depth--;
			if( depth > 0 ) {
				var naddr;
				naddr = addr + (minusOne(x) << HBITS);
				if( fget(naddr) & TMP != 0 )
					count += removeBlobRec(minusOne(x), y, z, naddr, depth);
				naddr = addr + (minusOne(y) << HBITS)*size;
				if( fget(naddr) & TMP != 0 )
					count += removeBlobRec(x, minusOne(y), z, naddr, depth);
				if( z > 0 ) {
					naddr = addr - 1;
					if( fget(naddr) & TMP != 0 )
						count += removeBlobRec(x, y, z--, naddr, depth);
				}
			}
		}
		return count;
	}
	
	inline function countEmpty(x, y, z, addr) {
		var count = 0;
		if( fget(addr + (minusOne(x) << HBITS)) == EMPTY )
			count++;
		if( fget(addr + (plusOne(x) << HBITS)) == EMPTY )
			count++;
		if( z > 0 && fget(addr - 1) == EMPTY )
			count++;
		if( z < HEIGHT - 1 && fget(addr + 1) == EMPTY )
			count++;
		if( fget(addr + (minusOne(y) << HBITS) * size) == EMPTY )
			count++;
		if( fget(addr + (plusOne(y) << HBITS) * size) == EMPTY )
			count++;
		return count;
	}
	
	function smooth3D( hmin = -1, hmax = 255 ) {
		var changed = 0;
		if( hmin < 0 ) hmin = waterLevel;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = height(x,y);
				if( h <= hmin || h > hmax ) continue;
				var addr = ((x + y * size) << HBITS) + hmin;
				for( z in hmin...HEIGHT ) {
					var b = fget(addr);
					if( b == EMPTY ) {
						var count = countEmpty(x, y, z, addr);
						if( count <= 2 )
							changed += smooth3DEmptyRec(x, y, z, addr, 4);
					} else if( b != WATER ) {
						var count = countEmpty(x, y, z, addr);
						if( count >= 5 )
							changed += smooth3DRec(x, y, z, addr, 10);
					}
					addr++;
				}
			}
		return changed;
	}
	
	function smooth3DRec(x, y, z, addr, depth) {
		if( fget(addr) == WATER )
			return 0;
		fset(addr, EMPTY);
		var count = 1;
		depth--;
		if( depth == 0 ) return count;
		var naddr = addr + (minusOne(x) << HBITS);
		if( countEmpty(minusOne(x), y, z, naddr) >= 5 )
			count += smooth3DRec(minusOne(x), y, z, naddr, depth);
		var naddr = addr + (minusOne(y) << HBITS) * size;
		if( countEmpty(x,minusOne(y), z, naddr) >= 5 )
			count += smooth3DRec(x, minusOne(y), z, naddr, depth);
		var naddr = addr - 1;
		if( z > 0 && countEmpty(x,y, z-1, naddr) >= 5 )
			count += smooth3DRec(x, y, z - 1, naddr, depth);
		return count;
	}
	
	function smooth3DEmptyRec(x, y, z, addr, depth) {
		fset(addr, SOIL);
		var count = 1;
		depth--;
		if( depth == 0 ) return count;
		var naddr = addr + (minusOne(x) << HBITS);
		if( countEmpty(minusOne(x), y, z, naddr) <= 2 )
			count += smooth3DEmptyRec(minusOne(x), y, z, naddr, depth);
		var naddr = addr + (minusOne(y) << HBITS) * size;
		if( countEmpty(x,minusOne(y), z, naddr) <= 2 )
			count += smooth3DEmptyRec(x, minusOne(y), z, naddr, depth);
		var naddr = addr - 1;
		if( z > 0 && countEmpty(x,y, z-1, naddr) <= 2 )
			count += smooth3DEmptyRec(x, y, z - 1, naddr, depth);
		return count;
	}
	
	public function getBitmap() {
		var bmp = new flash.display.BitmapData(size, size, true, 0);
		var colors = bmp.getVector(bmp.rect);
		flash.Memory.select(perlin.buf);
		
		var wh = waterLevel;
		for( y in 0...size )
			for( x in 0...size ) {
				var p = x + y * size;
				var addr = p << HBITS;
				var h = hval(p);
				var color;
				if( h < wh )
					color = Std.int(h * 255 / wh);
				else {
					var f = Std.int( (h - wh) * 255 / (HEIGHT - wh) );
					color = f | (f << 16) | (((f >> 1) | 0x80) << 8);
				}
				if( h > wh ) h = wh;
				for( i in 0...h )
					if( fget(addr++) == EMPTY ) {
						var f = 0.2 + 0.8 * (i / h);
						var r = Std.int( ((color >> 16) & 0xFF) * f + (1 - f) * 0xFF );
						var g = Std.int( ((color >> 8) & 0xFF) * f );
						var b = Std.int( (color & 0xFF) * f + (1 - f) * 0xFF );
						color = (r << 16) | (g << 8) | b;
						break;
					}
				colors[p] = 0xFF000000 | color;
			}
		bmp.setVector(bmp.rect, colors);
		return bmp;
	}
	
	public function getBytes() {
		var out = new flash.utils.ByteArray();
		out.writeBytes(perlin.buf, outPos, size * size << HBITS);
		return out;
	}
		
	inline function srand( v : Float ) {
		return rnd.rand() * (v * 2) - v;
	}
	
	// ---------------- CAVES/TOOLS ---------------------------------------------------------------------------------------------
	
	inline function box(sizeX, sizeY, sizeZ, callb) {
		for(dx in 0...sizeX)
			for(dy in 0...sizeY)
				for(dz in 0...sizeZ)
					callb(dx,dy,dz);
	}
	
	inline function boxWalls(sizeX, sizeY, sizeZ, callb) {
		for(dx in 0...sizeX)
			for(dy in 0...sizeY)
				for(dz in 0...sizeZ)
					if( dx==0 || dx==sizeX-1 || dy==0 || dy==sizeY-1 || dz==0 || dz==sizeZ-1 )
						callb(dx,dy,dz);
	}
	
	inline function boxCentered(sizeX,sizeY,sizeZ, callb) {
		var bx = -Std.int(sizeX/2);
		var by = -Std.int(sizeY/2);
		var bz = -Std.int(sizeZ/2);
		for( dx in bx...bx + Std.int(sizeX) )
			for( dy in by...by + Std.int(sizeY) )
				for( dz in bz...bz + Std.int(sizeZ) )
					callb(dx,dy,dz);
	}
	
	inline function boxCenteredWalls(sizeX,sizeY,sizeZ, callb) {
		var bx = -Std.int(sizeX/2);
		var by = -Std.int(sizeY/2);
		var bz = -Std.int(sizeZ/2);
		for( dx in bx...bx + Std.int(sizeX) )
			for( dy in by...by + Std.int(sizeY) )
				for( dz in bz...bz + Std.int(sizeZ) )
					if( dx==bx || dx==bx+Std.int(sizeX)-1 || dy==by || dy==by+Std.int(sizeY)-1  || dz==bz || dz==bz+Std.int(sizeZ)-1 )
						callb(dx,dy,dz);
	}
	
	
	inline function square(sizeX,sizeY, callb) {
		var bx = -Std.int(sizeX/2);
		var by = -Std.int(sizeY/2);
		for( dx in bx...bx + Std.int(sizeX) )
			for( dy in by...by + Std.int(sizeY) )
				callb(dx,dy);
	}
	
	inline function squareWalls(sizeX,sizeY, callb) {
		var bx = -Std.int(sizeX/2);
		var by = -Std.int(sizeY/2);
		for( dx in bx...bx + Std.int(sizeX) )
			for( dy in by...by + Std.int(sizeY) )
				if( dx==bx || dx==bx+Std.int(sizeX)-1 || dy==by || dy==by+Std.int(sizeY)-1 )
					callb(dx,dy);
	}
	//inline function squareWalls(sizeX,sizeY,sizeZ, callb) {
		//var bx = -Std.int(sizeX/2);
		//var by = -Std.int(sizeY/2);
		//var bz = -Std.int(sizeZ/2);
		//for( dx in bx...bx + Std.int(sizeX) )
			//for( dy in by...by + Std.int(sizeY) )
				//for( dz in bz...bz + Std.int(sizeZ) )
					//if( dx==bx || dx==bx+Std.int(sizeX)-1 || dy==by || dy==by+Std.int(sizeY)-1  || dz==bz || dz==bz+Std.int(sizeZ)-1 )
						//callb(dx,dy,dz);
	//}
	
	
		
	inline function elipse(xx, yy, zz, callb) {
		var ix = Math.ceil(xx);
		var iy = Math.ceil(yy);
		var iz = Math.ceil(zz);
		for( dx in -ix...ix + 1 )
			for( dy in -iy...iy + 1 )
				for( dz in -iz...iz + 1 ) {
					var d = (dx / xx) * (dx / xx) + (dy / yy) * (dy / yy) + (zz == 0 ? 0 : (dz / zz) * (dz / zz));
					if( d > 1 ) continue;
					callb(dx, dy, dz);
				}
	}
	
	inline function circle(xx, yy, callb) {
		var ix = Math.ceil(xx);
		var iy = Math.ceil(yy);
		for( dx in -ix...ix + 1 )
			for( dy in -iy...iy + 1 ) {
				var d = (dx / xx) * (dx / xx) + (dy / yy) * (dy / yy);
				if( d > 1 ) continue;
				callb(dx, dy);
			}
	}
	
	inline function min(a, b) return a < b ? a : b
	inline function max(a, b) return a < b ? b : a
	
	inline function line( x : Int, y : Int, z : Int, dx : Int, dy : Int, dz : Int, callb ) {
		
		var ax = dx < 0 ? -1 : 1;
		var ay = dy < 0 ? -1 : 1;
		var az = dz < 0 ? -1 : 1;
		var d = dx * ax + dy * ay + dz * az;
		if( d == 0 ) d = 1;
		
		var ix = x;
		var iy = y;
		var iz = z;

		while( --d >= 0 ) {
			callb(x, y, z);
			var nx = (x + ax - ix) / dx;
			var ny = (y + ay - iy) / dy;
			var nz = (z + az - iz) / dz;
			if( nx < ny ) {
				if( nx < nz )
					x += ax;
				else
					z += az;
			} else if( ny < nz )
				y += ay;
			else
				z += az;
		}
	}

	function addCaves( amount : Float, scale : Float, broken : BlockKind ) {
		var wh = waterLevel;
		var pts = [];
		var broken = alloc(broken);
		for( i in 0...Std.int(size * size * amount / 1000) ) {
			var x, y, z, ntry = 100;
			do {
				x = rnd.random(size);
				y = rnd.random(size);
				z = height(x,y) - 1;
				if( --ntry == 0 ) break;
			} while( z < wh || z > wh + (wh >> 1) || fget(addr(x, y, z)) != SOIL );
			if( ntry == 0 )
				continue;
			z = rnd.random(z) + (z>>2) + 5;
			var size = Std.int((2. + min(rnd.random(20), rnd.random(20)) - Std.int(z * 4 / wh)) * scale);
			if( size < 2 ) size = 2;
			pts.push(new CavePoint(x,y,z,size));
		}
		for( p in pts ) {
			for( p2 in pts ) {
				if( p2.z >= p.z ) continue;
				var dx = realDist(p.x - p2.x), dy = realDist(p.y - p2.y), dz = p2.z - p.z;
				p2.dist = dx * dx + dy * dy + dz * dz;
				if( p2.dist < 50*50 )
					p.next.push(p2);
			}
			p.next.sort(sortCaves);
			var next = 0;
			for( i in 0...min(p.next.length, 2 + (rnd.random(3) == 0 ? 1 : 0)) - p.links ) {
				var p2 = p.next[i];
				p.links++;
				p2.links++;
				var x = p.x, y = p.y, z = p.z;
				var walls = [];
				while( true ) {
					var dx = realDist(p2.x - x);
					var dy = realDist(p2.y - y);
					var dz = p2.z - z;
					var ax = dx < 0 ? -dx : dx;
					var ay = dy < 0 ? -dy : dy;
					var az = dz < 0 ? -dz : dz;
					var t = ax + ay + az;
					elipse(1 + rnd.random(3), 1 + rnd.random(3), 2+rnd.random(2), function(dx, dy, dz) {
						var x = x + dx, y = y + dy, z = z + dz;
						set(x, y, z, CAVE);
					});
					if( t == 0 ) break;
					var jump = 1;
					if( rnd.random(20) == 0 )
						jump = 10;
					for( i in 0...jump ) {
						if( i == 5 )
							walls.push( { x : x, y : y, z : z } );
						var k = rnd.random(t);
						k -= ax;
						if( k < 0 ) {
							x += dx > 0 ? 1 : -1;
							continue;
						}
						k -= ay;
						if( k < 0 ) {
							y += dy > 0 ? 1 : -1;
							continue;
						}
						z += dz > 0 ? 1 : -1;
					}
				}
				for( w in walls )
					elipse(2 + rnd.random(2), 2 + rnd.random(2), 2+rnd.random(2), function(dx, dy, dz) {
						var x = w.x + dx, y = w.y + dy, z = w.z + dz;
						if( rnd.random(3) != 0 ) {
							var b = get(x, y, z);
							if( b == ROCK || b == SOIL )
								set(x, y, z, broken);
						}
					});
			}
		}
		for( p in pts ) {
			if( p.links == 0 ) continue;
			var size = p.size;
			for( i in 0...size * size ) {
				var x = p.x + rnd.random(size) - (size >> 1);
				var y = p.y + rnd.random(size) - (size >> 1);
				var z = p.z + ((rnd.random(size) - (size >> 1)) >> 1);
				elipse(rnd.random(size >> 1) + 1, rnd.random(size >> 1) + 1, (rnd.random(size >> 1) >> 1) + 1, function(dx, dy, dz) {
					var x = x + dx, y = y + dy, z = z + dz;
					set(x, y, z, CAVE);
				});
			}
		}
	}
	
	inline function realDist( d : Int ) {
		var half = size >> 1;
		return d <= -half ? d + size : (d > half ? d - size : d);
	}
	
	function sortCaves( c1 : CavePoint, c2 : CavePoint ) {
		return c1.dist - c2.dist;
	}
	
	function showCaves() {
		var tot = size * size << HBITS;
		var tmp = new flash.Vector<Int>(tot+1);
		for( addr in 0...tot )
			if( fget(addr) == CAVE )
				tmp[addr] = 1;
		addStep(function() {
			var addr = 0;
			for( y in 0...size )
				for( x in 0...size )
					for( z in 0...HEIGHT ) {
						if( tmp[addr] == 1 || (z > 0 && tmp[addr-1] == 1) || tmp[addr+1] == 1 || tmp[addr+(plusOne(x)<<HBITS)] == 1 || tmp[addr+(minusOne(x)<<HBITS)] == 1 || tmp[addr+(plusOne(y)<<(HBITS*2))] == 1 || tmp[addr+(minusOne(y)<<(HBITS*2))] == 1 ) {
							// ok
						} else {
							fset(addr, EMPTY);
						}
						addr++;
					}
		});
	}
	
	function checkWater() {
		var addr = 0;
		waterTotal = 0;
		var transp = btrans.copy();
		transp[WATER] = false;
		var isLiquid = blocks[WATER].hasProp(PLiquid);
		for( y in 0...size )
			for( x in 0...size ) {
				addr++;
				for( z in 1...HEIGHT ) {
					var f = fget(addr);
					if( f != WATER ) {
						addr++;
						continue;
					}
					waterTotal++;
					if( isLiquid ) {
						var a = addr + (minusOne(x) << HBITS);
						if( transp[fget(a)] ) fset(a, SOIL);
						var a = addr + (plusOne(x) << HBITS);
						if( transp[fget(a)] ) fset(a, SOIL);
						var a = addr + (minusOne(y) << HBITS) * size;
						if( transp[fget(a)] ) fset(a, SOIL);
						var a = addr + (plusOne(y) << HBITS) * size;
						if( transp[fget(a)] ) fset(a, SOIL);
						if( z > 0 ) {
							var a = addr - 1;
							if( transp[fget(a)] ) fset(a, SOIL);
						}
						if( z < waterLevel && fget(addr + 1) == EMPTY )
							fset(addr + 1, WATER);
					}
					addr++;
				}
			}
	}
	
	function fillBedrock() {
		for( p in 0...size * size ) {
			fset(p << HBITS, BEDROCK);
			// clear z=127
			fset((p << HBITS) | (HEIGHT - 1), EMPTY);
		}
	}
	
	inline function gen( density : Float, retry = 100, callb : Void -> Bool ) {
		for( i in 0...Math.ceil(size * size * density / 100) ) {
			var ntry = retry;
			while( ntry-- > 0 )
				if( callb() )
					break;
		}
	}
	
	function loadModel( mdata : String ) {
		var m = models.get(mdata);
		if( m != null )
			return m;
		var bytes : haxe.io.Bytes = haxe.Unserializer.run(mdata);
		var data = bytes.getData();
		data.uncompress();
		bytes = haxe.io.Bytes.ofData(data);
		var sx = bytes.get(0), sy = bytes.get(1), sz = bytes.get(2);
		// calculate size
		var xmin = sx - 1, ymin = sy - 1, xmax = 0, ymax = 0, zmax = 0;
		var pos = 3;
		for( y in 0...sy )
			for( x in 0...sx )
				for( z in 0...sz ) {
					if( bytes.get(pos) != 0 || bytes.get(pos + 1) != 0 ) {
						if( x < xmin ) xmin = x;
						if( y < ymin ) ymin = y;
						if( x > xmax ) xmax = x;
						if( y > ymax ) ymax = y;
						if( z > zmax ) zmax = z;
					}
					pos += 2;
				}
		zmax++;
		var w = xmax - xmin + 1;
		var h = ymax - ymin + 1;
		var b = haxe.io.Bytes.alloc(w * h * zmax);
		var hblocks = new IntHash();
		var blocks = [];
		var out = 0;
		for( y in 0...h )
			for( x in 0...w )
				for( z in 0...zmax ) {
					var pos = 3 + (z + (x+xmin) * sz + (y + ymin) * sz * sx) * 2;
					var k = bytes.get(pos) | (bytes.get(pos + 1) << 8);
					if( k == 0 ) {
						out++;
						continue;
					}
					var index = hblocks.get(k);
					if( index == null ) {
						index = blocks.length + 1;
						hblocks.set(k, index);
						blocks.push(Block.all[k].k);
					}
					b.set(out++, index);
				}
		m = new Model(w, h, zmax, b);
		m.blocks = blocks;
		models.set(mdata, m);
		return m;
	}
	
	function addModel( px, py, pz, model : String ) {
		var m = loadModel(model);
		px -= (m.sx - 1) >> 1;
		py -= (m.sy - 1) >> 1;
		var blocks = [];
		for( b in m.blocks )
			blocks.push(alloc(b));
		var pos = 0;
		for( y in 0...m.sy )
			for( x in 0...m.sx )
				for( z in 0...m.sz ) {
					var b = m.bytes.get(pos++);
					if( b == 0 )
						continue;
					set(px + x, py + y, pz + z, blocks[b-1]);
				}
	}
	
	function isSolid(b) {
		return b != EMPTY && !btrans[b];
	}
	
	inline function isSolidAt(x,y,z) {
		var b = get(x,y,z);
		return b!=CAVE && b != EMPTY && !btrans[b];
	}
	
	function putModel( px, py, pz, model ) {
		var m = loadModel(model);
		var x = px - (m.sx >> 1);
		var y = py - (m.sy >> 1);
		var pos = 0;
		// check if the volume is empty and the lower parts on soil
		for( dy in 0...m.sy )
			for( dx in 0...m.sx )
				for( dz in 0...m.sz ) {
					if( dz == 0 ) {
						if( m.bytes.get(pos) != 0 ) {
							var b = get(x + dx, y + dy, pz - 1);
							if( !isSolid(b) )
								return false;
						}
					} else if( get(x + dx, y + dy, pz + dz) != EMPTY )
						return false;
					pos++;
				}
		addModel(px, py, pz, model);
		return true;
	}
	
}
