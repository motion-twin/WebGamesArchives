package com.gen;

import mt.MLib;
import mt.RandList;
import mt.deepnight.Lib;

typedef Platform = {
	var cx		: Int;
	var cy		: Int;
	var wid		: Int;
	var ladders	: Array<Int>;
}

enum GenCancels {
	Stop(msg:String);
}

enum Patterns {
	P_Generic;
	P_Singles;
	P_Smalls;
	P_SmallsZ;
	P_Symetric;
	P_SymetricHole;
	P_Tower;
	P_SideTower;
}

enum LockType {
	LT_Silver;
	LT_Gold;
	LT_Movable;
}

enum MobType {
	MT_Simple;
	MT_Classic;
	MT_Bomber;
	MT_Smart;
	MT_Big;
	MT_Fly;
}

enum MobPattern {
	MP_Balanced;
	MP_BalancedEasy;
	MP_FlyBalanced;
	MP_FlyBig;
	MP_Horde;
	MP_Bigs;
	MP_BombHorde;
	MP_SmartHorde;
	MP_MiniBoss;
}

class LevelGenerator {
	static var MAX_FAILURES = 400;
	public static var MAX_LEVEL = 100;

	var seed				: Int;
	var lid					: Int;
	var rseed				: mt.Rand;
	public var wid			: Int;
	public var hei			: Int;
	public var pattern		: Patterns;

	public var targets		: Array<{cx:Int, cy:Int, type:LockType}>;
	public var platforms	: Array<Platform>;
	public var mobs			: Array<MobType>;
	public var exit			: {cx:Int, cy:Int};
	#if genTest
	var genLog				: Array<String>;
	//var profiler			: mt.deepnight.MiniProfiler;
	#end

	public function new() {
		seed = 0;
		lid = 1;
		rseed = new mt.Rand(seed);

		wid = 23;
		hei = 17;
		pattern = P_Generic;

		init();
	}


	inline function debug(str:Dynamic) {
		#if genTest
		Game.ME.log.addLine(str);
		#end
	}

	public inline function generateProgressionLevel(l:Int) {
		lid = l;
		return generate(18660 + lid*1000);
	}

	function generate(s:Int) {
		seed = s;
		initRandom();

		var failures = 0;
		var reasons = [];

		function getReasons() {
			var rmap = new Map();
			for(r in reasons)
				if( !rmap.exists(r) )
					rmap.set(r, 1);
				else
					rmap.set(r, rmap.get(r)+1);
			var rlist = [];
			for(r in rmap.keys())
				rlist.push(r+" ["+rmap.get(r)+"]");
			return rlist.join("\n");
		}


		function getMainReason() {
			var rmap = new Map();
			for(r in reasons)
				if( !rmap.exists(r) )
					rmap.set(r, 1);
				else
					rmap.set(r, rmap.get(r)+1);

			var main = "N/A";
			var best = 0;
			for(r in rmap.keys())
				if( rmap.get(r)>best ) {
					main = r;
					best = rmap.get(r);
				}
			return main+" (x"+best+")";
		}


		var version = 0;
		while( failures<MAX_FAILURES ) {
			try {
				// Generating
				#if genTest
				Game.ME.clearMarkers();
				#end
				init();
				initRandom();
				makePlatforms();
				makeLadders();
				makeTargets();
				addExit();
				addMobs();
				analyseLevel();

				// Complete !
				debug("--DONE------------------------");
				debug('Seed=$seed Pattern=$pattern');
				debug('Targets=${targets.length}');
				debug("Failures="+failures);
				debug("Reasons=\n"+getReasons());
				#if genTest
				for(l in genLog)
					debug(l);
				#end
				debug("------------------------------");
				if( needReroll(version++) )
					throw "Reroll";
				return { failures:failures, report:getMainReason() };
			}
			catch(e:GenCancels) {
				switch( e ) {
					case Stop(s) :
						debug("STOPPED: "+s);
						reasons.push(s);
				}
				#if debug
				return null;
				#end
			}
			catch(e:String) {
				reasons.push(e);
			}
			// Failure
			seed++;
			failures++;
		}
		debug("**FAILED********************");
		debug('Seed=$seed Pattern=$pattern');
		debug("Totally failed");
		debug("Reasons=\n"+getReasons());
		debug("****************************");
		return null;
	}


