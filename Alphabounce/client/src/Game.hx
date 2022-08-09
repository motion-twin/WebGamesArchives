import mt.bumdum.Sprite;
import mt.bumdum.Phys;
import mt.bumdum.Lib;
import mt.bumdum.Plasma;
import mt.bumdum.Bmp;
import Module;

typedef McText = {>flash.MovieClip, field:flash.TextField }
typedef Plan = {>flash.MovieClip, c:Float }

typedef Title = {>flash.MovieClip, mcField:{>flash.MovieClip,field:flash.TextField}, bl:Float, t:Float }


enum Step {
	Play;
	Ending;
}

class _Js {
	public static function _updateMouse( x:Int, y:Int ){
		var z = haxe.remoting.Connection;
		Cs.MX = x;
		Cs.MY = y;
	}

	public static function _updateCapsules(n){
		Cs.pi.chs = n;
		navi.Map.me.flFuel = Cs.pi.chs+Cs.pi.chl > 0;
		navi.Map.me.initMoveZone();
		if(navi.Map.me.flFuel){
			navi.Map.me.box.removeMovieClip();
		}

	}
}

class Game extends Module{//}

	public static var FL_DEBUG = false;
	public static var PLAY_AUTO = false;

	public static var DP_BG = 		0;
	//public static var DP_PLASMA = 		2;
	public static var DP_UNDERPARTS = 	3;
	public static var DP_BLOCK = 		4;
	public static var DP_PLASMA =		5;
	public static var DP_PAD = 		6;
	public static var DP_OPTION = 		7;
	public static var DP_BALL = 		8;
	public static var DP_PARTS2 = 		9;
	public static var DP_DRONE = 		10;
	public static var DP_MONSTER = 		11;
	public static var DP_PARTS = 		12;
	public static var DP_FRONT_PARTS = 	13;
	public static var DP_FRONT = 		14;
	public static var DP_INTER = 		15;
	public static var DP_PAUSE = 		16;


	public var flFirstBall:Bool;
	public var flItemFall:Bool;
	public var flSwap:Bool;


	public var flSafe:Bool;
	public var flItemCollected:Bool;

	var step:Step;
	public var life:mt.flash.VarSecure;



	public var missileType:Int;
	public var missileCadence:Float;
	public var missileTurnSpeed:Float;
	public var difficulty :Float;



	public var block:Int;
	var spaceColor:Int;
	var blockTotal:Int;
	var accTimer:Float;
	var scroll:Float;
	var timeCoef:Float;

	public var shake:Float;
	public var levelTimer:Float;
	public var autoLaunchTimer:Float;
	public var inactiveTimer:Float;
	public var respawnTimer:Float;

	public var grid:Array<Array<Block>>;
	public var blocks:Array<Block>;
	public var crawlers:Array<{update:Void->Void}>;
	public var monsterGrid:Array<Array<Array<el.Molecule>>>;

	public var balls:Array<el.Ball>;
	public var options:Array<Option>;
	public var events:Array<Event>;
	public var titles:Array<Title>;
	public var molecules:Array<el.Molecule>;


	public var specialSpent:Array<Int>;


	public var pad:Pad;



	public static var me:Game;

	public var bdm:mt.DepthManager;

	public var base:flash.MovieClip;


	public var bg:flash.MovieClip;
	public var mcSunglasses:flash.MovieClip;

	public var mcPlasma:{>flash.MovieClip,bmp:flash.display.BitmapData};
	public var mcTitle:{>flash.MovieClip,field:flash.TextField,timer:Float};

	public var mcInter:{>flash.MovieClip,dm:mt.DepthManager,lives:Array<flash.MovieClip>, mis:McText, min:{>McText,timer:Float,act:Int,trg:Int} };
	public var mcFlash:{>flash.MovieClip,c:Float,inc:Float,pow:Float};

	public var mcCursor:{>flash.MovieClip,c:Float};
	public var mcWarning:McText;

	public var bmpBg:flash.display.BitmapData;



	public function new( mc : flash.MovieClip, col:Int ){
		me = this;
		super(mc);

		base = dm.empty(DP_BLOCK);
		Filt.glow(base,4,2,0xFFFFFF);
		bdm = new mt.DepthManager(base);

		spaceColor = col;
		flPause = false;
		flSwap = false;
		flItemFall = false;

		//
		balls = [];
		options = [];
		events = [];
		titles = [];
		crawlers = [];
		molecules = [];
		monsterGrid = [];
		for( x in 0...Cs.XMAX ){
			monsterGrid[x] = [];
			for( y in 0...Cs.YMAX )monsterGrid[x][y] = [];
		}

		min = new mt.flash.VarSecure();
		accTimer = 0;
		level.lvl = 0;
		pauseCount = 0;

		difficulty = Cs.pi.gotItem(MissionInfo.MODE_DIF)?2:1;


		life = new mt.flash.VarSecure( Cs.pi.getLife() );
		#if test
		life = new mt.flash.VarSecure( 1 );
		#end

		missile = new mt.flash.VarSecure(Cs.pi.missile);
		missileType = Cs.pi.getMissileType();

		missileCadence = Cs.pi.getMissileCadence();//4;
		missileTurnSpeed = Cs.pi.getMissileTurnSpeed();


		// PAD
		newPad();



		//
		if(Cs.PREF_GFX>0.5)initPlasma();
		//initMouseListener();
		initKeyListener();
		initInter();
		//

		initCursor();
		//
		mouseMove();
		//
		if( Cs.pi.missileMax>0 && Cs.pi.shopItems[ShopInfo.MISSILE_GENERATOR]==1 )incMissile(1);


		//haxe.Log.clear();





	}

