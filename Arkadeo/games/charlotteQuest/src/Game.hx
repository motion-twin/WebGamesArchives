import api.AKApi;
import api.AKApi;
import api.AKProtocol;
import mt.flash.Volatile;

import flash.ui.Keyboard;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import mt.deepnight.Tweenie;
import mt.deepnight.SpriteLib;

import TitleLogo;
import Player;
import Lang;
import Room;

@:bitmap("gfx/levels.png") class GfxLevels extends BitmapData {}
@:bitmap("gfx/shadow2.png") class GfxShadow extends BitmapData {}
@:bitmap("gfx/shop.png") class GfxShop extends BitmapData {}
@:bitmap("gfx/clouds2.png") class GfxClouds extends BitmapData {}
@:bitmap("gfx/cloudsArrival.png") class GfxCloudsArrival extends BitmapData {}

class Game extends flash.display.Sprite, implements haxe.Public {
	public static var ME	: Game;
	public static var WID = 600;
	public static var HEI = 460;
	public static var TW : Tweenie;
	static var MAP_SIZE = 100;
	static var SCROLL_SPEED_LEVEL_UP = api.AKApi.const(14); // x10
	static var SCROLL_SPEED_LEAGUE = api.AKApi.const(16); // x10
	static var RAINBOW_SCALE = 6;
	static var RAINBOW_LOSS = mt.deepnight.Color.getColorizeCT(0x0, 0.01);

	static var uniq = 0;
	public static var DP_BG = uniq++;
	public static var DP_LEVEL = uniq++;
	public static var DP_CHESTS = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_ITEM = uniq++;
	public static var DP_ENEMY = uniq++;
	public static var DP_SHADOW = uniq++;
	public static var DP_PLAYER = uniq++;
	public static var DP_TEXTS = uniq++;
	public static var DP_BULLET = uniq++;
	public static var DP_SHOP_BG = uniq++;
	public static var DP_INTERF = uniq++;
	public static var DP_MASK = uniq++;

	var seed			: Int;
	var rseed			: mt.Rand;
	var time			: Float;
	var absoluteTime	: Float;
	var perf			: Float;
	var ended			: Volatile<Bool>;
	var shopping		: Volatile<Bool>;
	var lockControls	: Volatile<Bool>;
	var rendering		: Bool;
	var skipFrames		: Int;
	var kpoints			: Array<api.SecureInGamePrizeTokens>;

	var fx				: Fx;

	var scroller		: Sprite;
	var dm				: mt.DepthManager;
	var sdm				: mt.DepthManager;
	var viewport		: flash.geom.Rectangle;
	var lastScroll		: {x:Float, y:Float};

	var map				: Hash<Room>;
	var curRoom			: Room;
	//var nextPowerUp		: Volatile<Int>;
	var nextUber		: Volatile<Int>;
	var powerUpSpread	: Array<Int>;

	var player			: Player;
	var bullets			: List<Bullet>;
	var enemies			: List<Enemy>;
	var items			: List<Entity>;
	var killList		: List<Entity>;

	var nextWave		: Volatile<Int>;
	var glevel			: Volatile<Int>;
	var diff			: Volatile<Float>;
	var skill			: Volatile<Float>;
	var corridorLen		: Int;
	var scrollSpeedFact	: Volatile<Float>;

	var bgColor			: Int;
	var levels			: SpriteLib;
	var plasmaBg		: Bitmap;
	var plasma			: BitmapData;
	var plasmaCont		: Bitmap;
	var plasmaSettings	: {dx:Float, dy:Float, w:Int, h:Int};
	var ptime			: Int;

	var rainbow			: Bitmap;

	var shop			: Sprite;
	var shopSnap		: Bitmap;
	var shopBg			: Bitmap;
	var shopPlasma		: Bitmap;
	var shopCursor		: Sprite;
	var shopClouds		: Bitmap;
	var stime			: Int;
	var curItem			: Int;
	var shopKeyCD		: Int;
	var shopBuyCD		: Int;

	var mouseControls	: Bool;
	var cursor			: Sprite;
	var xm				: Int;
	var ym				: Int;

	var wakeUp			: Null<Bitmap>;
	var wakeUpOriginal	: Null<BitmapData>;
	var wakeDistort		: Null<BitmapData>;
	var wakeTimer		: Float;

	var wonMoney		: Int; // argent gagné dans cette partie uniquement (pour les stats)
	var totalMoney		: Int; // argent gagné dans cette partie uniquement (pour les stats)

	#if dev
	var chrono			: Float;
	var debug			: Sprite;
	#end