	inline function needReroll(v) {
		return
			lid==23 && v<=2 ||
			lid==75 && v<=1 ||
			lid==77 && v<=2 ||
			lid==89 && v<=1 ||
			lid==71 && v<=1;
	}


	inline function mark(cx,cy, ?col) {
		#if genTest
		Game.ME.marker(cx,cy,col);
		#end
	}

	inline function markLadder(cx,cy, ?col) {
		#if genTest
		for( cy in getLadderTop(cx, cy)+1...cy )
			mark(cx, cy, col);
		#end
	}

	inline function text(cx,cy, txt) {
		#if genTest
		Game.ME.textMarker(cx,cy,txt);
		#end
	}

	inline function dmark(cx,cy, ?col=0xFFFF00) {
		#if genTest
		Game.ME.delayedMarker(cx,cy, 12, col);
		#end
	}

	inline function dmarkFast(cx,cy, ?col=0xFFFF00) {
		#if genTest
		Game.ME.delayedMarker(cx,cy, 4, col);
		#end
	}


	inline function initRandom() {
		rseed.initSeed(seed);
	}

	function getLadderTop(cx,cy) {
		cy-=floorHei();
		while( cy>0 && !hasPlatform(cx,cy) )
			cy-=floorHei();
		return MLib.max(0,cy);
	}

	inline function lratio() {
		return MLib.fmin(1, lid/MAX_LEVEL);
	}

	inline function d100() {
		return rseed.random(100);
	}

	inline function between(a,b) {
		return lid>=a && lid<=b;
	}

	inline function bottom() {
		return hei-1;
	}

	inline function startX(p:Platform) {
		return p.cx;
	}
	inline function endX(p:Platform) {
		return p.cx+p.wid-1;
	}

	inline function top() {
		return floorHei()+1;
	}

	inline function floorHei() {
		return 3;
	}

	public function getPlatform(cx,cy) : Platform {
		for(p in platforms)
			if( cy==p.cy && cx>=startX(p) && cx<=endX(p) )
				return p;
		return null;
	}

	public function getBottomPlatform() {
		for(p in platforms)
			if( p.cy==bottom() )
				return p;
		throw "No bottom platform??";
	}

	public function hasPlatform(cx,cy) {
		return getPlatform(cx,cy)!=null;
	}

	public function hasLadder(p:Platform, lcx) {
		for(cx in p.ladders)
			if( cx==lcx )
				return true;
		return false;
	}

	inline function addPlatform(cx:Int,cy:Int, w:Int) {
		if( cx+w>wid )
			throw 'overflow X: $cx,$cy w=$w';

		if( cy>=hei )
			throw 'overflow Y: $cx,$cy w=$w';

		platforms.push({
			cx		: cx,
			cy		: cy,
			wid		: w,
			ladders	: [],
		});
	}

	function getPlatformsLinkedUnder(from:Platform) {
		var linked = [];
		for(p in platforms) {
			if( p.cy<=from.cy )
				continue;

			for( lcx in p.ladders ) {
				var lcy = p.cy-floorHei();
				while( lcy>0 && !hasPlatform(lcx, lcy) )
					lcy-=floorHei();
				if( getPlatform(lcx,lcy)==from ) {
					linked.push(p);
					break;
				}
			}
		}

		return linked;
	}

	function init() {
		#if genTest
		Game.ME.log.clear();
		genLog = [];
		#end
		platforms = [];
		targets = [];
		mobs = [];
		exit = { cx:1, cy:hei-2 }
	}


	inline function log(str:Dynamic) {
		#if genTest
		genLog.push( Std.string(str) );
		#end
	}



