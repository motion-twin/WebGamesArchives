class game.Herb extends Game{//}
	
	// CONSTANTES

	
	// VARIABLES
	var goal:int;
	var sx:int;
	var sy:int;
	var xMax:int;
	var yMax:int;
	var startTimer:int;
	var grid:Array<Array<{t:int,sp:Sprite}>>
	
	// MOVIECLIPS
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 360-dif*2;
		super.init();
		
		xMax = 5
		yMax = 5
		
		goal = xMax*yMax - 6
		
		startTimer = 10;
		
		attachElements();
		initGround();
		
		
		
		
	};
	
	function attachElements(){
		
		// CASE
		
		var sx = 40
		var sy = 30
		
		var mx = (Cs.mcw-(xMax*sx))*0.5
		var my = (Cs.mch-(yMax*sy))*0.5
		
		grid = new Array();
		for(var x=0; x<xMax; x++ ){
			grid[x] = new Array();
			for(var y=0; y<yMax; y++ ){
				var info = {}
				var sp = newSprite("mcHerbCase")
				sp.x = mx + x*sx
				sp.y = my + y*sy
				sp.init();
				grid[x][y] = {t:0,sp:sp}
				initCase(x,y)
			}		
		}
		
	
	}
	
	function initGround(){
		sx = Std.random(xMax)	
		sy = Std.random(yMax)
		

		
		var goal = (xMax*yMax)-5
			
		var list = [{x:sx,y:sy}]
		var a = findWay(list,0)	

		for(var i=0; i<list.length; i++ ){
			var p = list[i]
			var info = grid[p.x][p.y]
			info.t = 1;
			//downcast(sp.skin).field.text = i
		}
				
		for(var x=0; x<xMax; x++ ){
			for(var y=0; y<yMax; y++ ){
				var info = grid[x][y]
				info.sp.skin.gotoAndStop(string(info.t+1))
			}
		}
		
		bloom(grid[sx][sy])

	}
	
	function initCase(x,y){
		var sp = grid[x][y].sp
		var me = this;
		sp.skin.onRollOver = fun(){
			me.select(x,y)
		}
		
	}
		
	function findWay( list:Array<{x:int,y:int}>,n:int):bool{
		
		var x = list[list.length-1].x
		var y = list[list.length-1].y
		//Log.trace("wp("+x+","+y+")")
		
		var dir = [
			{x:0,y:1},
			{x:1,y:0},
			{x:0,y:-1},
			{x:-1,y:0}
		]
		
		do{
			
			var index = Std.random(dir.length)
			//Log.trace("--->"+index)
			var d = dir[index]
			dir.splice(index,1)

			var nx = x+d.x
			var ny = y+d.y

			if( grid[nx][ny].t == 0 ){
				
				var flag = true;
				for(var i=0; i<list.length; i++){
					var o = list[i]
					if(o.x==nx && o.y==ny)flag = false;
				}
				
				if(flag){
					n++
					list.push({x:nx,y:ny})
					if(n==goal){
						//Log.trace("youhou !!! ")
						return true ;
					}
					if( !findWay(list,n) ){
						list.pop();
						n--
					}else{
						return true;
					}
					//if(n==goal)return true ;
				}
			}
			
			
		}while( dir.length > 0 )
		return false;
	}
		
	function update(){
		switch(step){
			case 1:
				if(startTimer>0)startTimer-=Timer.tmod;
				break;
		}
		//
		super.update();
	}
	
	function select(x,y){
		if( Math.abs(sx-x)+Math.abs(sy-y) == 1 && grid[x][y].t == 1 && startTimer<0 ){
			bloom(grid[x][y])
			sx = x
			sy = y
			goal--;
			if(goal==0){
				setWin(true);
			}else{
				var dir = [
					{x:0,y:1},
					{x:1,y:0},
					{x:0,y:-1},
					{x:-1,y:0}
				]				
				for(var i=0; i<dir.length; i++){
					var d = dir[i]
					if(grid[x+d.x][y+d.y].t == 1)return;
				}
				setWin(false)
			}
		}
	}
	
	function bloom(info){
		info.t = 2;
		info.sp.skin.gotoAndPlay("bloom");

		
	}

	
	
//{	
}











