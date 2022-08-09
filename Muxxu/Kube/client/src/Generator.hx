import Common;

private typedef Table<T> = flash.Vector<T>
private typedef Bitmap = flash.display.BitmapData

private enum Kind {
	KSoilTree;
	KAutumnTree;
	KHighTree;
	KClouds;
	KSphereTree;
	KLargeTree;
	KSnowSapin;
	KJungle;
	KCaverns;
	KField;
	KSwamp;
	KSoilPeaks;
	KPilarPlain;
	KFlowerPlain;
	KSavana;
	KDesert;
	KFlying;
}

private class Tables {

	public var soils : Table<Int>;
	public var heights : Table<Float>;
	public var kmap : Table<Table<Kind>>;
	public var lavas : Table<Int>;
	public var details : Table<Void -> Void>;
	public var gmap : Table<Int>;

	public function new( g : Generator ) {
		var kinds = Lambda.array(Lambda.map(Type.getEnumConstructs(Kind),function(k) return Type.createEnum(Kind,k)));
		var nkind = kinds.length;
		soils = new Table();
		for( i in 0...nkind )
			soils[i] = Type.enumIndex(BFixed);
		lavas = new Table(nkind);
		heights = new Table(nkind);
		for( i in 0...nkind )
			heights[i] = 1.0;
		var probas = new Table();
		for( i in 0...nkind )
			probas[i] = 100;
		// details
		details = new Table();
		for( k in kinds ) {
			var fun = try Reflect.field(g,Type.enumConstructor(k)) catch( e : Dynamic ) null;
			details.push(fun);
		}
		// INIT
		for( k in kinds )
			init(k,probas);
		// build decor kind proba table
		kmap = new Table();
		if( kinds[Level.FORCE] == null )
			Level.FORCE = null;
		for( dist in 0...16 ) {
			var i : UInt = 1;
			var pmap = new Table();
			kmap.push(pmap);
			var sum = 0;
			for( p in probas )
				if( dist == 15 || p >= (16-dist) * 100 / 16 )
					sum += p;
			for( idx in 0...Std.int(probas.length) ) {
				var p = probas[idx];
				if( dist < 15 && p < (16-dist) * 100 / 16 )
					continue;
				var k = kinds[idx];
				if( Level.FORCE != null )
					k = kinds[Level.FORCE];
				i += Math.ceil(p * 65535 / sum);
				while( pmap.length < i )
					pmap.push(k);
			}
		}
		// build gem proba table
		var gems = [BAmethyste,BSaphir,BSaphir,BRubis,BRubis,BRubis,BEmeraude,BEmeraude,BEmeraude,BGold,BDolpart];
		var rnd = new mt.Rand(12345);
		gmap = new Table();
		for( i in 0...1023 )
			if( rnd.random(7) != 0 )
				gmap[i] = 0;
			else {
				var bid = Type.enumIndex(gems[rnd.random(gems.length)]);
				var proba = 30 + rnd.random(200);
				gmap[i] = bid | (proba << 8);
			}
	}

	function init( k : Kind, probas ) {
		var me = this;
		var soil = function(v) tset(me.soils,k,Type.enumIndex(v));
		var lava = function(v) tset(me.lavas,k,Type.enumIndex(v));
		var height = function(v) tset(me.heights,k,v);
		var proba = function(v) tset(probas,k,v);
		switch( k ) {
		case KSoilTree:
			soil(BSoilTree);
			height(0.4);
		case KAutumnTree:
			soil(BAutumnTree);
			height(0.2);
		case KHighTree:
			soil(BHighTree);
			height(0.15);
		case KClouds:
			soil(BClouds);
			lava(BWater);
			height(1.5);
			proba(20);
		case KSphereTree:
			soil(BSphereTree);
			height(0.55);
			proba(70);
		case KLargeTree:
			soil(BLargeTree);
			height(0.35);
		case KSnowSapin:
			soil(BSnowSapin);
			proba(30);
		case KJungle:
			soil(BJungle);
			height(0.4);
			proba(60);
		case KCaverns:
			soil(BCaverns);
			proba(10);
		case KField:
			soil(BField);
			height(0.3);
		case KSwamp:
			soil(BSwamp);
			height(0.1);
		case KSoilPeaks:
			soil(BSoilPeaks);
			height(1.8);
			lava(BLava);
			proba(40);
		case KPilarPlain:
			soil(BPilarPlain);
			height(0.33);
			proba(16);
		case KFlowerPlain:
			soil(BFlowerPlain);
			height(0.15);
			proba(90);
		case KSavana:
			soil(BSavana);
			height(0.15);
			proba(65);
		case KDesert:
			soil(BDesert);
			height(0.3);
			proba(35);
		case KFlying:
			soil(BFlying);
			proba(5);
			height(0.3);
		}
	}