	// BG
	public function initBg(){

		var rx = wx-navi.Map.SX;
		var ry = wy-navi.Map.SY;

		bg = dm.empty(0);
		bmpBg = getBmpBg(spaceColor);
		bg.attachBitmap(bmpBg,0);

		// ELEMENTS
		var zid = level.zid;
		if( zid != null )drawPlanet(zid,Manager.mcPlanet);

		// SUNGLASSES
		if( Cs.pi.shopItems[ShopInfo.SUNGLASSES]==1 ){

			var o = Col.colToObj(spaceColor);
			var br = Math.max(Math.max( o.r*0.7, o.g), o.b*0.4);
			if( br > 100 ){
				mcSunglasses = new mt.DepthManager(bg).attach("mcDarkScreen",1);
				mcSunglasses.blendMode = "subtract";
			}
		}

		bg.cacheAsBitmap = true;

		//


	}
	function drawPlanet(zid,mc){

		mc.smc.gotoAndStop(zid+1);
		var zi = ZoneInfo.list[zid];

		var m = new flash.geom.Matrix();
		var scx = zi.pos[2]*2*Cs.mcw *0.01;
		var scy = zi.pos[2]*2*Cs.mch *0.01;
		var m = new flash.geom.Matrix();
		m.scale(scx,scy);
		m.translate( (zi.pos[0]-wx)*Cs.mcw, (zi.pos[1]-wy)*Cs.mch );
		var c = 1;
		var o = Col.colToObj(spaceColor);
		var ct = new flash.geom.ColorTransform(c,c,c,1,o.r*(1-c),o.g*(1-c),o.b*(1-c),0);
		//bmpBg.draw(mc,m,ct);

			// BASE
			var bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0x00000000);
			bmp.draw(mc,m,ct);


			// BLUR
			var fl = new flash.filters.BlurFilter();
			fl.blurX = 8;
			fl.blurY = 8;
			bmp.applyFilter(bmp,bmp.rectangle,new flash.geom.Point(0,0),fl);

			// TEXTURE
			var text = new flash.display.BitmapData(Cs.mcw,Cs.mch,false,0);
			var seed = new mt.OldRandom(level.wx*10000+level.wy);
			text.perlinNoise( Cs.mcw,Cs.mch,4,seed.random(1000),false,false,null,true);


			var ct = new flash.geom.ColorTransform(1,1,1,0.4,0,0,0,0);
			bmp.draw(text,new flash.geom.Matrix(),ct,"add");

