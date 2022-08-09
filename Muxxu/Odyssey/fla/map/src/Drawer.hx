import Protocol;

private typedef Tile = {
	var cl : Class<Dynamic>;
	var pattern : Array<Array<flash.display.BitmapData>>;
	var color : Int;
	var ground : Array<{ b : flash.display.BitmapData, dy : Int }>;
	var groundDensity : Int;
	var brush : Array<{ b : flash.display.BitmapData, dy : Int }>;
	var brushLevel : Int;
}

class Drawer {

	public static inline var SIZE = 30;
	public static inline var TILE_LEVELS = 3;
	static inline var SHOW_GRID = false;
	static var TILES : { grounds : Array<Tile>, tiles : Array<Tile> };

	public static function initTiles() {
		if( TILES == null )
			TILES = {
				grounds : [
					/* 0 */ tile(fl.tiles.Island, 0xAFA126),
					/* 1 */ tile(fl.tiles.Aride, 0x807654),
					/* 2 */ tile(fl.tiles.Dust, 0x5E666D),
					/* 4 */ tile(fl.tiles.Dust2, 0x6B6A4F),
					/* 3 */ tile(fl.tiles.Cliff, 0x4D4F4A),
					/* 5 */ tile(fl.tiles.Cliff2, 0x6B7266),
				],
				tiles : [
					/* 0 */tile(fl.tiles.Grass, 	0x547935,	2, 110),
					/* 1 */tile(fl.tiles.Rock, 		0x344340, 	2, 150),
					/* 2 */tile(fl.tiles.Sand, 		0xE7C13D,	3, 160),
					/* 3 */tile(fl.tiles.Ground, 	0x624E31,	2, 140),
					/* 4 */tile(fl.tiles.Marecage, 	0x373F2A, 	1, 120),
					/* 5 */tile(fl.tiles.Gravier, 	0x8E6F34, 	2, 120),
					/* 6 */tile(fl.tiles.Ice, 		0xFFFFFF, 	1, 110),
					/* 7 */tile(fl.tiles.Lava, 		0x3F2A26, 	1, 160),
					/* 8 */tile(fl.tiles.Pierre, 	0x565E69, 	1, 140),
					/* 9 */tile(fl.tiles.Water, 	0x357991, 	1, 150),
					/* 10 */tile(fl.tiles.Graveyard, 0x49473D, 	1, 120),
					/* 11 */tile(fl.tiles.Fields, 	0x8AAA00,	1, 140),
					/* 12 */tile(fl.tiles.Jungle, 	0x3E494F,	1, 100),
					/* 13 */tile(fl.tiles.Mountain,	0x3E494F,	1, 120),
					//un truc super svvauvage pour drune
				],
			}
		return TILES;
	}

	var i : MapIsland;
	var bmp : flash.display.BitmapData;
	var m : flash.geom.Matrix;
	var pt : flash.geom.Point;
	public var placeBits : Bits;
	public var pathBits : Bits;

	public function new(i) {
		this.i = i;
		m = new flash.geom.Matrix();
		m.identity();
		pt = new flash.geom.Point();
	}

	public function getPlaceFrame( id : Int, k : _PK, used : Bool ) {
		return switch(k) {
		case PEmpty: 4;
		case PMonsters: used ? 2 : 1;
		case PObject(_): used ? 6 : 5;
		case PGold(n): used ? 4 : [39,40,41][n];
		case PPort: 7;
		case PRumor(_): 8;
		case PPnj(_): 18 + (id&3);
		case PInn: 22;
		case PFountain: 23;
		case PTest: used ? 4 : 3;
		case PRuins: 25;
		case PDistill: 26;
		case PDirection: 24;
		case PMerchant: 15 + (id & 1);
		case PBoss(_): used ? 4 : 1;
		case PLibrary: used ? 36 : 35;
		case PShrine: used ? 38 : 37;
		case PGod(g): [10, 13, 12, 14, 11][g];
		case PUpFood: 17;
		};
	}

	inline function put( x : Float, y : Float, o : flash.display.DisplayObject ) {
		m.tx = x * SIZE;
		m.ty = y * SIZE;
		bmp.draw(o, m);
	}

