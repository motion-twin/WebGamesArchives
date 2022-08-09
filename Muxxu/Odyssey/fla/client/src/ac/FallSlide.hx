package ac;
import Protocole;
import mt.bumdum9.Lib;


private typedef FEvent = {
	ball:Ball,
	tw:Tween,
	type:Int,
}

class FallSlide extends Action {//}
	
	var speed:Float;
	var board:Board;
	var grid:Array<Array<Ball>>;	
	var events:Array<FEvent>;	

	public function new(b,direct=false) {
		super();
		board = b;
		speed = 0.34;
		speed = 0.15;
		if ( direct ) speed = 20;
		
	}
	override function init() {
		super.init();
		coef = 0;		
		grid = board.getGrid();
		tick();
	}
	
	// UPDATE
	override function update() {
		super.update();
		coef = coef + speed;
		
		while ( coef >= 1 ) {
			coef--;
			var end = true;
			for ( ev in events ) ev.ball.updatePos();
			tick();
			if ( events.length == 0) {
				board.buildGroups();
				board.ready = true;
				kill();
				return;
			}			
		}
		
		for ( ev in events ) {
			var p = ev.tw.getPos(coef);
			ev.ball.gotoPos(p.x, p.y);
		}		
		
	
		
		
		
	}

	//
	function tick() {
		events = [];
			
		// FALL
		grid = board.getGrid();
		for ( b in board.balls ) {
			if ( isSolid(b.px,b.py+1) ) continue;
			addBall(b, 0, 1);
		}
		
		// SLIDE
		for ( b in board.balls ) {
		
			var up = getBall(b.px, b.py - 1);
			if ( up != null ) continue;
			
			var sides = [false, false];
			for ( i in 0...2 ) {					
				var sens = i * 2 - 1;
				if ( !board.isIn(b.px + sens, b.py) || !board.isIn(b.px, b.py + 1) ) continue;
				if( !isSolid(b.px+sens,b.py) && !isSolid(b.px+sens,b.py+1) ) sides[i] = true;				
			}
			
			var side = -1;
			for ( i in 0...2 ) if ( sides[i] ) side = i;				
			if ( sides[0] && sides[1] ) side = Std.random(2);
			
			if ( side == -1 ) continue;
			addBall(b, side*2-1, 1 );				
			
		}
		
	}
	
	//
	inline function getBall(x,y) {
		if ( !board.isIn(x, y) ) return null;
		else return grid[x][y]; 
	}
	inline function isSolid(x, y) {
		if ( !board.isIn(x, y) ) {
			return true;
		}else{
			return grid[x][y] != null;
		}
	}
	
	
	inline function addBall(b:Ball, dx:Int, dy:Int ) {
		var tw = new Tween(b.px, b.py, b.px + dx, b.py + dy);
		events.push( { ball:b, tw:tw, type:0 } );
		
		grid[b.px][b.py] = null;
		b.px += dx;
		b.py += dy;
		grid[b.px][b.py] = b;
		
	}	
	
//{
}


