			// DRAW
			var inc = -30;
			var ct = new flash.geom.ColorTransform(1,1,1,1,inc,inc,inc,0);
			bmpBg.draw(bmp,new flash.geom.Matrix(),ct);



	}

	// INTER
	function initInter(){
		if(Cs.DEMO)return;

		mcInter = cast dm.empty(DP_INTER);
		mcInter.dm = new mt.DepthManager(mcInter);
		mcInter._y = Cs.mch;


		// SPECIALS
		initSpecials();
		placeSpecials();
		// MISSILES
		mcInter.mis = cast mcInter.dm.attach("mcInterMissile",0);

		mcInter.mis.smc.gotoAndStop(missileType+1);
		Filt.glow(mcInter,2,4,0);
		incMissile(0);

		// LIVES
		mcInter.lives = [];
		for( n in 0...life.get() )newLife(n);



	}
	public function newLife(n,?flSpark){
		var mc = mcInter.dm.attach("mcLife",0);
		mc._x = 16 + n*30;
		mc._y = -7;
		mcInter.lives.push(mc);

		if(flSpark){
			for( n in 0...32 ){
				var p = new Phys(dm.attach("partSpark",Game.DP_INTER));
				//p.vy = -1;
				p.x =  mcInter._x + mc._x + (Math.random()*2-1)*10;
				p.y =  mcInter._y + mc._y + Math.random()*3;
				p.weight = -(0.05+Math.random()*0.2);
				p.timer = 10+Math.random()*10;
				p.sleep = n*0.5;
				p.fadeType = 0;
				p.setScale(100+Math.random()*150);
				p.root.blendMode = "add";

			}
		}

	}
	public function incMissile(n){

		//missile = Std.int( Math.min(missile+n,Cs.pi.missileMax));
		missile.addValue(n);
		if( missile.get() > Cs.pi.missileMax )missile.setValue(Cs.pi.missileMax);


		mcInter.mis.field.text = Std.string(missile.get())+"/"+Cs.pi.missileMax;
		mcInter.mis._visible = missile.get() > 0;
		mcInter.mis._x = Cs.mcw-specials.length*12;
	}
	public function incMinerai(n:mt.flash.VarSecure){

		/*
		if( mcInter.min == null ){
			mcInter.min = cast mcInter.dm.attach("mcMinCounter",DP_INTER);
			mcInter.min._x = Cs.mcw;
			mcInter.min._y = -Cs.mch;
			mcInter.min.act = min;
			mcInter.min.field.text = Std.string(mcInter.min.act);
		}

		mcInter.min.trg = min+n;
		mcInter.min.timer = 30;
		mcInter.min._alpha = 100;
		*/


		//
		Api.increaseMineralCounter(n.get());
		min.add(n);

		if( Cs.DEMO!=true )flash.Mouse.hide();

		//


	}
	function updateInter(){

		if(mcInter.min!=null){



			if( mcInter.min.trg>mcInter.min.act ){
				mcInter.min.act++;
				mcInter.min.field.text = Std.string(mcInter.min.act);
			}else{

				mcInter.min.timer -= mt.Timer.tmod;
				var lim = 10;
				if(mcInter.min.timer<lim)mcInter.min._alpha = (mcInter.min.timer/lim)*10;
				if(mcInter.min.timer<0){
					mcInter.min.removeMovieClip();
					mcInter.min = null;
				}

			}



		}
	}

	// CURSOR
	function initCursor(){
		if( Cs.DEMO )return;
		mcCursor = cast Manager.dm.attach("mcCursor",11);
		mcCursor._alpha = 50;
		flash.Mouse.hide();
	}
	function updateCursor(){
		if( Cs.DEMO )return;

		mcCursor._x = Pad.getPadX();
		mcCursor._y = Cs.MY;

		var m = 0;
		if( !flPause && (mcCursor._x > Cs.mcw+m || mcCursor._x < -m || mcCursor._y > Cs.mch+m || mcCursor._y < -m) ){
			if( mcWarning == null && Cs.PREF_BOOLS[2]){
				mcWarning = cast dm.attach("mcWarning",DP_INTER);
				mcWarning.field.text = Text.get.WARNING_ZONE;
			}
		}else{
			if( mcWarning != null ){
				mcWarning.removeMovieClip();
				mcWarning = null;
			}
		}

	}

	// UPDATE
	override public function update(){
		//trace("!"+Std.random(10));
		super.update();


		if(mcFlash!=null)updateFlash();
		updateCursor();
		updateTitle();

		if(pauseCoef!=null)return;



		if(pad.flStop){
			if(timeCoef==null)timeCoef = 1;
			timeCoef = Math.max(timeCoef-0.3*mt.Timer.tmod,0.1);
		}else{
			if(timeCoef!=null){
				timeCoef = Math.min(timeCoef+0.08*mt.Timer.tmod,1);
				if(timeCoef==1)timeCoef=null;
			}
		}

		if(timeCoef!=null)mt.Timer.tmod = timeCoef;

		switch(step){
			case Play:			updatePlay();
			case Ending:		updateEnding();
		}

		updatePlasma();
		updateInter();

		flClick = false;

		//
		if( respawnTimer!=null ){
			respawnTimer -= mt.Timer.tmod;
			if(respawnTimer<=0){
				newPad();
				respawnTimer = null;
			}
		}

		//
		if(shake!=null){
			if(Math.abs(shake)<1)shake = 0;
			base._y = shake;
			shake *= -0.75;
			base.filters = [];

			if(shake==0){
				shake = null;

			}else{
				Filt.blur(base,0,Math.abs(shake));
			}


		}


	//
		Plasma.updateAll();

	}

	// PLAY
	override public function initPlay(){
		step = Play;

		//trace("");
		//trace(7+level.dst*0.35);

		/*
		var b = newBall();
		var rnd = (Math.random()*2-1);
		if(!PLAY_AUTO)b.gluePoint = rnd*20;
		b.moveTo(pad.x,pad.y);
		b.vx=0;
		b.vy=1;
		b.update();
		b.colPad(rnd);
		*/

		levelTimer = 0;
		autoLaunchTimer = 0;
		//flSafe = level.lvl == 0;
	}
	function updatePlay(){
		/*
		haxe.Log.clear();j
		for( y in 0...Cs.YMAX ){
			var str = "";
			for( x in 0...Cs.XMAX )	str+= monsterGrid[x][y].length+"-";
			trace(str);
		}
		//*/

		//
		if(!flFirstBall){
			levelTimer+= mt.Timer.tmod;
			autoLaunchTimer += mt.Timer.tmod;
		}
		if(autoLaunchTimer>200){
			autoLaunchTimer = 0;
			for( b in balls )b.unglue();
		}



		// BALL ACCELERATION
		var mult = 1.0;
		if( level.lvl>=10 ) mult = level.lvl*0.1;
		mult *= difficulty;
		if(!flFirstBall)accTimer += mult*mt.Timer.tmod;
		if(accTimer>Cs.TEMPO){
			for( b in balls ){
				if( b.speed< (7+level.dst*0.35)*difficulty )b.setSpeed(b.speed+0.5);

			}
			accTimer = 0;
		}

		// INACTIVE
		if( !flFirstBall )inactiveTimer+=mt.Timer.tmod;
		var timer = 200+block*40 - inactiveTimer;
		if( timer < 200 ){
			var c = 1-timer/200;
			mcCursor.smc.gotoAndStop(Std.int(c*160)+1);
		}else{
			mcCursor.smc.gotoAndStop(1);
		}
		if( timer<0 ){
			pad.initCharge();
			inactiveTimer = 0;
		}



		// UPDATE
		updateSprites();
		for(e in events)e.update();
		for(c in crawlers)c.update();

	}

	public function removeBlock(){
		inactiveTimer = 0;
		block--;
		var c = block/blockTotal;
		if( block == 0 )initEnding(true);
	}
	function cleanAll(){

		while(balls.length>0)		balls.pop().kill();
		while(options.length>0)		options.pop().kill();
		while(events.length>0)		events[0].kill();
		while(crawlers.length>0)	crawlers.pop();
	}

	// VICTORY
	override public function initEnding(flVictory){
		super.initEnding(flVictory);

		if(Cs.DEMO){
			Demo.me.timer = -1;
			return;
		}

		/*
		if(step==Ending(true) ){
			trace("error ending++");
			return;
		}
		*/
		step = Ending;
		for( b in balls )b.flImmortal = true;
		for( mc in titles )mc.removeMovieClip();

	}
	override function updateEnding(){
		super.updateEnding();
		if(flEndConnect)return;

		// TIMER
		if(flItemFall)victoryTimer = 0;
		var lim = 50;
		if( victoryTimer > lim ){
			pad.y += (victoryTimer-lim)*2;
		}

		// SPRITES
		updateSprites();
		for(e in events)e.update();
		for(c in crawlers)c.update();

		/*
		if( !flEndConnect && victoryTimer > 60 ){
			flEndConnect = true;
			cleanAll();
			//navi.Map.me.initInter();
			navi.Map.me.initConnexion();


			navi.Map.me.setTimeOut(1200);
		}
		*/

	}
	override function endGame(){
		cleanAll();
		var item = null;
		if(flItemCollected)item = level.itemId;
		if(flVictory){
			if( Cs.pi.items[level.itemId] == MissionInfo.TRIGGER ){
				item =  level.itemId;
			}
		}

		var intMin = min.get();
		var intMis = missile.get();
		if( min.bug || missile.bug ){
			//trace("VarSecure Error!");
		}else{
			//trace("endMission gain("+intMin+","+intMis+")");
			Api.endGame(wx,wy,flVictory,intMin,intMis,item,specialSpent);
		}
	}

	// PAD
	function newPad(){
		pad = new Pad(dm.attach("mcPad",DP_PAD));
		if(respawnTimer!=null){
			mcInter.lives.pop().play();
			//newPad();
			pad.init();
			life.addValue(-1);
			pad.y = 500;
		}
	}
	public function killPad(){

		pad.explode(Game.me.dm.empty(Game.DP_PARTS));
		pad = null;
		while( balls.length > 0 )balls.pop().kill();
		if( life.get()>0 && !life.bug ){
			respawnTimer = 30;
		}else{
			initEnding(false);
		}

	}

	// OPTIONS
	public function newOption(t,?x,?y){

		//Api.error("Erreur de reception des données. Cette erreur peut etre provoquée par l'ouverture de deux sessions dans des onglets ou navigateurs différents.");


		if(x==null)x = pad.x;
		if(y==null)y = pad.y-60;
		var opt = new Option(dm.attach("mcOption",DP_OPTION));
		opt.x = x;
		opt.y = y;
		opt.setType(t);
	}
	public function getOption(id){

		switch(id){

			case 0:	// A IMANT
				pad.setType(Cs.PAD_AIMANT);

			case 1:	// B LINDAGE
				for( bl in blocks )if(bl.type<5)bl.setLife(bl.life+1);

			case 2:	// C OLLE
				pad.setType(Cs.PAD_GLUE);

			case 3:	// D IMINUTION
				pad.setRay(Math.max(pad.ray-15,Pad.SIDE+1));
				pad.powerUp();

			case 4:	// E XTENSION
				pad.setRay(Math.min(pad.ray+15,80));
				pad.powerUp();

			case 5:	// F LAMME
				for( b in balls )b.setType(Cs.BALL_FIRE);

			case 6:	// G LACE
				for( b in balls )b.setType(Cs.BALL_ICE);

			case 7:	// H ALO
				for( b in balls )b.setType(Cs.BALL_HALO);

			case 8:	// I NDISGESTION
				//for( i in 0...10 )new fx.Fly(null);
				//pad.moveFactor *= -1;
				new ev.Indigestion();

			case 9:	// J AVELOT
				pad.initCharge();

			case 10: // K AMIKAZE
				for( b in balls )b.setType(Cs.BALL_KAMIKAZE);

			case 11: // L ASER
				pad.setType(Cs.PAD_LASER);

			case 12: // M ULTI-BALL
				var list = balls.copy();
				for( b in list ){
					if(balls.length>=Cs.MAX_BALL)break;
					if(b.type!=Cs.BALL_SHADE){
						var ball = b.clone();
						var a = Math.atan2(b.vy,b.vx);
						var ma = 0.15;
						ball.vx = Math.cos(a+ma)*ball.speed;
						ball.vy = Math.sin(a+ma)*ball.speed;
						b.vx = Math.cos(a-ma)*b.speed;
						b.vy = Math.sin(a-ma)*b.speed;
					}
				};

			case 13: // N OUVELLE BALLE
				var b = pad.initStartBall();
				b.fxLight();
				//pad.setType(Cs.PAD_SHAKE);

			case 14: // O UVRE
				new ev.Ouverture();

			case 15: // P ROVISION
				missile.setValue( Cs.pi.missileMax );
				incMissile(0);

			case 16: // Q UASAR
				new ev.Quasar();

			case 17: // R EGENERATION
				pad.setType(Cs.PAD_GENERATOR);

			case 18: // S ECONDE CHANCE
				newLife(life.get(),true);
				life.addValue(1);

			case 19: // T EMPORALITE
				pad.setType(Cs.PAD_TIME);

			case 20: // U LTRAVIOLET
				new ev.UltraViolet();

			case 21: // V OLT
				for( b in balls )b.setType(Cs.BALL_VOLT);

			case 22: // W HISKY
				for( b in balls )b.setType(Cs.BALL_DRUNK);

			case 23: // X ANAX
				for( b in balls )b.setSpeed(Math.max(b.speed-5,3));

			case 24: // Y OYO
				for( b in balls )b.setType(Cs.BALL_YOYO);

			case 25: // Z ELE
				for( b in balls )b.setSpeed(b.speed+5);

			case 26: // MISSILE
				//missile;
				//if(missile>Cs.pi.missileMax)missile = Cs.pi.missileMax;
				incMissile(1);

		}

		// TITLE
		newTitle(Text.get.OPTION_NAMES[id],Option.getCol(id));

	}

	// SPECIAL
	public function initSpecials(){
		while( specials.length>0 )specials.pop().removeMovieClip();
		specials = [];
		var a = [ShopInfo.BLACKHOLE,ShopInfo.ICE,ShopInfo.FIRE,ShopInfo.STORM];

		var id=0;
		for( sid in a ){
			if( Cs.pi.shopItems[sid] == 1 ){
				var mc:Special = cast mcInter.dm.attach("mcSpecial",0);
				//mc._x = Cs.mcw - specials.length*ssize;
				mc.gotoAndStop(id+1);
				mc.id = id;
				mc.sid = sid;
				specials.push(mc);
			}
			id++;
		}
	}
	public function placeSpecials(){
		var id = 0;
		var ssize = 12;
		for( mc in specials ){
			mc._x = Cs.mcw - id*ssize;
			id++;
		}
	}
	override public function useSpecial(?id){
		if(specials.length==0)return;

		var mc:Special = null;
		var i = 0;
		for( spec in specials ){
			if(spec.id==id){
				mc = spec;
				specials.splice(i,1);
				break;
			}
			i++;
		}

		if(id==null)mc = specials.shift();


		switch(mc.id){
			case 0:	new ev.Quasar();
			case 1:	for( b in balls )b.setType(Cs.BALL_ICE);
			case 2: for( b in balls )b.setType(Cs.BALL_FIRE);
			case 3: for( b in balls )b.setType(Cs.BALL_VOLT);
		}
		//
		if( specialSpent == null ) specialSpent = [];
		specialSpent.push(mc.sid);
		//
		mc.removeMovieClip();
		placeSpecials();
		incMissile(0);

		//
		setFlash(1);

		if(flPause){
			togglePause();
			pauseCoef = 0;
		}




	}

	// GRID
	override public function initLevel(x,y,zid,flMinerai,?lvl){

		super.initLevel(x,y,zid,flMinerai,lvl);


		//
		initBg();
		pad.init();
		initGrid();
		fillGrid();

	}
	function initGrid(){

		/*
		var generator = new LevelGenerator(wx,wy);
		generator.build();
		grid = generator.grid();
		*/
		grid = [];
		for( x in 0...Cs.XMAX ){
			grid[x] = [];
			for( y in 0...Cs.YMAX ){
				grid[x][y] = null;
			}
		}


	}
	function fillGrid(){

		bdm.clear(0);

		level.genModel();
		level.genPalette();

		block = 0;
		blocks = [];
		level.genBonusTable();

		if( Cs.pi.gotItem(MissionInfo.MINES) ){
			var max = 1;
			if( Cs.pi.shopItems[ShopInfo.MINE_0]==1 )max++;
			if( Cs.pi.shopItems[ShopInfo.MINE_1]==1 )max++;
			if( Cs.pi.shopItems[ShopInfo.MINE_2]==1 )max++;
			for( i in 0...max )level.addMine();
		}



		// BLOCKS
		for( y in 0...Cs.YMAX ){
			for( x in 0...Cs.XMAX){
				var type = level.model[x][y];
				if( level.flDepleted && type >= Block.BONUS &&  type < Block.BONUS+Block.BONUS_MAX ){
					type = Block.DEPLETED;
				}
				if( type != null ){
					var bl = new Block(x,y,type);
				}
			}
		}


		//
		blockTotal = block;
	}
	public function hit(px,py,ball){
		grid[px][py].damage(ball);
	}
	public function killZone(px,py){
		var a =  Game.me.monsterGrid[px][py];
		while( a.length>0 )a.pop().explode();
	}

	// TITLES
	public function newTitle(str,col,?flBlink,?time){

		var mc:Title = cast dm.attach("mcTitle",DP_INTER);
		mc.mcField.field.text = str;
		mc.bl = 100;
		mc.t = time;
		if(mc.t==null)mc.t = 32;
		mc._y= 12;
		mc._yscale = 10;
		if(flBlink==null)mc.mcField.stop();
		Filt.glow(cast mc.mcField,4,2,col);

		titles.unshift(mc);
	}
	function updateTitle(){
		var i = 0;
		while( i < titles.length ){
			var mc = titles[i];
			mc.t -= mt.Timer.tmod;
			if(i==0 && mc.t>0){
				mc.bl*=0.5;
				if(mc.bl<0.5)mc.bl=0;
				mc._yscale = Math.max(100-mc.bl,10);
			}else{
				mc._yscale *= 0.75;
				mc.bl +=20;
				if(mc.bl>100){
					mc.removeMovieClip();
					titles.splice(i--,1);
				}
			}
			if(mc.bl>0){
				mc.filters = [];
				Filt.blur( mc, mc.bl, 0 );
			}
			i++;
		}

	}

	// LISTENERS

	override public function mouseDown(){
		super.mouseDown();
		autoLaunchTimer = 0;
		mcTitle.timer = 0;
		pad.action();
	}
	override public function mouseUp(){
		super.mouseUp();
		pad.release();

	}
	override function mouseMove(){
		super.mouseMove();
		pad.flMouse = true;
	}

	// PLASMA
	function initPlasma(){
		//Cs.PQ = Cs.PREF_GFX;
		mcPlasma = cast dm.empty(DP_PLASMA);
		mcPlasma.bmp = new flash.display.BitmapData(Std.int(Cs.mcw*Cs.PQ),Std.int(Cs.mch*Cs.PQ),true,0x00000000);
		mcPlasma._xscale = mcPlasma._yscale = 100/Cs.PQ;
		mcPlasma.attachBitmap(mcPlasma.bmp,0);
		mcPlasma.blendMode = "add";
	}
	function updatePlasma(){
		// BLUR
		var fl = new flash.filters.BlurFilter();
		var bl = Math.max(2,mt.Timer.tmod*4*Cs.PQ);
		fl.blurX = bl;
		fl.blurY = bl;
		mcPlasma.bmp.applyFilter(mcPlasma.bmp,mcPlasma.bmp.rectangle,new flash.geom.Point(0,0),fl);

		// COLOR TRANSFORM
		var ct = new flash.geom.ColorTransform(1,1,1,1,0,0,0,-2);
		mcPlasma.bmp.colorTransform(mcPlasma.bmp.rectangle,ct);


	}
	public function plasmaDraw(mc:flash.MovieClip){
		var m = new flash.geom.Matrix();

		m.scale( (mc._xscale/100)*Cs.PQ, (mc._yscale/100)*Cs.PQ );
			m.rotate(mc._rotation*0.0174);
		m.translate(mc._x*Cs.PQ,mc._y*Cs.PQ);
		var ct = new flash.geom.ColorTransform(1,1,1,mc._alpha/100,0,0,0,0) ;
		mcPlasma.bmp.draw(mc,m,ct,mc.blendMode);
	}

	// DISPLAY SCORE
	public function displayScore(x,y,sc,?col,?size:Float){
		if(col==null)col=0x222288;
		if(size==null)size=1;

		var psc = new Phys( Game.me.dm.attach("mcScore",Game.DP_PARTS) );
		psc.x = x;
		psc.y = y;
		psc.vy = -0.5;
		psc.timer =  30;
		var field:flash.TextField = (cast psc.root).field;
		field.text = Std.string(sc);
		psc.fadeLimit = 5;
		psc.fadeType = 0;
		psc.setScale(100*size);
		Filt.glow(cast field, 4, 2, col);
	}

	// FX
	public function setFlash(?c:Float,?inc:Float,?pow:Float){
		if(c==null)c=1;
		if(inc==null)inc=-0.1;
		if(pow==null)pow=0.5;

		if(mcFlash==null){
			mcFlash = cast dm.attach("mcFlash",DP_FRONT);
			mcFlash.blendMode = "add";
		}
		mcFlash.c = c;
		mcFlash.inc = inc;
		mcFlash.pow = pow;

	}
	public function updateFlash(){
		mcFlash.c = Num.mm(0,mcFlash.c+mcFlash.inc*mt.Timer.tmod,5);
		if(mcFlash.c==0){
			mcFlash.removeMovieClip();
			mcFlash = null;
		}
		mcFlash._alpha = Math.pow( mcFlash.c,mcFlash.pow)*100;

	}
	public function swapScreen(){
		flSwap = !flSwap;
		if( flSwap ){
			root._yscale = -100;
			root._y = Cs.mch;
		}else{
			root._yscale = 100;
			root._y = 0;
		}

	}

	// TOOLS
	public function newBall(){
		var ball = new el.Ball(dm.attach("mcBall",DP_BALL));
		return ball;
	}
	public function isFree(px,py){
		return grid[px][py] == null && px>=0 && px<Cs.XMAX && py>=0;
	}
	public function getLowestBall(){
		var ball:el.Ball = null;
		for( b in balls ){
			if( ball==null || ( b.flUp && b.y>ball.y && b.vy>0 ) ){
				if( b.gluePoint == null ) ball = b;
			}
		}
		return ball;
	}

	// PROTOCOLE
	/*
	public function error(str:String){
		var head = str.substr(0,3);
		if( head.indexOf("CRC")==1 || head.indexOf("crc")==1 ){

		}else{
			trace(str);
		}
		// ;
		// mcBar.field.text = str.toUpperCase;
	}
	*/

	// KILL
	override public function kill(){

		mcPlasma.bmp.dispose();
		bmpBg.dispose();
		var list = Sprite.spriteList.copy();
		for( sp in list)sp.kill();
		me = null;

		super.kill();
	}

	// AUTO
	public function updateAuto(){

		// AUTO CLICK
		if( pad.type == Cs.PAD_LASER || pad.type == Cs.PAD_GLUE || pad.chargeTimer > 30+Std.random(100) ){
			if(flPress)mouseUp();
			if( Math.random() < 0.07 ){
				mouseDown();
			}

		}
	}

	// PAUSE
	override public function togglePause(){
		if(step!=Play)return;
		super.togglePause();
	}

	// DEBUG
	function initKeyListener(){
		kl = {};
		Reflect.setField(kl,"onKeyDown",pressKey);
		flash.Key.addListener(cast kl);
	}
	function pressKey(){
		var n = flash.Key.getCode();
		//if( n==flash.Key.SPACE )mouseDown();

		//initVictory();

		switch(n){
			case 13: // ENTER
				useSpecial();

			case 80: // P AUSE
				togglePause();

			case 27: // ESC AUSE
				togglePause();
		}


		if(Cs.pi.flAdmin){

			var al = 65;
			if( n >= al  && n<al+26 )newOption(n-al);
		}

	}