	public function new() {
		var t = flash.Lib.getTimer();
		super();
		ME = this;

		var raw = haxe.Resource.getString(api.AKApi.getLang());
		if( raw==null ) raw = haxe.Resource.getString("en");
		Lang.init(raw);

		seed = api.AKApi.getSeed();
		rseed = new mt.Rand(0);
		rseed.initSeed(seed);
		#if dev
		haxe.Firebug.redirectTraces();
		haxe.Log.setColor(0xFFFF00);
		#end
		fx = new Fx();
		scrollSpeedFact = #if debug 1 #else 0 #end;
		wakeTimer = 0;
		skill = 0;
		nextUber = -1;
		//nextPowerUp = -1;
		powerUpSpread = [];

		xm = ym = 0;


		skipFrames = #if debug 10 #else 40 #end;

		shopping = false;
		lockControls = true;
		perf = 1;
		time = 0;
		absoluteTime = -1; // incrément en début de frame
		ptime = 0;
		stime = 0;
		shopKeyCD = shopBuyCD = 0;
		map = new Hash();
		nextWave = 40*5;
		#if debug
		nextWave = 0;
		#end
		glevel = isProgression() ? api.AKApi.getLevel() : 1;
		diff = glevel;
		//#if dev diff = 25; #end
		TW = new mt.deepnight.Tweenie();
		bullets = new List();
		enemies = new List();
		items = new List();
		killList = new List();
		lastScroll = {x:0,y:0}
		ended = false;


		flash.Lib.current.stage.quality = flash.display.StageQuality.MEDIUM;

		// Blocs de salles
		levels = new SpriteLib( new GfxLevels(0,0) );
		levels.setUnit(Room.CWID, Room.CHEI);
		levels.sliceUnit("horizontal",	1,0, 21);
		levels.sliceUnit("vertical",	1,2, 26);
		levels.sliceUnit("toUp",		1,4, 19);
		levels.sliceUnit("bedroom",		1,6, 1);

		dm = new mt.DepthManager(this);
		scroller = new Sprite();
		dm.add(scroller, DP_LEVEL);
		sdm = new mt.DepthManager(scroller);

		#if dev
		debug = new Sprite();
		dm.add(debug, DP_INTERF);
		#end

		// Curseur de souris
		var spr = new Sprite();
		spr.graphics.lineStyle(2, 0xFF97FF, 1);
		spr.graphics.drawCircle(0,0,7);
		spr.filters = [
			new flash.filters.GlowFilter(0xFF48FF, 0.6, 8,8,2),
		];
		cursor = new Sprite();
		cursor.addChild( mt.deepnight.Lib.flatten(spr, 4, true, flash.display.StageQuality.BEST) );
		dm.add(cursor, DP_INTERF);
		setMouseControls(false);

		player = new Player();
		if( isProgression() )
			player.loadState( api.AKApi.getState() );

		viewport = new flash.geom.Rectangle(0,0,WID,HEI);

		// Réglages plasma
		rseed.initSeed( isProgression() ? glevel : seed );
		do {
			bgColor = mt.deepnight.Color.randomColor(rseed.rand(), rseed.range(0.5, 0.7), rseed.range(0.2, 0.3));
		} while( mt.deepnight.Color.getRgbRatio(bgColor).g>0.7 );
		var bgColor2 = mt.deepnight.Color.randomColor(rseed.rand(), 0.3, rseed.range(0.3, 0.5));
		var ok = false;
		var pow2 = [8,16,32,64];
		plasmaSettings = {
			dx : rseed.range(0, 0.8, true),
			dy : rseed.range(0, 0.8, true),
			w : pow2.splice(rseed.random(pow2.length), 1)[0],
			h : -1,
		}
		if( plasmaSettings.w>=64 )
			pow2.remove(8);
		if( plasmaSettings.w<=8 )
			pow2.remove(64);
		plasmaSettings.h = pow2.splice(rseed.random(pow2.length), 1)[0];

		// Bg plasma
		var gradient : Array<UInt> = [
			mt.deepnight.Color.interpolateInt(bgColor, 0x0, 0.8),
			bgColor,
			bgColor2,
		];
		if( rseed.random(100)<20 )
			gradient.reverse();
		var bg = new Sprite();
		var m = new flash.geom.Matrix();
		m.createGradientBox(WID,HEI, 90*3.14/180);
		bg.graphics.beginGradientFill(
			flash.display.GradientType.LINEAR,
			gradient,
			[1,1,1],
			[0,160,255],
			m
		);
		bg.graphics.drawRect(0,0,WID,HEI);
		plasmaBg = new Bitmap( new BitmapData(WID,HEI,false,0x0) );
		plasmaBg.smoothing = false;
		dm.add(plasmaBg, DP_BG);
		plasmaBg.bitmapData.draw(bg);

		// Etoiles
		rseed.initSeed( isProgression() ? glevel : seed );
		var s = 3;
		var perlin = new BitmapData(Math.ceil(WID/s), Math.ceil(HEI/s), false, 0x0);
		perlin.perlinNoise(Std.int(200/s),Std.int(128/s), 1, seed, false, false, 1, true);
		var star = new Sprite();
		star.graphics.beginFill(0xffffff, 1);
		star.graphics.drawRect(0,0,2,2);
		star.filters = [ new flash.filters.GlowFilter(bgColor2,0.8, 8,8,4, 2) ];
		var star = mt.deepnight.Lib.flatten(star, 8);
		var ct = new flash.geom.ColorTransform();
		plasmaBg.bitmapData.lock();
		for(i in 0...300) {
			var x = rseed.random(WID);
			var y = rseed.random(HEI);
			var m = new flash.geom.Matrix();
			m.translate(x,y);
			ct.alphaMultiplier = 0.7 * perlin.getPixel(Std.int(x/s), Std.int(y/s)) / 0xffffff;
			plasmaBg.bitmapData.draw(star, m, ct, flash.display.BlendMode.ADD);
		}
		plasmaBg.bitmapData.unlock();
		star.bitmapData.dispose();
		perlin.dispose();


		// Décors de fond
		rseed.initSeed( isProgression() ? glevel : seed );
		var cont = new Sprite();
		var base = rseed.range(0, 6.28);
		var frames = new mt.deepnight.RandList();
		var n = 5;
		if( glevel<10 ) {
			frames.add(1, 20); // arbres
			frames.add(2, 1); // bigben
			frames.add(3, 2); // visages
			frames.add(4, 2); // mains
			n = rseed.irange(0,20);
		}
		else if( glevel<15 ) {
			frames.add(2, 1); // bigben
			frames.add(3, 5); // visages
			frames.add(4, 15); // mains
			n = rseed.irange(0,6);
		}
		else {
			frames.add(2, 1); // bigben
			frames.add(3, 15); // visages
			frames.add(4, 5); // mains
			n = rseed.irange(5,12);
		}
		for(i in 0...n) {
			var a = base - rseed.range(0, 2);
			var mc = new lib.DecorBG();
			mc.gotoAndStop( frames.draw(rseed.random) );
			cont.addChild(mc);
			mc.x = WID*0.5 + Math.cos(a)*WID*0.7;
			mc.y = HEI*0.5 + Math.sin(a)*HEI*0.6;
			mc.scaleX = mc.scaleY = rseed.range( 0.4, 1, true );
			mc.scaleX *= rseed.sign();
			mc.rotation = 90 + mt.deepnight.Lib.deg(a);
			mc.filters = [ new flash.filters.GlowFilter(0x0, 0.8, 16,16,1) ];
		}
		if( glevel==1 ) {
			// Big ben
			var mc = new lib.DecorBG();
			mc.gotoAndStop(2);
			cont.addChild(mc);
			mc.x = 400;
			mc.y = HEI;
			mc.rotation = 190;
		}
		cont.filters = [
			mt.deepnight.Color.getColorizeMatrixFilter(bgColor, 0.8, 0.2),
			new flash.filters.BlurFilter(4,4),
		];
		plasmaBg.bitmapData.draw(cont);

		// Nuages de fond
		var clouds = new Bitmap( new GfxClouds(0,0) );
		clouds.width = WID;
		clouds.height = HEI;
		clouds.smoothing = false;
		var ct = new flash.geom.ColorTransform();
		ct.color = mt.deepnight.Color.randomColor( rseed.rand(), 0.7, 0.7 );
		ct.color = bgColor2;
		ct.alphaMultiplier = 0.3;
		plasmaBg.bitmapData.draw( clouds, clouds.transform.matrix, ct, flash.display.BlendMode.DIFFERENCE );


		// Plasma (alpha défini dans update)
		var s = 6;
		plasma = new BitmapData(Math.ceil(WID/s), Math.ceil(HEI/s), false, 0x0);
		plasmaCont = new Bitmap( plasma );
		dm.add(plasmaCont, DP_BG);
		plasmaCont.scaleX = plasmaCont.scaleY = s;
		plasmaCont.blendMode = flash.display.BlendMode.OVERLAY;
		plasmaCont.alpha = 0;

		// Plasma de la boutique (alpha défini dans update)
		var s = 7;
		shopPlasma = new Bitmap( new BitmapData(Math.ceil(WID/s), Math.ceil(HEI/s), false, 0x0), flash.display.PixelSnapping.NEVER, false );
		dm.add(shopPlasma, DP_INTERF);
		shopPlasma.scaleX = shopPlasma.scaleY = s;
		shopPlasma.blendMode = flash.display.BlendMode.ADD;
		shopPlasma.visible = false;

		// Arc en ciel
		var s = RAINBOW_SCALE;
		rainbow = new Bitmap( new BitmapData(Math.ceil(WID/s), Math.ceil(HEI/s), true, 0x0), flash.display.PixelSnapping.NEVER, false );
		sdm.add( rainbow, DP_FX );
		rainbow.scaleX = rainbow.scaleY = s;
		rainbow.blendMode = flash.display.BlendMode.ADD;
		rainbow.alpha = 0.8;

		// Ombre
		var s = new Bitmap( new GfxShadow(0,0) );
		s.blendMode = flash.display.BlendMode.MULTIPLY;
		s.width = WID;
		s.height = HEI;
		dm.add(s, DP_SHADOW);

		// Niveau
		kpoints = api.AKApi.getInGamePrizeTokens().copy();
		initPowerUps();
		generateMap();

		// Attachement des niveaux
		//for(col in map)
			//for(r in col)
				//if( r!=null )
					//r.draw();

		curRoom = getRoom(0,0);
		curRoom.attach();
		curRoom.getNext().attach();
		curRoom.getNext().getNext().attach();

		#if debug
			lockControls = false;
			//player.spr.alpha = 1;
		#else
			var mask = new Sprite();
			mask.graphics.beginFill(0x0,1);
			mask.graphics.drawRect(0,0,WID,HEI);
			mask.alpha = 1;
			var bmp = mt.deepnight.Lib.flatten(mask);
			dm.add(bmp, DP_MASK);
			player.setPosScreen(190,170);
			//player.dx = 0.2;
			//player.dy = 0.1;
			TW.create(bmp, "alpha", 0, TEaseIn, 1500).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
				//fx.playerSpawn();
				lockControls = false;
			}
		#end

