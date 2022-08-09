import Pion;

class Level {

	static var D = Const.D;
	static var D2 = D * 2;

	var game : Game;
	public var all : Array<Pion>;
	public var tbl : Array<Array<Pion>>;
	public var minX : Int;
	public var maxX : Int;
	public var minY : Int;
	public var maxY : Int;

	public function new( g ) {
		game = g;
		all = new Array();
		tbl = new Array();
		tbl[D] = new Array();
		tbl[D][D] = new Pion(game,D,D,PNeutral);
		minX = minY = D - 3;
		maxX = maxY = D + 3;
	}

	public function canPut(x,y) {
		var l = lookup(x,y);
		return l.x == x && l.y == y;
	}

	public function lookup( x : Int, y : Int ) {
		if( lookupX(x,y,1) )
			return { x : x, y : y, dx : 1, dy : 0 };
		if( lookupX(x,y,-1) )
			return { x : x, y : y, dx : -1, dy : 0 };
		if( lookupY(x,y,1) )
			return { x : x, y : y, dx : 0, dy : 1 };
		if( lookupY(x,y,-1) )
			return { x : x, y : y, dx : 0, dy : -1 };
		return null;
	}

	public function lookupX(x,y,dx) {
		if( tbl[x-dx][y] == null )
			return false;
		while( tbl[x][y] == null ) {
			x += dx;
			if( x < 0 || x > D2 )
				return true;
		}
		return false;
	}

	public function lookupY(x,y,dy) {
		if( tbl[x][y-dy] == null )
			return false;
		while( tbl[x][y] == null ) {
			y += dy;
			if( y < 0 || y > D2 )
				return true;
		}
		return false;
	}

	public function set( x, y, mine ) {
		if( tbl[x] == null )
			tbl[x] = new Array();
		var p = new Pion(game,x,y,if( mine ) PMine else POther);
		all.push(p);
		tbl[x][y] = p;
		if( x < minX )
			minX = x;
		else if( x > maxX )
			maxX = x;
		if( y < minY )
			minY = y;
		else if( y > maxY )
			maxY = y;
		return p;
	}

	public function checkVictory() {
		var best = null;
		for( x in 0...D2 ) {
			if( tbl[x] == null )
				continue;
			var count = 0;
			var kind = null;
			for( y in 0...D2 ) {
				var k = tbl[x][y].kind;
				if( k == kind )
					count++;
				else {
					if( kind != null && count >= 4  )
						best = { k : kind, n : count, x : x, y : y-4, h : false };
					else if( count == 3 && best == null && kind == POther && (canPut(x,y) || canPut(x,y-4)) )
						best = { k : kind, n : count, x : x, y : y-3, h : false };
					count = 1;
					kind = k;
				}
			}
		}
		for( y in 0...D2 ) {
			var count = 0;
			var kind = null;
			for( x in 0...D2 ) {
				var k = tbl[x][y].kind;
				if( k == kind )
					count++;
				else {
					if( kind != null && count >= 4  )
						best = { k : kind, n : count, x : x-4, y : y, h : true };
					else if( count == 3 && best == null && kind == POther && (canPut(x,y) || canPut(x-4,y)) )
						best = { k : kind, n : count, x : x-3, y : y, h : true };
					count = 1;
					kind = k;
				}
			}
		}
		return best;
	}

}
