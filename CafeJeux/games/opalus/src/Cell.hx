import Common;
import Anim;
import mt.bumdum.Lib;
import mt.bumdum.Phys;

class Cell {//}
	public var color(default,null) : Int;
	public var team(default,null) : Team;

	public var x(default,null) : Int;
	public var y(default,null) : Int;

	public var chained : Bool;
	public var accA : Bool;
	public var accB : Bool;

	var game : Game;

	var mcGlow : flash.MovieClip;
	var mcBad : flash.MovieClip;
	var mcAlien : flash.MovieClip;
	public function new( g : Game, x : Int, y : Int, f : Int ){
		game = g;
		this.x = x;
		this.y = y;
		color = f;
	}

	public var top(default,null) : Cell;
	public var bottom(default,null) : Cell;
	public var left(default,null) : Cell;
	public var right(default,null) : Cell;

	public function cacheNeighbour(){
		top = game.grid[y-1][x];
		bottom = game.grid[y+1][x];
		left = game.grid[y][x-1];
		right = game.grid[y][x+1];
	}

	public function blob( t : Team ){
		if( color == null ) return;
		color = null;
		team = t;
		var bl = game.getBlob( team );
		bl.add( this );

		if(MMApi.isReconnecting())return;
		
		//GFX
		var max = bl.maxLight;
		var cx = (x+0.5)*Const.CELL_SIZE;
		var cy = (y+0.5)*Const.CELL_SIZE;
		var ma = Math.random()*6.28;
		for( i in 0...max ){
			var a = (i/max)*6.28 + Math.random()*0.2 + ma;
			var ca = Math.cos(a);
			var sa = Math.sin(a);
			var sp = 0.5+Math.random()*2;
			var ray = 8;
			var p = new Phys( game.dm.attach("partLight",Game.DP_PARTS) );
			p.x =  cx + ca*ray;
			p.y =  cy + sa*ray;
			p.vx = ca*sp;
			p.vy = sa*sp;
			p.timer = 10+Math.random()*10;
			p.setScale(100+Math.random()*100);
			p.fadeType = 0;
			p.frict = 0.92;
			p.sleep = 6;
			p.root.gotoAndPlay(Std.random(2)+1);
		}
		
		// TWINKLE
		var mc = game.dm.attach("mcTwinkle",Game.DP_PARTS);
		mc._x = cx;
		mc._y = cy;
	}

	public function getPossibleMoves() : List<Cell> {
		chained = true;
		var ret = new List();
		if( color == null ){
			var n = top;
			if( n != null && !n.chained && n.color != null ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = left;
			if( n != null && !n.chained && n.color != null ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = right;
			if( n != null && !n.chained && n.color != null ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = bottom;
			if( n != null && !n.chained && n.color != null ) for( t in n.getPossibleMoves() ) ret.add( t );
		}else{
			ret.add( this );
			var n = top;
			if( n != null && !n.chained && n.color == color ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = left;
			if( n != null && !n.chained && n.color == color ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = right;
			if( n != null && !n.chained && n.color == color ) for( t in n.getPossibleMoves() ) ret.add( t );
			n = bottom;
			if( n != null && !n.chained && n.color == color ) for( t in n.getPossibleMoves() ) ret.add( t );
		}
		return ret;
	}

	// Show this cell as a possible move
	public function showPM(){
		showGlow();
	}

	public function hidePM(){
		hideGlow();
	}

	// Show this cell as a possible but bad move
	public function showBadPM(c){
		mcBad = game.dm.attach("croix",Game.DP_FX);
		mcBad._x = x * Const.CELL_SIZE + Const.CELL_SIZE / 2;
		mcBad._y = y * Const.CELL_SIZE + Const.CELL_SIZE / 2;
		Col.setColor(mcBad,Const.TOKEN_COLORS[c]);
	}

	public function hideBadPM(){
		mcBad.removeMovieClip();
		mcBad = null;
	}

	public function showGlow(){
		mcGlow = game.dm.attach("glowanim",Game.DP_FX);
		mcGlow._x = x * Const.CELL_SIZE + Const.CELL_SIZE / 2;
		mcGlow._y = y * Const.CELL_SIZE + Const.CELL_SIZE / 2;
		mcGlow.blendMode = "add";
	}

	public function hideGlow(){
		mcGlow.removeMovieClip();
		mcGlow = null;
	}

	public function getMcBlob(){
		return mcBlob;
	}

	//// TMP
	var mcBlob : {> flash.MovieClip, sub: flash.MovieClip };
	
	public function getBlobFrame(){
		var t = team;
		var p = 1;
		if( top.team == t ) p+= 1;
		if( right.team == t ) p+= 2;
		if( bottom.team == t ) p+= 4;
		if( left.team == t ) p+= 8;

		return p;
	}
	
	public function toString(){
		return "Cell "+x+","+y;
	}

//{	
}
