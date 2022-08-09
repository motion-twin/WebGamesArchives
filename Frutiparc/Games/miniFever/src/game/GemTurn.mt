class game.GemTurn extends Game{//}
	
	// CONSTANTES
	var xMax:int
	var yMax:int	
	var dir:Array<{x:int,y:int}>
	
	// VARIABLES
	var ray:int;
	var max:int;
	
	var grid:Array<Array<MovieClip>>
	var center:{x:int,y:int};
	var tList:Array<MovieClip>
	var gList:Array<MovieClip>
	var gemTurner:MovieClip;
	
	var cx:float;
	
	// MOVIECLIPS
	
	
	function new(){
		dir = [
			
			{x:1,y:0}
			{x:0,y:1}
			{x:-1,y:1}
			{x:-1,y:0}
			{x:0,y:-1}
			{x:1,y:-1}

		]
		super();

		
	}

	function init(){
		gameTime = 400-dif*2;
		super.init();
		xMax = 7
		yMax = 7		
		ray = 10
		
		max = 2 + Math.round(dif*0.1)
		attachElements();
		
	};
	
	function attachElements(){

		grid  = new Array();
		gList  = new Array();
		for(var x=0; x<xMax; x++ ){
			grid[x] = new Array();
			for(var y=0; y<yMax; y++ ){
				var sum = Math.abs(x)+Math.abs(y)
				if( sum > 2 && sum < 10){
					var mc = dm.attach("mcGem",Game.DP_SPRITE)
					mc._x = getX( x, y );
					mc._y = getY( x, y );
					mc._xscale = ray*2
					mc._yscale = ray*2
					mc.gotoAndStop("1")
					initGem(mc,x,y)
					grid[x][y] = mc;
					gList.push(mc);
				}
			}
		}
		
		while(true){
			var list =  new Array();
			for(var i=0; i<gList.length; i++) list.push(i);
			for(var i=0; i<max; i++){
				var index = Std.random(list.length);
				var mc = gList[list[index]];
				list.splice(index,1);
				mc.gotoAndStop("2");
			}
			
			if(!checkWin())break;
			
			for(var x=0; x<xMax; x++ ){
				for(var y=0; y<yMax; y++ ){
					grid[x][y].gotoAndStop("1")
				}
			}
		}
		
	}

	function initGem(mc,x,y){
		var me = this;
		mc.onPress = fun(){
			me.select(x,y)
		}
	}
	
	function update(){
		switch(step){
			case 1:
				break;
			case 2:
				var x = getX(center.x,center.y)
				var y = getY(center.x,center.y)
				
				var tx = (this._xmouse - x)/Cs.mcw
				tx = Math.round(tx*10)//*6
				cx = cx*0.5 + tx*0.5
			
				for( var i=0; i<tList.length; i++ ){
					var a = ((i/tList.length)+((cx+0.5)/6))*6.28
					var mc = tList[i]
					mc._x = x + Math.cos(a) * ray*2*1.1
					mc._y = y + Math.sin(a) * ray*2*1.1
				}
						
				if( !base.flPress ){
					for(var i=0; i<tList.length; i++ ){
						var mc = tList[i]
						var index = i+tx
						if(index < 0 )index+=6;
						if(index > 5 )index-=6;
						var d = dir[int(index)]
						var nx = center.x + d.x
						var ny = center.y + d.y
						grid[nx][ny] = mc
						mc._x = getX(nx,ny)
						mc._y = getY(nx,ny)
						initGem(mc,nx,ny)
					}
					if(checkWin())setWin(true);
					gemTurner.removeMovieClip();
					step = 1
				}
				break;			
		}
		//
		super.update();
	}
	
	function select(x:int,y:int){
		var list = new Array();
		for(var i=0; i<dir.length; i++ ){
			var d = dir[i]
			var mc = grid[x+d.x][y+d.y]
			if(  mc == null )return;
			list.push(mc)
		}
		tList = list;
		center = {x:x,y:y};
		step = 2;
		gemTurner = dm.attach("mcGemTurner",Game.DP_SPRITE)
		gemTurner._x = getX(x,y)
		gemTurner._y = getY(x,y)
		gemTurner._xscale = ray*4*1.1
		gemTurner._yscale = ray*4*1.1
		dm.under(gemTurner)
		cx =0 
		//Log.trace("good ")
		
	}
	
	function checkWin(){
		//Log.clear();
		// CHERCHE UN ROUGE
		var flWillWin = false;
		Log.clear();
		for( var x=0; x<xMax; x++ ){
			for( var y=0; y<yMax; y++ ){
				var mc = grid[x][y]
				if(  mc._currentframe > 1 ){
					
					var n = getNeighbours(x,y,[mc])
					
					if(  n == max ){
						flWillWin = true;
					};
					if(flWillWin)mc.gotoAndStop("3");
				}
			}
		}
		
		return flWillWin;
	}
	
	function getNeighbours(x:int,y:int,list:Array<MovieClip>):int{
		var n = 0
		for( var i=0; i<dir.length; i++ ){
			var d = dir[i]
			var mc = grid[x+d.x][y+d.y]
			if(mc._currentframe > 1 ){
				var flAdd = true;
				for( var g=0; g<list.length; g++){
					if( list[g] == mc )flAdd = false;
				}
				if(flAdd){
					list.push(mc)
					n += getNeighbours(x+d.x,y+d.y,list);
					
				}
			}
		}
		
		
		return n+1
	}
	
	
	function getX(x,y){
		return 56 + x*ray*2//(x*2+y%2)*ray*2
	}
	
	function getY(x,y){
		return 20 + (y*ray*2 + x*0.5*ray*2)*1.1//(y+(x%2)*0.5)*ray + (x%2)*ray*0.5//(y*1.1)*ray
	}	
	
	
//{	
}











