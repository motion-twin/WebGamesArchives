package ac;
import Protocole;
import mt.bumdum9.Lib;



class Fall extends Action {//}
	
	var speed:Float;
	var boards:Array<Board>;
	var balls:Array <Ball>;
	

	public function new(?b,direct=false) {
		super();
		boards = [];
		if ( b != null ) boards.push(b);
		
		else {
			for ( h in game.heroes ) boards.push(h.board);
		}
		//speed = 0.34;
		speed = 0.2;
		if ( direct ) speed = 20;
	}
	override function init() {
		super.init();
		initVertical();

	}
	function initVertical() {
		step = 0;
		coef = 0;
		balls = [];
		
		for( board in boards ){
			var grid = board.getGrid();
			for ( x in 0...board.xmax ) {
				var fall = 0;
				for ( dy in 0...board.ymax ) {
					var y = board.ymax - (1 + dy);
					var b = grid[x][y];
					if ( b == null ) {
						fall++;
					}else {
						b.fall = fall;
						if( fall > 0 )balls.push(b);
					}
			
				}
			}
		}
		
		if ( balls.length == 0 )
			initHorizontal();
		
		
	}
	function initHorizontal() {
		nextStep();
		balls = [];
		for( board in boards ){
			var grid = board.getGrid();
			var fall = 0;
			for ( x in 0...board.xmax ) {
				for ( y in 0...board.ymax ) {
					var b = grid[x][y];
					if ( b == null ) {
						if ( y == board.ymax - 1 ) fall++;
					}else {
						b.fall = fall;
						if( fall > 0 )balls.push(b);
					}
				}
			}
		}
		if ( balls.length == 0 )
			finish();
	}
	
	
	// UPDATE
	override function update() {
		super.update();
		coef = coef + speed;
		
		switch(step) {
			 case 0 :
				while ( coef >= 1 ) {
					coef--;
					var end = true;
					for ( b in balls ) {
						if ( b.fall == 0 ) continue;
						b.fall--;
						b.setPos(b.px, b.py + 1);
						//if ( end && b.fall > 0 ) end = false;
						end = false;
					}
					if ( end ) {
						initHorizontal();
						return;
					}
				}
				for ( b in balls ) {
					if ( b.fall == 0 ) continue;
					b.y = (b.py+0.5 + coef) * Ball.SIZE;
				}
				
			case 1 :
				while ( coef >= 1 ) {
					coef--;
					var end = true;
					for ( b in balls ) {
						if ( b.fall == 0 ) continue;
						b.fall--;
						b.setPos(b.px-1, b.py);
						end = false;
					}
					if ( end ) {
						finish();
						return;
					}
				}
				for ( b in balls ) {
					if ( b.fall == 0 ) continue;
					b.x = (b.px+0.5 - coef) * Ball.SIZE;
				}
					
			
		}
		

	
	}

	function finish() {
		for( board in boards ){
			board.buildGroups();
			board.ready = true;
			board.checkBreath();
		}
		kill();
	}
	
	
//{
}