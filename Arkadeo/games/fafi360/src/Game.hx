import api.AKApi;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.flash.Volatile;
import mt.deepnight.Buffer;
import mt.deepnight.deprecated.SpriteLibBitmap;
import mt.deepnight.Tweenie;
import mt.deepnight.Cinematic;
import mt.flash.DepthManager;
import mt.Delayer;

import TitleLogo;
import TeamInfos;

@:bitmap("png/tiles.png") class GfxTiles extends BitmapData {}

enum GamePhase {
	Init;
	ChoosePerk;
	TeamAnnounce;
	Waiting(endTime:Float, suspend:Bool, onEnd:Void->Void);
	WaitingPlayers;
	Playing;
	End(time:Float);
}

enum Font {
	FSmall;
	FBig;
	FTime;
}

class Game extends Sprite implements game.IGame {
	public static var PERK_LEVELS = AKApi.aconst([2,5,7,9,11,13,15,17,19]);
	public static var ME : Game;
	public static var UPSCALE = 2;
	public static var FPS = 30;

	static var BEGIN_CHARGE_0 = 0;
	static var END_CHARGE_0 = 1;
	static var BEGIN_CHARGE_1 = 2;
	static var END_CHARGE_1 = 3;
	static var RUN_0 = 4;
	static var RUN_1 = 5;
	static var CHOOSE_UPGRADE_0 = 6;
	static var CHOOSE_UPGRADE_1 = 7;
	static var GLUE_THRESHOLD : UInt = 0x8D8D8D;
	static var WATER_THRESHOLD : UInt = 0;
	static var WATER_THRESHOLD1 : UInt = 0x939393;
	static var WATER_THRESHOLD2 : UInt = 0x747474;

	//static inline var BG_SIZE = {w:120, h:120}

	public static var SNOW_SCALE = 2;

	public static inline var PASS_THRESHOLD = 5;

	static var _uniq = 0;
	public static var DP_BG1 = _uniq++;
	public static var DP_SNOW = _uniq++;
	public static var DP_BG2 = _uniq++;
	public static var DP_FX_BG = _uniq++;
	public static var DP_ZSORTABLES = _uniq++;
	public static var DP_GOAL_CAGE = _uniq++;
	public static var DP_FX = _uniq++;
	public static var DP_INTERF = _uniq++;
	public static var DP_BG_SCROLL = _uniq++;
	public static var DP_MENU = _uniq++;
	public static var DP_TIP = _uniq++;

	public static var FIELD_RATIO = 90/120;
	public static inline var GRID = 16;
	public static var WID = 600;
	public static var HEI = 460;
	public static var FPADDING = 8;
	public static var FWID = 45;
	public static var FHEI = 34;

	public static var BG_SCROLL_REPEAT = 3;

	static var GOAL_VALUE = AKApi.const(1);
	static var GOAL_SCORE = AKApi.const(1500);

	public var buffer		: Buffer;
	//var tip					: mt.deepnight.deprecated.Tip;
	public var scroller		: Sprite;
	public var dm			: DepthManager;
	public var sdm			: DepthManager;
	public var viewport		: flash.geom.Rectangle;
	public var zsortLayer	: Sprite;
	public var fx			: Fx;
	public var tw			: Tweenie;
	public var tiles		: SpriteLibBitmap;
	public var cd			: mt.Cooldown;
	public var cm			: Cinematic;
	public var delayer		: Delayer;
	var fl_stopped			: Bool;
	var charging			: Bool;
	var fl_stageReady		: Bool;
	var engager				: Volatile<Int>;
	public var allowRun		: Volatile<Bool>;
	public var grass		: BitmapData;
	public var ground		: BitmapData;
	var waterPerlin			: BitmapData;
	var mudPerlin			: BitmapData;
	var snow				: Bitmap;
	var snowFlattened		: Bool;
	var miniMap				: Bitmap;
	var miniMapVisible		: Bool;
	var snowCache			: Map<Int,Bool>;

	var kbPanX				: Float;
	var kbPanY				: Float;

	public var round		: Volatile<Int>;
	public var scores		: Array<api.AKConst>;
	public var controlTimes	: Array<Float>;
	public var scoreTarget	: api.AKConst;
	public var seed			: Volatile<Int>;
	public var rseed		: mt.Rand;
	public var time			: Volatile<Int>;
	public var totalDuration: Int;
	public var colMap		: Array<Array<Float>>;

	public var chrono		: Volatile<Float>;
	var chronoField			: flash.text.TextField;
	var chronoBg			: lib.Bg_score;
	public var diff			: Volatile<Float>; // ********************* TODO gérer difficulté !
	public var pass			: Volatile<Int>;
	public var passField	: flash.text.TextField;
	public var scoreField	: flash.text.TextField;

	public var ball			: en.Ball;
	public var items		: Array<GenericItem>;
	public var miscEntities	: Array<Entity>;
	public var allPlayers	: Array<en.Player>;
	public var playerTeam	: TeamInfos;
	public var oppTeam		: TeamInfos;
	public var zsortables	: Array<Entity>;
	public var killList		: Array<Entity>;
	public var goals		: Array<Bitmap>;
	var timeWarning			: Bitmap;
	var perkQuestion		: Sprite;
	var bgScroll			: Null<Bitmap>;
	var perkList			: Sprite;
	var spawner				: Array<{t:Float, cb:Void->Void}>;

	var mouseOutside		: Bool;
	var outTimer			: Int;
	var clickStart			: Int;
	var phase				: GamePhase;
	var perlin				: BitmapData;
	var powerBar			: { wrapper:Sprite, bar:Sprite };
	public var lowq			: Bool;

	var lastAnnounce		: Null<lib.Annonce>;

	var stats				: Map<String,api.AKConst>;

	//var blur				: Bitmap;

