import KKApi;
import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;

enum Step {
	_Play;
	_GameOver;
}

typedef Fish = {>Phys,type:Int};

class Game {//}

	public static var FL_DEBUG = false;
	public static var FL_DISPLAY_SCORE = true;
	public static var FL_GOLDEN_FISH = true;





	// CONSTANTES
	static var DP_BG =	2;
	static var DP_PELICAN =	3;
	static var DP_FISH = 	4;
	static var DP_PARTS = 	5;
	static var DP_BUBBLES =	7;
	static var DP_FRONT = 	10;


	static var SKY = 50;
	static var SEA = 230;

	static var PSPEED = 3;
	static var FALL = 0.4;
	static var FRAY = 8;
	static var BEC = 28;
	static var BRAY = 14;

	//static var a:mt.flash.Volatile<Int>;

	// VARIABLES
	var lvl:Int;
	var clvl:mt.flash.Volatile<Int>;

	var flGoldenFish:mt.flash.Volatile<Bool>;
	var flClick:Bool;
	var flPress:Bool;
	var flAbove:Bool;
	var frame:Float;
	var plouf:Float;
	var freeze:Float;
	var drip:Float;
	var timer:mt.flash.Volatile<Float>;
	var fishDisplayTimer:Float;

	var pool:mt.flash.Volatile<Int>;
	var step:Step;

	var fList:Array<Fish>;
	var gList:Array<Phys>;
	var bList:Array<Phys>;

	// MOVIECLIPS
	var pel:{>Phys,sens:Int};
	var sea:flash.MovieClip;
	var head:flash.MovieClip;
	var rond:flash.MovieClip;
	var mcBar:{>flash.MovieClip,fieldLevel:flash.TextField,slot:flash.MovieClip,b:flash.MovieClip};



	public var dm:mt.DepthManager;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var me:Game;


	public function new( mc : flash.MovieClip ){

		//

		root = mc;
		me = this;
		dm = new mt.DepthManager(root);
		bg = dm.attach("mcBg",DP_BG);
		init();



		var me = this;
		var ml  = {};
		Reflect.setField(ml,"onMouseDown",function(){me.flClick=true;});
		Reflect.setField(ml,"onMouseUp",function(){me.flClick=false;});
		flash.Mouse.addListener(cast ml);

	}
	function init(){

		flAbove = true;
		freeze = 0;
		plouf = 0;
		frame = 0;
		lvl = 0;
		clvl = 0;
		pool = 0;

		gList = [];
		bList = [];
		fList = [];

		initInter();
		attachElements();
		nextLevel();

		step = _Play;

	}
	function attachElements(){
		// SEA
		sea = dm.attach("mcPelicanSea",DP_FRONT);
		//sea._y = Cs.mch;
		sea._y = SEA;
		//sea.blendMode = "overlay";

		// PELICAN
		pel = cast new Phys(dm.attach("mcPelican",DP_PELICAN));
		pel.x = 8;
		pel.y = SKY;
		pel.sens = 1;
		pel.vx = pel.sens * PSPEED;
		pel.setScale(120);
		//Filt.glow(pel.root,2,1,0);

		head = cast (pel.root).head;
		head.stop();
	}

	// UPDATE
	public function update(){

		flPress = flClick || flash.Key.isDown(flash.Key.SPACE);

		//for(i in 0...200000){var a = i*5+6;}
		movePelican();

		moveFish();
		moveGoutte();
		moveBubble();
		updateTimer();
		updateSprites();

		if(clvl!=lvl)KKApi.flagCheater();

	}
	function updateSprites(){
		var list =  Sprite.spriteList.copy();
		for(sp in list)sp.update();
	}

