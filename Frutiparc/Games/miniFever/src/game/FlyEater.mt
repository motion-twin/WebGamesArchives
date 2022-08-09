class game.FlyEater extends Game{//}
	
	// CONSTANTES
	static var SL = 208
	static var POWER_MAX = 14
	static var DODGE_RAY = 80
	
	
	
	// VARIABLES
	var flCharge:bool;
	var flFace:bool;
	var xdec:float;
	var ydec:float;
	var power:float;
	var timer:float;
	var dodge:float;
	
	
	
	// MOVIECLIPS
	var sea:MovieClip;
	var bar:MovieClip;
	var fish:sp.Phys;
	var fly:{>sp.Phys,dec:float, trg:{x:float,y:float}};
	
	
	function new(){
		super();
	}

	function init(){
		gameTime = 600
		super.init();
		airFriction  = 0.94
		xdec = 0;
		ydec = 0;
		flCharge = false;
		dodge = dif*0.0024 - 0.1
		attachElements();
	};
	
	function attachElements(){

		// SEA
		sea = dm.attach("mcFlyWater",Game.DP_SPRITE)
		sea._y = SL

		// FISH
		fish = newPhys("mcFlyFish")
		fish.x = 0
		fish.y = SL
		fish.skin.gotoAndStop("profil")
		fish.flPhys = false;
		fish.weight = 0.7
		fish.init();
		
		// FLY
		fly = downcast(newPhys("mcBlackFly"))
		fly.x = Math.random()*Cs.mcw;
		fly.y = Math.random()*Cs.mch;
		fly.dec = 0;
		fly.flPhys = false;
		fly.init();
		chooseTrg();
		
		// BAR
		bar = dm.attach("mcFlyBar",Game.DP_FRONT)
		bar._x = Cs.mcw*0.5
		bar._y = Cs.mch - 6
		bar._xscale = 0
		
		
		
		
	}
	
	function update(){
		super.update();
		
		xdec = (xdec+15)%628
		ydec = (xdec+1.5)%628
		sea._x = (sea._x+(Math.cos(xdec/100)+0.5)*Timer.tmod)%24
		sea._y = SL + Math.sin(ydec/100)*4
		
		moveFish();
		moveFly();
		switch(step){
			case 1: // CENTER
				
				break;
			case 2: // 
				timer-=Timer.tmod;
				if(timer<0)setWin(true)
				break;
			
		}
		
	}
	
	function moveFish(){
		
		var sens = fish.vitx/Math.abs(fish.vitx)
		var tb = 0
		
		if(!fish.flPhys){
			
			var frict = Math.pow(0.9,Timer.tmod)
			fish.vitx *= frict;
			fish.vity *= frict;
			var p = {
				x:Cs.mcw*0.5 + Math.cos(xdec/100)*5,
				y:sea._y+6
			}
			fish.towardSpeed(p,0.3,0.5)
			
			fish.skin._rotation *= 0.5

			if( !flFace ){
				fish.skin._xscale = sens*100
				if( Math.abs(fish.x-Cs.mcw*0.5) < 8 ){
					fish.skin.gotoAndPlay("profil")
					flFace = true;
				}
			}
			
			
			if(flCharge){
				power = Math.min( power+Timer.tmod*0.4, POWER_MAX )
				tb = (power/POWER_MAX)*100
				if(!base.flPress)jump();
			}else{
				if(base.flPress){
					flCharge = true;
					power = 0
				}
			}
			

			
			
		}else{
			// PLONGE
			if( fish.y > sea._y && fish.vity > 0 ){
				fish.flPhys = false;
				flFace = false;
				fish.skin.gotoAndStop("profil")
				// PART
				var max = int(6+fish.vity*1.5)
				for( var i=0; i<max; i++ ){
					var p = newPart("partBlackWater")
					var a = -Math.random()*3.14
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var pb = 1+fish.vity*0.1
					var pw = pb+Math.random()*pb
					p.x = fish.x + ca*7
					p.y = sea._y + 10
					p.vitx = ca*pw
					p.vity = sa*pw*3
					p.timerFadeType = 1
					p.weight = 0.3 + Math.random()*0.2
					p.scale = 100+Math.random()*150
					p.timer=  10+Math.random()*30
					p.init();
					
				}
			}
			
			// GNAC
			if( fly != null && fish.getDist(fly) < 18 ){
				fly.kill();
				fly = null;
				fish.skin.gotoAndPlay("gnac")
				step = 2
				timer = 6;
			}		
			
			//
			fish.skin._rotation = Math.atan2( fish.vity, fish.vitx )/0.0174 + (-sens+1)*0.5*180
			fish.skin._xscale = sens*100
		}
		
		var ds = tb - bar._xscale 
		bar._xscale += ds*0.5*Timer.tmod; 
		
		
		
		
		
		/*
		var dx = Cs.mcw*0.5 - fish.x;
		var lim = 2
		fish.vitx += Cs.mm(-lim,dx*0.1,lim)
		*/
		
		
	}
	
	function jump(){
		flCharge = false;
		fish.flPhys = true;
		
		fish.vitx = (_xmouse - fish.x)*0.13
		fish.vity = -power*1.7
		
		fish.skin.gotoAndPlay("jump")
		
	}
		
	function moveFly(){
	
		fly.towardSpeed( fly.trg, 0.2, 0.5 )
		
		var lim = 20
		var frame = 21-int(Cs.mm(-lim,fly.vitx,lim))
		fly.skin.gotoAndStop(string(frame))
		
		if( fly.getDist(fly.trg) < 16 || Math.random()/Timer.tmod < 0.02 ){
			chooseTrg();
		}
	
		// DODGE
		if(dodge < 0 && !fish.flPhys )return;
		var dist = fly.getDist(fish)
		if( dist < DODGE_RAY ){
			var d = DODGE_RAY-dist
			var a = fish.getAng(fly)
			fly.x += Math.cos(a)*dodge*d
			fly.y += Math.sin(a)*dodge*d
			
			
		}
		
		
		
	}
	
	function chooseTrg(){
		var m = 10
		fly.trg = {
			x:m+Math.random()*(Cs.mcw-2*m)
			y:m+Math.random()*(Cs.mch-(50+dif))
		}
	}
	

	


	
//{	
}

