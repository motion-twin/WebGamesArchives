package gen;

typedef ClimInfos = {
	var water : Int;
	var heights : Array<{ v : Float, h : Int }>;
	var holes : { size : Int, min : Float, max : Float };
	var caves : { size : Int, value : Float };
}

class Generator {

	static inline var EMPTY = 0;
	static inline var BEDROCK = 1;
	static inline var WATER = 2;
	static inline var SOIL = 3;
	static inline var CLOSED = 4;

	static var CLIMATES : Array<ClimInfos> = [
		{
			water : 64,
			heights : [ { v : -1., h : -8 }, { v : 0.,  h : 0 }, { v : 0.3, h : 4 }, { v : 0.4, h : 7 }, { v : 0.6, h : 7 }, { v : 1.0, h : 20 } ],
			holes : null,//{ size : 15, min : -0.6, max : 0.8 },
			caves : { size : 80, value : 0.97 },
		},
		{
			water : 32,
			heights : [ { v : -1, h : -2 }, { v : 0.3, h : 0 }, { v : 0.6, h : 4 } , { v : 1., h : 16 } ],
			holes : null,
			caves : null,
		}
	];
	static var DEF_CLIMATE = {
		water : 64,
		heights : [ { v : -1, h : -64 }, { v : 0, h : 0 }, { v : 1., h : 64 } ],
		holes : null,
		caves : null,
	};

	var size : Int;
	var height : Int;
	var seed : Int;
	var rnd : mt.Rand;
	
	var hmap : FPerlin;
	var realHeightMin : Float;
	var realHeightScale : Float;
	
	var outHeight : Int;
	var outPos : Int;
	
	var lastTime : Int;
	
	var infos : ClimInfos;
	public var fast : Bool;
	
	public function new(size,height,seed) {
		this.size = size;
		this.seed = seed;
		this.height = height;
		hmap = new FPerlin(size);
		outHeight = hmap.buf.length;
		hmap.buf.length += size * size;
		outPos = hmap.buf.length;
		hmap.buf.length += size * size * height;
	}
	
	inline function fset(addr, v) {
		flash.Memory.setByte(addr + outPos, v);
	}

	inline function fget(addr) {
		return flash.Memory.getByte(addr + outPos);
	}
	
	inline function hval(addr) {
		return flash.Memory.getByte(addr + outHeight);
	}
	
	inline function realHeight(p) {
		 return (flash.Memory.getDouble(hmap.outOffset + (p << 3)) - realHeightMin) * realHeightScale;
	}
	
	inline function time(name) {
		var t = flash.Lib.getTimer();
		trace(name + " " + (t - lastTime));
		lastTime = t;
	}
	
