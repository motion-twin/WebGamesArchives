import data.PuzzleData;

private typedef MC = flash.MovieClip;

class Piece {

	public static inline var YBASE = 0;
	public static inline var SIZE = 36;

	public var x : Int;
	public var y : Int;
	public var mc : MC;
	public var k : PuzzlePiece;
	public var fall : Int;

	public function new(mc,x,y,k) {
		this.mc = mc;
		this.k = k;
		setPos(x,y);
	}

	public function setPos(x,y) {
		this.x = x;
		this.y = y;
		animate(0,0);
	}

	public function animate(dx,dy) {
		this.mc._x = (x + 0.5) * SIZE + dx;
		this.mc._y = (y + 0.5) * SIZE + dy + YBASE;
	}

}

class Level {

	public static inline var SIZE = 8;
	public var tbl : Array<Array<Piece>>;
	public var pieces : Array<PuzzlePiece>;

	public function new() {
		reset();
		pieces = new Array();
		for( c in Type.getEnumConstructs(PuzzlePiece) )
			pieces.push(Reflect.field(PuzzlePiece,c));
	}

	public function reset() {
		tbl = new Array();
		for( x in 0...SIZE )
			tbl[x] = new Array();
	}

	public function set(x,y,p) {
		tbl[x][y] = p;
	}

	public function swap(x,y,h) {
		var p1 = tbl[x][y];
		var p2 = tbl[x + (h?1:0)][y + (h?0:1)];
		p1.setPos(p2.x,p2.y);
		tbl[p2.x][p2.y] = p1;
		p2.setPos(x,y);
		tbl[x][y] = p2;
	}

	public function canSwap(x,y,h) {
		if( h )
			return checkSwapH(x,y,1) || checkSwapH(x+1,y,-1);
		else
			return checkSwapV(x,y,1) || checkSwapV(x,y+1,-1);
	}

	public function checkSwapH(x,y,d) {
		var ak = tbl[x][y].k;
		var a1 = tbl[x+d][y-1].k == ak;
		var a2 = tbl[x+d][y+1].k == ak;
		return ( a1 && a2 )
		|| (a1 && tbl[x+d][y-2].k == ak)
		|| (a2 && tbl[x+d][y+2].k == ak)
		|| (tbl[x+d*2][y].k == ak && tbl[x+d*3][y].k == ak);
	}

	public function checkSwapV(x,y,d) {
		var ak = tbl[x][y].k;
		var a1 = tbl[x-1][y+d].k == ak;
		var a2 = tbl[x+1][y+d].k == ak;
		return ( a1 && a2 )
		|| (a1 && tbl[x-2][y+d].k == ak)
		|| (a2 && tbl[x+2][y+d].k == ak)
		|| (tbl[x][y+d*2].k == ak && tbl[x][y+d*3].k == ak);
	}

	public function checkExplodes() {
		var combos = new List();
		// horizontal checks
		for( y in 0...SIZE ) {
			var last = null;
			var pl = new Array();
			for( x in 0...SIZE ) {
				var p = tbl[x][y];
				if( p.k == last ) {
					pl.push(p);
					continue;
				}
				if( pl.length >= 3 )
					combos.add(pl);
				last = p.k;
				pl = [p];
			}
			if( pl.length >= 3 )
				combos.add(pl);
		}
		// vertical checks
		for( x in 0...SIZE ) {
			var last = null;
			var pl = new Array();
			for( y in 0...SIZE ) {
				var p = tbl[x][y];
				if( p.k == last ) {
					pl.push(p);
					continue;
				}
				if( pl.length >= 3 )
					combos.add(pl);
				last = p.k;
				pl = [p];
			}
			if( pl.length >= 3 )
				combos.add(pl);
		}
		if( combos.isEmpty() )
			return combos;
		// eliminate duplicate combos
		for( c1 in combos )
			for( p in c1 )
				for( c2 in combos )
					if( c2 != c1 && c2.length <= c1.length && c2.remove(p) )
						combos.remove(c2);
		return combos;
	}

	public function destroy( combos : List<Array<Piece>> ) {
		// delete pieces
		for( c in combos )
			for( p in c )
				tbl[p.x][p.y] = null;
	}

	public function gravity() {
		for( x in 0...SIZE )
			for( y in 0...SIZE ) {
				var p = tbl[x][y];
				p.fall = 0;
			}
		var nfalls = 0;
		var y = SIZE - 2;
		while( y >= 0 ) {
			for( x in 0...SIZE ) {
				var p = tbl[x][y];
				if( p !=null && p.fall == 0 ) {
					var under = tbl[x][y+1];
					if( under != null ) {
						// check under status
						p.fall=under.fall;
					} else {
						// nothing under
						var h = 1;
						while( y + h < SIZE - 1 && tbl[x][y+h] == null )
							h++;
						if( tbl[x][y+h] != null )
							h += tbl[x][y+h].fall-1;
						p.fall = h;
					}
				}
				if( p.fall > 0 )
					nfalls++;
			}
			y--;
		}
		// update table
		y = SIZE - 2;
		while( y >= 0 ) {
			for( x in 0...SIZE ) {
				var p = tbl[x][y];
				if( p.fall > 0 ) {
					tbl[x][y+p.fall] = tbl[x][y];
					tbl[x][y] = null;
					p.y += p.fall;
				}
			}
			y--;
		}
		return nfalls;
	}

	public function refill(f) {
		for( x in 0...SIZE )
			for( y in 0...SIZE )
				if( tbl[x][y] == null ) {
					var p = f(x,y);
					tbl[x][y] = p;
					return p;
				}
		return null;
	}

	public function count(k) {
		var count = 0;
		for( x in 0...SIZE )
			for( y in 0...SIZE )
				if( tbl[x][y].k == k )
					count++;
		return count;
	}

}