class game.Trampoline extends Game{//}
	
	// CONSTANTES
	var th:int;
	var gh:int;
	var hRay:int;
	var tRay:int;
	// VARIABLES
	var flUp:bool;
	var flOut:bool;
	var flFaceSwap:bool;
	var wallLevel:int;
	
	// MOVIECLIPS
	var hero:sp.Phys;
	var trampo:Sprite;
	var filet:MovieClip;
	var wall:MovieClip;
	var ground:MovieClip;
	var mask:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 400;
		super.init();
		
		th = Cs.mch-40
		gh = Cs.mch-6
		hRay = 24
		tRay = 94
		wallLevel = ( 4-Math.round(dif*0.1) )*32
		flUp = false;
		flOut = false;
		flFaceSwap = true;
		attachElements();
	};
	
	function attachElements(){
		
		// WALL
		wall = dm.attach("mcTrampolineWall",Game.DP_BACKGROUND);
		wall._y = wallLevel;
		
		// GROUND
		ground = dm.attach("mcTrampolineGround",Game.DP_BACKGROUND);
				
		// HERO
		hero = newPhys("mcTrampoMan")
		hero.x = Cs.mcw*0.5
		hero.y = Cs.mch*0.5
		hero.vitr = 0;
		hero.weight = 0.5
		hero.skin._xscale = hRay*2
		hero.skin._yscale = hRay*2
		hero.skin.stop();
		hero.init();

		// FILET
		filet = dm.empty(Game.DP_SPRITE)
		
		// TRAMPOLINE
		trampo = newSprite("mcTrampoline")
		trampo.x = Cs.mcw*0.5
		trampo.y = th
		trampo.init();
		


	}

	function update(){
		super.update();
		switch(step){
			case 1:
				var y  = hero.y+hRay
				
				// CHECKWIN
				if( !flUp && y < wallLevel ){
					flUp = true;
					flFreezeResult = true
					hero.skin.gotoAndStop("6")
					
				}
				
				if( flUp && y > wallLevel ){
					flFreezeResult  = false
					flUp = false;
					setWin(true)
					mask = dm.attach("mcRedSquare",Game.DP_SPRITE)
					mask._xscale = Cs.mcw
					mask._yscale = Cs.mch
					mask._y = wallLevel - Cs.mch
					hero.skin.setMask(mask)
				}
				
			
				
				// REBOND
				if( flOut ){

					if( y > gh ){
						hero.y = gh-hRay
						hero.vity *= -0.5
						setWin(false)
						hero.skin.gotoAndStop("5")
					}
				}else{
					
					if( y > th ){
						
						if(  Math.abs(hero.x-trampo.x) > tRay-hRay ){
							flOut = true;
							dm.over(hero.skin)
						}
						var dy = th-y
						hero.vity += dy*0.1*Timer.tmod*(base.flPress?2:1)
						
						if(base.flPress){
							var dx = (_xmouse - hero.x)+(Math.random()*2-1)*5
							hero.vitx -= dx*0.005
							hero.vitr -= dx*0.05
						}
						
						if( flFaceSwap && Math.abs(dy)> hRay*1.5 ){
							flFaceSwap  = false;
							hero.skin.gotoAndStop(string(Std.random(3)+2))
						}
						
						
					}else{
						if(!flFaceSwap)flFaceSwap = true;
						
						hero.vitr -= hero.skin._rotation*0.002
						
					}
					
					if( !flUp && !flWin && Math.abs(hero.x-trampo.x) > tRay-hRay*2  ){
						hero.skin.gotoAndStop("7")
					}

					
				}
				
				

				// DRAW FILET
				filet.clear();
				if(!flOut && y>th-4){			
					
					filet.lineStyle(1,0x0000,20)
					filet.beginFill(0xCECE79,100)
					filet.moveTo( trampo.x-tRay, trampo.y )
					filet.lineTo( trampo.x+tRay, trampo.y )
					filet.curveTo( (trampo.x+tRay)*0.3+hero.x*0.7, y, hero.x, y )
					filet.curveTo( (trampo.x-tRay)*0.3+hero.x*0.7, y, trampo.x-tRay, trampo.y )
					filet.endFill()
				}			
				
				
		
				

				
				
				// MOVEMAP
				var c = 0.15
				var dy = ( Cs.mch*0.5 - hero.y ) - _y
				
				_y = Math.max(0,_y + dy*c*Timer.tmod)
				
					
				
				
			
				break;
		}
		//
	
	}
	
	
	
//{	
}









