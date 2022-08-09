class game.Chain extends Game{//}
	
	// CONSTANTES
	

	// VARIABLES
	var chainLength:int;
	var size:int;
	var xMax:int;
	var yMax:int;
	var idMax:int;
	var xMargin:float;
	var yMargin:float;
	
	
	var rowList: Array<{mc:MovieClip,id:int}>
	var slotList:Array<Array<{mc:MovieClip,id:int}>>
	var cList:Array<{x:int,y:int}>
	
	// MOVIECLIPS
	var bar:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400-dif;
		super.init();
		chainLength = 8
		idMax = 5;
		
		size = 50-Math.round(dif*0.2)
		attachElements();
		
		cList = new Array();
		
	};
	
	function attachElements(){
		
		// TABLE
		slotList = new Array();
		xMax = Math.floor((Cs.mcw-8)/size)
		xMargin = Cs.mcw-(xMax*size)
		yMax = Math.floor((Cs.mch-(60+size))/size)
		yMargin = Cs.mch-((yMax+1)*size)
		for( var x=0; x<xMax; x++ ){
			slotList[x] = new Array();
			for( var y=0; y<yMax; y++ ){
				initTableSlot(x,y)
			}			
		}
		
		// ROW
		rowList = new Array();
		var dirList = [
				{ x:-1,	y:0 }
				{ x:0,	y:1 }
				{ x:1,	y:0 }
				{ x:0,	y:-1 }
		]
		var list = [{x:Std.random(xMax),y:Std.random(yMax)}]
		rowList.push( {id:slotList[list[0].x][list[0].y].id,mc:null} )
		var t = 0
		while( list.length < xMax ){
			var d = dirList[Std.random(dirList.length)]
			var last = list[list.length-1]
			
			var x = last.x + d.x
			var y = last.y + d.y
			
			var flIn = x>=0 && x<xMax && y>=0 && y<yMax
			for(var i=0; i<list.length; i++){
				if( x == list[i].x && y == list[i].y ){
					flIn = false;
					break;
				}
			}
			
			if(flIn){
				list.push({x:x,y:y})
				rowList.push( {id:slotList[x][y].id,mc:null} )
			}
			t++
			if(t>20){
				t=0
				while(list.length>1){
					list.pop();
					rowList.pop();
				}
			};
		}
		//Log.trace("t("+t+")")
		
		for( var x=0; x<rowList.length; x++ ){
			initRowSlot(x)
		}
		
		// BAR
		bar._y = size*0.25 + yMargin*0.33
		bar._yscale = size*0.5
		
		
		
	}
	
	function initTableSlot(x,y){
		var id = Std.random(idMax);
		var mc = dm.attach("mcChainSlot",Game.DP_SPRITE)
		mc._x = xMargin*0.5 + (x+0.5)*size
		mc._y = yMargin*0.66 + (y+1.5)*size
		mc._xscale = size
		mc._yscale = size
		mc.gotoAndStop(string(id+1))
		Std.cast(mc).bg.gotoAndStop("1")
		var me = this
		mc.onPress = fun(){
			me.press(x,y)
		}
		slotList[x][y] = {mc:mc,id:id};
	}

	function initRowSlot(x){
		var id = rowList[x].id;
		var mc = dm.attach("mcChainSlot",Game.DP_SPRITE)
		mc._x = xMargin*0.5 + (x+0.5)*size
		mc._y = yMargin*0.33 + 0.5*size
		mc._xscale = size
		mc._yscale = size
		mc.gotoAndStop(string(id+1))
		Std.cast(mc).bg.gotoAndStop("2")
		rowList[x].mc = mc;
	}
	
	
	function press(x,y){
		/*
		if( cList == undefined ){
			cList = new Array();
			return;
		}
		*/
		if( flWin ) return;
		if( cList.length == 0 ){
			select(x,y);
			return;
		}
				
		var last = cList[cList.length-1]
		var dx = last.x - x
		var dy = last.y - y
		var sum = Math.abs(dx)+Math.abs(dy)
		
		if( sum == 0 ){
			cancel(x,y)
		}else if( sum == 1){
			select(x,y)
		}else{
			deselect();
		}
	}
	
	
	function cancel(x,y){
		var mc = slotList[x][y].mc;
		Mc.setPColor(Std.cast(mc),0xFFFFFF,100)
		cList.pop();
	}
	
	function select(x,y){
		for( var i=0; i<cList.length; i++ ){
			var p = cList[i]
			if( p.x == x && p.y == y ){
				deselect();
				return;
			}
		}
		
		var matchId = rowList[cList.length].id
		var info  = slotList[x][y]
		if( info.id == matchId ){
			cList.push({x:x,y:y})
			Mc.setPColor(Std.cast(info.mc),0xFFFFFF,20)
			if( cList.length == rowList.length )setWin(true);
			
		}else{
			deselect();
		}
		
	}
	
	function deselect(){
		while( cList.length > 0 ){
			var p = cList.pop();
			var mc = slotList[p.x][p.y].mc
			Mc.setPColor(Std.cast(mc),0xFFFFFF,100)
		}
	}
	
	function checkRowVanish(){
		for( var i=0; i<rowList.length; i++ ){
			var trg = size
			if( i<cList.length )trg  = 0;
			var mc = rowList[i].mc
			var dif =  trg - mc._xscale 
			mc._xscale += dif*0.5*Timer.tmod
			mc._yscale = mc._xscale
		}
	}
	
	
	
	function update(){
		
		switch(step){
			case 1: // GAME
				checkRowVanish();
				break;
			case 2: // ANGLE

		}
		//
		super.update();
	}
	

//{	
}






















