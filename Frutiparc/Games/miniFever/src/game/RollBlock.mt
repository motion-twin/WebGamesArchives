class game.RollBlock extends Game{//}
	
	// CONSTANTES
	static var EC = 12
	static var XMAX = 21
	static var YMAX = 21
	static var CX = -6 
	static var CY = -6 
	
	static var EMPTY = 0;
	static var PATH = 1;
	static var SEA = 2;
	static var BLOCK = 3;
	static var OUT = 4;
	
	static var DIR = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}]
	
	static var FLTRACE = true;
	
	
	// VARIABLES
	
	var flWillWin:bool;
	var x:int;
	var y:int;
	var cmax:int;
	var cd:int;
	var gtry:int;
	var coef:float;
	var grid:Array<Array<int>>
	var nList:Array<{x:int,y:int,d:int}>
	var test:String;
	
	// MOVIECLIPS
	var ball:MovieClip;
	var cross:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400
		super.init();
		test =""
		cmax = 4+int(dif*0.12)
		gtry = 0

	};
	
	function genLevel(){

		// GRILLE
		grid = new Array();
		for(var x=0; x<XMAX; x++){
			grid[x] = new Array();
			for(var y=0; y<YMAX; y++){
				grid[x][y] = (x==0 || x==XMAX-1 || y==0 || y==YMAX-1)?SEA:EMPTY;

			}
		}
		
		// SORTIE + GENERATION
		{
			var m = 4
			var sx = m+Std.random(XMAX-2*m)
			var sy = m+Std.random(YMAX-2*m)
			grid[sx][sy] = OUT

			nList = [{x:sx,y:sy,d:Std.random(4)}]
			getRange()
			
			var last = nList[nList.length-1]
			x = last.x
			y = last.y
		}
		
		
		// PARASITES
		
		var bList = new Array();
			var max = null;
			// FALSE PATH
			for( var i=0; i<8; i++ ){
				var m = 4
				var x = m+Std.random(XMAX-2*m)
				var y = m+Std.random(YMAX-2*m)
				var d = DIR[Std.random(4)]
				while(true){
					x += d.x;
					y += d.y;
					var sq = grid[x][y]
					if(sq == EMPTY ){
						grid[x][y] = PATH
					}
					if(sq == SEA )break;
				}
			}
			
			// LINE
			max = Math.min( dif*0.2, 8 )
			for( var i=0; i<max; i++ ){
				var m = 4
				var x = m+Std.random(XMAX-2*m)
				var y = m+Std.random(YMAX-2*m)
				var d = DIR[Std.random(4)]
				while(true){
					x += d.x;
					y += d.y;
					var sq = grid[x][y]
					if(sq == EMPTY ){
						grid[x][y] = BLOCK
						bList.push({x:x,y:y})
					}
					if(sq == SEA )break;
				}
			}
			
			// HOLE
			bList = Std.cast(Tools.shuffle)(bList)
			for( var i=0; i<max; i++ ){
				var p = bList.pop();
				grid[p.x][p.y] = EMPTY
			}
			
			// ALONE
			max = Math.floor(dif*0.1)
			for( var i=0; i<max; i++ ){
				var m = 1
				var x = m+Std.random(XMAX-2*m);
				var y = m+Std.random(YMAX-2*m);
				if(grid[x][y]==EMPTY)grid[x][y] = BLOCK;
			}
			

	
	}
	
	function getRange():bool{
		if( nList.length >= cmax ){
			return true;
		}
		var last = nList[nList.length-1]
		var d = DIR[last.d]
		
		// Fait la liste des distances accessibles
		var dList = new Array();
		var n = 0
		while(true){
			n++
			var nx = last.x+n*d.x;
			var ny = last.y+n*d.y;
			var sq = grid[nx][ny]
			if( sq == EMPTY ){
				dList.push(n)
			}else{
				if( sq != PATH )break;
			}
		}
		
		// Melange de la liste des distances accessibles
		dList = Std.cast(Tools.shuffle)(dList)

		
		// Parcours les distances accessibles
		while(dList.length>0){
			
			// Récupère une distance
			var dist = dList.pop();
			
			
			// Calcule le x et le y de la case d'arrivée
			var nx = last.x + dist*d.x; 
			var ny = last.y + dist*d.y; 
			// Peint le chemin
			for( var i=1; i<dist+1; i++ ){
				var px = last.x + i*d.x
				var py = last.y + i*d.y
				grid[px][py] = PATH
			}
		
			// Choisis une direction au hasard parmis les deux disponibles
			var dir = new Array();
			dir.push( (last.d+1)%4 )
			dir.push( (last.d+3)%4 )
			dir = Std.cast(Tools.shuffle)(dir)
			while(dir.length>0){
				// index de la direction a verifier;
				var nd = dir.pop();
				// essaie de placer un block dans la direction opposé
				var od = (nd+2)%4
				var bx = nx+DIR[od].x
				var by = ny+DIR[od].y
				var sq = grid[bx][by]
				if( sq == EMPTY || sq == BLOCK ){
					
					// Pose le block
					grid[bx][by] = BLOCK

					// Ajoute a la liste
					nList.push({x:nx,y:ny,d:nd})
					
					// verifie le prochain path
					if(getRange()){
						return true;
					}
					
					// nettoie la liste
					nList.pop();
					
					// Enleve le block
					grid[bx][by] = sq
					
				}
							
				
			}

			// Nettoie le chemin
			for( var i=1; i<dist+1; i++ ){
				var px = last.x + i*d.x
				var py = last.y + i*d.y
				grid[px][py] = EMPTY
			}

		}
		
		// ECHEC
		return false;
				
	}

	function attachElements(){
		
		// BLOCK AND HOLE
		for( var x=0; x<XMAX; x++ ){
			for( var y=0; y<YMAX; y++ ){
				var sq = grid[x][y]
				if( sq == BLOCK || sq == OUT ){
					var mc = dm.attach("mcRollSquare",Game.DP_SPRITE)
					mc._x = getX(x)
					mc._y = getY(y)
					mc.gotoAndStop((sq==BLOCK)?"1":"2")					
				}
			}		
		}
		
		// BALL
		/*
		var last = nList[nList.length-1]
		x = last.x
		y = last.y
		*/
		ball = dm.attach("mcRollSquare",Game.DP_SPRITE)
		ball._x = getX(x)
		ball._y = getY(y)
		ball.gotoAndStop("3")
		
		// CROSS
		//*
		cross = dm.attach("mcRollSquare",Game.DP_SPRITE)
		cross._x = ball._x
		cross._y = ball._y
		cross.gotoAndStop("4")

		//*/

	}

	function update(){
		super.update();
		switch(step){
			case 1:
				gtry++;
				genLevel();
				step = 11;

				break;
			case 11:
				var b = bestPath()
				if( b >= cmax*0.6 || gtry > 5 ){
					attachElements();
					step = 2
				}else{
					//Log.trace(b+" < "+cmax*0.75+" ("+cmax+")")
					step = 1
				}			
				break;
			case 2:
				// CROSS
				var dx = _xmouse - (ball._x+EC*0.5)
				var dy = _ymouse - (ball._y+EC*0.5)
				var a = Math.atan2(dy,dx) + 0.77
				if(a<0)a+=6.28;
				var d = Math.floor((a/6.28)*4)
				downcast(cross).d.gotoAndStop(string(d+1))
				
				// PRESS
				if( base.flPress ){
					cross._visible = false;
					cd = d
					var nd = DIR[cd]
					x -= nd.x;
					y -= nd.y;
					coef = 1
					step = 3
					
				}
			
				break;
			case 3:
				coef += 0.66*Timer.tmod;
				var d = DIR[cd]
				while(coef>1){
					coef--
					
					x += d.x
					y += d.y

					var sq = grid[x][y]
					if( sq == OUT ){
						flWillWin = true
						downcast(ball).o._visible = false;
						step = 4
						coef = 0
						break;
					}
					
					if( sq == SEA ){
						flWillWin = false
						downcast(ball).o._visible = false;
						step = 4
						coef = 0
						break;
					}
					
					// PROCHAINE CASE
					var nx = x + d.x
					var ny = y + d.y
					var nsq = grid[nx][ny] 
					if( nsq == BLOCK ){
						initMove();
						coef = 0
						break;
					}
				
				}
				
				ball._x = getX(x+coef*d.x)
				ball._y = getY(y+coef*d.y)
				break;
			case 4 :
				var mc = downcast(ball).b
				mc._xscale *= 0.85
				mc._yscale = mc._xscale
				mc._y += 0.35
				if(mc._xscale < 10 ){
					mc.removeMovieClip();
					setWin(flWillWin)
				}
				break;
		}
		
		
	}
	
	function initMove(){
		step = 2;
		cross._visible = true;
		cross._x = getX(x)
		cross._y = getY(y)
	}
	
	
	// CHECK BEST PATH
	function bestPath(){
		var best = 100
		for( var d=0; d<4; d++ ){
			best =  Math.min( best, go(x,y,d,2,[]) )
		}
		return best;
	}
	
	function go(x:int,y:int,di:int,result:int,pl:Array<{x:int,y:int,r:int}>):int{

		var d = DIR[di]
		var n = 0
		while(true){
			x += d.x
			y += d.y
			var sq = grid[x][y]
			switch(sq){
				case BLOCK:
					if(n==0)return 999
					result++
					//
					var nx = x-d.x
					var ny = y-d.y
					for( var m=0; m<pl.length; m++){
						var p = pl[m]
						if( p.x == nx && p.y == ny && result>= p.r){
							return 999
						}
					}
					pl.push({x:nx,y:ny,r:result})
					//
					
					var dir = new Array();
					dir.push( (di+1)%4 )
					dir.push( (di+3)%4 )
					var bw = 999
			
					for( var i=0; i<dir.length; i++ ){
						var ndi = dir[i]
						bw = int(Math.min( bw, go( nx, ny, ndi, result, pl) ));
					}
					
					return bw
					
				case SEA:
					return 999
					break;
				case OUT:
					return result;
					break;
				
			}
			n++	

		}
		
		
		/*

		*/
		
		
	}
	
	
	
	
	// TOOLS
	function getX(gx){
		return CX + gx*EC
	}
	
	function getY(gy){
		return CY + gy*EC
	}	
	
	
	
//{	
}















