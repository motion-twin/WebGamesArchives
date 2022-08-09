import mt.bumdum9.Lib;
import Protocole;

class Chain extends Game{//}

	// VARIABLES
	var chainLength:Int;
	var size:Int;
	var xMax:Int;
	var yMax:Int;
	var idMax:Int;
	var xMargin:Float;
	var yMargin:Float;

	var rowList: Array<{mc:flash.display.MovieClip,id:Int}>;
	var slotList:Array<Array<{mc:flash.display.MovieClip,id:Int}>>;
	var cList:Array<{x:Int,y:Int}>;

	// MOVIECLIPS
	var bar:flash.display.MovieClip;

	override function init(dif:Float){
		gameTime = 400-dif;
		super.init(dif);
		chainLength = 8;
		idMax = 5;

		size = 50-Math.round(dif*20);
		if( size < 16 )size = 16;

		attachElements();

		cList = new Array();

		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("chain_bg",0);

		// TABLE
		slotList = new Array();
		xMax = Math.floor((Cs.omcw-8)/size);
		xMargin = Cs.omcw-(xMax*size);
		yMax = Math.floor((Cs.omch-(60+size))/size);
		yMargin = Cs.omch-((yMax+1)*size);
		for( x in 0...xMax ){
			slotList[x] = new Array();
			for( y in 0...yMax )initTableSlot(x,y);
		}

		// ROW
		rowList = new Array();
		var dirList = [
				{ x:-1,	y:0 },
				{ x:0,	y:1 },
				{ x:1,	y:0 },
				{ x:0,	y:-1 },
		];
		var list = [{x:Std.random(xMax),y:Std.random(yMax)}];
		rowList.push( {id:slotList[list[0].x][list[0].y].id,mc:null} );
		var t = 0;
		while( list.length < xMax ){
			var d = dirList[Std.random(dirList.length)];
			var last = list[list.length-1];

			var x = last.x + d.x;
			var y = last.y + d.y;

			var flIn = x>=0 && x<xMax && y>=0 && y<yMax;
			for(p in list){
				if( x == p.x && y == p.y ){
					flIn = false;
					break;
				}
			}

			if(flIn){
				list.push({x:x,y:y});
				rowList.push( {id:slotList[x][y].id,mc:null} );
			}
			t++;
			if(t>20){
				t=0;
				while(list.length>1){
					list.pop();
					rowList.pop();
				}
			};
		}


		for( x in 0...rowList.length )initRowSlot(x);

		// BAR
		//bar.y = size*0.25 + yMargin*0.33;
		//bar.scaleY = size*0.5;



	}

	function initTableSlot(x:Int,y:Int){
		var id = Std.random(idMax);
		var mc = dm.attach("mcChainSlot",Game.DP_SPRITE);
		mc.x = xMargin*0.5 + (x+0.5)*size;
		mc.y = yMargin*0.66 + (y+1.5)*size;
		mc.scaleX = size*0.01;
		mc.scaleY = size*0.01;
		mc.gotoAndStop(id+1);
		getMc(mc,"bg").gotoAndStop("1");
		var me = this;
		//mc.onPress = callback(press, x, y);
		mc.addEventListener(flash.events.MouseEvent.CLICK, function(e) { me.press(x, y); } );
		mc.mouseEnabled = true;
		mc.useHandCursor = true;
		slotList[x][y] = {mc:mc,id:id};
	}

	function initRowSlot(x){
		var id = rowList[x].id;
		var mc = dm.attach("mcChainSlot",Game.DP_SPRITE);
		mc.x = xMargin*0.5 + (x+0.5)*size;
		mc.y = yMargin*0.33 + 0.5*size;
		mc.scaleX = size*0.01;
		mc.scaleY = size*0.01;
		mc.gotoAndStop(id+1);
		getMc(mc,"bg").gotoAndStop("5");
		rowList[x].mc = mc;
	}


	function press(x,y){
		if( win ) return;
		if( cList.length == 0 ){
			select(x,y);
			return;
		}

		var last = cList[cList.length-1];
		var dx = last.x - x;
		var dy = last.y - y;
		var sum = Math.abs(dx)+Math.abs(dy);

		if( sum == 0 ){
			cancel(x,y);
		}else if( sum == 1){
			select(x,y);
		}else{
			deselect();
		}
	}


	function cancel(x,y){
		var mc = slotList[x][y].mc;
		Col.setPercentColor(mc,0,0xFFFFFF);
		cList.pop();
	}

	function select(x,y){
		for(p in cList ){

			if( p.x == x && p.y == y ){
				deselect();
				return;
			}
		}

		var matchId = rowList[cList.length].id;
		var info  = slotList[x][y];
		if( info.id == matchId ){
			cList.push({x:x,y:y});
			Col.setPercentColor(info.mc,0.8,0xFFFFFF);
			if( cList.length == rowList.length ) setWin(true,20);

		}else{
			deselect();
		}

	}

	function deselect(){
		while( cList.length > 0 ){
			var p = cList.pop();
			var mc = slotList[p.x][p.y].mc;
			Col.setPercentColor(mc,0,0xFFFFFF);
		}
	}

	function checkRowVanish(){
		for(  i  in 0...rowList.length ){
			var trg = size*0.01;
			if( i<cList.length )trg  = 0;
			var mc = rowList[i].mc;
			var dif =  trg - mc.scaleX;
			mc.scaleX += dif*0.5;
			mc.scaleY = mc.scaleX;
		}
	}



	override function update(){

		switch(step){
			case 1: // GAME
				checkRowVanish();
			case 2: // ANGLE
		}
		//
		glowLast();
		super.update();

	}



	var str:Null<Int>;
	function glowLast(){

		if( str == null )str = 0;
		str = (str+32)%628;
		// TODO
		var o = rowList[cList.length];
		var p = 0.5 + Math.cos(str * 0.01) * 0.5;
		if( o == null ) return;
		o.mc.filters = [];
		Filt.glow(o.mc,3,p*4,0xFFFFFF);
		Filt.glow(o.mc,20*p,1.5,0xFFFF00);

		dm.over(o.mc);



	}


//{
}






















