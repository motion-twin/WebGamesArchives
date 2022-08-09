class Game {//}

	static var FL_CHEAT = false;

	static var DP_INTERFACE = 	12
	static var DP_SHOT = 		10
	static var DP_PARTS = 		9
	static var DP_BADS = 		8
	static var DP_HERO = 		7
	static var DP_DRAW = 		5
	static var DP_UNDERPARTS =	3
	static var DP_BG =		3

	//


	//

	//
	var stats:{
		$k:Array<int>,
		$b:Array<int>
	}

	var flCheatReady:bool;

	var lvl:int;
	var step:int;

	var flOption:bool;

	var monsterlvl:float
	var phaseTimer:float
	var scrollDash:float;
	var scrollSpeed:float;

	var sList:Array<Sprite>;
	var pList:Array<Part>;
	var shotList:Array<Shot>;
	var badsList:Array<Bads>;
	var bonusList:Array<Bonus>;
	var dashLightList:Array<MovieClip>

	var dm:DepthManager;

	var hero:Hero;

	var root:MovieClip;
	var bg:MovieClip;
	var draw:MovieClip;

	var inter:Inter;

	function new(mc) {

		Cs.game = this
		dm = new DepthManager(mc);
		root = mc;

		sList = new Array();
		shotList = new Array();
		badsList = new Array();
		bonusList = new Array();

		bg = dm.attach("mcBg",DP_BG)



		hero = new Hero(dm.attach("mcHero",DP_HERO))
		hero.x = Cs.mcw*0.5;
		hero.y = Cs.mch*0.5;

		inter = new Inter(dm.empty(DP_INTERFACE));
		inter.h = hero


		draw = dm.empty(DP_DRAW)
		stats = {
			$k:[0,0,0,0,0],
			$b:[]
		}

		lvl = 1

		initStep(1);

		if(FL_CHEAT){
			flCheatReady = true;
			initKeyListener();
		}

	}

	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}

	function onKeyPress(){
		if(flCheatReady){
			var n = Key.getCode();
			if(n>=96 && n<107 ){
				hero.updateSecondary(n-96)
			}
			if(n>=49 && n<54 ){
				hero.updateWeapon(n-49)
			}
			if(n>=54 && n<59 ){
				hero.updateSecondary(n-54)
			}
		}
		flCheatReady = false
	}

	function onKeyRelease(){
		flCheatReady = true;
	}

	function initStep(n){
		step = n
		switch(n){
			case 0:
				break;
			case 1:
				var mc = dm.attach("mcLevel",DP_INTERFACE)
				downcast(mc).txt = "secteur "+lvl

				flOption = true;
				genMonsters();
				break;
			case 2:
				lvl++;
				hero.wings[0].trg = 0
				hero.wings[1].trg = 0
				break;
			case 3 :
				scrollDash = 0
				scrollSpeed = 0
				dashLightList = new Array();
				break;
		}

	}

	function main() {
		draw.clear();

		// SPRITE
		var list = sList.duplicate();
		for( var i=0; i<list.length; i++ ){
			list[i].update();
		}

		switch(step){
			case 0:
				break;
			case 1: // PLAY
				hero.control();
				if(badsList.length==0 && bonusList.length==0 )initStep(2);
				break;
			case 2 :
				if(shotList.length==0)initStep(3);
				//Log.print(speed)
				//Log.setColor(0x000000)
				break;
			case 3 :
				var lim = 0.1
				hero.angle -= Cs.mm(-lim, hero.angle*0.2 ,lim)
				hero.root._rotation = hero.angle/0.0174
				var ca = Math.max(0,Math.cos(hero.angle));
				hero.mainFlameTrg = Math.max(0,ca*100)
				var center = {x:Cs.mcw*0.5,y:Cs.mch*0.5}
				hero.toward(center,0.1,3)
				var f = Math.pow( 0.9, Timer.tmod )
				hero.vx *= f;
				hero.vy *= f;
				scrollDash += Timer.tmod
				scrollSpeed = ca*Math.max( 20-hero.getDist(center), 0 )+scrollDash
				if(scrollDash>=100)initStep(4)
				scrollBg();
				updateDashLight();
				Cs.game.hero.launchSparks(0,Math.min(scrollSpeed*0.1,5),scrollSpeed*0.1);

				break;
			case 4:
				var center = {x:Cs.mcw*0.5,y:Cs.mch*0.5}
				hero.toward(center,0.1,3)
				scrollSpeed*=Math.pow(0.95,Timer.tmod)
				scrollBg();
				updateDashLight();
				Cs.game.hero.launchSparks(0,Math.min(scrollSpeed*0.1,5),scrollSpeed*0.1);
				if(dashLightList.length==0){
					initStep(1);

				}
				break;

		}


	}

	function genMonsters(){
		var dif = lvl*14 -8
		while(dif>0){
			if(Std.random(2)==0 ){
				var m = new bads.Asteroid(dm.attach("mcAsteroid",DP_BADS));
				var type = int(Math.min(Std.random( int(lvl*0.5) ),4));
				var max = Math.min( Math.pow(lvl-type,0.5),3 )
				var size = 2 + Std.random(int(max));
				m.setInfo(type,size);
				m.initStartPosition();
				dif -= m.dif;
			}
		}
	}


	//

	function scrollBg(){
		bg._x -= scrollSpeed
		if(bg._x<-900)bg._x+=900;
	}

	function spawnDashLight(){
		if(Std.random(2)==0)return;
		var mc = dm.attach("mcDashLight",DP_PARTS)
		mc._x = Cs.mcw+Math.random()*100
		mc._y = Math.random()*Cs.mch
		mc._yscale = 50+Math.random()*50
		mc._xscale = mc._yscale;

		downcast(mc).multi = 1+Math.random()*3
		dashLightList.push(mc)
	}

	function updateDashLight(){
		for(var i=0; i<int(scrollSpeed*0.1); i++ )spawnDashLight();
		for( var i=0; i<dashLightList.length; i++ ){
			var mc = dashLightList[i]
			mc._x -= scrollSpeed*(mc._yscale/100);
			mc._xscale = mc._yscale + Math.max( scrollSpeed-30, 0)*10*downcast(mc).multi
			mc._alpha -= 4*(mc._yscale/100)*Timer.tmod;
			if(mc._x<-mc._width || mc._alpha < 3 ){
				mc.removeMovieClip();
				dashLightList.splice(i--,1)
			}
		}
	}



//{
}