	function makePlatforms() {
		initRandom();

		// Level pattern
		pattern = P_Generic;

		if( lid%5==0 )
			pattern = P_Symetric;
		else if( lid%4==0 )
			pattern = P_Singles;

		var fixedPatterns = [
			1 => P_Tower,
			10 => P_Tower,
			20 => P_SideTower,
			30 => P_SymetricHole,
			40 => P_Tower,
			50 => P_SymetricHole,
			60 => P_SideTower,
			70 => P_SymetricHole,
			71 => P_Tower,
			72 => P_SideTower,
			73 => P_Tower,
			74 => P_Tower,
			76 => P_Tower,
			77 => P_SideTower,
			78 => P_Tower,
			79 => P_SideTower,
			80 => P_Tower,
			90 => P_SymetricHole,
			100 => P_Tower,
		];
		if( fixedPatterns.exists(lid) )
			pattern = fixedPatterns.get(lid);

		#if genTest
		//pattern = P_SymetricHole; // HACK
		#end


		if( pattern==P_SymetricHole && lid<=10 )
			throw "Pattern "+pattern+" not allowed for low levels";

		// Platform count
		var nrand = new RandList(rseed.random);
		switch( pattern ) {
			case P_Singles :
				nrand.add(1, 1);

			case P_Tower, P_SideTower :
				nrand.add(1, 10);
				nrand.add(2, 2);

			case P_Generic :
				if( lid<=30 ) {
					nrand.add(1, 5);
					nrand.add(2, 10);
					nrand.add(3, 1);
				}
				else {
					nrand.add(1, 1);
					nrand.add(2, 10);
					nrand.add(3, 20);
				}

			case P_Smalls, P_SmallsZ :
					nrand.add(3, 1);
					nrand.add(4, 20);
					//if( lid>=50 )
						//nrand.add(5, 8);

			case P_SymetricHole :
				nrand.add(1, 20);

			case P_Symetric :
				nrand.add(1, 20);
				nrand.add(2, 7);
		}


		initRandom();
		var y = 4;
		var floor = 0;
		while( y<bottom() ) {

			// Platform count
			var n = nrand.draw();

			// Large gaps
			var extraGaps =
				switch( pattern ) {
					case P_Generic :
						if( lid<50 )
							rseed.irange(2,8);
						else
							rseed.irange(0,8);

					case P_Smalls, P_SmallsZ :
						if( n>=4 )
							rseed.irange(0,1);
						else
							rseed.irange(1,6);

					case P_Tower, P_SideTower :
						rseed.irange(0,2);

					case P_Singles :
						if( lid<50 )
							rseed.irange(6,10);
						else
							rseed.irange(8,18);

					case P_Symetric :
						rseed.irange(0, 8);

					case P_SymetricHole :
						rseed.irange(1, 3);
				}

			// Required cells
			var cells = switch( pattern ) {
				case P_Generic, P_Singles, P_Smalls, P_SmallsZ :
					wid - extraGaps - (n-1)*2;

				case P_Tower, P_SideTower :
					MLib.max( 12, n*3 + rseed.irange(0,8) );

				case P_Symetric :
					rseed.irange(6, 12);

				case P_SymetricHole :
					MLib.round( rseed.range(wid*0.2, wid*0.4) );
					//Std.int(wid*0.5 - extraGaps - (n-1)*2 - 1);
			}

			// Min platform length
			var minLen =
				if( lid<35 ) 4;
				else if( lid<50 ) 3;
				else 2;
			if( pattern==P_Smalls || pattern==P_SmallsZ )
				minLen = 2;

			// Special floors
			switch( pattern ) {
				case P_SmallsZ :
					if( (floor+1)%2==0 ) {
						n = RandList.fromMap([ 1=>10, 2=>1 ]).draw(rseed.random);
						cells = rseed.irange(3*n, 9);
						extraGaps = wid - cells - (n-1)*2;
					}

				case P_Smalls, P_Generic, P_Singles, P_Symetric, P_SymetricHole, P_Tower, P_SideTower :
			}

			log('n=$n cells=$cells extraGaps=$extraGaps minLen=$minLen');

			if( cells<n*minLen )
				throw "Not enough cells";


			var x = rseed.irange(0, extraGaps);
			if( pattern==P_SymetricHole )
				x = MLib.min(2, x);
			if( pattern==P_Tower)
				x = Std.int( wid*0.5 - (cells+extraGaps+(n-1)*2) * 0.5 ); // center
			else
				extraGaps-=x;


			while( n>0 ) {
				var w = n==1 ? cells : rseed.irange(minLen, cells-minLen*(n-1));
				addPlatform(x,y, w);
				cells-=w;
				if( x>=wid )
					throw Stop("x overflowed");
				x+=w+2;
				if( extraGaps>0 ) {
					var g = rseed.irange(0,extraGaps);
					extraGaps-=g;
					x+=g;
				}
				n--;
			}

			y+=floorHei();
			floor++;
		}


		// Special post operations
		initRandom();
		switch( pattern ) {
			case P_Symetric, P_SymetricHole :
				// Horizontal mirror (duplicates)
				var all = platforms.copy();
				for(p in all)
					addPlatform(wid-p.cx-p.wid, p.cy, p.wid);

			case P_SmallsZ, P_Tower, P_SideTower :
				// Horizontal flip
				if( rseed.random(2)==0 )
					for(p in platforms)
						p.cx = wid-p.cx-p.wid;

			case P_Generic, P_Singles, P_Smalls :
		}


		// Middle platforms joints
		if( pattern==P_SymetricHole ) {
			var y = 4;
			for(y in [4,10])
				addPlatform(Std.int(wid*0.5) - rseed.random(2), y, 2);
		}




		// Clear overlaps/too-close platforms
		var killList = [];
		var killed = new Map();
		for(i in 0...platforms.length)
			for(j in 0...platforms.length) {
				var p = platforms[i];
				var p2 = platforms[j];
				if( p==p2 || p.cy!=p2.cy || killed.exists(i) || killed.exists(j) )
					continue;

				if( startX(p2)>=startX(p)-1 && startX(p2)<=endX(p)+1 || endX(p2)>=startX(p)-1 && endX(p2)<=endX(p)+1 ) {
					var start = MLib.min( startX(p), startX(p2) );
					var end = MLib.max( endX(p), endX(p2) );
					p.cx = start;
					p.wid = end-start+1;
					killed.set(j,true);
					killList.push(p2);
				}
			}
		while( killList.length>0 ) {
			var p = killList.pop();
			platforms.remove(p);
		}

		// Main ground
		initRandom();
		var pw =
			if( lid<20 )
				wid;
			else if( lid<40 && rseed.random(100)<40 )
				wid
			else if( lid<60 && rseed.random(100)<60 )
				MLib.round( rseed.range(0.5, 0.9)*wid );
			else
				MLib.round( rseed.range(0.3, 0.9)*wid );
		if( pattern==P_Tower && lid>=40 )
			pw = rseed.irange(10, 15);
		addPlatform(rseed.irange(0,wid-pw), bottom(), pw);

		// Verify reach
		var p = getBottomPlatform();
		var done : Map<String,Bool> = new Map();
		var todo = [p];
		var reached = [];
		while( todo.length>0 ) {
			var p = todo.pop();

			if( done.exists(p.cx+","+p.cy) )
				continue;

			done.set(p.cx+","+p.cy, true);
			reached.push(p);

			var around = platforms.filter( function(p2) return p2!=p && (p2.cy==p.cy || p2.cy==p.cy-floorHei()) );
			for( next in around ) {
				if( next.cy==p.cy ) {
					// Same floor
					if( next.cx<=endX(p)+4 || endX(next)>=p.cx-4 )
						todo.push(next);
				}
				else {
					// Above
					if( next.cx<=endX(p)+2 && endX(next)>=p.cx-2 )
						todo.push(next);
				}
			}
		}
		if( reached.length<platforms.length )
			throw "Could not reach all platforms";
	}



