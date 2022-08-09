class game.PlatJump extends Game{//}
	
	
	
	// CONSTANTES
	static var JUMP = 12
	static var GL = 236
	// VARIABLES
	var pi:int;
	var ni:int;
	var pList:Array<{>MovieClip,s0:MovieClip,s1:MovieClip,m:MovieClip, ray:float, speed:float}>
	
	// MOVIECLIPS
	var hero:sp.Phys;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 450
		super.init();
		airFriction = 0.96
		attachElements();
	};
	
	function attachElements(){
		
		// PLATEFORME
		var max = 3
		var ec = Cs.mch/(max+1)
		var r = Cs.getRandRep(max);
		pList = new Array();
		
		//var dc = 12-dif*0.08
		
		for( var i=0; i<max; i++ ){
			var mc = downcast(dm.attach("mcRayPlateforme",Game.DP_SPRITE));
			//mc.ray = Cs.mm( 12+dif*0.1, 12+24*r[i*2]*dc, 150 )
			mc.ray = 60-dif*0.4
			mc.speed = 1.5+(r[i]*3)
			//Log.trace(r[i*2])
			mc._x = mc.ray + Math.random()*(Cs.mcw-2*mc.ray)
			mc._y = (i+1)*ec
			
			
			mc.m._xscale = mc.ray*2
			mc.s0._x = -mc.ray;
			mc.s1._x = mc.ray;
			
			if(i==0){
				mc.gotoAndStop("2")
			}else{
				mc.gotoAndStop("1")
			}
			
			pList.push(mc)
		}
		
		// HERO
		hero = newPhys("mcPlatMonster")
		hero.x = Cs.mcw*0.5;
		hero.y = GL
		hero.flPhys = false;
		hero.weight = 0.5
		hero.init();
		
		
	}
	
	function update(){
		
	
		movePlats();
		if(pi!=null)hero.x += pList[pi].speed*Timer.tmod;
		
		switch(step){
			case 1:
				if(base.flPress){
					hero.skin.gotoAndPlay("prepare")
					step = 2
				}
				break;
			case 2:
				if(!base.flPress){
					pi = null
					hero.flPhys = true;
					hero.vity = -JUMP
					hero.skin.gotoAndPlay("jump")
					step = 3
				}
				break;
			case 3:
				if( hero.vity>0 ){
					ni = null
					for( var i=0; i<pList.length; i++){
						var mc = pList[i]
						if( hero.y < mc._y ){
							ni = i
							break;
						}
					}
					
					hero.skin.gotoAndPlay("jump_end")
					step = 4
				}
				break;
			case 4:
				if(ni!=null){
					var mc = pList[ni]
					if( hero.y > mc._y ){
						if(Math.abs(hero.x - mc._x)<mc.ray){
							pi = ni
							landing(mc._y)
							if( ni==0 ){
								step = 5
								hero.skin.gotoAndPlay("win");
								mc.gotoAndStop("1")
								setWin(true)
							}
						}else{
							ni++
							if(ni==pList.length)ni = null;
						}
					}
				}else{
					if( hero.y > GL ){
						landing(GL)
					}
				}
				
				
				break;
				
		}
		
		super.update();
	}
	
	function movePlats(){
		for( var i=0; i<pList.length; i++ ){
			var mc = pList[i]
			mc._x += mc.speed*Timer.tmod;
			if( mc._x < mc.ray || mc._x > Cs.mcw-mc.ray ){
				mc._x = Cs.mm(mc.ray,mc._x,Cs.mcw-mc.ray)
				mc.speed*=-1;
			}
			
			
		}
		
		
	}
	
	function landing(y){
		hero.y = y
		hero.flPhys = false;
		hero.vity = 0;
		hero.skin.gotoAndPlay("land")
		step = 1	
	}
	

//{	
}