	public function new() {
		super();

		ME = this;
		haxe.Log.setColor(0xFFFF00);

		var raw = haxe.Resource.getString(api.AKApi.getLang());
		if( raw==null ) raw = haxe.Resource.getString("en");
		Lang.init(raw);

		lowq = AKApi.isLowQuality();
		//FPS = Std.int( AKApi.getBaseFramerate() ); // TODO bug fps
		tw = new Tweenie( FPS );
		cm = new Cinematic();
		delayer = new Delayer();
		seed = AKApi.getSeed();
		rseed = new mt.Rand(0);
		kbPanX = kbPanY = 0;
		initSeed();
		allowRun = true;
		scores = [AKApi.const(0),AKApi.const(0)];
		controlTimes = [0,0];
		fl_stageReady = false;
		scoreTarget = AKApi.const(1);
		totalDuration = 0;
		#if multi
		engager = rseed.random(2);
		#else
		engager = 0;
		#end
		cd = new mt.Cooldown();
		fl_stopped = false;
		snowCache = new Map();
		diff = 0;
		pass = 0;
		round = -1;
		charging = false;
		mouseOutside = true;
		spawner = new Array();
		items = new Array();
		miscEntities = new Array();
		killList = new Array();
		allPlayers = new Array();
		zsortables = new Array();
		goals = new Array();
		time = 0;
		outTimer = 0;
		clickStart = -1;
		stats = new Map();
		snowFlattened = false;
		phase = Init;

		playerTeam = new TeamInfos();
		playerTeam.color = 0x3980F4;
		playerTeam.name = AKApi.getUserName();
		if( playerTeam.name==null )
			playerTeam.name = "#missingName";
		if( isProgression() )
			playerTeam.loadPerks( AKApi.getState() );
		#if debug
		playerTeam.skill = AKApi.const(1);
		//playerTeam.addPerk(_PDoubleAttack);
		#end

		oppTeam = new TeamInfos();
		if( isProgression() )
			oppTeam.setProgressionLevel(AKApi.getLevel());

		if( isLeague() )
			chrono = 1.5 * 60 * FPS;
		if( isProgression() )
			chrono = 2 * 60 * FPS;

		//#if !prod chrono = 2 * FPS; #end // HACK

		fx = new Fx();

		tiles = new SpriteLibBitmap( new GfxTiles(0,0) );
		tiles.setDefaultCenter(0,0);
		tiles.setSliceGrid(16,16);
		tiles.slice("ballTexture", 0,0, 24,36, 2);
		tiles.sliceGrid("smoke", 0,4);

		genField();

		dm = new DepthManager(this);

		buffer = new Buffer(Math.ceil(WID/UPSCALE),Math.ceil(HEI/UPSCALE), UPSCALE, false, 0x0);
		dm.add(buffer.render, DP_BG1);
		//if( UPSCALE>1 )
			//buffer.setTexture( Buffer.makeScanline(0x0, 4), 0.2, true );

		viewport = new flash.geom.Rectangle(1000, GRID*(FPADDING+FHEI*0.5)-buffer.height*0.5, buffer.width, buffer.height);

		scroller = new Sprite();
		buffer.dm.add(scroller, DP_BG1);
		sdm = new DepthManager(scroller);

		zsortLayer = new Sprite();
		sdm.add(zsortLayer, DP_ZSORTABLES);

		perlin = new BitmapData(300,300, false, 0x0);
		perlin.perlinNoise(64,128,1, seed, true, false, 1, true);
		//buffer.addChild( new Bitmap(perlin) );

		// Barre de puissance de tir
		var w = new Sprite();
		w.graphics.beginFill(0x222331, 0.7);
		w.graphics.lineStyle(1, 0x0, 1);
		w.graphics.drawRect(0,0, 16,3);
		var b = new Sprite();
		w.addChild(b);
		b.graphics.beginFill(0xFDD700, 1);
		b.graphics.drawRect(0,0, w.width,w.height);
		b.filters = [ new flash.filters.GlowFilter(0xFD9200, 0.8, 4,4,2) ];
		b.blendMode = flash.display.BlendMode.ADD;
		powerBar = {wrapper:w, bar:b};
		sdm.add(powerBar.wrapper, DP_INTERF);

		drawStadium();

		// Mini map
		miniMap = new Bitmap( new BitmapData(FWID, FHEI, false, 0x0) );
		dm.add(miniMap, DP_INTERF);
		miniMap.scaleX = miniMap.scaleY = 3;
		miniMap.alpha = 0.6;
		miniMap.x = 3;
		miniMap.y = HEI;
		miniMap.bitmapData.fillRect(miniMap.bitmapData.rect, 0x0);
		miniMapVisible = false;

		// Tooltip
		//tip = new mt.deepnight.Tip( new mt.deepnight.Tip.TipSprite(0x0, 0xffffff));
		//tip.setFont(8, "big");
		//tip.bgFilters = [];
		//dm.add(tip.spr, DP_TIP);

		// Joueurs
		#if multi
		for(i in 0...11) {
			new en.Player(0);
			new en.Player(1);
		}
		#else
		for(i in 0...11)
			new en.Player(0, playerTeam);
		for(i in 0...oppTeam.playerCount.get())
			new en.Player(1, oppTeam);
		#end

		// Ballon
		ball = new en.Ball();
		ball.owner = playerTeam.players[0];
		ball.xx = ball.owner.xx;
		ball.yy = ball.owner.yy;

		var s = new Sprite();
		var h = 0.3;
		var m = new flash.geom.Matrix();
		m.createGradientBox(buffer.width, buffer.height*h, Math.PI*0.5, 0,buffer.height*h*0.5);
		s.graphics.beginGradientFill(flash.display.GradientType.RADIAL, [0xFF0000,0xFF0000], [1,0], [0,255], m);
		s.graphics.drawRect(0,0, buffer.width,buffer.height*h);
		timeWarning = mt.deepnight.Lib.flatten(s);
		timeWarning.y = Math.ceil(buffer.height*(1-h));
		timeWarning.blendMode = flash.display.BlendMode.ADD;
		timeWarning.visible = false;
		buffer.dm.add(timeWarning, DP_INTERF);


		// Compteur temps
		chronoBg = new lib.Bg_score();
		buffer.dm.add(chronoBg, DP_INTERF);
		chronoField = createField("0:00", FTime);
		buffer.dm.add(chronoField, DP_INTERF);
		chronoField.scaleX = chronoField.scaleY = 2;
		chronoField.y = buffer.height-20;
		chronoField.filters = [];
		chronoField.blendMode = flash.display.BlendMode.ADD;
		chronoBg.x = Std.int( buffer.width*0.5 - chronoBg.width*0.5 );
		chronoBg.y = buffer.height-18;
		updateChrono();

		// Score
		var wrapper = new Sprite();
		scoreField = createField("00 - 00", FSmall, true);
		scoreField.scaleX = scoreField.scaleY = 2;
		scoreField.y = -9;
		scoreField.textColor = 0x0;
		scoreField.filters = [
			new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.4, 2,2,1)
		];
		//scoreField.filters = [];
		wrapper.addChild(scoreField);
		AKApi.setStatusMC(wrapper, "center");
		updateScore();

		// Compteur passes
		passField = createField("???");
		buffer.dm.add(passField, DP_INTERF);
		passField.scaleX = passField.scaleY = 2;
		passField.y = -3;
		passField.filters = [];
		onPassChange();

		// Init des bonus temps
		var n = rseed.random(3)+1;
		for(i in 0...n)
			spawner.push({
				t	: Std.int(chrono*rseed.range(0.1, 0.8)),
				cb	: function() new it.Time(),
			});

		// Init des supers bonus
		if( isLeague() ) {
			var rlist = new mt.RandList();
			rlist.add( 5, 200 );
			rlist.add( 6, 100 );
			rlist.add( 7, 70 );
			rlist.add( 8, 30 );
			rlist.add( 9, 10 );
			rlist.add( 11, 5 );
			rlist.add( 13, 2 );
			var n = rlist.draw(rseed.random);
			for(i in 0...n)
				spawner.push({
					t	: Std.int(chrono*rseed.range(0.1, 0.9)),
					cb	: function() new it.Bonus(true),
				});
		}

		spawner.sort( function(a,b) return Reflect.compare(a.t, b.t) );

