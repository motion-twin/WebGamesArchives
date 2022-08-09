class Level {

	static var EMPTY = 0;
	static var BLOCK = 1;
	static var EARTH = 2;
	static var FALLING = 3;
	static var BLOCKSPE = 5;

	var game : Game;
	var dun : Array<Array< {
			t : Array<Array<int>>,
			b : Array<{ x : int, y : int, t : int }>
		}>>;
	var px : int;
	var py : int;

	var tbl : Array<Array<int>>;
	var bonus : Array<{ x : int, y : int, t : int }>

	function new( g ) {
		dun = new Array();
		bonus = new Array();
		game = g;
		px = 100;
		py = 0;
	}

	function checkPath(p : Array<Array<bool>>, x : int, y : int ) : bool {
		var l = tbl[x][y];
		if( x < 0 || x >= Const.WIDTH )
			return false;
		if( (l == EMPTY || l == EARTH) && !p[x][y] ) {
			p[x][y] = true;
			if( y == Const.HEIGHT-1 )
				return true;
			if( checkPath(p,x,y+1) )
				return true;
			if( checkPath(p,x-1,y) )
				return true;
			if( checkPath(p,x+1,y) )
				return true;
		}
		return false;
	}

	function init(sx : int,sy : int, diff : int) {
		var d = dun[px][py];
		tbl = d.t;
		bonus = d.b;
		if( tbl != null ) {
			tbl[sx][sy] = EMPTY;
			return;
		}

		var nterres = int(Math.max(100 - diff * 2,10));
		var ntrous = int(Math.max(10-diff/2,3));
		var nlegs = 7+int(diff/10);


		tbl = new Array();
		var x,y;
		for(x=0;x<Const.WIDTH;x++) {
			tbl[x] = new Array();
			for(y=0;y<Const.HEIGHT;y++) {
				if( (y & 1) == 0 ) {
					if( x == 0 || x == Const.WIDTH - 1 ) {
						if( y > 0 && y <= 5 && Std.random(4) == 0 )
							tbl[x][y] = EARTH;
						else
							tbl[x][y] = BLOCKSPE;
					} else
						tbl[x][y] = EARTH;
				}
				else if( x == 0 || x == Const.WIDTH - 1 )
					tbl[x][y] = BLOCKSPE;
				else
					tbl[x][y] = BLOCK;
			}
			tbl[x][y] = EMPTY;
		}
		var i;
		for(i=0;i<nterres;i++) {
			x = Std.random(Const.WIDTH - 2) + 1;
			y = Std.random(Const.HEIGHT) | 1;
			tbl[x][y] = EARTH;
		}

		for(i=0;i<3;i++) {
			x = Std.random(Const.WIDTH - 2) + 1;
			y = Std.random(Const.HEIGHT) & 0xFE;
			tbl[x][y] = BLOCK;
		}

		for(i=0;i<ntrous;i++) {
			x = Std.random(Const.WIDTH - 2) + 1;
			y = Std.random(Const.HEIGHT);
			if( tbl[x][y-1] == EARTH )
				tbl[x][y] = EMPTY;
		}

		tbl[sx][sy] = EMPTY;
		if( sy > 0 ) {
			tbl[sx+1][sy] = EARTH;
			tbl[sx-1][sy] = EARTH;
		}

		tbl[sx][sy+1] = BLOCK;
		var btbl = new Array();
		var probas = Const.BONUS_PROBAS.duplicate();
		probas[0] += 20 - diff;
		if( probas[0] < 10 )
			probas[0] = 10;
		bonus = new Array();
		for(i=0;i<nlegs;i++) {
			x = 1+Std.random(Const.WIDTH-2);
			y = Std.random(Const.HEIGHT-1);
			if( tbl[x][y] == EARTH && Math.abs(sx - x) >= 2 && sy != y && !btbl[x + y * Const.WIDTH] ) {
				var t = Tools.randomProbas(probas);
				if( t == 2 ) {
					var max = int(diff/5)+1;
					if( max > 6 )
						max = 6;
					t = int(2 + Math.min(Std.random(max),Std.random(max)));
				}
				btbl[x + y * Const.WIDTH] = true;
				bonus.push({
					x : x, y : y, t : t
				});
			}
		}

		connect();

		var path = new Array();
		for(x=0;x<Const.WIDTH;x++)
			path[x] = new Array();
		if( checkPath(path,sx,sy) ) {
			if( dun[px] == null )
				dun[px] = new Array();
			dun[px][py] = { t : tbl, b : bonus };
		}
		else
			init(sx,sy,diff);
	}

	function connect() {
		var x,y;
		var t = dun[px-1][py].t;
		if( t != null ) {
			for(y=0;y<Const.HEIGHT;y++) {
				var l = t[Const.WIDTH-1][y];
				if( l != BLOCK && l != BLOCKSPE )
					tbl[0][y] = EARTH;
				else
					tbl[0][y] = BLOCKSPE;
			}
		}
		t = dun[px+1][py].t;
		if( t != null ) {
			for(y=0;y<Const.HEIGHT;y++) {
				var l = t[0][y];
				if( l != BLOCK && l != BLOCKSPE )
					tbl[Const.WIDTH-1][y] = EARTH;
				else
					tbl[Const.WIDTH-1][y] = BLOCKSPE;
			}
		}
	}

}