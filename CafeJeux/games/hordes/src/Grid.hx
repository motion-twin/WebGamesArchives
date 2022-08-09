import Common;

typedef T_Grid = Array<Array<{x:Int,y:Int,p:Int,t:Bool}>>;

class Grid {

	static var g : T_Grid;

	public static function generate() : Array<Array<{x:Int,y:Int,p:Int,t:Bool}>> {
		g = new Array();

		// Attention : le nombre de case doit toujours être pair
		var max = Const.BOARD_SIZE;
		var array = new Array();
		for( i in 0...max ){
			g[i] = new Array();
			for( j in 0...max ){
				g[i][j] = { x:i, y:j, p:0, t:false };
//				g[i][j] = { x:i, y:j, p:Std.random(6) + 2, t:if( Std.random( 2 ) == 0 ) true else false };
			}
		}

		for( i in 1...4 ) {
			g[max-i][max-i] = {x:max-i,y:max-i, p:0, t: false };
			g[max-i][max-i] = {x:max-i,y:max-i, p:0, t: false };
		}

		switch( Const.MODE_GFX ) {
			case High:
				var d = Std.int( Const.BOARD_SIZE * Const.BOARD_SIZE * Const.GFX_HIGH / 100 );
				if( d % 2 != 0 ) d++;
				discardCells( g, d );

			case Medium :
				var d = Std.int( Const.BOARD_SIZE * Const.BOARD_SIZE * Const.GFX_MEDIUM / 100 );
				if( d % 2 != 0 ) d++;
				discardCells( g, d );

			case Low :
				var d = Std.int( Const.BOARD_SIZE * Const.BOARD_SIZE * Const.GFX_LOW / 100 );
				if( d % 2 != 0 ) d++;
				discardCells( g, d );
		}

//		setDoorTriggers(g,3);

		return g;
	}

	static function setDoorTriggers(g:T_Grid,n) {
		var clist = new Array();
		for (row in g) {
			for (cell in row) {
				if (cell!=null) clist.push(cell);
			}
		}

		var maxTries =  50;
		while( n>0 && maxTries-- > 0 ) {
			var cell = clist[Std.random(clist.length)];
			if ( cell.x==-1 && cell.y==-1 ) continue;
			cell.x = -1;
			cell.y = -1;
			n--;
//			var x = if( Std.random( 2 ) == 1 ) 0 else Const.BOARD_SIZE -1;
//			var y = if( Std.random( 2 ) == 1 ) 0 else Const.BOARD_SIZE -1;
//			if( g[x][y] == null ) continue;
//			g[x][y] = { x:-1, y:-1 };
//			return;
		}
	}

	static function discardCells( grid:T_Grid, discardedCells : Int ) {
		var maxTries = 180;

		while( discardedCells > 0 && maxTries > 0 ) {
			maxTries--;
			var x = Std.random(Const.BOARD_SIZE);
			var y = Std.random(Const.BOARD_SIZE);
			var c = grid[x][y];

			if( c == null ) continue;
			if( !isBorder( g, c ) ) continue;

			grid[x][y] = null;
			discardedCells--;
		}
	}

	static function isBorder( g:T_Grid, c ) {
		if( c.y % 2 == 0 ) {
			var directions = Const.DIRECTIONS_2.copy();
			while( directions.length > 0 ) {
				var idx = Std.random(directions.length);
				var d = directions[idx];
				var x = c.x + d.x;
				var y = c.y + d.y;
				directions.splice( idx,1);
				if( g[x][y] == null ) {
					return true;
				}
			}
			return false;
		}
		var directions = Const.DIRECTIONS_1.copy();
		while( directions.length > 0 ) {
			var idx = Std.random(directions.length);
			var d = directions[idx];
			var x = c.x + d.x;
			var y = c.y + d.y;
			directions.splice( idx,1);
			if( g[x][y] == null ) {
				return true;
			}
		}
		return false;
	}

}
