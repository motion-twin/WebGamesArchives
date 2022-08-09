class game.Lander extends Game{//}

	// CONSTANTE
	
	// VARIABLES
	var flWasUp:bool;
	var shipRay:float
	var platRay:float
	var angle:float
	var power:float;
	
	// MOVIECLIPS
	var ship:sp.Phys
	var plat:MovieClip;
	

	function new(){
		super();
	}

	function init(){
		gameTime = 200;
		super.init();
		Log.setColor(0xFFFFFF)
		attachElements();
		angle = -1.57
		//PARAMS
		power = 0.25//-dif/500
	};
		
	function attachElements(){
		// SHIP
		shipRay = 11
		ship = newPhys("mcLanderShip");
		ship.x = Cs.mcw*0.5;
		ship.y = Cs.mch*0.5
		ship.weight = 0.04
		ship.skin.stop();
		ship.init();
		
		// PLATEFORME
		platRay = (110-dif)*0.5
		plat = Std.cast( dm.attach( "mcPlateforme", Game.DP_SPRITE) )
		var mc = downcast(plat)
		var r = (platRay+10)
		plat._x = r+Std.random(Math.round(Cs.mcw-r*2));
		plat._y = Cs.mch-15
		r = platRay-6
		mc.s1._x = -r
		mc.s2._x = r
		mc.b._x = -r
		mc.b._xscale = r*2
		
	}
	
	function update(){
		switch(step){
			case 1:
				// ANGLE
				var ta = ((this._xmouse/Cs.mcw)*2-1)*1.2 - 1.57
				var da =  ta - angle
				//var ag = 0.1-(dif/2000)
				angle += da*0.1*Timer.tmod
				ship.skin._rotation = angle/0.0175
			
				// THRUST
				if(base.flPress){
					ship.vitx += Math.cos(angle)*power
					ship.vity += Math.sin(angle)*power
				}
				ship.skin.gotoAndStop( base.flPress?"2":"1" )

				
				//
				var flUp = ship.y+shipRay < plat._y
				var flIn = Math.abs(ship.x-plat._x)< platRay
				
				if( !flUp ){
					if( flIn ){
						checkLanding();
					}
					
					if ( ship.y+shipRay > Cs.mcw-6 ){
						explode();
					}
				}
				
				flWasUp = flUp
				break;
		}
		//
		super.update();
	}
	
	function checkLanding(){
		var da = -1.57-angle
		if( Math.abs(ship.vitx)<1 && Math.abs(ship.vity)<1 && da<0.1 && flWasUp ){
			ship.flPhys = false;
			ship.vitx = 0;
			ship.vity = 0;
			ship.skin.gotoAndStop("1")
			ship.skin._rotation = -90
			setWin(true)
			step = 2
		}else{
			/* CHECK
			if( Math.abs(ship.vitx)>0.5 )Log.trace("vitesse lateral trops importante");
			if( Math.abs(ship.vity)>0.5 )Log.trace("vitesse horizontale trops importante");
			if( da>0.1 )Log.trace("angle trops important");
			if( flWasUp )Log.trace("collision laterale");
			//*/
			explode();
		}
		
	}
	
	function explode(){
		for( var i=0; i<10; i++ ){
			var mc = newPart("mcPartStrombo")
			var a = Math.random()*6.28
			var speed = 0.5+Std.random(6)
			mc.x = ship.x
			mc.y = ship.y
			mc.vitx = Math.cos(a)*speed;
			mc.vity = Math.sin(a)*speed;
			mc.scale = 50+Std.random(50)
			mc.weight = 0.1
			mc.timer = 10+Std.random(10)
			mc.timerFadeType = 1;
			mc.init();
			mc.skin.gotoAndStop(string(i+1))
		}
		ship.kill();
		setWin(false)
		step = 2
	}
	
	
//{	
}




