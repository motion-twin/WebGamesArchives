class game.Source extends Game{//}
	
	// CONSTANTES
	static var HERO_RAY = 	8;
	
	// VARIABLES
	var oList:Array<{>sp.Phys,ray:float}>
	var speed:float;
	var timer:float;
	var freq:int;
	
	// MOVIECLIPS
	var hero:sp.Phys;
	
	function new(){
		super();
		airFriction = 1
	}

	function init(){
		gameTime = 400
		super.init();
		
		oList = new Array();
		speed = 1
		freq = 16 - int(dif*0.1)
		timer = 0 
		
		attachElements();
	};
	
	function attachElements(){
		
		// HERO
		hero = newPhys("mcSourceHero")
		hero.x = Cs.mcw*0.5
		hero.y = Cs.mch
		hero.vity = -speed
		hero.flPhys = false;
		hero.init();
		
	}
	
	function update(){

		switch(step){
			case 1: 
				hero.vity = Math.max( hero.vity-0.1*Timer.tmod, -speed);
				if( hero.y < 0 ){
					setWin(true)
				}
				var dx = _xmouse - hero.x
				hero.x += dx*0.15*Timer.tmod;
				hero.vitx *= Math.pow(0.95,Timer.tmod)
				
				hero.skin._rotation = dx*0.6
				
				// HELICEE
				var h = downcast(hero.skin).h.h
				h._rotation += Math.max(10,-30*hero.vity)
				
				
				//
				timer -= Timer.tmod;
				if(timer<0){
					timer = freq
					genObstacle();
				}
				
				
				updateObstacle();
				
				break;
			
		}
		//
		super.update();
	}
	
	function genObstacle(){
		var sp = downcast( newPhys("mcSourceObstacle") )
		sp.ray = 5+Math.random()*(15+dif*0.1)
		do{
			sp.ray-=0.2
			sp.x = sp.ray + Math.random()*(Cs.mcw - 2*sp.ray)
		}while( isCol(sp) || ( hero.y < 40 && Math.abs(sp.x-hero.x) < 30 )  )
		sp.y = -sp.ray
		sp.vity = 1+Math.random()*3
		sp.flPhys= false;
		sp.init()
		sp.skin._xscale = sp.ray*2
		sp.skin._yscale = sp.ray*2
		sp.skin.gotoAndStop(string(1+Math.round(sp.ray/20)))
		oList.push(sp)
	}
	
	function updateObstacle(){
		for( var i=0; i<oList.length; i++ ){
			var sp = oList[i]
			var flDeath = sp.y>Cs.mch+sp.ray
			// CHECK COL
			for( var n=0; n<oList.length; n++ ){
				var spo = oList[n];
				if( sp != spo ){
					var dist = sp.getDist(spo)
					if( dist < sp.ray+spo.ray ){
						var d = (sp.ray+spo.ray-dist)*0.5
						var a = sp.getAng(spo)
						sp.x -= Math.cos(a)*d
						sp.y -= Math.sin(a)*d
						spo.x += Math.cos(a)*d
						spo.y += Math.sin(a)*d							
					}
				}
			}
			
			// HERO COL
			var dist = sp.getDist(hero)
			if( dist < sp.ray+HERO_RAY ){
				var d = 5
				var a = sp.getAng(hero)
				hero.vitx += Math.cos(a)*d
				hero.vity += Math.sin(a)*d	
	
				var p = newPart("mcCrossOnde")
				p.x = sp.x;
				p.y = sp.y;
				p.flPhys = false;
				p.scale = sp.skin._xscale*1.5;
				p.init();
				
				flDeath = true;
			}
			
			if( flDeath ){
				sp.kill();
				oList.splice(i--,1);
			}

		}
	}
	
	function checkCol(sp){

		
	}	
	
	function isCol(sp){
		for( var n=0; n<oList.length; n++ ){
			var spo = oList[n];
			if( sp != spo ){
				var dist = sp.getDist(spo)
				if( dist < sp.ray+spo.ray ){
					return true
				}
			}
		}
		return false
	}

//{	
}








