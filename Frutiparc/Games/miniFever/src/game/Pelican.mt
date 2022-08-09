class game.Pelican extends Game{//}
	
	
	
	// CONSTANTES
	static var SKY = 40
	static var SEA = 180
	static var PSPEED = 3 
	static var FALL = 0.4
	static var FRAY = 6
	static var BEC = 21
	static var BRAY = 14
	
	
	// VARIABLES
	var flAbove:bool
	var frame:float;
	var plouf:float;
	var freeze:float;
	var timer:float;
	var fList:Array<sp.Phys>;
	var gList:Array<sp.phys.Part>;
	var bList:Array<sp.phys.Part>;
	
	// MOVIECLIPS
	var pel:{>sp.Phys,sens:int}
	var sea:MovieClip;
	var head:MovieClip;
	
	var test:MovieClip
	
	function new(){
		super();
	}

	function init(){

		gameTime = 400
		super.init();
		flAbove = true;
		freeze = 0;
		plouf = 0;
		frame = 0;
		airFriction = 0.96
		gList = new Array();
		bList = new Array();
		attachElements();
	};
	
	function attachElements(){
		// SEA
		sea = dm.attach("mcPelicanSea",Game.DP_FRONT)
		sea._y = Cs.mch
		
		// FISH
		fList = new Array();
		var max = 4-Math.floor(dif*0.03)
		for( var i=0; i<max; i++ ){
			var sp = newPhys("mcPelicanFish")
			sp.flPhys = false;
			sp.x = FRAY + Math.random()*Cs.mcw-2*FRAY
			sp.y = SEA + 27 + (Math.random()*2-1)*12
			sp.vitx = 0.4 + dif*0.025 + Math.random()
			var sens = Std.random(2)*2-1
			sp.skin._xscale = 100*sens
			sp.vitx *= sens;
			sp.friction = 1
			sp.init();
			fList.push(sp)
		}
		
		// PELICAN
		pel = downcast(newPhys("mcPelican"));
		pel.x = 8;
		pel.y = SKY;
		pel.friction = 1;
		pel.sens = 1
		pel.vitx = pel.sens * PSPEED
		pel.flPhys = false;
		pel.init();
		
		head = downcast(pel.skin).head
		head.stop();
		
		
	}
	
	function update(){

		movePelican();
		moveFish();
		moveGoutte();
		moveBubble();
		
		
		switch(step){
			case 2:
				timer -=Timer.tmod;
				if(timer<0)setWin(true);
				break;
		}
		
		super.update();
	}

	function movePelican(){
	
		// CHECK SIDE
		var m = 0
		if( pel.x < m || pel.x > Cs.mcw-m ){
			pel.sens *= -1
			pel.x  = Cs.mm(m,pel.x,Cs.mcw-m)
			pel.skin._xscale = pel.sens*100
			pel.vitx = pel.sens * PSPEED
			
			if( pel.y > SKY*1.5 )freeze=50;
			
		}
		
		
		
		// PLOUF
		if( pel.y > SEA-20 ){
			
			if( pel.y > SEA ){
				if(flAbove){
					splash();
					flAbove = false;
				}
				if(Math.random()<0.8){
					var p = newPart("partPelicanBubble")
					p.x = pel.x+(Math.random()*2-1)*10;
					p.y = pel.y+(Math.random()*2-1)*10
					p.weight = -0.4+Math.random()*0.4
					p.scale = 30+Math.random()*70
					p.vitx = pel.vitx*0.8
					p.vity = pel.vity*0.8
					p.friction = 0.92
					p.init();
					bList.push(p)
				}
				
			}
			
			// FORCE
			pel.vity -= 0.1*Timer.tmod;
			
			// RETOUR
			if( !base.flPress || pel.y > SEA+14 ){
				freeze = 60
			}
			if( pel.vity > -5 && step == 1 ){
				var a = Math.atan2(pel.vity,pel.vitx)///0.0174
				var p = {
					x:pel.x + Math.cos(a)*BEC
					y:pel.y + Math.sin(a)*BEC
				}
				//Log.print("plonge!")
				for( var i=0; i<fList.length; i++ ){
					var fish = fList[i]
					//Log.print(fish.getDist(p))
					var dist = fish.getDist(p)
					if( dist < BRAY ){
						fish.kill();
						freeze = 2000
						step = 2
						timer = 18
						flTimeProof = true;
						head.nextFrame();
						break;
					}
					
					if( dist < 100 ){
						var dx = fish.x-p.x
						fish.x += (dx*0.06*Timer.tmod)*dif*0.01;
					}
					
					
				}
				/* DEBUG
				if(test==null)test = dm.attach("mcRoundTest",Game.DP_SPRITE);
				test._x = p.x
				test._y = p.y
				test._xscale = test._yscale = BRAY*2
			}else{
				
				test.removeMovieClip();
				test = null
				//*/
				
			}
		}else{
			flAbove = true;
		}
		
		

		
		
		//
		if( freeze>0 ) freeze -= Timer.tmod;
		
		// CONTROL
		if( base.flPress && freeze <= 0){
			var lim = 6
			pel.vity = Cs.mm(-lim,(pel.vity+FALL*Timer.tmod),lim)
		}else{
			var dy = SKY-pel.y
			var lim = 0.3//0.3
			pel.vity += Cs.mm(-lim,dy*0.01,lim)*Timer.tmod;
			
			pel.vity *= Math.pow(0.95,Timer.tmod)
			
		}
		
		// GFX
		pel.skin._rotation = (pel.vity/pel.vitx)*40
		frame = (frame+Math.max(0,-pel.vity*0.5 + 2))%25
		pel.skin.gotoAndStop(string(int(frame)+1))
		
		
		
		
	}
	
	function moveFish(){
		for( var i=0; i<fList.length; i++ ){
			var fish = fList[i]
			fish.x += fish.vitx*Timer.tmod;
			if( fish.x < FRAY || fish.x > Cs.mcw-FRAY ){
				fish.x = Cs.mm( FRAY, fish.x, Cs.mcw-FRAY );
				fish.vitx *= -1;
				fish.skin._xscale = 100*(fish.vitx/Math.abs(fish.vitx))
			}
		}
	}
	
	function splash(){
		// GOUTTE
		var max = Math.floor(pel.vity*2)
		for( var i=0; i<max; i++ ){
			var p = newPart("partPelicanWater")
			p.x = pel.x;
			p.y = SEA
			p.weight = 0.1+Math.random()*0.15
			p.scale = 70+Math.random()*60
			var a = -Math.random()*3.14
			p.vitx = Math.cos(a)*2
			p.vity = Math.sin(a)*5
			p.init();
			gList.push(p)
		}
		
		// PLOUF
		var p = newPart("partPelicanPlouf")
		p.flPhys = false;
		p.x = pel.x
		p.y = SEA
		p.scale = 40+(pel.vity*15)
		p.init();	
	}
	
	function moveGoutte(){
		for( var i=0; i<gList.length; i++ ){
			var p = gList[i]
			if(p.y>SEA){
				p.flPhys = false;
				p.y = SEA
				p.vity = 0
				p.skin.play();
				p.skin._xscale = (Std.random(2)*2-1)*100
				gList.splice(i--,1)
			}
		}
	}
	
	function moveBubble(){
		for( var i=0; i<bList.length; i++ ){
			var p = bList[i]
			if(p.y<SEA || p.y > Cs.mch ){
				p.kill();
				bList.splice(i--,1)
			}
		}
	}	
	
//{	
}















