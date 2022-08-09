class game.Taquin extends Game{//}
	
	// CONSTANTES
	var cx:float;
	var cy:float;
	var ec:float;
	var size:int;
	
	// VARIABLES
	var side:int;
	var sList:Array< { id:int, x:float, y:float, mc:Sprite } >;
	//var mList:Array< { id:int, x:float, y:float, mc:Sprite } >
	var free:{x:int,y:int}
	//var grid:Array<Array<MovieClip>>
	
	// MOVIECLIPS
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 600-dif*2;
		super.init();

		size = 200
		side = 3//+Math.round(dif*0.02)
		free={x:0,y:0}
		
		//mList = new Array();
		
		attachElements();
		shuffle()
		
	};
	
	function attachElements(){
		
		cx = (Cs.mcw-size)*0.5
		cy = (Cs.mch-size)*0.5
		
		// SLOTS
		sList = new Array();
		ec  = size/side
		var id = 0;
		var picFrame = Std.random(4)+1
		for( var x=0; x<side; x++ ){
			for( var y=0; y<side; y++ ){
				if( free.x != x || free.y != y ){
					var mc = newSprite("mcTaquinSlot");
					mc.x = cx + x*ec
					mc.y = cy + y*ec
					mc.skin._xscale = ec
					mc.skin._yscale = ec
					mc.init();
					var pic  = Std.attachMC( Std.cast(mc.skin).s ,"mcTaquinPicture",id)
					var c = (100/ec)
					//var sc = size
					pic.gotoAndStop(string(picFrame))
					pic._xscale = 100*c
					pic._yscale = 100*c
					pic._x = -x*ec*c;
					pic._y = -y*ec*c;
					var o = { mc:mc, x:x*1.0, y:y*1.0, id:id }
					sList.push(o)
					initSelect(mc,o)
				}
				id++;
			}		
		}
		
		
		// CADRE
		var c = dm.attach("mcTaquinCadre",Game.DP_SPRITE)
		c._x = cx
		c._y = cy
		c._xscale = size;
		c._yscale = size;
		
	}
	
	function shuffle(){
		var max = 2+(dif*0.3)
		for( var i=0; i<max; i++ ){
			var o = sList[Std.random(sList.length)]
			var d = Math.abs(free.x-o.x)+Math.abs(free.y-o.y)
			if( d == 1 ){
				swap(o)
			}else{
				i--;
			}
			
		}
		if( checkWin() ){
			shuffle();
			return;
		}
		
		for( var i=0; i<sList.length; i++ ){
			var o = sList[i];
			o.mc.x = cx + o.x*ec
			o.mc.y = cy + o.y*ec
		}
		
		
		/*
		var cross = [
			{x:0,y:1},
			{x:-1,y:0},
			{x:0,y:-1},
			{x:1,y:0}
		]
		for( var i=0; i<10+dif; i++ ){
			var d = cross[Std.random(cross.length)]
			var x = free.x+d.x
			var y = free.y+d.y
			if( x < side && x >= 0 && y < side && y >= 0 ){
				swap()
			}
			
		}
		*/
	}
		
	function initSelect(mc,o){
		var me = this;
		mc.skin.onPress = fun(){
			me.select(o)
			
		}
	}
		
	function update(){
		switch(step){
			case 1:
				for( var i=0; i<sList.length; i++ ){
					var o = sList[i]
					var pos = {
						x:cx + o.x*ec,
						y:cy + o.y*ec
					}
					o.mc.toward(pos,0.5,null)
					
				}
				break;
		}
		//
		super.update();
	}
	
	function select(o){
		if ( Math.abs(free.x-o.x)+Math.abs(free.y-o.y) == 1 ){
			swap(o)
			if(free.x == 0 && free.y == 0 && checkWin() )setWin(true);
		}	
			
		
	}

	function swap(o){
		var x = o.x
		var y = o.y
		o.x = free.x
		o.y = free.y
		free.x = x
		free.y = y	
	}
	
	function checkWin(){

		for( var i=0; i<sList.length; i++ ){
			var o = sList[i]
			if( o.id != Math.round(o.y + o.x*side) ){
				return false;
			}
		}
		return true;
	
	}
	
	
	
	
//{	
}