	static inline function tset<T>( t : Table<T>, k : Kind, v : T ) {
		t[Type.enumIndex(k)] = v;
	}

}

private class Cursor {
	public var r : mt.Rand;
	public var x : Int;
	public var y : Int;
	public var z : Int;

	public var d1 : Int;
	public var d2 : Int;
	public var d3 : Int;

	public function new() {
	}
	public inline function rand(k) {
		return r.random(k);
	}
	public inline function p(k) {
		return r.random(k) == 0;
	}
}

class Generator {

	static inline var X = 0;
	static inline var Y = GameConst.XYBITS;
	static inline var Z = GameConst.XYBITS + GameConst.XYBITS;
	static inline var XYSIZE = 1 << GameConst.XYBITS;
	static inline var ZSIZE = 1 << GameConst.ZBITS;
	static inline var ZMAX = ZSIZE - 2;
	static inline var DETSIZE = 32;

	public static var KINDS = Type.getEnumConstructs(Kind);
	public static var BKINDS = flash.Vector.ofArray(Lambda.array(
		Lambda.map(Type.getEnumConstructs(BlockKind),function(c) return Type.createEnum(BlockKind,c))
	));

	var t : Table<BlockKind>;
	var tables : Tables;
	var cur : Cursor;
	var cx : Int;
	var cy : Int;
	var u : Int;

	public function new(universe) {
		t = new Table(XYSIZE * XYSIZE * ZSIZE);
		tables = new Tables(this);
		u = universe;
	}

	static inline function tget<T>( t : Table<T>, k : Kind ) : T {
		return t[Type.enumIndex(k)];
	}

	inline function addr(x,y,z) {
		return (x<<X)|(y<<Y)|(z<<Z);
	}

	inline function outside(x,y,z) {
		return (x|y|(z<<(GameConst.XYBITS-GameConst.ZBITS))) >>> GameConst.XYBITS != 0;
	}

	inline function set(x,y,z,b) {
		if( z > 0 && !outside(x,y,z+2) ) t[addr(x,y,z)] = b;
	}

	inline function oset(x,y,z,b) {
		return if( z > 0 && !outside(x,y,z+2) ) {
			var a = addr(x,y,z);
			if( t[a] == null ) { t[a] = b; true; } else false;
		} else false;
	}

	inline function get(x,y,z) {
		return t[addr(x,y,z)];
	}

	inline function has(x,y,z) {
		return !outside(x,y,z) && get(x,y,z) != null;
	}

