import Common;

typedef LockPos = {
	lock : Bool,
	pos : Pos
}

typedef PPos = {
	x : Int,
	y : Int,
}

class Grid {

	static var g : Array<Array<Pos>>;

	public static function generate() : Array<Array<Pos>> {
		g = new Array();
		closeBorders();
		avoidDoubleClosure();
		randomAnimals();
		return g;
	}

	static function getLines( x, y ) {

		if( x== 0 && y == 0 )
			return 100;

		var i = 0;
		var p = g[x][y];
		if( p.b ) i++;
		if( p.r ) i++;

		if( g[x-1][y].r ) i++;
		if( g[x][y-1].b ) i++;

		return i;
	}

	static function closeBorders() {

		var max = Const.BOARD_SIZE + 1;
		var array = new Array();
		for( i in 0...max ){
			g[i] = new Array();
			for( j in 0...max ){
				var pos : Pos = { t:false,r:false,b:false,l:false,points:0};
				g[i][j] = pos;
				array.push( { x:i, y:j });
			}
		}

		var poss = [ [ [0,1],[1,0] ], [ [1,0],[0,1] ] ];
		var count = 0;
		var to = 0;
		while( count < Const.MAX_BLOCKS && to++ < 500 ) {

			var w = Std.random( array.length );
			if( array.length <= 0) {
				trace("no more element");
				return;
			}
				
			var point = array[w];
			var x = point.x;
			var y = point.y;

			var p = g[x][y];

			if( getLines(x,y) >= 2 ) { 
				continue;
			}

			var tests = [];
			var rnd = Std.random(2);
			if( rnd == 1 ) {
				if( !p.r )tests.push([1,0]);
				if( !p.b )tests.push([0,1]);
			} else {
				if( !p.b )tests.push([0,1]);
				if( !p.r )tests.push([1,0]);
			}

			var current = null;
			for( t in tests ) {

				var nx = x + t[0];
				var ny = y + t[1];

				current = g[nx][ny];
				if( getLines(nx,ny) >= 2 ) {
					continue;
				}

				var isFirstColumn = (x == 0);
				var isFirstLine = (y == 0);
				var right = ( t[0] == 1 );
				var bottom = ( t[0] == 0 );


				if( right && !isFirstLine ) {
					p.r = true;
					count++;
					check(x,y,array);
					check(x+1,y,array);
					break;
				}
				
				if( bottom && !isFirstColumn ) {
					p.b = true;
					count++;					
					check(x,y,array);
					check(x,y+1,array);
					break;
				}
			}
		}


		var actualGrid = new Array();
		for( i in 0...Const.BOARD_SIZE ){
			actualGrid[i] = new Array();
			for( j in 0...Const.BOARD_SIZE ){
				var pos = g[i+1][j+1];
				if( i == 0 ) {
					var leftCell = g[0][j+1];
					if( leftCell.r ) {
						pos.l = true;
						actualGrid[i][j] = pos;
						continue;
					}					
					actualGrid[i][j] = pos;
					continue;
				}
				if( j == 0 ) {
					var topCell = g[i+1][0];
					if( topCell.b ) {
						pos.t = true;
						actualGrid[i][j] = pos;
						continue;
					}					
					actualGrid[i][j] = pos;
					continue;					
				}
				actualGrid[i][j] = pos;
			}
		}
		g = [];
		g = actualGrid;
	}

	static function check( x,y, array ) {
		var pos = g[x][y];
		var line = getLines( x,y);
		if( line >= 2) {
			var element = getElementIndex( x,y, array );
			if( element != null )
				array.splice( element, 1 );
		}
	}

	static function getElementIndex(x : Int,y :Int, a : Array<PPos>) {
		for( i in 0...a.length ) {
			var pos = a[i];
			if( pos.x == x && pos.y == y )
				return i;
		}
		return null;
	}

	static function randomAnimals() {
		if( !Const.WITHPOINTS ) 
			return;

		// les vaches :)
		var i = Std.random( Const.BOARD_SIZE ); 
		var j = Std.random( Const.BOARD_SIZE ); 
		var pos = g[i][j];
		pos.points = 5;

		// les moutons :)
		var max = 3 + Std.random(4);
		for( k in 0...max ) {
			var i = Std.random( Const.BOARD_SIZE ); 
			var j = Std.random( Const.BOARD_SIZE ); 
			var pos = g[i][j];
			if( pos.points <= 0 ) {
				pos.points = 2;
			}
		}
	}

	static function avoidDoubleClosure() {	
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var current : Pos = g[i][j];
				var leftCell = g[i-1][j];
				var topCell = g[i][j-1];

				if( leftCell.r ) current.l = true;
				if( topCell.b  ) current.t = true;
				if( current.l ) leftCell.r = true;
				if( current.t ) topCell.b = true;
			}
		}
	}
	
}