	inline function bput( x : Int, y : Int, o : flash.display.BitmapData ) {
		pt.x = x;
		pt.y = y;
		bmp.copyPixels(o, o.rect, pt, null, null, true );
	}

	function frames<T>( cl : Class<T> ) : Array<flash.display.MovieClip> {
		var a = new Array();
		var m : flash.display.MovieClip = cast Type.createInstance(cl,[]);
		m.stop();
		a.push(m);
		for( f in 2...m.totalFrames + 1 ) {
			var m : flash.display.MovieClip = cast Type.createInstance(cl,[]);
			m.gotoAndStop(f);
			a.push(m);
		}
		return a;
	}

	function bitmaps( cl : Class<Dynamic> ) {
		var a = new Array();
		for( mc in frames(cl) ) {
			var b = mc.getBounds(mc);
			var bmp = new flash.display.BitmapData(Math.round(b.right),Math.round(b.bottom), true, 0);
			bmp.draw(mc, m);
			a.push(bmp);
		}
		return a;
	}

	function tileBitmap( mc : flash.display.MovieClip ) {
		var bmps = new Array();
		if( mc == null )
			return bmps;
		var filters = mc.filters;
		var m = new flash.geom.Matrix();
		var p0 = new flash.geom.Point(0, 0);
		for( i in 0...mc.totalFrames ) {
			mc.gotoAndStop(i + 1);
			var bounds = mc.getBounds(mc);
			var height = Math.ceil(bounds.height);
			var width = Math.ceil(bounds.width);
			if( width <= 0 ) width = 1;
			if( height <= 0 ) height = 1;
			var b = new flash.display.BitmapData(width, height, true, 0);
			m.ty = -bounds.top;
			m.tx = -bounds.left;
			b.draw(mc,m);
			bmps.push({ b : b, dy : Std.int(bounds.top) });
			for( f in filters )
				b.applyFilter(b, b.rect, p0, f);
		}
		return bmps;
	}

	static function tile(cl : Class<Dynamic>, color, ?groundDensity = 0, ?brushLevel = 128) : Tile {
		return {
			cl : cl,
			pattern : null,
			color : color,
			ground : null,
			groundDensity : groundDensity,
			brush : null,
			brushLevel : brushLevel,
		};
	}

	function makeTile( t : Tile ) {
		if( t.brush != null )
			return;
		var tileMC : flash.display.MovieClip = Type.createInstance(t.cl, []);
		var p0 = new flash.geom.Point(0, 0);
		// init pattern
		var pat : flash.display.MovieClip = Reflect.field(tileMC, __unprotect__("pattern"));
		if( pat == null )
			throw "Tile " + Type.getClassName(t.cl) + " missing pattern";
		var pattern = [];
		var tex : flash.display.MovieClip = Reflect.field(pat, __unprotect__("tex"));
		var msk : flash.display.MovieClip = Reflect.field(pat, __unprotect__("msk"));
		var filters = pat.filters;
		for( f in 0...((tex == null) ? 1 : tex.totalFrames) ) {
			var bmps = [null];
			pattern.push(bmps);
			if( tex != null )
				tex.gotoAndStop(f + 1);
			for( i in 1...16 ) {
				pat.gotoAndStop(i + 1);
				if( msk != null )
					msk.gotoAndStop(i + 1);
				var bounds = pat.getBounds(pat);
				var width = Math.round(bounds.right);
				var height = Math.round(bounds.bottom);
				if( width > SIZE ) width = SIZE;
				if( height > SIZE ) height = SIZE;
				if( SHOW_GRID ) {
					width--;
					height--;
				}
				var b = new flash.display.BitmapData(width, height, true, 0);
				b.draw(pat);
				bmps.push(b);
				for( f in filters )
					b.applyFilter(b, b.rect, p0, f);
			}
		}
		t.pattern = pattern;
		// init ground
		var gr : flash.display.MovieClip = Reflect.field(tileMC, __unprotect__("ground"));
		t.ground = tileBitmap(gr);
		// init brush
		var br : flash.display.MovieClip = Reflect.field(tileMC, __unprotect__("brush"));
		t.brush = tileBitmap(br);
	}

