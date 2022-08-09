package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.slb.assets.TexturePacker;
import mt.deepnight.slb.*;
import mt.deepnight.Color;
import mt.deepnight.Cinematic;
import mt.deepnight.Tweenie;
import mt.deepnight.Lib;
import mt.flash.Sfx;
import mt.flash.DepthManager;
import mt.flash.Key;
import mt.MLib;
import mt.Metrics;

import TeamInfos;
import Const;

@:bitmap("misc.png") class GfxMisc extends BitmapData {}

enum GamePhase {
	Init;
	TeamAnnounce;
	Waiting(endTime:Float, suspend:Bool, onEnd:Void->Void);
	Repositionning(onComplete:Void->Void);
	ShootOut(side:Int);
	RedCard(e:en.Player, endTime:Float);
	Playing;
	End(time:Float);
}

class Game extends mt.deepnight.FProcess {
	public static var ME : Game;

	public var wrapper		: Sprite;
	public var dm			: DepthManager;
	public var gwrapper		: Sprite; // game wrapper
	public var scroller		: Sprite;
	public var sdm			: DepthManager;
	public var gdm			: DepthManager;
	public var viewport		: { x:Float, y:Float, wid:Int, hei:Int, dx:Float, dy:Float, focus:Entity };
	var drag				: Null<{x:Float, y:Float}>;
	public var zsortLayer	: Sprite;
	public var fx			: Fx;
	public var cine			: Cinematic;
	public var hud			: Hud;
	public var stadium		: Stadium;
	var movePreview			: Bitmap;
	public var iaKickPreview: BSprite;
	public var lid			: Int;
	public var tutorial		: Tutorial;
	public var isCustomMatch: Bool;
	var variant				: GameVariant;

	public var tiles		: BLib;
	public var misc			: BLib;
	public var whiteGuys	: BLib;
	public var blackGuys	: BLib;
	public var shirtA		: BLib;
	public var shirtB		: BLib;

	var fl_stopped			: Bool;
	public var chargeInfos	: Array<{ active:Bool, clickStart:Int }>;

	public var round		: Int;
	public var score		: Int;
	public var controlTimes	: Array<Float>;
	public var seed			: Int;
	public var rseed		: mt.Rand;
	public var totalDuration: Int;

	public var chrono		: Float;
	public var shakePow		: Float;
	public var shakeFrict	: Float;
	var realMatchDuration	: Float;

	public var ball			: en.Ball;
	public var playerTeam	: TeamInfos;
	public var oppTeam		: TeamInfos;
	public var zsortables	: Array<Entity>;
	var bgScroll			: Null<Bitmap>;
	var events				: Array<{t:Float, cb:Void->Void}>;

	var mouseOutside		: Bool;
	var outTimer			: Int;
	public var phase		: GamePhase;
	var powerBar			: Array<Bitmap>;
	public var enemyBar		: Bitmap;
	public var lowq			: Bool;
	public var windAng		: Float;
	public var windPower	: Float;
	var slowFrames			: Int;

	var crowd				: Crowd;

	var stats				: Map<String, Int>;

	public function new(team:TeamInfos, v:GameVariant) {
		super();

		ME = this;
		lid = team.lid;
		variant = v;

		lowq = Global.ME.isLowQuality();
		shakePow = 0;
		shakeFrict = 0;
		slowFrames = 0;
		cine = new Cinematic();
		controlTimes = [0,0];
		totalDuration = 0;
		cd = new mt.Cooldown();
		fl_stopped = false;
		round = -1;
		mouseOutside = true;
		events = new Array();
		zsortables = new Array();
		time = 0;
		outTimer = 0;
		stats = new Map();
		phase = Init;
		windAng = 0;
		windPower = 0;
		crowd = new Crowd();
		powerBar = [];

		chargeInfos = [
			{ active:false, clickStart:-1 },
			{ active:false, clickStart:-1 },
		];

		// Game seed
		seed = 1 + lid*1866 + Type.enumIndex(getVariant())*569;
		#if !prod
			seed = Std.random(99999);
			#if debug
			trace("SEED="+seed);
			#end
		#end
		rseed = new mt.Rand(0);
		initSeed();

		//might be useful for the future if we track UserId
		//var v = switch( getVariant() ) {
			//case Normal : "normal";
			//case Hard : "hard";
		//}
		Ga.event("play", "levelId", Std.string(lid) );
		Ga.pageview("/app/game/"+getVariant()+"/"+lid );

		// Main wrapper
		wrapper = new Sprite();
		root.addChild(wrapper);
		dm = new DepthManager(wrapper);

		// Init teams
		playerTeam = makePlayerTeam();
		oppTeam = team;

		// Sprite libs
		misc = new BLib( new GfxMisc(0,0) );
		misc.setDefaultCenter(0,0);
		misc.setSliceGrid(16,16);
		misc.slice("ballTexture", 0,0, 24,36, 2);
		misc.sliceGrid("smoke", 0,4);

		tiles = Global.ME.tiles;
		whiteGuys = TexturePacker.importXml("skinWhite.xml");
		whiteGuys.initBdGroups();

		blackGuys = TexturePacker.importXml("skinBlack.xml");
		blackGuys.initBdGroups();

		shirtA = TexturePacker.importXml("shirt.xml");


		shirtB = TexturePacker.importXml("shirt.xml");
		shirtB.source = shirtB.source.clone();

		fx = new Fx();

		// Clothes colors
		paintClothes(shirtA, playerTeam.shirtColor, playerTeam.pantColor, playerTeam.stripeColor);
		shirtA.initBdGroups();
		paintClothes(shirtB, oppTeam.shirtColor, oppTeam.pantColor, oppTeam.stripeColor);
		shirtB.initBdGroups();


		// Main buffer
		gwrapper = new Sprite();
		dm.add(gwrapper, Const.DP_BG1);
		gwrapper.scaleX = gwrapper.scaleY = Const.UPSCALE;
		gdm = new DepthManager(gwrapper);

		// Scroller
		scroller = new Sprite();
		gdm.add(scroller, Const.DP_BG1);
		sdm = new DepthManager(scroller);
		viewport = { x:0, y:0, wid:Const.WID, hei:Const.HEI, dx:0, dy:0, focus:null };

		// Z-sortables objects
		zsortLayer = new Sprite();
		sdm.add(zsortLayer, Const.DP_ZSORTABLES);


		// Shoot power bar
		for(i in 0...2) {
			var bmp = new Bitmap( new BitmapData(60,15, true, 0x0) );
			sdm.add(bmp, Const.DP_INTERF);
			bmp.visible = false;
			powerBar[i] = bmp;
		}

		// Enemy bar
		enemyBar = new Bitmap( new BitmapData(18,5, false, 0x0) );
		sdm.add(enemyBar, Const.DP_INTERF);
		//enemyBar.visible = false;

		// Defender move preview
		var s = new Sprite();
		s.graphics.lineStyle(2, 0xFFFFCC,1, true, NONE);
		s.graphics.drawCircle(0,0, 20);
		s.filters = [
			new flash.filters.GlowFilter(0xFFFF80,1, 4,4,2),
			new flash.filters.GlowFilter(0xFF8000,1, 8,8,1),
		];
		movePreview = Lib.flatten(s, 8);
		sdm.add(movePreview, Const.DP_BG2);

		// IA kick preview
		iaKickPreview = tiles.get("ennemyArrow");
		sdm.add(iaKickPreview, Const.DP_BG2);
		iaKickPreview.setCenter(0.3, 0.5);
		//iaKickPreview.visible = false;

		// Background stadium
		stadium = new Stadium();
		stadium.initAndRender();

		createPlayers();

		// Ballon
		ball = new en.Ball();
		ball.owner = en.Player.getEngager(0);
		ball.xx = ball.owner.xx;
		ball.yy = ball.owner.yy;
		viewport.focus = ball;


		// UI
		hud = new Hud();

		onResize();

		delayer.add( startGame, 500 );
	}


