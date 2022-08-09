class game.Gobelet extends Game{//}

	// TODO
	
	// CONSTANTE
	
	// VARIABLES
	var flSoluce:bool;
	var swap:int;
	var pos:int;
	var gobMax:int;
	var gobSize:int;
	var timer:float;
	var speed:float;
	var decal:float;
	var gobList:Array< { mc:MovieClip, shade:MovieClip, t:float, x:float } >
	var swapList:Array< { list:Array<int>, x:float, d:float } >
	var upList:Array<MovieClip>
	
	// MOVIECLIPS
	var token:MovieClip;
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 220;
		super.init();
		timer = 20
		speed = 0.2+dif*0.003
		gobMax = 4 + Math.round(dif/50)
		gobSize = 30
		flSoluce = false;
		pos = Std.random(gobMax)
		attachElements();
	};
		
	function attachElements(){
		

		var base = Cs.mch-30
		
		var ec = (Cs.mcw - gobMax*gobSize)/(gobMax+1)
		
		gobList = new Array();
		for( var i=0; i<gobMax; i++ ){
			var x = ec+gobSize*0.5+i*(ec+gobSize)
			// SHADE
			var shade  = Std.cast( dm.attach( "mcGobShadow", Game.DP_SPRITE) )
			shade._xscale = gobSize
			shade._yscale = gobSize
			shade._x = x
			shade._y = base

			// TOKEN
			if( pos == i ){
				token = Std.cast( dm.attach( "mcGobToken", Game.DP_SPRITE) )
				token._x = x
				token._y = base
				token._xscale = gobSize
				token._yscale = gobSize
			}
			
			// MC
			var mc  = Std.cast( dm.attach( "mcGobelet", Game.DP_SPRITE) )
			mc._xscale = gobSize
			mc._yscale = gobSize
			mc._x = x
			mc._y = Cs.mch*0.5
			gobList.push( { mc:mc, t:4*i, shade:shade, x:x } )
		}
	}
	
	function update(){
		switch(step){
			case 1:
				if( timer<0 ){
					step = 2
				}else{
					timer -= Timer.tmod
				}
				break;
			case 2:
				var base = Cs.mch-30
				var flNext = true;
				for( var i=0; i<gobList.length; i++ ){
					var gob = gobList[i];
					if( gob.t < 0 ){
						var mc = gob.mc
						var d = base - mc._y
						mc._y += Math.min(d*0.2,10)*Timer.tmod
						if( Math.abs(d) < 0.5 ){
							mc._y = base
						}else{
							flNext = false;
						}
					}else{
						gob.t -= Timer.tmod
						flNext = false;
					}
				}
				if(flNext){
					swap = 4+Math.round(dif/10)
					for( var i=0; i<gobList.length; i++ )gobList[i].shade.removeMovieClip();
					token.removeMovieClip();
					launchSwap();
					
				}
				break;
			case 3:
				decal = Math.min( decal + speed*Timer.tmod, 3.14 )
				
				var base = Cs.mch-30
				for(var i=0; i<swapList.length; i++){
					var s = swapList[i]
					
					for( var g=0; g<2,; g++){
						var n = s.list[g];
						var mc = gobList[n].mc
						var sens = (g*2-1)
						mc._x = s.x + Math.cos(decal)*s.d*sens
						mc._y = base + Math.sin(decal*sens)*(4+Math.abs(s.d)*0.25)
						//Log.print(n)
						//Log.print(mc)
					}
				}
				
				if(decal==3.14)launchSwap();
				break;
			case 4:
				for( var i=0; i<upList.length; i++ ){
					var mc = upList[i]
					var d = Cs.mch*0.5 - mc._y
					mc._y += Math.min(d*0.2,10)*Timer.tmod
				}
				
				if(!flWin && endTimer<16 && upList.length<2 && !flSoluce ){
					select(pos)
					flSoluce = true;
				}
				
				break;
				
			case 10:
				break;
		}
		//
		super.update();
	}
	
	function initSelectStep(){
		step = 4;
		upList = new Array();
		for( var i=0; i<gobList.length; i++ ){
			var me = this;
			var f = fun(mc,id){
				mc.onPress = fun(){
					me.select(id)
				}
			}
			f(gobList[i].mc,i);
		}
		//select(0)
		
	}
	
	function select(id){
		var mc = gobList[id].mc

		// SHADE
		var shade  = Std.cast( dm.attach( "mcGobShadow", Game.DP_SPRITE) )
		shade._xscale = gobSize
		shade._yscale = gobSize
		shade._x = mc._x
		shade._y = mc._y

		
		// TOKEN
		if(id==pos){
			genToken(mc._x,mc._y);
			setWin(true)
		}else{
			setWin(false)
		}
		
		//
		dm.over(mc)	
		upList.push(mc)
		
		// CLEAN
		for( var i=0; i<gobList.length; i++ ){
			 gobList[i].mc.onPress = null
		}
		
	}
	
	function genToken(x,y){
		token = Std.cast( dm.attach( "mcGobToken", Game.DP_SPRITE) )
		token._x = x
		token._y = y
		token._xscale = gobSize
		token._yscale = gobSize		
	}
		
	function launchSwap(){

		swap--;
		if( swap == 0 ){
			initSelectStep();
			return;
		}

		step = 3;
		decal =0
		swapList = new Array();
		var max = 1
		if( Std.random(Math.round(dif)) > 20 ){
			max++;
		}
		var list = new Array()
		for(var i=0; i<gobList.length; i++ )list.push(i);
		
		for( var i=0; i<max; i++ ){
			var p:Array<int> = new Array();
			for(var g=0; g<2; g++){
				var index = Std.random(list.length);
				var n = list[index];
				list.splice(index,1);
				p.push(n)
			}
			var gob0 = gobList[p[0]]
			var gob1 = gobList[p[1]]
			
			var d = (gob0.x - gob1.x)*0.5
			var x = (gob0.x + gob1.x)*0.5
			//Log.trace(d)
			
			swapList.push( {list:p,x:x,d:d} )
			
			
			dm.over(gob0.mc)
			dm.under(gob1.mc)
			
			// OBJ SWAP
			var trans = gob0.mc
			gob0.mc = gob1.mc
			gob1.mc = trans

			if(pos == p[0] ){
				pos = p[1];
			}else	if(pos == p[1] ){
				pos = p[0];
			}
			
			//Std.cast(gob0.mc).txt = p[0]
			//Std.cast(gob1.mc).txt = p[1]
		}
		

		
		
	}
	

	
//{	
}