	function sortPlatforms() {
		platforms.sort( function(a,b) {
			if( a.cy!=b.cy )
				return -Reflect.compare(a.cy, b.cy);
			else
				return Reflect.compare(a.cx, b.cx);
		});

	}

	inline function platformId(p:Platform) {
		return p.cx + p.cy*wid;
	}

	inline function horizontalDist(p1:Platform, p2:Platform) {
		return p1.cx<p2.cx ? p2.cx-endX(p1)-1 : p1.cx-endX(p2)-1;
	}

	function makeLadders() {
		initRandom();
		sortPlatforms();

		// Analyse level and detect platform groups
		var groups : Map<Int, Int> = new Map();
		var gid = 0;
		var prev : Platform = null;
		for(p in platforms) {
			if( prev!=null ) {
				if( prev.cy!=p.cy )
					gid++;
				else if( horizontalDist(p, prev)>2 )
					gid++;
			}

			groups.set( platformId(p), gid );
			text(p.cx, p.cy, gid);
			prev = p;
		}

		function getGroupPlatforms(gid) {
			return platforms.filter( function(p) return groups.get( platformId(p) )==gid );
		}

		// Add ladders up (no exits)
		initRandom();
		var gid = 0;
		var group = getGroupPlatforms(gid);
		while( group.length>0 ) {
			var lcy = group[0].cy;
			if( lcy>top() ) {
				var spots = [];
				for(p in group) {
					for( cx in p.cx...p.cx+p.wid )
						if( getLadderTop(cx,p.cy)>0 )
							spots.push(cx);
				}
				if( spots.length==0 )
					throw "No ladder spot for whole group";

				if( spots.length>0 ) {
					var lcx = spots[ rseed.random(spots.length) ];
					var p = getPlatform(lcx, lcy);
					p.ladders.push(lcx);
				}
			}
			group = getGroupPlatforms(++gid);
		}

		// Add exits (one for each group at the top)
		var gid = 0;
		var group = getGroupPlatforms(gid);
		while( group.length>0 ) {
			var lcy = group[0].cy;
			if( lcy==top() ) {
				var spots = [];
				for(p in group) {
					for( cx in p.cx...p.cx+p.wid )
						spots.push(cx);
				}
				var lcx = spots[ rseed.random(spots.length) ];
				var p = getPlatform(lcx, lcy).ladders.push(lcx);
			}
			group = getGroupPlatforms(++gid);
		}

		// Add ladders down on orphaned platforms
		initRandom();
		var gid = 1;
		var group = getGroupPlatforms(gid);
		while( group.length>0 ) {
			var downLinks = 0;
			for(p in group)
				downLinks += getPlatformsLinkedUnder(p).length;

			if( downLinks==0 ) {
				var p = group[rseed.random(group.length)];
				var lcx = rseed.irange(p.cx, endX(p));
				var lcy = p.cy + floorHei();
				while( lcy<hei && !hasPlatform(lcx,lcy) )
					lcy+=floorHei();

				var p = getPlatform(lcx, lcy);
				if( p==null )
					throw "Ladder reached bottom";
				p.ladders.push(lcx);
			}
			group = getGroupPlatforms(++gid);
		}

		// Add a few extra ladders (no exits)
		initRandom();
		for(p in platforms) {
			if( p.wid<=4 || p.cy==top() || p.ladders.length>=3 )
				continue;

			var n = 0;
			if( between(20,50) && rseed.random(100)<40 )
				n++;
			if( between(50,100) ) {
				n++;
				if( rseed.random(100)<40 )
					n++;
			}
			while( n>0 ) {
				var spots = [];
				for( cx in startX(p)...endX(p)+1 )
					if( !hasLadder(p, cx) && !hasLadder(p, cx-1) && !hasLadder(p, cx+1) && getLadderTop(cx, p.cy)>0 )
						spots.push(cx);

				if( spots.length==0 )
					break;

				var lcx = spots.splice( rseed.random(spots.length), 1 )[0];
				p.ladders.push(lcx);
				n--;
			}
		}

		// Add extra exit ladders
		initRandom();
		var exits = 0;
		for( p in platforms )
			for( lcx in p.ladders )
				if( getLadderTop(lcx, p.cy)==0 )
					exits++;
		var needed =
			if(between(0, 19)) 1;
			else if(between(20, 69)) 2;
			else if(between(70,89)) 3;
			else 4;
		needed-=exits;
		if( needed<0 )
			throw "Too many exits";
		log("extra exits needed="+needed);
		while( needed>0 ) {
			var shorts = [];
			var mediums = [];
			var longs = [];
			for(cx in 1...wid-1) {
				var cy = top();
				var len = 1;
				while( cy<hei && !hasPlatform(cx,cy) ) {
					len++;
					cy+=floorHei();
				}

				if( cy>=hei )
					continue;

				var p = getPlatform(cx,cy);
				if( hasLadder(p, cx) || hasLadder(p, cx-1) || hasLadder(p, cx+1) )
					continue;

				text(cx, 0, len);
				if( len==1 )
					shorts.push(cx);
				else if( len<=3 )
					mediums.push(cx);
				else
					longs.push(cx);
			}

			var pool = shorts;
			if( between(30,69) && rseed.random(100)<50 )
				pool = mediums;

			if( between(70,100) )
				if( rseed.random(100)<60 )
					pool = longs;
				else if( rseed.random(100)<70 )
					pool = mediums;

			if( pool.length==0 )
				pool = shorts;

			if( pool.length==0 )
				pool = mediums;

			if( pool.length==0 )
				pool = longs;

			if( pool.length==0 )
				throw "No room for extra exit ladder";

			var cx = pool.splice( rseed.random(pool.length), 1 )[0];
			var cy = top();
			var p = getPlatform(cx,cy);
			while( p==null ) {
				cy+=floorHei();
				p = getPlatform(cx,cy);
			}
			p.ladders.push(cx);
			needed--;
		}
	}


