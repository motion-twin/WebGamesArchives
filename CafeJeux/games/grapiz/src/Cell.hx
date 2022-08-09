import Common;

class Cell {
	public var x(default,null) : Int;
	public var y(default,null) : Int;
	var game : Game;
	public var token : Token;

	public var mc(default,null) : flash.MovieClip;
	
	public function new(g,y,x){
		this.x = x;
		this.y = y;
		game = g;
		display();
	}

	public function display(){
		if( mc == null ) mc = game.dmanagerBoard.attach("hexa",1);
		mc._x = x * 37.5 + 50;
		mc._y = y * 43 - x * 21.5 + Const.RADIUS * 21.5 + 8;
		mc.stop();
	}

	public function addToken( t : Bool ){
		token = new Token(game,this,t);
	}


	public function getLine( d : Direction ){
		if( d == NorthEast || d == SouthWest ){
			return game.grid[y];
		}else if( d == North || d == South ){
			var ret = new Array();
			for( a in game.grid ){
				if( a[x] != null ) ret.push(a[x]);
			}
			return ret;
		}else{ // if( d == NorthWest || d == SouthEast ){
			var ret = new Array();
			var i = 0;
			var last : Cell = null;
			do {
				last = game.grid[y+i][x+i];
				if( last != null ) ret.push( last );
				i++;
			}while( last != null );

			i = -1;
			do {
				last = game.grid[y+i][x+i];
				if( last != null ) ret.push( last );
				i--;
			}while( last != null );
			return ret;
		}
	}

	public function countLineToken( d : Direction ){
		var a = getLine( d );
		var ret = 0;
		for( c in a ){
			if( c.token != null ) ret++;
		}
		return ret;
	}

	public function getNeighbour( d : Direction, ?l : Int, ?team: Bool ){
		if( l == null ) l = 1;
		var next = switch( d ){
			case NorthEast: game.grid[y][x+1];
			case SouthWest: game.grid[y][x-1];
			case North: game.grid[y-1][x];
			case South: game.grid[y+1][x];
			case NorthWest: game.grid[y-1][x-1];
			case SouthEast: game.grid[y+1][x+1];
		}
		if( next == null ) return null;
		if( l == 1 ){
			if( team != null && next.token != null && next.token.team == team ) return null;
			return next;
		}
		if( team != null && next.token != null && next.token.team != team ) return null;
		return next.getNeighbour( d, l-1, team );
	}
	
}