	public function generate( cx : Int, cy : Int ) {
		var world = new World(1234567 + u * 11);
		world.generate(cx,cy);
		this.cx = cx;
		this.cy = cy;

		// generate height table
		var hmap = new Table((XYSIZE + DETSIZE*2) * (XYSIZE + DETSIZE*2));
		var hpos = 0;
		var water = Type.enumIndex(BWater) | (1 << 8);
		for( y in -DETSIZE...XYSIZE+DETSIZE )
			for( x in -DETSIZE...XYSIZE+DETSIZE ) {
				var seed = world.zmap.getPixel(x+World.IMAX,y+World.IMAX) & 0xFFFFF;
				if( seed == 0 ) {
					hmap[hpos++] = water;
					continue;
				}
				var kind = tables.kmap[seed >> 16][seed & 0xFFFF];
				var gem = tables.gmap[seed % tables.gmap.length];
				var soil = tget(tables.soils,kind);
				var height = Std.int((world.hmap.getPixel(x+World.IMAX,y+World.IMAX) & 0xFF) * tget(tables.heights,kind) / (1 << (8 - GameConst.ZBITS)));
				var recall = false;
				while( height >= ZMAX ) {
					height -= ZMAX;
					height = ZMAX - height - 1;
					recall = true;
				}
				if( recall && height < ZMAX - 3 ) {
					var lava = tget(tables.lavas,kind);
					if( lava != 0 ) {
						soil = lava;
						height = ZMAX - 3 - height;
						height = Std.int(height * 0.5);
						height = ZMAX - 3 - height;
					}
				}
				if( height < 1 ) height = 1;
				hmap[hpos++] = (gem << 16) | ((height+1) << 8) | soil;
			}

		// fill table soil
		var t = t;
		var blocks = BKINDS;
		var rgem = new mt.Rand(0);
		for( y in 0...XYSIZE ) {
			hpos = (y + DETSIZE) * (XYSIZE + DETSIZE*2) + DETSIZE;
			for( x in 0...XYSIZE ) {
				var code = hmap[hpos++];
				var soil = blocks[code & 0xFF];
				var gem = code >>> 16;
				var h = (code >> 8) & 0xFF;
				var a = addr(x,y,0);
				while( h-- > 0 ) {
					if( gem == 0 || h == 0 )
						t[a] = soil;
					else {
						rgem.initSeed(((cx + x)&0xFFFFF) + ((cy + y)&0xFFFFF) * XYSIZE * 11);
						if( rgem.random(gem >> 8) == 0 )
							t[a] = blocks[gem & 0xFF];
						else
							t[a] = soil;
					}
					a += 1 << Z;
				}
			}
		}

		// generate details
		var dmap = new flash.display.BitmapData(256+DETSIZE*2,256+DETSIZE*2);
		dmap.perlinNoise(64,64,1,0,false,true,7,false,[new flash.geom.Point(cx-DETSIZE,cy-DETSIZE)]);
		cur = new Cursor();
		cur.r = new mt.Rand(0);
		hpos = 0;
		for( y in -DETSIZE...XYSIZE+DETSIZE )
			for( x in -DETSIZE...XYSIZE+DETSIZE ) {
				var hpos = hpos++;
				var seed = world.zmap.getPixel(x+World.IMAX,y+World.IMAX) & 0xFFFFF;
				if( seed == 0 ) continue;
				var kind = tables.kmap[seed >> 16][seed & 0xFFFF];
				var details = tget(tables.details,kind);
				if( details == null ) continue;
				// init cursor
				var d = dmap.getPixel(x+DETSIZE,y+DETSIZE);
				cur.d1 = (d & 0xFF) - 65;
				cur.d2 = ((d >> 8) & 0xFF) - 65;
				cur.d3 = ((d >> 16) & 0xFF) - 65;
				if( cur.d1 < 0 ) cur.d1 = 0 else if( cur.d1 > 127 ) cur.d1 = 127;
				if( cur.d2 < 0 ) cur.d2 = 0 else if( cur.d2 > 127 ) cur.d2 = 127;
				if( cur.d3 < 0 ) cur.d3 = 0 else if( cur.d3 > 127 ) cur.d3 = 127;
				cur.x = x;
				cur.y = y;
				cur.z = (hmap[hpos] >> 8) & 0xFF;
				cur.r.initSeed(((cx + x)&0xFFFFF) + ((cy + y)&0xFFFFF) * XYSIZE * 11);
				// generate details
				details();
			}

		// drop chests
		rgem.initSeed((cx&0xFFFFF) + (cy&0xFFFFF) * XYSIZE * 11);
		var chests = 4+rgem.random(3);
		var retry = 1000;
		while( retry > 0 && chests > 0 ) {
			var x = rgem.random(XYSIZE);
			var y = rgem.random(XYSIZE);
			var pos = (x + DETSIZE) + (y + DETSIZE) * (XYSIZE + DETSIZE*2);
			var h = (hmap[pos] >> 8) & 0xFF;
			if( h > 1 && oset(x,y,h,BChest) ) {
				retry = 1000;
				chests--;
			} else
				retry--;
		}
		if( chests > 0 ) {
			var mx = cx >> GameConst.XYBITS;
			var my = cy >> GameConst.XYBITS;
			if( Math.sqrt(mx*mx+my*my) < 20 )
				chests = 0;
			else
				chests = 1;
		}
		while( chests > 0 ) {
			var x = rgem.random(XYSIZE-8) + 4;
			var y = rgem.random(XYSIZE-8) + 4;
			var pos = (x + DETSIZE) + (y + DETSIZE) * (XYSIZE + DETSIZE*2);
			var h = (hmap[pos] >> 8) & 0xFF;
			if( h > 1 ) continue;
			chests -= 2 + rgem.random(2);
			for( dx in -2...4 )
				for( dy in -2...4 )
					for( h in 1...4 ) {
						var center = dx >= -1 && dx <= 2 && dy >= -1 && dy <= 2;
						set(x+dx,y+dy,h,center ? ((h == 3) ? BWater : BChest) : BInvisible);
					}
		}

		// drop dolparts
		var dolparts = 2+rgem.random(8);
		var retry = 10000;
		while( retry > 0 && dolparts > 0 ) {
			var x = rgem.random(XYSIZE-2)+1;
			var y = rgem.random(XYSIZE-2)+1;
			var pos = (x + DETSIZE) + (y + DETSIZE) * (XYSIZE + DETSIZE*2);
			var h = (hmap[pos] >> 8) & 0xFF;
			if( h > 1 && oset(x,y,h,BDolpart) ) {
				oset(x,y,h+1,BDolpart);
				oset(x,y,h+2,BDolpart);
				retry = 10000;
				dolparts--;
			} else
				retry--;
		}


		// fill water
		for( x in 0...XYSIZE )
			for( y in 0...XYSIZE )
				t[addr(x,y,0)] = BWater;

		// cleanup
		dmap.dispose();
		world.dispose();
		return t;
	}

