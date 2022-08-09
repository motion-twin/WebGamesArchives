import KKApi;
import Protocole;
import mt.bumdum.Lib;
import mt.bumdum.Sprite;

enum Step {
	Trans;
	Play;
	GameOver;
	Editor;
}

typedef Plan = {>flash.MovieClip,coef:Float};

class Game {//}

	#if prod
		public static var FL_TEST = 	false;
	#else
		public static var FL_TEST = 	true;
		public static var FL_EDITOR = 	false;
	#end


	var step:Step;

	public static var DP_MASK = 		9;
	public static var DP_FX = 		8;
	public static var DP_SCORE = 		7;
	public static var DP_PROJECTILES = 	6;
	public static var DP_ENT = 		4;
	public static var DP_BONUS = 		3;
	public static var DP_LEVEL = 		2;
	public static var DP_TOWER = 		1;
	public static var DP_BG = 		0;

	public static var FLOOR = 4;
	public static var START_X = 4;
	public static var START_Y = 17;

	public static var LEVELS_ENCRYPTED = haxe.Resource.getString("Levels.data");

	var lvl:mt.flash.Volatile<Int>;
	var rlvl:mt.flash.Volatile<Int>;
	var flGameOver:Bool;
	var flZoom:Bool;
	var levels:Array<Array<Int>>;
	var levelOrder:Array<Int>;
	public var tags:mt.flash.PArray<Bool>;

	var coef:Float;

	public var gry:Float;

	public var hero:Hero;
	var grid:Array<Array<Square>>;
	public var monsters:mt.flash.PArray<Mon>;
	public var ents:Array<Ent>;

	public var focus:Ent;

	public var mcLevel:flash.MovieClip;
	public var bmpLevel:flash.display.BitmapData;

	public static var me:Game;
	public var mdm:mt.DepthManager;
	public var dm:mt.DepthManager;
	public var map:flash.MovieClip;
	public var root:flash.MovieClip;
	public var bg:flash.MovieClip;
	public var mcTowerMask:flash.MovieClip;


	public var timestamp:Float;
	public var playInfo:{_k:Array<Int>,_g:Array<Int>,_t:Array<Int>,_b:Array<Int>,_lm:Int};

	// DEBUG
	public var markers:Array<flash.MovieClip>;
	public var mcTracer:flash.MovieClip;



	public function new( mc : flash.MovieClip ){


		haxe.Log.setColor(0xFFFFFF);

		root = mc;
		me = this;

		mdm = new mt.DepthManager(root);
		map = mdm.empty(1);
		dm = new mt.DepthManager(map);

		initBg();

		lvl = 0;
		rlvl = 0;
		tags = new mt.flash.PArray();
		//for( i in 0...7 )tags.push(i!=0);
		for( i in 0...Cs.DIAMS )tags.push(false);


		timestamp = 0;
		playInfo  = {
			_k:[0,0,0,0,0,0,0],
			_g:[0,0,0,0,0,0,0,0],
			_t:[0,0,0,0,0,0,0,0],
			_b:[0,0],
			_lm:0,
		}


		ents = [];
		monsters = new mt.flash.PArray();
		markers = [];


		flZoom = false;
		initScroll();

		// LEVELS
		var str = StringTools.urlDecode(LEVELS_ENCRYPTED);
		if( str.length > 0 ){
			var o = new mt.PersistCodec();
			levels = o.decode(str);
		}else{
			trace("NO LEVEL");
			levels = [];
		}


		var a = [];
		for( i in 0...10 )a.push(i+3);
		levelOrder = [];
		while(a.length>0){
			var coef = Math.min( 0.5+levelOrder.length*0.2, 1 );
			var index = Std.random( Math.ceil(a.length*coef));
			levelOrder.push(a[index]);
			a.splice(index,1);
		}
		levelOrder.unshift(Std.random(3));



		#if prod
			toggleZoom();
			initGame();
		#else
			if( FL_EDITOR ){
				initEditor();
			}else{
				toggleZoom();
				initGame();
			}
		#end

		mcTracer = dm.empty(10);
		root._quality = "low";

		initInter();


	}


