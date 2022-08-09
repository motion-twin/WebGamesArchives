class Trampoline extends Game{//}

	// CONSTANTES
	var th:Int;
	var gh:Int;
	var hRay:Int;
	var tRay:Int;
	// VARIABLES
	var flUp:Bool;
	var flOut:Bool;
	var flFaceSwap:Bool;
	var wallLevel:Int;

	// MOVIECLIPS
	var hero:Phys;
	var trampo:Sprite;
	var filet:flash.display.MovieClip;
	var wall:flash.display.MovieClip;
	var ground:flash.display.MovieClip;
	var mask_:flash.display.MovieClip;


	override function init(dif){
		gameTime = 400;
		super.init(dif);

		th = Cs.omch-40;
		gh = Cs.omch-6;
		hRay = 24;
		tRay = 94;
		wallLevel = ( 4-Math.round(dif*10) )*32;
		flUp = false;
		flOut = false;
		flFaceSwap = true;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		dm.attach("trampoline_bg",0);

		// WALL
		wall = dm.attach("mcTrampolineWall",Game.DP_BG);
		wall.y = wallLevel;

		// GROUND
		ground = dm.attach("mcTrampolineGround",Game.DP_BG);

		// HERO
		hero = newPhys("mcTrampoMan");
		hero.x = Cs.omcw*0.5;
		hero.y = Cs.omch*0.5;
		hero.vr = 0;
		hero.weight = 0.5;
		hero.root.scaleX = hRay*0.02;
		hero.root.scaleY = hRay*0.02;
		hero.root.stop();
		hero.updatePos();

		// FILET
		filet = dm.empty(Game.DP_SPRITE);

		// TRAMPOLINE
		trampo = newSprite("mcTrampoline");
		trampo.x = Cs.omcw*0.5;
		trampo.y = th;
		trampo.updatePos();



	}

	override function update(){
		super.update();
		switch(step){
			case 1:
				var y  = hero.y+hRay;

				// CHECKWIN
				if( !flUp && y < wallLevel ){
					flUp = true;
					timeProof = true;
					hero.root.gotoAndStop(6);

				}

				if( flUp && y > wallLevel ){
					timeProof   = false;
					flUp = false;
					setWin(true,20);
					mask_ = dm.attach("mcRedSquare",Game.DP_SPRITE);
					mask_.scaleX = Cs.omcw*0.01;
					mask_.scaleY = Cs.omch*0.01;
					mask_.y = wallLevel - Cs.omch;
					hero.root.mask = mask_;
				}



				// REBOND
				if( flOut ){

					if( y > gh ){
						hero.y = gh-hRay;
						hero.vy *= -0.5;
						setWin(false,20);
						hero.root.gotoAndStop("5");
					}
				}else{

					if( y > th ){

						if(  Math.abs(hero.x-trampo.x) > tRay-hRay ){
							flOut = true;
							dm.over(hero.root);
						}
						var dy = th-y;
						hero.vy += dy*0.1*(click?2:1);


						if(click){
							var dx = (getMousePos().x - hero.x);
							//dx += (Math.random()*2-1)*dif*100;
							hero.vx += dx*0.01;
							hero.vr += dx*0.05;
						}

						if( flFaceSwap && Math.abs(dy)> hRay*1.5 ){
							flFaceSwap  = false;
							hero.root.gotoAndStop(Std.string(Std.random(3)+2));
						}


					}else{
						if(!flFaceSwap)flFaceSwap = true;

						hero.vr -= hero.root.rotation*0.002;

					}

					if( !flUp && !win && Math.abs(hero.x-trampo.x) > tRay-hRay*2  ){
						hero.root.gotoAndStop(7);
					}


				}



				// DRAW FILET
				filet.graphics.clear();
				if(!flOut && y>th-4 && win!=true ){

					filet.graphics.lineStyle(1,0x0000,20);
					filet.graphics.beginFill(0xCECE79,100);
					filet.graphics.moveTo( trampo.x-tRay, trampo.y );
					filet.graphics.lineTo( trampo.x+tRay, trampo.y );
					filet.graphics.curveTo( (trampo.x+tRay)*0.3+hero.x*0.7, y, hero.x, y );
					filet.graphics.curveTo( (trampo.x-tRay)*0.3+hero.x*0.7, y, trampo.x-tRay, trampo.y );
					filet.graphics.endFill();
				}


				// MOVEMAP
				var c = Cs.mcw / Cs.omcw;
				box.y = Math.max(0, Cs.mch * 0.5 - hero.y*c );
				
				
				/*
				var c = 0.15;
				var ty = (Cs.omch*0.5 - hero.y)*Cs.mcw/Cs.omcw;
				var dy = ty - box.y;
				box.y = Math.max(0, box.y + dy * c);
				*/



		}
		//

	}


//{
}

// TODO : rebond sur trampoline derrière mur