	public function generateEmpty() {
		for( x in 0...XYSIZE )
			for( y in 0...XYSIZE )
				t[addr(x,y,0)] = BWater;
		return t;
	}

	function grid( g ) {
		return ((cur.x+cx)&0xFFFFFF)%g == 0 && ((cur.y+cy)&0xFFFFFF)%g == 1;
	}

	function KSoilTree() {
		if( !grid(2) || !cur.p(10) )
			return;
		genClassicTree(3,5,BSoilTree1,BSoilTree2);
	}

	function KAutumnTree() {
		if( (cur.d1*cur.d2) & 7 == 0 )
			set(cur.x,cur.y,cur.z-1,BAutumnTree2);
		if( !grid(3) || !cur.p(7) )
			return;
		genClassicTree(4,7,BAutumnTree1,BAutumnTree2);
	}

	function KHighTree() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(3) )
			return;
		for( dx in -2...3 )
			for( dy in -2...3 )
				if( dx*dx+dy*dy < 8 )
					if( has(cur.x+dx,cur.y+dy,cur.z-1) )
						set(cur.x+dx,cur.y+dy,cur.z-1,BHighTree3);
		genRTree(10+cur.rand(7),BHighTree1,BHighTree2);
	}

	function KClouds() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(40) )
			return;
		var z = cur.z + 12 + cur.rand(10);
		var size = 3 + cur.rand(4);
		var ray = size * size;
		if( z + size >= ZSIZE - 3 ) z = ZSIZE - 3 - size;
		for( dx in -size...size+1 )
			for( dy in -size...size+1 )
				for( dz in -size...size+1 ) {
					var dist = dx*dx + dy*dy + dz*dz;
					if( dist < ray ) {
						if( dist <= ray>>1 )
							oset(cur.x+dx,cur.y+dy,z+dz,BClouds1);
						else
							oset(cur.x+dx,cur.y+dy,z+dz,BClouds2);
					}
				}
	}

	function KSphereTree() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(10) )
			return;
		var size = 3 + cur.rand(4);
		for( dx in -size...size+1 )
			for( dy in -size...size+1 )
				for( dz in -size...size+1 )
					if( dx*dx + dy*dy + dz*dz < size * size )
						oset(cur.x+dx,cur.y+dy,cur.z+dz,BSphereTree1);
	}

	function KLargeTree() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(80) )
			return;
		var size = 4;
		var ox = cur.x, oy = cur.y;
		for( dx in -size...size+1 )
			for( dy in -size...size+1 )
				if( dx * dx + dy * dy < size * size ) {
					cur.x = ox + dx;
					cur.y = oy + dy;
					genRTree(8+cur.rand(15),BLargeTree1,BLargeTree2);
					var dz = 0;
					for( k in 0...20 ) {
						oset(cur.x,cur.y,cur.z+dz-1,BLargeTree1);
						if( cur.rand(30) == 0 && dz > -3  ) dz--;
						if( cur.rand(30) == 0 && dz < 1 ) dz++;
						if( cur.rand(5) == 0 ) cur.x++;
						if( cur.rand(5) == 0 ) cur.x--;
						if( cur.rand(5) == 0 ) cur.y++;
						if( cur.rand(5) == 0 ) cur.y--;
					}
					dz += 8+cur.rand(15);
					if( has(cur.x,cur.y,cur.z+dz) && get(cur.x,cur.y,cur.z+dz) == BLargeTree2 )
						set(cur.x,cur.y,cur.z+dz,BFruit);
				}
	}

	function KSnowSapin() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(10) )
			return;
		set(cur.x,cur.y,cur.z++,BSnowSapin1);
		set(cur.x,cur.y,cur.z++,BSnowSapin1);
		var size = 2 + cur.rand(3);
		var k = 0;
		while( size > 0 ) {
			for( dx in -size...size+1 )
				for( dy in -size...size+1 )
					if( dx * dx + dy * dy < size * size )
						set(cur.x+dx,cur.y+dy,cur.z,BSnowSapin2);
			cur.z++;
			if( k > 0 && cur.rand(4-k) == 0 ) {
				k = 0;
				size--;
			} else
				k++;
		}
	}

	function KJungle() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(2) )
			return;
		var x = cur.x, y = cur.y, z = cur.z;
		var b = switch( cur.rand(9) ) { case 0,1: BJungle1; case 2,3: BJungle2; default: BJungle3; };
		for( i in 0...5+cur.rand(50) ) {
			if( cur.rand(3) == 0 ) z++;
			if( cur.rand(30) == 0 ) z--;
			if( cur.rand(5) == 0 ) x++;
			if( cur.rand(5) == 0 ) x--;
			if( cur.rand(5) == 0 ) y++;
			if( cur.rand(5) == 0 ) y--;
			oset(x,y,z,b);
		}
		for( i in 0...50 ) {
			if( cur.rand(5) == 0 ) x++;
			if( cur.rand(5) == 0 ) x--;
			if( cur.rand(5) == 0 ) y++;
			if( cur.rand(5) == 0 ) y--;
			oset(x,y,z,b);
		}
		if( !cur.p(10) )
			return;
		x = cur.x; y = cur.y; z = cur.z + 15;
		for( i in 0...10 )
			if( has(x,y,--z) ) {
				var dx = 0, dy = 0;
				switch( cur.rand(4) ) {
				case 0: dx = 1;
				case 1: dx = -1;
				case 2: dy = 1;
				default: dy = -1;
				}
				set(x+dx,y+dy,z,BKoala);
				set(x-dx,y-dy,z,BKoala);
				x += dy; y += dx;
				set(x,y,z,BKoala);
				set(x,y,z+1,BKoala);
				return;
			}
	}

	function KCaverns() {
		if( (cur.d1+cur.d2) & 16 != 0 )
			return;
		var z = cur.z >> 2;
		if( z == 0 ) {
			set(cur.x,cur.y,z++,BCaverns);
			set(cur.x,cur.y,z++,BCaverns);
			set(cur.x,cur.y,z++,BCaverns);
			set(cur.x,cur.y,z++,BCaverns1);
		} else {
			set(cur.x,cur.y,z++,BCaverns1);
			set(cur.x,cur.y,z++,null);
			set(cur.x,cur.y,z++,null);
			set(cur.x,cur.y,z++,null);
			if( has(cur.x,cur.y,z) ) {
				set(cur.x,cur.y,z,BCaverns1);
				if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(10) )
					return;
				set(cur.x,cur.y,--z,BCaverns2);
				set(cur.x,cur.y,--z,BCaverns2);
				set(cur.x,cur.y,--z,BCaverns2);
			}
		}
	}

	function KField() {
		if( cur.d1 > 115 || cur.d2 > 115 ) {
			if( cur.d1 > 120 || cur.d2 > 120 )
				set(cur.x,cur.y,cur.z,BField1);
		} else if( (cur.d1*cur.d2) & 8 == 0 )
			set(cur.x,cur.y,cur.z,BField2);
	}

	function KSwamp() {
		if( (cur.d1+cur.d2) & 16 == 0 )
			set(cur.x,cur.y,cur.z-1,BSwamp3);
		if( cur.p(31) )
			genRTree(3 + cur.rand(4),BSwamp1,BSwamp2);
	}

	function KSoilPeaks() {
		if( (cur.d1+cur.d2) & 8 == 0 )
			set(cur.x,cur.y,cur.z,BSoilPeaks1);
	}

	function KPilarPlain() {
		if( (cur.d3&15) >= 12 )
			set(cur.x,cur.y,cur.z-1,BPilarPlain1);
		else if( (cur.d3&15) <= 3 && cur.p(101) ) {
			// pillar
			var size = 9 + cur.rand(9);
			for( z in 0...size ) {
				set(cur.x,cur.y,cur.z+z,BPilarPlain2);
				if( (z & 1) == 1 ) {
					if( cur.p(5) ) set(cur.x+1,cur.y,cur.z+z,BPilarPlain2);
					if( cur.p(5) ) set(cur.x-1,cur.y,cur.z+z,BPilarPlain2);
					if( cur.p(5) ) set(cur.x,cur.y-1,cur.z+z,BPilarPlain2);
					if( cur.p(5) ) set(cur.x,cur.y+1,cur.z+z,BPilarPlain2);
				}
			}
		}
	}

	function KFlowerPlain() {
		if( cur.p(11) )
			set(cur.x,cur.y,cur.z-1,BFlowerPlain1);
		else if( cur.p(101) )
			set(cur.x,cur.y,cur.z-1,BFlowerPlain2);
		else if( cur.p(2001) && has(cur.x-2,cur.y,cur.z-1) ) {
			// stonedge
			for( z in 0...5 ) {
				set(cur.x,cur.y,cur.z+z,BFlowerPlain3);
				set(cur.x-2,cur.y,cur.z+z,BFlowerPlain3);
			}
			set(cur.x-1,cur.y,cur.z+4,BFlowerPlain3);
		}
	}

	function KSavana() {
		if( !grid(5) || !cur.p(11) ) {
			// bush
			if( (cur.x+cx+cur.y+cy)&3 == 0 && (cur.d1 % 20) == 1 )
				set(cur.x,cur.y,cur.z,BSavana1);
			return;
		}
		var dx, dy;
		if( cur.p(2) ) {
			dx = -1;
			dy = 0;
		} else {
			dx = 0;
			dy = -1;
		}
		var x = cur.x, y = cur.y, z = cur.z;
		if( cur.p(3) ) {
			// zebre
			if( has(x+dx*2,y+dy*2,z-1) ) {
				set(x,y,z,BSavana2);
				set(x+dx*2,y+dy*2,z,BSavana2);
				set(x,y,z+1,BSavana2);
				set(x+dx,y+dy,z+1,BSavana2);
				set(x+dx*2,y+dy*2,z+1,BSavana2);
				set(x,y,z+2,BSavana2);
				set(x-dx,y-dy,z+2,BSavana2);
			}
		} else if( cur.p(13) )  {
			// elephant
			if( has(x+dx*2,y+dy*2,z-1) && has(x+dy,y+dx,z-1) && has(x+dx*2+dy,y+dy*2+dx,z-1) ) {
				set(x,y,z,BSavana3);
				set(x+dy,y+dx,z,BSavana3);
				set(x+dx*2,y+dy*2,z,BSavana3);
				set(x+dx*2+dy,y+dy*2+dx,z,BSavana3);
				for( k in 0...3 ) {
					z++;
					for( mx in -1...4 )
						for( my in -1...3 )
							set(x+mx*dx+my*dy,y+mx*dy+my*dx,z,BSavana3);
				}
				for( k in 0...2 ) {
					set(x+dx*4,y+dy*4,z,BSavana3);
					set(x+dx*4+dy,y+dy*4+dx,z,BSavana3);
					set(x+dx*5,y+dy*5,z,BSavana3);
					set(x+dx*5+dy,y+dy*5+dx,z,BSavana3);
					z--;
				}
				set(x+dx*5,y+dy*5,z,BSavana3);
				set(x+dx*5+dy,y+dy*5+dx,z,BSavana3);
			}
		}
	}

	function KDesert() {
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(19) )
			return;
		for( z in 0...2+cur.rand(3)  )
			set(cur.x,cur.y,cur.z++,BDesert1);
		cur.z--;
		if( cur.p(2) ) {
			for( z in 0...2 )
				set(cur.x-1,cur.y,cur.z+z,BDesert1);
			if( cur.p(2) )
				for( z in 0...2 )
					set(cur.x+1,cur.y,cur.z+z,BDesert1);
		} else if( cur.p(2) ) {
			for( z in 0...2 )
				set(cur.x,cur.y-1,cur.z+z,BDesert1);
			if( cur.p(2) )
				for( z in 0...2 )
					set(cur.x,cur.y+1,cur.z+z,BDesert1);
		}
	}

	function KFlying() {
		// reverse
		var blocks = new Array();
		while( true ) {
			var z = blocks.length+1;
			if( !has(cur.x,cur.y,z) ) break;
			blocks.push(get(cur.x,cur.y,z));
			set(cur.x,cur.y,z,null);
		}
		cur.z = ZMAX - ((blocks.length * 3) >> 1);
		for( b in blocks )
			set(cur.x,cur.y,cur.z++,b);
		if( (cur.x+cx+cur.y+cy)&7 != 0 || !cur.p(17) )
			return;
		for( z in 0...2+cur.rand(3)  )
			set(cur.x,cur.y,cur.z++,BFlying1);
		cur.z--;
		for( d in 1...3 ) {
			set(cur.x+d,cur.y,cur.z,BFlying2);
			set(cur.x-d,cur.y,cur.z,BFlying2);
			set(cur.x,cur.y+d,cur.z,BFlying2);
			set(cur.x,cur.y-d,cur.z,BFlying2);
		}
	}

	function genClassicTree(size,size2,wood,leaves) {
		size += cur.rand(size2);
		for( k in 0...size )
			set(cur.x,cur.y,cur.z++,wood);
		var l = size >> 1;
		var repeat = 4;
		while( l >= 0 ) {
			for( dx in -l...l+1 )
				for( dy in -l...l+1 )
					oset(cur.x+dx,cur.y+dy,cur.z,leaves);
			cur.z++;
			if( repeat == 0 || cur.rand(2) == 0 ) {
				repeat = 4;
				l--;
			} else
				repeat--;
		}
	}

	function genRTree( size : Int, tree : BlockKind, leaves : BlockKind ) {
		if( size + cur.z >= ZMAX-1 ) {
			var s2 = ZMAX - 1 - cur.z;
			if( s2 < Std.int(size/3) )
				return;
			size = s2;
		}
		if( cur.p(3) ) {
			var dz = 0;
			while( oset(cur.x+1,cur.y,cur.z-dz,tree) )
				dz++;
		}
		if( cur.p(3) ) {
			var dz = 0;
			while( oset(cur.x-1,cur.y,cur.z-dz,tree) )
				dz++;
		}
		if( cur.p(3) ) {
			var dz = 0;
			while( oset(cur.x,cur.y-1,cur.z-dz,tree) )
				dz++;
		}
		if( cur.p(3) ) {
			var dz = 0;
			while( oset(cur.x,cur.y+1,cur.z-dz,tree) )
				dz++;
		}
		for( dz in 0...size )
			set(cur.x,cur.y,cur.z+dz,tree);
		var dz = size - 1;
		for( i in 0...10 ) {
			var dx = 0, dy = 0;
			for( k in 0...20 ) {
				oset(cur.x+dx,cur.y+dy,cur.z+dz,leaves);
				switch( cur.rand(5) ) {
				case 0: dx++;
				case 1: dy++;
				case 2: dx--;
				case 3: dy--;
				case 5: if( cur.rand(7) == 0 ) dz-- else if( cur.rand(7) == 0 ) dz++;
				}
			}
		}
	}

}