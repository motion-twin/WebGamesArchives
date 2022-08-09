class game.Intruder extends Game{//}
	
	static var DIF = [
		[2,0],
		[3,0],
		[3,1],
		[4,0],
		[4,1],
		[4,2],
		[5,0],
		[5,1],
		[5,2]
	]
	
	// CONSTANTES

	// VARIABLES
	var flGoodMove:bool;
	var id:int;
	var timer:float;
	var pList:Array<MovieClip>;
	
	// MOVIECLIPS

	function new(){
		
		super();
	}

	function init(){
		gameTime = 300
		super.init();
		attachElements();
	};
	
	function attachElements(){
		
		var list = new Array();
		for( var i=0; i<4; i++ )list[i] = Std.random(3);
		
		var index = Math.floor((dif/101)*DIF.length)
		var info = DIF[index]
		var size = Cs.mcw/info[0]
		
		var cList = new Array();
		for( var i=0; i<list.length; i++ )cList[i]=true;
		
		var max = Math.round(dif/100)*(cList.length-1)
		for( var i=0; i<max; i++){
			
			do{
				index = Std.random(cList.length)
			}while(!cList[index])
				
			cList[index] = false;
		}
		
		
		id = Std.random( int(Math.pow(info[0],2)) )
		pList = new Array();
		for( var x=0; x<info[0]; x++ ){
			for( var y=0; y<info[0]; y++ ){
				var mc = dm.attach("mcIntruder",Game.DP_SPRITE)
				mc._x = x*size;
				mc._y = y*size;
				mc._xscale = size;
				mc._yscale = size;
				mc.gotoAndStop(string(info[1]+1))
				for( var i=0; i<list.length; i++){
					var el = Std.getVar( mc, "$d"+i )
					var frame = list[i]
					if( pList.length == id && cList[i] ){
						var base = frame;
						while(frame == base)frame = Std.random(3);
					}
					el.gotoAndStop(string(frame+1))
				}
				mc.onPress = callback(this,select,pList.length);
				pList.push(mc)
				
				
			}
		}
		
	}
	
	function update(){

		switch(step){
			case 1: 
						
				break;
			case 2: 
				timer -= Timer.tmod;
				if(timer<=0){
					step = 3
					setWin(flGoodMove);
				}
				break;			
		}
		super.update();
	}
	
	
	function select(n){
		step = 2
		timer = 20
		flTimeProof = true;
		flGoodMove = ( n == id )
		
		for( var i=0; i<pList.length; i++ ){
			var mc = pList[i]
			if( i != id ){
				var p = newPart("mcIntruderExplosion")//
				p.x = mc._x
				p.y = mc._y
				p.scale = mc._xscale
				p.init();
				p.skin.gotoAndPlay(string(Std.random(3)+1))
				Mc.setPercentColor(mc,100,0xD194C6)//0xCDC07A)
				
				//mc.removeMovieClip();
				
			}
			mc.onPress = null;
			
		}
		
		
	}
	
//{	
}