	//
	public function update(){

		#if prod
		#else
		viewGrid();
		cleanMarkers();
		mcTracer.clear();
		#end

		//timestamp += mt.Timer.tmod;



		switch(step){
			case Play : 		updatePlay();
			case Trans :		updateTrans();
			#if editor
			case Editor :		updateEditor();
			#end
			default:
		}


		/*
		for( i in 0...30000 ){
			var a = 40*5.6;
		}
		*/

		updateInter();
		updateSprites();


		if( monsters.cheat || tags.cheat )KKApi.flagCheater();

		/*
		haxe.Log.clear();
		trace(lvl);
		trace(rlvl);
		*/



	}
	public function updateSprites(){

		var a = Sprite.spriteList.copy();
		for( sp in a )sp.update();
	}

	// GAME
	function initGame(){

		hero = new Hero();
		hero.root._x = Cs.mcw*Math.random();
		hero.root._y = Cs.mch*Math.random();
		initTrans();
		coef = 1;

		//hero.moveTo(7,Cs.YMAX-2);
	}

	// TRANS
	var ttw:Tween;
	var flSwapLevel:Bool;
	var transDec:Float;
	var opx:Float;
	var opy:Float;
	var wind:Array<Plan>;

	function initTrans(){
		step = Trans;
		hero.state = null;
		coef = 0;
		hero.playAnim("jump");

		transDec = Cs.mcw*2 + 50;

		ttw = new Tween();
		ttw.sx = hero.root._x;
		ttw.sy = hero.root._y;
		ttw.ex = transDec + Cs.getX( START_X + 0.5 );
		ttw.ey = Cs.getY( START_Y+0.5 );

		flSwapLevel = false;


		// FX
		/*	// SYSTEME DE PARITCULES VENT
		wind= [];
		var max = 8;
		for( i in 0...max ){
			var mc:Plan = cast mdm.attach("partWind",1);
			mc._x = Math.random()*Cs.mcw;
			mc._y = Math.random()*Cs.mch;
			mc.coef = 0.5+i/max * 1.5;
			mc._xscale = 0;
			wind.push(mc);
		}
		//*/


	}
	function updateTrans(){


		coef = Math.min(coef+0.012,1);

		if( coef > 0.5 && !flSwapLevel )decale();


		var p = ttw.getPos(coef);
		p.y -= Math.sin(coef*3.14)*150;
		hero.root._x = p.x;
		hero.root._y = p.y;

		if( Math.isNaN(opx) || opx == null ){
			opx = p.x;
			opy = p.y;
		}
		var vx = p.x - opx;
		var vy = p.y - opy;

		if( Math.isNaN(vx) )trace(opx);


		updateScroll();

		mcTowerMask._visible = hero.root._x > Cs.mcw || hero.root._x < 0;

		// CASSE BRIQUE
		var px = Cs.getPX(hero.root._x);
		var py = Cs.getPY(hero.root._y);
		var sq = Game.me.grid[px][py];
		if(sq.type==BLOCK ||sq.type==PLAT){
			var c = 1;
			explodeSquare(px,py,vx*c,vy*c);
		}

		// START
		if( coef == 1 ){
			endTrans();
			return;
		}

		// ENTS
		var a = ents.copy();
		for( e in a ){
			if(e.type==PART)e.update();
		}

		// SPARK
		hero.fxSpark();

		//
		var rot = Math.atan2(vy,vx)/0.0174;
		var dist = Math.sqrt(vx*vx+vy*vy)*3;
		if( !Math.isNaN(vx) ){
			for( mc in wind ){
				mc._x = Num.sMod(mc._x+vx*mc.coef,Cs.mcw);
				mc._y = Num.sMod(mc._y+vy*mc.coef,Cs.mch);
				mc._rotation = rot;
				mc._xscale = dist*mc.coef * Math.sin(coef*3.14) ;
			}
		}


		//
		opx = p.x;
		opy = p.y;



	}
	function decale(){

		for( e in ents )e.setPos(e.root._x-transDec,e.root._y);
		for( sp in Sprite.spriteList )sp.x -= transDec;
		loadLevel(levelOrder[lvl]);
		opx -= transDec;
		ttw.sx -= transDec;
		ttw.ex -= transDec;
		flSwapLevel = true;
		initEnemies();

		updateLevelInfo();

		hero.playAnim("jumpDown");


	}
	function endTrans(){
		initPlay();
		hero.playAnim("land");
		hero.initStand();
		hero.moveTo(START_X,START_Y);
		hero.blast(30,0,Cs.CS);

		while(wind.length>0)wind.pop().removeMovieClip();

	}