	// PELICAN
	function movePelican(){

		// CHECK SIDE
		var m = 0;
		if( pel.x < m || pel.x > Cs.mcw-m ){
			pel.sens *= -1;
			pel.x  = Num.mm(m,pel.x,Cs.mcw-m);
			pel.root._xscale = pel.sens*pel.scale;
			pel.vx = pel.sens * PSPEED;
			//if( pel.y > SKY+100 )freeze=50;	// FRZ COGNE
		}



		// PLOUF
		if( pel.y > SEA-10 ){


				if(flAbove){
					splash();
					flAbove = false;
				}
				if(Math.random()<0.8){
					var p = new Phys(dm.attach("partPelicanBubble",DP_BUBBLES));
					p.x = pel.x+(Math.random()*2-1)*10;
					p.y = pel.y+(Math.random()*2-1)*10;
					p.weight = -(0.1+Math.random()*0.3);
					p.scale = 30+Math.random()*70;
					p.vx = pel.vx*0.8;
					p.vy = pel.vy*0.8;
					p.frict = 0.92;
					p.setScale(50-p.weight*150);
					//p.root._alpha = 50;
					bList.push(p);
				}

				if( !flPress || pel.y > SEA+14 ){
					freeze = 60;			// FRZ BACK
				}


			// FORCE
			pel.vy -= 0.1*mt.Timer.tmod;

			// RETOUR


			if( pel.vy > -5  ){
				var a = Math.atan2(pel.vy,pel.vx);
				var p = {
					x:pel.x + Math.cos(a)*BEC,
		 			y:pel.y + Math.sin(a)*BEC
				}


				/*
				if(rond==null){
					rond = dm.attach("mcRoundTest",DP_FRONT);
					rond._xscale = rond._yscale = BRAY*2;
				}
				rond._x = p.x;
				rond._y = p.y;
				*/

				var list = fList.copy();

				for( fish in list ){
					var dx = Math.max(Math.abs(fish.x-p.x)-10,0);
					var dy = fish.y-p.y;
					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist < BRAY ){
						fList.remove(fish);
						fish.kill();
						//freeze = 3000;	// FRZ FISH
						/*
						if(head._currentframe<5)head.nextFrame();
						if(fish.type==1){
							flGoldenFish = true;
							head.gotoAndStop(head._currentframe+10);
						}
						*/
						pool++;
						if(fish.type==1)flGoldenFish = true;
						var frame = pool+1;
						if(flGoldenFish)frame+=20;
						head.gotoAndStop(frame);

						break;
					}
					// ESCAPE


					if( fish.type==1 && dist < 100 ){
						var dx = fish.x-p.x;
						var adx = Math.abs(dx);
						var sens = adx/dx;
						fish.x += (100-dist)*Math.abs(fish.vx)*0.03*sens;
					}


				}
			}

		}else{
			if(!flAbove){
				splash(0.5);
				drip = 0;
				if(pool>0){
					displayFish(pool);
				}

			}

			flAbove = true;
		}



		if( freeze>0 )freeze -= mt.Timer.tmod;

		// CONTROL
		if( flPress && freeze <= 0 && step == _Play){
			var lim = 6;
			pel.vy = Num.mm(-lim,(pel.vy+FALL*mt.Timer.tmod),lim);
		}else{
			var dy = SKY-pel.y;
			var lim = 0.3;
			pel.vy += Num.mm(-lim,dy*0.01,lim)*mt.Timer.tmod;
			pel.vy *= Math.pow(0.95,mt.Timer.tmod);
		}

		// EAT

		if( pel.y< SKY && pool>0 && step==_Play ){

			//displayFish(pool);
			mcBar.slot.smc.smc.gotoAndPlay(2);
			fishDisplayTimer = 20;

			var sc:Float =  (2*pool-1) *  KKApi.val(Cs.SCORE);
			sc *=  0.5+(timer/100)*0.5;
			var sci = Math.ceil( sc/50 )*50;

			if(flGoldenFish){
				flGoldenFish = false;
				sci*=2;
			}

			KKApi.addScore( KKApi.const(sci) );

			if( FL_DISPLAY_SCORE ){
				var mc = dm.attach("mcScore",DP_FRONT);
				cast(mc).score = "+"+sci;
			}


			freeze = 0;
			pool = 0;
			head.gotoAndStop(1);
			if(fList.length==0)nextLevel();




		}

		// GFX
		pel.root._rotation = (pel.vy/pel.vx)*40;
		frame = (frame+Math.max(0,-pel.vy*0.5 + 2))%25;
		pel.root.gotoAndStop(Std.string(Std.int(frame)+1));


