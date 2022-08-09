class Level {

	var game : Game;
	var tbl : Array<Array<Card>>;
	var dx : int;
	var dy : int;

	var combis : Array<int>;

	function new(g) {
		this.game = g;
		combis = [0,0,0,0];
		initLevel();
	}

	function breakCards(c1,c2) {
		var matchs = c1.id.matchs(c2.id);
		if( c1 == c2 )
			return false;

		var m = computePath(c1,c2);
		if( m[c2.x][c2.y] == null )
			return false;

		combis[matchs]++;

		KKApi.addScore( Const.POINTS_ENCODE[matchs] );
		game.spawn(c1,matchs);
		game.spawn(c2,matchs);
		tbl[c1.x][c1.y] = null;
		tbl[c2.x][c2.y] = null;
		return true;
	}

	function canBreak() {
		var x,y;
		for(x=0;x<Const.LVL_WIDTH;x++)
			for(y=0;y<Const.LVL_HEIGHT;y++) {
				var c = tbl[x][y];
				if( c != null ) {

					if( Const.NTURNS >= 1 )
						return true;

					var px,py;
					px = x;
					while( ++px < Const.LVL_WIDTH )
						if( tbl[px][y] != null )
							return true;
					py = y;
					while( ++py < Const.LVL_HEIGHT )
						if( tbl[x][py] != null )
							return true;
					px = x;
					while( --px >= 0 )
						if( tbl[px][y] != null )
							return true;
					py = y;
					while( --py >= 0 )
						if( tbl[x][py] != null )
							return true;
				}
			}
		return false;
	}


	function computePath(c1,c2) {
		tbl[c1.x][c1.y] = null;
		tbl[c2.x][c2.y] = null;
		var m = new Array();
		var i;
		for(i=0;i<Const.LVL_WIDTH;i++)
			m[i] = new Array();
		genColMap(Std.cast(tbl),m,c1.x,c1.y);
		tbl[c1.x][c1.y] = c1;
		tbl[c2.x][c2.y] = c2;
		return m;
	}

	/****** GENERATION *******/

	function shuffle(tbl) {
		var l = tbl.length;
		var i;
		for(i=0;i<l;i++) {
			var a = Std.random(l);
			var b = Std.random(l);
			var s = tbl[a];
			tbl[a] = tbl[b];
			tbl[b] = s;
		}
	}

	function fillColMapRec(tmp : Array<Array<int>>, m : Array<Array<int>>, x : int, y : int, d : int, p : int ) {
		var k = m[x][y];
		if( k > p || tmp[x][y] != null )
			return;
		m[x][y] = p;
		if( x > 0 ) {
			if( d == 0 )
				fillColMapRec(tmp,m,x-1,y,d,p);
			else if( p > 0 )
				fillColMapRec(tmp,m,x-1,y,0,p-1);
		}
		if( y > 0 ) {
			if( d == 1 )
				fillColMapRec(tmp,m,x,y-1,d,p);
			else if( p > 0 )
				fillColMapRec(tmp,m,x,y-1,1,p-1);
		}
		if( x < Const.LVL_WIDTH-1 ) {
			if( d == 2 )
				fillColMapRec(tmp,m,x+1,y,d,p);
			else if( p > 0 )
				fillColMapRec(tmp,m,x+1,y,2,p-1);
		}
		if( y < Const.LVL_HEIGHT-1 ) {
			if( d == 3 )
				fillColMapRec(tmp,m,x,y+1,d,p);
			else if( p > 0 )
				fillColMapRec(tmp,m,x,y+1,3,p-1);
		}
	}

	function genColMap(tmp,m,x,y) {
		fillColMapRec(tmp,m,x,y,0,Const.NTURNS);
		fillColMapRec(tmp,m,x,y,1,Const.NTURNS);
		fillColMapRec(tmp,m,x,y,2,Const.NTURNS);
		fillColMapRec(tmp,m,x,y,3,Const.NTURNS);
	}

	function initLevel() {
		var x,y;
		var w = Const.LVL_WIDTH;
		var h = Const.LVL_HEIGHT;

		tbl = new Array();
		for(x=0;x<w;x++)
			tbl[x] = new Array();
		for(y=0;y<h;y++)
			for(x=0;x<w;x++)
				tbl[x][y] = new Card(game,CardID.random(),x,y);
	}

	function pathLength(c1,c2) {
		var x,y;
		var n = 0;
		if( c1.x < c2.x ) {
			for(x=c1.x;x<c2.x;x++)
				if( tbl[x][c1.y] != null )
					n++;
		} else {
			for(x=c1.x;x>c2.x;x--)
				if( tbl[x][c1.y] != null )
					n++;
		}
		if( c1.y < c2.y ) {
			for(y=c1.y;y<c2.y;y++)
				if( tbl[x][y] != null )
					n++;
		} else {
			for(y=c1.y;y>c2.y;y--)
				if( tbl[x][y] != null )
					n++;
		}
		return n - 1;
	}

/*
	function initLevel() : bool {
		var x,y;
		var w = Const.LVL_WIDTH;
		var h = Const.LVL_HEIGHT;

		var tmp = new Array();
		for(x=0;x<w;x++)
			tmp[x] = new Array();

		var npairs = int((w - 2) * (h - 2) / 2);
		var ids = new Array();
		var i;
		for(i=0;i<npairs;i++)
			ids.push(i%Const.NCARDS);
		shuffle(ids);
		var ntrys = 100;
		while( ntrys > 0 ) {
			x = Std.random(w-2) + 1;
			y = Std.random(h-2) + 1;
			if( tmp[x][y] == null ) {
				var m = new Array();
				for(i=0;i<Const.LVL_WIDTH;i++)
					m[i] = new Array();
				genColMap(tmp,m,x,y);
				m[x][y] = null;

				var best = null;
				for(i=0;i<10;i++) {
					var xp = Std.random(w-2) + 1;
					var yp = Std.random(h-2) + 1;
					var k = m[xp][yp];
					if( k != null && best.k >= k )
						best = {
							x : xp,
							y : yp,
							k : k
						};
				}
				if( best == null )
					ntrys--;
				else {
					var id = ids[--npairs];
					tmp[best.x][best.y] = id;
					tmp[x][y] = id;
					ntrys = (npairs == 0)?0:100;
					// Log.trace("PAIR "+x+","+y+" - "+best.x+","+best.y);
				}
			}
		}

		if( npairs > 1 )
			return false;

		tbl = new Array();
		for(x=0;x<Const.LVL_WIDTH;x++) {
			tbl[x] = new Array();
			for(y=0;y<Const.LVL_HEIGHT;y++) {
				var id = tmp[x][y];
				if( id != null )
					tbl[x][y] = new Card(game,id,x,y);
			}
		}

		return true;
	}
*/
}
