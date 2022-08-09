package mt.deepnight;

import mt.gx.algo.Heap;

typedef AStarPoint = {x:Int, y:Int, parent:AStarPoint, goalDist:Float, homeDist:Float};

private class AStarList {
	var hash		: IntHash<AStarPoint>;
	var heap		: Heap<AStarPoint>;
	public var length(default,null)	: Int;
	
	public function new() {
		hash = new IntHash();
		heap = new Heap();
		length = 0;
	}
	
	private inline function id(pt:AStarPoint) {
		return pt.x + pt.y*100000;
	}
	
	public inline function add(pt:AStarPoint) {
		if( !has(pt) ) {
			hash.set(id(pt), pt);
			heap.heapify({ w : -(pt.goalDist-pt.homeDist), data : pt});
			length++;
		}
	}
	
	public function search(spt:AStarPoint) {
		return hash.get( id(spt) );
	}
	
	public inline function popBest() {
		length--;
		return heap.delMin().data;
	}
	
	public inline function has(pt:AStarPoint) {
		return hash.exists( id(pt) );
	}
}


// Credits : http://www.policyalmanac.org/games/aStarTutorial.htm

typedef Path = Array<{x:Int, y:Int}>;

class PathFinder {
	var colMap						: Array<Array<Bool>>;
	var wid							: Int;
	var hei							: Int;
	
	public var moveCost				: Int->Int -> Int->Int -> Float; //    fn(fromX,fromY, toX,toY) -> cost
	//public var turnCost			: Float; // Set to 1.1+ to reduce turnings
	public var useCache				: Bool;
	public var cacheSymetricPaths	: Bool;
	//public var coordCache	: Array<Array< Array<Path> >>;

	var openList					: AStarList;
	var closedList					: AStarList;
	
	var cache						: IntHash<Array<{x:Int, y:Int}>>;
	var diagonals					: Bool;
	
	public var statNoCache			: Int;
	public var statCache			: Int;
	public var maxHomeDistance		: Int;
	public var maxGoalDistance		: Int;
	
	public function new(w,h, ?allowDiagonals=false) {
		wid = w;
		hei = h;
		useCache = true;
		cacheSymetricPaths = true;
		diagonals = allowDiagonals;
		maxGoalDistance = maxHomeDistance = 9999;
		//turnCost = 1.0;
		statNoCache = 0;
		statCache = 0;
		moveCost = function(x1,y1, x2,y2) return 1;
		
		resetCollisions();
	}
	
	public inline function resetCache() {
		cache = new IntHash();
	}
	
	public function resetCollisions() {
		resetCache();
		colMap = new Array();
		for(x in 0...wid) {
			colMap[x] = new Array();
			for(y in 0...hei)
				setCollision(x,y, false);
		}
	}
	
	public inline function fillAll(b:Bool) {
		for(x in 0...wid)
			for(y in 0...hei)
				setCollision(x,y,b);
	}
	
	inline function abs(n) {
		return n>0 ? n : -n;
	}
	
	inline function getHeuristicDist(a:AStarPoint, b:AStarPoint) {
		return abs(a.x-b.x) + abs(a.y-b.y);
	}
	
	public inline function getPath(from:{x:Int, y:Int}, to:{x:Int, y:Int}) : Path {
		return astar(from, to);
	}
	
	public function astar(from:{x:Int, y:Int}, to:{x:Int, y:Int}) : Path {
		if( useCache ) {
			if( cache.exists(getCacheID(from,to)) ) {
				statCache++;
				return cache.get( getCacheID(from,to) ).copy();
			}
			if( cacheSymetricPaths && cache.exists(getCacheID(to,from)) ) {
				statCache++;
				var a = cache.get( getCacheID(to,from) ).copy();
				a.reverse();
				return a;
			}
		}
		
		statNoCache++;
		
		openList = new AStarList();
		closedList = new AStarList();
		if( getCollision(from.x,from.y) || getCollision(to.x,to.y) )
			return new Array();
		if( from.x<0 || from.y<0 || from.x>=wid || from.y>=hei )
			return new Array();
		if( to.x<0 || to.y<0 || to.x>=wid || to.y>=hei )
			return new Array();
		
		var path = astarLoop(
			{x:from.x, y:from.y, homeDist:0, goalDist:0, parent:null},
			{x:to.x, y:to.y, homeDist:0, goalDist:0, parent:null}
		);
		if( useCache ) {
			cache.set( getCacheID(from,to), path);
			for(i in 0...path.length-1) {
				var fpt = path[i];
				var sub = [fpt];
				for(j in i+1...path.length) {
					sub.push(path[j]);
					cache.set( getCacheID(fpt, path[j]), sub.copy());
				}
			}
		}
			
		return path;
	}
	
	inline function getCacheID(start:{x:Int,y:Int}, end:{x:Int,y:Int}) {
		return start.x+start.y*wid + 100000*(end.x+end.y*wid);
	}
	