		// DRIP
		if(drip!=null){
			drip += 0.6*mt.Timer.tmod;
			if( Std.random(Std.int(drip)) < 3 ){
				var p = newGoutte();
				p.x += (Math.random()*2-1)*5;
				p.y += (Math.random()*2-1)*5;
				if(drip>20)drip=null;
			}
		}



	}


	/*
	Papoyo le toucan vagabond s'est perdu lors d'une migration improvisé vers la Suède.
Il est maintenant perdu au dessus du port de Caen et il a très faim !
Aidez le a plonger pour trouver les bancs de délicieux poissons des docks.
*/

	// FISH
	function genFish(){

		var flGold = FL_GOLDEN_FISH && lvl>1;
		var max = 2+lvl;
		for( i in 0...max ){
			var sp:Fish = cast new Phys(dm.attach("mcFish",DP_FISH));
			var sens = Std.random(2)*2-1;
			sp.x = Cs.mcw*0.5 - (Cs.mcw*0.5+FRAY+Math.random()*((lvl+2)*15))*sens;
			sp.y = SEA + 15 + Math.random()*Math.min(26+lvl,55);
			//sp.x = FRAY + Math.random()*Cs.mcw-2*FRAY;
			//sp.y = SEA + 27 + (Math.random()*2-1)*12;
			sp.vx = 0.3 + lvl*0.05 + Math.random();

			//sp.root._xscale = 100*sens;
			sp.vx *= sens;
			sp.type =  0;
			if(flGold && Std.random(3+lvl) == 0 ){
				sp.type = 1;
				flGold = false;
			}
			sp.root.gotoAndStop(sp.type+1);
			fList.push(sp);



		}
	}
	function moveFish(){
		for( fish in fList ){
			fish.x += fish.vx*mt.Timer.tmod;

			var m = Math.abs(fish.vx)*5 + FRAY;
			if(fish.x<m)fish.root.smc.prevFrame();
			else if(fish.x>Cs.mcw-m)fish.root.smc.nextFrame();
			else if(fish.vx>0)fish.root.smc.prevFrame();
			else if(fish.vx<0)fish.root.smc.nextFrame();


			if( ( fish.x < FRAY || fish.x > Cs.mcw-FRAY ) && (fish.x-Cs.mcw*0.5)*fish.vx>0 ) {
				fish.x = Num.mm( FRAY, fish.x, Cs.mcw-FRAY );
				fish.vx *= -1;
				//fish.root._xscale = 100*(fish.vx/Math.abs(fish.vx));
			}
		}
	}

	// LEVEL
	function nextLevel(){
		timer = 100;
		lvl++;
		clvl++;
		genFish();
		mcBar.fieldLevel.text = "NIVEAU "+lvl;
	}

	// INTERFACE
	function initInter(){
		mcBar = cast dm.attach("mcBar",DP_FRONT);
		mcBar.slot.stop();
	}
	function updateTimer(){

		// TIMER
		var dec = 0.02+lvl*0.015;

		timer = Math.max(timer-dec*mt.Timer.tmod,0);
		mcBar.b._xscale += (timer-mcBar.b._xscale )*0.2*mt.Timer.tmod;

		if(timer==0 && fList.length>0 ){
			step = _GameOver;
			KKApi.gameOver({});
		}


		//
		/*
		if(freeze>0 && mcBar.slot._currentframe !=3 ){
			mcBar.slot.gotoAndStop(3);
		}else mcBar.slot.gotoAndStop(flPress?2:1);
		*/


		// SLOT



		if(fishDisplayTimer==null){


			var tr = 0;
			if( flPress && freeze<=0 )tr = 180;

			var dr = Num.hMod(tr-mcBar.slot.smc._rotation,180);
			mcBar.slot.smc._rotation += dr*0.2;
			mcBar.slot._xscale = pel.sens*100;

			if(freeze>0 )mcBar.slot.smc.gotoAndStop(2);
			else mcBar.slot.smc.gotoAndStop(1);



		}else{
			fishDisplayTimer -= mt.Timer.tmod;
			if(fishDisplayTimer<0){
				fishDisplayTimer = null;
				mcBar.slot.smc.gotoAndStop(2);
			}
		}



	}
	function displayFish(n){
		//trace(n);
		fishDisplayTimer = 100;
		mcBar.slot.smc.gotoAndStop(3);
		mcBar.slot._xscale = 100;
		mcBar.slot.smc._rotation = 0;

		var field:flash.TextField = cast (mcBar.slot.smc).field;
		field.text = Std.string(n);
	}

	// FX
	function splash(?c:Float){

		if(c==null)c=1;
		// GOUTTE
		var max = Math.floor(pel.vy*2);
		for( i in 0...max ){
			var p = newGoutte();
			p.y = SEA;
			var a = -Math.random()*3.14;
			p.vx = Math.cos(a)*2;
			p.vy = Math.sin(a)*5;

		}

		// PLOUF
		for(i in 0...2 ){
			var mc = dm.attach("plouf",DP_PARTS);
			mc._x = pel.x;
			mc._y = SEA;
			mc._xscale = mc._yscale = (40+(Math.abs(pel.vy)*15))*c;
		}
	}
	function newGoutte(){
		var p = new Phys( dm.attach("partPelicanWater",DP_PARTS));
		p.x = pel.x;
		p.y = pel.y;
		p.weight = 0.1+Math.random()*0.15;
		p.scale = 70+Math.random()*60;
		gList.push(p);
		return p;


	}
	function moveGoutte(){
		for( p in gList ){
			if(p.y>SEA){
				p.y = SEA;
				p.vx = 0;
				p.vy = 0;
				p.weight = 0;
				p.root.play();
				p.root._xscale = (Std.random(2)*2-1)*100;
				// WARNING REMOVE ERROR
			}
		}
	}
	function moveBubble(){

		for( p in bList ){
			if(p.y<SEA || p.y > Cs.mch ){
				p.kill();
			}
		}
	}


	//
	function mousePress(){

	}

//{
}




