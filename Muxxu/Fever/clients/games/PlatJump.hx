import mt.bumdum9.Lib;
typedef Plat = {>flash.display.MovieClip,s0:flash.display.MovieClip,s1:flash.display.MovieClip,m:flash.display.MovieClip, ray:Float, speed:Float};

class PlatJump extends Game{//}

	static var mcw = 240;
	static var mch = 240;

	// CONSTANTES
	static var JUMP = 11;
	static var GL = 236;
	
	// VARIABLES
	var pi:Null<Int>;
	var ni:Null<Int>;
	var pList:Array<Plat>;

	// MOVIECLIPS
	var hero:Phys;

	override function init(dif){
		gameTime = 280;
		super.init(dif);
		attachElements();
		zoomOld();
		bg = dm.attach("platjump_bg",0);
	}

	function attachElements(){

		// PLATEFORME
		var max = 3;
		var ec = mch/(max+1);
		var r = Cs.getRandRep(max);
		pList = [];

		for( i in 0...max ){
			var mc:Plat = cast dm.attach("mcRayPlateforme",Game.DP_SPRITE);
			//mc.ray = Cs.mm( 12+dif*0.1, 12+24*r[i*2]*dc, 150 )
			mc.ray = 60-dif*40;
			if( mc.ray<10 )mc.ray = 10;
			mc.speed = 1.5+(r[i]*3);
			mc.x = mc.ray + Math.random()*(mcw-2*mc.ray);

			mc.y = (i+1)*ec;
			mc.m.scaleX = mc.ray*0.02;
			mc.s0.x = -mc.ray;
			mc.s1.x = mc.ray;

			if(i==0)		mc.gotoAndStop(2);
			else			mc.gotoAndStop(1);

			pList.push(mc);
		}

		// HERO
		hero = newPhys("mcPlatMonster");
		hero.frict = 0.96;
		hero.x = mcw*0.5;
		hero.y = GL;
		//hero.weight = 0.5;
		hero.updatePos();


	}

	override function update(){


		movePlats();
		if(pi!=null)hero.x += pList[pi].speed;

		switch(step){
			case 1:
				if(click){
					hero.root.gotoAndPlay("prepare");
					step = 2;
				}
			case 2:
				if(!click){
					pi = null;
					hero.weight = 0.5;
					hero.vy = -JUMP;
					hero.root.gotoAndPlay("jump");
					step = 3;
				}
			case 3:
				if( hero.vy>0 ){
					ni = null;
					var id = 0;
					for( mc in pList){
						if( hero.y < mc.y ){
							ni = id;
							break;
						}
						id++;
					}
					hero.root.gotoAndPlay("jump_end");
					step = 4;
				}
			case 4:
				if(ni!=null){
					var mc = pList[ni];
					if( hero.y > mc.y ){
						if(Math.abs(hero.x - mc.x)<mc.ray){
							pi = ni;
							landing(mc.y);
							if( ni==0 ){
								step = 5;
								hero.root.gotoAndPlay("win");
								mc.gotoAndStop(1);
								setWin(true,34);
							}
						}else{
							ni++;
							if(ni==pList.length)ni = null;
						}
					}
				}else{
					if( hero.y > GL )landing(GL);
				}

		}

		super.update();
	}

	function movePlats(){
		for(mc in pList ){
			mc.x += mc.speed;
			if( mc.x < mc.ray || mc.x > mcw-mc.ray ){
				mc.x = Num.mm(mc.ray,mc.x,mcw-mc.ray);
				mc.speed*=-1;
			}


		}


	}

	function landing(y){
		hero.weight = null;
		hero.y = y;
		hero.vy = 0;
		hero.root.gotoAndPlay("land");
		step = 1;
	}


//{
}