	public function generate(climate) {
		
		this.infos = CLIMATES[climate];
		if( infos == null )
			infos = DEF_CLIMATE;
		
		lastTime = flash.Lib.getTimer();
		
		rnd = new mt.Rand(climate);
		
		hmap.init(seed, 0, 0);
		hmap.clear();
		makeHMap();
		
		time("hmap");
		
		// fill height
		var wh = infos.water;
		var heights = new flash.Vector<Int>();
		var maxHeight = 0;
		var hmin = infos.heights[0].v;
		var hmax = infos.heights[infos.heights.length - 1].v;
		var hscale = 65535 / (hmax - hmin);
		this.realHeightMin = hmin;
		this.realHeightScale = hscale;
		var pos = 0;
		var prev = infos.heights[0];
		for( h in infos.heights ) {
			var target = Std.int((h.v - hmin) * hscale);
			if( target > pos ) {
				var cur = 0.;
				var dt = 1. / (target - pos);
				while( pos < target ) {
					var h = Std.int(prev.h * (1 - cur) + h.h * cur + wh);
					if( h > maxHeight ) maxHeight = h;
					heights[pos++] = h;
					cur += dt;
				}
			}
			prev = h;
		}
		while( pos < 65536 )
			heights[pos++] = prev.h + wh;
		
		var waterLimit = 65536;
		for( i in 0...65536 )
			if( heights[i] > wh+1 ) {
				waterLimit = i-1;
				break;
			}
				
		for( p in 0...size * size ) {
			var fh = Std.int(realHeight(p));
			if( fh < 0 ) fh = 0 else if( fh > 0xFFFF ) fh = 0xFFFF;
			flash.Memory.setByte(outHeight + p, heights[fh]);
		}

		time("height");
		
		// smooth height
		smoothHeight();
		smoothHeight();
		
		time("smooth");
		
		var hmax = 0;
		
		// fill soil
		for( p in 0...size * size ) {
			var h = hval(p);
			var addr = p * height;
			for( i in 0...h )
				fset(addr++, SOIL);
			if( realHeight(p) < waterLimit )
				for( i in h...wh+1 )
					fset(addr++, WATER);
		}
		
		time("soil");

		// make holes
		if( infos.holes != null && infos.holes.size > 1 ) {
			var gscale = hmap.initScale(1 / infos.holes.size);
			var zmin = infos.holes.min;
			var zscale = (infos.holes.max - infos.holes.min) / maxHeight;
			for( y in 0...size )
				for( x in 0...size ) {
					var p = x + y * size;
					if( realHeight(p) < waterLimit )
						continue;
					var h = hval(p);
					var min = wh + 1;
					var addr = p * height + min;
					for( z in 0...h-min ) {
						var g = hmap.gradient3DAt(x * gscale, y * gscale, z * gscale);
						if( g < zmin+z*zscale )
							fset(addr, EMPTY);
						addr++;
					}
				}
			time("holes");
		}
		
		// make caverns
		if( infos.caves != null && infos.caves.size > 1 && !fast ) {
			var gscale = hmap.initScale(1 / infos.caves.size);
			var g2scale = gscale * 0.5;
			var max = infos.caves.value;
			for( y in 0...size )
				for( x in 0...size ) {
					var p = x + y * size;
					var addr = p * height;
					var h = hval(p);
					if( h <= wh ) h = (h * 3) >> 2;
					for( z in 0...h ) {
						var g1 = hmap.gradient3DAt(x * gscale, y * gscale, z * gscale);
						if( g1 < 0 ) g1 = -g1;
						var g2 = hmap.gradient3DAt(x * g2scale, y * g2scale, z * g2scale);
						if( g2 < 0 ) g2 = -g2;
						var g = 1 - (g1 * 0.667 + g2 * 0.334);
						if( g > max )
							fset(addr, EMPTY);
						addr++;
					}
				}
			time("caves");
		}

		if( !fast ) {
			for( i in 0...10 )
				if( smooth3DEmpty() <= 1 )
					break;

			for( i in 0...10 )
				if( smooth3D() <= 1 )
					break;
					
			time("smooth3D");
		}

		// make sure water touch soil
		var addr = 0;
		for( y in 0...size )
			for( x in 0...size )
				for( z in 0...height ) {
					var f = fget(addr);
					if( f != WATER ) {
						addr++;
						continue;
					}
					var a = addr + (x == 0 ? size - 1 : -1) * height;
					if( fget(a) == EMPTY ) fset(a, SOIL);
					var a = addr + (x == size - 1 ? - (size - 1) : 1) * height;
					if( fget(a) == EMPTY ) fset(a, SOIL);
					var a = addr + (y == 0 ? size - 1 : -1) * height * size;
					if( fget(a) == EMPTY ) fset(a, SOIL);
					var a = addr + (y == size - 1 ? -(size - 1) : 1) * height * size;
					if( fget(a) == EMPTY ) fset(a, SOIL);
					if( z > 0 ) {
						var a = addr - 1;
						if( fget(a) == EMPTY ) fset(a, SOIL);
					}
					addr++;
				}
		time("checkwater");
		
		// fill bedrock
		for( p in 0...size * size )
			fset(p * height, BEDROCK);
			
		time("bedrock");
		
		return wh;
	}

