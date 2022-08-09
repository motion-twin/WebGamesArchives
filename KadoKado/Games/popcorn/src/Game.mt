class Game {//}


	static var LIMIT = 290

	static var DP_BASE = 	0
	static var DP_BG = 	4
	static var DP_DECOR = 	5;
	static var DP_CORN = 	6;
	static var DP_PIOU = 	7;
	static var DP_PART = 	8;

	static var TOLERANCE = 30

	static var DEBUG = false;

	static var SCROLL_DECAL = -50

	var step:int;
	volatile var timer:float;
	volatile var flasher:float;
	var grey:float;

	var ly:float
	var glow:float
	var glowSpeed:float
	var scrollSpeed:float


	var dm:DepthManager;
	var gdm:DepthManager;

	var sList:Array<Sprite>;
	var gpList:Array<{>MovieClip,size:float}>;
	var cList:Array<Corn>;

	var map:MovieClip;
	var bg:MovieClip;
	var lim:MovieClip;
	var plan:Array<{>MovieClip,c:float}>
	var animator:Array<{>MovieClip,frame:float,fs:float,endType:int}>

	var lvl:flash.display.BitmapData;

	var hero:Hero;
	var boss:Boss;

	var focus:{y:float}
	var stats:{}



	function new(mc) {
		Log.setColor(0xFFFFFF)
		Cs.init();
		Cs.game = this
		gdm = new DepthManager(mc);
		bg = gdm.attach("bg",1);
		map = gdm.empty(2)

		dm = new DepthManager(map);
		sList = new Array();
		cList = new Array();
		animator = new Array();
		gpList = new Array();

		ly = Cs.HEIGHT-30
		scrollSpeed = 100

		initStep(0)
	}

	function initDecor(){

		// LIMIT
		lim = dm.attach("mcLimit",DP_DECOR)
		lim._y = Cs.HEIGHT - LIMIT
		//
		lvl = new flash.display.BitmapData(Cs.mcw,Cs.HEIGHT,true,0x00000000)
		dm.empty(DP_DECOR).attachBitmap(lvl,0)

		// BASE
		{
			var mc = dm.attach("mcCadre",DP_BASE)
			mc._y = Cs.HEIGHT-Cs.mch
			//Cs.draw(lvl,mc)
			mc.removeMovieClip();
		}

		// WALL
		/*
		for( var y=0; y<Cs.HEIGHT; y+=100 ){
			for( var n=0; n<2; n++ ){
				var mc = dm.attach("mcWall",DP_BASE)
				mc._xscale = -(n*2-1)*100
				mc._x = n*Cs.mcw
				mc._y = y
				mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
				Cs.draw(lvl,mc)
				mc.removeMovieClip();


			}
		}
		*/

		// PLAN
		plan = new Array();
		{	// FRONT

			for( var n=0; n<2; n++ ){
				var pl = downcast(gdm.empty(3))
				pl.c = 1.3
				var bmp = new flash.display.BitmapData(70,int(Cs.HEIGHT*pl.c),true,0x00000000)
				pl.attachBitmap(bmp,0)
				plan.push(pl)
				pl._x = n*Cs.mcw
				pl._xscale = -(n*2-1)*100
				for( var y=0; y<bmp.height; y+=100 ){
					if(Std.random(3)==0){
						var mc = dm.attach("mcFrontDecor",DP_BASE)
						mc._y = y
						mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
						var sc  = 50+Math.random()*50
						mc._xscale = sc
						mc._yscale = sc
						Cs.draw(bmp,mc)
						mc.removeMovieClip();
					}


				}
			}
		}

		{	// BACK
			var info = [
				{ c:0.5, link:"mcWall2" },
				{ c:1,	 link:"mcWall" },

			]
			for( var i=0; i<2; i++ ){
				for( var n=0; n<2; n++ ){
					var pl = downcast(gdm.empty(1))
					pl.c = info[i].c
					var h = int(Cs.HEIGHT*pl.c)+Cs.mch
					var bmp = new flash.display.BitmapData(50,h,true,0x00000000)
					pl.attachBitmap(bmp,0)
					plan.push(pl)
					pl._x = n*Cs.mcw
					pl._xscale = -(n*2-1)*100
					for( var y=0; y<h; y+=100*pl.c ){
						var mc = dm.attach(info[i].link,DP_BASE)
						mc._xscale = 100*pl.c
						mc._yscale = 100*pl.c
						mc._y = y
						mc.gotoAndStop(string(Std.random(mc._totalframes)+1))
						Cs.draw(bmp,mc)
						mc.removeMovieClip();
					}
				}

			}

		}

		/*

		*/

		initStep(1)
	}

	function initStep(s:int){
		step = s;

		switch(step){
			case 0: //
				initDecor();
				break;
			case 1:	//
				initKeyListener();

				hero = new Hero(null);
				hero.bouncer.setPos(Cs.mcw*0.5,Cs.HEIGHT-20);

				boss = new Boss(null)
				boss.y = Cs.HEIGHT - 320
				map._y = - Cs.HEIGHT+Cs.mch

				focus = upcast(hero);


				break;
			case 9: // ENDGAME
				if(hero.jumpPower!=null)hero.releaseJump();
				timer = 8
				break


		}




	}

	//
	function main() {

		//if(Key.isDown(107))Timer.tmod = 10;
		//if(Key.isDown(109))Timer.tmod = 0.3;
		if(hero.jumpPower!=null)Timer.tmod = 0.2;
		timer-=Timer.tmod;
		switch(step){
			case 0: //
				break;
			case 1:


				//Log.print(ly+" < "+yLim)
				var yLim = Cs.HEIGHT-LIMIT
				if( ly < yLim){
					for( var x=0; x<Cs.mcw; x+=3 ){
						if( !isFree(x,yLim) ){
							Cs.game.focus = {y:yLim};
							Cs.game.initStep(9);
						}
					}
				}


				break;
			case 9:
				endPart();


				if(timer<0){
					KKApi.gameOver(stats);
					initStep(10)
				}
				break;
			case 10:
				endPart();
				break;

		}
		//
		updateScroll();
		updateAnimator();
		updateScreenEffect();
		// SPRITES
		var list = sList.duplicate();
		for( var i=0; i<list.length;i++){
			list[i].update();
		}
		//



	}

	function endPart(){
		var list = new Array();
		var yLim = Cs.HEIGHT-LIMIT
		for( var x=0; x<Cs.mcw; x+=3 ){
			if( !isFree(x,yLim) )list.push(x);
		}
		for( var i=0; i<3; i++ ){
			var p = newPart("partLight");
			p.x = list[Std.random(list.length)]
			p.y = yLim
			p.weight = -(0.1+Math.random()*0.5)
			p.timer = 10+Math.random()*10
			p.setScale(100+Math.random()*150)
			p.vy = -1
		}

	}

	function setScore(x,y,score,scale){
		if(Cs.game.step!=10){
			var mc = downcast( Cs.game.dm.attach("mcScore",Game.DP_PART) )
			mc._x = x;
			mc._y = y;
			mc._xscale = scale;
			mc._yscale = scale;
			mc.score = KKApi.val(score);
			Cs.cellShadeMc(mc,0x000000,2);
			KKApi.addScore(score);
		}
	}

	function updateAnimator(){
		for( var i=0; i<animator.length; i++){
			var mc = animator[i]
			mc.frame += mc.fs*Timer.tmod
			if( mc.frame > mc._totalframes ){
				mc.removeMovieClip()
				animator.splice(i--,1)
			}else{
				mc.gotoAndStop(string(int(mc.frame)+1))
			}
		}
	}

	function newPart(link){
		var p  = new Part(dm.attach(link,DP_PART));
		return p;
	}

	function newDebris(x,y){
		var color = lvl.getPixel32(int(x),int(y))
		if( !isBg(color) ){
			var p = newPart("mcDebris")
			p.x = x;
			p.y = y;
			p.setScale(50+Math.random()*80)
			p.timer = 10+Math.random()*10
			p.fadeType = 0
			p.weight = 0.1+Math.random()*0.1
			p.frict = 0.98
			Cs.setColor(p.root, color ,-255)
			return p;
		}
		return null;
	}

	// FX
	function updateScreenEffect(){
		if( flasher!=null){
			var prc = flasher
			if(prc<5){
				prc = 0
				flasher = null;
			}
			Cs.setPercentColor(dm.root_mc,prc,0xFFFFFF)
			if(flasher!=null)flasher-= (110-flasher)
		}

		if(grey!=null){
			var c = 0
			if( hero.jumpPower!=null ){
				grey = Math.min(grey+(105-grey)*0.2,100)
			}else{
				grey = Math.max(grey-(120-grey)*0.5,0)
			}
			c = grey/100

			var m = []
			for( var i=0; i<Cs.CM_STD.length; i++ ){
				m[i] = Cs.CM_GREY[i]*c + Cs.CM_STD[i]*(1-c)
			}

			if( grey==0 ){
				grey = null;
				while(gpList.length>0)gpList.pop().removeMovieClip();
				Manager.root_mc.filters = []
			}else{
				var fl = new flash.filters.ColorMatrixFilter();
				/*
				glow = Cs.mm(0,glow+glowSpeed*Timer.tmod,255)
				glowSpeed -= 100*Timer.tmod;
				if( glow<100 && Math.random()*25<1){
					glowSpeed = 50+Math.random()*100
				}
				*/
				//fl.matrix= Cs.getGreyMatrix(30+glow+Math.random()*30);
				//fl.matrix= Cs.getAlmostGreyMatrix(30+glow+Math.random()*10);


				var  glow = 0;
				if(hero.jumpPower!=null)glow = (1-c)*160
				fl.matrix= Cs.getGreyMatrix(30+glow+Math.random()*15);
				Manager.root_mc.filters = [fl]
				//Log.print(glow)
				//Log.print(c)
			}


			var margin = 10
			for( var i=0; i<gpList.length; i++ ){
				var mc = gpList[i];
				mc._y -= 5*mc.size + (1-c)*50
				if(mc._y<-margin){
					mc._y += Cs.mch+2*margin
				}
			}


		}
	}

	function initGrey(){
		if(grey==null){
			grey = 0;
			glow = 0;
			glowSpeed = 0
			var max = 12/Timer.tmod;
			for( var i=0; i<max; i++ ){
				var mc = downcast(gdm.attach("partLight",10));
				mc._x = Math.random()*Cs.mcw
				mc._y = Math.random()*Cs.mch
				mc.size = 0.2+Math.random()*0.8
				mc._xscale = 50+mc.size*100
				mc._yscale = mc._xscale
				if(i%2==0)mc.gotoAndPlay("2");
				gpList.push(mc)
			}
		}
	}

	// SCROLL
	function updateScroll(){

		var dy = Cs.mm( -(Cs.HEIGHT-Cs.mch), Cs.mch*0.5-(focus.y+SCROLL_DECAL), 0) - map._y
		var lim = Math.min( Math.abs(dy), scrollSpeed )
		map._y  += Cs.mm(-lim,dy*0.2*Timer.tmod,lim)

		//
		for( var i=0; i<plan.length; i++ ){
			var mc = plan[i]
			mc._y = map._y*mc.c
		}

	}

	// GEN
	function genPopcorn(x,y){
		var sp = new Corn(null)
		sp.x = x
		sp.y = y
		//sp.bouncer.setPos(x,y)
		return sp;
	}

	// LEVEL
	function isFree(x,y){
		if(x<0 || x>=Cs.mcw || y>=Cs.HEIGHT)return false;
		var m = Cs.MARGIN
		return isBg(lvl.getPixel32(int(x),int(y)))
	}

	function isBg(col){
		var pc = Cs.colToObj32(col)
		return pc.a <= TOLERANCE
	}

	// KEYS
	function initKeyListener(){
		var kl = {
			onKeyDown:callback(this,onKeyPress),
			onKeyUp:callback(this,onKeyRelease)
		}
		Key.addListener(kl)

	}

	function onKeyPress(){

		var n = Key.getCode();

		if(n>=96 && n<107 ){

		}
		if(n>=49 && n<52 ){
		}
		if(n>=52 && n<55 ){

		}

		switch(n){
			case Key.SPACE:
				hero.action()
				break;
			case Key.ENTER:
				//boss.hit();
				break;
		}


	}

	function onKeyRelease(){

	}

	//
	function getRandomPos(){
		return {
			x:int(Cs.MARGIN + Math.random()*(Cs.mcw-2*Cs.MARGIN))
			y:int(Cs.MARGIN + Math.random()*(Cs.mch-2*Cs.MARGIN))
		}
	}


//{
}








