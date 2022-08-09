class GemTurn extends Game{//}

	// CONSTANTES
	var xMax:Int;
	var yMax:Int;
	var dir:Array<{x:Int,y:Int}>;

	// VARIABLES
	var ray:Int;
	var max:Int;

	var grid:Array<Array<flash.display.MovieClip>>;
	var center:{x:Int,y:Int};
	var tList:Array<flash.display.MovieClip>;
	var gList:Array<flash.display.MovieClip>;
	var gemTurner:flash.display.MovieClip;
	var cx:Float;

	// MOVIECLIPS


	override function init(dif:Float){
		gameTime = 500-dif*300;
		super.init(dif);
		dir = [
			{x:1,y:0},
			{x:0,y:1},
			{x:-1,y:1},
			{x:-1,y:0},
			{x:0,y:-1},
			{x:1,y:-1},

		];

		xMax = 7;
		yMax = 7;
		ray = 10;

		max = 9;//2 + Math.round(dif*8);
		attachElements();
		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("gemTurn_bg",0);

		var mc = dm.attach("gemturn_hex",0);
		mc.x = Cs.omcw*0.5 - 5;
		mc.y = Cs.omch*0.5;
		mc.scaleX = mc.scaleY = 1.3;
		mc.rotation = 30;

		grid  = new Array();
		gList  = new Array();
		for( x in 0...xMax ){
			grid[x] = new Array();
			for( y in 0...yMax ){
				var sum = Math.abs(x)+Math.abs(y);
				if( sum > 2 && sum < 10){
					var mc = dm.attach("mcGem",Game.DP_SPRITE);
					mc.x = getX( x, y );
					mc.y = getY( x, y );
					mc.scaleX = ray*0.022;
					mc.scaleY = ray*0.022;
					mc.gotoAndStop("1");
					initGem(mc,x,y);
					grid[x][y] = mc;
					gList.push(mc);
				}
			}
		}

		while(true){
			var list =  new Array();
			for( i in 0...gList.length ) list.push(i);
			for( i in 0...max ){
				var index = Std.random(list.length);
				var mc = gList[list[index]];
				list.splice(index,1);
				mc.gotoAndStop("2");
			}

			if(!checkWin())break;

			for( x in 0...xMax ){
				for( y in 0...yMax ) {
					var mc = grid[x][y];
					if(mc!=null)mc.gotoAndStop("1");
				}
			}
		}

	}

	function initGem(mc:flash.display.Sprite, x, y) {
		
		var but = getMc(mc, "but");
		if( but != null ) mc.removeChild(but);
		
		
		var but = new flash.display.MovieClip();
		cast(mc).but = but;
		but.graphics.beginFill(0xFF0000,0);
		but.graphics.drawCircle(0, 0, 50);
		var me = this;
		but.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, function(e) { me.select(x, y); } );
		mc.addChild(but);
		//trace(but.x);
		//mc.onPress = callback(select,x,y);
	}

	override function update(){
		switch(step){
			case 1:

			case 2:
				var x = getX(center.x,center.y);
				var y = getY(center.x,center.y);

				var tx = (getMousePos().x - x)/Cs.omcw;
				tx = Math.round(tx*10);
				cx = cx*0.5 + tx*0.5;

				for( i in 0...tList.length ){
					var a = ((i/tList.length)+((cx+0.5)/6))*6.28;
					var mc = tList[i];
					mc.x = x + Math.cos(a) * ray*2*1.1;
					mc.y = y + Math.sin(a) * ray*2*1.1;
				}

				if( !click ){
					for( i in 0...tList.length ){
						var mc = tList[i];
						var index = i+tx;
						if(index < 0 )index+=6;
						if(index > 5 )index-=6;
						var d = dir[Std.int(index)];
						var nx = center.x + d.x;
						var ny = center.y + d.y;
						if( !isIn(nx, ny) )continue;
						grid[nx][ny] = mc;
						mc.x = getX(nx,ny);
						mc.y = getY(nx,ny);
						initGem(mc,nx,ny);
					}
					if(checkWin()) {
			
						setWin(true,15);
					}
					if(win) for( mc in gList ) {
						//if( mc.currentFrame == 3 ) new mt.fx.Flash(mc);
						mc.removeChild( getMc(mc, "but"));
					}
					
					gemTurner.parent.removeChild(gemTurner);
					step = 1;
				}

		}
		//
		super.update();
	}

	function select(x:Int,y:Int){
		var list = new Array();
		for( d in dir ) {
			if( !isIn(x + d.x, y + d.y) ) return;
			var mc = grid[x+d.x][y+d.y];
			if(  mc == null )return;
			list.push(mc);
		}
		tList = list;
		center = {x:x,y:y};
		step = 2;
		gemTurner = dm.attach("mcGemTurner",Game.DP_SPRITE);
		gemTurner.x = getX(x,y);
		gemTurner.y = getY(x,y);
		gemTurner.scaleX = ray*4*0.011;
		gemTurner.scaleY = ray*4*0.011;
		dm.under(gemTurner);
		cx =0;
		//trace("good ");

	}

	function checkWin(){
		// CHERCHE UN ROUGE
		var flWillWin = false;
		for( x in 0...xMax ){
			for( y in 0...yMax ){
				var mc = grid[x][y];
				if( mc!=null && mc.currentFrame > 1 ){
					var n = getNeighbours(x,y,[mc]);
					if(  n == max )	flWillWin = true;
					if(flWillWin)mc.gotoAndStop("3");
				}
			}
		}
		return flWillWin;
	}

	function getNeighbours(x:Int,y:Int,list:Array<flash.display.MovieClip>):Int{
		var n = 0;
		for(d in dir ){
			if( !isIn(x + d.x, y + d.y) ) continue;
			
			var mc = grid[x + d.x][y + d.y];
			if(mc != null && mc.currentFrame > 1 ){
				var flAdd = true;
				for( g in list )if( g == mc )flAdd = false;
				if(flAdd){
					list.push(mc);
					n += getNeighbours(x+d.x,y+d.y,list);

				}
			}
		}


		return n+1;
	}
	function isIn(x, y) {
		return x >= 0 && x < xMax && y >= 0 && y < yMax ;
	}


	function getX(x,y){
		return 56 + x*ray*2;//(x*2+y%2)*ray*2
	}

	function getY(x,y){
		return 20 + (y*ray*2 + x*0.5*ray*2)*1.1;//(y+(x%2)*0.5)*ray + (x%2)*ray*0.5//(y*1.1)*ray
	}


//{
}