		#if !prod
		trace( "new="+(flash.Lib.getTimer() - t) );
		#end
		#if dev
		chrono = flash.Lib.getTimer();
		#end
	}

	function pop(x:Float,y:Float, str:Dynamic, ?color=0xffffff, ?duration=500) {
		var tf = createField(str, true);
		tf.textColor = color;
		tf.x = Std.int( x-tf.textWidth*0.5 - 2 );
		tf.y = Std.int( y-tf.textHeight*0.5 - 1 );
		tf.filters = [ new flash.filters.GlowFilter(0xffffff,0.2, 10,10, 10) ];

		var bmp = mt.deepnight.Lib.flatten(tf, true);
		bmp.blendMode = flash.display.BlendMode.ADD;
		sdm.add(bmp, DP_TEXTS);

		haxe.Timer.delay( function() {
			TW.create(bmp, "alpha", 0, TEase, 500).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
			}
		}, duration);
	}

	public function addScore(?from:Entity, v:api.AKConst) {
		api.AKApi.addScore(v);
		if( from!=null ) {
			var pt = from.getPoint();
			pop(pt.x, pt.y, v.get(), from.color);
		}
	}

	public function addSkill(v:Float) {
		skill+=v;
		if( skill>1 )
			skill = 1;
		if( skill<0 )
			skill = 0;
	}


	public function onNextWave() {
		if( curRoom.last() )
			return;

		rseed.initSeed(seed + Enemy.WAVE_ID*99);
		nextWave = 40*3;

		//#if debug
		//Enemy.initWave();
		////for(j in 0...2) {
			////Enemy.initWave();
			////for(i in 0...4)
				////new en.Pacman(0);
		////}
//
		////nextWave = 40* (diff<=3 ? 9 : 6);
		//for(i in 0...3)
			//new en.Mosquito();
			////new en.Eye(0);
		////for(i in 0...20)
			////new en.Pacman(0);
		////new en.Mosquito();
		////for( i in 0...3 )
			////new en.Mosquito();
		////var t = rseed.random(2);
		////for( i in 0...rseed.irange(10,20) ) {
			////Enemy.initWave();
			////for( i in 0...2 )
				////new en.Worm(2);
		////}
		//nextWave = 40*10;
		//return;
		//#end

		var waves = new mt.deepnight.RandList();

		// Pacmans
		waves.add(function() {
			if( diff>=en.Pacman.MIN_DIFFS[2] ) {
				// Tireurs
				Enemy.initWave();
				for(i in 0...rseed.irange(5,8))
					new en.Pacman(2);
				nextWave = Std.int(40*5);
			}
			else if( diff>=en.Pacman.MIN_DIFFS[1] ) {
				// Solides
				for(j in 0...2) {
					Enemy.initWave();
					for(i in 0...rseed.irange(3,6))
						new en.Pacman(1);
				}
				nextWave = 40*6;
			}
			else if( diff>=en.Pacman.MIN_DIFFS[0] ) {
				// Petits
				var packs = if( diff<8 ) rseed.irange(1,2) else rseed.irange(1,3);
				for(j in 0...packs) {
					Enemy.initWave();
					for(i in 0...( packs==1 ? 4 : rseed.irange(6,8) ) )
						new en.Pacman(0);
				}
				nextWave = 40* (diff<=3 ? 9 : 6);
			}
		}, 100);

		// Yeux
		if( diff>=en.Eye.MIN_DIFFS[0] ) {
			if( diff>=en.Eye.MIN_DIFFS[1] )
				// Gros
				waves.add( function() {
					Enemy.initWave();
					for( i in 0...rseed.irange(3,5) )
						new en.Eye(1);
					nextWave = 40*9;
				}, 70 );
			else
				// Petits
				waves.add( function() {
					Enemy.initWave();
					for( i in 0...rseed.irange(4,7) )
						new en.Eye(0);
					nextWave = 40*9;
				}, 50 );
		}

		// Moustiques
		if( diff>=en.Mosquito.MIN_DIFF )
			waves.add( function() {
				Enemy.initWave();
				for( i in 0...rseed.irange(1,2) )
					new en.Mosquito();
				nextWave = 40*4;
			}, 60);

		// Vers
		if( diff>=en.Worm.MIN_DIFFS[0] )
			waves.add( function() {
				var t = diff>=en.Worm.MIN_DIFFS[1] ? 1 : 0;
				Enemy.initWave();
				var len = t==0 ? rseed.irange(6,10) : rseed.irange(9,12);
				for( i in 0...len )
					new en.Worm(t);
				nextWave = 40*6;
			}, 30);

		// Vers Fourmis
		if( diff>=en.Worm.MIN_DIFFS[2] )
			waves.add( function() {
				for( i in 0...rseed.irange(10,20) ) {
					Enemy.initWave();
					for( i in 0...2 )
						new en.Worm(2);
				}
				nextWave = 40*8;
			}, 60);

		// Guêpes
		if( diff>=en.Bee.MIN_DIFF )
			waves.add( function() {
				var n = 1;
				if( diff>=en.Bee.MIN_DIFF+5 )
					n++;
				if( diff>=en.Bee.MIN_DIFF+10 )
					n++;
				if( diff>=en.Bee.MIN_DIFF+20 )
					n++;
				Enemy.initWave();
				for( i in 0...n )
					new en.Bee();
				nextWave = 40*n*6;
			}, 100);

		// Tirage
		waves.draw(rseed.random)();
	}

	public function populateRoom(r:Room) {
		if( r.distance==0 )
			return;

		rseed.initSeed(seed + r.distance);

		#if debug
		Enemy.initWave();
		//for(p in api.AKApi.getInGamePrizeTokens())
			//new en.Chest(r, function(c) {
				//new it.PowerUp(c);
			//});
		return;
		#end

		while( isLeague() && kpoints.length>0 && api.AKApi.getScore()>=kpoints[0].score.get() ) {
			var pk = kpoints.splice(0,1)[0];
			r.kpoints.push(pk);
		}

		// Coffres à power-ups
		if( isLeague() && r.hasPowerUp ) {
			Enemy.initWave();
			var k = it.PowerUp.randomKind(rseed);
			if( k==null )
				new en.Chest( r ); // Non, finalement, des thunes ça ira aussi
			else
				new en.Chest( r, function(c) new it.PowerUp(c, k) );
		}

		// Coffres Uber !
		if( r.hasUber) {
			Enemy.initWave();
			new en.Chest( r, function(c) new it.PowerUp(c, Uber) );
		}

		// Coffres à points kadeo
		if( r.kpoints.length>0 ) {
			Enemy.initWave();
			for(pk in r.kpoints)
				new en.Chest( r, function(c) new it.KPoint(c, pk) );
		}

		// Coffres à thunes
		if( r.distance>0 ) {
			Enemy.initWave();
			var rlist = new mt.deepnight.RandList();
			rlist.add(0, 100);
			if( isLeague() ) {
				rlist.add(1, 50);
				rlist.add(2, 30);
				rlist.add(4, 3);
				rlist.add(8, 1);
			}
			else {
				rlist.add(1, 25);
				rlist.add(2, 10);
			}
			for( i in 0...rlist.draw(rseed.random) )
				new en.Chest(r);
		}


		// Mines
		var hasMines = false;
		if( diff>=en.Mine.MIN_DIFF && rseed.random(100)<15 ) {
			Enemy.initWave();
			var n = Math.round( rseed.irange(4,6) );
			for( i in 0...n )
				new en.Mine( r, rseed.random(100)<20 ? 1 : 0 );
			hasMines = true;
		}

		// Tourelles
		if( diff>=en.Turret.MIN_DIFF ) {
			Enemy.initWave();
			var min = 0;
			var max = 0;
			if( diff<6 )		{ min = 1; max = 2; }
			else if( diff<8 )	{ min = 1; max = 3; }
			else if( diff<14 )	{ min = 2; max = 3; }
			else if( diff<18 )	{ min = 3; max = 4; }
			else if( diff<21 )	{ min = 3; max = 5; }
			else 				{ min = 4; max = 6; }
			if( hasMines )
				max = Std.int(max*0.5);
			if( min>max )
				min = max;
			var n = rseed.irange(min, max);
			for( i in 0...n )
				new en.Turret(r, diff<=3 ? 0 : 1);
		}
	}

	function setMouseControls(b:Bool) {
		mouseControls = b;
		if( skipFrames<=0 )
			pop(viewport.x + WID*0.5, viewport.y + 20, mouseControls ? Lang.MouseOn : Lang.MouseOff, 0xFFE655);
		cursor.visible = mouseControls && !api.AKApi.isReplay();
		if( mouseControls && !api.AKApi.isReplay() )
			flash.ui.Mouse.hide();
		else
			flash.ui.Mouse.show();
	}

	public function gameOver(win:Volatile<Bool>) {
		if( ended )
			return;
		ended = true;

		player.dx = player.dy = 0;

		if( mouseControls ) {
			flash.ui.Mouse.show();
			cursor.visible = false;
		}

		if( win ) {
			// Victoire
			for( e in bullets )
				e.destroy();
			var s = 3;
			wakeUp = new Bitmap( new BitmapData(Math.ceil(WID/s), Math.ceil(HEI/s), false, 0x0) );
			var m = new flash.geom.Matrix();
			m.scale(1/s, 1/s);
			wakeUp.bitmapData.draw(this, m);
			wakeUpOriginal = wakeUp.bitmapData.clone();
			dm.add(wakeUp, DP_MASK);
			wakeUp.scaleX = wakeUp.scaleY = s;
			wakeUp.alpha = 0;
			TW.create(wakeUp, "alpha", 1, TEaseIn, 700);

			wakeDistort = new BitmapData(wakeUp.bitmapData.width, wakeUp.bitmapData.height, false, 0x7D7D7D);

			var clouds = new Bitmap( new GfxClouds(0,0) );
			dm.add(clouds, DP_MASK);
			clouds.alpha = 0;
			clouds.width = WID;
			clouds.height = HEI;
			TW.create(clouds, "alpha", 0.7, TEaseIn, 2000);

			var mask = new Sprite();
			dm.add(mask, DP_MASK);
			mask.graphics.beginFill(0xFFB0FF,1);
			mask.graphics.drawRect(0,0,WID,HEI);
			mask.blendMode = flash.display.BlendMode.ADD;
			mask.alpha = 0;
			TW.create(mask, "alpha", 1, TEaseIn, 4000).onEnd = function() {
				var mask = new Sprite();
				dm.add(mask, DP_MASK);
				mask.graphics.beginFill(0xffffff,1);
				mask.graphics.drawRect(0,0,WID,HEI);
				mask.alpha = 0;
				TW.create(mask, "alpha", 1, TEaseOut, 700).onEnd = function() {
					if( isProgression() && win )
						api.AKApi.saveState( player.saveState() );
					api.AKApi.gameOver(true);
				}
			}
		}
		else {
			// Défaite
			var mask = new flash.display.Sprite();
			dm.add(mask, DP_MASK);
			mask.graphics.beginFill(0x1F1F1F,1);
			mask.graphics.drawRect(0,0,WID,HEI);
			mask.alpha = 0;
			TW.create(mask, "alpha", 0.4, TEase, 2200).onEnd = function() {
				api.AKApi.gameOver(false);
			}
		}
	}

	public function createField(str:Dynamic, ?adjustSize=false, ?letterSpacing=1.0) {
		var str = Std.string(str);
		var f = new flash.text.TextFormat();
		f.font = "def";
		f.size = 16;
		f.color = 0xffffff;
		f.letterSpacing = letterSpacing;
		//f.bold = true;

		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		//tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		//tf.sharpness = 800;
		tf.embedFonts = true;
		tf.text = str;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}

		return tf;
	}


	function initPowerUps() {
		var rlist = new mt.deepnight.RandList();
		rlist.add(0, 10);
		rlist.add(1, 100);
		rlist.add(2, 90);
		rlist.add(3, 50);
		rlist.add(4, 20);
		rlist.add(5, 5);
		rlist.toString();
		var closes = rlist.draw(rseed.random);
		var closeChance = 15.0;

		powerUpSpread = [];
		var totalDist = 0;
		for(n in 0...30) {
			var nextDist =
				if( n==0 )
					rseed.irange(1,3);
				else
					if( closes>0 && rseed.random(100)<closeChance ) {
						closeChance = 15;
						closes--;
						1;
					}
					else {
						closeChance*=1.4;
						if( n<=3 )
							rseed.irange(2,3);
						else
							rseed.irange(2,4);
					}

			totalDist+=nextDist;
			powerUpSpread.push( totalDist );
		}
	}


	public function generateMap(?count:Int) {
		if( count==null ) {
			// horizontal=14.18s, vertical=10.74, average=12.46s
			if( isLeague() )
				count = 3;
			else
				count = Std.int(glevel*0.7)+5;
		}
		var t = flash.Lib.getTimer();
		var newMap = Room.ALL.length==0;
		var last = Room.ALL[Room.ALL.length-1];
		var x = newMap ? 0 : last.cx + last.getNextDir().dx;
		var y = newMap ? 0 : last.cy + last.getNextDir().dy;
		var n = 0;
		var k = Bedroom;
		if( !newMap )
			k = switch( last.kind ) {
				case Bedroom : Horizontal;
				case Horizontal, VerticalDown, VerticalUp : last.kind;
				case FromUp, FromDown : Horizontal;
				case ToUp : VerticalUp;
				case ToDown : VerticalDown;
			}


		if( nextUber==-1 ) {
			rseed.initSeed( seed );
			nextUber = 99999;
			if( isProgression() && rseed.random(100)<10 )
				nextUber = rseed.irange(2, count-1);
			if( isLeague() )
				nextUber = rseed.irange(8, 20);
		}
		//if( nextPowerUp==-1 )
			//nextPowerUp = rseed.irange(2,3);


		if( isLeague() )
			rseed.initSeed( seed + Room.ALL.length*99 );
		else
			rseed.initSeed( glevel );
		var corridorLen = Room.ALL.length==0 ? 2 : 0;
		var duration = 0.;
		while( n<count ) {
			var r = new Room(x,y, k);

			var next = r.getNextDir();
			x += next.dx;
			y += next.dy;
			corridorLen--;

			k = switch( k ) {
				case Bedroom :
					if( isProgression() && glevel==2 )
						ToDown
					else
						Horizontal;
				case ToDown : VerticalDown;
				case ToUp : VerticalUp;
				case FromDown : Horizontal;
				case FromUp : Horizontal;
				default : k;
			}
			duration += r.getDuration();
			if( corridorLen<=0 ) {
				corridorLen = rseed.irange(1,4);
				if( isLeague() || glevel>=3 )
					k = switch( k ) {
						case VerticalDown :
							rseed.random(6)==0 ? k : FromUp;
						case VerticalUp :
							rseed.random(6)==0 ? k : FromDown;
						case Horizontal, Bedroom :
							corridorLen++;
							rseed.random(2)==0 ? ToUp : ToDown;
						default :
					}
			}
			if( isProgression() && n==count-1 )
				r.addArrival();

			if( isLeague() && powerUpSpread.length>0 && powerUpSpread[0]==r.distance ) {
				powerUpSpread.splice(0,1);
				r.hasPowerUp = true;
			}
			if( nextUber--<=0 ) {
				r.hasUber = true;
				nextUber = rseed.irange(10,20);
			}
			n++;
		}
		#if debug
		//trace("duration="+Math.round(duration)+"s (approx. "+Math.round(duration/60)+"min)");
		#end

		// Points kadeo
		rseed.initSeed( seed );
		if( isProgression() )
			while( kpoints.length>0 ) {
				var r = Room.ALL[ rseed.irange(1,Room.ALL.length-1) ];
				var pk = kpoints.splice(0,1)[0];
				r.kpoints.push( pk );
			}

		// Uber
		//rseed.initSeed( seed );
		//if( isProgression()
			//if( rseed.random(100)<10 )
				//Room.ALL[ 2 + rseed.random(Room.ALL.length-2) ].hasUber = true;
		//else
			//trace("TODO");

		// Boutique
		rseed.initSeed( seed );
		if( isProgression() && glevel>1 ) {
			var d = rseed.irange(1+Math.ceil(count*0.2), Math.ceil(count*0.5));
			var ok = false;
			while( !ok && d < Room.ALL.length ) {
				var r = Room.getByDist(d);
				ok = r.addShop();
				d++;
			}
			if( !ok )
				trace("ERROR : no room for shop :(");
		}

		#if debug
		trace("gen="+(flash.Lib.getTimer()-t));
		#end
	}


	//public inline function getNextRoom() {
		//return
			//if( getRoom(curRoom.cx,curRoom.cy-1)!=null )
				//getRoom(curRoom.cx,curRoom.cy-1);
			//else if( getRoom(curRoom.cx,curRoom.cy+1)!=null )
				//getRoom(curRoom.cx,curRoom.cy+1);
			//else if( getRoom(curRoom.cx+1, curRoom.cy)!=null )
				//getRoom(curRoom.cx+1, curRoom.cy);
			//else
				//null;
	//}

	//public function getScrollDir() {
		//var r = getNextRoom();
		//return
			//if( r==null )
				//{dx:0., dy:0.};
			//else if( r.cx>curRoom.cx )
				//{dx:1, dy:0}
			//else if( r.cy<curRoom.cy )
				//{dx:0, dy:-1}
			//else if( r.cy>curRoom.cy )
				//{dx:0, dy:1}
	//}

	//public inline function initSeed(?delta=0) {
		//rseed.initSeed( seed + delta*99 );
	//}

	public inline function setRoom(cx:Int,cy:Int, r:Room) {
		map.set(cx+","+cy, r);
	}
	public inline function getRoom(cx:Int,cy:Int) {
		return map.get(cx+","+cy);
	}
	public inline function getRoomAt(x:Float,y:Float) {
		return getRoom( Math.floor(x/(Room.CWID*Room.GRID)), Math.floor(y/(Room.CHEI*Room.GRID)) );
	}

	#if dev
	function devKey() {
		if( ended || player.hasCD("debug") )
			return;
		if( api.AKApi.unrecordedIsDown(Keyboard.W) ) gameOver(true);
		if( api.AKApi.unrecordedIsDown(Keyboard.L) ) player.kill();
		if( api.AKApi.unrecordedIsDown(Keyboard.M)  ) {
			player.setCD("debug", 4);
			for( i in 0...10 ) {
				var e = new it.Score(player,Std.random(3));
				e.setPosScreen(Std.random(WID), Math.random()*HEI*0.5);
			}
			//var e = new it.PowerUp(0,0);
			//e.setPosScreen(Std.random(WID), Math.random()*HEI*0.8);
		}
		if( api.AKApi.unrecordedIsDown(Keyboard.D)  ) {
			trace("------------------");
			trace("en="+enemies.length);
			trace("bul="+bullets.length);
			trace("fx="+mt.deepnight.Particle.ALL.length);
			trace("items="+items.length);
		}
		if( api.AKApi.unrecordedIsDown(Keyboard.P)  ) {
			player.setCD("debug", 4);
			player.build.speed++;
			player.build.back++;
			player.build.front++;
			player.build.up++;
			player.build.down++;
			player.build.capture++;
			//player.build.frontUp++;
			//player.build.frontDown++;
			//player.build.upDown++;
			trace(player.build.speed);
			player.applyBuild();
		}
		if( api.AKApi.unrecordedIsDown(Keyboard.BACKSPACE) ) {
			if( player.hasCD("pauseScroll") )
				player.clearCD("pauseScroll");
			else
				player.setCD("pauseScroll", 999999);
		}
		if( api.AKApi.unrecordedIsDown(Keyboard.ENTER) ) {
			player.setCD("debug", 4);
			player.uber();
			//var pt = player.getPoint();
			//fx.splash(player, player);
			//fx.cadaver();
			//fx.playerDeath();
			//fx.playerSpawn();
		}
	}
	#end

	public function enterShop() {
		if( ended || player.dead() || player.hasCD("shopping") )
			return;

		if( mouseControls ) {
			flash.ui.Mouse.show();
			cursor.visible = false;
		}
		var d = 800;

		shopping = true;
		player.setCD("shopping", 30*15); // 40*2
		shopKeyCD = 40;
		curItem = 0;

		// Fond flouté
		shopSnap = new Bitmap( new BitmapData(WID,HEI, false, 0x0) );
		shopSnap.bitmapData.draw(this);
		dm.add(shopSnap, DP_SHOP_BG);
		shopSnap.bitmapData.applyFilter( shopSnap.bitmapData, shopSnap.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(8,8, 2) );
		shopSnap.bitmapData.applyFilter( shopSnap.bitmapData, shopSnap.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getContrastFilter(-0.5) );
		shopSnap.bitmapData.applyFilter( shopSnap.bitmapData, shopSnap.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getColorizeMatrixFilter(0xFFFFFF, 0.3) );
		shopSnap.bitmapData.applyFilter( shopSnap.bitmapData, shopSnap.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getColorizeMatrixFilter(0xE294EB, 0.75, 0.25) );

		//shopSnap.bitmapData.fillRect( new flash.geom.Rectangle(0,0,shopSnap.bitmapData.width,30), ShopItem.BG );
		//shopSnap.bitmapData.applyFilter( shopSnap.bitmapData, shopSnap.bitmapData.rect, new flash.geom.Point(0,0), mt.deepnight.Color.getSaturationFilter(-1) );
		shopSnap.alpha = 0;
		TW.create(shopSnap, "alpha", 1, d);

		TW.create(player.lifeCont, "alpha", 0, d);

		// Wrapper
		shop = new Sprite();
		dm.add(shop, DP_INTERF);
		shop.alpha = 0;
		TW.create(shop, "alpha", 1, d);

		// Nuages
		shopClouds = new Bitmap( new GfxClouds(0,0) );
		shopClouds.alpha = 0;
		shopClouds.width = WID;
		shopClouds.height = HEI;
		TW.create(shopClouds, "alpha", 0.8, d*2);
		dm.add(shopClouds, DP_SHOP_BG);

		// Image de fond
		shopBg = new Bitmap( new GfxShop(0,0) );
		dm.add( shopBg, DP_SHOP_BG );
		shopBg.x = Std.int( WID*0.5 - shopBg.width*0.5 - 5 );
		shopBg.y = Std.int( HEI*0.5 - shopBg.height*0.5 + 5 );
		shopBg.alpha = 0;
		TW.create(shopBg, "alpha", 1, d);

		// Curseur
		shopCursor = new Sprite();
		shop.addChild(shopCursor);
		shopCursor.x = -5;
		shopCursor.graphics.lineStyle(1, 0xFFFF79, 1);
		shopCursor.graphics.drawRoundRect(0,0, ShopItem.WID+10, ShopItem.HEI+9, 8,8);
		shopCursor.filters = [
			new flash.filters.GlowFilter(0xFCB612, 1, 4,4, 2),
			new flash.filters.GlowFilter(0xFF990F, 1, 16,16, 2),
		];
		//shopCursor.graphics.beginFill(0x0, 1);
		//shopCursor.graphics.moveTo(-10, -10);
		//shopCursor.graphics.lineTo(0, 0);
		//shopCursor.graphics.lineTo(-10, 10);
		//shopCursor.graphics.endFill();
		//shopCursor.filters = [
			//new flash.filters.GlowFilter(0xFFFF80, 0.8, 8,8,1),
			//new flash.filters.DropShadowFilter(4,60, 0x0,0.3, 4,4),
		//];

		// Plasma
		shopPlasma.visible = true;
		shopPlasma.alpha = 0;
		TW.create(shopPlasma, "alpha", 0.3, d);

		var si = new ShopItem(6, Lang.ShopCapture, player.build.capture, 8, lib.Bubble);
		si.apply = function() player.build.capture++;

		var si = new ShopItem(5, Lang.ShopSpeed, player.build.speed, 5, lib.SpeedIcon);
		si.apply = function() player.build.speed++;

		var si = new ShopItem(3, Lang.ShopUp, player.build.up, 8, lib.Shoot);
		si.apply = function() player.build.up++;

		var si = new ShopItem(4, Lang.ShopDown, player.build.down, 8, lib.Shoot);
		si.apply = function() player.build.down++;

		var si = new ShopItem(1, Lang.ShopFront, player.build.front, 8, lib.Shoot);
		si.apply = function() player.build.front++;

		var si = new ShopItem(2, Lang.ShopBack, player.build.back, 8, lib.Shoot);
		si.apply = function() player.build.back++;

		var si = new ShopItem(0, Lang.ShopExit, 0, 0, null);
		si.apply = function() leaveShop();
		curItem = ShopItem.ALL.length-1;

		//var si = new ShopItem("Avant-haut", player.build.frontUp, 10, lib.Shoot);
		//si.apply = function() player.build.frontUp++;
		//
		//var si = new ShopItem("Avant-bas", player.build.frontDown, 10, lib.Shoot);
		//si.apply = function() player.build.frontDown++;

		//var si = new ShopItem("Haut + bas", player.build.upDown, 10, lib.Shoot);
		//si.apply = function() player.build.upDown++;

		//var si = new ShopItem("Front", player.build.front, 10);
		//si.apply = function() player.build.front++;
		//
		//var si = new ShopItem("Back", player.build.back, 10);
		//si.apply = function() player.build.back++;

		ShopItem.ALL[curItem].setActive(true);
		shop.x = Std.int( WID*0.5 - shop.width*0.5 );
		shop.y = Std.int( HEI*0.5 - shop.height*0.5 );

	}

	function countRealEnemies() {
		var n = 0;
		for(e in enemies)
			if( e.hasToBeKilled ) n++;
		return n;
	}

	public function leaveShop() {
		shopping = false;
		player.shield();

		for(i in ShopItem.ALL)
			i.destroy();
		ShopItem.ALL = new Array();

		shop.mouseChildren = shop.mouseEnabled = false;
		shop.parent.removeChild(shop);

		var bmp = shopSnap;
		shopSnap = null;
		TW.create(bmp, "alpha", 0, 400).onEnd = function() {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
		var bmp = shopClouds;
		shopClouds = null;
		TW.create(bmp, "alpha", 0, 800).onEnd = function() {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
		var bmp = shopBg;
		shopBg = null;
		TW.create(bmp, "alpha", 0, 400).onEnd = function() {
			bmp.parent.removeChild(bmp);
			bmp.bitmapData.dispose();
		}
		TW.create(shopPlasma, "alpha", 0, 400).onEnd = function() {
			shopPlasma.visible = false;
		}

		TW.create(player.lifeCont, "alpha", 1, 400);
		if( mouseControls )
			setMouseControls(true);
	}

	inline function actionKey() {
		return !mouseControls && api.AKApi.isDown(Keyboard.CONTROL, Keyboard.SPACE) || mouseControls && api.AKApi.isClicked();
	}

	inline function actionKeyToggled() {
		return api.AKApi.isToggled(Keyboard.CONTROL, Keyboard.SPACE);
	}

	public inline function isLeague() {
		return Type.enumIndex(api.AKApi.getGameMode()) == Type.enumIndex(GM_LEAGUE);
	}
	public inline function isProgression() {
		return Type.enumIndex(api.AKApi.getGameMode()) == Type.enumIndex(GM_PROGRESSION);
	}

	inline function updateMouse() {
		if( mouseControls ) {
			var grid = 8;
			var minDeltaX = Math.ceil(WID/grid) + 20;
			var minDeltaY = Math.ceil(HEI/grid) + 20;

			var oldX = Std.int(xm/grid);
			var oldY = Std.int(ym/grid);

			var x = Math.round(mouseX/grid);
			var y = Math.round(mouseY/grid);
			var dx = Math.floor(x - oldX) + minDeltaX;
			var dy = Math.floor(y - oldY) + minDeltaY;
			if( dx<0 ) dx = 0;
			if( dy<0 ) dy = 0;

			dx = AKApi.getCustomValue( dx );
			dy = AKApi.getCustomValue( dy );

			xm = (oldX+dx-minDeltaX) * grid;
			ym = (oldY+dy-minDeltaY) * grid;

			#if debug
			debug.graphics.clear();
			debug.graphics.lineStyle(1, 0x6AFF06, 0.4);
			debug.graphics.drawCircle(xm,ym,5);
			#end
			cursor.x = mouseX;
			cursor.y = mouseY;
		}
	}

	public function update(r:Bool){
		updateMouse();

		absoluteTime++;
		//var t = flash.Lib.getTimer();
		rendering = r;

		perf = api.AKApi.getRealFramerate() / api.AKApi.getBaseFramerate();

		Room.updateAll();
		//trace(rendering+" "+api.AKApi.getRealFramerate()+" "+(flash.Lib.getTimer()-t)+"ms");

		if( skipFrames-->0 )
			return;

		if( !shopping ) {
			// En jeu
			//#if debug enterShop(); #end
			#if dev
			devKey();
			#end

			if( curRoom.last(2) && isLeague() ) {
				glevel++;
				diff += 1.32 + 0.6*skill;
				var total = 0.;
				for(r in Room.ALL)
					total+=r.getDuration();
				generateMap(2);
			}

			if( time%3==0 && curRoom.last() && isProgression() && !player.dead() && !ended && items.length==0 && countRealEnemies()==0 )
				gameOver(true);

			if( time%5==0 && curRoom.distance>0 && nextWave>40 && !curRoom.last() && !player.dead() && !ended && countRealEnemies()==0 )
				nextWave = 40;
			if( nextWave-- <= 0 )
				onNextWave();

			// Contrôles mouvement
			if( !lockControls && !player.dead() && !ended ) {
				var reset = true;
				var ps = player.speed + 0.15*player.speed*(1-player.getCD("slow")/15);

				if( mouseControls ) {
					var pt = player.getScreenPoint();
					var d = mt.deepnight.Lib.distance(xm,ym, pt.x,pt.y);
					var ms = d<=30 ? ps*(d/30) : ps;
					var ang = Math.atan2(ym-pt.y, xm-pt.x);
					player.dx += Math.cos(ang)*ms;
					player.dy += Math.sin(ang)*ms;
				}
				else {
					if( AKApi.isDown(Keyboard.UP, Keyboard.Z, Keyboard.W) ) {
						reset = false;
						player.setPlayerAnim("up");
						player.dy-=ps;
					}
					if( AKApi.isDown(Keyboard.DOWN, Keyboard.S) ) {
						reset = false;
						player.setPlayerAnim("down");
						player.dy+=ps;
					}

					if( AKApi.isDown(Keyboard.LEFT, Keyboard.Q, Keyboard.A) ) {
						reset = false;
						player.setPlayerAnim("left");
						player.mc.rotation-=1;
						player.dx-=ps;
					}
					if( AKApi.isDown(Keyboard.RIGHT, Keyboard.D) ) {
						reset = false;
						player.setPlayerAnim("right");
						player.mc.rotation+=1;
						player.dx+=ps;
					}
				}
				if( AKApi.isToggled(Keyboard.U) ) {
					setMouseControls( !mouseControls );
				}

				if( reset )
					player.setPlayerAnim();

				// Tir
				if( actionKey() ) {
					player.shoot();
					player.setCD("slow", 15);
				}
			}

			// Scrolling auto
			if( scrollSpeedFact<1 && time>=40 ) {
				scrollSpeedFact+=0.008;
				if( scrollSpeedFact>1 )
					scrollSpeedFact = 1;
			}
			var d = curRoom.getNextDir();
			if( curRoom.getNext()==null )
				d.dx = d.dy = 0;
			var speed = scrollSpeedFact * ( isLeague() ? SCROLL_SPEED_LEAGUE.get() : SCROLL_SPEED_LEVEL_UP.get() )/10;
			if( ended )
				speed = 0;
			#if dev
			//speed = 0;
			if( player.hasCD("pauseScroll") )
				speed = 0;
			if( api.AKApi.unrecordedIsDown(Keyboard.NUMPAD_ADD) )
				speed += 15;
			#end
			var curScroll = { dx : d.dx*speed, dy : d.dy*speed }
			viewport.x += curScroll.dx;
			viewport.y += curScroll.dy;
			scroller.x = -Std.int(viewport.x);
			scroller.y = -Std.int(viewport.y);

			// Salle suivante
			if( curRoom.goneThrough() ) {
				#if dev
				trace("chrono="+(flash.Lib.getTimer()-chrono));
				chrono = flash.Lib.getTimer();
				#end
				curRoom.detach();
				curRoom = curRoom.getNext();
				var next = curRoom.getNext();
				if( next!=null ) {
					next.attach();
					if( next.getNext()!=null )
						next.getNext().attach();
				}
				viewport.x = curRoom.cx*Room.CWID*Room.GRID;
				viewport.y = curRoom.cy*Room.CHEI*Room.GRID;
			}

			// Updates
			lastScroll =  { x:curScroll.dx/Room.GRID, y:curScroll.dy/Room.GRID }
			for(e in bullets)
				e.update();
			for(e in enemies)
				e.update();
			for(e in items)
				e.update();
			player.update();
			for(e in killList)
				e.unregister();
			killList = new List();
			//trace([enemies.length, bullets.length, items.length]);

			// Plasma
			if( perf<0.9 && plasmaCont.alpha>0 )
				plasmaCont.alpha-=0.05;
			if( !ended && time%2==0 && perf>=0.9 ) {
				if( plasmaCont.alpha<0.4 )
					plasmaCont.alpha+=0.05;
				if( rendering ) {
					var s = 0.4;
					var vdx = viewport.x*0.05;
					var vdy = viewport.y*0.05;
					var off = [
						new flash.geom.Point(ptime*s*plasmaSettings.dx + vdx, ptime*s*plasmaSettings.dy*0.3 + vdy),
						new flash.geom.Point(ptime*s*plasmaSettings.dx*0.3 + vdx*0.9, ptime*s*plasmaSettings.dy + vdy*0.9),
						//new flash.geom.Point(ptime*s*0.32, -ptime*0.21*s),
					];
					//plasma.perlinNoise(16,32, 2, 0, true, false, 1, true, off);
					plasma.perlinNoise(plasmaSettings.w, plasmaSettings.h, 2, 0, true, false, 1, true, off);
					plasma.threshold(plasma, plasma.rect, new flash.geom.Point(0,0), ">", mt.deepnight.Color.addAlphaF(0x232323), 0x0, 0xffFFFFFF, true);
					plasma.applyFilter(plasma, plasma.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(4,4));
				}
				ptime++;
			}

			// Anim de réveil
			if( ended && wakeUp!=null ) {
				if( perf<=0.6 )
					wakeUp.visible = false;
				else {
					if( rendering ) {
						wakeUp.bitmapData.copyPixels( wakeUpOriginal, wakeUpOriginal.rect, new flash.geom.Point(0,0) );
						var offsets = [ new flash.geom.Point(0, -wakeTimer*400) ];
						wakeDistort.perlinNoise(64,32, 1, seed, false, true, 1, true, offsets);
						//wakeDistort.perlinNoise(64,32, 1, seed, false, true, 1, true);
						//var amp = wakeTimer*perf;
						wakeUp.bitmapData.applyFilter(
							wakeUp.bitmapData, wakeUp.bitmapData.rect, new flash.geom.Point(0,0),
							new flash.filters.DisplacementMapFilter(
								wakeDistort, new flash.geom.Point(0,0), 1,1,
								Math.sin(3.14*wakeTimer*0.5)*64,
								Math.sin(3.14*wakeTimer*0.5)*16,
								flash.filters.DisplacementMapFilterMode.WRAP, 0xffffff)
						);
						if( perf>=0.7 ) {
							var b = Math.min(32, wakeTimer*10);
							wakeUp.bitmapData.applyFilter( wakeUp.bitmapData, wakeUp.bitmapData.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(b,b) );
						}
					}
					wakeTimer+=0.006;
				}
				//if( wakeTimer<3 )
				//wakeTimer*=1.03;
				//wakeUp.filters = [
					//new flash.filters.DisplacementMapFilter(wakeDistort, new flash.geom.Point(0,0), 1,1, 16,16, flash.filters.DisplacementMapFilterMode.COLOR, 0x0),
				//];
			}

			// Arc en ciel
			if( perf>=0.7 ) {
				if( rendering ) {
					if( !rainbow.visible )
						rainbow.visible = true;
					rainbow.x = viewport.x;
					rainbow.y = viewport.y;
					var bd = rainbow.bitmapData;
					if( absoluteTime%2==0 )
						bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(2,2));
					bd.colorTransform( bd.rect, RAINBOW_LOSS );
				}
			}
			else
				if( rainbow.visible )
					rainbow.visible = false;


			// Barre progression
			if( isProgression() && time%3==0 ) {
				api.AKApi.setProgression( curRoom.distance/(Room.ALL.length-1) );
			}

			//api.AKApi.emitEvent( Std.int(player.rx+player.ry) );
			time++;
		}

		if ( shopping ) {
			// Dans la boutique
			if( shopKeyCD>0 )
				shopKeyCD--;
			if( shopBuyCD>0 )
				shopBuyCD--;

			if( shopKeyCD<=0 ) {
				if( AKApi.isToggled(Keyboard.UP) && curItem>0 )
					api.AKApi.emitEvent(100+curItem-1);
				if( AKApi.isToggled(Keyboard.DOWN) && curItem<ShopItem.ALL.length-1 )
					api.AKApi.emitEvent(100+curItem+1);
				if( AKApi.isToggled(Keyboard.ESCAPE) )
					api.AKApi.emitEvent(2);
				if( shopBuyCD<=0 && actionKeyToggled() )
					api.AKApi.emitEvent(1);

				var eid = api.AKApi.getEvent();
				while( eid!=null ) {
					if( eid==2 )
						leaveShop();
					else if( eid==1 )
						ShopItem.ALL[curItem].buy()
					else if( eid>=100 ) {
						ShopItem.ALL[curItem].setActive(false);
						curItem = eid-100;
						ShopItem.ALL[curItem].setActive(true);
					}
					eid = api.AKApi.getEvent();
				}
			}


			// Plasma
			if( rendering /*&& stime%2==0*/ ) {
				var bd = shopPlasma.bitmapData;
				var s = 0.35;
				var off = [
					new flash.geom.Point(-stime*s*0.10, stime*s*0.5),
					new flash.geom.Point(stime*s*0.40, stime*s*0.23),
				];
				bd.perlinNoise(8,16, 2, seed, false, true, 1, true, off);
				bd.threshold(bd, bd.rect, new flash.geom.Point(0,0), "<", mt.deepnight.Color.addAlphaF(0x787878), 0x0, 0xffFFFFFF, true);
				bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(8,8));
			}

			//var e = null;
			//while( ( e = api.AKApi.getEvent() ) != null ) {
				//if( e==0 ) {
					//ShopItem.ALL[curItem].setActive(false);
					//curItem--;
					//ShopItem.ALL[curItem].setActive(true);
				//}
				//if( e==1 ) {
					//ShopItem.ALL[curItem].setActive(false);
					//curItem++;
					//ShopItem.ALL[curItem].setActive(true);
				//}
				//if( e>=100 && e<=199 ) {
					//ShopItem.ALL[curItem].setActive(false);
					//curItem = e-100;
					//ShopItem.ALL[curItem].setActive(true);
				//}
				//if( e>=200 && e<=299 ) {
					//var iid = e-200;
					//ShopItem.ALL[iid].buy();
				//}
			//}

			stime++;

		}

		fx.update();
		TW.update();

		//var t = flash.Lib.getTimer()-t;
		//if( t>10 )
			//trace("update "+t+"ms");
	}

}