	// PLAY
	var chrono:mt.flash.Volatile<Int>;
	var gorilla:mt.flash.Volatile<Int>;
	function initPlay(){
		gorilla = 0;
		chrono = 2000;
		if(lvl==0)chrono += 4000;
		if(lvl==1)chrono += 2000;
		//chrono = 50;	// HACK
		step = Play;
	}
	function updatePlay(){

		if(hero!=null){

			// CHONO
			if( chrono-- == 0 )newGorilla();

			// END LEVEL

			if( !hero.flEndLevelOk && monsters.length-gorilla ==0 ){
				fxScore(hero.root._x,hero.root._y-15,Cs.SCORE_FINISH);
				hero.flEndLevelOk = true;
			}

			//if(  !hero.flEndLevelOk && flash.Key.isDown(flash.Key.ENTER) && FL_TEST ) 	hero.flEndLevelOk = true;
			if(  !hero.flEndLevelOk && flash.Key.isDown(flash.Key.ENTER) && FL_TEST ) 	chrono = 1;

		}

		var a = ents.copy();
		for( e in a )e.update();

		updateScroll();
	}
	public function endLevel(){
		var a = ents.copy();
		for( e in a){
			if(e.type!=HERO)e.kill();
		}
		lvl++;
		rlvl++;
		initTrans();
	}