	public inline function getUnderPlatforms(p:Platform) {
		return platforms.filter(function(p2) {
			return p2.cy>=p.cy+floorHei() && p2.cx<p.cx+p.wid && p2.cx+p2.wid>p.cx;
		});
	}


	function makeTargets() {
		initRandom();

		// Parse level spots
		var baseSpots = [];
		var minCY = lid<20 ? bottom()-floorHei() : 9999;
		for(p in platforms) {
			if( p.cy>minCY )
				continue;

			var ladders = new Map();
			for(cx in p.ladders)
				ladders.set(cx, true);
			for(cx in startX(p)+1...endX(p))
				if( !ladders.exists(cx) )
					baseSpots.push({ cx:cx, cy:p.cy-1 });
		}

		// Prepare counts
		var n = Std.int(6 + 9 * lid/100);
		if( n>baseSpots.length )
			throw "No room for "+n+" targets";

		// Prepare types
		var ltypes = [];
		if( lid==1 || rseed.random(100) < 50+50*lid/100 )
			ltypes.push(LT_Movable);
		for(i in ltypes.length...n)
			if( rseed.random(100) < 20*lid/100 )
				ltypes.push(LT_Gold);
			else if( rseed.random(100) < 50*lid/100 )
				ltypes.push(LT_Movable);
			else
				ltypes.push(LT_Silver);
		ltypes = Lib.shuffle(ltypes, rseed.random);

		// Try to place everything
		initRandom();
		var minDist = n<=8 ? 3*3 : n<=11 ? 2*2 : 1;
		var tries = 10;
		do {
			try {
				var ltypes = ltypes.copy();
				var spots = baseSpots.copy();
				while( targets.length<n ) {
					if( spots.length<=0 )
						throw "Failed";
					var pt = spots.splice( rseed.random(spots.length), 1 )[0];
					var tooClose = false;
					for(t in targets)
						if( Lib.distanceSqr(pt.cx, pt.cy, t.cx, t.cy)<=minDist ) {
							tooClose = true;
							break;
						}
					if( !tooClose ) {
						var t = ltypes.pop();
						targets.push({ cx:pt.cx, cy:pt.cy, type:t });
					}
				}
			}
			catch(e:String) {
				targets = [];
				tries--;
				if( tries<=0 )
					throw "Failed to place targets";
			}
		} while( targets.length<n );

		// Shuffle
		initRandom();
		targets = Lib.shuffle(targets, rseed.random);
	}