//{
}


	/*
	Les limitation de prix imposées aux marchands interstellaires par le traité de Sproutch viennent d'être abrogées.
	"La libre concurrence entre marchands itinerants est une bonne chose pour l'économie de la galaxie, au final, le client profitera des meilleurs prix s'il prend la peine de choisir le bon magasin ! " a déclaré Moldane propriétaire de la "Belle-Lycanaise" Epicerie fine orbitale [-8][14].


	*/


	// NOM DES CPASULES A TRADUIRE
	// CORRIGER BUG MARCHAND SOL

	// X INVENTAIRE SALMEEN + ROLLOVER DES PASSAGERS
	// X MONTER LE PRIX DES CHS
	// X BUG BLOCK PUSH Avec explosion
	// X ayohan3 : il lui manque bien un des elements.
	// X moussman23 == moussman2316 ?
	// X SHOP - RADIO A LONGUE PORTEE
	// X SHOP - PRIX DYNAMICS
	// X INV - ECHANGE CONVERTISSEUR / COLLECTEUR
	// X INV - PB AFFICHAGE MISSILE
	// X INTEGRER PLANETE DETRITUS
	// X BUG - TRANSFORMEUR + BRIQUE MOLECULE ?
	// X REPARER LE MESSAGE CONNEXION PERDUE
	// X PLANETE BALIXT PLUS  VISIBLE
	// X PREFERENCE - DETOURAGE DE BALL
	// X PREFERENCE - MOUVEMENT AU CLAVIER
	// X BUG INDIGESTION SUR BRIQUE INVISIBLE
	// X TRANSOFRMATION + BRIQUE INSECTE
	// X AMELIORER COMPREHENSION ITINERAIRE = click sur pass
	// X PROBLEME BRIQUES MARRONS
	// X CHANCER LE DETOURAGE DES COORDS
	// X DIMINUTION DIFFICULTE
	// X INTERFACE -> voir moteur + vies
	// X REMPLIR MISSION AVEC GENERATEUR 2
	// X REVOIR RESERVOIR VIDE BOX
	// X EDITOR - AJOUTER CONG FERREUX.
	// X ESPACE DANS LES COORD DES TEXTES.
	// X CURSEUR ROLLOVER COORD.
	// X MAP - CLIGNOTEMENT VERT MOISN INTENSE.
	// X ABUS PAUSE
	// X ADMIN BUILD LEVEL AVEC TOUTE LES BRIQUES
	// X TIMEOUT
	// X DEEP - DEBRIEFING EN PLEIN ECRAN PAR DESSUS ( voir avec warp )
	// X LOLO - DEBUT = 12 CH Solide
	// X COMPLETION POURCENTAGE >0 voir lolo
	// X MISSION DOUGLAS -> principal
	// X MISSION SOUPALINE -> plus loin.
	// X TEXTES -> DOUGLAS != AIDE
	// X MINERAI GRIS.
	// X MISSION - RADAR NON FONCTIONNEL ( pas trouvé en boutique )
	// X INTER - DRONE DE SOUTIEN S AFFICHE QUAND ON L'A PAS.
	// X INTER - TOOLTIPS SUR LES PASS
	// X BUG - PAD APPARAIT HORS-CHAMPS
	// X OPTION - TRON / TIMIDE / TENTACULE / TORNADE
	// X OPTION - INDIGESTION - EXPAND FILL
	// X CASE ? --> BRIQUE STANDARD + OPTION SPEC BLOQUE ENDING
	// X GAMEPLAY - VERIFIER PLANETES
	// X GAMEPLAY - ENLEVER MINERAI SUR GRIMORN ET TIBOON
	// X COMPATIBILITE -  tir balle sur salve = probleme avec nouvelle balle.
	// X GAMEPLAY - AJOUTER MINERAI SUR DOURIV
	// X FAIRE ICONES MANQUANTS.
	// X INTERFACE - affichage pourcentage
	// X INTERFACE - affichage hint
	// X MOUSE - CADRE ROUGE SI SORTIE DE ZONE
	// X POINTEUR UNIQUEMENT SUR ZONE VERTE.
	// X TEMPS DE DEPART DESACTIVE pour debut + nouveau pad.
	// X REDUIRE ANGLE DEMARRAGE BALLE.
	// X MINERAI - REGARDER UPDATE MINERAI TEMPS REEL
	// X GAMEPLAY - CEINTEURE FERREUSE --> LINES
	// X SHOP - DESCRIPTION ITEMS
	// X VOIR LES MISSILES MAX
	// X JAVELOT - SURLIGNE LIGNE DE BRIQUES.
	// X JAVELOT - CHARGEMENT SUR CURSEUR
	// X PARAMETRES DE JEUX EDITABLES
	// X GAME - TITLE SUR ITEM RAMASSE.
	// X MISSION CREATION DES VIGNETTES EN 100x100
	// X COLLE TIRER BALLE SUR PRESS
	// X boutons sur super attaque
	// X SHOP - CAPSULE ECLAIR.
	// X SHOP - REMPLACER GRAPH CAPSULE HYDROGENE.
	// X SHOP - SKIN radar de secours
	// X BUG HALO + COLLE
	// X BUG HALO + AIMANT
	// X PROBLEME - MISSILE PAS ASSEZ JOUABLE
	// X BLOCK - reapparait quand sous la balle
	// X BLOCK - missile
	// X Remplacer curseur souris.
	// X SOURIS + PAD = +de sensibilité.
	// X FX BLUR ADD BLANC QUAND LE PAD MEURT
	// X FX BALL LEVEL UP / DOWN
	// X RECUL SUR LE PAD
	// X remettre minerais sur planètes
	// X FOG PROGRESSIF ( = SHOP_RADAR + SUPER RADAR ? )
	// X bug missileMax
	// X ETOILE DASH sur ZOOM MAP
	// X HALO DOIT TOUCHER BRIQUE LA PLUS HAUTE
	// X EMPECHER LES TIR DES STORMS TROP NOMBREUX
	// X PAD - BALL CREATOR
	// X ICONES DE PIERRE DE LYCANS / SPYGNISOS NON PRESENTS
	// X MODE DEMO VISIBLE + REVOIR LES OPTIONS DE START
	// X BALL - KILL + steel = blockage
	// X BLOCK - INSECT
	// X BLOCK - qui retourne l'ecran
	// X FAIRE DEFILER COMPTEUR MINERAI
	// X DEMO - GERER GAMEOVER
	// X MESSAGE PLUS DE FUEL
	// X CLIQUER SUR LA ZONE VERTE POUR COMMENCER
	// X LOADING DES PLANETES
	// X MISSIONS - GAIN de CHS scenarisé au debut du jeu
	// X MISSIONS - LIFE +3 AU DEPART TANT QUE LE JOUEUR NE DEPASSE PAS DST 5
	// X CODER LA PAUSE
	// X BALL - EMPECHER DE TIRER LES BALLES COLLEES OFF-SCREEN
	// X IMPLEMENTER LES NOUVEAUX MISSILES
	// X API - ENDITEM
	// X BUG - TIR REDUCTRINE SUR PAD NULL
	// X BUG - EDITOR type molecule change
	// X ETUDIER encodage niveau
	// X IMPLEMENTER LES NOUVELLES BALLES
	// X CORRIGER PB CIBLAGE DRONE + CREER LURE BLOCK
	// X BRIQUE LURE / ANTI-DRONE
	// X IMPLEMENTER CAPSULES ICE FIRE HOLE
	// X AMELIORER DESSIN PLANETES
	// X TOOL = MAP MONDE
	// X EDITEUR / ENREGISTREUR DE NIVEAU
	// X BRIQUE GENERATEUR DE MONSTRE
	// X IMPLEMENTATION DES LUNETTES DE SOLEIL
	// X JAVE CHARGER BUILD
	// X ZONE DE TROU-NOIR
	// X OPTIONS SEEDEES
	// X COLLAGE DE BALLE
	// X VIE SUP
	// X BUG NOUVELLE PARTIE
	// X RECUP MINERAI
	// X FAIRE LES DRONES
	// X BUG Paillette de charge qui ne se retirent pas.
	// X SHOP - DRONE + RAPIDE
	// X SHOP - DRONE TRANSFORME + VITE
	// X SHOP - DRONE CONVERTIS EN MINERAI
	// X SHOP - DRONE PEUVENT COLLECTER MINERAI.
	// X SHOP - Empecher d'acheter des recharges quand missile plein
	// X MISSILE - AMELiORER LA CADENCE DE TIR
	// X MISSILE - AMELIORER LA PUISSANCE DE TIR
	// X MISSILE - AMELIORER LA VITESSE DE ROTATION

	// ABANDON - FAIRE UNE MAP SCAN














