
typedef SourceObstacle = {>Phys,ray:Float};

class Source extends Game{//}

	// CONSTANTES
	static var HERO_RAY = 	8;

	// VARIABLES
	var oList:Array<SourceObstacle>;
	var speed:Float;
	var timer:Float;
	var freq:Int;

	// MOVIECLIPS
	var hero:Phys;

	override function init(dif){
		gameTime = 400;
		super.init(dif);
		oList = new Array();
		speed = 1;
		freq = 16 - Std.int(dif*10);
		timer = 0;

		attachElements();
		zoomOld();
	}

	function attachElements(){

		bg = dm.attach("source_bg",0);

		// HERO
		hero = newPhys("McSourceHero");
		hero.x = Cs.omcw*0.5;
		hero.y = Cs.omch;
		hero.vy = -speed;
		hero.updatePos();

	}

	override function update(){

		switch(step){
			case 1:
				hero.vy = Math.max( hero.vy-0.1, -speed);
				if( hero.y < 0 ) setWin(true,10);
				var dx = getMousePos().x - hero.x;
				hero.x += dx*0.15;
				hero.vx *= 0.95;

				hero.root.rotation = dx*0.6;

				// HELICEE
				var h:McSourceHero = cast(hero.root);
				h.h.h.rotation += Math.max(10, -30 * hero.vy);

				//
				timer--;
				if(timer<0){
					timer = freq;
					genObstacle();
				}
				updateObstacle();
		}
		//
		super.update();
	}

	function genObstacle(){
		var sp:SourceObstacle = cast newPhys("mcSourceObstacle");
		sp.ray = 5+Math.random()*(15+dif*0.1);
		do{
			sp.ray-=0.2;
			sp.x = sp.ray + Math.random()*(Cs.omcw - 2*sp.ray);
		}while( isCol(sp) || ( hero.y < 40 && Math.abs(sp.x-hero.x) < 30 )  );
		sp.y = -sp.ray;
		sp.vy = 1+Math.random()*3;
		sp.updatePos();
		sp.root.scaleX = sp.ray*0.02;
		sp.root.scaleY = sp.ray*0.02;
		sp.root.gotoAndStop(1+Math.round(sp.ray/20));
		oList.push(sp);
	}

	function updateObstacle(){

		var a = oList.copy();
		for( sp in a ){
			var flDeath = sp.y>Cs.omch+sp.ray;
			// CHECK COL
			for( spo in a ){
					if( sp != spo ){
					var dist = sp.getDist(spo);
					if( dist < sp.ray+spo.ray ){
						var d = (sp.ray+spo.ray-dist)*0.5;
						var a = sp.getAng(spo);
						sp.x -= Math.cos(a)*d;
						sp.y -= Math.sin(a)*d;
						spo.x += Math.cos(a)*d;
						spo.y += Math.sin(a)*d;
					}
				}
			}

			// HERO COL
			var dist = sp.getDist(hero);
			if( dist < sp.ray+HERO_RAY ){
				var d = 5;
				var a = sp.getAng(hero);
				hero.vx += Math.cos(a)*d;
				hero.vy += Math.sin(a)*d;

				var p = dm.attach("mcCrossOnde", Game.DP_SPRITE);//newPhys("mcCrossOnde");
				p.x = sp.x;
				p.y = sp.y;
				p.scaleX = p.scaleY = sp.root.scaleX*1.5;
				//p.scale = sp.root.scaleX * 1.5 * 100;
				//p.updatePos();

				flDeath = true;
			}

			if( flDeath ){
				sp.kill();
				oList.remove(sp);
			}

		}
	}

	function checkCol(sp){


	}

	function isCol(sp){
		for( spo in oList ){
			if( sp != spo ){
				var dist = sp.getDist(spo);
				if( dist < sp.ray+spo.ray )return true;
			}
		}
		return false;
	}

//{
}