	function addExit() {
		initRandom();
		var p = getBottomPlatform();

		// Mark blocked columns
		var blk = new Map();
		for( cx in p.ladders )
			blk.set(cx, true);
		for( t in targets )
			if( t.cy==p.cy-1 )
				blk.set(t.cx, true);

		// Find a spot
		var spots = [];
		for( cx in startX(p)+1...endX(p) )
			spots.push(cx);
		spots = Lib.shuffle(spots, rseed.random);

		for( cx in spots )
			if( !blk.exists(cx-1) && !blk.exists(cx) && !blk.exists(cx+1) ) {
				exit = { cx:cx, cy:p.cy-1 }
				return;
			}

		throw "No room for exit";
	}


	function addMobs() {
		initRandom();
		mobs = [];
		log("--Mobs------");

		// Mob count
		var size = 6 + Std.int( lid*0.06 ) + rseed.irange(0,2);
		if( lid>=10 ) size++;


		var prand = RandList.fromMap([
			MP_Balanced => 20,
			MP_Horde => 10,
			MP_Bigs => 5,
		]);
		if( lid>10 ) prand.add(MP_SmartHorde, 5);
		if( lid<50 ) prand.add(MP_BombHorde, 3);
		if( lid>50 ) prand.add(MP_FlyBig, 5);
		if( lid>75 ) prand.add(MP_FlyBalanced, 5);

		var mpatt = prand.draw( rseed.random );

		// Special levels
		if( lid%10==0 ) mpatt = MP_MiniBoss;
		if( lid==1 ) mpatt = MP_BalancedEasy;
		if( lid==2 ) mpatt = MP_BombHorde;
		if( lid==5 ) mpatt = MP_Bigs;
		if( lid<10 && mpatt==MP_Balanced ) mpatt = MP_BalancedEasy;

		log("Pattern: "+mpatt);

		function add(t:MobType, ?n=1) {
			for(i in 0...n)
				mobs.push(t);
		}

		function fillWith(t:MobType) {
			var n = size-mobs.length;
			for(i in 0...n)
				mobs.push(t);
		}

		function addPct(t:MobType, ratio:Float, ?max=999) {
			add( t, MLib.min( MLib.ceil( size*ratio ), max ) );
		}


		switch( mpatt ) {
			case MP_BalancedEasy :
				addPct(MT_Simple, 0.8);
				add(MT_Smart);
				fillWith( MT_Classic );

			case MP_Balanced :
				addPct( MT_Smart, 0.25 );
				fillWith( MT_Classic );

			case MP_Horde :
				fillWith( MT_Classic );
				addPct( MT_Classic, 0.5 );

			case MP_Bigs :
				fillWith(MT_Big);

			case MP_FlyBalanced :
				add(MT_Fly, 1);
				if( lid>80 ) add(MT_Smart, 2);
				else if( lid>40 ) add(MT_Smart, 1);
				addPct(MT_Classic, 0.3);

			case MP_FlyBig :
				add(MT_Fly, 1);
				if( lid>80 ) add(MT_Big, 2);
				else if( lid>40 ) add(MT_Big, 1);
				addPct(MT_Classic, 0.3);

			case MP_BombHorde :
				add(MT_Smart, rseed.irange(0, 2));
				addPct(MT_Big, rseed.range(0.2, 0.6));
				fillWith(MT_Classic);
				add(MT_Bomber, rseed.irange(2,4));

			case MP_SmartHorde :
				addPct(MT_Smart, 0.4, lid<60 ? 5 : 6);
				add(MT_Big);

			case MP_MiniBoss :
				addPct(MT_Big, 0.7);
				addPct(MT_Smart, 0.1);
				addPct(MT_Classic, 0.2);
		}

		if( lid<50 && rseed.random(100)<7 )
			add(MT_Bomber);

		#if genTest
		// Debug
		var map = new Map();
		for( k in mobs ) {
			if( !map.exists(k) )
				map.set(k, 1);
			else
				map.set(k, map.get(k)+1);
		}
		for(k in map.keys())
			log('$k x${map.get(k)}');
		#end
	}


