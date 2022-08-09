class game.Nest extends Game{//}
	//			    
	
	
	// CONSTANTES

	
	// VARIABLES
	var timer:float;
	var pList:Array<{>sp.phys.Part, flNest:bool,flBird:bool}>;
	var bList:Array<{>sp.Phys, flFly:bool, tx:float}>;
	var pression:float;
	var mother:{ >MovieClip, hand:MovieClip, body:MovieClip }

	
	

	function new(){
		super();
	}

	function init(){
		gameTime = 650
		super.init();
		pression = 0
		pList = new Array();
		
		attachElements();
			

	};
	
	function attachElements(){
		
		// BIRD NEST
		var mc = dm.attach("mcBirdNest",7)
		mc._x  = 121
		mc._y  = 199
		
		// MOTHER
		mother = downcast(dm.attach("mcMotherBird",Game.DP_SPRITE))
		
		// CHILD
		var max = 1+(dif*0.05)
		var ec = Math.min(30,160/(max-1))
		if(max ==1 )ec = 0
		var mx  = 130 - ((max-1)*ec)*0.5
		bList = new Array();
		for( var i=0; i<max; i++ ){
			var sp = downcast(newPhys("mcBirdChild"))
			sp.x = mx+i*ec
			sp.y = 185
			sp.flPhys = false;
			sp.flFly = false;
			sp.init();
			bList.push(sp)
		}
		
		
	}
	
	function update(){
		switch(step){
			case 1:
				// ANGLE
				var coef  = _xmouse/Cs.mcw
				var a = (coef*2-1)*0.77
				var ca = Math.cos(a)
				var sa = Math.sin(a)
				mother.gotoAndStop(string(1+int(coef*50)))
				mother.body._rotation = a*0.2/0.0174
			
				// JET
				if(base.flPress)pression += 0.1*Timer.tmod;
				pression *= Math.pow(0.98,Timer.tmod)
			
				var p = downcast(newPart("mcPartBirdFood"))
				p.x = mother.hand._x + ca*50
				p.y = mother.hand._y + sa*50
				
				var pw = 2+Math.random()*0.2
			
				p.vitx = ca*pression*pw;
				p.vity = sa*pression*pw;
				p.weight = 0.2
				p.scale = 30+Math.random()*80
				p.flNest = true;
				p.flBird = true;				
				p.init();
				pList.push(p)
				
				// FEED
				for( var i=0; i<pList.length; i++ ){
					var food = pList[i]
					var flKill = food.y > 250

					if( food.flBird && food.y > 150 ){
						food.flBird = false
						for(var n=0; n<bList.length; n++ ){
							var bird = bList[n]
							if( !bird.flFly && Math.abs(bird.x-food.x) < 8 ){
								flKill = true;
								var frame = bird.skin._currentframe+1
								bird.skin.gotoAndStop(string(frame))
								if( frame == 41 ){
									bird.flFly = true;
									bird.tx = Cs.mm(0,bird.x+(Math.random()*2-1)*80,Cs.mcw)
									bird.vity = -0.5
									break;
								}
							}
							
						}
					}
					if( food.flNest && food.y > 200 ){
						food.flNest = false
						if( food.x>47 && food.x<217 ){
							flKill = true;
						}
					}
					
					if( flKill ){
						food.kill();
						pList.splice(i--,1)
					}
				}
				
				
				// BIRD FLY
				var flWin = true;
				for( var i=0; i<bList.length; i++ ){
					
					var bird = bList[i]
					if(bird.flFly){
						bird.vity *= 1.05
						var dx = bird.tx - bird.x
						var lim = 0.5
						bird.vitx += Cs.mm(-lim,dx*0.1,lim)*Timer.tmod
						bird.vitx *= Math.pow(0.95,Timer.tmod)
						bird.skin._rotation = bird.vitx*2
						if( bird.y < -40 ){
							bird.kill();
							bList.splice(i--,1);
						}
						
					}else{
						flWin = false;
					}
				}

				
				if(timer==null){
				
					if(flWin){
						timer = 24
						flTimeProof = true;
					}
				}else{
					timer-=Timer.tmod
					if(timer <0)setWin(true);
				}
				
				
				break;


		}
		
		super.update();
	}

	
//{	
}



