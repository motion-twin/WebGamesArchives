import Game;
import Anim;

typedef McCell = {> flash.MovieClip, symbol: flash.MovieClip }

class Cell {//}

	public var symbol : Int;
	var x : Int;
	var y : Int;
	public var chained : Bool;

	public var mcSymbol(default,null) : McCell;

	public var removeCount:Int;
	
	public function new( x, y, s ){
		this.x = x;
		this.y = y;
		this.symbol = s;
		this.chained = false;
	}

	public function display(){
		if( mcSymbol == null ) mcSymbol = cast Game.dm.attach("cell",Game.DP_CELL);
		
		mcSymbol.stop();
		mcSymbol._x = getX(x);
		mcSymbol._y = getY(y); 
		mcSymbol.symbol.gotoAndStop( symbol + 1 );
		mcSymbol.onRelease = onClic;
		mcSymbol.onRollOver = onRollOver;

		mcSymbol.gotoAndStop(Const.ANIM_APPEAR.start);
		Game.addAnim( new AnimPlay(mcSymbol,Const.ANIM_APPEAR,x+y+Std.random(2)) );
	}

	public function kill(){
		if( !chained ){
			var time:Float = (x+y)*4;
			var dx = x - KKApi.val(Game.width)*0.5;
			var dy = y - KKApi.val(Game.height)*0.5;			
			switch(Game.cleanId){
				case 1:
					time = x*5 + y;
				case 2:
					time = y*5 + x;
				case 3:
					time = Math.sqrt(dx*dx+dy*dy)*5;
				case 4:
					time = (Math.atan2(dy,dx)+3.14)*5;				
			}
			Game.addAnim( new BeurkAnim(Std.int(time),remove,Const.DESTROY_ANIM_LENGTH) );
		}else{
			remove();
		}
	}

	function remove(){
		Game.inst.destroyAnim( mcSymbol, EndLevel );
		mcSymbol.removeMovieClip();
	}

	function onClic(){
		if( !Game.locked() && !Game.suite.started() && Game.suite.check( this ) ){
			Game.suite.next(this);
		}else if( !Game.locked() && Game.suite.started() ){
			//onRollOver();
			Game.suite.reinit();
		}
	}

	function onRollOver(){
		if( !Game.locked() && isNeighbour(Game.suite.last()) && Game.suite.check( this ) ){
			Game.suite.next(this);
		}	
	}

	public function tryNeighbour(){
		if( Game.locked() ) return;

		var difX = mcSymbol._parent._xmouse - mcSymbol._x;
		var difY = mcSymbol._parent._ymouse - mcSymbol._y;

		var n = null;
		if( Math.abs(difX) > Math.abs(difY) ){
			if( difX > 20 ){
				n = Game.grid[y][x+1];
			}else if( difX < -20 ){
				n = Game.grid[y][x-1];
			}
		}else{
			if( difY > 20 ){
				n = Game.grid[y+1][x];
			}else if( difY < -20 ){
				n = Game.grid[y-1][x];
			}
		}

		if( n != null && Game.suite.check(n) ){
			Game.suite.next(n);
		}
	}


	public function isNeighbour( c : Cell ){
		if( c == null ) return null;

		if( c == Game.grid[y][x-1] ) return true;
		if( c == Game.grid[y][x+1] ) return true;
		if( c == Game.grid[y-1][x] ) return true;
		if( c == Game.grid[y+1][x] ) return true;
		
		return false;
	}

	public function randomNeighbour(){
		var a = new Array();
		var c = Game.grid[y][x-1];
		if( c != null && !c.chained ) a.push( c );

		c = Game.grid[y][x+1];
		if( c != null && !c.chained ) a.push( c );

		c = Game.grid[y-1][x];
		if( c != null && !c.chained ) a.push( c );

		c = Game.grid[y+1][x];
		if( c != null && !c.chained ) a.push( c );

		return a[Std.random(a.length)];
	}

	public function hide(){
		Game.inst.destroyAnim( mcSymbol, SnakeEat );
	}

	public function displaySnake( prev : Cell, next : Cell ){
		mcSymbol._visible = true;
		if( (prev == null || prev.x == x) && next.x == x ) mcSymbol.gotoAndStop( Const.FRAME_VERT );
		if( (prev == null || prev.y == y) && next.y == y ) mcSymbol.gotoAndStop( Const.FRAME_HORI );

		if( prev.x  == x && prev.y > y && next.x > x ) mcSymbol.gotoAndStop( Const.FRAME_BOTTOM_RIGHT );
		if( next.x  == x && next.y > y && prev.x > x ) mcSymbol.gotoAndStop( Const.FRAME_BOTTOM_RIGHT );

		if( prev.x  == x && prev.y > y && next.x < x ) mcSymbol.gotoAndStop( Const.FRAME_BOTTOM_LEFT );
		if( next.x  == x && next.y > y && prev.x < x ) mcSymbol.gotoAndStop( Const.FRAME_BOTTOM_LEFT );

		if( prev.x  == x && prev.y < y && next.x < x ) mcSymbol.gotoAndStop( Const.FRAME_TOP_LEFT );
		if( next.x  == x && next.y < y && prev.x < x ) mcSymbol.gotoAndStop( Const.FRAME_TOP_LEFT );

		if( prev.x  == x && prev.y < y && next.x > x ) mcSymbol.gotoAndStop( Const.FRAME_TOP_RIGHT );
		if( next.x  == x && next.y < y && prev.x > x ) mcSymbol.gotoAndStop( Const.FRAME_TOP_RIGHT );
	}

	public function hideSnake(){
		mcSymbol._visible = true;
		mcSymbol.gotoAndStop(1);
		mcSymbol.symbol.gotoAndStop( symbol + 1 );
	}

	public static function getX(x){
		var s = 30;
		return x * s + (300 - KKApi.val(Game.width) * s)/2 + s / 2;
	}
	public static function getY(y){
		var s = 30;
		return y * s + 60 + (240 - KKApi.val(Game.height) * s)/2 + s / 2;
	}	
	
//{
}

