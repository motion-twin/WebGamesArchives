import mt.bumdum9.Lib;
class FlyEater extends Game{//}

	// CONSTANTES
	static var SL = 208;
	static var POWER_MAX = 14;
	static var DODGE_RAY = 80;

	// VARIABLES
	var flCharge:Bool;
	var flFace:Bool;
	var xdec:Float;
	var ydec:Float;
	var power:Float;
	var timer:Float;
	var dodge:Float;

	// MOVIECLIPS
	var sea:flash.display.MovieClip;
	var bar:flash.display.MovieClip;
	var fish:Phys;
	var fly:{>Phys,dec:Float, trg:{x:Float,y:Float}};


	override function init(dif:Float){
		gameTime = 600-dif*200;
		super.init(dif);
		xdec = 0;
		ydec = 0;
		flCharge = false;
		dodge = dif*0.2 - 0.1;
		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("flyEater_bg",0);

		// SEA
		sea = dm.attach("mcFlyWater",Game.DP_SPRITE);
		sea.y = SL;

		// FISH
		fish = newPhys("mcFlyFish");
		fish.x = 0;
		fish.y = SL;
		fish.root.gotoAndStop("profil");
		//fish.weight = 0.7
		fish.updatePos();
		fish.frict = 0.94;

		// FLY
		fly = cast newPhys("mcBlackFly");
		fly.x = Math.random()*Cs.omcw;
		fly.y = Math.random()*Cs.omch;
		fly.dec = 0;
		fly.updatePos();
		fly.frict = 0.94;
		chooseTrg();

		// BAR
		bar = dm.attach("mcFlyBar",Game.DP_SPRITE+1);
		bar.x = Cs.omcw*0.5;
		bar.y = Cs.omch - 6;
		bar.scaleX = 0;
	}

	override function update(){
		super.update();

		xdec = (xdec+15)%628;
		ydec = (xdec+1.5)%628;
		sea.x = (sea.x+(Math.cos(xdec/100)+0.5))%24;
		sea.y = SL + Math.sin(ydec/100)*4;

		moveFish();
		moveFly();
		switch(step){
			case 1: // CENTER

			case 2: //
				timer--;
				if(timer<0)setWin(true,20);
		}
	}

	function moveFish(){

		var sens = fish.vx/Math.abs(fish.vx);
		var tb = 0.0;

		if(fish.weight == null){

			var frict = 0.9;
			fish.vx *= frict;
			fish.vy *= frict;
			var p = {
				x:Cs.omcw*0.5 + Math.cos(xdec/100)*5,
				y:sea.y+6
			}
			fish.towardSpeed(p,0.3,0.5);

			fish.root.rotation *= 0.5;

			if( !flFace ){
				fish.root.scaleX = sens;
				if( Math.abs(fish.x-Cs.omcw*0.5) < 8 ){
					fish.root.gotoAndPlay("profil");
					flFace = true;
				}
			}


			if(flCharge){
				power = Math.min( power+0.4, POWER_MAX );
				tb = (power/POWER_MAX);
				if(!click)jump();
			}else{
				if(click){
					flCharge = true;
					power = 0;
				}
			}




		}else{
			// PLONGE
			if( fish.y > sea.y && fish.vy > 0 ){
				fish.weight = null;
				flFace = false;
				fish.root.gotoAndStop("profil");
				// PART
				var max = Std.int(6+fish.vy*1.5);
				for( i in 0...max ){
					var p = newPhys("partBlackWater");
					var a = -Math.random()*3.14;
					var ca = Math.cos(a);
					var sa = Math.sin(a);
					var pb = 1+fish.vy*0.1;
					var pw = pb+Math.random()*pb;
					p.x = fish.x + ca*7;
					p.y = sea.y + 10;
					p.vx = ca*pw;
					p.vy = sa*pw*3;
					p.fadeType = 0;
					p.weight = 0.3 + Math.random()*0.2;
			
					p.setScale(1+Math.random()*1.5);
					p.timer=  10+Std.random(30);
					p.updatePos();

				}
			}

			// GNAC
			if( fly != null && fish.getDist(fly) < 18 ){
				var mc = dm.attach("flyEater_fxCatch",Game.DP_SPRITE);
				mc.x = fly.x;
				mc.y = fly.y;
				fly.kill();
				fly = null;
				fish.root.gotoAndPlay("gnac");
				step = 2;
				timer = 6;
			}

			//
			fish.root.rotation = Math.atan2( fish.vy, fish.vx )/0.0174 + (-sens+1)*0.5*180;
			fish.root.scaleX = sens;
		}

		var ds = tb - bar.scaleX;
		bar.scaleX += ds*0.5;


	}

	function jump(){
		flCharge = false;
		fish.weight = 0.7;

		fish.vx = (getMousePos().x - fish.x)*0.13;
		fish.vy = -power*1.7;

		fish.root.gotoAndPlay("jump");

	}

	function moveFly(){

		if( fly == null ) return;
		
		fly.towardSpeed( fly.trg, 0.2, 0.5 );

		var lim = 20;
		var frame = 21-Std.int(Num.mm(-lim,fly.vx,lim));
		fly.root.gotoAndStop(frame);

		if( fly.getDist(fly.trg) < 16 || Math.random() < 0.02 ){
			chooseTrg();
		}

		// DODGE
		if(dodge < 0 && fish.weight == null )return;
		var dist = fly.getDist(fish);
		if( dist < DODGE_RAY ){
			var d = DODGE_RAY-dist;
			var a = fish.getAng(fly);
			fly.x += Math.cos(a)*dodge*d;
			fly.y += Math.sin(a)*dodge*d;


		}



	}

	function chooseTrg(){
		var m = 10;
		fly.trg = {
			x:m+Math.random()*(Cs.omcw-2*m),
			y:m+Math.random()*(Cs.omch-(50+dif*100)),
		}
	}






//{
}

