class game.Plate extends Game{//}
	
	// CONSTANTES

	// VARIABLES
	var depthRun:int;
	var pRay:int;
	var sRay:float;
	
	var tache:Array<{mc:MovieClip,ray:float,life:float}>
	var op:{x:float,y:float};
	
	// MOVIECLIPS
	var plate:Sprite;
	var sponge:Sprite;

	function new(){
		super();
	}

	function init(){
		gameTime = 320;
		super.init();
	
		pRay = 50
		sRay = 30 - dif*0.15
		depthRun = 0;
		op={x:0,y:0}
		attachElements();
	};
		
	function attachElements(){
		
		// PLATE
		plate =  newSprite("mcPlate")
		plate.x = Cs.mcw*0.5
		plate.y = Cs.mch*1.5
		plate.skin._xscale = pRay*2
		plate.skin._yscale = pRay*2
		plate.init();

		// TACHES
		tache = new Array();
		var max = 6+dif*0.09
		for( var i=0; i<max; i++ ){
			var mc = Std.attachMC( plate.skin, "mcTache", i )
			var ray = 10+dif*0.1+Std.random(30);
			var d = Std.random(int(100-ray))
			var a = Std.random(628)/100
			mc._x = Math.cos(a)*d
			mc._y = Math.sin(a)*d
			mc._xscale = ray*2
			mc._yscale = ray*2
			mc._alpha = 100
			mc._rotation = Std.random(360)
			mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
			tache.push({mc:mc,ray:ray*1.0,life:ray*1.0})
		}
		
		
		// SPONGE
		sponge = newSprite("mcSponge")
		sponge.x = Cs.mcw*0.5
		sponge.y = Cs.mch*0.5
		sponge.skin._xscale = sRay*2
		sponge.skin._yscale = sRay*2
		sponge.init();
		
		// PART WATER
		for( var i=0; i<10; i++ ){
			var mc = Std.attachMC( plate.skin, "mcPartWaterFlow", 100+i )
			var d = Std.random(100)
			var a = Std.random(628)/100
			mc._x = Math.cos(a)*d
			mc._y = Math.sin(a)*d
			mc._xscale = 50+Math.random()*50
			mc._yscale = mc._xscale
			mc.gotoAndPlay(string(Std.random(10)+1))
		}		
		
		
		
	}
	
	function update(){
		super.update();
		switch(step){
			case 1:
				// PLATE
				plate.toward({x:Cs.mcw*0.5,y:Cs.mch*0.5},0.2,null)
			
				// MOVE SPONGE
				sponge.toward({x:_xmouse,y:_ymouse},0.5,null)
				var power = sponge.getDist(op)*0.1
				
				// MOUSSE
				var max = Math.round(power)
				var dx = sponge.x - plate.x;
				var dy = sponge.y - plate.y;
				for( var i=0; i<max; i++ ){
					
					
					var d = Std.random(int(sRay))
					var a = Std.random(628)/100
					var x = dx+Math.cos(a)*d
					var y = dy+Math.sin(a)*d
					if( Math.sqrt(x*x+y*y) < 100 ){
						depthRun++
						var mc = Std.attachMC( plate.skin, "mcMousse", 200+depthRun )
						mc._x = x
						mc._y = y
						mc._xscale = 100+(Math.random()*2-1)*50
						mc._yscale = mc._xscale
						mc._rotation = Std.random(360)
						mc.gotoAndPlay(string(Std.random(3)+1))
					}
					
					
				}
				
				
			
				// CLEAN TACHE
				var efCoef = 1
				for( var i=0; i<tache.length; i++ ){
					var o = tache[i]
					var dist = sponge.getDist({x:o.mc._x+plate.x,y:o.mc._y+plate.y})
					var c = 1-(dist/(sRay+o.ray))
					
					if( c > 0 ){
						o.life = Math.max( 0, o.life-c*power*efCoef )
						o.mc._alpha = (o.life/o.ray)*100
						if( o.life == 0 ){
							tache.splice(i,1)
							i--
						} 
						efCoef*=0.5
						
					}					
					
				}
			
				// CHECK WIN
				if( tache.length == 0 )setWin(true);
				
				// OLD POS
				op={x:sponge.x,y:sponge.y}
				break;
		}
		//
	
	}
	


	
	
//{	
}