	function analyseLevel() {
		initRandom();

		var exits = 0;
		var mediums = 0;
		var longs = 0;
		var longDirects = 0;
		var allExits = [];
		for(p in platforms)
			for(lcx in p.ladders) {
				var top = getLadderTop(lcx, p.cy);
				var len = MLib.ceil( (p.cy-top) / floorHei() );
				if( len == 2 )
					mediums++;

				if( len >= 3 )
					longs++;

				if( top<=0 ) {
					allExits.push(lcx);
					exits++;
					if( len>3 )
						longDirects++;
				}
			}

		if( pattern==P_SymetricHole && longDirects>0 )
			throw "Symetric too hard";

		if( exits==0 )
			throw "No exit";

		if( between(0, 10) ) {
			if( exits>1 )
				throw "Too many exits";

			if( longs>0 )
				throw "Too many longs";
		}

		if( lid<50 && longDirects>0 )
			throw "No direct allowed";

		if( ( pattern==P_Tower || pattern==P_SideTower ) && lid<90 && longDirects>1 )
			throw "No direct allowed";

		if( lid<50 && exits>2 )
			throw "Too many exits";

		if( lid<75 && exits>4 )
			throw "Too many exits";

		if( allExits.length>1 ) {
			var maxExitDelta =
				if( lid<40 ) 9;
				else if( lid<60 ) 12;
				else 15;
			allExits.sort( function(a,b) return Reflect.compare(a,b) );
			for( i in 0...allExits.length-1 ) {
				var d = allExits[i+1] - allExits[i];
				if( d>maxExitDelta )
					throw "Ladders too far";
			}
		}


		switch( pattern ) {
			case P_Singles, P_SideTower :
				if( longDirects>0 ) throw "Bad level";

			case P_Generic, P_Smalls, P_SmallsZ, P_Symetric, P_SymetricHole, P_Tower :
		}
	}


}