	function makePlayerTeam() {
		var t = new TeamInfos(0);
		t.shirtColor = Const.PALETTE[ Global.ME.playerCookie.data.shirtColor ];
		t.pantColor = Const.PALETTE[ Global.ME.playerCookie.data.pantColor ];
		t.stripeColor = Const.PALETTE[ Global.ME.playerCookie.data.stripeColor ];
		return t;
	}


	public function isMulti() {
		return false;
	}


	function createPlayers() {
		for(i in 0...11)
			new en.Player(playerTeam);

		for(i in 0...oppTeam.playerCount)
			new en.Player(oppTeam);
	}


	public inline function getVariant() {
		//return Global.ME.variant;
		return variant;
	}

	public function setWind(a:Float, s:Float) {
		windAng = a;
		windPower = MLib.fclamp(s, 0,1);
	}


	function paintClothes(lib:BLib, shirt:Int, pant:Int, stripe:Int) {
		function makePal(c:Int) {
			return Color.makePaletteCustom([
				{ ratio:0.0,	col:Color.setLuminosityInt(c, 0) },
				{ ratio:0.6,	col:c},
			]);
		}

		var bd = lib.source;
		var pt0 = new flash.geom.Point();
		Color.paintBitmap(bd, makePal(pant), makePal(shirt), Color.makeNicePalette(stripe));
	}


	public function startGame() {
		scroller.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		root.stage.addEventListener(flash.events.Event.MOUSE_LEAVE, onMouseLeave );
		try {
			flash.desktop.NativeApplication.nativeApplication.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true );
		} catch(e:Dynamic) {}

		chrono = Const.seconds( oppTeam.getTimeSeconds() );

		// Sounds
		Global.ME.fadeOutMusic();
		crowd.start();


		// Init des bonus temps
		#if !video
		if( !oppTeam.hasPerk(_PNoTimeBonus) ) {
			var n = rseed.random(3)+1;
			for(i in 0...n)
				events.push({
					t	: chrono*rseed.range(0.1, 0.8),
					cb	: function() new en.it.SmallTime(),
				});
			events.push({
				t	: chrono*0.05,
				cb	: function() new en.it.SmallTime(),
			});
			events.sort( function(a,b) return Reflect.compare(a.t, b.t) );
		}
		#end

		// Cinématique intro team
		cine.create({
			newRound();
			#if prod
			versus(oppTeam);
			fx.flashBang(0xFFFF80, 1, 1500);
			1500;
			#end
		});

		tutorial = new Tutorial(this);

		applyPerks();
		realMatchDuration = 0;

		flash.system.System.pauseForGCIfCollectionImminent(0.1);
		flash.system.System.gc();

