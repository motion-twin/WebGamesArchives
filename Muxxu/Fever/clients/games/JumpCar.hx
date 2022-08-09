import mt.bumdum9.Lib;
import Protocole;

typedef JCCar = {>Phys,w:Float,flLeft:Bool};

class JumpCar extends Game{//}

	static var GL = 171;
	static var EDGE = 44;
	static var SIZE = [54,90];
	static var CH = 20;

	// CONSTANTES

	// VARIABLES
	var flJumpReady:Bool;
	var flSky:Bool;
	var hStep:Int;
	var wf:Float;
	var startTimer:Float;
	var freq:Float;
	var speed:Float;
	var cList:Array<JCCar>;
	var car:JCCar;

	// MOVIECLIPS
	var hero:Phys;

	override function init(dif){
		gameTime = 200;
		super.init(dif);
		flJumpReady = true;
		hStep = 0;
		wf = 0;
		startTimer = 20;
		freq = 20-dif*17;
		speed = 2+dif*4;
		flSky = false;
		cList = new Array();
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("jumpCar_bg",0);

		// HERO
		var sp = newPhys("mcJumpCarHero");
		sp.x = 74;
		sp.y = GL;
		sp.updatePos();
		hero = sp;

	}

	override function update(){
		if( !flJumpReady && !click )flJumpReady=true;

		switch(step){
			case 1:
				// ADD CARS
				if(startTimer<0){
					var last = null;
					if(cList.length > 0) last = cList[cList.length - 1];
					
					if( last == null || ( last.x < Cs.omcw - 60 && Std.random(Std.int(freq)) == 0 )  )	addCar();
					
				}else{
					startTimer--;
				}
				// MOVE
				moveCars();
				moveHero();

		}
		super.update();
	}

	function moveHero(){
		switch(hStep){
			case 0: // WALK
				if( hero.x < EDGE ){
					hero.weight = 0.5;
					hero.vx -= 1;
					hStep = 1;

				}

				//

				var dx = getMousePos().x - hero.x;
				var lim = 0.8;
				var inc = Num.mm(-lim,dx*0.05,lim);
				hero.vx += inc;
				hero.vx *= 0.8;

				var run = Math.abs(inc);

				if( run<0.1 ){
					wf = 0;
					hero.root.gotoAndStop("1");
				}else{
					wf=(wf+run*1.2)%11;
					hero.root.gotoAndStop(5+Std.int(wf));
					if( hero.vx*hero.root.scaleX < 0 )hero.root.scaleX*=-1;
				}

				if(car!=null){
					var dif = car.x-hero.x;
					if( dif < 0 || dif > car.w ){
						hero.root.gotoAndStop("10");
						flSky = true;
						hero.weight = 0.5;
						hStep = 1;
						car = null;
					}
				}
				//
				if( car!=null ){
					hero.x += car.vx;
					hero.y += car.vy;
				}
				//
				if(click){
					flJumpReady = false;
					hero.root.gotoAndStop("10");
					flSky = true;
					hero.weight = 0.5;
					hero.vy = -(10-dif*3);
					hStep = 1;
					car = null;
				}


			case 1: // FLY
				if(hero.vy > 0 && hero.x >= EDGE ){
					if( flSky && hero.y > GL-CH ){
						flSky = false;
						for( sp in cList ){
							if(sp.weight==null){
								var dx = sp.x - hero.x;
								if( dx > 0 && dx < sp.w ){
									hStep = 0;
									hero.weight = 0;
									hero.vx = 0;
									hero.vy = 0;
									hero.root.gotoAndPlay("land");
									hero.y = GL-CH;
									car = sp;
									break;
								}
							}
						}
					}

					if( hero.y > GL ){
						hero.y = GL;
						hStep = 0;
						hero.weight = null;
						hero.vx = 0;
						hero.vy = 0;
						hero.root.gotoAndPlay("land");

					}

				}

			case 2:

				if( hero.y > GL-6 && hero.x > EDGE ){
					hero.y = GL-6;
					hero.vy *= -1 ;
				}

		}
		if( hero.y > Cs.omch || hero.x < -10 ){
			timeProof = false;
			setWin(false);
		}





	}

	function moveCars(){
		var prev:JCCar = null;
		for(  sp in cList ){

			// CHECK OTHER CAR
			if( prev != null ){
				var dx = Math.abs(sp.x-prev.x);
				if( dx < sp.w ){
					var d = sp.w - dx;
					sp.x += d*0.5;
					prev.x -= d*0.5;

				}
			}

			// CHECK FALL
			if( sp.x-sp.w*0.5 < EDGE ){
				if( sp.weight == null ){
					sp.weight = 0.75;
					sp.vr = -4;
				}
			}else{
				prev = sp;
			}

			// CHECK HERO COL

			var ddx = (sp.x-sp.w)-hero.x;
			if( ( !sp.flLeft && ddx < 0 ) || ( sp.flLeft && ddx > 0 ) ){

				if( flSky ){
					sp.flLeft = !sp.flLeft;
				}else if(hStep!=2){
					hStep = 2;
					hero.weight = 0.5;
					hero.vx = sp.vx*2;
					hero.vy = -(3+Math.random()*3);
					hero.vr = 12;
					hero.root.gotoAndStop("ouch");
					hero.y -= 6;
					sp.vx *= 0.5;
					timeProof = true;
				}
			}



			//
			if( sp.x < 0 )sp.kill();

			//


		}
	}

	function addCar(){

		var sp:JCCar = cast(newPhys("mcJumpCar"));
		var type = 0;
		sp.vx = -(speed+Math.random()*speed);
		sp.w = SIZE[type];
		sp.x = Cs.omcw+sp.w+10;
		sp.y = GL;
		sp.frict = 1;
		sp.flLeft = false;
		sp.updatePos();
		sp.root.gotoAndStop(Std.random(sp.root.totalFrames)+1);
		cList.push(sp);
	}

	override function outOfTime(){
		setWin(true);
	}



//{
}






















