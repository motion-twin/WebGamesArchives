class game.Flower extends Game{//}

	// VARIABLES
	var groundLevel:int;
	var grow:float;
	var timer:float;
	var speed:float;
	var size:float;
	var decal:float;
	var goutteList:Array<sp.Phys>

	// MOVIECLIPS
	var nuage:MovieClip;
	var flower:MovieClip;
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 250 - dif*1.5;
		super.init();
		
		speed = 8 + dif*0.2
		size = 70 - (dif*0.3) 
		decal = 0;
		grow = 0;
		groundLevel = Cs.mch-34;
		goutteList = new Array();
		
		attachElements();
		
	};
		
	function attachElements(){
		// NUAGE
		nuage = dm.attach( "mcNuage", Game.DP_SPRITE)
		nuage._x = Cs.mcw*0.5
		nuage._y = 30
		//nuage.stop();
		nuage._xscale = size;
		nuage._yscale = size;
		
		// FLOWER
		flower = dm.attach( "mcFlower", Game.DP_SPRITE)
		var m = 60
		flower._x = m+Std.random(Cs.mcw-2*m)
		flower._y = (groundLevel+Cs.mch)*0.5
		flower.stop();

	}
	
	function update(){
		switch(step){
			case 1:
				// NUAGE
				decal = (decal+speed*Timer.tmod)%628
				var m =  Cs.mcw*0.5
				nuage._x = m + Math.cos(decal/100)*(m-nuage._width*0.5)
				updateNuage();
			
				// GOUTTE
				moveGoutte();
			
				// CHECK LOOSE
				if( size == 0 && goutteList.length == 0 ){
					setWin(false)
				}

			
				break;
		}
		//
		super.update();
	}
	
	function click(){
		if(size>0){
			size = Math.max( 0, size-10 )
			var mc = newPhys("mcGoutte")//dm.attach( "mcGoutte", Game.DP_SPRITE)
			mc.x = nuage._x
			mc.y = nuage._y+20
			mc.weight = 0.5;
			mc.init()
			goutteList.push(mc)
		}
	}
	
	function updateNuage(){
		nuage._xscale = nuage._xscale*0.5 + size*0.5
		nuage._yscale = nuage._xscale
	}
	
	function incGrow(s){
		///Log.trace(s)
		grow = Math.min(grow+s,1)
		var frame = Math.floor(grow*(flower._totalframes-1))+1
		flower.gotoAndStop(string(frame))
		
		if( grow == 1 ) setWin(true);
		
		
	}

	function moveGoutte(){


		for( var i=0; i<goutteList.length; i++){
			var mc = goutteList[i];
			if( mc.y > groundLevel ){
				var d = Math.abs(mc.x-flower._x)
				var limit = 30
				if(d<limit){
					incGrow( (limit-d)*0.02 )
				}
				for( var n=0; n<10; n++ ){
					var g = newPart("mcPartGoutte")
					g.x = mc.x
					g.y = mc.y
					g.vitx = 6*(Math.random()*2-1);
					g.vity = -(2+Math.random()*6)
					g.scale = 40+Std.random(60);
					g.weight = 0.3;
					g.flPhys = true;
					g.timer = 10+Std.random(10);
					g.timerFadeType = 1;
					g.init();
				}
				
				mc.kill();
				goutteList.splice(i,1)
			}
			
		}

			
	}
	
	
//{	
}




