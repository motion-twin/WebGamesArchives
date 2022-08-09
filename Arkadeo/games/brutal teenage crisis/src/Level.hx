import Const;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Lib;
import mt.RandList;

import com.gen.LevelGenerator;

@:bitmap("assets/testLevel.png") class GfxLevel extends BitmapData {}

typedef MapCell = {
	var collide	: Bool;
	var ladder	: Bool;
}

class Level {
	static var PLATFORM_SKINS = [
		"Blue", "Brick", "Goth", "Metal",
	];

	var mode		: Mode;
	var map			: Array<Array<MapCell>>;
	var walls		: Bitmap;
	var rseed		: mt.Rand;
	var spots		: Map<String, Array<{cx:Int, cy:Int}>>;
	public var lgen	: LevelGenerator;

	public function new() {
		mode = Mode.ME;
		map = new Array();
		rseed = new mt.Rand(0);
		spots = new Map();

		lgen = new LevelGenerator();

		for(cx in 0...Const.LWID) {
			map[cx] = new Array();
			for(cy in 0...Const.LHEI) {
				map[cx][cy] = {
					collide	: false,
					ladder	: false,
				}
			}
		}
	}

	inline function initRandom() {
		rseed.initSeed( getSeed() );
	}

	inline function getSeed() {
		return mode.isLeague() ? mode.seed : mode.asProgression().lid;
	}

	public function generateProgression(lvl:Int) {
		initRandom();

		// Generate
		lgen.generateProgressionLevel(lvl);

		// Store interesting spots
		for(p in lgen.platforms) {
			var cy = p.cy;
			for( cx in p.cx...p.cx+p.wid ) {
				map[cx][cy].collide = true;
				addSpot("ground", cx, cy-1);
				addSpot("floor_"+getFloor(cy-1), cx, cy-1);
			}
		}

		// Trace ladders
		for(p in lgen.platforms)
			for( lcx in p.ladders ) {
				var lcy = p.cy-1;
				while( lcy>0 && !hasCollision(lcx,lcy) ) {
					map[lcx][lcy].ladder = true;
					lcy--;
				}
				map[lcx][lcy].ladder = true;
			}

		initRandom();
	}


	public function readFromFile(n:Int) {
		var source = new GfxLevel(0,0);

		for(x in 0...Const.LWID) {
			map[x] = new Array();
			for(y in 0...Const.LHEI) {
				var pixel = source.getPixel(x,y + n*Const.LHEI);
				var under = source.getPixel(x,y + n*Const.LHEI + 1);
				var coll = pixel==0xFFFFFF;
				map[x][y] = {
					collide	: coll,
					ladder	: pixel==0xFF0000 || under==0xff0000,
				}
				if( !coll && under==0xFFFFFF ) {
					addSpot("ground",x,y);
					addSpot("floor_"+getFloor(y), x,y);
				}
			}
		}
		source.dispose();
	}


	public static inline function getFloor(cy) : Int {
		return 4 - Std.int( Math.min(4, Math.max(0, (cy-2)/3)) );
	}

	public inline function addSpot(k:String, cx,cy) {
		if( !spots.exists(k) )
			spots.set(k, new Array());

		spots.get(k).push({cx:cx, cy:cy});
	}


	public function destroy() {
		detach();
	}

	public function detach() {
		if( walls!=null ) {
			walls.parent.removeChild(walls);
			walls.bitmapData.dispose();
		}
	}

	public inline function isValid(cx,cy) {
		return cx>=0 && cy>=0 && cx<Const.LWID && cy<Const.LHEI;
	}

	public inline function hasCollision(cx,cy) {
		if( cy<0 || cy>=Const.LHEI )
			return false;
		else if( cx<0 || cx>=Const.LWID )
			return true;
		else
			return map[cx][cy].collide;
	}

	public function hasLadder(cx,cy) {
		if( cy<0 )
			return true;
		else if( isValid(cx,cy ) )
			return map[cx][cy].ladder;
		else
			return false;
	}