	function astarLoop(start:AStarPoint, end:AStarPoint) : Path {
		var tmp = end; end = start; start = tmp; // Avoid the path to be returned reversed
		openList = new AStarList();
		closedList = new AStarList();
		openList.add(start);
		
		//var fx = mode.Play.ME.fx;
	
		var neig = new Array();
		neig.push( { dx:-1,	dy:0,	cost:1.0} );
		neig.push( { dx:1,	dy:0,	cost:1.0} );
		neig.push( { dx:0,	dy:-1,	cost:1.0} );
		neig.push( { dx:0,	dy:1,	cost:1.0} );
		if( diagonals ) {
			neig.push( { dx:-1,	dy:-1,	cost:1.4} );
			neig.push( { dx:1,	dy:-1,	cost:1.4} );
			neig.push( { dx:1,	dy:1,	cost:1.4} );
			neig.push( { dx:-1,	dy:1,	cost:1.4} );
		}
		
		var idx = 0;
		//var total = flash.Lib.getTimer();
		//var sub = 0;
		while( openList.length>0 ) {
			//var t = flash.Lib.getTimer();
			var cur = openList.popBest();
			//sub+=flash.Lib.getTimer()-t;
			closedList.add(cur);
			if( cur.x==end.x && cur.y==end.y ) {
				end = cur;
				break;
			}
			
			//fx.markerCaseTxt(cur.x, cur.y-0.4, idx++, 0x0080FF);
			//fx.markerCaseTxt(cur.x, cur.y, Std.string(Math.round((cur.goalDist)*10)/10), 0xFFFF00);
			
			for( n in neig ) {
				var pt = { x:cur.x+n.dx, y:cur.y+n.dy, homeDist:0., goalDist:0., parent:cur }
				//fx.markerCase(pt.x, pt.y, 0xFF8000, 0.1);
				if( getCollision(pt.x, pt.y) || closedList.has(pt) )
					continue;
				var cost = moveCost(cur.x, cur.y, pt.x, pt.y) * n.cost;
				if( cost<0 )
					continue;
				pt.homeDist = cur.homeDist + cost;
				pt.goalDist = -getHeuristicDist(pt, end);
				if( pt.homeDist<=maxHomeDistance && -pt.goalDist<=maxGoalDistance )
					if( !openList.has(pt) )
						openList.add(pt);
					else {
						var old = openList.search(pt);
						if( pt.homeDist<old.homeDist ) {
							old.homeDist = pt.homeDist;
							old.parent = pt.parent;
						}
					}
			}
		}
		//trace(sub);
		//trace(flash.Lib.getTimer()-total);
		
		if( end.parent==null )
			return new Array();
		else {
			var path = new Array();
			var pt = end;
			while( pt.parent!=null ) {
				//fx.markerCase(pt.x, pt.y, 0x00FF00);
				path.push({x:pt.x, y:pt.y});
				pt = pt.parent;
			}
			path.push({x:start.x, y:start.y});
			return path;
		}
	}
	
	public function setSquareCollision(x,y,w,h, ?b=true) {
		for(ix in x...x+w)
			for(iy in y...y+h)
				colMap[ix][iy] = b;
		resetCache();
	}
	
	
	public inline function setCollision(x:Int,y:Int, ?b=true) {
		colMap[x][y] = b;
		resetCache();
	}
	
	public inline function getCollision(x:Int, y:Int) {
		if( x<0 || x>=wid || y<0 || y>=hei )
			return true;
		else
			return colMap[x][y];
	}
	
	inline function getCollisionFast(x:Int, y:Int) {
		return colMap[x][y];
	}
	
	public function bresenham( x0:Int, y0:Int, x1:Int, y1:Int ) {
		var a = [];
		var error:Int;
		var dx = x1 - x0;
		var dy = y1 - y0;
		var yi = 1;

		if( dx < dy ){
			//-- swap end points
			x0 ^= x1; x1 ^= x0; x0 ^= x1;
			y0 ^= y1; y1 ^= y0; y0 ^= y1;
		}

		if( dx < 0 ) {
			dx = -dx;
			yi = -yi;
		}

		if( dy < 0 ){
			dy = -dy;
			yi = -yi;
		}

		if( dy > dx ) {
			error = -( dy >> 1 );
			while( y1 <= y0) {		// < to <=
				a.push( { x:x1, y:y1 } );
				error += dx;
				if( error > 0 ){
					x1 += yi;
					error -= dy;
				}
				y1++;
			}
		} else {
			error = -( dx >> 1 );
			while( x0 <= x1  ) {		// < to <=
				a.push( { x:x0, y:y0 } );
				error += dy;
				if( error > 0 ) {
					y0 += yi;
					error -= dx;
				}
				x0++;
			}
		}

		return a;
	}

	public function smooth(path:Path) : Path {
		if( path==null )
			return null;
		if( path.length==0 )
			return [];
			
		var smoothed = new Array();
		smoothed.push(path[0]);
		
		var from = 0;
		var i = 1;
		var bresScale = 4;
		while(i<path.length) {
			var pt = path[i];
			var line = bresenham(path[from].x*bresScale, path[from].y*bresScale, pt.x*bresScale, pt.y*bresScale);
			var valid = true;
			for(pt in line)
				if( getCollisionFast(Math.round((pt.x-1)/bresScale), Math.round((pt.y-1)/bresScale)) ||
					getCollisionFast(Math.round((pt.x+1)/bresScale), Math.round((pt.y-1)/bresScale)) ||
					getCollisionFast(Math.round((pt.x+1)/bresScale), Math.round((pt.y+1)/bresScale)) ||
					getCollisionFast(Math.round((pt.x-1)/bresScale), Math.round((pt.y+1)/bresScale)) ) {
						valid = false;
						break;
				}
			
			if( !valid ) {
				smoothed.push( path[i-1] );
				from = i-1;
			}
			else
				i++;
		}
		smoothed.push(path[path.length-1]);
		return smoothed;
	}
	
	
	//public function cacheEverything() {
		//resetCache();
		//
		//for( fx in 0...10 )
			//for( fy in 0...10 )
				//for( tx in 0...10)
					//for( ty in 0...10) {
						//astar({x:fx, y:fy}, {x:tx, y:ty});
					//}
	//}
	
}

