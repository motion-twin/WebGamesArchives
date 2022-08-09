package mt.deepnight;

import mt.gx.algo.Heap;

typedef AStarPoint = {x:Int, y:Int, parent:AStarPoint, goalDist:Float, homeDist:Float};

private class AStarList {
	var hash		: Array<AStarPoint>;
	var heap		: Heap<AStarPoint>;
	public var length(default,null)	: Int;

	public function new() {
		hash = new Array();
		heap = new Heap();
		length = 0;
	}

	public function destroy() {
		hash = null;
		heap = null;
	}

	private inline function id(pt:AStarPoint) {
		return pt.x + pt.y*100000;
	}

	public inline function add(pt:AStarPoint) {
		if( !has(pt) ) {
			hash[id(pt)] = pt;
			heap.heapify({ w : -(pt.goalDist-pt.homeDist), data : pt});
			length++;
		}
	}

	public inline function search(spt:AStarPoint) {
		return hash[id(spt)];
	}

	public inline function popBest() {
		length--;
		return heap.delMin().data;
	}

	public inline function has(pt:AStarPoint) {
		return hash[id(pt)]!=null;
	}
}


// Credits : http://www.policyalmanac.org/games/aStarTutorial.htm

typedef Path = Array<{x:Int, y:Int}>;

class PathFinder {
	var colMap						: Array<Array<Bool>>;
	var wid							: Int;
	var hei							: Int;

	public var moveCost				: Int->Int -> Int->Int -> Float; //    fn(fromX,fromY, toX,toY) -> cost
	public var useCache				: Bool;
	public var cacheSymetricPaths	: Bool;

	var openList					: AStarList;
	var closedList					: AStarList;

	var cache						: Map<Int, Array<{x:Int, y:Int}>>;
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

		setAllCollisions(false);
	}

	public function destroy() {
		colMap = null;

		if( openList!=null ) {
			openList.destroy();
			openList = null;
		}

		if( closedList!=null ) {
			closedList.destroy();
			closedList = null;
		}

		cache = null;

		moveCost = null;
	}

	public inline function resetCache() {
		cache = new Map();
	}

	public function setAllCollisions(defaultValue:Bool) {
		resetCache();
		colMap = new Array();
		for(x in 0...wid) {
			colMap[x] = new Array();
			for(y in 0...hei)
				setCollision(x,y, defaultValue);
		}
	}

	public inline function fillAll(b:Bool) {
		for(x in 0...wid)
			for(y in 0...hei)
				setCollision(x,y,b);
	}

	inline function getHeuristicDist(a:AStarPoint, b:AStarPoint) {
		return MLib.iabs(a.x-b.x) + MLib.iabs(a.y-b.y);
	}

	public function getPath(from:{x:Int, y:Int}, to:{x:Int, y:Int}) : Path {
		return astar(from, to);
	}


	public function astar(from:{x:Int, y:Int}, to:{x:Int, y:Int}) : Path {
		if( useCache ) {
			if( cache[getCacheID(from,to)]!=null ) {
				statCache++;
				return cache[getCacheID(from,to)].copy();
			}
			if( cacheSymetricPaths && cache[getCacheID(to,from)]!=null ) {
				statCache++;
				var a = cache[getCacheID(to,from)].copy();
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
			cache[getCacheID(from,to)] = path;
			//for(i in 0...path.length-1) {
				//var fpt = path[i];
				//var sub = [fpt];
				//for(j in i+1...path.length) {
					//sub.push(path[j]);
					//cache[ getCacheID(fpt, path[j])] = sub.copy(); // TODO : trop coûteux en mémoire!
				//}
			//}
		}

		return path;
	}

	inline function getCacheID(start:{x:Int,y:Int}, end:{x:Int,y:Int}) {
		return start.x + start.y*wid + 100000*(end.x+end.y*wid);
	}

	function astarLoop(start:AStarPoint, end:AStarPoint) : Path {
		var tmp = end; end = start; start = tmp; // Avoid the path to be returned reversed
		openList = new AStarList();
		closedList = new AStarList();
		openList.add(start);

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
		while( openList.length>0 ) {
			var cur = openList.popBest();
			closedList.add(cur);
			if( cur.x==end.x && cur.y==end.y ) {
				end = cur;
				break;
			}

			for( n in neig ) {
				var pt = { x:cur.x+n.dx, y:cur.y+n.dy, homeDist:0., goalDist:0., parent:cur }
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

		if( end.parent==null )
			return new Array();
		else {
			var path = new Array();
			var pt = end;
			while( pt.parent!=null ) {
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

	public function smooth(path:Path) : Path {
		if( path==null )
			return null;
		if( path.length==0 )
			return [];
		if( path.length<=2 )
			return path;

		var smoothed = new Array();
		smoothed.push(path[0]);

		var from = 0;
		var to = 2;

		while( to<path.length ) {
			if( !Bresenham.checkFatLine(path[from].x, path[from].y, path[to].x, path[to].y, function(x,y) return !getCollisionFast(x,y)) ) {
				smoothed.push(path[to-1]);
				from = to-1;
			}
			to++;
		}
		smoothed.push(path[path.length-1]);

		return smoothed;
	}

}

