class RollBlock extends Game{//}

	// CONSTANTES
	static var EC = 12;
	static var XMAX = 21;
	static var YMAX = 21;
	static var CX = -6;
	static var CY = -6;

	static var EMPTY = 0;
	static var PATH = 1;
	static var SEA = 2;
	static var BLOCK = 3;
	static var OUT = 4;

	static var DIR = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}];

	static var FLTRACE = true;


	// VARIABLES


	var mx:Int;
	var my:Int;
	var cmax:Int;
	var cd:Int;
	var gtry:Int;
	var coef:Float;
	var grid:Array<Array<Int>>;
	var nList:Array<{x:Int,y:Int,d:Int}>;
	var test:String;

	// MOVIECLIPS
	var ball:flash.display.MovieClip;
	var cross:flash.display.MovieClip;

	override function init(dif){
		gameTime = 400;
		super.init(dif);
		test ="";
		cmax = 4+Std.int(dif*12);
		gtry = 0;
		zoomOld();
		
		genLevelFinal();
		step = 2;
		//genLevel();
		attachElements();
	}

	function genLevelFinal() {
	
		for( i in 0...5 ){
			genLevel();
			var b = bestPath();
			if( b >= cmax * 0.6  ) break;
		}
	}
	
	function genLevel(){

		bg = dm.attach("rollBlock_bg",0);

		// GRILLE
		grid = new Array();
		for( x in 0...XMAX ){
			grid[x] = new Array();
			for( y in 0...YMAX ){
				grid[x][y] = (x==0 || x==XMAX-1 || y==0 || y==YMAX-1)?SEA:EMPTY;

			}
		}

		// SORTIE + GENERATION
		{
			var m = 4;
			var sx = m+Std.random(XMAX-2*m);
			var sy = m+Std.random(YMAX-2*m);
			grid[sx][sy] = OUT;

			nList = [{x:sx,y:sy,d:Std.random(4)}];
			getRange();

			var last = nList[nList.length-1];
			mx = last.x;
			my = last.y;
		}


		// PARASITES

		var bList = new Array();
		//var max:Null<Int> = null;
		// FALSE PATH
		for( i in 0...8 ){
			var m = 4;
			var x = m+Std.random(XMAX-2*m);
			var y = m+Std.random(YMAX-2*m);
			var d = DIR[Std.random(4)];
			while(true){
				x += d.x;
				y += d.y;
				var sq = grid[x][y];
				if(sq == EMPTY )grid[x][y] = PATH;
				if(sq == SEA )break;
			}
		}

		// LINE
		var max = Std.int( Math.min( dif*20, 8 ));
		for( i in 0...max ){
			var m = 4;
			var x = m+Std.random(XMAX-2*m);
			var y = m+Std.random(YMAX-2*m);
			var d = DIR[Std.random(4)];
			while(true){
				x += d.x;
				y += d.y;
				var sq = grid[x][y];
				if(sq == EMPTY ){
					grid[x][y] = BLOCK;
					bList.push({x:x,y:y});
				}
				if(sq == SEA )break;
			}
		}

		// HOLE
		bList = shuffle( cast bList);
		for( i in 0...max ) {
			if( bList.length == 0 ) break;
			var p = bList.pop();
			grid[p.x][p.y] = EMPTY;
		}

		// ALONE
		max = Math.floor(dif*10);
		for( i in 0...max ){
			var m = 1;
			var x = m+Std.random(XMAX-2*m);
			var y = m+Std.random(YMAX-2*m);
			if(grid[x][y]==EMPTY)grid[x][y] = BLOCK;
		}



	}

	function getRange():Bool{

		if( nList.length >= cmax )return true;

		var last = nList[nList.length-1];
		var d = DIR[last.d];

		// Fait la liste des distances accessibles
		var dList = new Array();
		var n = 0;
		while(true){
			n++;
			var nx = last.x+n*d.x;
			var ny = last.y+n*d.y;
			var sq = grid[nx][ny];
			if( sq == EMPTY )	dList.push(n);
			else if( sq != PATH )	break;

		}

		// Melange de la liste des distances accessibles

		dList = shuffle(dList);



		// Parcours les distances accessibles
		while(dList.length>0){

			// Récupère une distance
			var dist = dList.pop();


			// Calcule le x et le y de la case d'arrivée
			var nx = last.x + dist*d.x;
			var ny = last.y + dist*d.y;
			// PeInt le chemin
			for( i in 1...dist+1 ){
				var px = last.x + i*d.x;
				var py = last.y + i*d.y;
				grid[px][py] = PATH;
			}

			// Choisis une direction au hasard parmis les deux disponibles
			var dir = new Array();
			dir.push( (last.d+1)%4 );
			dir.push( (last.d+3)%4 );

			dir = shuffle( cast dir);//dir = Std.cast(Tools.shuffle)(dir);



			while(dir.length>0){
				// index de la direction a verifier;
				var nd = dir.pop();
				// essaie de placer un block dans la direction opposé
				var od = (nd+2)%4;
				var bx = nx+DIR[od].x;
				var by = ny+DIR[od].y;
				var sq = grid[bx][by];
				if( sq == EMPTY || sq == BLOCK ){

					// Pose le block
					grid[bx][by] = BLOCK;

					// Ajoute a la liste
					nList.push({x:nx,y:ny,d:nd});

					// verifie le prochain path
					if(getRange())	return true;

					// nettoie la liste
					nList.pop();

					// Enleve le block
					grid[bx][by] = sq;

				}


			}

			// Nettoie le chemin
			for( i in 1...dist+1 ){
				var px = last.x + i*d.x;
				var py = last.y + i*d.y;
				grid[px][py] = EMPTY;
			}

		}

		// ECHEC
		return false;

	}

	function attachElements(){

		// BLOCK AND HOLE
		for( x in 0...XMAX ){
			for( y in 0...YMAX ){
				var sq = grid[x][y];
				if( sq == BLOCK || sq == OUT ){
					var mc = dm.attach("mcRollSquare",Game.DP_SPRITE);
					mc.x = getX(x);
					mc.y = getY(y);
					mc.gotoAndStop((sq==BLOCK)?"1":"2");
				}
			}
		}


		ball = dm.attach("mcRollSquare",Game.DP_SPRITE);
		ball.x = getX(mx);
		ball.y = getY(my);
		ball.gotoAndStop("3");

		// CROSS
		//*
		cross = dm.attach("mcRollSquare",Game.DP_SPRITE);
		cross.x = ball.x;
		cross.y = ball.y;
		cross.gotoAndStop("4");

		//*/

	}

	override function update(){
		super.update();
		switch(step){
			/*
			case 1:
			
				gtry++;
				genLevel();
				step = 11;


			case 11:
				var b = bestPath();
				if( b >= cmax*0.6 || gtry > 5 ){
					attachElements();
					step = 2;
				}else{
					//Log.trace(b+" < "+cmax*0.75+" ("+cmax+")")
					step = 1;
				}
			*/

			case 2:
				// CROSS
				var mp = getMousePos();
				var dx = mp.x - (ball.x+EC*0.5);
				var dy = mp.y - (ball.y+EC*0.5);
				var a = Math.atan2(dy,dx) + 0.77;
				if(a<0)a+=6.28;
				var d = Math.floor((a / 6.28) * 4);
				var mc = getMc(cross, "d");
				if( mc != null ) mc.gotoAndStop(d+1);

				// PRESS
				if( click ){
					cross.visible = false;
					cd = d;
					var nd = DIR[cd];
					mx -= nd.x;
					my -= nd.y;
					coef = 1;
					step = 3;

				}

			case 3:
				coef += 0.66;
				var d = DIR[cd];
				while(coef>1){
					coef--;

					mx += d.x;
					my += d.y;

					var sq = grid[mx][my];
					if( sq == OUT ){
						setWin(true, 15);
						cast(ball).o.visible = false;
						step = 4;
						coef = 0;
						timeProof = true;
						break;
					}

					if( sq == SEA ){
						setWin(false, 15);
						cast(ball).o.visible = false;
						step = 4;
						coef = 0;
						break;
					}

					// PROCHAINE CASE
					var nx = mx + d.x;
					var ny = my + d.y;
					var nsq = grid[nx][ny];
					if( nsq == BLOCK ){
						initMove();
						coef = 0;
						break;
					}

				}

				ball.x = getX(mx+coef*d.x);
				ball.y = getY(my+coef*d.y);

			case 4 :
				var mc:flash.display.MovieClip = cast(ball).b;
				mc.scaleX *= 0.85;
				mc.scaleY = mc.scaleX;
				mc.y += 0.35;
				if(mc.scaleX < 0.1 ){
					mc.parent.removeChild(mc);
					step = 5;
				}

		}


	}

	function initMove(){
		step = 2;
		cross.visible = true;
		cross.x = getX(mx);
		cross.y = getY(my);
	}


	// CHECK BEST PATH
	function bestPath(){
		var best = 100;
		for(d in 0...4 ){
			best =  Std.int( Math.min( best, go(mx,my,d,2,[]) ));
		}
		return best;
	}

	function go(x:Int,y:Int,di:Int,result:Int,pl:Array<{x:Int,y:Int,r:Int}>):Null<Int>{

		var d = DIR[di];
		var n = 0;
		while(true){
			x += d.x;
			y += d.y;
			var sq = grid[x][y];
			switch(sq){
				case BLOCK:
					if(n==0)return 999;
					result++;
					//
					var nx = x-d.x;
					var ny = y-d.y;
					for( p in pl){
						if( p.x == nx && p.y == ny && result>= p.r){
							return 999;
						}
					}
					pl.push({x:nx,y:ny,r:result});
					//

					var dir = new Array();
					dir.push( (di+1)%4 );
					dir.push( (di+3)%4 );
					var bw = 999;

					for( ndi in dir ){
							bw = Std.int(Math.min( bw, go( nx, ny, ndi, result, pl) ));
					}

					return bw;

				case SEA:
					return 999;

				case OUT:
					return result;


			}
			n++;

		}

		return null;

		/*

		*/


	}




	// TOOLS
	function getX(gx:Float){
		return CX + gx*EC;
	}

	function getY(gy:Float){
		return CY + gy*EC;
	}

	function shuffle(a:Array<Dynamic>):Dynamic{
		var b = [];
		while(a.length>0){
			var index = Std.random(a.length);
			b.push(a[index]);
			a.splice(index,1);
		}
		return b;
		//for( el in b )a.push(el);
	}

//{
}