		Global.ME.fadeIn();
	}


	public function whistle() {
		var pr = ball.getPositionRatio();
		Global.SBANK.sifflet().play(Lib.rnd(0.4, 0.8), -(pr.x-0.5)*2);
	}
	public function whistleGoal() {
		var pr = ball.getPositionRatio();
		Global.SBANK.sifflet_but().play(Lib.rnd(0.7, 1), -(pr.x-0.5)*2);
	}
	public function whistleFault(red:Bool) {
		var pr = ball.getPositionRatio();
		Global.SBANK.sifflet_carton_rouge().play(red ? Lib.rnd(0.7, 1) : Lib.rnd(0.4,0.6), -(pr.x-0.5)*2);
	}


	function onMatchStart() {
		whistle();
		tutorial.trigger(_PTuto1, 0);

		tutorial.trigger(_PTuto2, 0);
		delayer.add( function() tutorial.trigger(_PTuto2, 1), 300 );

		tutorial.trigger(_PTuto3, 0);
		tutorial.chain(_PTuto3, 1);

		tutorial.trigger(_PTutoMatch, 0);
		tutorial.chain(_PTutoMatch, 1);
		tutorial.chain(_PTutoMatch, 2);
		tutorial.chain(_PTutoMatch, 3);

		tutorial.trigger(_PTutoElectric, 0);
		tutorial.chain(_PTutoElectric, 1);
		tutorial.chain(_PTutoElectric, 2);
		tutorial.chain(_PTutoElectric, 3);

		setPhase(Playing);
	}




	public inline function getWidth() return MLib.ceil( Const.WID/Const.UPSCALE );
	public inline function getHeight() return MLib.ceil( Const.HEI/Const.UPSCALE );



	override function unregister() {
		scroller.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp );
		root.stage.removeEventListener(flash.events.Event.MOUSE_LEAVE, onMouseLeave );
		try {
			flash.desktop.NativeApplication.nativeApplication.removeEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true);
		} catch(e:Dynamic) {}

		super.unregister();

		for(e in Entity.ALL)
			e.destroy();
		Entity.garbageCollect();

		crowd.destroy();
		tutorial.destroy();
		fx.destroy();
		stadium.destroy();
		movePreview.bitmapData.dispose(); movePreview.bitmapData = null;

		whiteGuys.destroy();
		blackGuys.destroy();
		shirtA.destroy();
		shirtB.destroy();

		hud.destroy();

		gdm.destroy();
		dm.destroy();
		sdm.destroy();
	}


	override function onResize() {
		super.onResize();

		gwrapper.scaleX = gwrapper.scaleY = Const.UPSCALE;

		viewport.wid = Std.int( Const.WID/Const.UPSCALE );
		viewport.hei = Std.int( Const.HEI/Const.UPSCALE );

		hud.onResize();
	}

	override function onActivate() {
		super.onActivate();
	}


	override function onDeactivate() {
		super.onDeactivate();
	}



	public inline function getLevel() {
		return lid;
	}

	public inline function getLevelRatio() {
		#if video
		return 1.0;
		#else
		return lid/100;
		#end
	}

	public inline function getPerf() {
		return 1.0;
	}



	public inline function addStat(k:String, ?n=1) {
		stats.set(k, getStat(k)+n );
	}


	public inline function getStat(k:String) {
		if( !stats.exists(k) )
			stats.set(k, 0);
		return stats.get(k);
	}



	function onGoal() {
		initSeed(round);

		while( en.Player.getTeam(1).length<oppTeam.playerCount )
			new en.Player(oppTeam);

		if( oppTeam.hasPerk(_PMines) )
			for(i in 0...rseed.random(3)+1)
				new en.Mine();
	}

	public function onBallTaken(e:en.Player) {
	}

	function updatePowerBar(side) {
		var active = en.Player.getActive(side);
		if( active==null )
			return;

		var bmp = powerBar[side];
		var p = getClickPower(side);
		bmp.alpha = p>0 ? 1 : 0.5;
		bmp.x = Std.int(active.xx-bmp.width*0.5);
		bmp.y = active.yy+8;

		var bd = bmp.bitmapData;
		bd.fillRect( bd.rect, Color.addAlphaF(0x1F1D34) );
		bd.fillRect( new flash.geom.Rectangle(1,1, bd.width-2, bd.height-2), Color.addAlphaF(0x1F1D34,0.5) );
		var col = Color.addAlphaF( Color.interpolateInt(0xFB7D00, 0xFFFF00, p) );
		bd.fillRect( new flash.geom.Rectangle(1,1, (bd.width-2)*p, bd.height-2), col );
	}


	function hideBgScroll() {
		tw.create(bgScroll.alpha, 0, 500).onEnd = function() {
			bgScroll.parent.removeChild(bgScroll);
			bgScroll.bitmapData.dispose();
		}
	}

	function showBgScroll(?fadeIn=true) {
		var base = mt.deepnight.Lib.flatten( new lib.Damier() ).bitmapData;
		var t = new Sprite();
		t.graphics.beginFill(0x162F6D,1);
		t.graphics.drawRect(0,0, base.width*Const.BG_SCROLL_REPEAT, base.height*Const.BG_SCROLL_REPEAT);
		t.graphics.beginBitmapFill(base, true, false);
		t.graphics.drawRect(0,0, base.width*Const.BG_SCROLL_REPEAT, base.height*Const.BG_SCROLL_REPEAT);
		bgScroll = mt.deepnight.Lib.flatten(t);
		gdm.add(bgScroll, Const.DP_INTERF);

		//#if debug
		//var bmp = mt.deepnight.Lib.flatten(t);
		//bmp.scaleX = bmp.scaleY = 0.6;
		//addChild(bmp);
		//#end

		if( fadeIn ) {
			bgScroll.alpha = 0;
			tw.create(bgScroll.alpha, 1, 700);
		}

		base.dispose();
	}


	public function applyPerks() {
		var ratio = 0.2 + 0.8*oppTeam.getSkillLevel();

		// Obstacles
		if( oppTeam.hasPerk(_PRocks) )
			for(i in 0...(oppTeam.getSkillLevel()==0 ? 5 : 12))
				new en.Obstacle(_PRocks);

		if( oppTeam.hasPerk(_PPumpkins) )
			for(i in 0...Std.int(ratio*10))
				new en.Obstacle(_PPumpkins);

		if( oppTeam.hasPerk(_PLifeBelts) )
			for(i in 0...Std.int(ratio*10))
				new en.Obstacle(_PLifeBelts);

		if( oppTeam.hasPerk(_PAnvils) )
			for(i in 0...Std.int(ratio*10))
				new en.Obstacle(_PAnvils);

		// Bumpers
		if( oppTeam.hasPerk(_PBumpers) )
			for(i in 0...10+Std.int(ratio*10))
				new en.so.Bumper();

		// Teleports (random)
		if( oppTeam.hasPerk(_PTeleports) )
			for(i in 0...2+Std.int(ratio*8))
				new en.so.Teleport();

		// Teleports (corners)
		if( oppTeam.hasPerk(_PCornerTeleports) ) {
			new en.so.CornerTeleport(0,0, 0);
			new en.so.CornerTeleport(1,1, 0);

			new en.so.CornerTeleport(1,0, 1);
			new en.so.CornerTeleport(0,1, 1);
		}

		// Mines
		if( oppTeam.hasPerk(Perk._PMines) ) {
			#if video
			for(i in 0...30)
				new en.Mine();
			#else
			for(i in 0...10+Std.int(ratio*6))
				new en.Mine();
			#end
		}

		// Caracts des joueurs
		for(p in en.Player.ALL)
			p.updateStats();

		// Special balls
		if( oppTeam.hasPerk(_PRugby) )
			ball.setRugby();

		if( oppTeam.hasPerk(_PBowling) )
			ball.setBowling();

		if( oppTeam.hasPerk(_PElectric) )
			ball.setElectric();

		// Walls
		if( oppTeam.hasPerk(_PMiddleWall) )
			stadium.addWall( Std.int(Const.FWID*0.5) );

		if( oppTeam.hasPerk(_PDefenseWall) )
			stadium.addWall( Std.int(Const.FWID*0.3) );

		if( oppTeam.hasPerk(_PAttackWall) )
			stadium.addWall( Std.int(Const.FWID*0.7) );

		if( oppTeam.hasPerk(_PGoalWall) )
			stadium.addGoalWall(1);

		//if( hasSnow() )
			//fx.initLeaves("snow");

		// Temps
		//if( playerTeam.hasPerk(_PExtraTime1) )
			//chrono+= 0.5*60*Const.FPS;
		//if( playerTeam.hasPerk(_PExtraTime2) )
			//chrono+= 0.5*60*Const.FPS;
		hud.updateValues();

		// NEIGE
		if( hasSnow() )
			stadium.initSnow();

		#if debug
		stadium.debugRender();
		#end
	}


	public inline function initSeed(?inc=0) {
		rseed.initSeed(seed+inc*159);
	}

	public inline function isPlaying() {
		return phase==Playing || isShootOut();
		//return phase==Playing;
	}

	public inline function isRepositionning() {
		return phase.getIndex() == Type.enumIndex(Repositionning(null));
	}
	public inline function isShootOut() {
		return phase.getIndex() == Type.enumIndex(ShootOut(-1));
	}

	public inline function isSuspended() {
		return switch(phase) {
			case Waiting(t, suspend, n) : suspend;
			case RedCard(_) : true;
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
		if( phase==Playing && ball.owner!=null && ball.owner.side==0 )
			ball.owner.activate();
	}



	public function shake(p, frict) {
		shakePow = MLib.fmax(shakePow, p);
		shakeFrict = MLib.fmax(shakeFrict, frict);
	}



	public function timeAnnounce(str:String) {
		var tf = createField(str, FBig, true);
		var bmp = Lib.flatten(tf);
		gdm.add(bmp, Const.DP_INTERF);
		bmp.bitmapData = Lib.scaleBitmap(bmp.bitmapData, 2, true);
		bmp.x = getWidth();
		bmp.y = 30;
		tw.create(bmp.x, getWidth()-bmp.width, 900);
		delayer.add(function() {
			tw.create(bmp.alpha, 0).onEnd = function() {
				bmp.bitmapData.dispose();
				bmp.bitmapData = null;
				bmp.parent.removeChild(bmp);
				bmp = null;
			}
		}, 2500);
	}


	public function versus(t:TeamInfos) {
		var col = switch( getVariant() ) {
			case Normal : 0xB3DF00;
			case Hard : 0xFFA600;
			case Epic : 0xFF0000;
		}
		announce(oppTeam.name, col, "VS");
	}


	public function announce(str:String, ?col=0xFFFF00, ?char="siflet") {
		if( !hud.wrapper.visible )
			return;

		var dark = Color.interpolateInt( Color.setLuminosityInt(col,0.2), 0x1A1A4A, 0.3);

		var wrapper = new Sprite();
		gdm.add(wrapper, Const.DP_INTERF);
		wrapper.mouseChildren = wrapper.mouseEnabled = false;

		// Band
		var band = new Sprite();
		wrapper.addChild(band);
		band.x = -band.width;
		var bd = tiles.getBitmapData("stripe");
		var btex = new Bitmap( Lib.createTexture(bd, getWidth()+6*2, bd.height, true) );
		band.addChild(btex);
		btex.bitmapData.applyFilter( btex.bitmapData, btex.bitmapData.rect, pt0, Color.getColorizeFilter(dark, 1, 0) );
		var tanim = createTinyProcess();
		tanim.onUpdate = function() {
			btex.x+=1;
			while( btex.x>0 )
				btex.x-=6;
		}

		// Character
		var art = new BSprite(tiles);
		if( char!="" ) {
			art.set(char);
			wrapper.addChild(art);
			art.x = -art.width;
			art.y = Std.int(band.height*0.5 - art.height*0.5);
			art.setCenter(1,0);
			art.scaleX = char!="VS" ? -1 : 1;
		}

		// Text
		var scale = str.length>14 ? 3 : 4;
		var s = new Sprite();
		var tf = createField(str.toUpperCase(), FBig, true);
		s.addChild(tf);
		tf.textColor = col;
		tf.filters = [
			new flash.filters.DropShadowFilter(scale,90, Color.setLuminosityInt(col, 0.45),1, 0,0),
		];
		tf.scaleX = tf.scaleY = scale;
		var msg = Lib.flatten(s);
		wrapper.addChild(msg);
		msg.x = getWidth();
		msg.y = 26 - msg.height*0.5;
		//msg.y = Global.ME.getFont().cyrillic ? -10 : -20;

		function _announceDestroy() {
			art.dispose();
			wrapper.parent.removeChild(wrapper);
			msg.bitmapData.dispose(); msg.bitmapData = null;
			btex.bitmapData.dispose(); btex.bitmapData = null;
		}

		if( char=="VS" ) {
			art.x = -100;
			art.setCenter(0,0);
			msg.x = getWidth();
			cine.create({
				tw.create(art.x, 10, TEaseOut, 200);
				tw.create(band.x, 0, TEaseOut, 3000);
				300;
				tw.create(msg.x, 100, TEaseOut, 500);
				1000;
				tw.create(wrapper.alpha, 0, 700);
				1200;
				tanim.destroy();
				_announceDestroy();
			});
		}
		else {
			cine.create({
				tw.create(art.x, getWidth()-10-art.width, TEaseOut, 500);
				tw.create(band.x, 0, TEaseOut, 3000);
				300;
				tw.create(msg.x, 10, TEaseOut, 500);
				1000;
				tw.create(wrapper.alpha, 0, 700);
				800;
				tanim.destroy();
				_announceDestroy();
			});
		}

		wrapper.y = Std.int(getHeight()*0.5-wrapper.height*0.5);
	}



	public inline function hasSnow() {
		return oppTeam.hasPerk(Perk._PSnow);
	}

	public inline function hasLeather() {
		return oppTeam.hasPerk(Perk._PLeather);
	}



	public inline function createField(str, font, ?adjustSize) {
		return Global.ME.createField(str,font,adjustSize);
	}


	public inline function isClicking(side) {
		return chargeInfos[side].clickStart>=0;
	}

	public inline function wait(ms:Float, ?suspend=false, ?cb:Void->Void) {
		setPhase(  Waiting(time+Const.seconds(ms/1000), suspend, cb)  );
	}

	public function onLostBall() {
		if( isShootOut() )
			endShootOut();
		else {
			cine.create({
				announce(Lang.LostBall, 0xFFFF00);
				whistle();
			});
			newRound();
		}
	}

	public function newRound() {
		if( matchEnded() )
			return;

		round++;
		initSeed(round);
		viewport.focus = ball;
		ball.onNewRound();

		// Init wind
		if( oppTeam.hasPerkAmong([_PWindLight, _PWindMedium, _PWindStrong]) ) {
			var p = if( oppTeam.hasPerk(_PWindLight) ) 0.3;
				else if( oppTeam.hasPerk(_PWindMedium) ) 0.65;
				else 0.85;

			var a = if( oppTeam.hasPerk(_PWindFront) ) 3.14;
				else if( oppTeam.hasPerk(_PWindBack) ) 0;
				else if( oppTeam.hasPerk(_PWindBottom) ) 1.48;
				else if( oppTeam.hasPerk(_PWindTop) ) -1.48;
				else {
					rseed.range(MLib.PI*0.35, MLib.PI*0.65, true);
				}

			a+=rseed.range(0, 0.5, true);
			setWind(a, p);
		}

		for(e in en.Player.ALL)
			e.deactivate();

		if( round==0 )
			wait(#if !prod 500 #else 2500 #end, function() setPhase( Repositionning( onMatchStart ) ));
		else
			setPhase( Repositionning( setPhase.bind(Playing) ) );

		initPlayers();

		if( round==0 )
			for( e in en.Player.ALL ) {
				e.cx = Math.round(e.origin.x/Const.GRID);
				e.cy = Math.round(e.origin.y/Const.GRID);
			}

		if( oppTeam.hasPerk(_PTuto3) ) {
			// Ball to a random attacker
			var p = en.Player.getTeam(1)[2];
			p.takeBall();
			if( round==0 ) {
				ball.cx = p.cx;
				ball.cy = p.cy;
			}
			en.Player.getTeam(0)[2].activate();
		}
		else {
			// Ball to the goal
			var p = en.Player.getEngager(0);
			p.takeBall();
			p.setRestrictMode(true);
			p.activate();
			if( round==0 ) {
				ball.cx = p.cx;
				ball.cy = p.cy;
			}
		}

		for( e in en.Player.ALL )
			e.setTarget(e.origin.x, e.origin.y);
	}


	public function prepareShootOut(side:Int) {
		newRound();

		var def = side==0 ? 1 : 0;
		var pt = stadium.getGoalFront(def);

		announce(Lang.ShootOut);

		// Everyone fallsback
		for( e in en.Player.ALL )
			if( MLib.fabs(e.origin.x-pt.x) <= 400 )
				e.setOrigin(e.origin.x + (side==0 ? -300 : 300), e.origin.y);

		// Init shooter
		var atk = en.Player.getTeam(side)[1];
		atk.setOrigin(
			pt.x + (150 + rseed.range(0,20)) * (side==0 ? -1 : 1),
			pt.y + rseed.range(0,60,true)
		);

		// Init goal
		var goal = en.Player.getGoal(def);
		if( goal!=null ) {
			goal.setOrigin(
				pt.x + rseed.range(0,10,true),
				pt.y + rseed.range(0,30,true)
			);
			goal.setRestrictMode(false);
		}

		ball.owner = null;
		ball.setPosFree(atk.origin.x-10, atk.origin.y+3);

		setPhase( Repositionning( function() {
			atk.takeBall();
			if( side==0 )
				atk.activate();
			else if( goal!=null )
				goal.activate();
			setPhase( ShootOut(side) );
		}) );
	}


	public function endShootOut() {
		if( ball.owner!=null )
			ball.owner.deactivate();

		wait(400, true, function() {
			announce(Lang.ShootOutBlocked, 0x80FF00);
			newRound();
		});
	}


	public function initPlayers() {
		var maxTries = 2000;
		var tries = 0;
		var minDist = 80.;
		var done = false;

		while( tries<maxTries && !done ) {
			try {
				initSeed(round*999+tries);

				for( p in en.Player.ALL )
					p.setOrigin(-999, -999);

				for(side in [0,1]) {
					var gr = stadium.getGoalRectangle(side);
					var or = stadium.getGoalRectangle(side==0 ? 1 :0);
					//var above = true;
					for( p in en.Player.getTeam(side) ) {
						var cx = 0.;
						var cy = 0.;
						if( p.isGoal ) { // Gardien
							cx = Const.FPADDING + rseed.range(2, 3);
							cy = gr.y + rseed.range(1, gr.h-1);
						}
						else if( p.id==1 ) { // Attaquant standard
							cx = Const.FPADDING + rseed.range(Const.FWID-9, Const.FWID-8);
							cy = or.y + rseed.range(0, or.h);
						}
						else if( p.id==2 && p.side==1 && oppTeam.hasPerk(_PTuto3) ) { // Tuto: centre adversaire
							cx = Const.FPADDING + Std.int(Const.FWID*0.5);
							cy = Const.FPADDING + Std.int(Const.FHEI*0.4);
						}
						else if( p.id==2 && p.side==0 && oppTeam.hasPerk(_PTuto3) ) { // Tuto: centre défenseur
							cx = Const.FPADDING + Std.int(Const.FWID*0.35);
							cy = Const.FPADDING + Std.int(Const.FHEI*0.4);
						}
						else if( p.id==2 && p.side==0 ) { // Défenseur
							cx = Const.FPADDING + rseed.range(8,10);
							cy = gr.y + rseed.range(0, gr.h);
						}
						else { // Autre joueur
							var m = 3;

							if( p.id%2==0 ) {
								// Défense
								cx = Const.FPADDING + rseed.range(m, Const.FWID*0.5-1);
							}
							else {
								// Attaque
								cx = Const.FPADDING + rseed.range(Const.FWID*0.5+1, Const.FWID-m);
							}
							cy = Const.FPADDING + rseed.range(m, Const.FHEI-m);
							//if( above )
								//cy = Const.FPADDING + rseed.range(m, Const.FHEI*0.5-1);
							//else
								//cy = Const.FPADDING + rseed.range(Const.FHEI*0.5+1, Const.FHEI-m);
							//above = !above;

							//if( p.id%2==0 )
								//cy = Const.FPADDING + rseed.range(m, Const.FHEI*0.5);
							//else
								//cy = Const.FPADDING + rseed.range(Const.FHEI*0.5, Const.FHEI-m);
						}

						// Reverse coordinate
						if( p.side==1 )
							cx = Const.FPADDING*2 + Const.FWID - cx;

						// Clamp bounds
						if( cy<Const.FPADDING )
							cy = Const.FPADDING;

						if( cy>=Const.FPADDING+Const.FHEI )
							cy = Const.FPADDING+Const.FHEI-1;

						// Apply
						p.setOrigin(Const.GRID*cx, Const.GRID*cy);

						// Check distances
						for(p2 in en.Player.ALL )
							if( p!=p2 && mt.deepnight.Lib.distanceSqr(p.origin.x, p.origin.y, p2.origin.x, p2.origin.y)<=minDist*minDist )
								throw "too close "+p+" "+p2;
					}
				}
				done = true;
			}
			catch(e:String) {
				tries++;
				//trace(e);
				if( minDist>40 )
					minDist-=1;
			}
		}

		#if debug
		trace("initPlayer tries = "+tries+" minDist="+minDist+" seed="+rseed.getSeed());
		#end
		if( tries>=maxTries )
			trace("TOTALLY FAILED");

		// Add stars
		var starsReq = switch( getVariant() ) {
			case Normal :
				if( getLevel()<20 )
					0;
				else if( getLevel()==20 )
					2;
				else
					rseed.irange(0,2);
			case Hard : Std.int(oppTeam.playerCount*0.3 + oppTeam.playerCount*0.3*getLevelRatio());
			case Epic : Std.int(oppTeam.playerCount*0.5 + oppTeam.playerCount*0.5*getLevelRatio());
		}
		starsReq = MLib.max(starsReq, oppTeam.forcedStars);
		starsReq-=en.Player.countStars(1);
		if( isMulti() )
			starsReq = 0;
		var pool = en.Player.getPotentialStars(1);
		while( pool.length>0 && starsReq>0 ) {
			var e = pool[rseed.random(pool.length)];
			e.setStar();
			pool = en.Player.getPotentialStars(1);
			starsReq--;
		}

		for(p in en.Player.ALL)
			p.updateStats();
	}

	public function addTime(sec:Int) {
		chrono += Const.seconds(sec);
		hud.updateValues();
	}


	public inline function getClickPower(side) {
		return
			if( chargeInfos[side].clickStart<0 )
				0;
			else {
				var max = 20 - (ball.hasOwner() ? (1-ball.owner.precision)*10 : 0);

				if( oppTeam.hasPerk(_PEasyPowerControl) )
					max = 25;

				var d = (time-chargeInfos[side].clickStart) % max;
				var phase = Std.int((time-chargeInfos[side].clickStart) / max)%2;
				if( phase==0 )
					Math.min(1, d/max);
				else
					Math.min(1, 1-d/max);
			}
	}


	public function getDefendMoveDir(e:en.Player, pow:Float) {
		var d = 100 * (0.3 + 0.7*pow);
		return {
			x	: e.xx + Math.cos(e.ang)*d,
			y	: e.yy + Math.sin(e.ang)*d
		}

	}

	public function resetCharge() {
		for(i in 0...2) {
			chargeInfos[i].clickStart = -1;
			chargeInfos[i].active = false;
		}
		movePreview.visible = false;
		enemyBar.visible = false;
		drag = null;
	}


	public function canDoAction() {
		return isPlaying() && ball.hasOwner() && ball.owner.side==0 && !ball.owner.cd.has("shootDelay") && ball.owner.isPlayable();
	}


	public inline function isCharging(side) {
		return chargeInfos[side].active;
	}


	function beginCharge(side) {
		if( chargeInfos[side].active )
			return;

		if( !en.Player.hasActive(side) )
			return;

		var e = en.Player.getActive(side);
		if( e.isKnocked() )
			return;

		movePreview.visible = !e.hasBall();

		chargeInfos[side].active = true;
		chargeInfos[side].clickStart = time;

	}

	public function endCharge(side, ?forced=false) {
		if( !chargeInfos[side].active && !forced )
			return;

		if( !en.Player.hasActive(side) )
			return;

		var e = en.Player.getActive(side);

		var clickPow = getClickPower(side);
		if( forced )
			clickPow = rseed.range(0.1, 0.4);
		resetCharge();

		if( e.hasBall() ) {
			// Kick ball
			e.kickBall(e.ang, 0.5+clickPow*0.5, clickPow);
			ball.makeUncatchable(0, 5);
		}
		else {
			// Move defender
			var t = getDefendMoveDir(e, clickPow);
			e.setTarget(t.x,t.y, 2);
			e.deactivate();
			e.cd.set("defend", Const.seconds(1));
			e.cd.set("faultEnabled", Const.seconds(0.8));
			e.cd.set("repositionLock", 99999);
			cd.set("autoPickDefender", Const.seconds(1));

			ball.owner.cd.set("waitKick", Const.seconds(0.5));
		}
	}




	public function onMouseDown(_) {
		if( !isPlaying() )
			return;

		var m = getMouse();
		var cornerX = Global.ME.playerCookie.data.leftHanded ? 0 : viewport.wid;
		//var d = Const.WID*0.35;
		var d = 160;
		if( !hud.wrapper.visible || Lib.distance(m.gx/Const.UPSCALE, m.gy/Const.UPSCALE, cornerX, viewport.hei) <= d )
			beginCharge(0);
		else
			drag = { x:m.x, y:m.y };
	}

	public function onMouseUp(_) {
		drag = null;

		if( !isPlaying() )
			return;

		endCharge(0);
	}

	function onMouseLeave(_) {
		mouseOutside = true;
		outTimer = 30;
	}


	function onSoftKeyDown(e:flash.events.KeyboardEvent) {
		if( destroyAsked )
			return;

		switch( e.keyCode ) {
			case flash.ui.Keyboard.BACK, flash.ui.Keyboard.MENU :
				e.preventDefault();
				if( !paused )
					onMenu();
		}
	}

	public function onMenu() {
		pause();
		new m.GameMenu();
	}


	public function goal(win:Bool) {

		if( win )
			score++;
		else
			score--;

		if( score<0 )
			score = 0;

		if( win )
			crowd.onGoal(win?0:1);

		var done = score>=getScoreTarget();

		if( done )
			setPhase( End(time+Const.seconds(1.2)) );

		for(p in en.Player.ALL)
			p.clearTarget();

		if( win ) {
			// But pour le joueur
			addStat("goal0", 1);

			fx.flashBang(0xFFDF00, 0.7, 2800);
			announce( Lang.ScoreGoal, 0x77B5FF );
			whistleGoal();

			tutorial.complete();

			cine.create({
				1000;
				hud.updateValues();
			});
			if( !matchEnded() ) {
				wait(1500, true, newRound);
				onGoal();
				Ga.event("play", "match", "goalScored" );
			}
			else {
				Ga.event("play", "match", "win" );
			}
		}
		else {
			// But pour les opponents
			addStat("goal1", 1);
			announce( ball.getLastOwnerSide()==1 ? Lang.ConcedeGoal : Lang.ConcedeGoalYourself, 0xFF0000, "looser" );

			fx.flashBang(0xFF0000, 0.7, 1000);
			whistleGoal();

			cine.create({
				1000;
				hud.updateValues();
				1000;
			});
			if( !matchEnded() ){
				wait(1000, true, newRound);
				Ga.event("play", "match", "goalAgainst" );
			}
			else
				Ga.event("play", "match", "lost" );

		}
	}



	public function gameOver() {
		if( fl_stopped )
			return;

		fl_stopped = true;
		if( score>=getScoreTarget() ) {
			// Victory !
			if( !oppTeam.isCustom && lid == Global.ME.playerCookie.getLastLevel(getVariant()) ) {
				switch( getVariant() ) {
					case Normal : Global.ME.playerCookie.data.lastLevelNormal++;
					case Hard : Global.ME.playerCookie.data.lastLevelHard++;
					case Epic : Global.ME.playerCookie.data.lastLevelEpic++;
				}
				Global.ME.playerCookie.save();
			}

			var stars = getStars();
			if( !oppTeam.isCustom )
				Global.ME.playerCookie.setStars(getVariant(), lid, stars);
			Global.ME.run(this, function() new MatchEnd(oppTeam, true, stars), false);
		}
		else {
			// You lose...
			Global.ME.run(this, function() new MatchEnd(oppTeam, false, 0), false);
		}
	}


	function getStars() {
		var d = realMatchDuration/Const.FPS;
		var ideal = switch( oppTeam.getScoreTarget() ) {
			case 1, 2 : 30;
			case 3 : 50;
			case 4 : 65;
			default : 80;
		}
		var n =
			if( d<=ideal )
				3;
			else if( d<=ideal+20 )
				2;
			else
				1;

		var total = n - getStat("goal1") - (getStat("redCard")>=3 ? 1 :0);
		return MLib.clamp(MLib.round(total), 0,Const.MAX_STARS);
	}


	public inline function getScoreTarget() {
		return oppTeam.getScoreTarget();
	}



	public function onTimeOut() {
		//if( getPlayerScore()==getOpponentScore() ) {
			//finalShootOuts = true;
			//wait(99999, true);
			//en.Player.deactivateCurrent();
			//cine.create({
				//announce(Lang.TimeOut, 0xFFFF00);
				//2500;
				//initFinalShootOuts();
			//});
		//}
		//else {
			cine.create({
				announce(Lang.TimeOut, 0xFFFF00, "looser");
				whistle();
			});
			setPhase( End(time+Const.FPS*2.5) );
		//}
	}


	//public function nextShootOut() {
		//curShootOutSide = curShootOutSide==0 ? 1 : 0;
		//trace("next "+curShootOutSide);
		//wait(99999, true);
		//en.Player.deactivateCurrent();
//
		//if( curShootOutSide==1 && getPlayerScore()!=getOpponentScore() ) {
			//cine.create({
				//700;
				//gameOver();
			//});
		//}
		//else {
			//cine.create({
				//1000;
				//prepareShootOut();
			//});
		//}
	//}



	public function getMouse() {
		var x = root.mouseX;
		var y = root.mouseY;
		return {
			gx		: x,
			gy		: y,
			x		: x/Const.UPSCALE - scroller.x,
			y		: y/Const.UPSCALE - scroller.y,
		}
	}


	function getViewportTarget() {
		var tx = viewport.focus.xx;
		var ty = viewport.focus.yy;
		if( viewport.focus==ball && ball.getOwnerOrLastOwnerSide()==0 )
			tx+=40;
		switch( phase ) {
			case RedCard(e, t) :
				if( time>=t ) {
					e.setSubstitute();
					wait(700, true, newRound);
				}

			default :
				// Center camera between ball and defender
				var active = en.Player.getActive(0); // HACK multi)
				if( active!=null && ball.owner!=active ) {
					tx = (active.xx*2+ball.xx*1) / 3;
					ty = (active.yy*2+ball.yy*1) / 3;
				}
		}
		return { x:tx, y:ty }
	}


	override function preUpdate() {
		super.preUpdate();

		Key.update();
		stadium.preUpdate();
	}

	override function update() {
		super.update();

		if( fl_stopped )
			return;

		if( outTimer>0 )
			outTimer--;

		// Timed events
		while( events.length>0 && time>=events[0].t )
			events.splice(0,1)[0].cb();

		// Entities
		for(e in Entity.ALL)
			e.update();
		Entity.garbageCollect();

		for(side in 0...2) {
			if( side==1 && !isMulti() )
				continue;

			// Power bar
			powerBar[side].visible = en.Player.hasActive(side);
			if( powerBar[side].visible )
				updatePowerBar(side);

			// Active player
			var active = en.Player.getActive(side);
			if( active!=null ) {
				if( isPlaying() ) {
					tutorial.trigger(_PTuto3, 2);
					tutorial.chain(_PTuto3, 3);
				}

				if( isCharging(side) ) {
					var p = getClickPower(side);

					// Move preview
					if( movePreview.visible ) {
						var t = getDefendMoveDir(active, p);
						movePreview.visible = true;
						movePreview.x = t.x - movePreview.width*0.5;
						movePreview.y = t.y - movePreview.height*0.5;
					}
				}

				// Rotation
				if( !isCharging(side) && isPlaying() )
					active.rotate();
			}
		}


		// Enemy bar
		if( enemyBar.visible ) {
			var e = ball.owner;
			if( e!=null ) {
				enemyBar.x = Std.int(e.xx-enemyBar.width*0.5);
				enemyBar.y = e.yy+3;
				enemyBar.bitmapData.fillRect( enemyBar.bitmapData.rect, 0x3D141F );
				var t = 1 - e.cd.get("waitKick") / e.iaKickDelay;
				var col = Color.addAlphaF( Color.interpolateInt(0x80FF00, 0xFF6000, t) );
				enemyBar.bitmapData.fillRect( new flash.geom.Rectangle(1,1, (enemyBar.width-2)*t, enemyBar.height-2), col );
			}
		}


		// Debug keys
		#if !prod
		if( Key.isToggled( flash.ui.Keyboard.D ) ) {
			var e = en.Player.getActive(0);
			//fx.hit(e.xx, e.yy);
			fx.grass(e.xx, e.yy, 10);
			//fx.airGrab(e);
		}

		if( Key.isToggled( flash.ui.Keyboard.S ) ) {
			hud.wrapper.visible = false;
			powerBar[0].visible = false;
			pause();
			var e = en.Player.getActive(0);
			if( e!=null )
				e.arrow.visible = false;
			Global.ME.delayer.add(function() {
				hud.wrapper.visible = true;
				resume();
			}, 2000);
		}

		if( Key.isToggled( flash.ui.Keyboard.H ) ) {
			var v = !hud.wrapper.visible;
			hud.wrapper.visible = v;
			Global.ME.dstats.visible = v;
		}
		#end




		// Viewport management
		var vx = viewport.x + viewport.wid*0.5;
		var vy = viewport.y + viewport.hei*0.5;
		var vt = getViewportTarget();
		var d = mt.deepnight.Lib.distance(vt.x, vt.y, vx,vy);
		var a = Math.atan2( vt.y-vy, vt.x-vx );
		var s = 0.04;
		if( drag==null ) {
			viewport.dx += Math.cos(a)*d*s;
			viewport.dy += Math.sin(a)*d*s;
		}

		// Scrolling
		viewport.x += viewport.dx;
		viewport.y += viewport.dy;
		if( drag!=null ) {
			var m = getMouse();
			viewport.x-=m.x-drag.x;
			viewport.y-=m.y-drag.y;
		}
		viewport.dx*=0.76;
		viewport.dy*=0.76;
		if( MLib.fabs(viewport.dx)<=0.2 ) viewport.dx = 0;
		if( MLib.fabs(viewport.dy)<=0.2 ) viewport.dy = 0;

		if( viewport.x+viewport.wid>stadium.wid ) viewport.x = stadium.wid-viewport.wid;
		if( viewport.x<0 ) viewport.x = 0;
		if( viewport.y + viewport.hei > stadium.hei-70 ) viewport.y = stadium.hei-viewport.hei-70;
		if( viewport.y<0 ) viewport.y = 0;
		scroller.x = -viewport.x;
		scroller.y = -viewport.y;

		// Shaking
		scroller.x += shakePow * Math.sin(time*1.7)*5;
		scroller.y += shakePow * Math.cos(time*2)*10;
		shakePow *= shakeFrict;

		// ZSort
		if( time%4==0 ) {
			zsortables.sort(function(a,b) return Reflect.compare(a.yy+a.z*10+a.zpriority, b.yy+b.z*10+b.zpriority));
			var z = 0;
			for(e in zsortables)
				e.spr.parent.setChildIndex(e.spr, z++);
		}

		cine.update();

		switch( phase ) {
			case Waiting(t, s, cb) :
				if( time>=t ) cb();
			//case WaitingPlayers :
				//var l = Lambda.filter(en.Player.ALL, function(p) return !p.nearOrigin());
				//if( l.length==0 )
					//setPhase(Playing);

			case Repositionning(cb) :
				var l = Lambda.filter(en.Player.ALL, function(p) return !p.nearOrigin());
				if( l.length==0 )
					cb();

			case End(t) :
				if( time>=t )
					gameOver();

			case ShootOut(_), RedCard(_), Init, TeamAnnounce, Playing :
		}


		// Chrono
		if( matchStarted() && isPlaying() ) {
			// Time out!
			if( chrono<=0 && ball.hasOwner() )
				onTimeOut();

			// Warnings
			if( chrono<=Const.seconds(60) && !cd.has("chrono60") ) {
				cd.set("chrono60", 999999);
				timeAnnounce( Lang.TimeWarning60 );
			}

			if( chrono<=Const.seconds(30) ) {
				if( !cd.has("chrono30") ) {
					cd.set("chrono30", 999999);
					timeAnnounce( Lang.TimeWarning30 );
				}
			}
			else
				cd.unset("chrono30");

			if( chrono<=Const.seconds(10) ) {
				if( !cd.has("chrono10") ) {
					cd.set("chrono10", 999999);
					timeAnnounce( Lang.TimeWarning10 );
				}
			}
			else
				cd.unset("chrono10");

			chrono--;
			if( chrono<0 )
				chrono = 0;
			realMatchDuration++;

			if( chrono%Const.FPS==0 )
				hud.updateValues();

			// Temps de contrôle de la balle
			totalDuration++;
			var bside = ball.hasOwner() ? ball.owner.side : ball.getLastOwnerSide();
			if( bside!=-1 )
				controlTimes[bside]++;
		}




		// Textures qui scrollent en fond
		if( bgScroll!=null ) {
			var s = 1;
			bgScroll.x-=s;
			bgScroll.y+=s*0.5;
			if( bgScroll.x<-bgScroll.width/Const.BG_SCROLL_REPEAT )
				bgScroll.x+=bgScroll.width/Const.BG_SCROLL_REPEAT;
			if( bgScroll.y>-bgScroll.height/Const.BG_SCROLL_REPEAT )
				bgScroll.y-=bgScroll.height/Const.BG_SCROLL_REPEAT;
		}

		if( getPerf()<=0.6 )
			lowq = true;

		iaKickPreview.visible = ball.hasOwner() && ball.owner.side==1 && getVariant()==Normal;

		hud.update();

		// Auto low quality
		if( !Global.ME.playerCookie.data.forcedQuality ) {
			if( Global.ME.fps()>=22 )
				slowFrames = 0;
			else if( !lowq ) {
				slowFrames++;
				if( slowFrames>Const.seconds(2) )
					Global.ME.setLowQuality();
			}
		}
		lowq = Global.ME.isLowQuality();

		if( windPower>0 && time%6==0 )
			fx.wind(windAng, windPower);
	}


	override function render() {
		super.render();

		stadium.update();
		fx.lowq = lowq;
		fx.update();

		tiles.updateChildren();
		misc.updateChildren();
		whiteGuys.updateChildren();
		blackGuys.updateChildren();
		shirtA.updateChildren();
		shirtB.updateChildren();
		//mt.deepnight.slb.BSprite.updateAll();

		for(e in en.Player.ALL)
			e.postRender();
	}
}