	public function makeView() {
		var s = new flash.display.Sprite();
		s.addChild(new flash.display.Bitmap(bmp,flash.display.PixelSnapping.ALWAYS,false));
		return s;
	}

	public function getBitmap() {
		return bmp;
	}

	public function cleanup() {
		bmp.dispose();
	}

	static var BITMAPS;
	function initBitmaps() {
		if( BITMAPS == null )
			BITMAPS = {
				eraser : bitmaps(fl.Eraser),
				erabig : bitmaps(fl.EraserBig),
				paths : bitmaps(fl.tiles.Path),
			};
		return BITMAPS;
	}

	public function initPaths() {
		var pflags = new Array();
		var hw = i.w * Const.ISIZE;
		var points = i.pts;
		var paths = i.segs;
		var npaths = Std.int(paths.length / 3);
		var p = 0;
		while( p < npaths ) {
			if( pathBits != null && !pathBits.get(p) ) {
				p++;
				continue;
			}
			var pid = p++ * 3;
			var p1 = points[paths.get(pid)];
			var p2 = points[paths.get(pid+1)];
			var x = p1.x;
			var y = p1.y;
			var tx = p2.x;
			var ty = p2.y;
			pflags[x + y * hw] = p;
			while( x != tx || y != ty ) {
				if( x < tx ) x++ else if( x > tx ) x-- else if( y < ty ) y++ else y--;
				pflags[x + y * hw] = p;
			}
		}
		return pflags;
	}

