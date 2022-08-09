class game.Cliff extends Game{//}
	
	// CONSTANTES
	var jumpPoint:int;
	var cliffLevel:int;
	var heroDecal:int;
	var heroFrameMax:int;
	var jumpSize:float;
	
	// VARIABLES
	var flWasUp:bool;
	var holeWidth:float;
	//var px:float;
	var speed:float;
	var heroFrame:float;
	var vitx:float;
	var vity:float;
	var angle:float;
	var omp:{x:float,y:float}
	
	// MOVIECLIPS
	var hero:MovieClip;
	var cliff:MovieClip;
	var hole:MovieClip;
	var decor:MovieClip;
	var angleMeter:MovieClip;
	
	function new(){
		super();
	}

	function init(){
		gameTime = 260;
		super.init();

		jumpPoint = 1000;
		jumpSize = 60+dif*2;
		
		
		cliffLevel = Cs.mch - 50
		
		heroDecal = 40
		heroFrame = 0
		heroFrameMax = 36
		
		omp = {x:_xmouse,y:_ymouse}
		//px = 0;
		speed = 0;
		
		attachElements();
		
		
		
	};
	
	function attachElements(){

		// CLIFF
		cliff = dm.attach("mcCliffGround",Game.DP_SPRITE)
		cliff._x = 0
		cliff._y = cliffLevel

		// DECOR
		genDecor();
		
		// HERO
		/*
		hero = newPhys("mcCliffHero")
		hero.x = heroDecal;
		hero.y = cliffLevel;
		hero.flPhys = false;
		hero.skin.stop();
		hero.init();
		*/
		hero = Std.attachMC(decor,"mcCliffHero",500)
		hero.stop();
		hero._x = 0
		hero._y = 0
		
		
	}
	
	function update(){
		
		moveMap();
		switch(step){
			case 1: // RUN
				var p = {x:this._xmouse,y:this._ymouse}
				
				var dx = p.x - omp.x
				var dy = p.y - omp.y
				var dist = Math.sqrt(dx*dx+dy*dy);
				
				speed += dist*0.01
				speed *= Math.pow(0.96,Timer.tmod)
				
				//hero.x = heroDecal + speed*2
				//decor._x -= speed;
				
				hero._x += speed;
				
				// FRAME
				var dash = speed*0.3;
				heroFrame = ( heroFrame + dash )%heroFrameMax
				if( dash < 4 ){
					hero.gotoAndStop(string(Math.round(heroFrame+1)))				
				}else{	
					hero.gotoAndStop(string(40+Std.random(3)))
				}
				

				// SAUVE LA POS DE LA SOURIS
				omp = p;
				
				if( hero._x > jumpPoint ){
					hero._x = jumpPoint
					initJump( -0.2, speed );
				}
				
				if( base.flPress ){
					angle = 0
					step = 2
					angleMeter = dm.attach("mcAngleQuart",Game.DP_SPRITE)
					angleMeter._x = hero._x + decor._x
					angleMeter._y = hero._y + decor._y
				}
				break;
			
			case 2: // ANGLE
				
				angle -= 0.05*Timer.tmod
						
				Std.cast(angleMeter).a._rotation = angle/0.0174
				
				if( angle < -1.3 || !base.flPress ){
					initJump( angle, speed );
					angleMeter.removeMovieClip();
				}				
				
				break;
			
			case 3: // JUMP
				vity += 1*Timer.tmod
				
				vitx *= airFrict;
				vity *= airFrict;
				
				hero._x += vitx*Timer.tmod
				hero._y += vity*Timer.tmod
				
				hero._rotation = (Math.atan2(vity,vitx)/0.0174)*0.8
				
				var flUp = hero._y < 0
				var flIn = hero._x > jumpPoint && hero._x < jumpPoint+jumpSize
				
				if( !flUp ){

					if( flWasUp ){
						if( !flIn ){
							if( hero._x > jumpPoint+jumpSize ){
								//Log.trace("win")
								setWin(true)
								hero.gotoAndPlay("$win")
								
							}else{
								//Log.trace("soon")
								setWin(false)
								hero.gotoAndPlay("$tooSoon")
							}
							hero._y = 0
							hero._rotation = 0
							step = 4
							
						}else{
							//Log.trace("fall")
							setWin(false)
						}
						
						
					}else{
						if( !flIn ){
							
							hero._x = Math.min(Math.max(jumpPoint,hero._x),jumpPoint+jumpSize)
							vitx *= -0.9
							
							/*
							if( hero._y > 0 ){
								hero._x = jumpPoint+jumpSize 
								vitx *= -0.8
							}else{
								setWin(true,40)
							}
							*/
						}						
					}	
					

					

				}
				
				flWasUp = flUp
				break;
			case 4: // ATTERISSAGE
				vitx *= Math.pow(0.9,Timer.tmod)
				hero._x += vitx
				if(!flWin && hero._x > jumpPoint-10 ){
					hero._x = jumpPoint-10
					vitx = 0
				}
				break
			case 5: // ATTERISSAGE LOUPE

		}
		//
		super.update();
	}
	
	function initJump( angle, power ){
		flWasUp = true;
		step = 3
		vitx = Math.cos(angle)*power
		vity = Math.sin(angle)*power
		hero.gotoAndStop("$jump")
	}
	
	function genDecor(){
		decor = dm.empty(Game.DP_SPRITE)
		decor._y = cliffLevel
		var x = 0
		var ec = 40
		var d = 0
		while( x< jumpPoint ){
			d++
			x += ec*0.2 + Std.random(ec)
			if( x < jumpPoint ){
				var mc = Std.attachMC(decor,"mcCliffDecor",d)
				mc._x  = x
				mc._y  = 0
				mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
				//Log.trace(mc)
			}else{
				hole = Std.attachMC(decor,"mcCliffHole",d)
				hole._x = jumpPoint;
				hole._y = 0;
				Std.cast(hole).pink._xscale = jumpSize;
				Std.cast(hole).s2._x = jumpSize;
			}
		};
	}

	function moveMap(){
		var x = ( heroDecal  ) - hero._x
		var dif = x - decor._x
		decor._x += dif*0.5*Timer.tmod 
	}
	
//{	
}






















