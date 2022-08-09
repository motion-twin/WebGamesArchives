import mt.bumdum9.Lib;



class Puissance4 extends Game{//}

	static var XMAX = 7;
	static var YMAX = 6;
	static var SIZE = 50;

	var last:Int;
	var timer:Int;
	var rpx:Int;
	var px:Int;
	var py:Float;
	var cur:Int;
	var grid:Array<Array<Int>>;
	var tokens:Array<P4Token>;
	var token:P4Token;
	var playground:flash.display.Sprite;

	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);
		
		grid = getEmptyGrid();
		last = 3;
		cur = dif<0.5?0:1;
		tokens = [];
		
		attachElements();
		nextTurn();
	}

	function attachElements(){
	
		bg = new P4Bg();
		addChild(bg);
		
		// PLAYGROUND
		playground = new flash.display.Sprite();
		addChild(playground);
		
		// BOARD
		var board = new flash.display.Sprite();
		addChild(board);
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				var mc = new P4Hole();
				board.addChild(mc);
				mc.x = getX(x);
				mc.y = getY(y);
			}
		}
	
		// BASE
		var base = new P4Base();
		addChild(base);
		base.x = getX(0)-SIZE*0.5;
		base.y = getY(YMAX-1)+SIZE*0.5;
		
	}
	var opx:Int;
	override function update(){
		super.update();
		
		switch(step) {
			case 1 : // CHOOSE
				
				px = Num.clamp( 0, getPX(getMousePos().x), XMAX - 1 );
				moveToken();
				
				if( click ) {
					if( grid[px][0] == -1 )		initFall();
					else new mt.fx.Flash(bg,0.1,0xFF0000);
				}
				
				
			case 2 : // FALL
				py += 0.5;
				var ny = Math.ceil(py);
				token.y = getY(py);
				if( grid[px][ny] != -1 ) {
					var py  = ny - 1;
					token.y = getY(py);
					token.tabIndex = px * 10 + py;
					grid[px][py] = cur;
					endTurn();
	
				}
				
			case 3 : // IA
				if( rpx != px && Std.random(8) == 0 ) {
					px = rpx;
					if( timer < 6 ) timer = 6;
				}
				moveToken();
				if( timer-- < 0 ) initFall();
		}
		
	}
	
	// MOVE TOKEN
	function moveToken() {
		var free = grid[px][0] == -1;
		py = free? -0.5: -1;
		token.x += (getX(px)-token.x)*0.6;
		var dif  = getY(py) - token.y;
		token.y += dif * 0.4;
		if( dif < 25 && px != opx ) token.y = getY( -1);
		opx = px;
	}
	
	// TURN
	function nextTurn() {
		
		token = new P4Token();
		tokens.push(token);
		playground.addChild(token);
		token.x = getX(Std.int(XMAX * 0.5));
		token.y = -50;
		py = -0.5;
		token.gotoAndStop(cur + 1);
		
		if( cur == 0 ) {
			step = 1;
		}else {
			px = getIaMove();
			rpx = getIaMove();
			step = 3;
			timer = 8;
		}
	}
	
	function endTurn() {
		var a = getLines(cur,grid);
		if( a.length >= 4 ) {
			step = 4;
			setWin(cur == 0, 20);
			var b = [];
			for( to in tokens ) for( o in a ) if( to.tabIndex == o.x * 10 + o.y ) b.push(to);
			
			for( mc in b ) new mt.fx.Flash(mc, 0.1, 0xFFFFFF);
	
			
			return;
		}
		cur = 1 - cur;
		nextTurn();
	}
	
	// IA
	function getIaMove() {
		
		// PLAYABLE
		var a = [];
		for( x in 0...XMAX ) if(grid[x][0] == -1) a.push(x);
		a.sort(sortClose);
		
		// VICTORY !
		if( dif > 0.2 ){
			for( x in a ) {
				var fut = cloneGrid(grid);
				insert( fut, x, cur );
				var a = getLines( cur, fut );
				if( a.length == 4 ) return x;
			}
		}
		
		// BLOCK
		if( Math.random()<dif ){
			for( x in a ) {
				var fut = cloneGrid(grid);
				insert( fut, x, 1-cur );
				var a = getLines( 1 - cur, fut );
				if( a.length == 4 ) return x;
			}
		}
		
		
		
		
		// STANDARD
		var range = 3;
		if( range > a.length ) range == a.length;
		return a[Std.random(range)];
	}
	function sortClose(a:Int,b:Int) {
		if( Math.abs(a - last) <  Math.abs(b - last) ) return -1;
		return 1;
	}
	
	// FALL
	function initFall() {
		last = px;
		token.x = getX(px);
		step = 2;
	}
	

	
	// GRID
	function getEmptyGrid() {
		var grid = [];
		for( x in 0...XMAX ){
			grid[x] = [];
			for( y in 0...YMAX ) grid[x][y] = -1;
		}
		return grid;
	}
	function cloneGrid(gr) {
		var grid = getEmptyGrid();
		for( x in 0...XMAX ){
			grid[x] = [];
			for( y in 0...YMAX ) grid[x][y] = gr[x][y];
		}
		return grid;
	}
	function insert(gr, x, col) {
		for( y in 0...YMAX ) {
			if( gr[x][y + 1] != -1 ) {
				gr[x][y] = col;
				return;
			}
		}
	}
	
	function scanGrid() {
		
	}
	
	
	
	function getLines(col:Int,grid):Array<{x:Int,y:Int}> {
		
		var max = [];
		
		// COLONNES
		for( x in 0...XMAX ) {
			var a = [];
			for( y in 0...YMAX ) {
				if( grid[x][y] == col ){
					a.push( { x:x, y:y } );
				}else {
					if( a.length > max.length ) max = a;
					a = [];
				}
			}
			if( a.length > max.length ) max = a;
		}
		
		// LINES
		for( y in 0...YMAX ) {
			var a = [];
			for( x in 0...XMAX ) {
				if( grid[x][y] == col ){
					a.push( { x:x, y:y } );
				}else {
					if( a.length > max.length ) max = a;
					a = [];
				}
			}
			if( a.length > max.length ) max = a;
		}
		
		// DIAG 1
		var dg = [];
		for( i in 0...XMAX + YMAX ) dg[i] = [];
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				dg[x + y].push({ x:x, y:y, col:grid[x][y] });
			}
		}
		for( b in dg ) {
			var a = [];
			for( o in b ) {
				if( o.col == col ) {
					a.push( { x:o.x, y:o.y } );
				}else {
					if( a.length > max.length ) max = a;
					a = [];
				}
			}
			if( a.length > max.length ) max = a;
		}
		
		// DIAG 2
		var dg = [];
		for( i in 0...XMAX + YMAX ) dg[i] = [];
		for( x in 0...XMAX ) {
			for( y in 0...YMAX ) {
				dg[(YMAX-1)+x-y].push({ x:x, y:y, col:grid[x][y] });
			}
		}
		for( b in dg ) {
			var a = [];
			for( o in b ) {
				if( o.col == col ) {
					a.push( { x:o.x, y:o.y } );
				}else {
					if( a.length > max.length ) max = a;
					a = [];
				}
			}
			if( a.length > max.length ) max = a;
		}
		
		return max;
		
		
	}
	
	
	//
	inline function getX(x:Float) {
		return 50 + x * SIZE;
	}
	inline function getY(y:Float) {
		return 80 + y * SIZE;
	}
	inline function getPX(x:Float) {
		return Math.round((x - 50) / SIZE);
	}
	
//{
}