	// ENNEMIES
	function initEnemies(){
		var a = [];
		var dxlim = 3;
		if(lvl>0)dxlim = 0;

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var sq = Game.me.grid[x][y];
				var gr = Game.me.grid[x][y+1];
				if( sq.type == EMPTY && isGround(gr.type) ){
					var dx = Math.abs(x -START_X);
					if( y != START_Y || dx > dxlim  )a.push(sq);
				}
			}
		}

		var max = 2+lvl*4;
		for( i in 0...max ){
			var index = Std.random(a.length);
			var sq = a[index];
			a.splice(index,1);
			var m = new Mon();
			m.setType(Standard);
			if(lvl>0 && i%3==0)m.setType(Soldat);
			if(lvl>1 && i%4==0)m.setType(Heavy);
			if(lvl>1 && i%5==0)m.setType(Sapper);
			if(lvl>2 && i%6==0)m.setType(Ninja);

			//m.setType(Heavy);
			//m.setType(Ninja);

			m.moveTo(sq.x,sq.y);
			m.ox = 0.3+Math.random()*0.4;
			//m.moveTo(START_X,START_Y);
			m.playAnim("stand");
			m.updatePos();

		}


		ents.remove(Game.me.hero);
		ents.push(Game.me.hero);
		dm.over(Game.me.hero.root);

	}
	function newGorilla(){
		var m = new Mon();
		m.setType(Gorilla);
		m.moveTo(-5,START_Y);
		m.setSens(1);
		m.jump();
		m.vx = 7;
		m.vy = -6;
		m.flDestructor = true;

		m.updatePos();
		chrono = 1500;
		gorilla++;
	}

	// LEVEL
	var tower:flash.MovieClip;

	function loadLevel(n){


		// BASE
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				var o = {
					type:(x==0||y==0||x==Cs.XMAX-1||y==Cs.YMAX-1)?BLOCK:EMPTY,
					ent:[],
					ladder:false,
					x:x,
					y:y,
				}
				grid[x][y] = o;

			}
		}

		// MODEL
		var model = levels[n];

		if( model != null ){
			var id = 0;
			var ec = 3;
			for( n in model ){
				var x = Std.int(id/Cs.XMAX);
				var y = id%Cs.YMAX;
				grid[x][y] = {
					type :		[EMPTY,BLOCK,PLAT][n%ec],
					ladder :	n>=ec,
					ent :		[],
					x:x,
					y:y,
				}
				id++;
			}
		}else{  // CUSTOM
			for( i in 0...6 )grid[5+i][13].type = BLOCK;
			for( i in 0...6 )grid[10+i][11].type = BLOCK;
			grid[10][12].type = BLOCK;
			for( i in 0...6 )grid[15][10-i].ladder = true;

			for( i in 0...12 )grid[4+i][5].type = BLOCK;

			for( i in 0...4 )grid[14+i][14].type = BLOCK;
			for( i in 0...3 )grid[12+i][15].type = BLOCK;

			for( i in 0...5 )grid[1+i][16].type = PLAT;
		}

		// DRAW
		drawLevel();


	}
	function drawLevel(){

		if(mcLevel==null){
			mcLevel = dm.empty(DP_LEVEL);
			bmpLevel = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
			mcLevel.attachBitmap(bmpLevel,0);
		}

		var seed = new mt.Rand(lvl);


		bmpLevel.fillRect(bmpLevel.rectangle,0);
		var mc = dm.attach("mcSquare",0);
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var sq = grid[x][y];
				mc.gotoAndStop( Type.enumIndex(sq.type)+1 );
				cast(mc).ladder._visible = sq.ladder;
				var m = new flash.geom.Matrix();
				m.translate(Cs.getX(x),Cs.getY(y));
				Cs.randomize(mc.smc);
				Col.setColor(mc.smc,0,-30);
				bmpLevel.draw(mc,m);
			}
		}
		mc.removeMovieClip();
	}

	var bmpTower:flash.display.BitmapData;
	function initBg(){

		// CIEL
		var model = mdm.attach("mcBg",0);
		bg = mdm.empty(DP_BG);
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x00FF00);
		bg.attachBitmap(bmp,0);
		bmp.draw(model);
		var ec = 15;
		var max = Math.ceil(Cs.mch/ec);
		for( i in 0...max ){
			var rect = new flash.geom.Rectangle(0,i*ec,Cs.mcw,ec);
			var col = bmp.getPixel(0,Std.int((i+0.5)*ec));
			bmp.fillRect(rect,col);
		}
		model.removeMovieClip();

		// DRAW BG
		var sc = 0.5;
		var bg = dm.empty(DP_BG);
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0);
		bg.attachBitmap(bmp,0);
		var brush = dm.attach("mcTiles",0);
		brush.stop();
		var ec = 10;
		var max = Math.ceil(Cs.mcw/ec);
		for( x in 0...max ){
			for( y in 0...max ){
				var m = new flash.geom.Matrix();
				m.translate(x*ec,y*ec);
				brush.smc.gotoAndStop(Std.random(brush.smc._totalframes)+1);
				bmp.draw(brush,m);
			}
		}
		brush.removeMovieClip();

		// TOWER
		var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0x440000);
		var mc = dm.attach("mcSquare",0);
		mc.gotoAndStop(2);
		cast(mc).ladder._visible = false;
		mc.stop();
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var m = new flash.geom.Matrix();
				m.translate(Cs.getX(x),Cs.getY(y));
				Cs.randomize(mc.smc);
				bmp.draw(mc,m);
			}
		}
		mc.removeMovieClip();
		bmpTower = bmp;

			// FENETRE
			var mc = dm.attach("mcWindow",0);
			var xmax = 5;
			var ymax = 4;
			var ecx = (Cs.mcw - xmax*26)/(xmax+1);
			var ecy = (Cs.mch - ymax*40)/(ymax+1);
			for( x in 0...xmax ){
				for( y in 0...ymax ){
					var m = new flash.geom.Matrix();
					m.translate(ecx+x*(26+ecx), ecy+y*(40+ecy));
					bmp.draw(mc,m);
				}
			}
			mc.removeMovieClip();


			// ETAGE
			for( i in 0...3 ){
				var dp = (i==1)?DP_MASK:DP_TOWER;
				var mc = dm.empty(dp);
				mc._x = 0;
				mc._y = (i-1)*Cs.mch;
				mc.attachBitmap(bmp,0);
				if( i == 1 )mcTowerMask = mc;
			}




		// GROUND
		gry = FLOOR*Cs.mch;


	}

	// FALL
	public function initFall(){



		// TOWER
		for( i in 0...FLOOR-2 ){
			var mc = dm.empty(DP_TOWER);
			mc._x = 0;
			mc._y = (i+2)*Cs.mch;
			mc.attachBitmap(bmpTower,0);
		}

		//
		var side = Game.me.hero.px<=0?0:1;
		var mc = dm.attach("mcGround",DP_TOWER);
		mc._x = side*Cs.mcw;
		mc._y = gry;
		mc._xscale = -(side*2-1)*100;



	}

	// GAMEOVER
	public function initGameOver(){
		//step = GameOver;
		root._quality = "high";
		KKApi.gameOver(playInfo);
		coef = 0;

	}
	function updateGameOver(){

		updateScroll();

	}

	// ZOOM
	var zoom:Float;
	public function toggleZoom(){
		flZoom = !flZoom;
		if(flZoom){
			zoom = 2;
			map._xscale = map._yscale = 100*zoom;
		}else{
			zoom = 1;
			map._xscale = map._yscale = 100;
			map._x = 0;
			map._y = 0;
		}


	}

	// SCROLL
	var plans:Array<Plan>;
	var pvx:Float;
	function initScroll(){

		plans = [];
		var coef = [0.2,0.5];
		for( i in 0...2 ){
			var mc:Plan = cast mdm.attach("mcScrolling",0);
			mc._y = Cs.mch;
			mc._xscale = mc._yscale = 200;
			mc.gotoAndStop(i+1);
			mc.coef = coef[i];
			plans.push(mc);
			if( i == 0 )Col.setPercentColor(mc,50,0xDD00DD);
		}

	}
	public function updateScroll(){
		if(flZoom){


			var p = focus.getPos();
			var mw = Cs.mcw*zoom;
			var mh = Cs.mch*zoom;

			//map._x = Num.mm( Cs.mcw-mw, Cs.mcw*0.5-p.x*zoom, 0) ;
			//map._y = Num.mm( Cs.mch-mh, Cs.mch*0.5-p.y*zoom, 0) ;


			var lim = gry - 50;
			if( p.y > lim )p.y = lim;

			var vx = Cs.mcw*0.5-p.x*zoom - map._x;
			var vy = Cs.mch*0.5-p.y*zoom - map._y;

			map._x += vx;
			map._y += vy;



			// SHAKE
			if( shake!=null ){
				if(shakeTimer--<0){
					shakeTimer = 1;
					shake *= 0.5;
					map._y += shake*shakeSens;
					shakeSens *= -1;
					if( Math.abs(shake) < 1 )shake = null;
				}
			}


			// SCROLL
			var by = gry - hero.root._y;

			if(Math.abs(vx)>100)vx = pvx;
			var bdy = Cs.mch*0.5+106;
			for( mc in plans ){
				//if(Math.abs(vx)<100)mc._x = Num.sMod(mc._x+vx*mc.coef,480);
				mc._x = Num.sMod(mc._x+vx*mc.coef,480);
				mc._y = bdy + by*mc.coef*0.5;
				if( mc._y < bdy )mc._y = bdy;

			}
			pvx = vx;


		}


	}

	// INTER
	var mcInter:{>flash.MovieClip,dm:mt.DepthManager,level:flash.MovieClip};
	var gemTimer:Int;
	var gemStep:Int;
	public function initInter(){
		mcInter = cast mdm.empty(5);
		mcInter.dm = new mt.DepthManager(mcInter);
		mcInter._y = Cs.mch;
		mcInter._y = 19;
		mcInter._xscale = mcInter._yscale = 200;

		// LIFE BAR
		var mc = mcInter.dm.attach("mcLifeBar",0);
		mc._x = 1;
		mc._y = -2;

		// LEVEL
		var mc = mcInter.dm.attach("mcLevel",0);
		mc._x = 44;
		mc._y = -9;
		mcInter.level = mc;

		updateGems();
		updateLifeBar();

	}
	public function updateLifeBar(){
		mcInter.dm.clear(3);
		var max = Std.int(hero.life);
		if(hero==null)max = 0;
		for( i in 0...max ){
			var mc = mcInter.dm.attach("mcLifePoint",3);
			mc._x = 5 + i*3;
			mc._y = -7;
		}
	}
	function updateLevelInfo(){
		mcInter.level.smc.gotoAndStop(lvl+2);
	}
	public function updateGems(?index){
		var flAll = true;
		var a = tags;
		if( gemStep!=null){
			a = new mt.flash.PArray();
			flAll = false;
			for( i in 0...Cs.DIAMS )a[i] = gemStep <= i;
		}

		mcInter.dm.clear(4);

		for( i in 0...Cs.DIAMS ){
			var mc = mcInter.dm.attach("mcGem",4);
			var p = getGemPos(i);
			mc._x = p.x;
			mc._y = p.y;
			var fr = i+1;
			if( gemStep == 0 )fr=(fr+gemTimer)%Cs.DIAMS + 1;
			mc.gotoAndStop(a[i]?fr:11);
			if( i!=index || gemStep!=null )mc.smc.gotoAndStop(mc.smc._totalframes);
			if(!a[i])flAll = false;
		}
		if( flAll ){
			tags = new mt.flash.PArray();
			gemTimer = 50;
			gemStep = 0;
		}

	}
	function getGemPos(i){
		return { x:88 + i*8,y:-5};
	}


	function updateInter(){
		if( gemTimer != null){
			//if(gemStep==0)Col.setColor(hero.root,Cs.RAINBOW[gemTimer%Cs.RAINBOW.length]);
			if( gemTimer-- < 0 ){
				// FX
				var max = 16;
				var cr = 3;
				for( i in 0...max){
					var mc = mcInter.dm.attach("mcBlinkPix",5);
					Col.setColor(mc.smc,Cs.RAINBOW[gemStep]);
					Cs.randomize(mc);
					mc.play();

					//var a = i/max * 6.28;
					//var speed = 1+Math.random();
					var p = new mt.bumdum.Phys(mc);
					var pos = getGemPos(gemStep);
					//p.vx = Math.cos(a)*speed;
					//p.vy = Math.sin(a)*speed - 1;
					//p.vx = 0;
					//p.vy = 0;
					//p.x = pos.x + p.vx*cr;
					//p.y = pos.y + p.vy*cr;
					p.x = pos.x + Std.random(9)-4;
					p.y = pos.y + Std.random(9)-4;
					p.fadeType = 1;
					p.timer = 10 + Std.random(10);
					p.weight = 0.1+Math.random()*0.1;
					p.frict = 0.8;

				}

				// SCORE
				var hp = hero.getPos();
				if(gemStep==0){
					fxScore(hp.x,hp.y,Cs.SCORE_ALL_GEM);
					//Col.setColor(hero.root,0);
				}

				//
				gemStep++;
				gemTimer = 5;
				if( gemStep == Cs.DIAMS){
					gemStep = null;
					gemTimer = null;
				}
			}
			updateGems();
		}

	}


	// LEVEL
	public function explodeSquare(px,py,vx=0.0,vy=0.0){
		var sq = Game.me.grid[px][py];
		if( sq.type == EMPTY )return;
		var x = Std.int(Cs.getX(px));
		var y = Std.int(Cs.getY(py));
		bmpLevel.fillRect(new flash.geom.Rectangle(x,y,Cs.CS,Cs.CS),0);


		switch(sq.type){
			case BLOCK :

				for( i in 0...12 ){
					var p = newSquarePart(px,py,4,vx,vy);
				}
				var max = 1+Std.random(2);
				for( i in 0...max ){
					var p = newSquarePart(px,py,4,vx,vy,"partBrick");
					p.root.gotoAndStop(i+1);
					p.vr = (Math.random()*2-1)*8;
					p.ray = 0.15;
					Col.setColor(p.root,0,-30);
					p.fadeType = 0;
					p.fadeLimit = 15;
					p.timer += 30;
					p.groundFrict = 0.75;
				}
			case PLAT :
				var impact = 4;
				for( i in 0...5 ){
					var p = newSquarePart(px,py,4,vx,vy,"partWood");
					p.root.gotoAndStop(i+1);
					p.vr = (Math.random()*2-1)*8;
					p.ray = 0.15;
					Col.setColor(p.root,0,-30);
					p.fadeType = 0;
					p.fadeLimit = 15;
					p.timer += 30;
					p.groundFrict = 0.75;

				}
			default:

		}
		//
		fxShake(10);
		//
		sq.type = EMPTY;
		sq.ladder = false;
	}
	public function newSquarePart(px,py,impact,vx:Float,vy:Float,?link){
		var p = newShard(link);
		p.moveTo(px,py);
		p.ox = Math.random();
		p.oy = Math.random();
		p.vx = (Math.random()*2-1)*impact + vx*Math.random() ;
		p.vy = (Math.random()*2-1)*impact + vy*Math.random() ;
		return p;

	}


	// FX
	var shake:Float;
	var shakeTimer:Int;
	var shakeSens:Int;
	public function fxShake(shakeAmount){
		if(step==Trans)return;
		shake = shakeAmount;
		shakeTimer = 0;
		shakeSens = 1;
	}
	public function fxBrickDust(sq:Square,sx,sy){

		var ox = 0.5 + sx*0.4;
		var oy = 0.5 + sy*0.4;



		var impact = 3;
		var max = Std.int(3+impact*2);

		for( i in 0...max ){

			if(sx==0)ox = Math.random();
			if(sy==0)oy = Math.random();
			var p = newShard();
			p.moveTo(sq.x,sq.y);
			p.ox = ox;
			p.oy = oy;
			p.vx = (Math.random()*2-1)*impact;
			p.vy = (Math.random()*2-1)*impact;
			p.frict = 0.97;
			p.updatePos();
		}
	}
	public function fxScore(x:Float,y:Float,sc:KKConst){

		KKApi.addScore(sc);
		if( KKApi.val(sc) < 200 )return;

		var root = dm.empty(DP_SCORE);
		var score = Std.string(KKApi.val(sc));
		var dm = new mt.DepthManager(root);
		var ec = 4;
		var id = 0;
		var dx = -Std.int(score.length*ec*0.5);
		while(score.length>0){
			var ch = score.charAt(0);
			score = score.substr(1,score.length);
			var mc = dm.attach("mcNum",0);
			mc.gotoAndStop(Std.parseInt(ch)+1);
			mc._x = id*ec + dx ;
			mc._y = -3 ;
			id++;
		}


		var p = new mt.bumdum.Phys(root);
		p.x = x;
		p.y = y;
		p.weight = -0.1;
		p.timer = 30;
		p.frict = 0.7;
		p.fadeType = 1;

	}
	public function fxAttach(link,x:Float,y:Float){
		var mc = dm.attach(link,DP_FX);
		mc._x = x;
		mc._y = y;
		return mc;
	}
	function newShard(link="fxBrickDust"){
		var p = new Part(dm.attach(link,DP_FX));
		p.initPhys();
		p.weight = 0.1+Math.random()*0.1;
		p.timer = 30+Math.random()*50;
		p.ray = 0.01;
		p.bounceFrict = 0.5;
		p.groundFrict = 0.9;
		Cs.randomize(p.root);
		return p;
	}
	public function fxFlash(fr){
		var mc = mdm.attach("mcFlash",12);
		mc.smc.gotoAndStop(fr);
	}
	// GET
	public function getSq(px,py){
		var base=
		if( px<0 || px>=Cs.XMAX ) 	return {type:EMPTY,ladder:false,ent:[],x:px,y:py};
		if( py<0 || py>=Cs.YMAX ) 	return {type:BLOCK,ladder:false,ent:[],x:px,y:py};
		return grid[px][py];

	}

	// IS
	public function isGround(t){
		return t == BLOCK || t == PLAT;
	}
	public function isJumpFree(px,py){
		var type = grid[px][py].type;
		return type == EMPTY || type == PLAT ;
	}
	public function isFree(px,py){
		var type = grid[px][py].type;
		return type == EMPTY || type == PLAT ;
	}

	public function isHangable(px,py){
		var type = grid[px][py].type;
		return type == PLAT ;
	}

	#if prod
	#else

	// EDITOR
	var layer:Int;
	var flClick:Bool;
	var mcCursor:flash.MovieClip;

	function initEditor(){
		step = Editor;

		loadLevel(0);

		// MOUSE LISTENER
		var ml = {};
		Reflect.setField( ml, "onMouseDown", function(){me.flClick = true;} );
		Reflect.setField( ml, "onMouseUp", function(){me.flClick = false;} );
		flash.Mouse.addListener( cast ml );
		// KEY LISTENER
		var kl = {};
		Reflect.setField( kl, "onKeyDown", pushKey );
		flash.Key.addListener( cast kl );

		//
		mcCursor = dm.attach("mcCursor",10);
		Filt.glow(mcCursor,2,4,0);
		//
		layer = 0;
		updateLevelInfo();
		//
		mcTowerMask._visible = false;
	}
	function pushKey(){
		var n = flash.Key.getCode();
		switch(n){
			case 83 :	saveLevel();		// S

			case flash.Key.SPACE :
				layer = (layer+1)%3;
				Col.setColor(mcCursor.smc,[0xFF0000,0xFF8800,0x00FF00][layer]);

			case 33 :	incLevel(-1);		// PAGE UP
			case 34 :	incLevel(1);		// PAGE DOWN


			case 45 : levels.unshift([]);

		}


	}
	function storeLevel(){
		var a = [];
		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){
				var sq = Game.me.grid[x][y];
				var n = Type.enumIndex(sq.type) + (sq.ladder?3:0);
				a.push(n);
			}
		}
		levels[lvl] = a;
	}
	function saveLevel(){
		storeLevel();
		var o = new mt.PersistCodec();
		var str = o.encode(levels);
		flash.System.setClipboard(str);
	}
	function incLevel(inc){
		storeLevel();
		lvl = lvl+inc;
		if(lvl<0)lvl = 0;
		loadLevel(lvl);
		updateLevelInfo();
	}

	function updateEditor(){

		var px = Cs.getPX( map._xmouse );
		var py = Cs.getPY( map._ymouse );

		mcCursor._x = Cs.getX(px);
		mcCursor._y = Cs.getY(py);

		if(flClick){

			var sq = Game.me.grid[px][py];
			switch(layer){
				case 0,1 :
					var type = [BLOCK,PLAT][layer];
					if( flash.Key.isDown(46) )type = EMPTY;
					if( sq.type != type ){
						sq.type = type;
						drawLevel();
					}
				case 2 :
					var obj = true;
					if( flash.Key.isDown(46) )obj = false;
					if( sq.ladder != obj ){
						sq.ladder = obj;
						drawLevel();
					}
			}

		}




	}



	// DEBUG
	var bmpGrid:flash.display.BitmapData;
	function viewGrid(){
		if( !flash.Key.isDown(71) ){
			bmpGrid.dispose();
			bmpGrid = null;
			return;
		}


		if(bmpGrid==null){
			bmpGrid = new flash.display.BitmapData(  Cs.XMAX, Cs.YMAX, false, 0 );
			var mc = dm.empty(DP_BG);
			mc.attachBitmap(bmpGrid,10);
			mc.blendMode = "add";

			mc._xscale = (Cs.mcw/Cs.XMAX)*100;
			mc._yscale = (Cs.mch/Cs.YMAX)*100;

		}

		for( x in 0...Cs.XMAX ){
			for( y in 0...Cs.YMAX ){

				var n = grid[x][y].ent.length*50;
				if( n >255 ) n = 255;
				var col = Col.objToCol({r:n,g:n,b:n});


				bmpGrid.setPixel(x,y,col);
			}
		}


	}
	function cleanMarkers(){
		while(markers.length>0)markers.pop().removeMovieClip();
	}
	public function mark(x,y){
		var mc = dm.attach("mcMark",20);
		mc._x = x;
		mc._y = y;
		markers.push(mc);
	}

	#end


	// > BUG <
	// lancer multiples contre le mur

	// > FEATURES <
	// COLLISION EN L'AIR KNOCKOUT <> KNOCKOUT
	// créer un mega boss
	// nouvelles techniques
	// GORILLA : nouvelles fatalities
	// GORILLA : jump ( purchopper perchés)
	// SAPER : grenade
	// CHECKER LES FACE A FACE BALLISTIQUE
	// GERER teleport + auto teleport;

	// EMBELISSEMENT : gestion side + gestion bordure + gestion fenetres bg;
	// EMBELISSEMENT : fenetres bg;

	// RECALE DU ARM LOCK PROGRESSIF




//{
}
