		#if !multi
		for( pk in AKApi.getInGamePrizeTokens() )
			new it.KPoint(pk);
		#end
	}

	public function drawCollisions() {
		#if debug
		var s = new Sprite();
		var g = s.graphics;
		g.beginFill(0xFF0000, 0.5);
		for( x in 0...FWID+FPADDING*2 )
			for( y in 0...FHEI+FPADDING*2 )
				if( colMap[x][y]>0 )
					g.drawRect(x*GRID, y*GRID, GRID,GRID);
		ground.draw(s);
		#end
	}

	public inline function isLeague() {
		return AKApi.getGameMode()==api.AKProtocol.GameMode.GM_LEAGUE;
	}

	public inline function isProgression() {
		return AKApi.getGameMode()==api.AKProtocol.GameMode.GM_PROGRESSION;
	}

	public inline function addStat(k:String, n:Int) {
		getStat(k).add( AKApi.const(n) );
		//stats.set( k, getStat(k)+n );
	}

	public inline function getStat(k:String) {
		if( !stats.exists(k) )
			stats.set(k, AKApi.const(0));
		return stats.get(k);
	}

	public function isPerkLevel(level:Int) {
		for(l in PERK_LEVELS)
			if( l.get()==level )
				return true;
		return false;
	}

	public function onStageReady() {
		fl_stageReady = true;
		addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
		stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, function(_) { kbPanX=kbPanY=0; mouseOutside=false; } );
		stage.addEventListener(flash.events.Event.MOUSE_LEAVE, function(_) { mouseOutside = true; outTimer = 30; } );

		#if !multi
		AKApi.setUseMouse(true);
		AKApi.setMouseArcade(true);
		#end

		newRound(true);
		//#if debug onLeagueGoal(); #end // HACK

		if( isProgression() ) {
			if( isPerkLevel(AKApi.getLevel()) )
				askPerk();
			else {
				AKApi.saveState( playerTeam.savePerks() );
				applyPerks();
				announceTeam();
			}
		}
	}

	function onLeagueGoal() {
		initSeed(round);

		new en.Player(1, oppTeam);

		var olist = [5,7,8];
		for(i in 0...rseed.random(2))
			new en.Obstacle( olist[rseed.random(olist.length)] );

		for(i in 0...rseed.random(4)-1)
			new en.Mine();

		if( getPlayerScore()>=3 && oppTeam.getSkill()==0 )
			oppTeam.skill.add( AKApi.const(1) );

		if( getPlayerScore()>=7 )
			oppTeam.addPerk(_PGoalJump);

		if( getPlayerScore()>=9 && oppTeam.getSkill()==1 )
			oppTeam.skill.add( AKApi.const(1) );
	}

	function onProgressionGoal() {
		initSeed(round);

		if( oppTeam.hasPerk(_PKamikaze) )
			new en.Player(1, oppTeam);

		if( oppTeam.hasPerk(_PMineField) )
			for(i in 0...rseed.random(3)+1)
				new en.Mine();
	}


	function getPerkSelection() {
		initSeed();

		var allPerks = playerTeam.getUnusedPlayerPerks();
		for(p in allPerks)
			if( playerTeam.hasPerk(p) )
				allPerks.remove(p);

		var plist = [];
		for(i in 0...2)
			plist.push( allPerks.splice(rseed.random(allPerks.length),1)[0] );

		return plist;
	}


	function hideBgScroll() {
		tw.create(bgScroll, "alpha", 0, 500).onEnd = function() {
			bgScroll.parent.removeChild(bgScroll);
			bgScroll.bitmapData.dispose();
		}
	}

	function showBgScroll(?fadeIn=true) {
		var base = mt.deepnight.Lib.flatten( new lib.Damier() ).bitmapData;
		var t = new Sprite();
		t.graphics.beginFill(0x162F6D,1);
		t.graphics.drawRect(0,0, base.width*BG_SCROLL_REPEAT, base.height*BG_SCROLL_REPEAT);
		t.graphics.beginBitmapFill(base, true, false);
		t.graphics.drawRect(0,0, base.width*BG_SCROLL_REPEAT, base.height*BG_SCROLL_REPEAT);
		bgScroll = mt.deepnight.Lib.flatten(t);
		buffer.dm.add(bgScroll, DP_INTERF);

		//#if debug
		//var bmp = mt.deepnight.Lib.flatten(t);
		//bmp.scaleX = bmp.scaleY = 0.6;
		//addChild(bmp);
		//#end

		if( fadeIn ) {
			bgScroll.alpha = 0;
			tw.create(bgScroll,"alpha", 1, 700);
		}

		base.dispose();
	}


	public function onPerkSelect(id:Int) {
		var plist = getPerkSelection();
		playerTeam.addPerk(plist[id]);
		AKApi.saveState( playerTeam.savePerks() );

		var tf = createField( TeamInfos.getPerkText(plist[id]).name, true );
		buffer.dm.add(tf, DP_INTERF);
		tf.x = Std.int( buffer.width*0.5 - tf.textWidth*0.5 );
		tf.y = Std.int( buffer.height );
		cm.create({
			tw.create( tf, "y", tf.y-40, TEaseOut, 500 );
			2500;
			tw.create( tf, "y", tf.y+40, TEaseOut, 500 ).onEnd = function() {
				tf.parent.removeChild(tf);
			}
		});

		hideBgScroll();

		wait(500, announceTeam);
		perkQuestion.mouseChildren = perkQuestion.mouseEnabled = false;
		tw.create(perkList, "y", perkList.y+70, 500).onEnd = function() {
			perkList.parent.removeChild(perkList);
		}
		tw.create(perkQuestion, "alpha", 0, 500).onEnd = function() {
			perkQuestion.parent.removeChild(perkQuestion);
		}

		applyPerks();
	}

	public function applyPerks() {
		// Décor
		if( oppTeam.hasPerk(_PRocks) )
			for(i in 0...(oppTeam.getSkill()==0 ? 5 : 12))
				new en.Obstacle(5);

		if( oppTeam.hasPerk(_PPumpkins) )
			for(i in 0...9)
				new en.Obstacle(2);

		if( oppTeam.hasPerk(_PMissiles) )
			for(i in 0...15)
				new en.Obstacle(1);

		if( oppTeam.hasPerk(Perk._PMineField) )
			for(i in 0...12)
				new en.Mine();

		// Caracts des joueurs
		for(p in allPlayers)
			p.updateStats();

		// Temps
		if( playerTeam.hasPerk(_PExtraTime1) )
			chrono+= 0.5*60*FPS;
		if( playerTeam.hasPerk(_PExtraTime2) )
			chrono+= 0.5*60*FPS;
		updateChrono();

		// NEIGE
		if( hasSnow() ) {
			if( snow!=null ) {
				snow.bitmapData.dispose();
				snow.parent.removeChild(snow);
			}
			var c = 0xC4D3D7;
			var w = GRID*(FWID+FPADDING*2);
			var h = GRID*(FHEI+FPADDING*2);
			snow = new Bitmap( new BitmapData(Math.ceil(w/SNOW_SCALE),Math.ceil(h/SNOW_SCALE),true,0x0), flash.display.PixelSnapping.NEVER, false );
			sdm.add(snow, DP_SNOW);
			snow.bitmapData.fillRect( snow.bitmapData.rect, mt.deepnight.Color.addAlphaF(c) );
			var ct = new flash.geom.ColorTransform(1,1,1, 0.3);
			//snow.bitmapData.draw(texture, ct, flash.display.BlendMode.OVERLAY);
			snow.scaleX = snow.scaleY = SNOW_SCALE;
			snow.alpha = 0.9;
			snow.filters = [
				new flash.filters.GlowFilter(c,0.5, 4,4,1),
				new flash.filters.GlowFilter(0xffffff,0.5, 2,2,1, 1,true),
			];
			var perlin = snow.bitmapData.clone();
			perlin.perlinNoise(16,8, 1,seed, true,false, 1, true);
			snow.bitmapData.draw(perlin, new flash.geom.ColorTransform(1,1,1, 0.2), flash.display.BlendMode.OVERLAY);
			perlin.dispose();

			if( lowq )
				flattenSnow();
		}
	}

	public function askPerk() {
		setPhase(ChoosePerk);

		showBgScroll(false);

		var wrapper = new Sprite();
		perkQuestion = wrapper;
		dm.add(wrapper, DP_MENU);
		wrapper.scaleX = wrapper.scaleY = 2;

		// Perks précédents
		var all = playerTeam.getPerks();
		perkList = new Sprite();
		dm.add(perkList, DP_MENU);
		if( all.length>0 ) {
			var w = 63;
			var h = 30;
			perkList.graphics.beginFill(0x0, 0.3);
			perkList.graphics.drawRect(0,0,WID, h+10);
			perkList.y = HEI-perkList.height;
			var i = 0;
			for( p in all ) {
				var spr = new Sprite();
				perkList.addChild(spr);
				spr.x = 5 + i*(w+3);
				spr.y = 5;
				spr.alpha = 0.7;
				spr.graphics.beginFill(0xB7DDF9, 1);
				//spr.graphics.drawRect(0,0,50,50);
				spr.graphics.drawRoundRect(0,0,w,h, 4);

				var tf = createField( TeamInfos.getPerkText(p).name );
				spr.addChild(tf);
				tf.textColor = 0x202864;
				tf.filters = [];
				tf.width = w-4;
				tf.multiline = tf.wordWrap = true;
				tf.height = 50;
				tf.x = Std.int(w*0.5-tf.textWidth*0.5);
				tf.y = Std.int(h*0.5-tf.textHeight*0.5-4);

				if( !AKApi.isReplay() ) {
					spr.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) {
						spr.alpha = 1;
						//tip.showAbove(spr, TeamInfos.getPerkText(p).desc);
					});
					spr.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) {
						spr.alpha = 0.7;
						//tip.hide();
					});
				}

				i++;
			}
		}

		var f = new flash.filters.DropShadowFilter(9,110, 0x0,0.1, 8,8,2);

		// Titre
		var title = createField(Lang.ChoosePerk, FBig, true);
		wrapper.addChild(title);
		title.textColor = 0xFFF3A4;
		title.x = Std.int( buffer.width*0.5 - title.textWidth*0.5 );
		title.y = 20;
		title.filters = [ new flash.filters.GlowFilter(0xFFC846,0.8, 16,16,1, 2) ];
		title.filters = [f];

		// Choix
		var plist = getPerkSelection();
		var y = 50;
		for(i in 0...plist.length) {
			var p = plist[i];
			var data = TeamInfos.getPerkText(p);
			var h = 55;

			// Bouton
			var hit = new Sprite();
			wrapper.addChild(hit);
			hit.graphics.beginFill(0xFFFFFF, 0.2);
			hit.graphics.drawRect(0,0,buffer.width,h);
			hit.filters = [ new flash.filters.GlowFilter(0x00FFFF,0.5, 16,16,1) ];
			hit.y = y;
			hit.alpha = 0;
			hit.buttonMode = hit.useHandCursor = true;
			if( !AKApi.isReplay() ) {
				hit.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) hit.alpha = 1 );
				hit.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) hit.alpha = 0 );
				hit.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
					AKApi.emitEvent(i==0 ? CHOOSE_UPGRADE_0 : CHOOSE_UPGRADE_1);
				});
			}

			// Nom
			var tf = createField(data.name.toUpperCase(), FBig, true);
			var name = tf;
			wrapper.addChild(tf);
			tf.x = Std.int( buffer.width*0.5 - tf.textWidth*0.5 );
			tf.filters = [ new flash.filters.GlowFilter(0xFFFF00,0.2, 8,8,1) ];
			tf.filters = [f];

			// Desc
			var tf = createField(data.desc, FSmall, true);
			var desc = tf;
			wrapper.addChild(tf);
			tf.multiline = tf.wordWrap = true;
			tf.width = 200;
			tf.height = 50;
			tf.textColor = 0xB7DDF9;
			tf.x = Std.int( buffer.width*0.5 - tf.textWidth*0.5 );
			tf.filters = [f];

			name.y = Std.int(y + h*0.5 + 5 - (name.textHeight+desc.textHeight+15)*0.5);
			desc.y = name.y + 15;

			y+=20+h;
		}
	}

	function flattenSnow() {
		if( !hasSnow () || snow==null || snowFlattened )
			return;

		snowFlattened = true;

		var m = new flash.geom.Matrix();
		m.scale(SNOW_SCALE, SNOW_SCALE);
		grass.draw(snow, m, new flash.geom.ColorTransform(1,1,1, 0.9));
		snow.parent.removeChild(snow);
		snow.bitmapData.dispose();
		snow = null;
	}


	public inline function checkWaterPerlin(x:Float,y:Float) {
		return waterPerlin!=null && waterPerlin.getPixel(Std.int(x),Std.int(y)) >= WATER_THRESHOLD;
	}

	public inline function checkMudPerlin(x:Float,y:Float) {
		return mudPerlin!=null && mudPerlin.getPixel(Std.int(x),Std.int(y)) >= GLUE_THRESHOLD;
	}

	public inline function checkPerlin(x,y) {
		return perlin.getPixel(x%perlin.width, y%perlin.height) >= 0x444444;
	}

	public function initSeed(?inc=0) {
		rseed.initSeed(seed+inc*159);
	}

	public function onSuccessfulPass(e:Entity) {
		addStat("pass", 1);
		var p = Std.int( Math.min(10, pass) );
		var v = AKApi.const(50*p);
		addScore(v, "pass");
		fx.popScore(e.xx, e.yy, v.get());
		fx.popPass(e.xx, e.yy, p);
	}

	public inline function getPlayerScore() {
		return scores[0].get();
	}

	public inline function getOpponentScore() {
		return scores[1].get();
	}

	public inline function isPlaying() {
		return phase==Playing;
	}

	public inline function isWaitingPlayers() {
		return phase==WaitingPlayers;
	}

	public inline function isChoosingPerk() {
		return phase==ChoosePerk;
	}

	public inline function isSuspended() {
		return switch(phase) {
			case Waiting(t, suspend, n) : suspend;
			default : false;
		}
	}

	public inline function matchStarted() {
		return phase!=Init;
	}

	public inline function matchEnded() {
		return Type.enumIndex(phase)==Type.enumIndex(End(0));
	}

	public function setPhase(p:GamePhase) {
		if( matchEnded() )
			return;

		resetCharge();
		phase = p;
	}


	public function onPassChange() {
		tw.terminate(passField);

		//passField.scaleX = passField.scaleY = Math.min(4, pass);
		passField.x = Std.int( buffer.width*0.5 - passField.textWidth*0.5*passField.scaleX );
		passField.y = Std.int( 8 - passField.textHeight*0.5*passField.scaleY );
		passField.text = pass+" pass";
		passField.visible = pass>0;
		passField.visible = false;
		tw.create(passField,"y", passField.y+10, TLoop, 250).onUpdateT = function(t) {
			passField.filters = [ new flash.filters.GlowFilter(0xFFEC00, Math.sin(t*3.14), 16,16,2) ];
		}
	}


	public function addScore(v:api.AKConst, ?origin:String) {
		if( v.get()<= 0 )
			return;
		if( origin!=null )
			addStat("score_"+origin, v.get());
		api.AKApi.addScore( AKApi.const(v.get()) );
		//if( from!=null )
			//fx.popScore(from.xx, from.yy, v.get(), color);
	}

	public function announceTeam() {
		//#if debug
		//setPhase(WaitingPlayers);
		//#else
		setPhase(TeamAnnounce);

		var mc = new lib.Versus();
		buffer.dm.add(mc, DP_INTERF);
		var tf : flash.text.TextField = Reflect.field(mc._nameTeamA, "_field");
		tf.text = playerTeam.name;
		var tf : flash.text.TextField = Reflect.field(mc._nameTeamB, "_field");
		tf.text = oppTeam.name;

		var bmp : Bitmap;
		function _showObjective() {
			var tf = createField(Lang.Objective({_n:scoreTarget.get()}), true);
			tf.textColor = 0xFFFFFF;
			tf.filters = [
				new flash.filters.GlowFilter(0x00ACFF,1, 4,4,1),
			];
			bmp = mt.deepnight.Lib.flatten(tf);
			mc.addChild(bmp);
			bmp.scaleX = bmp.scaleY = 4;
			bmp.alpha = 0;
			tw.create(bmp, "alpha", 1, 100);
			tw.create(bmp, "scaleX", 1, TLinear, 150).onUpdate = function() {
				bmp.scaleY = bmp.scaleX;
				bmp.x = Std.int(buffer.width*0.5 - bmp.width*0.5);
				bmp.y = Std.int(10 + buffer.height*0.5 - bmp.height*0.5);
			}
		}

		cm.create({
			2800 >> _showObjective();
			4000;
			tw.create(mc, "alpha", 0, 600).onEnd = function() {
				var tf = createField(Lang.NeededGoals({_n:scoreTarget.get()}), FBig, true);
				tf.filters = [ new flash.filters.GlowFilter(0x0,1, 4,4,2) ];
				var bmp = mt.deepnight.Lib.flatten(tf);
				dm.add(bmp, DP_INTERF);
				bmp.x = Std.int( WID*0.5 - bmp.width*0.5);
				bmp.y = -10;
				tw.create(bmp, "y", 3).fl_pixel = true;
				mc.parent.removeChild(mc);
				cm.signal();
			}
			end;
			1000;
			setPhase(WaitingPlayers);
		});
		//#end
	}


	public function announce(frame:Int, str:String, ?text=0xFFFF00, ?bg:Int) {
		removeAnnounce();

		var mc = new lib.Annonce();
		lastAnnounce = mc;
		buffer.dm.add(mc, DP_INTERF);
		mc.y = 90;
		mc._illu._sub.gotoAndStop(frame);
		mc._field.width = 400;
		mc._field.x = buffer.width;
		mc._field.y += 2;
		var tf = mc._field.getTextFormat();
		mc._field.setTextFormat(tf);
		mc._field.defaultTextFormat = tf;
		mc._field.text = str;
		mc._field.textColor = text;
		mc.play();
		//#if debug
		//mc.alpha = 0.4;
		//#end

		tw.create(mc._field, "x", -mc._field.textWidth, TLinear, 2500).onEnd = function() cm.signal("announce");

		if( bg!=null )
			mc._bg.filters = [ mt.deepnight.Color.getColorizeFilter(bg, 0.7, 0.3) ];
	}

	public function removeAnnounce() {
		if( lastAnnounce!=null ) {
			var mc = lastAnnounce;
			mc._illu.play();
			tw.create(mc, "alpha", 0, 800).onEnd = function () {
				mc.parent.removeChild(mc);
			}
			lastAnnounce = null;
		}
	}

	function drawGoal(side:Int) {
		var r = getGoalRectangle(side);

		var b = new BitmapData(GRID*5, (r.h+4)*GRID, true, 0x0);
		var f = b.clone();

		// Fond
		var top = new lib.But_back_shadow();
		b.draw(top, top.transform.matrix);
		var bottom = new lib.But_front_shadow();
		bottom.y = GRID*r.h;
		b.draw(bottom, bottom.transform.matrix);
		for(y in 3...r.h) {
			var mc = new lib.But_tile_shadow();
			mc.y = GRID*y;
			b.draw(mc, mc.transform.matrix);
		}

		// Filet
		var top = new lib.But_back();
		f.draw(top, top.transform.matrix);
		var bottom = new lib.But_front();
		bottom.y = GRID*r.h;
		f.draw(bottom, bottom.transform.matrix);
		for(y in 3...r.h) {
			var mc = new lib.But_tile();
			mc.y = GRID*y;
			f.draw(mc, mc.transform.matrix);
		}

		return { rect:r, front:f, ground:b }
	}

	public inline function hasSnow() {
		return oppTeam.hasPerk(Perk._PSnowTerrain);
	}

	public inline function hasLeather() {
		return oppTeam.hasPerk(Perk._PLeatherTerrain);
	}

	function drawStadium() {
		initSeed();
		var w = GRID*(FWID+FPADDING*2);
		var h = GRID*(FHEI+FPADDING*2);

		grass = new BitmapData(w,h, false, 0x4B7F48);
		var bmp1 = new Bitmap(grass, flash.display.PixelSnapping.NEVER, false);
		sdm.add(bmp1, DP_BG1);

		// Sol
		var s = new lib.Gazon();
		s.stop();
		if( oppTeam.hasPerk(Perk._PLeatherTerrain) )
			s.gotoAndStop(2);
		s.x = FPADDING*GRID;
		s.y = FPADDING*GRID;
		grass.draw(s, s.transform.matrix);

		// Saleté
		if( !oppTeam.hasPerk(_PGlueTerrain) && !oppTeam.hasPerk(Perk._PLeatherTerrain) ) {
			var dirt = new BitmapData(grass.width, grass.height, true, 0x0);
			for(i in 0...60) {
				var x,y;
				var tries = 500;
				do {
					x = GRID * ( rseed.random(FWID+FPADDING*2) );
					y = GRID * ( rseed.random(FHEI+FPADDING*2) );
				} while( !checkPerlin(x,y) && tries-->0 );
				var mc = new lib.Taches();
				mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
				mc.x = x;
				mc.y = y;
				mc.scaleX = mc.scaleY = rseed.range(2,3);
				mc.rotation = rseed.rand()*360;
				mc.alpha = rseed.range(0.4, 0.9);
				dirt.draw(mc, mc.transform.matrix, mc.transform.colorTransform, flash.display.BlendMode.MULTIPLY);
			}
			dirt.colorTransform( dirt.rect, mt.deepnight.Color.getColorizeCT(0x858043, 1) );
			grass.draw(dirt);
		}

		// Cuir
		if( oppTeam.hasPerk(Perk._PLeatherTerrain) ) {
			var x = 0;
			var y = 0;
			var d = 30;
			while(y<grass.height) {
				while(x<grass.width) {
					if( checkPerlin(x,y) ) {
						var mc = new lib.LeatherTexture();
						mc.x = x;
						mc.y = y;
						mc.gotoAndStop(rseed.random(mc.totalFrames)+1);
						grass.draw(mc, mc.transform.matrix, flash.display.BlendMode.OVERLAY);
					}
					x+=d;
				}
				x = 0;
				y+=d;
			}
		}

		// Noise
		var noise = mt.deepnight.Lib.flatten(new lib.Noise());
		var texture = new Sprite();
		texture.graphics.beginBitmapFill(noise.bitmapData, true);
		texture.graphics.drawRect(0,0,w,h);
		if( !oppTeam.hasPerk(Perk._PLeatherTerrain) )
			grass.draw(texture, flash.display.BlendMode.OVERLAY);

		// Teinte
		var teint : flash.filters.BitmapFilter = new flash.filters.ColorMatrixFilter();
		if( !oppTeam.hasPerk(Perk._PLeatherTerrain) ) {
			var grand = new mt.Rand(0);
			grand.initSeed( isProgression() ? AKApi.getLevel() : seed );
			var colors = [
				{c:0x0, r:0.},
				{c:0x806031, r:0.5},
				{c:0x40715F, r:0.5},
				{c:0x783848, r:0.5},
				{c:0xA35A4E, r:0.5},
				{c:0x6D4A30, r:0.8},
				{c:0x425B49, r:0.8},
				{c:0x732B37, r:0.5},
			];
			var c = colors[grand.random(colors.length)];
			if( c.r>0 ) {
				teint = mt.deepnight.Color.getColorizeFilter(c.c, c.r, 1-c.r);
				grass.applyFilter(grass, grass.rect, new flash.geom.Point(0,0), teint);
			}
		}


		// EAU
		if( oppTeam.hasPerk(Perk._PWetTerrain) ) {
			waterPerlin = new BitmapData(w,h,false,0x0);
			WATER_THRESHOLD = oppTeam.hasPerk(Perk._PExtraWater) ? WATER_THRESHOLD2 : WATER_THRESHOLD1;
			if( oppTeam.hasPerk(Perk._PExtraWater) )
				waterPerlin.perlinNoise(100,60,4, seed, true,true, 1, true);
			else
				waterPerlin.perlinNoise(150,100,4, seed, true,true, 1, true);
			var c = 0x0A599A;
			var bd = new BitmapData(w,h,true,0x0);
			bd.threshold(waterPerlin, waterPerlin.rect, new flash.geom.Point(0,0), ">", mt.deepnight.Color.addAlphaF(WATER_THRESHOLD), mt.deepnight.Color.addAlphaF(c));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0xffffff,0.4, 32,32,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(1,-90, 0xffffff,0.3, 2,2,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(20,90, 0xffffff,0.3, 16,16,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0xffffff,0.8, 2,2,1));
			grass.draw(bd, new flash.geom.ColorTransform(1,1,1,0.4), flash.display.BlendMode.NORMAL);
		}

		// BOUE
		if( oppTeam.hasPerk(Perk._PGlueTerrain) ) {
			mudPerlin = new BitmapData(w,h,false,0x0);
			mudPerlin.perlinNoise(130,100,4, seed, true,true, 1, true);
			//var c = 0xAAA60D;
			var c = 0x733582;
			var bd = new BitmapData(w,h,true,0x0);
			bd.threshold(mudPerlin, mudPerlin.rect, new flash.geom.Point(0,0), ">", mt.deepnight.Color.addAlphaF(GLUE_THRESHOLD), mt.deepnight.Color.addAlphaF(c));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0xffffff,0.4, 32,32,1, 1,true));
			//bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(4,4, 2));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(1,-90, 0xffffff,0.5, 2,2,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x4B7843,1, 16,16,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.DropShadowFilter(20,90, 0xffffff,0.1, 16,16,1, 1,true));
			bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.GlowFilter(0x4B7843,0.7, 4,4,1));
			grass.draw(bd, new flash.geom.ColorTransform(1,1,1,0.7), flash.display.BlendMode.NORMAL);
		}


		// Fleurs
		if( !oppTeam.hasPerk(Perk._PLeatherTerrain) )
			for(i in 0...120) {
				var mc = new lib.Item_deco();
				mc.x = GRID * ( rseed.random(FWID+FPADDING*2) );
				mc.y = GRID * ( rseed.random(FHEI+FPADDING*2) );
				mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
				mc.alpha = rseed.rand()*0.3 + 0.5;
				mc.filters = [teint];
				grass.draw(mc, mc.transform.matrix, mc.transform.colorTransform);
			}

		// ÉLÉMENTS AVANT
		var top_bd = new BitmapData(w,h, true, 0x0);
		var bmp = new Bitmap(top_bd, flash.display.PixelSnapping.NEVER, false);
		sdm.add(bmp, DP_BG2);

		// Public gauche
		if( !oppTeam.hasPerk(Perk._PPlayerLargeCage) ) {
			var mc = new lib.Public_cotes();
			mc.x = 72;
			//mc.filters = [teint];
			top_bd.draw(mc, mc.transform.matrix);
		}

		// Public droite
		if( !oppTeam.hasPerk(_PRandomCage) && !oppTeam.hasPerk(_PCornerCage) && oppTeam.hasPerk(_PLargeCage) ) {
			var mc = new lib.PublicDroit();
			mc.x = 72;
			//mc.filters = [teint];
			top_bd.draw(mc, mc.transform.matrix);
		}

		// Gradins
		var mc = new lib.Gradins_fixe();
		mc.x = FPADDING*GRID;
		//mc.filters = [teint];
		top_bd.draw(mc, mc.transform.matrix);

		// Mur
		var mc = new lib.Muret();
		mc.x = FPADDING*GRID-10;
		mc.y = FPADDING*GRID-14;
		//mc.filters = [teint];
		top_bd.draw(mc, mc.transform.matrix, mc.transform.colorTransform);

		// Trous des buts
		var r = getGoalRectangle(0);
		top_bd.fillRect(new flash.geom.Rectangle(r.x*GRID,r.y*GRID-15, 20+r.w*GRID, r.h*GRID+10), 0x0);
		var r = getGoalRectangle(1);
		top_bd.fillRect(new flash.geom.Rectangle(r.x*GRID-20,r.y*GRID-15, r.w*GRID, r.h*GRID+10), 0x0);

		// But 0
		var g = drawGoal(0);
		var m = new flash.geom.Matrix();
		m.translate( GRID*(g.rect.x-1)-10, GRID*(g.rect.y-3));
		top_bd.draw(g.ground, m);
		var bmp = new Bitmap(g.front);
		sdm.add(bmp, DP_GOAL_CAGE);
		bmp.transform.matrix = m;
		goals[0] = bmp;

		// But 1
		var g = drawGoal(1);
		var m = new flash.geom.Matrix();
		m.scale(-1, 1);
		m.translate(g.ground.width, 0);
		m.translate( GRID*(g.rect.x)-5, GRID*(g.rect.y-3));
		top_bd.draw(g.ground, m);
		var bmp = new Bitmap(g.front);
		sdm.add(bmp, DP_GOAL_CAGE);
		bmp.transform.matrix = m;
		goals[1] = bmp;


		ground = new BitmapData(w,h, true, 0x0);
		sdm.add(new Bitmap(ground), DP_BG2);
	}

	public inline function snowHole(x:Float,y:Float, ?alpha=0.5) {
		if( snow!=null && !snowFlattened ) {
			var x = x/SNOW_SCALE;
			var y = y/SNOW_SCALE;
			if( !snowCache.exists(Std.int(x+y*snow.width)) )	{
				snowCache.set(Std.int(x+y*snow.width), true);
				var mc = new lib.Taches();
				mc.gotoAndStop( Std.random(mc.totalFrames)+1 );
				mc.rotation = Std.random(360);
				mc.x = x;
				mc.y = y;
				mc.scaleX = mc.scaleY = 0.8/SNOW_SCALE;
				mc.alpha = alpha;
				snow.bitmapData.draw(mc, mc.transform.matrix, mc.transform.colorTransform, flash.display.BlendMode.ERASE);
			}
		}
	}

	public function createField(str:String, ?font:Font, ?adjustSize=false) {
		if( font==null )
			font = FSmall;
		var f = new flash.text.TextFormat();
		switch(font) {
			case FSmall : f.font = "small"; f.size = 16;
			case FBig : f.font = "big"; f.size = 8;
			case FTime : f.font = "time"; f.size = 8;
		}
		f.color = 0xffffff;

		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = str;
		tf.multiline = tf.wordWrap = true;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}

		tf.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2,5),
		];

		return tf;
	}

	public function getGoalRectangle(side:Int) {
		var grand = new mt.Rand(0);
		grand.initSeed(seed + side*55);

		var r = {x:0, y:0, w:3, h:6};

		if( side==1 && oppTeam.hasPerk(Perk._PSmallCage) )
			r.h = 4;

		if( side==0 && oppTeam.hasPerk(Perk._PPlayerLargeCage) )
			r.h = 16;

		if( side==1 && oppTeam.hasPerk(Perk._PLargeCage) )
			r.h = 8;

		r.x = side==0 ? FPADDING - r.w : FPADDING + FWID;
		r.y = Std.int(FPADDING + FHEI*0.5 - r.h*0.5);

		if( side==1 ) {
			if( oppTeam.hasPerk(Perk._PRandomCage) )
				r.y = FPADDING + grand.random(FHEI-r.h-1);
			if( oppTeam.hasPerk(Perk._PCornerCage) ) {
				if( grand.random(2)==0 )
					r.y = FPADDING + 1 + grand.random(4);
				else
					r.y = FPADDING + FHEI - r.h - 1 - grand.random(4);
			}
		}
		return r;
	}

	function genField() {
		colMap = new Array();
		for(x in 0...FWID+FPADDING*2) {
			colMap[x] = new Array();
			for(y in 0...FHEI+FPADDING*2)
				colMap[x][y] = 999;
		}

		for( x in 0...FWID )
			for( y in 0...FHEI )
				colMap[FPADDING+x][FPADDING+y] = 0;

		var r = getGoalRectangle(0);
		for( x in r.x...r.x+r.w )
			for( y in r.y...r.y+r.h)
				colMap[x][y] = 0;

		var r = getGoalRectangle(1);
		for( x in r.x...r.x+r.w )
			for( y in r.y...r.y+r.h)
				colMap[x][y] = 0;
	}



	public inline function getColHeight(x:Int,y:Int) {
		return
			if( x<0 || x>=FWID+FPADDING*2 || y<0 || y>=FHEI+FPADDING*2 )
				999;
			else
				colMap[x][y];
	}

	public inline function isClicking() {
		return clickStart>=0;
	}

	public inline function wait(ms:Float, ?suspend=false, ?cb:Void->Void) {
		setPhase(  Waiting(time+(ms/1000)*FPS, suspend, cb)  );
	}

	public function onLostBall() {
		pass = 0;
		onPassChange();
		cm.create({
			announce(3, Lang.LostBall, 0xFF0000, 0x9B0000) > end;
			removeAnnounce();
		});
		newRound(false);
	}

	public function newRound(repop:Bool) {
		if( matchEnded() )
			return;

		round++;
		initSeed(round);

		if( round==0 ) {
			#if debug drawCollisions(); #end
			wait(1000, function() setPhase(WaitingPlayers));
		}
		else
			setPhase(WaitingPlayers);

		if( repop )
			repopBonus();
		initPlayers();
		engage();
	}

	public function initPlayers() {
		for( p in allPlayers )
			p.origin.x = p.origin.y = -9999;

		var tries = 0;
		for( p in allPlayers ) {
			var gr = getGoalRectangle(p.side);
			var or = getGoalRectangle(p.side==0 ? 1 :0);
			var minDist = 150;
			var tooClose = false;
			do {
				tries++;
				var cx = 0.;
				var cy = 0.;
				if( p.isGoal ) { // Gardien
					cx = FPADDING + rseed.range(2, 3);
					cy = gr.y + rseed.range(1, gr.h-1);
				}
				else if( !p.team.hasPerk(_PDoubleAttack) && p.id==1 ) { // Attaquant standard
					cx = FPADDING + rseed.range(FWID-12, FWID-8);
					cy = or.y + rseed.range(0, or.h);
				}
				else if( p.team.hasPerk(_PDoubleAttack) && p.id==1 ) { // Attaquant double 1
					cx = FPADDING + rseed.range(FWID-12, FWID-7);
					cy = or.y - or.h*0.5 + rseed.range(0, or.h);
				}
				else if( p.team.hasPerk(_PDoubleAttack) && p.id==3 ) { // Attaquant double 2
					cx = FPADDING + rseed.range(FWID-12, FWID-7);
					cy = or.y + or.h*0.5 + rseed.range(0, or.h);
				}
				else if( p.id==2 && p.side==0 ) { // Défenseur
					cx = FPADDING + rseed.range(8,10);
					cy = gr.y + rseed.range(0, gr.h);
				}
				else { // Autre joueur
					var m = 3;
					cx = FPADDING + rseed.range(m, FWID-m);
					cy = FPADDING + rseed.range(m, FHEI-m);
				}

				if( p.side==1 )
					cx = FPADDING*2 + FWID - cx;
				if( cy<FPADDING )
					cy = FPADDING;
				if( cy>=FPADDING+FHEI )
					cy = FPADDING+FHEI-1;

				p.origin.x = GRID*cx;
				p.origin.y = GRID*cy;

				// Check distances
				tooClose = false;
				for(p2 in allPlayers )
					if( p!=p2 && mt.deepnight.Lib.distance(p.origin.x, p.origin.y, p2.origin.x, p2.origin.y)<=minDist ) {
						tooClose = true;
						break;
					}
				if( minDist>20 )
					minDist-=5;
			} while( tooClose );
		}

		for(p in allPlayers)
			p.updateStats();
	}

	public function repopBonus() {
		for(i in items)
			if( i.fl_repop )
				i.removeItem();

		#if !multi
		if( isLeague() ) {
			for(n in 0...25)
				new it.Bonus(false);
		}
		#end
	}

	public function engage() {
		if( round==0 )
			for( e in allPlayers ) {
				e.cx = Math.round(e.origin.x/GRID);
				e.cy = Math.round(e.origin.y/GRID);
			}

		allowRun = false;

		var p = engager==0 ? playerTeam.players[0] : oppTeam.players[0];
		p.takeBall(false);
		p.setRestrictMode(true);
		if( round==0 ) {
			ball.cx = p.cx;
			ball.cy = p.cy;
		}

		for( e in allPlayers )
			e.setTarget(e.origin.x, e.origin.y);
	}

	public function loseTime(sec:Int) {
		chrono -= sec*FPS;

		//var tf = createField("Lost "+sec+" seconds", true); // TODO trad
		//buffer.dm.add(tf, DP_INTERF);
		//tf.textColor = 0xFF4935;
		//tf.scaleX = tf.scaleY = 2;
		//tf.x = Std.int(buffer.width*0.5 - tf.textWidth*0.5*tf.scaleX);
		//tf.y = buffer.height;
		//tf.filters = [];
		//tf.blendMode = flash.display.BlendMode.ADD;
		//
		//tw.create(tf, "y", buffer.height-40, TEaseOut, 500);
		//delayer.add( function() {
			//tw.create(tf, "alpha", 0, TEaseIn, 1000).onEnd = function() {
				//tf.parent.removeChild(tf);
			//}
		//}, 1000);

		updateChrono();
	}

	public function addTime(sec:Int) {
		chrono += sec*FPS;
	}

	public inline function getClickPower() {
		return
			if( clickStart<0 )
				0;
			else {
				var max = 20 - (ball.hasOwner() ? (1-ball.owner.precision)*10 : 0);
				var d = (time-clickStart) % max;
				var phase = Std.int((time-clickStart) / max)%2;
				if( phase==0 )
					Math.min(1, d/max);
				else
					Math.min(1, 1-d/max);
			}
	}

	public function resetCharge() {
		charging = false;
		clickStart = -1;
		powerBar.wrapper.visible = false;
	}

	function beginCharge(side:Int) {
		if( charging )
			return;

		if( !isPlaying() )
			return;

		if( !ball.hasOwner() || ball.owner.side!=side )
			return;

		if( ball.owner.cd.has("shootDelay") )
			return;

		if( !ball.owner.isPlayable() )
			return;

		charging = true;
		clickStart = time;
		powerBar.wrapper.visible = true;
	}

	function endCharge(side:Int) {
		if( !charging )
			return;

		if( !isPlaying() )
			return;

		if( !ball.hasOwner() || !ball.owner.isPlayable() || ball.owner.side!=side )
			return;

		var clickPow = getClickPower();
		resetCharge();

		//#if debug // freemove
		//var e = ball.owner;
		//e.dx = Math.cos(e.ang)*(0.2+clickPow*1.5);
		//e.dy = Math.sin(e.ang)*(0.2+clickPow*1.5);
		//return;
		//#end

		ball.owner.kickBall(ball.owner.ang, 0.5+clickPow*0.5, clickPow);
	}

	function runToBall(side:Int) {
		#if multi
		if( ball.hasOwner() && ball.owner.side==side )
			return;


		var cdist = 9999.;
		var closest : en.Player = null;
		var team = side==0 ? playerTeam : opponents;
		for( p in team ) {
			if( p.isKnocked() )
				continue;
			var d = mt.deepnight.Lib.distance(p.xx, p.yy, ball.xx, ball.yy);
			if( d<cdist ) {
				closest = p;
				cdist = d;
			}
		}
		var a = Math.atan2(ball.yy-closest.yy, ball.xx-closest.xx);
		var boost = Math.min(1, cdist/200);
		var s = boost*0.15 + (ball.hasOwner() ? 0.12 : 0.06);
		if( !allowRun )
			s = 0;
		closest.dx+=Math.cos(a)*s;
		closest.dy+=Math.sin(a)*s;
		closest.cd.set("manualRun", FPS);
		closest.clearTarget();
		fx.glow(closest, 0xFFFF00, 150);
		#end
	}

	function onKeyDown(e:flash.events.KeyboardEvent) {
		switch(e.keyCode) {
			#if debug
			case flash.ui.Keyboard.D :
				ball.owner.iaKick();
			#end

			#if multi
			case flash.ui.Keyboard.CONTROL : // Joueur 1
				AKApi.emitEvent(BEGIN_CHARGE_0);

			case flash.ui.Keyboard.NUMPAD_ADD : // Joueur 2
				AKApi.emitEvent(BEGIN_CHARGE_1);
			#end

			case flash.ui.Keyboard.M :
				miniMapVisible = !miniMapVisible;
				tw.terminate(miniMap);
				if( miniMapVisible )
					tw.create(miniMap, "y", miniMap.y-miniMap.height, 400).fl_pixel = true;
				else
					tw.create(miniMap, "y", miniMap.y+miniMap.height, 400).fl_pixel = true;

			default : // Toutes les autres touches
				#if !multi
				AKApi.emitEvent(BEGIN_CHARGE_0);
				#end
		}
	}

	function onKeyUp(e:flash.events.KeyboardEvent) {
		switch( e.keyCode ) {
			#if multi
			case flash.ui.Keyboard.CONTROL : // Joueur 1
				AKApi.emitEvent(RUN_0);
				AKApi.emitEvent(END_CHARGE_0);

			case flash.ui.Keyboard.NUMPAD_ADD : // Joueur 2
				AKApi.emitEvent(RUN_1);
				AKApi.emitEvent(END_CHARGE_1);
			#end

			default :
				#if !multi
				AKApi.emitEvent(END_CHARGE_0);
				#end
		}
	}

	function onMouseDown(_) {
		#if !multi
		AKApi.emitEvent(BEGIN_CHARGE_0);
		#end
	}
	function onMouseUp(_) {
		#if !multi
		AKApi.emitEvent(END_CHARGE_0);
		#end
	}


	public function goal(win:Bool) {
		for( p in allPlayers )
			p.gotBallThisRound = false;

		#if multi
		engager = win ? 1 : 0;
		#end

		scores[ win ? 0 : 1 ].add(GOAL_VALUE);

		var done = isProgression() && (getPlayerScore()>=scoreTarget.get() || getOpponentScore()>=scoreTarget.get());

		if( done )
			setPhase( End(time+FPS*2.5) );

		if( win ) {
			fx.flashBang(0xFFDF00, 0.3, 1500);
			pass++;
			onPassChange();
			if( done )
				announce( 3, Lang.Victory, 0xBCFB00, 0x0 );
			else
				announce( 1, Lang.ScoreGoal, 0x77B5FF );

			cm.create({
				1000;
				updateScore(true);
				1000;
				if( !matchEnded() )
					removeAnnounce();
			});
			if( !matchEnded() ) {
				wait(1500, true, newRound.bind(true));
				if( isLeague() )
					onLeagueGoal();
				if( isProgression() )
					onProgressionGoal();
			}
		}
		else {
			pass = 0;
			onPassChange();

			#if multi
			announce( 1, Lang.ScoreGoal, 0x77B5FF );
			#else
			if( done )
				announce( 3, Lang.Defeat, 0xFF3300, 0x0 );
			else
				announce( 2, ball.getLastOwnerSide()==1 ? Lang.ConcedeGoal : Lang.ConcedeGoalYourself, 0xFC8003, 0x9B0000 );
			#end
			fx.flashBang(0xFF0000, 0.7, 1000);

			cm.create({
				1000;
				updateScore(true);
				1000;
				if( !matchEnded() )
					removeAnnounce();
			});
			if( !matchEnded() )
				wait(1000, true, newRound.bind(false));
		}
	}


	public function gameOver() {
		if( fl_stopped )
			return;
		fl_stopped = true;

		#if !prod
		// Répartitions points
		if( isLeague() ) {
			var sum = 0;
			var n = 0;
			var list = [];
			trace(stats);
			for(k in stats.keys())
				if( k.indexOf("score_")==0 ) {
					var v = stats.get(k).get();
					sum+=v;
					list.push({k:k, v:v});
				}
			for(e in list)
				trace(e.k+" -> "+e.v+" ("+Math.round(100*e.v/sum)+"%)");
		}
		#end


		if( isProgression() )
			AKApi.gameOver( getPlayerScore()>=scoreTarget.get() );
		else
			AKApi.gameOver(true);
	}

	public function progressionTimeOut() {
		cm.create({
			announce(3, Lang.TimeOut, 0xFFFF00, 0x0);
			end;
			removeAnnounce();
		});
		setPhase( End(time+FPS*2.5) );
	}

	public function endLeague() {
		if( matchEnded() )
			return;

		cm.create({
			announce(3, Lang.TimeOut, 0xFFFF00, 0x0);
			lastAnnounce.y = 40;
			end;
			removeAnnounce();
		});

		AKApi.setMouseArcade(false);
		AKApi.setUseMouse(false);

		for(i in items)
			i.removeItem();
		items = [];
		setPhase( End(time+FPS*5) );

		delayer.add( showBgScroll.bind(true), 1000 );

		var slist : Array<{label:String, value:Dynamic, bonus:api.AKConst}> = [];

		var delta = getPlayerScore()-getOpponentScore();
		var bonus = AKApi.const(delta>0 ? delta*GOAL_SCORE.get() : 0);
		slist.push({
			label	: Lang.StatScore,
			value	: "<font color='#BFFE01'>"+getPlayerScore()+"</font> - <font color='#F28657'>"+getOpponentScore()+"</font>",
			bonus	: bonus,
		});

		slist.push({
			label	: Lang.StatPass,
			value	: getStat("pass").get(),
			bonus	: null,
		});
		slist.push({
			label	: Lang.StatControl,
			value	: Math.round(100*controlTimes[0]/totalDuration)+"%",
			bonus	: null,
		});

		var i = 0;
		for(s in slist) {
			var y = 110 + i*30;
			// Labels
			var tf = createField(s.label, FBig, true);
			buffer.dm.add(tf, DP_MENU);
			tf.x = 20;
			tf.y = y;
			tf.filters = [];
			tf.textColor = 0xBEC6D8;
			tf.alpha = 0;
			delayer.add( function() {
				tw.create(tf, "x", tf.x+10, 200).fl_pixel = true;
				tw.create(tf, "alpha", 1, 500);
			}, 1500 + i*300);

			// Valeur
			var tf = createField(Std.string(s.value), FBig, true);
			buffer.dm.add(tf, DP_MENU);
			tf.x = 130;
			tf.y = y-8;
			tf.scaleX = tf.scaleY = 2;
			tf.textColor = 0xFFFFFF;
			tf.alpha = 0;
			tf.filters = [];
			delayer.add( function() {
				tw.create(tf, "x", tf.x+10, 200);
				tw.create(tf, "alpha", 1, 500);
			}, 1800 + i*300);

			// Bonus
			if( s.bonus!=null ) {
				var tf = createField("+"+s.bonus.get(), FBig, true);
				buffer.dm.add(tf, DP_MENU);
				tf.scaleX = tf.scaleY = 2;
				tf.x = buffer.width-20-tf.textWidth*tf.scaleX;
				tf.y = y-8;
				tf.alpha = 0;
				tf.textColor = 0xFFFF80;
				tf.filters = [ new flash.filters.GlowFilter(0xFFB00D,0.9, 16,16,1, 2) ];
				delayer.add( function() {
					if( s.bonus.get()!=0 )
						addScore(s.bonus, "goal");
					tw.create(tf, "x", tf.x-10, 200);
					tw.create(tf, "alpha", 1, 500);
				}, 2600 + i*300);
			}

			i++;
		}
	}

	function updateScore(?blink=false) {
		scoreField.width = 300;
		scoreField.text = Lang.Score({_player:getPlayerScore(), _opponent:getOpponentScore()});
		scoreField.width = scoreField.textWidth+5;

		if( blink ) {
			var o = {t:0.};
			tw.terminate(scoreField, "y");
			tw.create(scoreField, "y", scoreField.y+6, TShakeBoth, 350);
			tw.create(o, "t", 1, TBurnIn, 900).onUpdateT = function(t) {
				var t = Math.sin(t*3.14);
				scoreField.filters = [
					new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.4*(1-t), 2,2,1),
					new flash.filters.GlowFilter(0xffffff,t, 4,4,4, 1,true),
					new flash.filters.GlowFilter(0xFFF200,t, 8,4,2),
					new flash.filters.GlowFilter(0xFFD900,t, 32,16,2),
				];
			}
		}
	}

	function updateChrono() {
		if( matchEnded() )
			return;

		var c = Std.int( chrono/FPS );
		var mins = Std.int( c/60 );
		var sec = Std.int( c-mins*60 );
		if( mins<0 ) mins = 0;
		if( sec<0 ) sec = 0;
		chronoField.text = mins+":"+mt.deepnight.Lib.leadingZeros(sec,2);
		chronoField.x = Std.int( buffer.width*0.5 - chronoField.textWidth*0.5*chronoField.scaleX - 3 );

		if( chronoField.scaleX!=3 && mins==0 && sec<=20 ) {
			chronoField.filters = [ new flash.filters.GlowFilter(0xFF0000, 0.9, 8,8,1) ];
			chronoField.textColor = 0xFF8600;
		}

		if( mins<=0 && sec>0 )
			if( sec<=10 ) {
				tw.terminate(timeWarning);
				timeWarning.visible = true;
				timeWarning.alpha = 0.7;
				tw.create(timeWarning, "alpha", 0, TLinear, 700);
				tw.create(chronoField, "y", chronoField.y-4, TLoop, 200);
			}
			else if( sec<=20 ) {
				tw.terminate(timeWarning);
				timeWarning.visible = true;
				timeWarning.alpha = 0.4;
				tw.create(timeWarning, "alpha", 0, TLinear, 700);
			}
	}

	inline function mapDot(cx,cy, col:Int) {
		if( miniMapVisible && time%3==0 )
			miniMap.bitmapData.setPixel(cx-FPADDING, cy-FPADDING, col);
	}

	public function update(render:Bool) {
		if( fl_stopped )
			return;

		if( !snowFlattened && !lowq && hasSnow() && AKApi.getPerf()<=0.7 )
			flattenSnow();

		var eid = AKApi.getEvent();
		while( eid!=null ) {
			if( eid==BEGIN_CHARGE_0 ) beginCharge(0);
			else if( eid==BEGIN_CHARGE_1 ) beginCharge(1);
			else if( eid==END_CHARGE_0 ) endCharge(0);
			else if( eid==END_CHARGE_1 ) endCharge(1);
			else if( eid==RUN_0 ) runToBall(0);
			else if( eid==RUN_1 ) runToBall(1);
			else if( eid==CHOOSE_UPGRADE_0 ) onPerkSelect(0);
			else if( eid==CHOOSE_UPGRADE_1 ) onPerkSelect(1);

			//switch(eid) {
				//case BEGIN_CHARGE_0 : beginCharge(0);
				//case BEGIN_CHARGE_1 : beginCharge(1);
				//case END_CHARGE_0 : endCharge(0);
				//case END_CHARGE_1 : endCharge(1);
				//case RUN_0 : runToBall(0);
				//case RUN_1 : runToBall(1);
				//case CHOOSE_UPGRADE_0 : onPerkSelect(0);
				//case CHOOSE_UPGRADE_1 : onPerkSelect(1);
				//default : throw "unknown event "+eid;
			//}

			eid = AKApi.getEvent();
		}

		cd.update();

		if( outTimer>0 )
			outTimer--;

		// Apparition des chronos
		while( spawner.length>0 && time>=spawner[0].t ) {
			spawner[0].cb();
			spawner.splice(0,1);
		}

		if( miniMapVisible && time%3==0 )
			miniMap.bitmapData.fillRect(miniMap.bitmapData.rect, 0x0);
		for(e in allPlayers) {
			e.update();
			mapDot(e.cx, e.cy, e.side==0 ? 0x009FFF : 0xFF5300);
		}
		for(e in items)
			e.update();
		for(e in miscEntities)
			e.update();
		ball.update();
		mapDot(ball.cx+1, ball.cy, 0xFFFFFF);

		// Destruction
		for(e in killList)
			e.unregister();
		killList = new Array();

		if( isClicking() && ball.hasOwner() && ball.owner.isPlayable() && isPlaying() ) {
			powerBar.wrapper.x = Std.int(ball.owner.xx-powerBar.wrapper.width*0.5);
			powerBar.wrapper.y = ball.owner.yy+3;
			powerBar.bar.scaleX = getClickPower();
		}

		#if debug
		if( AKApi.unrecordedIsDown( flash.ui.Keyboard.L ) ) {
			var lag = [];
			for(i in 0...500000) lag.push(1);
		}
		#end


		//addBlurSpot( Std.random(100), Std.random(100), 0xFFFFFF, 5);

		// Scrolling
		if( !isChoosingPerk() ) {
			var mx = mouseX / WID - 0.5;
			var my = mouseY / WID - 0.5;
			#if multi
			mx = my = 0;
			#else
			if( AKApi.isReplay() || mouseOutside && outTimer<=0 || phase==ChoosePerk )
				mx = my = 0;
			#end
			var mouseRange = !isPlaying() || ball.free() || ball.owner.side!=0 ? 0.2 : 0.45;
			var vx = ball.xx - viewport.width*0.5 + mx*WID*mouseRange + kbPanX;
			var vy = ball.yy - viewport.height*0.5 + my*HEI*mouseRange + kbPanY;
			viewport.x += (vx-viewport.x)*0.08;
			viewport.y += (vy-viewport.y)*0.08;
			var w = GRID*(FPADDING*2+FWID);
			var h = GRID*(FPADDING*2+FHEI);
			if( viewport.x<56 ) viewport.x = 56;
			if( viewport.x>w-viewport.width-56 ) viewport.x = w-viewport.width-56;
			if( viewport.y<0 ) viewport.y = 0;
			if( viewport.y>h-viewport.height-100) viewport.y = h-viewport.height-100;
			scroller.x = -Math.round( viewport.x );
			scroller.y = -Math.round( viewport.y );

			// Z-Sort
			if( time%4==0 ) {
				zsortables.sort(function(a,b) return Reflect.compare(a.yy+a.zpriority, b.yy+b.zpriority));
				var z = 0;
				for(e in zsortables)
					e.spr.parent.setChildIndex(e.spr, z++);
			}
		}

		//var bd = blur.bitmapData;
		//bd.applyFilter(bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(4,4));

		delayer.update();
		cm.update();
		tw.update();
		//tip.update();
		if( render )
			fx.update();
		if( render )
			buffer.update();
		time++;

		switch( phase ) {
			case Waiting(t, s, cb) :
				if( time>=t ) cb();
			case WaitingPlayers :
				var l = Lambda.filter(allPlayers, function(p) return !p.nearOrigin());
				if( l.length==0 )
					setPhase(Playing);
			default :
		}

		// Chrono
		if( matchStarted() && isPlaying() ) {
			if( chrono<=0 && ball.hasOwner() ) {
				if( isLeague() )
					endLeague();
				else
					progressionTimeOut();
			}
			chrono--;
			if( chrono<0 )
				chrono = 0;
			chronoBg.alpha = chronoField.alpha = 1;
			if( chrono%FPS==0 )
				updateChrono();

			// Temps de contrôle de la balle
			totalDuration++;
			var bside = ball.hasOwner() ? ball.owner.side : ball.getLastOwnerSide();
			if( bside!=-1 )
				controlTimes[bside]++;
		}
		else
			chronoBg.alpha = chronoField.alpha = 0.3;

		if( matchEnded() )
			switch( phase ) {
				case End(t) : if( time>=t ) gameOver();
				default :
			}

		// Textures qui scrollent en fond
		if( bgScroll!=null ) {
			var s = 1;
			bgScroll.x-=s;
			bgScroll.y+=s*0.5;
			if( bgScroll.x<-bgScroll.width/BG_SCROLL_REPEAT )
				bgScroll.x+=bgScroll.width/BG_SCROLL_REPEAT;
			if( bgScroll.y>-bgScroll.height/BG_SCROLL_REPEAT )
				bgScroll.y-=bgScroll.height/BG_SCROLL_REPEAT;
		}

		// Bug: focus forcé...
		if( fl_stageReady && stage!=null ) {
			stage.stageFocusRect = false;
			stage.focus = this;
		}

		if( AKApi.getPerf()<=0.6 )
			lowq = true;
	}
}


// TODO temps de contrôle de balle


