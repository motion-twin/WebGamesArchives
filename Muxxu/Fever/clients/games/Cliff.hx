class Cliff extends Game{//}

	// CONSTANTES
	var jumpPoint:Int;
	var cliffLevel:Int;
	var heroDecal:Int;
	var heroFrameMax:Int;
	var jumpSize:Float;

	// VARIABLES
	var flWasUp:Bool;
	var holeWidth:Float;
	//var px:Float;
	var speed:Float;
	var heroFrame:Float;
	var vitx:Float;
	var vity:Float;
	var angle:Float;
	var airFrict:Float;
	var omp:{x:Float,y:Float};
	var ddm:mt.DepthManager;

	// MOVIECLIPS
	var hero:flash.display.MovieClip;
	var cliff:flash.display.MovieClip;
	var hole:flash.display.MovieClip;
	var decor:flash.display.MovieClip;
	var angleMeter:flash.display.MovieClip;

	override function init(dif){
		gameTime = 260;
		super.init(dif);

		jumpPoint = 1000;
		jumpSize = 60+dif*200;
		cliffLevel = Cs.omch - 50;
		airFrict = 0.99;

		heroDecal = 40;
		heroFrame = 0;
		heroFrameMax = 36;

		omp = getMousePos();
		speed = 0;
		attachElements();

		zoomOld();

	}

	function attachElements(){

		bg = dm.attach("cliff_bg",0);

		// CLIFF
		cliff = dm.attach("mcCliffGround",Game.DP_SPRITE);
		cliff.x = 0;
		cliff.y = cliffLevel;

		// DECOR
		genDecor();

		// HERO
		/*
		hero = newPhys("mcCliffHero")
		hero.x = heroDecal;
		hero.y = cliffLevel;
		hero.flPhys = false;
		hero.skin.stop();
		hero.updatePos();
		*/
		hero = ddm.attach("mcCliffHero",3);
		hero.stop();
		hero.x = 0;
		hero.y = 0;


	}

	override function update(){

		moveMap();
		switch(step){
			case 1: // RUN
				var p = getMousePos();

				var dx = p.x - omp.x;
				var dy = p.y - omp.y;
				var dist = Math.sqrt(dx*dx+dy*dy);

				speed += dist*0.012;
				speed *= 0.97;

				//hero.x = heroDecal + speed*2
				//decor.x -= speed;

				hero.x += speed;

				// FRAME
				var dash = speed*0.3;
				heroFrame = ( heroFrame + dash )%heroFrameMax;
				if( dash < 4 ){
					hero.gotoAndStop(Math.round(heroFrame+1));
				}else{
					hero.gotoAndStop(40+Std.random(3));
				}


				// SAUVE LA POS DE LA SOURIS
				omp = p;

				if( hero.x > jumpPoint ){
					hero.x = jumpPoint;
					initJump( -0.2, speed );
				}

				if( click ){
					angle = 0;
					step = 2;
					angleMeter = dm.attach("mcAngleQuart",Game.DP_SPRITE);
					angleMeter.x = hero.x + decor.x;
					angleMeter.y = hero.y + decor.y;
				}

			case 2: // ANGLE

				angle -= 0.05;

				getMc(angleMeter,"a").rotation = angle/0.0174;

				if( angle < -1.3 || !click ){
					initJump( angle, speed );
					angleMeter.parent.removeChild(angleMeter);
				}


			case 3: // JUMP
				vity += 1;

				vitx *= airFrict;
				vity *= airFrict;

				hero.x += vitx;
				hero.y += vity;

				hero.rotation = (Math.atan2(vity,vitx)/0.0174)*0.8;

				var flUp = hero.y < 0;
				var flIn = hero.x > jumpPoint && hero.x < jumpPoint+jumpSize;

				if( !flUp ){

					if( flWasUp ){
						if( !flIn ){
							if( hero.x > jumpPoint+jumpSize ){
								
								setWin(true,25);
								hero.gotoAndPlay("$win");

							}else{
								
								setWin(false,20);
								hero.gotoAndPlay("$tooSoon");
							}
							hero.y = 0;
							hero.rotation = 0;
							step = 4;

						}else{
							//Log.trace("fall")
							setWin(false,20);
						}


					}else{
						if( !flIn ){

							hero.x = Math.min(Math.max(jumpPoint,hero.x),jumpPoint+jumpSize);
							vitx *= -0.9;
						}
					}




				}

				flWasUp = flUp;

			case 4: // ATTERISSAGE
				vitx *= 0.9;
				hero.x += vitx;
				if(!win && hero.x > jumpPoint-10 ){
					hero.x = jumpPoint-10;
					vitx = 0;
				}

			case 5: // ATTERISSAGE LOUPE

		}
		//
		super.update();
	}

	function initJump( angle:Float, power:Float ) {
		power += 1.5;
		flWasUp = true;
		step = 3;
		vitx = Math.cos(angle)*power;
		vity = Math.sin(angle)*power;
		hero.gotoAndStop("$jump");
	}

	function genDecor(){
		decor = dm.empty(Game.DP_SPRITE);
		decor.y = cliffLevel;
		ddm = new mt.DepthManager(decor);
		var x = 0.0;
		var ec = 40;
		var d = 0;
		while( x< jumpPoint ){
			d++;
			x += ec*0.2 + Std.random(ec);
			if( x < jumpPoint ){
				var mc = ddm.attach("mcCliffDecor",0);
				mc.x  = x;
				mc.y  = 0;
				mc.gotoAndStop(Std.random(mc.totalFrames)+1);
				//Log.trace(mc)
			}else{
				hole = ddm.attach("mcCliffHole",0);
				hole.x = jumpPoint;
				hole.y = 0;
				getMc(hole,"pink").scaleX = jumpSize*0.01;
				getMc(hole,"s2").x = jumpSize;
			}
		};
	}

	function moveMap(){
		var x = ( heroDecal  ) - hero.x;
		var dif = x - decor.x;
		decor.x += dif*0.5;
	}

//{
}






