	function smoothHeight() {
		var addr = 0;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = (hval(addr) << 2) + (hval(x == 0 ? addr + size - 1 : addr - 1) + hval(x == size - 1 ? addr - (size - 1) : addr + 1) + hval(y == 0 ? addr + (size - 1) * size : addr - size) + hval(y == size - 1 ? addr - (size - 1) * size : addr + size)) * 3;
				flash.Memory.setByte(outHeight + addr, (h + 7) >> 4);
				addr++;
			}
	}
	
	function smooth3D() {
		var changed = 0;
		var wh = infos.water;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = hval(x + y * size);
				if( h <= wh ) continue;

				
				var addr = (x + y * size) * height + wh;
				for( z in wh...height ) {
					var count = 0;
					if( fget(addr) != SOIL ) {
						addr++;
						continue;
					}
					if( fget(addr + (x == 0 ? size - 1 : -1) * height) != EMPTY )
						count++;
					if( fget(addr + (x == size - 1 ? -(size - 1) : 1) * height) != EMPTY )
						count++;
					if( fget(addr - 1) == SOIL )
						count++;
					if( z < height - 1 && fget(addr + 1) != EMPTY )
						count++;
					if( fget(addr + (y == 0 ? size - 1 : -1) * height * size) != EMPTY )
						count++;
					if( fget(addr + (y == size - 1 ? -(size - 1) : 1) * height * size) != EMPTY )
						count++;
					if( count <= 2 ) {
						changed++;
						fset(addr, EMPTY);
					}
					addr++;
				}
			}
		return changed;
	}
	
	function smooth3DEmpty() {
		var changed = 0;
		var wh = infos.water;
		for( y in 0...size )
			for( x in 0...size ) {
				var h = hval(x + y * size);
				if( h <= wh ) continue;

				
				var addr = (x + y * size) * height + wh;
				for( z in wh...height ) {
					var count = 0;
					if( fget(addr) != EMPTY ) {
						addr++;
						continue;
					}
					if( fget(addr + (x == 0 ? size - 1 : -1) * height) != EMPTY )
						count++;
					if( fget(addr + (x == size - 1 ? -(size - 1) : 1) * height) != EMPTY )
						count++;
					if( fget(addr - 1) == SOIL )
						count++;
					if( z < height - 1 && fget(addr + 1) != EMPTY )
						count++;
					if( fget(addr + (y == 0 ? size - 1 : -1) * height * size) != EMPTY )
						count++;
					if( fget(addr + (y == size - 1 ? -(size - 1) : 1) * height * size) != EMPTY )
						count++;
					if( count >= 4 ) {
						changed++;
						fset(addr, SOIL);
					}
					addr++;
				}
			}
		return changed;
	}
	
	function makeHMap() {
		var scale = (rnd.rand() * 4 + 1) / 180;
		var curve = 0.5 + srand(0.4);
		if( curve < 0.2 ) curve = 0.2;
		if( curve > 0.8 ) curve = 0.8;
		var tscale = 0.;
		for( s in [1., 2., 3., 4.] ) {
			var power = 1 - (s == 1. ? 0 : Math.pow(curve, s - 1));
			tscale += power;
			hmap.add(scale * s, power);
		}
		hmap.addMul(tscale, 0.6 / tscale);

		var adj = 3.1 + srand(2);
		hmap.adjust(scale / (2 + rnd.rand() * 2), adj);
		hmap.addMul( -(adj * 0.5), 2/adj );
	}
	
	public function getBitmap() {
		var water = 0.;
		
		if( infos.caves != null ) {
			var gscale = hmap.initScale(1 / infos.caves.size);
			var g2scale = gscale * 0.5;
			var max = infos.caves.value;
			for( y in 0...size )
				for( x in 0...size ) {
					var z = 0;
					var p = x + y * size;
					var g1 = hmap.gradient3DAt(x * gscale, y * gscale, z * gscale);
					if( g1 < 0 ) g1 = -g1;
					var g2 = hmap.gradient3DAt(x * g2scale, y * g2scale, z * g2scale);
					if( g2 < 0 ) g2 = -g2;
					var g = 1 - (g1 * 0.667 + g2 * 0.334);
					flash.Memory.setDouble(hmap.outOffset + (p << 3), 1-1.5/g - 0.3);
				}
		}
		
		hmap.setGradientAlpha([ { v : -1., c : 0xFFFFFF00 }, { v : -1. +0.0001, c : 0xFF000000 }, { v : water, c : 0xFF0000FF },  { v : water, c : 0xFF004000 }, { v : 1. -0.0001, c : 0xFFFFFFFF }, { v : 1., c : 0xFFFF0000 } ]);
		hmap.mergeGradientAlpha();
		
		var bmp = new flash.display.BitmapData(size, size, true, 0);
		bmp.setPixels(bmp.rect, hmap.getPixels());
		
		return bmp;
	}
	
	public function getBytes() {
		var out = new flash.utils.ByteArray();
		out.writeBytes(hmap.buf, outPos, size * size * height);
		return out;
	}
		
	inline function srand( v : Float ) {
		return rnd.rand() * (v * 2) - v;
	}
	
	
}