	public function draw( details ) {

		var rnd = new mt.Rand(i.seed);
		var bitmaps = initBitmaps();

		var t = haxe.Timer.stamp();

		if( bmp == null )
			bmp = new flash.display.BitmapData(i.w * Const.ISIZE * SIZE, i.h * Const.ISIZE * SIZE, true, 0 );
		else
			bmp.fillRect(bmp.rect, 0);

		var p0 = new flash.geom.Point(0, 0);
		var hw = i.w * Const.ISIZE;
		var hh = i.h * Const.ISIZE;

		// select tiles
		m.identity();
		var allTiles = initTiles();
		var tiles = [];
		for( t in i.tiles )
			if( tiles.length == 0 )
				tiles.push(allTiles.grounds[t % allTiles.grounds.length]);
			else
				tiles.push(allTiles.tiles[t % allTiles.tiles.length]);

		// extract levels
		var levels = [];
		for( p in 0...hw * hh )
			levels.push(i.bmp.get(p));

		// draw tiles & paths
		var ct = new flash.geom.ColorTransform(0, 0, 0, 1);
		var pathTmp = new flash.display.BitmapData(SIZE, SIZE, true, 0);
		var paths = if( details ) initPaths() else [];
		for( l in 0...TILE_LEVELS ) {
			var p = -1;
			var kinds = [];
			var t = tiles[l];
			makeTile(t);
			var pattern = t.pattern;
			for( y in 0...hh )
				for( x in 0...hw ) {
					// draw floors
					var level = levels[++p];
					var k = 0;
					if( level > l )
						k = 15;
					else {
						var k2 = 0;
						var v;
						v = levels[p - 1 - hw];
						if( v > l )	{ k |= 8; if( v > l + 1 ) k2 |= 8; }
						v = levels[p - hw];
						if( v > l )	{ k |= 12; if( v > l + 1 ) k2 |= 12; }
						v = levels[p + 1 - hw];
						if( v > l )	{ k |= 4; if( v > l + 1 ) k2 |= 4; }
						v = levels[p - 1];
						if( v > l )	{ k |= 10; if( v > l + 1 ) k2 |= 10; }
						v = levels[p + 1];
						if( v > l )	{ k |= 5; if( v > l + 1 ) k2 |= 5; }
						v = levels[p - 1 + hw];
						if( v > l )	{ k |= 2; if( v > l + 1 ) k2 |= 2; }
						v = levels[p + hw];
						if( v > l )	{ k |= 3; if( v > l + 1 ) k2 |= 3; }
						v = levels[p + 1 + hw];
						if( v > l )	{ k |= 1; if( v > l + 1 ) k2 |= 1; }
						if( k == 0 || (l != 3 && k == k2) )
							continue;
						// if we fill the block, then make sure we patch it
						if( k == 15 )
							levels[p] = l + 1;
					}
					var pat = pattern[rnd.random(pattern.length)][k];
					bput(x * SIZE, y * SIZE, pat);
					// draw paths
					if( paths[p] != 0 ) {
						var left = paths[p - 1] != 0;
						var right = paths[p + 1] != 0;
						var up = paths[p - hw] != 0;
						var down = paths[p + hw] != 0;
						if( left ) {
							if( right )
								kinds.push(0);
							if( up )
								kinds.push(2);
							if( down )
								kinds.push(5);
						}
						if( up ) {
							if( down )
								kinds.push(1);
							if( right )
								kinds.push(3);
						}
						if( right && down )
							kinds.push(4);
						if( kinds.length == 0 ) {
							if( left )
								kinds.push(7);
							else if( up )
								kinds.push(8);
							else if( right )
								kinds.push(9);
							else
								kinds.push(10);
						}
						// place : put circle
						//if( i._bmp.get(p) & 8 > 0 )
						//	kinds.push(6);
						var r = pathTmp.rect;
						pathTmp.fillRect(r, 0);
						while( kinds.length > 0 ) {
							var b = bitmaps.paths[kinds.shift()];
							pathTmp.copyPixels( b, r, p0, if( k == 15 ) null else pat, null, true );
						}
						var color = t.color;
						ct.redOffset = color >> 16;
						ct.greenOffset = (color >> 8) & 0xFF;
						ct.blueOffset = color & 0xFF;
						ct.alphaMultiplier = 0.5;
						pathTmp.colorTransform(r, ct);
						pt.x = x * SIZE;
						pt.y = y * SIZE;
						bmp.copyPixels( pathTmp, r, pt, null, null, true );
					}
				}
			}
		pathTmp.dispose();

		// set places data
		for( id in 0...i.pts.length ) {
			var p = i.pts[id];
			var a = p.x + p.y * hw;
			// erase a bit details around
			levels[a - 1] = 0;
			levels[a + 1] = 0;
			levels[a - hw] = 0;
			levels[a + hw] = 0;
			switch( p.k ) {
			case PEmpty, PMonsters, PBoss(_):
				if( paths[a - 1] == 0 && paths[a + 1] == 0 && paths[a - hw] == 0 && paths[a + hw] == 0 ) {
					levels[a] = -1000;
					continue;
				}
			default:
			}
			levels[a] = -getPlaceFrame(id, p.k, placeBits == null ? false : placeBits.get(id));
		}

		// draw details & places
		if( details ) {
			var places = frames(fl.Place);
			var perlin = new flash.display.BitmapData(hw, hh);
			perlin.perlinNoise(10, 10, 2, i.seed, false, true, 7);
			m.identity();
			var pos = -1;
			for( y in 0...hh )
				for( x in 0...hw ) {
					var level = levels[++pos];
					if( level < 0 ) {
						if( level == -1000 ) continue;
						put(x, y, places[-1-level]);
						continue;
					}
					if( level <= 1 )
						continue;
					if( levels[pos + 1] > level || levels[pos - 1] > level || levels[pos - hw] > level || levels[pos + hw] > level )
						continue;
					var t = tiles[level - 1];
					var pval = (perlin.getPixel(x, y) >> ((level - 2) << 3)) & 0xFF;
					if( (t.brushLevel < 0) ? (pval > -t.brushLevel) : (pval < t.brushLevel) ) {
						if( t.groundDensity > 0 && rnd.random(t.groundDensity) == 0 ) {
							var g = t.ground[rnd.random(t.ground.length)];
							var dx = rnd.random(SIZE >> 1);
							if( paths[pos] == 0 )
								bput(x * SIZE - (g.b.width >> 1) + (dx + (SIZE >> 2)), y * SIZE + (SIZE >> 1) + g.dy, g.b );
						}
						continue;
					}
					var m = t.brush[rnd.random(t.brush.length)];
					if( m != null && paths[pos] == 0 )
						bput(x * SIZE + (SIZE >> 1) - (m.b.width >> 1), y * SIZE + (SIZE >> 1) + m.dy, m.b);
				}
			perlin.dispose();
		}
		return makeView();
	}
}