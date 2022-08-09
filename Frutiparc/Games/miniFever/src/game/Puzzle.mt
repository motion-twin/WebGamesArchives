class game.Puzzle extends Game{//}
	
	// CONSTANTES
	
	static var DIR = [{x:1,y:0},{x:0,y:1},{x:-1,y:0},{x:0,y:-1}]
	static var SIZE = 6
	static var EC = 12
	static var HEIGHT = 6
	
	// VARIABLES
	var pmax:int;
	var timer:float;
	var gList:Array<Array<{id:int,x:int,y:int}>>
	var lvl:Array<Array<{>MovieClip,id:int,dec:float,y:float,sleep:float}>>
	var piece:{>MovieClip,dm:DepthManager,id:int,dx:int,dy:int}
	
	var anim:Array<{>MovieClip,id:int,dec:float,y:float,sleep:float}>
	// MOVIECLIPS


	function new(){
		super();
	}

	function init(){
		gameTime = 600-dif*0.16
		super.init();
		pmax = 2+int(dif*0.04)
		lvl = new Array()
		for( var x=0; x<20; x++ ){
			lvl[x]=new Array();
		}
		genLevel()
		attachElements();
	};
	
	function genLevel(){
	
		// PREPARE LA GRID
		var free = new Array();
		var grid = new Array();
		for( var x=0; x<SIZE; x++ ){
			grid[x] = new Array();
			for( var y=0; y<SIZE; y++ ){
				var e = {id:null,x:x,y:y}
				grid[x][y] = e
				free.push(e)
			}
		}
		
		// POSE MAX SOUCHES
		gList = new Array();
		for( var i=0; i<pmax; i++ ){
			var e = takeRandomElement(free)
			e.id = i
			gList[i] = [e]
		}
		
		
		// ETEND LES SOUCHES
		while( free.length>0 ){
			for( var i=0; i<pmax; i++ ){
				
				// CREE UNE LISTE DES PIECES ADJACENTES
				var list = new Array();
				for( var n=0; n<free.length; n++ ){
					var e = free[n]
					for( var m=0; m<DIR.length; m++) {
						var d = DIR[m]
						var eo = grid[e.x+d.x][e.y+d.y]
						if( eo.id == i ){
							list.push(e)
							break;
						}
					}	
				}
				
				// SELECTION D'UN DES ELEMENTS
				if( list.length>0 ){
					var e = list[Std.random(list.length-1)];
					e.id = i;
					free.remove(e);
					gList[i].push(e);
				}
			}
		}
		
		/*
		// DEBUG 
		for( var i=0; i<pmax; i++ ){
			Log.trace("---- "+i+" ----")
			var list = gList[i]
			for( var n=0; n<list.length; n++ ){
				var e = list[i]
				Log.trace(" - ("+e.x+","+e.y+")")
			}
		}
		*/
		
		
	}
	
	function takeRandomElement(list){
		var index = Std.random(list.length)
		var e = list[index]
		list.splice(index,1)
		return e;
	}
	
	function attachElements(){
		for( var i=0; i<pmax; i++ ){
			var list = gList[i]
			
			var x = null
			var y = null
			
			while(true){
				var r = 1
				x = r + Std.random( 20-2*r )
				y = r + Std.random( 20-2*r )
				if(fit(i,x,y))break;
			}
			draw(i,x,y)
		}

	}
	
	function fit(i,x,y){
		var list = gList[i]
		for( var n=0; n<list.length; n++ ){
			var e = list[n]
			var nx = e.x+x
			var ny = e.y+y	
			if( lvl[nx][ny] != null || !isIn(nx,ny) ){
				//Log.trace("fail!")
				return false;
			}
		}
		return true;
	}
	
	function isIn(x,y){
		var m = 1
		return x > m && x<20-m && y > m && y<20-m; 
	}
	
	function draw(i,dx,dy){
		var list = gList[i]
		for( var n=0; n<list.length; n++ ){
			var e = list[n];
			var nx = e.x+dx;
			var ny = e.y+dy;		
			
			var mc = downcast(dm.attach("mcPuzzlePiece",Game.DP_SPRITE2))
			mc.gotoAndStop(string(i+1))
			mc._x = nx*EC;
			mc._y = ny*EC;
			lvl[nx][ny] = mc;
			mc.id = i;
			mc.onPress = callback(this,take,i,dx,dy)

		}
		
		for( var x=0; x<20; x++ ){
			for( var y=0; y<20; y++ ){
				var mc = lvl[x][y]
				if(mc!=null)dm.over(mc);
			}
		}
	}
	
	function take(num,dx,dy){
		if( step !=1 )return;
		
		// SUMMON
		piece = summonPiece(num)
		piece._x += (piece.dx+dx)*EC
		piece._y += (piece.dy+dy)*EC
		
		// NETTOIE
		for( var x=0; x<20; x++ ){
			for( var y=0; y<20; y++ ){
				var mc = lvl[x][y]
				if(mc.id==num){
					mc.removeMovieClip();
					lvl[x][y] = null;
				}
			}
		}
		
		//
		step = 2
		
	}
	
	function summonPiece(num){
			var list = gList[num]
			var p = downcast(dm.empty(Game.DP_SPRITE));
			p.dm = new DepthManager(p);
			p.id = num;
			
			// DETERMINE LES POS MIN ET MAX
			var b = {
				xMin:99
				yMin:99
				xMax:-99
				yMax:-99
			}
			for( var n=0; n<list.length; n++ ){
				var e = list[n]
				b.xMin = Math.min(b.xMin,e.x)
				b.yMin = Math.min(b.yMin,e.y)
				b.xMax = Math.max(b.xMax,e.x)
				b.yMax = Math.max(b.yMax,e.y)				
			}
			
			p.dx = int((b.xMin+b.xMax)*0.5)
			p.dy = int((b.yMin+b.yMax)*0.5)
			
			// ORDONNE LA LISTE
			var f = fun(a,b){
				if(a.y>b.y)return 1;
				if(a.y<b.y)return -1;
				return 0
			}
			list.sort(f)
			
			// CREE LES PETITS CARRES
			for( var n=0; n<list.length; n++ ){
				var e = list[n]
				var mc = p.dm.attach("mcPuzzlePiece",1)
				mc.gotoAndStop(string(num+1))
				mc._x = (e.x-p.dx)*EC;
				mc._y = (e.y-p.dy)*EC;
			}
			
			return p;
			
	}
	

	
	function update(){
		
		switch(step){
			case 1: // CHOIX
				
				break;
			case 2: // PIECE FLY
				movePiece();
				if(!base.flPress)step = 3;
				break;
			case 3:	
				movePiece();
				if(base.flPress)drop();
				break;
			case 4:
				for( var i=0; i<anim.length; i++ ){
					var mc = anim[i]
					if(mc.sleep>0){
						mc.sleep -= Timer.tmod
					}else{
						mc.dec = (mc.dec +30)%628
						mc._y = mc.y + (Math.cos(mc.dec/100)-1)*3
					}
				}
				timer-=Timer.tmod;
				if(timer<0)setWin(true);
				break;
			
		}
		
		super.update();
	}
	
	function movePiece(){
		var dx = (_xmouse - piece._x)-EC*0.5		
		var dy = (_ymouse - piece._y)-EC*0.5
		var c = 0.15
		var lim = 8
		piece._x += Cs.mm(-lim,dx*c,lim)*Timer.tmod;
		piece._y += Cs.mm(-lim,dy*c,lim)*Timer.tmod;
					
	}
	
	function drop(){
		var dx = Math.round((_xmouse/EC)-0.5)-piece.dx
		var dy = Math.round((_ymouse/EC)-0.5)-piece.dy
		
		var dir = DIR.duplicate();
		dir.unshift({x:0,y:0})
		
		for( var i=0; i<dir.length; i++){
			var d = dir[i]
			var x = dx+d.x;
			var y = dy+d.y;
			
			if( fit(piece.id,x,y) ){
				draw(piece.id,x,y)
				piece.removeMovieClip()
				step = 1
				checkWin();
				return;
			}
		}
	}
	
	function checkWin(){
		anim = new Array();
		for( var x=7; x<13; x++ ){
			for( var y=7; y<13; y++ ){
				var mc = lvl[x][y]
				if(mc==null)return;
				mc.dec = 0
				mc.y = mc._y
				mc.sleep = ((x+y)-14)*1.5
				anim.push(mc)
			}
		}
		
		flTimeProof = true;
		timer = 30;
		step = 4;
		

	}
	

	
//{	
}


