	public function render() {
		initRandom();
		detach();
		walls = new Bitmap( new BitmapData(Const.WID, Const.HEI, true, 0x0) );
		mode.dm.add(walls, Const.DP_BG);
		var wbd = walls.bitmapData;
		var pbd = wbd.clone();


		// Skin
		var skinSet = [ [ "Rock"=>10 ] ];
		if( mode.isProgression() ) {
			var lid = mode.asProgression().lid;
			skinSet =
				if( lid<10 )		[ ["Wood"=>10] ]
				else if( lid<20 )	[ ["Grass"=>10] ]
				else if( lid<30 )	[ ["Roof"=>10] ]
				else if( lid<40 )	[ ["Rock"=>10] ]
				else if( lid<50 )	[ ["Ice"=>10], ["Ice"=>10,"Metal"=>3], ["Ice"=>10,"Brick"=>4] ]
				else if( lid<60 )	[ ["Blue"=>10] ]
				else if( lid<70 )	[ ["Ruby"=>10] ]
				else if( lid<80 )	[ ["Metal"=>10], ["Metal"=>10,"Ice"=>4] ]
				else if( lid<90 )	[ ["Metal"=>10], ["Metal"=>10,"Ice"=>4] ]
				else if( lid<100 )	[ ["Obsidian"=>10], ["Obsidian"=>10,"Brick"=>4] ]
				else [ ["Obsidian"=>10,"Roof"=>4] ];
		}
		var skin = skinSet[rseed.random(skinSet.length)];


		// Background
		if( mode.isLeague() ) {
			// League
			var s = mode.bgs.get("bg", 0);
			s.scaleX = s.scaleY = 2;
			wbd.draw(s, s.transform.matrix);
		}
		if( mode.isProgression() ) {
			// Progression
			var f = mode.isProgression() ? Std.int(mode.asProgression().lid/10) : 0;
			f = f%4;
			var s = mode.bgs.get("bg", f);
			s.scaleX = s.scaleY = 2;
			wbd.draw(s, s.transform.matrix);
		}

		var s = new Sprite();
		for(cx in 0...Const.LWID)
			for(cy in 0...Const.LHEI) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;

				if( hasCollision(cx,cy) ) {
					var id = RandList.fromMap(skin).draw(rseed.random);
					var s = mode.tiles.get("plateform"+id);
					s.setCenter(0,0);
					s.x = x;
					s.y = y;
					if( !hasCollision(cx+1,cy) )
						s.set("plateform"+id+"Side");
					else if( !hasCollision(cx-1,cy) ) {
						s.set("plateform"+id+"Side");
						s.scaleX = -1;
						s.x += Const.GRID;
					}
					else {
						s.scaleX = rseed.sign();
						if( s.scaleX<0 )
							s.x+=Const.GRID;
					}

					pbd.draw(s, s.transform.matrix);
					s.destroy();
				}

				if( rseed.random(100)<25 && hasCollision(cx,cy) && hasCollision(cx-1,cy) && hasCollision(cx+1,cy) ) {
					mode.tiles.drawIntoBitmapRandom(wbd, x,y-Const.GRID, "deco_back", rseed.random, 0.5, 0);
				}

				if( rseed.random(100)<10 && hasCollision(cx,cy) && hasCollision(cx-1,cy) && hasCollision(cx+1,cy) ) {
					var s = mode.tiles.getRandom("deco_front", rseed.random);
					s.scaleX = rseed.sign();
					s.scaleY = rseed.range(0.5, 1);
					s.x = x;
					s.y = y;
					s.setPivotCoord(s.width*0.5, 34);
					pbd.draw(s, s.transform.matrix);
					s.destroy();
				}
			}

		// Inner shadow
		var pt0 = new flash.geom.Point();
		pbd.applyFilter( pbd, pbd.rect, pt0, new flash.filters.DropShadowFilter(9, -90, 0x311450,0.4, 0,0,1, 1,true) );

		// Perlin texture
		var perlin = new BitmapData(pbd.width, pbd.height, true, 0x0);
		perlin.perlinNoise(16,4, 2, getSeed(), false, false, 1, true);
		perlin.copyChannel(pbd, pbd.rect, pt0, flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);
		pbd.draw(perlin, new flash.geom.ColorTransform(1,1,1, 0.5), flash.display.BlendMode.OVERLAY);
		wbd.draw(pbd);

		pbd.dispose();
		pbd = null;
		perlin.dispose();
		perlin = null;

		// Ladders
		for(cx in 0...Const.LWID)
			for(cy in 0...Const.LHEI)
				if( hasLadder(cx,cy) ) {
					var x = cx*Const.GRID;
					var y = cy*Const.GRID;
					var f =
						if( !hasLadder(cx, cy-1) ) 1
						else if( !hasLadder(cx, cy+1) ) 2
						else 0;
					mode.tiles.drawIntoBitmap(wbd, x,y, "ladder", f);
				}
	}


	public function getGroundSpotsCopy() {
		return spots.get("ground").copy();
	}

	public function getGroundSpotsAround(cx,cy, ?min=0, ?max=5) {
		var all = [];
		for( pt in spots.get("ground") ) {
			var d = Lib.distanceSqr(cx,cy, pt.cx,pt.cy);
			if( d>=min*min && d<=max*max )
				all.push(pt);
		}
		return all;
	}

	public function getRandomSpotFar(?floor:Int) {
		var pt = null;
		var tries = 200;
		do {
			pt = getRandomSpot( floor );
		} while( tries-->0 && Lib.distance(mode.hero.cx, mode.hero.cy, pt.cx, pt.cy)<=5 );
		return pt;
	}


	public function getRandomSpot(?floor:Int) {
		if( floor==null ) {
			var all = spots.get("ground");
			return all[ rseed.random(all.length) ];
		}
		else {
			var all = spots.get("floor_"+floor);
			return all[ rseed.random(all.length) ];
		}
	}
}

