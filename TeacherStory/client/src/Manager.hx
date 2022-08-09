import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.BlendMode;
import flash.ui.Keyboard;
import mt.gx.MathEx;

import mt.flash.Key;
import mt.deepnight.Cinematic;
import mt.deepnight.Tip;
import mt.deepnight.Color;
import mt.deepnight.Lib;

import mt.deepnight.Buffer;
import mt.deepnight.SpriteLib;
import mt.deepnight.Tweenie;
import mt.deepnight.PathFinder;
import mt.deepnight.Sfx;
import mt.deepnight.SuperText;

import haxe.macro.Expr;

import Const;
import Common;
import Iso;
import iso.Student;
import iso.Teacher;

import Tx;

@:bitmap("gfx/tiles.png") class GfxTiles extends BitmapData { }
@:bitmap("gfx/characters.png") class GfxCharacters extends BitmapData { }
@:bitmap("gfx/hud.png") class GfxHud extends BitmapData { }
@:bitmap("gfx/hudOver.png") class GfxHudOver extends BitmapData { }
@:sound("sfx_uncompressed/sick.wav") class SndSickLoop extends flash.media.Sound { }

class Manager implements haxe.Public {//}
	static var SBANK = Sfx.importDirectory(#if debug "sfx" #else "sfx_compress" #end);
	public static var ME : Manager;
	public static var TW : Tweenie;
	
	var root			: MovieClip;
	var dm				: mt.DepthManager;
	var buffer			: Buffer;
	var cm				: Cinematic;
	var parallelCM		: Cinematic;
	var tw				: Tweenie;
	var cd				: mt.deepnight.Cooldown;
	var tg				: TextGen;
	var tiles			: SpriteLib;
	var chars			: SpriteLib;
	var spf				: PathFinder;
	var tpf				: PathFinder;
	var tuto			: Tutorial;
	var fx				: Fx;
	var flashBang		: Bitmap;
	var darkness		: Bitmap;
	var computerGlow	: Bitmap;
	var homeLight		: Bool;
	var neons			: Bitmap;
	var lightSources	: Hash<Bool>;
	var lockActions(default, setLockActions) : Bool;
	var lockObjects		: Bool;
	var ready			: Bool;
	var gameStarted		: Bool;
	var gameEnded		: Bool;
	var time			: Float;
	var curPlace		: GamePlace;
	var subject			: Subject;
	var prod			: Bool;
	var music			: Sfx;
	var ambiantLoop		: Sfx;
	var ringTone		: Sfx;
	var sick			: Bool;
	var dead			: Bool;
	var interMission	: Bool;
	var boughtSlots		: Bool;
	var boughtSlotsRecently: Bool;
	var photoMode		: Bool;
	var curSoundState	: Int;
	var assistant		: Null<Iso>;

	var helper 			: Null<iso.Helper> ;
	var supervisorSeats	: Array<{cx:Int, cy:Int}>;
	
	var delayer			: mt.deepnight.Delayer;

	var solver			: logic.Solver;
	var cinit			: ClientInit;
	var furns			: Hash<Iso>;
	
	var students		: IntHash<Student>;

	var teacher			: iso.Teacher;
	var lightSwitch		: Iso;

	var scroll			: {cx:Float, cy:Float};
	var bscroller		: Sprite;
	var gscroller		: Sprite;
	var sdm				: mt.DepthManager;
	var cursor			: Iso;
	var roomBg			: Sprite;
	var isos			: Array<Iso>;
	var tip				: Tip;
	var dofBlur			: Bitmap;
	var arrow			: {target:Null<Iso>, spr:DSprite};
	
	var bus				: iso.Bus;
	var bike			: iso.Bike;

	var lastActions		: Array<{a:TAction, c:Int}>;
	var mainBar			: ActionBar;
	var randBar			: ActionBar;
	
	//var btSwap			: Sprite;
	
	//var superCont		: Sprite; // TODO BAR
	//var superBar		: ActionBar;
	
	//var invBar			: ActionBar;
	
	//var objects2		: Bag<Int>;
	//var equipments		: ActionBar<Int>;
	var homeCustomizer	: HomeCustomizer;
	var hudWrapper		: Sprite;
	var hud				: lib.Hud;
	var lifeText		: flash.text.TextField;
	var timeText		: flash.text.TextField;
	var oldTime			: Int;
	var lastQuestion	: Null<HandUp_What>;
	var door			: {spr:lib.Porte, iso:Iso};
	var plasma			: Bitmap;
	var plasmaBg		: Sprite;
	var cineBand1		: Sprite;
	var cineBand2		: Sprite;
	var bgEventTimer	: Float;
	
	var globalTimer		: Null<{wrapper:Sprite, bg:lib.Chrono, button:Sprite, costTxt : SuperText, cost : Int, end:Date}>;
	var sickInfos 		: Null<{auto : Bool, next : Float, step : Float}> ;

	var serverTimeOff	: Float;
	
	var dragInfos		: Null<{s:Float, mx:Float,my:Float, sx:Float,sy:Float}>;
	var cancelClick		: Bool;
	
	var logs			: List<LessonLog>;
	var pendingAction	: Null<{a:TActionData, sub:Null<Dynamic>, target0:Null<AcTarget>}>;
	var pendingCursor	: Null<Sprite>;
	var potentialTargets: Array<{type:PotentialTargetType, value:AcTarget}>;
	var targets			: Array<AcTarget>;
	var neededTargets	: Int;
	//var lastOverIso		: Null<Iso>;
	var overedStudent	: Null<Student>;
	var allOveredIsos	: Array<Iso>;
	var overedIso		: Null<Iso>;
	var lastDetails		: Null<Int>;
	var studentTip		: Null<Bitmap>;
	var studentTipAnim	: Null<DSprite>;
	var studentTipMask	: Null<Bitmap>;
	//var studentName		: Null<Bitmap>;
	var focus			: {wrapper:Sprite, mask:Sprite, hole:Sprite, isoHole:Sprite};
	var curQuery		: Null<Sprite>;
	var cancellableQuery: Bool;
	var curMessage		: Null<Sprite>;
	var curMessageRedirect : Null<String> ;
	var curPointer		: Null<Sprite> ;
	var curPicture		: Null<{loader:flash.display.Loader, wrapper:Sprite}> ;
	var delayedTip		: Null<Void->Void>;
	var lastTurn		: Int;
	
	var mouse			: {x:Float, y:Float};
	var bmouse			: {x:Int, y:Int};

	var domain 			: String ;
	
	var queue			: List<Void->Void>;
	
	var stats			: mt.kiroukou.debug.Stats;
	var fps				: Int;
	var serverIsOk 		: Bool ;
	var fatalError 		: Bool ;
	var waitingUrl 		: Array<String> ;

	var langDivisor 	: Float ;
	
	public function new(r) {
		ME = this;
		root = r;
		root.stage.quality = Const.QUALITY;
		haxe.Log.setColor(0xFFFF00);
		Lib.redirectTracesToConsole();
		mt.Timer.wantedFPS = 30;
		cd = new mt.deepnight.Cooldown();
		
		root.addEventListener( flash.events.Event.ENTER_FRAME, main );
		furns = new Hash();
		students = new IntHash();
		isos = new Array();
		lastActions = [];
		allOveredIsos = [];
		supervisorSeats = [];
		//actions = new Array();
		ready = false;
		gameStarted = false;
		gameEnded = false;
		potentialTargets = new Array();
		targets = new Array();
		neededTargets = 0;
		queue = new List();
		lockActions = false;
		time = 0;
		cancelClick = false;
		scroll = {cx:0, cy:0};
		oldTime = 999;
		lockObjects = false;
		bgEventTimer = Std.random(32*10);
		lightSources = new Hash();
		lastTurn = -1;
		sick = false;
		interMission = false;
		serverTimeOff = 0;
		boughtSlots = false;
		boughtSlotsRecently = false;
		dead = false;
		curSoundState = 0;
		serverIsOk = true ;
		fatalError = false ;
		waitingUrl = new Array() ;
		photoMode = false;
		
		// Lecture des données d'init
		cinit = tools.Codec.getData("d");
		photoMode = cinit._picture==true;
		langDivisor = cinit._div ;

		
		// JS connect
		try {
			flash.external.ExternalInterface.addCallback("_js", jsCall);
			flash.system.Security.allowDomain("dev.teacherstory.com");//TODO Remove this line if not needed anymore

			for (d in ["", "www.","beta.","data."])
				for (lang in ["fr", "com", "es"])
					flash.system.Security.allowDomain(d+"teacher-story." + lang) ;

			

		}
		catch (e:Error) { }
		
		domain = getFlashVar("dom");
		prod = getFlashVar("dev")!="true";
		Const.LANG = getFlashVar("lang");
		if( Const.LANG==null )
			Const.LANG = "fr";

		Tx.init( haxe.Resource.getString("texts") );
		tg = new TextGen( haxe.Resource.getString("random") );
		tg.postProcess = function(s) {
			return StringTools.replace(s, "::pupil::", "[TODO NOM]");
		}

		Sfx.setGlobalVolume(Const.GLOBAL_VOLUME);
		
		delayer = new mt.deepnight.Delayer();
		cm = new Cinematic();
		cm.onAllComplete = playLog;
		parallelCM = new Cinematic();
		fx = new Fx();
		
		Key.init();
		
		tw = new Tweenie();
		TW = tw;
		
		dm = new mt.DepthManager(root);

		var g = root.graphics;
		g.beginFill(0x1D2525,1);
		g.drawRect(0,0,Const.WID, Const.HEI);
		g.endFill();
		
		buffer = new Buffer(340, 175, photoMode ? Const.UPSCALE : Const.UPSCALE, false, 0x292929);
		dm.add(buffer.render, Const.DP_BUFFER);
		
		// Scrollers
		bscroller = new Sprite();
		bscroller.x = bscroller.y = -999;
		buffer.dm.add(bscroller, Const.DP_SCROLLERS);
		sdm = new mt.DepthManager(bscroller);

		gscroller = new Sprite();
		dm.add(gscroller, Const.DP_SCROLLERS);
	
		// Fond du plasma
		plasmaBg = new Sprite();
		buffer.dm.add(plasmaBg, Const.DP_BG);
		
		// Plasma
		var s = 3;
		plasma = new Bitmap( new BitmapData(Math.ceil(buffer.width*1/s), Math.ceil(buffer.height*1/s), false, 0x0) );
		buffer.dm.add(plasma, Const.DP_BG);
		plasma.scaleX = plasma.scaleY = s;
		plasma.alpha = 0.5;
		plasma.blendMode = BlendMode.OVERLAY;
		
		plasma.visible = plasmaBg.visible = false;
		
		// Texture plasma
		var w = Std.int( buffer.width );
		var h = Std.int( buffer.height );
		var tt = Buffer.makeMosaic2(s);
		var t = new Bitmap( new BitmapData(w, h, true, 0x0) );
		buffer.dm.add(t, Const.DP_BG);
		var spr = new Sprite();
		var g = spr.graphics;
		g.beginBitmapFill(tt, true, false);
		g.drawRect(0,0,w, h);
		g.endFill();
		t.bitmapData.draw(spr);
		t.blendMode = BlendMode.OVERLAY;
		t.alpha = 0.10;
		tt.dispose();
		
		// Flash blanc
		var wf = new Sprite();
		wf.graphics.beginFill(0xFFFF80, 1);
		wf.graphics.drawRect(0,0,buffer.width, buffer.height);
		flashBang = Lib.flatten(wf);
		flashBang.visible = false;
		flashBang.blendMode = BlendMode.ADD;
		buffer.dm.add(flashBang, Const.DP_MASK);
		
		// Bandes cinéma
		var h = 15;
		//var col = SHADOW_COLOR;
		var col = 0x1c151a;
		cineBand1 = new Sprite();
		buffer.dm.add(cineBand1, Const.DP_INTERF);
		cineBand1.graphics.beginFill(col,1);
		cineBand1.graphics.drawRect(-2,0, buffer.width+4, h);
		cineBand1.graphics.lineStyle(1, 0xFFFFFF, 0.2);
		cineBand1.graphics.moveTo(0,h);
		cineBand1.graphics.lineTo(buffer.width,h);
		cineBand1.filters = [ new flash.filters.DropShadowFilter(4,90, 0x0,0.6, 0,8,1) ];
		cineBand1.visible = false;
		
		cineBand2 = new Sprite();
		cineBand2.mouseChildren = cineBand2.mouseEnabled = false;
		buffer.dm.add(cineBand2, Const.DP_INTERF);
		cineBand2.graphics.beginFill(col,1);
		cineBand2.graphics.drawRect(0,buffer.height-h, buffer.width, h);
		cineBand2.graphics.lineStyle(1, 0xFFFFFF, 0.2);
		cineBand2.graphics.moveTo(0, buffer.height-h);
		cineBand2.graphics.lineTo(buffer.width, buffer.height-h);
		cineBand2.filters = [ new flash.filters.DropShadowFilter(4,-90, 0x0,0.6, 0,8,1) ];
		cineBand2.visible = false;
		setCine(false);
		
		
		tiles = new SpriteLib( new GfxTiles(0,0) );
		tiles.setDefaultCenter(0.5, 0);
		tiles.slice("collision", 0,0, 28,32);
		tiles.slice("cursor", 28,0, 28,32);
		tiles.slice("silhouette", 4*16,0, 19,24);
		tiles.slice("shadow", 5*16,0, 16,16);
		tiles.slice("droppedObject", 6*16,0, 16,16);
		tiles.slice("check", 0,16*2, 6,6);
		tiles.slice("bag", 0, 16*2, 32,48);
		tiles.slice("supers", 32*1, 16*2, 32,48);
		tiles.slice("swap", 32*2, 16*2, 32,32);
		tiles.slice("scrollArrow", 16*6, 16*2, 16,32, 2);
		tiles.slice("buy", 16*8, 16*2, 32,32);
		tiles.slice("smallLife", 0,5*16, 6,7);
		tiles.slice("smallShield", 6,5*16, 6,7);
		tiles.slice("largeJauge", 0,6*16, 14,11, 3);
		tiles.slice("budget", 0,256, 23,17);
		
		tiles.setUnit(16,16);
		tiles.sliceUnit("hit", 0,8, 2);
		tiles.sliceUnit("note", 2,8, 3);
		tiles.sliceUnit("arrow", 5,8);
		tiles.sliceUnit("dots", 0,9, 3);
		tiles.sliceUnit("mouse", 0,10, 5);
		tiles.sliceUnit("life", 5,10);
		tiles.sliceUnit("queryArrow", 6,10);
		tiles.slice("subHud", 0,11*16, 112,33);
		tiles.slice("light", 0,14*16, 16*4, 16*2);
		tiles.setAnim("right", [0,2,1,0], [5,15,1]);
		tiles.setAnim("left", [0,4,3,0], [5,15,1]);
		tiles.slice("buffIcons", 0,7*16, 9,7, 2);
		
		chars = new SpriteLib( new GfxCharacters(0,0) );
		chars.setUnit(17,25);
		chars.setDefaultCenter(0.5, 0);
		chars.sliceUnit("torso", 0,0);
		chars.sliceUnit("legs", 1,0);
		chars.sliceUnit("head", 2,0, 4);
		chars.sliceUnit("shadow", 5,0);
		
		var line = 1;
		chars.slice("arms_full", 0,32*(line++), 17,25, 18);
		chars.slice("arms_short", 0,32*(line++), 17,25, 18);
		chars.slice("legs_anim", 0,32*(line++), 17,25, 8);
		chars.setAnim("write", 12,
			[0,1, 0,1, 0,1, 0,1, 2,3,  2,3, 2,3, 2,3, 2,3,  4,5, 4,5, 4,5, 4,5],
			[1,2, 1,1, 1,3, 2,3, 2,2,  1,2, 4,1, 2,3, 1,3,  2,3, 1,3, 1,2, 1,2] );
		chars.setAnim("walk", 0, [0,1,2,3,4,5,6,7], [2,2,4,2,2,2,4,2]);
		
		chars.slice("hair_m", 0,32*(line++), 23,17, 30);
		chars.slice("hair_f", 0,32*(line++), 23,17, 30);
		chars.slice("eyes", 0,32*(line++), 17,25, 16);
		chars.setAnim("eyes_blink", [1,2,0], [1]);
		chars.slice("mouth_m", 0,32*(line++), 17,25, 25);
		chars.setAnim("talk", [0,2], [4]);
		chars.slice("mouth_f", 0,32*(line++), 17,25, 25);
		
		chars.slice("shirt_m", 0,32*(line++), 17,25, 12);
		chars.slice("shirt_f", 0,32*(line++), 17,25, 12);
		chars.slice("trousers_m", 0,32*(line++), 17,25, 5);
		chars.slice("trousers_f", 0,32*(line++), 17,25, 5);
		
		mouse = getMouse();
		bmouse = getMouseBuffer();

		// Super textes
		SuperText.registerGlobalImage("boredom", tiles.getSprite("largeJauge",1));
		SuperText.registerGlobalImage("life", tiles.getSprite("largeJauge",2));
		SuperText.registerGlobalImage("life2", tiles.getSprite("largeJauge",0));
		SuperText.registerGlobalImage("smallLife", tiles.getSprite("smallLife"));
		SuperText.registerGlobalImage("smallBoredom", tiles.getSprite("smallShield"));
		SuperText.registerGlobalImage("budget", tiles.getSprite("budget"));
		SuperText.registerGlobalImage("buff", tiles.getSprite("buffIcons", 0));
		SuperText.registerGlobalImage("debuff", tiles.getSprite("buffIcons", 1));
		
		// Flêche highlight student
		arrow = {target:null, spr:tiles.getSprite("arrow") };
		sdm.add(arrow.spr, Const.DP_INTERF);
		arrow.spr.setCenter(0.5,1);
		arrow.spr.visible = false;

		// Tooltip
		tip = new Tip( new mt.deepnight.TipSprite(0x000000, 0xFFFFFF) );
		tip.bgFilters = [ new flash.filters.DropShadowFilter(2,45, 0x0,0.6, 4,4) ];
		tip.padding = 2;
		tip.yOffset = 24;
		tip.alignCenter = true;
		tip.popDelay = 5;
		tip.setFont("big", 16);
		dm.add(tip.spr, Const.DP_TIP);
		
		// Tutorial
		tuto = new Tutorial();
		dm.add(tuto.container, Const.DP_TUTORIAL);
		
		stats = new mt.kiroukou.debug.Stats(!prod);
		root.addChild(stats);
		stats.x = Const.WID-70;
		stats.y = 5;
		#if debug
		stats.visible = !photoMode;
		#else
		stats.visible = false;
		#end
		
		// Ecran chargement
		var mask = new Sprite();
		dm.add(mask, Const.DP_INTERF);
		mask.graphics.beginFill(Const.SHADOW_COLOR, 1);
		mask.graphics.drawRect(0,0,Const.WID,Const.HEI);
		var tf = createField(Tx.Initializing, Font.FSmall, true);
		mask.addChild(tf);
		tf.scaleX = tf.scaleY = 2;
		tf.x = Std.int(Const.WID*0.5 - tf.width*0.5);
		tf.y = Std.int(Const.HEI*0.5 - tf.height*0.5);
		delayer.add( function() {
			// Init (une frame plus tard)
			onInit() ;
			tf.visible = false;
			tw.create(mask, "alpha", 0, 1500).onEnd = function() {
				mask.parent.removeChild(mask);
			}
		}, 1);
		mt.Timer.pause();
	}
	
	function getFlashVar(k:String) {
		return Reflect.field(flash.Lib.current.stage.loaderInfo.parameters, k);
	}


	public function noteDiv(n : Float) : Float {
		return n / langDivisor ;
	}
	
	
	function setPlasma(c1:Int, c2:Int) {
		plasma.visible = plasmaBg.visible = true;
		var m = new flash.geom.Matrix();
		m.createGradientBox(buffer.width, buffer.height, 3.14*0.5);
		plasmaBg.graphics.beginGradientFill(
			flash.display.GradientType.LINEAR, [c1, c2], [1,1], [0,255], m
		);
		plasmaBg.graphics.drawRect(0, 0, buffer.width, buffer.height);
	}
	
	inline function freeMove() {
		return at(HQ) || at(Home) && !sick && !photoMode;
		//return true; // HACK
	}
	
	inline function at(p:GamePlace) {
		if( curPlace==null )
			return false;
		else
			return Type.enumIndex(p)==Type.enumIndex(curPlace);
	}


	public function isLogged() {
		return !cinit._freePlay ;
	}
	
	function updateConstants() {
		switch(curPlace) {
			case Class :
				Const.RWID = 12;
				Const.RHEI = 12;
				Const.EXIT = {x:1, y:9}
			case HQ :
				Const.RWID = 7;
				Const.RHEI = 11;
				Const.EXIT = {x:4, y:1}
			case Home :
				Const.RWID = 8;
				Const.RHEI = 9;
				Const.EXIT = {x:1, y:4}
		}
		Const.CORNER1 = {x:Const.RWID-1, y:Const.RHEI-1}
		Const.CORNER2 = {x:Const.RWID-1, y:1}
		Const.BOARD = {x:Std.int(Const.RWID*0.5), y:Const.RHEI-1}
		Const.ACT_SPOT = {x:Const.BOARD.x, y:Const.BOARD.y-1}
		Const.DESK = {x:Std.int(Const.RWID*0.5)-1, y:Const.RHEI-2}
		if( at(Home) )
			Const.MUSIC_VOLUME*=0.8;
		Iso.initHeightMap();
	}
	
	function gotoBank() {
		flash.external.ExternalInterface.call("_openBank") ;
	}
	
	function gotoUrl(u:String) {
		//#if debug
		//debug("GOTO URL : "+u);
		//#else
		if (serverIsOk || fatalError)
			flash.Lib.getURL( new flash.net.URLRequest(u), "_self" ) ;
		else
			waitingUrl.push(u) ;
		//#end
	}
	

	function checkLevelUp() {
		tools.Codec.load("http://" + cinit._extra._urlLevelUp, null, onCheckReturn, 5) ;
	}

	function checkMissionDone() {
		tools.Codec.load("http://" + cinit._extra._urlMissionDone, null, onCheckReturn, 5) ;
	}

	function onCheckReturn(u : Null<String>) {
		if (u == null)
			return ;
		gotoUrl(u) ;
	}

	
	function setCine(b:Bool) {
		if( photoMode )
			return;
		tw.terminate(cineBand1);
		tw.terminate(cineBand2);
		if( Const.LOWQ || fps<=25 ) {
			tw.terminate(cineBand1);
			tw.terminate(cineBand2);
			cineBand1.visible = cineBand2.visible = b;
			cineBand1.alpha = cineBand2.alpha = 0.8;
			cineBand1.y = cineBand2.y = 0;
		}
		else
			if( b ) {
				cineBand1.visible = true;
				cineBand1.alpha = 0;
				cineBand1.y = 0;
				tw.create(cineBand1,"alpha", 0.8, TEase, 500);
				
				cineBand2.visible = true;
				cineBand2.alpha = 0;
				cineBand2.y = 0;
				tw.create(cineBand2,"alpha", 0.8, TEase, 500);
			}
			else {
				tw.create(cineBand1,"y", -cineBand1.height, TEase, 1000).onEnd = function() {
					cineBand1.visible = false;
				}
				tw.create(cineBand2,"y", cineBand2.height, TEase, 1000).onEnd = function() {
					cineBand2.visible = false;
				}
			}
	}
	
	
	function setGlobalTimer(d:Date, animate:Bool) {
		var d = DateTools.delta(d, serverTimeOff);
		if( globalTimer!=null )
			globalTimer.wrapper.parent.removeChild(globalTimer.wrapper);
		var w = 180;
			
		var wrapper = new Sprite();
		dm.add(wrapper, Const.DP_CHRONO);
		wrapper.x = 10;
		wrapper.y = 10;
			
		// Base bg
		var bg = new lib.Chrono();
		wrapper.addChild(bg);
		bg.scaleX = bg.scaleY = 2;
		bg.x = 4;
		bg.y = 55;
		bg.filters = [
			new flash.filters.DropShadowFilter(6,-90, 0x0,0.5, 0,0,1, 1,true),
		];
		
		// Button wrapper
		var button = new Sprite();
		wrapper.addChild(button);
		//button.y = 85;
		button.buttonMode = button.useHandCursor = true;
		
		// Button bg
		var butBg = new Sprite();
		button.addChild(butBg);
		if (sick && !sickInfos.auto)
			butBg.graphics.beginFill(0xffb400, 1);
		else
			butBg.graphics.beginFill(0xCC4206, 1);

		butBg.graphics.drawRect(0,0,w,48);
		butBg.filters = [
			new flash.filters.GlowFilter(0x0,0.1, 32,32,1, 1,true),
			new flash.filters.DropShadowFilter(1,90, 0xFFFFFF,0.2, 0,0,1, 1,true),
			new flash.filters.DropShadowFilter(4,-90, 0x0,0.3, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,1, 4,4,8),
		];
		
		// Button labels
		var label =
			if(sick && !sickInfos.auto) Tx.HealChronoLabel
			else if( interMission ) Tx.NewMissionChronoLabel;
			else Tx.SkipChronoLabel;
		var tf = createField(label, FSmall, true);
		button.addChild(tf);
		tf.scaleX = tf.scaleY = 2;
		tf.y = -1;
		
		var stf = (globalTimer != null) ? globalTimer.costTxt : new SuperText() ;
		button.addChild(stf.wrapper);
		stf.setFont(0xFFFFFF, "big", 16);
		stf.setText("("+logic.Data.CONTINUE_COST+"_{budget})") ;
		stf.y = 22;
		stf.disableMouse();
		stf.autoResize();
		
		// Button positioning
		tf.x = Std.int( button.width*0.5 - tf.width*0.5 );
		stf.x = Std.int( button.width*0.5 - stf.width*0.5 );
		
		// Events
		var timerOver = new Sprite();
		wrapper.addChild(timerOver);
		timerOver.graphics.beginFill(0xFFFF00,0);
		timerOver.graphics.drawRect(5,70,bg.width-25, 50);
		var time = DateTools.format(d, "%H:%M");
		timerOver.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) tip.show(Tx.ChronoTip({_time:time})) );
		timerOver.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) tip.hide() );
		button.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
			lockActions = true;
			SBANK.actionSend().play();
			if( teacher.data.gold<globalTimer.cost )
				gotoBank();
			else
				skipChrono();
		});
		button.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) {
			tip.show((sick && !sickInfos.auto) ? Tx.HealChrono : Tx.SkipChrono);
			button.filters  = [ new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,6) ];
		});
		button.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) {
			tip.hide();
			button.filters  = [];
		});
		
		globalTimer = {wrapper:wrapper, bg:bg, end:d, button:button, costTxt : stf, cost : 100};
		updateGlobalTimer();

		updateTimerCost() ;

		
		var noWait = updateGlobalTimer() ;
		
		if( !noWait && animate ) {
			wrapper.y = -100;
			tw.create(wrapper, "y", 10, TEaseOut, 500);
		}
	}



	function updateTimerCost() {
		if (globalTimer == null)
			return ;

		var d = globalTimer.end ;

		var nCost = (sick && !sickInfos.auto) ? logic.Data.RESURRECT_COST : logic.Data.getContinueCost(cinit._solverInit._teacherData._llt, d.getTime() - ((sick) ? logic.Data.ILL_TIME : logic.Data.WAITING_TIME), Date.now().getTime()) ;

		if (nCost != globalTimer.cost) {
			globalTimer.cost = nCost ;
			globalTimer.costTxt.clear() ;
			globalTimer.costTxt.setText("("+globalTimer.cost+"_{budget})");
		}
	}

	
	function updateGlobalTimer() {
		var delta = globalTimer.end.getTime() - Date.now().getTime();
		if( delta<0 )
			delta = 0;
			
		var t = DateTools.parse(delta);
			
		globalTimer.bg._hour1.text = Lib.leadingZeros(t.hours, 2).charAt(0);
		globalTimer.bg._hour2.text = Lib.leadingZeros(t.hours, 2).charAt(1);
		
		globalTimer.bg._min1.text = Lib.leadingZeros(t.minutes, 2).charAt(0);
		globalTimer.bg._min2.text = Lib.leadingZeros(t.minutes, 2).charAt(1);
		
		globalTimer.bg._sec1.text = Lib.leadingZeros(t.seconds, 2).charAt(0);
		globalTimer.bg._sec2.text = Lib.leadingZeros(t.seconds, 2).charAt(1);

		if( delta==0 && !cd.hasSet("autoRedir", 9999) ) {
			haxe.Timer.delay( function() { gotoUrl(cinit._extra._urlNext+"?auto=1"); }, 1500 );
			return true ;
		}

		updateTimerCost() ;

		if (!sick)
			return false ;

		var sDelta = sickInfos.next - Date.now().getTime() ;

		if (sDelta <= 0) {
			logs = new List() ;
			logs.push(L_TeacherHeal(1)) ;
			logs.push(L_SelfControl(1)) ;
			playLog() ;
			sickInfos.next += sickInfos.step ;
		}
		return false ;
	}
	
	
	function onInit() {
		Sfx.disable();
		if( cinit._time!=null )
			serverTimeOff = Date.now().getTime() - cinit._time._now.getTime();
		
		curPlace = switch(cinit._period) {
			case Lesson(s) :
				subject = s;
				Class;
			case Break : HQ;
			case Rest : Home;
			case NeedMission : interMission = true ; Home ;
			case Ill :
					sick = true;
					var sInfos = cinit._solverInit._teacherData._ill ;
					sickInfos = {auto : sInfos._auto,
								next : DateTools.delta(Date.fromTime(sInfos._next), serverTimeOff).getTime(),
								step : sInfos._step} ;
					Home;
		}
		
		//if( !prod ) subject = S_Science; // HACK
		
		// Variables pour text-gen
		tg.setVar("user", cinit._extra._userName);
		
		/*
		if( !prod && at(Home) ) {
			sick = true;
			autoSick = true ;
			setGlobalTimer(DateTools.delta(Date.now(), 3600*1000), false);
		}*/
		
		updateConstants();
		solver = new logic.Solver();
		logs = solver.init(cinit._period, cinit._solverInit, cinit._gold, cinit._hp, cinit._time);

		// Prof
		teacher = new iso.Teacher(solver.teacher);
		teacher.initData();
		teacher.setPos(Const.EXIT);
		tuto.loadState(cinit._tutorialData);
		switch( curPlace ) {
			case Class :
			case HQ, Home :
				teacher.speed *= 0.7;
				teacher.autoRun = 1.5;
		}
		teacher.setInCasePos(Const.BOARD, 0.5, 0.9);


		if( at(Class) ) {
			// Equipements
			for (pt in solver.teacher.items) {

				// Tables d'élèves
				var i = new Iso( pt._x, pt._y+1 );
				var mc = new lib.TableEleve();
				mc.gotoAndStop(switch(subject) {
					case S_History : 3;
					case S_Science : 4;
					case S_Math : 1;
				});
				i.addFurnMc(mc, "table#" + pt._x + "," + pt._y, -6, -8);
				i.collides = true;
				i.update();
				teacher.setInCasePos({x:pt._x+1, y:pt._y+1}, 0.7, 0.5);
				
				// Chaises
				var i = new Iso( pt._x, pt._y );
				var mc = new lib.ChaiseEleve();
				mc.gotoAndStop(1);
				i.addFurnMc(mc, "chair#" + pt._x + "," + pt._y, -10, -5);
				i.collides = false;
				teacher.setInCasePos(i.getPoint(), 0.5, 0.3);
			}


			if (solver.helper != null) {
				helper = switch( solver.helper ) {
					case Helper.Director : new iso.h.Director();
					case Helper.Dog : new iso.h.Dog();
					case Helper.Eddy : new iso.h.Eddy();
					case Helper.Einstein : new iso.h.Tizoc();
					case Helper.Inspector : new iso.h.Inspector();
					case Helper.Skeleton : new iso.h.Nuke();
					case Helper.Peggy : new iso.h.Peggy();
					case Helper.Supervisor : new iso.h.Supervisor();
				}
			}
		}



		
		// élèves
		for(data in solver.students) {
			var s = new iso.Student( createCopy(data) );

			students.set(data.id, s);
			
			if( Lambda.filter(cinit._solverInit._students, function(s2) return s2._i == data.id).first()._new>0 )  {
				// Nouvel élève
				s.setPos(Const.EXIT);
				s.newbie = true;
				s.setStuffVisibility(false);
				s.fl_visible = false;
			}
			else if( Lambda.filter(cinit._solverInit._students, function(s2) return s2._i == data.id).first()._late>0 )  {
				// Retard
				s.setPos(Const.EXIT);
				s.late = true;
				s.setStuffVisibility(false);
				s.fl_visible = false;
			}
			else
				if( at(Class) )
					s.setPos(data.seat.x, data.seat.y);
				else
					s.setPos(-3,5);
				
			if( hasSeat(s.cx-1, s.cy) )
				s.setStandPoint(1,0);
			else
				s.setStandPoint(-1,0);
			if( s.data.isPet() ) {
				var mc = new lib.GoodBad();
				mc.gotoAndStop(1);
				mc._sub.gotoAndStop(2);
				s.addLinkedSprite("halo", mc, 0,s.headY*2-17);
				mc.parent.swapChildren(mc, s.bar); // berk...
			}
			s.setBarVisibility(false);
			s.setHostile( s.data.hostile );
			s.updatePhoto();
			s.updateStuffPosition();
			s.fl_visible = s.fl_visible && at(Class);
		}
		
		
		// BG HUD
		var bmp = new Bitmap( new GfxHud(0,0) );
		dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.y = Const.HEI-bmp.height;
		bmp.visible = !photoMode;
		
		// SOUS HUD
		//var s = tiles.getSprite("subHud");
		//s.setCenter(0,0);
		//dm.add(s, Const.DP_SUB_INTERF);
		//s.scaleX = s.scaleY = 2;
		//s.x = Std.int(Const.WID*0.5 - s.width*0.5);
		//s.y = bmp.y+57;
		
		// HUD
		hudWrapper = new Sprite();
		dm.add(hudWrapper, Const.DP_INTERF);
		hudWrapper.y = Const.HEI;
		hudWrapper.visible = !photoMode;
		
		hud = new lib.Hud();
		hud.scaleX = -1;
		hudWrapper.addChild(hud);
		hud.x = Const.WID;
		hud.scaleX = hud.scaleY = 2;
		hud.scaleX*=-1;
		hud._maskWhite.visible = false;
		hud._green.transform.colorTransform = Color.getColorizeCT(Color.desaturateInt(Const.HEAL_TXT_COLOR,0.2), 1);
		hud._white.blendMode = BlendMode.ADD;
		hud._sableTop.transform.colorTransform = Color.getColorizeCT(Const.AP_TXT_COLOR, 1);
		hud._fall.transform.colorTransform = Color.getColorizeCT(Const.AP_TXT_COLOR, 1);
		hud._bottom.transform.colorTransform = Color.getColorizeCT(Const.AP_TXT_COLOR, 1);
		hud._fall.visible = false;
		setTime(0, false);
		
		// Compteur de vie
		var hit = new Sprite();
		hud.addChild(hit);
		hit.graphics.beginFill(0xff, 0);
		hit.graphics.drawCircle(hud._green.x, hud._green.y, 24);

		if (sick) {
			hit.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) tip.showAt(100,250, formatTip( Tx.TimeLifeTip({_n:teacher.data.selfControl, _max:teacher.data.maxSelfControl, _time:getNextSickSFTime()}) ) ));
		} else {
			hit.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) tip.showAt(60,250, formatTip( Tx.LifeTip({_n:teacher.data.selfControl, _max:teacher.data.maxSelfControl}) ) ));
		}



		hit.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) tip.hide() );

		setLife(teacher.data.selfControl, false);

		// Sablier
		var hit = new Sprite();
		hud.addChild(hit);
		hit.graphics.beginFill(0xff, 0);
		hit.graphics.drawRect(hud._sableTop.x-hud._sableTop.width*0.5-3, hud._sableTop.y-hud._sableTop.height-3, hud._sableTop.width+6, 50);
		hit.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) {
			tip.showAt(Const.WID-75,250, formatTip( Tx.TimeTip({_n:Math.max(0,teacher.data.pa)}) ));
		});
		hit.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) tip.hide() );
		
		// Over HUD
		var bmp = new Bitmap( new GfxHudOver(0,0) );
		dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = bmp.scaleY = 2;
		bmp.y = Const.HEI-bmp.height;
		bmp.visible = !photoMode;

		// Compteurs HUD
		lifeText = createField("0");
		dm.add(lifeText, Const.DP_INTERF);
		lifeText.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
		];
		lifeText.visible = !photoMode;
		
		timeText = createField("0");
		dm.add(timeText, Const.DP_INTERF);
		timeText.filters = [
			new flash.filters.GlowFilter(0x0,0.7, 2,2,10),
		];
		timeText.visible = !photoMode;
		
		// Cadre photo
		if( photoMode ) {
			var s = new Sprite();
			dm.add(s, Const.DP_INTERF);
			s.graphics.lineStyle(1, 0xFFCC00, 1);
			s.graphics.drawRect(1,1, Const.WID-3,Const.HEI-3);
			s.filters = [
				new flash.filters.GlowFilter(0x6C1800,1, 2,2,10),
			];
			s.mouseChildren = s.mouseEnabled = false;
		}
		
		// Barre d'actions aléatoire
		var b = new ActionBar("main");
		hudWrapper.addChild(b);
		randBar = b;
		b.bwid = 40;
		b.bhei = 40;
		b.x = 120;
		b.y = -95;
		b.showLabel = false;
		b.filters = [ Color.getContrastFilter(0.3) ];
		
		// Barre d'actions principale
		var b = new ActionBar("main");
		hudWrapper.addChild(b);
		mainBar = b;
		b.bwid = 40;
		b.bhei = 40;
		b.x = 124;
		b.y = -49;
		b.showLabel = false;
		b.filters = [
			//Color.getContrastFilter(-0.1),
			Color.getColorizeMatrixFilter(b.offColor, 0.2,0.8),
		];
		
		var acts = Lambda.array( Lambda.map(cinit._solverInit._teacherData._act, function(a) return { a:a, c:0 }) );
		updateActionBars(acts);

		syncData();
		
		attach();
		
		// Chargement musique
		music = switch( curPlace ) {
			case HQ : Sfx.downloadAndCreate("/music/music_hq.mp3");
			case Class : Sfx.downloadAndCreate("/music/music_class.mp3");
			case Home : Sfx.downloadAndCreate("/music/music_home.mp3");
		}
		music.setChannel(Const.MUSIC_CHANNEL);
		Sfx.setChannelVolume(Const.MUSIC_CHANNEL, Const.MUSIC_VOLUME);
		ringTone = SBANK.ringTone();
		
		
		function announcePlace() {
			switch( curPlace ) {
				case HQ : placeName(Tx.PlaceNameHq, 0xFFFFFF, 2);
				case Home : placeName(Tx.PlaceNameHome, 0xFFFFFF, 2);
				case Class :
					var c = 0x0;
					var txt = "???";
					switch(subject) {
						case S_History : c = 0x99BD09; txt = Tx.History;
						case S_Science : c = 0x5EEACA; txt = Tx.Science;
						case S_Math : c = 0xEFB358; txt = Tx.Math;
						//case S_NativeLang : c = 0xD1BECD; txt = Tx.NativeLang;
						//case S_ForeignLang : c = 0xF35A5A; txt = Tx.ForeignLang;
					}
					placeName(txt, c, 2);
					delayer.add(function() {
						placeName(Tx.PlaceNameClass, 0xB7C5D5, 1, 28);
					}, 1000);
			}
		}
		
		//if( !prod && !at(Class))
			//setGlobalTimer( Date.fromTime( DateTools.delta(Date.now(), 3600*2000).getTime()) );
		
		// Arrivée prof
		randBar.empty();
		lockActions = true;
		switch( curPlace ) {
			case Class :
				var newDay = cinit._solverInit._teacherData._am;

				var engine = SBANK.scooter();
				var radio = SBANK.music_arrival();
				radio.setChannel(Const.MUSIC_CHANNEL);
				
				var scooter = new lib.Scooter();
				function _startScooter() {
					engine.play(0.35, 1);
					engine.tweenPanning(-0.2, 3000);
					radio.tweenPanning(-0.2, 3000);
					sdm.add(scooter, Const.DP_INTERF);
					var start = Iso.isoToScreenStatic(Const.RWID+6, -3);
					var end = Iso.isoToScreenStatic(Const.RWID+5, Const.RHEI+4);
					scooter.x = start.x;
					scooter.y = start.y;
					tw.create(scooter, "x", end.x, TLinear, 3000);
					var a = tw.create(scooter, "y", end.y, TLinear, 3000);
					a.onUpdate = function() {
						fx.scooterSmoke(scooter.x, scooter.y-4);
					}
					a.onEnd = function() {
						cm.signal();
					};
				}
				function _turnHeads(dx) {
					for(s in students)
						s.lookAt(dx,0);
				}
				
				// Effet après midi
				if( !newDay ) {
					var r = 0.07;
					buffer.postFilters.push( Color.getColorizeMatrixFilter(0xFFC600, r, 1-r) );
				}
				
				
				teacher.setSuitcase(newDay);
				cm.create({
					if( newDay )
						radio.playOnChannel(Const.MUSIC_CHANNEL, 1, 1);
						
					for(s in students) {
						s.canSit = false;
						s.pull(0.6, 0.3);
						s.lookAt(0,0);
						s.setBarVisibility(false);
					}
					teacher.setPos(Const.EXIT.x-3, Const.EXIT.y+12);
					500;
					if( newDay ) {
						// Début de journée
						tweenScroll(Const.RWID*0.7, scroll.cy, 1500);
						1100;
						_startScooter();
						1000 >> _turnHeads(1);
						end;
						scooter.parent.removeChild(scooter);
						500;
						if( Std.random(100)<4 ) {
							// Crash
							SBANK.crash().play(0.4, -0.8);
							800>>shake(1, 1000);
							2000;
						}
						radio.tweenVolume(0, 2000);
						300;
						SBANK.doorOpen().play(0.2, -1);
						SBANK.doorCreek().play(0.1, -1);
						300;
					}
					500;
					_turnHeads(-1);
					300;
					announcePlace();
					tweenScroll(Const.EXIT.x, Const.EXIT.y-3, 2000);
					teacher.gotoXY(Const.EXIT.x-2, Const.EXIT.y, 1.2) > end;
					teacher.setDir(1);
					
					if( helper!=null )
						helper.arrival();
						
					if( newDay ) {
						teacher.setAnim(TA_Tie);
						1300;
						teacher.setAnim();
					}
					teacher.fl_visible = false;
					shake(1,300);
					openDoor();
					200;
					teacher.setPos(Const.EXIT.x, Const.EXIT.y);
					800 >> closeDoor();
					400 >> centerScroll(1000);
					teacher.fl_visible = true;
					teacher.gotoXY(Const.EXIT.x+2, Const.EXIT.y, 2)> end;
					_turnHeads(0);
					if( newDay ) {
						300;
						teacher.setDir(0);
						100;
						teacher.say(Tx.T_GoodMorning);
						600;
						
						for(s in students) {
							s.setAnim(SA_Talk);
							700>>s.setAnim();
						}
						100;
						shake(2, 300);
						fx.hello();
						1500;
					}
					teacher.goto(Const.DESK)>end;
					teacher.setDir(0);
					teacher.pull(0, -0.2, 400);
					300;
					if( newDay ) {
						teacher.setSuitcase(false);
						SBANK.drop01().play(0.2);
					}
					300;
					for(s in students) {
						s.canSit = true;
						s.pull(0, 0, Std.random(700));
						s.updatePose();
					}
					200;
					200>>teacher.setAnim(TA_Wait);
					1600>>teacher.setAnim();
					teacher.say( switch( subject ) {
						//case Subject.S_NativeLang : tg.m_start_native();
						//case Subject.S_ForeignLang : tg.m_start_foreign();
						case Subject.S_Math : tg.m_start_maths();
						case Subject.S_Science : tg.m_start_science();
						case Subject.S_History : tg.m_start_history();
					});
					2000;
					
					fx.bigText(Tx.Fight, 0xD70000);
					200 >> fx.flashBang(0.5, 1700);
					200 >> shake(0.6, 500);
					200 >> SBANK.explosion02().play();
					SBANK.jingle().playOnChannel(Const.MUSIC_CHANNEL);
					if( cinit._actions.length==0 )
						haxe.Timer.delay( function() music.playLoop(), 1700 ); // indépendant du fps
					else
						music.playLoop();
					
					teacher.back() > end;

					setTime(teacher.data.pa, true);
					gameStarted = true;
					for(s in students ) {
						s.setBarVisibility(s.fl_visible);
						s.updatePose();
					}
				});
					
			case HQ :
				setScroll(scroll.cx, scroll.cy-2);
				centerScroll(2500);
				setCine(true);
				teacher.fl_visible = false;
				if( cinit._solverInit._leftActions<=0 )
					setGlobalTimer(cinit._time._last, true);
				
				cm.create({
					1500;
					openDoor() > 200;
					announcePlace();
					teacher.goto({x:teacher.cx, y:teacher.cy+1}, 0.5) > end;
					closeDoor();
					music.playLoop();
					gameStarted = true;
				});
				
			case Home :
				var t = teacher;
				t.setTired(true);
				if( !photoMode ) {
					setScroll(0, 3);
					centerScroll(2500);
					if( cinit._solverInit._leftActions<=0 ) {
						t.setPyjama(true);
						setHomeLight(false);
						setGlobalTimer(cinit._time._last, true);
					}
				}

				if( sick ) {
					setHomeLight(true);
					t.setDir(2);
					t.setShadow(false);
					t.pull(0.62, -0.1);
					t.setAnim(TA_Sick);
					t.headY = -4;
					if( true ) { // TODO gérer "cinématique déjà vue"
						var m = new iso.Medic();
						m.setPos(1,4);
						m.pull(0.2, -0.4);
						lockActions = true;
						ambiantLoop = new Sfx( new SndSickLoop() );
						ambiantLoop.setChannel(Const.MUSIC_CHANNEL);
						cm.create({
							ambiantLoop.playLoop();
							m.setAnim("temp2");
							SBANK.studentAttack().play(0.3);
							3000;
							m.setAnim("temp");
							200 >> t.setThermometer(false);
							200 >> SBANK.handUp01().play(0.5);
							1500;
							m.ambiant(tg.m_medic1());
							4500;
							m.ambiant();
							300;
							m.ambiant(tg.m_medic2());
							4000;
							m.ambiant();
							300;
							t.say(tg.m_agony());
							2900;
							m.ambiant("...");
							1300;
							m.ambiant(tg.m_medicbye());
							1100;
							m.pull(0.4,-0.3, 500);
							m.setAnim("case");
							SBANK.drop02().play(0.3);
							1000;
							SBANK.footstep01().play();
							300 >> SBANK.footstep02().play();
							500 >> SBANK.footstep01().play();
							m.setAnim("walk");
							m.pull(-0.5,0, 1000);
							500;
							m.fl_visible = false;
							500;
							m.destroy();
							gameStarted = true;
							music.playLoop();
							SBANK.doorClose().play(0.5);
							lockActions = false;
						});
					}
					else
						cm.create({
							t.say(tg.m_agony());
							2000;
							music.playLoop();
							gameStarted = true;
						});
				}
				else {
					if( photoMode ) {
						//setScroll(0,0);
						//centerScroll(2500);
						centerScroll();
						t.fl_visible = false;
						buffer.postFilters = [ Color.getColorizeMatrixFilter(0x7A6C41, 0.3, 0.7) ];
						cm.create({
							1000;
							placeName(Tx.UserHome({_name:cinit._extra._userName}), 0xFFFFFF, 2);
						});
					}
					else {
						t.setDir(1);
						t.setPos(Const.EXIT);
						cm.create({
							1000 >> announcePlace();
							t.gotoXY(Const.EXIT.x+2, Const.EXIT.y) > end;
							gameStarted = true;
							music.playLoop();
						});
					}
				}
		}
		
		//#if debug
		//function addFakeHistory(a:TAction, t:Array<AcTarget>) {
			//cinit._a.push({ _r:cinit._a.length, _a:a, _t:Lambda.list(t) });
		//}
		//addFakeHistory( TAction.Swap, [ AT_Coord({x:5,y:4}), AT_Coord({x:2,y:2}) ] );
		//#end

		tuto.useAnims = false;

		// Lecture logs d'init
		if (logs != null && logs.length > 0)
			cm.chainToLast({
				playLog() ;
			});

		// Lecture des actions déjà jouées

		var lDebug = getFlashVar("protDebug") == "2" ;
		var logDebug = [] ;
		if( cinit._actions.length>0 ) {
			skip();
			for(a in cinit._actions) {
				logs = solver.doTurn(a, true);
				if (lDebug)
					logDebug.push(Lambda.list(logs)) ;
				playLog();
				skip();
			}

			if (lDebug)
				trace(logDebug) ;

			Sfx.enable();
			music.playLoop();
			delayedTip = null;
		}
		
		Sfx.enable();
		if( photoMode )
			applySoundState(0);
		else
			applySoundState( Std.parseInt(getFlashVar("sound")) );
		
		while( tuto.queueLength()>0 ) {
			tuto.flushQueue();
			tuto.hide();
		}
			
		ActionBar.updateAll();
		ready = true;
		updateHud();
		mt.Timer.resume();
	}
	
	inline function countSupers() {
		var total = 0;
		for( a in cinit._solverInit._teacherData._act )
			switch( Common.getTActionData(a).stance ) {
				case Super : total++;
				default :
			}

		return total;
	}
	
	inline function countInventory() {
		var total = 0;
		for(id in teacher.data.objects.keys()) {
			var n = teacher.data.objects.get(id).stock;
			if( n>0 )
				total+=n;
		}
		return total;
	}
	
	
	function skipChrono() {
		lockActions = true;
		var t = teacher;
		tw.create(globalTimer.wrapper, "y", -100, TEaseIn).onEnd = function() {
			globalTimer.wrapper.parent.removeChild(globalTimer.wrapper);
			globalTimer = null;
		}
		
		if( at(Home) && sick ) {
			// Réveil de James malade
			sick = false;
			buffer.postFilters = [];
			fx.flashBang(0.8, 1000);
			shake(2,500);
			t.setPyjama(true);

			if (sickInfos.auto) {  //### TODO
				cm.create({
					music.stop();
					ambiantLoop.stop();
					SBANK.jingle().playOnChannel(Const.MUSIC_CHANNEL, 0.5);
					t.setAnim();
					t.jump(5);
					t.pull(0,-1);
					t.pull(0,0, 400);
					400>>SBANK.explosion03().play();
					t.setTired(false);
					200 >> t.setShadow(true);
					700;
					t.say( tg.m_superjames() );
					4000;
					gotoUrl(cinit._extra._urlNext);
					999999;
				});

			} else {
				cm.create({
					music.stop();
					ambiantLoop.stop();
					SBANK.jingle().playOnChannel(Const.MUSIC_CHANNEL, 0.5);
					t.setAnim();
					t.jump(5);
					t.pull(0,-1);
					t.pull(0,0, 400);
					400>>SBANK.explosion03().play();
					t.setTired(false);
					200 >> t.setShadow(true);
					700;
					t.say( tg.m_superjames() );
					4000;
					500 >> fx.illuminate(t, 0x00FFFF);
					500 >> fx.flashBang(0.3, 3000);
					500 >> SBANK.explosion02().play();
					SBANK.powerUp04().play();
					t.setAnim(TA_SuperWakeUp);
					t.data.selfControl = t.data.maxSelfControl ;
					setLife(t.data.maxSelfControl) ;
					1300;
					fx.fadeOut(Const.SHADOW_COLOR, 2000);
					2000;
					gotoUrl(cinit._extra._urlNext);
					999999;
				});
			}
		}
		else if( at(Home) && !sick ) {
			// Va se coucher
			function _sleep() {
				t.setDir(2);
				t.setShadow(false);
				t.setAnim(TA_Bed);
			}
			cm.create({
				t.gotoXY(1,4);
				end;
				if( homeLight ) {
					SBANK.click().play(0.6);
					fx.word(t, Tx.LightSwitchNoise);
					t.jump(2);
					setHomeLight(false);
					400;
				}
				t.setDir(1);
				t.pull(0.65, -0.1, 250);
				250;
				t.setDir(2);
				250;
				_sleep();
				1000;
				fx.fadeOut(Const.SHADOW_COLOR, 2000);
				2000;
				gotoUrl( cinit._extra._urlNext );
				999999;
			});
		}
		else if( at(HQ) ) {
			cm.create({
				t.gotoXY(Const.EXIT.x, Const.EXIT.y+1) > end;
				t.setDir(0);
				100;
				t.setAnim(TA_Point);
				fx.airWave(t, t.getDir());
				fx.flashBang(0.3, 1000);
				music.stop();
				SBANK.jingle().playOnChannel(Const.MUSIC_CHANNEL, 0.5);
				300;
				t.say(tg.m_skipStaffRoom());
				1500;
				t.goto(Const.EXIT) > end;
				t.fl_visible = true;
				t.setDir(0);
				openDoor();
				t.fl_visible = false;
				t.say();
				700;
				closeDoor();
				fx.fadeOut(Const.SHADOW_COLOR, 2000);
				2000;
				gotoUrl( cinit._extra._urlNext );
				999999;
			});
		}
	}
	
	/*
	function hideSupers() {
		if( superCont==null )
			return;
			
		tw.terminate(superCont);
		tw.create(superCont, "y", Const.HEI, TEaseIn, 200).onEnd = function() {
			superCont.visible = false;
		}
	}
	function showSupers() {
		hideInventory();
		tw.terminate(superCont);
		
		var y = Const.HEI - 95;
		superCont.y = Const.HEI;
		superCont.visible = true;
		tw.create(superCont, "y", y, TEaseOut, 300).fl_pixel = true;
	}
	*/
	
	function hideDofBlur() {
		if( dofBlur==null )
			return;
		tw.terminate(dofBlur);
		var bmp = dofBlur;
		dofBlur = null;
		tw.create(bmp, "alpha", 0, TEaseIn, 200).onEnd = function() {
			bmp.bitmapData.dispose();
			bmp.parent.removeChild(bmp);
		}
	}
	
	function showDofBlur() {
		hideDofBlur();
		
		var bd = new BitmapData(Const.WID+16, Const.HEI+16, false, 0xBABEC9);
		var m = new flash.geom.Matrix();
		m.translate(8,8);
		bd.draw(buffer.render, m, Color.getColorizeCT(Const.SHADOW_COLOR, 0.3));
		bd.applyFilter( bd, bd.rect, new flash.geom.Point(0,0), new flash.filters.BlurFilter(8,8,2) );
		
		dofBlur = new Bitmap( bd );
		dm.add(dofBlur, Const.DP_DOF);
		dofBlur.x = dofBlur.y = -8;
		dofBlur.alpha = 0;
		tw.create(dofBlur, "alpha", 1, TEaseOut, 300);
	}
	
	//function updateInventory() {
		//if( invBar==null )
			//return;
		//
		//invBar.empty();
		//var n = 0;
		//for(id in teacher.data.objects.keys()) {
			//var count = teacher.data.objects.get(id).stock;
			//if( count<=0 )
				//continue;
			//var data = Common.getObjectData( Type.createEnumIndex(TObject, id), [] );
			//var icon = new lib.Icons();
			//try { icon.gotoAndStop( data.frame ); } catch(e:Dynamic) { icon.gotoAndStop(1); trace("WARNING: unknown item frame "+data.name+" (f="+data.frame+")"); }
			//invBar.addAction(id, data.name, count, icon);
			//n++;
		//}
		//invBar.attachActions();
	//}
	
	function updateHud() {
		if( !ready )
			return;
		lifeText.width = 60;
		lifeText.text = Std.string(teacher.data.selfControl);
		lifeText.width = lifeText.textWidth+4;
		lifeText.x = Std.int( 59 - lifeText.textWidth*0.5-2 );
		lifeText.y = Std.int( Const.HEI-60 );
		
		timeText.width = 60;
		timeText.text = Std.string(teacher.data.pa);
		timeText.width = timeText.textWidth+4;
		timeText.x = Std.int( 604 - timeText.textWidth*0.5-2 );
		timeText.y = Std.int( Const.HEI-60 );
	}
	
	
	function setFocus(?iso:Iso, ?allStudents=false) {
		var d = 350;
		var wasHidden = focus.wrapper.visible==false;
		
		if( iso==null && !allStudents )
			tw.create(focus.wrapper, "alpha", 0, TEaseIn, d).onEnd = function() {
				focus.wrapper.visible = false;
			}
		else {
			focus.wrapper.visible = true;
			tw.create(focus.wrapper, "alpha", 1, TEaseIn, d);
		}
			
		if( iso!=null ) {
			var pt = iso.getFeet();
			if( focus.hole.alpha==0 || wasHidden ) {
				focus.hole.x = pt.x;
				focus.hole.y = pt.y;
			}
			else {
				var dd = 500;
				tw.create(focus.hole, "x", pt.x, TEaseOut, dd);
				tw.create(focus.hole, "y", pt.y, TEaseOut, dd);
			}
			tw.create(focus.hole, "alpha", 1, TEaseOut, d);
		}
		else
			tw.create(focus.hole, "alpha", 0, TEaseIn, d);
		
		if( allStudents ) {
			focus.isoHole.visible = true;
			focus.isoHole.alpha = 0;
			tw.create(focus.isoHole, "alpha", 1, TEaseOut, d);
		}
		else
			tw.create(focus.isoHole, "alpha", 0, TEaseIn, d);
	}
	
	
	function isActionVisible(a:TAction) {
		return switch(a) {
			case TAction.What, TAction.Answer, TAction.UseObject, TAction.Grab, TAction.Buy:
				false;
			case TAction.MoreSlots :
				solver.teacher.canDo(a) && !boughtSlotsRecently;
			case TAction.StartLesson, TAction.WakeUp :
				false;
			default :
				true;
		}
	}
	
	
	function hidePicture() {
		if( curPicture!=null ) {
			root.stage.quality = Const.QUALITY;
			try curPicture.loader.close() catch(e:Dynamic) {}
			curPicture.wrapper.parent.removeChild(curPicture.wrapper);
			curPicture = null;
		}
	}
	
	function loadPicture(url:String, onLoad:flash.display.Loader->Void) {
		tip.hide();
		hidePicture();
		lockActions = true;
		
		var wrapper = new Sprite();
		dm.add(wrapper, Const.DP_INTERF);
		
		var tf = createField(Tx.Loading, true);
		wrapper.addChild(tf);
		tf.scaleX = tf.scaleY = 3;
		tf.x = Std.int(Const.WID*0.5-tf.width*0.5);
		tf.y = Std.int(Const.HEI*0.4-tf.height*0.5);
		
		var l = new flash.display.Loader();
		l.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, function(_) {
			wrapper.addChild(l);
			tf.parent.removeChild(tf);
			onLoad(l);
		});
		
		function _error(_) {
			SBANK.error01().play();
			hidePicture();
			tf.parent.removeChild(tf);
			lockActions = false;
			message("Couldn't load picture "+url);
		}
		l.contentLoaderInfo.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, _error);
		l.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, _error);
		l.load( new flash.net.URLRequest(url) );
		
		curPicture = {loader:l, wrapper:wrapper};
		return l;
	}
	
	
	function initAncestor(mc:flash.display.DisplayObject, id:Int, i:Iso, x,y,r) {
		var enable = cinit._solverInit._teacherData._grade>=id;
		
		var url = "/img/ancestors/"+ switch( id ) {
			case 1 : "01_norray_cboy_19012012";
			case 2 : "02_norroy_cptain_17409845";
			case 3 : "03_nauret_temp_148298165";
			case 4 : "04_norius_temp_5269191";
			case 5 : "05_noris_70006981";
			case 6 : "06_naruhatl_12000984";
			case 7 : "07_noruk_65M81651";
			case 8 : "08_norray_1997657844";
			default : throw "error";
		}
		
		mc.visible = enable;
		i.glowClick = i.glowOver = false;
		if( enable ) {
			i.setClick(x,y,r, Tx.ALL.get("Ancestor"+id), function() {
				if( !lockActions )
					loadPicture(url+".jpg", function(l:flash.display.Loader) {
						var mc = curPicture.wrapper;
						if( l.width>460 )
							l.scaleX = l.scaleY = 460/l.width;
						if( l.height>380 )
							l.scaleX = (l.scaleY *= 380/l.height);
						
						mc.filters = [ new flash.filters.GlowFilter(0x0, 0.4, 8,8, 1) ];
						mc.x = -mc.width;
						mc.y = Std.int( Const.HEI*0.5 - l.height*0.5);
						tw.create(mc, "x", 5, TEaseOut, 400);
						root.stage.quality = flash.display.StageQuality.HIGH;
						
						var cmc = new lib.Cadre();
						mc.addChild(cmc);
						cmc.mouseChildren = cmc.mouseEnabled = false;
						
						SBANK.windDouble().play(0.6);
						
						l.addEventListener( flash.events.MouseEvent.MOUSE_OVER, function(_) tip.showAt(Const.WID-150, 5, Tx.ALL.get("Ancestor"+id+"_Desc") ) );
						l.addEventListener( flash.events.MouseEvent.MOUSE_OUT, function(_) tip.hide() );
					});
			});
		}
		else
			i.setAmbiantDesc(x,y,r, Tx.UnknownAncestor, Tx.UnknownAncestorDesc);
	}
	
	
	function loadDrawing(url:String) {
		loadPicture(url, function(l:flash.display.Loader) {
			SBANK.windShort().play(0.6);
			
			root.stage.quality = flash.display.StageQuality.HIGH;
			
			if( l.width>460 )
				l.scaleX = l.scaleY = 460/l.width;
			if( l.height>360 )
				l.scaleX = (l.scaleY *= 360/l.height);
			var m = l.transform.matrix;
			m.translate(-l.width*0.5, -l.height*0.5);
			m.rotate( Lib.rnd(0.02, 0.1, true));
			m.translate(l.width*0.5, l.height*0.5);
			l.transform.matrix = m;
			
			l.filters = [ new flash.filters.GlowFilter(0x0, 0.4, 8,8, 1) ];
			l.x = Std.int( Const.WID*0.5 - l.width*0.5);
			l.y = -l.height;
			tw.create(l, "y", Std.int( Const.HEI*0.5 - l.height*0.5), TEaseOut, 600);
		});
	}
	
	
	function attach() {
		var dayRand = new mt.Rand(0);
		dayRand.initSeed(cinit._solverInit._teacherData._pr);

		var rseed = new mt.Rand(0);
		rseed.initSeed(cinit._solverInit._seed);
		
		roomBg = new Sprite();
		sdm.add(roomBg, Const.DP_BG);
		
		// Focus
		var b = 8;
		focus = { wrapper:new Sprite(), mask:new Sprite(), hole:new Sprite(), isoHole:new Sprite() }
		focus.wrapper.mouseChildren = focus.wrapper.mouseEnabled = false;
		sdm.add(focus.wrapper, Const.DP_FOCUS);
		focus.wrapper.addChild( focus.mask );
		focus.wrapper.addChild( focus.hole );
		focus.wrapper.addChild( focus.isoHole );
		focus.wrapper.blendMode = BlendMode.LAYER;
		focus.wrapper.visible = false;
		focus.mask.graphics.beginFill(Const.SHADOW_COLOR, 0.28);
		//focus.mask.graphics.beginFill(Const.SHADOW_COLOR, 0.35);
		focus.mask.graphics.drawRect(0,0,buffer.width, buffer.height);
		focus.hole.graphics.beginFill(0xff0000, 1);
		focus.hole.graphics.drawCircle(0,0, 65);
		focus.hole.blendMode = BlendMode.ERASE;
		focus.hole.scaleY = 0.5;
		focus.hole.filters = [ new flash.filters.BlurFilter(b,b) ];
		focus.isoHole.graphics.beginFill(0x00FF00, 1);
		var pt = Iso.isoToScreenStatic(1,Const.DESK.y);
		var x = pt.x;
		var y = pt.y;
		var w = 14*Const.RWID;
		var h = 14*8;
		focus.isoHole.graphics.moveTo(x,y);
		focus.isoHole.graphics.lineTo(x+h, y-h*0.5);
		focus.isoHole.graphics.lineTo(x+h+w, y-h*0.5+w*0.5);
		focus.isoHole.graphics.lineTo(x+w, y+w*0.5);
		focus.isoHole.filters = [ new flash.filters.BlurFilter(b,b) ];
		focus.isoHole.blendMode = BlendMode.ERASE;
		
		// Curseur Iso
		cursor = new Iso( tiles.getSprite("cursor") );
		cursor.sprite.visible = false;
		cursor.alpha = 0.6;
		//cursor.filterTarget.filters = [
			//new flash.filters.DropShadowFilter(3,90, 0x0,0.3, 0,0),
		//];
		
		
		// Assombrissement environs
		if( at(Class) ) {
			var s = new Sprite();
			var dy = 10;
			s.graphics.beginFill(Const.WHITE_MASK, 0.35);
			
			s.graphics.drawRect(-200,-100, buffer.width+600, buffer.height+500);
			var pt = Iso.isoToScreenStatic(0,0);
			s.graphics.moveTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(Const.RWID,0);
			s.graphics.lineTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(Const.RWID,Const.RHEI);
			s.graphics.lineTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(0,Const.RHEI);
			s.graphics.lineTo(pt.x, pt.y+dy);
			s.filters = [
				new flash.filters.BlurFilter(64,32),
			];
			var bmp = Lib.flatten(s);
			sdm.add(bmp, Const.DP_MASK);
		}
		
		
		// Obscurité
		if( at(Class) ) {
			var s = new Sprite();
			var dy = 10;
			s.graphics.beginFill(Const.SHADOW_COLOR, 0.65);
			
			//s.graphics.drawRect(-200,-100, buffer.width+600, buffer.height+500);
			var pt = Iso.isoToScreenStatic(0,0);
			s.graphics.moveTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(Const.RWID,0);
			s.graphics.lineTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(Const.RWID,Const.RHEI);
			s.graphics.lineTo(pt.x, pt.y+dy);
			var pt = Iso.isoToScreenStatic(0,Const.RHEI);
			s.graphics.lineTo(pt.x, pt.y+dy);
			s.filters = [
				new flash.filters.BlurFilter(64,32),
			];
			darkness = Lib.flatten(s);
			sdm.add(darkness, Const.DP_MASK);
			darkness.blendMode = BlendMode.HARDLIGHT;
		}
		

		centerScroll(0);
		switch(curPlace) {
			case Class :
				var skinSet = switch( subject ) {
					case S_Science : 1;
					case S_Math: 2;
					case S_History : 3;
				};
				
				setScroll(Const.RWID*0.5-0, Const.RHEI*0.5-3);

				// Sol couloir
				var i = new Iso(0,Const.RHEI-5);
				i.changeDepth(Const.DP_BG);
				var mc = new lib.SolCouloir();
				mc.gotoAndStop(skinSet);
				i.sprite.addChild( Lib.flatten(mc) );
				i.zpriority = -99;
				i.update();
				
				// Mur couloir gauche
				var i = new Iso(0,0);
				i.changeDepth(Const.DP_BG);
				var mc = new lib.MurCouloir();
				mc.gotoAndStop(skinSet) ;
				i.sprite.addChild( Lib.flatten(mc) );
				i.update();
				
				// Salle haut-droite
				var i = new Iso(Const.RWID-1,-1);
				i.changeDepth(Const.DP_BG);
				var mc = new lib.Secretariat();
				mc.gotoAndStop(skinSet);
				i.addFurnMc(mc);
				i.zpriority = -98;
				i.update();
				
				// Mur tableau
				var i = new Iso(0,Const.RHEI);
				var mc = new lib.Mur2();
				mc.gotoAndStop(skinSet);
				i.sprite.addChild(mc);
				i.enableHole();
				i.zpriority = 8;
				i.update();
				
				// Salle bas-gauche
				var i = new Iso(0,Const.RHEI);
				var mc = new lib.Ground2();
				mc.gotoAndStop(skinSet);
				i.sprite.addChild( Lib.flatten(mc) );
				i.zpriority = 8;
				i.update();
				
				// Sol classe
				var i = new Iso(0,0);
				i.changeDepth(Const.DP_BG);
				var bg = new Sprite();
				var mc = new lib.Ground();
				mc.gotoAndStop(skinSet);
				bg.addChild(mc);
				i.sprite.addChild(bg);
				i.update();
				
				// Estrade
				var i = new Iso(3, Const.RHEI-1);
				var h = 3;
				i.changeDepth(Const.DP_BG);
				var mc = new lib.Estrade();
				mc.gotoAndStop(skinSet);
				i.addFurnMc( mc, -14, -7 + h );
				i.collides = false;
				for(x in i.cx...i.cx+6)
					for(y in i.cy-2...i.cy+1)
						Iso.setHeightMap(x,y, h);
						
				// Bureau prof
				var i = new Iso(Const.DESK.x, Const.DESK.y-1);
				i.addFurnMc(new lib.BureauProf(), -12, -6);
				i.collides = true;

				// Corbeille
				var i = new Iso(Const.DESK.x+1, Const.DESK.y-1);
				i.addFurnMc(new lib.Corbeille(), 0,1);
				i.zpriority = -0.5;
				i.collides = false;
				teacher.setInCasePos(i.getPoint(), 0.8, 0.5);
		
				// Malette prof
				var i = new Iso(Const.DESK.x, Const.DESK.y-1);
				i.xr = 0.3;
				i.yr = 0.;
				i.zpriority = 0.5;
				i.addFurnMc( new lib.Case(), "case", -10,-11 );
				i.collides = false;
				i.fl_visible = false;

				// Dessins d'élèves
				var drawings = new iso.MiscFurn( new lib.Dessins(), 9,0, 2 );
				drawings.setClick(2,13,12, Tx.KidsDrawing, function() {
					if( !lockActions ) {
						SBANK.bip01().play(0.5);
						loadDrawing("http://" + domain + "/drawing") ;
						tip.hide();
					}
				});
				
				// Porte
				var i = new Iso(Const.EXIT.x, Const.EXIT.y);
				i.zpriority = -1;
				door = {iso:i, spr:new lib.Porte()}
				i.sprite.addChild(door.spr);
				door.spr.x = -16;
				door.spr.y = 17;
				closeDoor(false, true);
				i.update();

				// Trou de la porte
				var mc = new lib.Portemask();
				bg.addChild(mc);
				var pt = Iso.isoToScreenStatic(Const.EXIT.x, Const.EXIT.y);
				pt.x += -16;
				pt.y += 17;
				mc.x = pt.x - bg.parent.x;
				mc.y = pt.y - bg.parent.y;
				mc.blendMode = BlendMode.ERASE;
				bg.blendMode = BlendMode.LAYER;

				// Mur couloir
				for(y in 0...Const.RHEI+1) {
					var i = new Iso(0,y);
					var mc = new lib.MurSolo();
					mc.gotoAndStop( (skinSet-1)*10 + switch(y) {
						case 0 : 7; // Coin
						case Const.EXIT.y : 6; // Porte
						case Const.EXIT.y-1 : 3; // interrupteur
						case 3, 5 : 2; // fenêtre
						case 1, 7 : if( skinSet!=1 ) 4 else 1; // mur abimé
						default : 1; // mur normal
					} );
					//i.alpha = 0.5;
					mc.x = 2;
					mc.y = -3;
					i.zpriority = -1;
					i.addFurnMc( mc, "classWall" );
				}
				
				// Mur ruelle
				var i = new Iso();
				var mc = new lib.Wall();
				mc.gotoAndStop(skinSet);
				i.sprite.addChild( mc );
				i.setPos(Const.RWID+1, Const.RHEI+1);
				i.enableHole();
				
				// Lumières néons
				var wrapper = new Sprite();
				var pt = Iso.isoToScreenStatic(Const.RWID*0.5, Const.RHEI*0.5);
				for( d in [{x:0,y:-30}, {x:0,y:30}, {x:-60,y:0}, {x:60,y:0}] ) {
					var s = tiles.getSprite("light");
					s.x = pt.x + d.x;
					s.y = pt.y + d.y;
					s.scaleX = s.scaleY = 1.3;
					s.alpha = dayRand.range(0.2, 0.3);
					wrapper.addChild(s);
				}
				wrapper.filters = [ new flash.filters.BlurFilter(32,16) ];
				neons = Lib.flatten(wrapper,32);
				sdm.add(neons, Const.DP_BG_FX);
				neons.blendMode = BlendMode.OVERLAY;
				
				// Interrupteur
				lightSwitch = new Iso(0,8);
				lightSwitch.setClick(1,13,6, Tx.LightSwitch, function() {
					setNeon( !lightSources.get("neon") );
				});
				lightSwitch.headY = 20;
				lightSwitch.glowClick = lightSwitch.glowOver = false;
				
				// Rayons lumière fenêtres
				var n = 0;
				for(y in [3.7, 5.2, 7.2, 8.7]) {
					var open = rseed.random(2)==0;
					var k = "window_"+n;
					lightSources.set(k, open);
					var cy = Std.int(y);
					var yr = y-cy;
					var i = new Iso(Const.RWID-1, cy);
					i.zpriority = -10;
					var mc = new lib.Sun();
					if( open )
						mc.stop();
					else
						mc.gotoAndStop(mc.totalFrames);
					i.yr = yr;
					i.addFurnMc(mc, -4,2);
					i.collides = false;
					i.sprite.blendMode = BlendMode.OVERLAY;
					mc.alpha = 0.85;
					i.glowClick = i.glowOver = false;
					i.headY = 20;
					i.setClick(8,23, 8, Tx.Window, function() {
						if( mc.currentFrame==1 ) mc.play() else mc.gotoAndStop(1);
						lightSources.set(k, !lightSources.get(k));
						fx.word(i, Tx.CurtainNoise);
						SBANK.windDouble().play( Lib.rnd(0.1, 0.2) );
						updateLight();
					});
					n++;
				}
				
				// Ruelle
				var mc = new lib.Street();
				mc.gotoAndStop(skinSet);
				var i = new Iso();
				i.sprite.addChild( Lib.flatten(mc) );
				i.setPos(Const.RWID+1, 12);
				i.zpriority = 1;
				
				// Abri bus
				var i = new Iso();
				var mc = new lib.Abri();
				mc.gotoAndStop(skinSet);
				i.sprite.addChild(mc);
				i.setPos(Const.RWID+1, 12);
				mc.x+=300;
				mc.y-=150;
				i.zpriority = 1;
				
				
				switch( skinSet ) {
					case 1 : // Sciences
						new iso.Skully(0,8);
						
						if( hasWorldMod("xmas") ) {
							// Sapin noel
							var i = new Iso(0,6);
							var mc = new lib.Sapin();
							mc.gotoAndStop(1);
							i.addFurnMc( mc, "tree", 13 );
						}
						else
							new iso.MiscFurn( new lib.Potions(), 0,6);
							
						new iso.MiscFurn( new lib.Potions(), 1,0, true, 2);
						new iso.MiscFurn( new lib.Potions(), 2,0, true, 1);
						new iso.MiscFurn( new lib.Potions(), Const.RWID-1,0, true, 2);
						new iso.MiscFurn( new lib.Armoire(), 0,10);
						new iso.MiscFurn( new lib.Ordi(), 3,0, 10);
						var i = new iso.MiscFurn( new lib.TableEleve(), 7,9 );
						i.mc.gotoAndStop(4);
						i.mc.x-=10;
						i.mc.y-=5;
						drawings.setPos(3,0);

						// Projecteur
						var i = new iso.MiscFurn( new lib.Projo(), 3,Const.RHEI-2);
						i.mc.gotoAndStop("off");
						i.setClick(4,15, 11, Tx.Projector, function() {
							SBANK.click(0.6);
							if( i.mc.currentFrameLabel=="off" )
								i.mc.gotoAndPlay("on");
							else
								i.mc.gotoAndStop("off");
						});
						
					case 2 : // Maths
						drawings.setPos(5,0);
						new iso.MiscFurn( new lib.Armoire2(), 0,7);
						new iso.MiscFurn( new lib.Armoire2(), 9,0, true, -2);
						new iso.MiscFurn( new lib.TableM(), 0,4, true, 2);
						
						// Sapin noel
						if( hasWorldMod("xmas") ) {
							var i = new Iso(4,9);
							var mc = new lib.Sapin();
							mc.gotoAndStop(1);
							i.addFurnMc( mc, "tree");
						}
						else
							new iso.MiscFurn( new lib.Paper(), 4,9);
							
						var i = new iso.MiscFurn( new lib.Paper2(), Const.RWID-3,Const.RHEI-3);
						i.mc.x-=3;
						var i = new iso.MiscFurn( new lib.MathsCadre(), 0,10, true, -6);
						i.mc.x-=3;
						var i = new iso.MiscFurn( new lib.MathsCadre(), 0,9, true, -6);
						i.mc.x-=5;
						i.setAmbiantDesc(-14,19, 12, Tx.MathPortraits);
						i.mc.gotoAndStop(2);
						
						// Hamster
						var i = new iso.MiscFurn( new lib.Hamster(), 1,0);
						i.setClick(4,20, 9, Tx.Hamster, function() {
							if( !cd.hasSet("hamster", 50) ) {
								i.mc.play();
								SBANK.handUp03().play(0.3);
								SBANK.windLong().play(0.2);
							}
						});
						
						// Projecteur
						var i = new iso.MiscFurn( new lib.Projo(), Const.RWID-3,Const.RHEI-3);
						i.mc.gotoAndStop("off");
						i.setClick(4,15, 11, Tx.Projector, function() {
							SBANK.click(0.6);
							if( i.mc.currentFrameLabel=="off" )
								i.mc.gotoAndPlay("on");
							else
								i.mc.gotoAndStop("off");
						});

						// Placard (armoire)
						var i = new Iso(0, 6);
						var mc = new lib.Armoire();
						mc.gotoAndStop(rseed.random(2)+1);
						i.addFurnMc( mc, "armoire" );
						i.setClick(4,16,12, Tx.Closet, function() {
							if( mc.currentFrame==1 )
								SBANK.doorCreek().play(0.4);
							else {
								SBANK.doorClose().play(0.5);
							}
							if( mc.currentFrame==2 )
								i.jump(1);
							mc.gotoAndStop( mc.currentFrame==1 ? 2 : 1 );
						});
						i.fl_static = false;
						i.glowClick = i.glowOver = false;
						i.collides = true;
						
						// Chaises coin
						var x = 2;
						for(n in 0...dayRand.random(3)) {
							var i = new Iso(x, 0);
							i.xr = dayRand.range(0.5, 0.9);
							i.yr = dayRand.range(0.5, 0.8);
							i.addFurnMc( new lib.ChaiseEleve() );
							i.collides = false;
							x += dayRand.random(1)+1;
						}
						// Aquarium bubulle
						var i = new iso.MiscFurn(new lib.Aquarium(), 7,0);
						i.glowClick = i.glowOver = false;
						i.setClick(0,8,14, Tx.FishTank, function() {
							if( !cd.hasSet("fishTank", 30) )
								SBANK.fishTank().play();
						});
						teacher.setInCasePos({x:i.cx,y:i.cy}, 0.5, 0.7);
						
					case 3 : // Histoire-géo
						new iso.Skully2(0,3);
						var i = new iso.MiscFurn( new lib.Coffre(), 0,4);
						i.setAmbiantDesc(5,17,13, Tx.Safe);
						
						// Sapin noel
						if( hasWorldMod("xmas") ) {
							var i = new Iso(0,6);
							var mc = new lib.Sapin();
							mc.gotoAndStop(1);
							i.addFurnMc( mc, "tree", 13 );
						}
						
						new iso.MiscFurn( new lib.Armoire2(), 0,6);
						new iso.MiscFurn( new lib.BureauOrdi(), 1,11, true, -10);
						new iso.MiscFurn( new lib.Worldmap(), 4,0, -24);
						var i = new iso.MiscFurn( new lib.Coucou(), 3,0, -6);
						i.setAmbiantDesc(-5,11,8, Tx.Cuckoo);
						var i = new iso.MiscFurn( new lib.Armoire(), 11,0, true);
						i.mc.stop();
						drawings.setPos(9,0);

						// Globe terrestre
						var i = new Iso(10,10);
						var mc = new lib.TableGlobe();
						mc.stop();
						i.addFurnMc( mc, "earth", 0,-8);
						i.glowClick = i.glowOver = false;
						i.setClick(10,10,10, Tx.Earth, function() {
							if( !cd.hasSet("earth", 40) ) {
								SBANK.windLong().play(0.3);
								mc._sub.gotoAndPlay(1);
								fx.earthAirWave(i);
							}
						});
				}
				
				
				// Bus
				bus = new iso.Bus();
				
				// Bus
				bike = new iso.Bike();
				
				// PNJs
				new iso.Director();
				new iso.Pedestrian();
					
				
			case HQ :
				//bscroller.filters = [ new flash.filters.GlowFilter(0x0,0.3, 4,4, 10) ];
				setPlasma(0x2E284F, 0x3E4695);
				
				// Roche
				var i = new Iso(0,0);
				var mc = new lib.Earth();
				i.zpriority = -100;
				i.sprite.addChild(mc);
				i.changeDepth(Const.DP_BG);

				// Bg de la salle des profs
				var i = new Iso(0,0);
				var bg = new lib.Salleprof();
				i.zpriority = -99;
				i.sprite.addChild(bg);
				i.changeDepth(Const.DP_BG);
				i.update();
				
				// Mur devant
				var i = new Iso(0,0);
				var mc = new lib.Murprof();
				i.sprite.addChild(mc);
				i.zpriority = 999;
				i.enableHole();
				
				var i = new Iso(2,0);
				i.addFurnMc( new lib.BureauOrdi() );
				
				var i = new Iso(2,1);
				i.addFurnMc( new lib.Chaiseluxe(), "deskChair" );
				i.setStandPoint(1,0);
				
				var i = new Iso(1,1);
				i.xr = 0.3;
				i.yr = 0.;
				i.addFurnMc( new lib.Corbeille(), "trash" );
				i.collides = false;
								
				// Eddy ou Peggy
				if( rseed.random(100)<50 && !helperAvailable(Helper.Eddy) )
					new iso.Eddy();
				else if( rseed.random(100)<50 && !helperAvailable(Helper.Peggy) )
					new iso.Peggy();

				var i = new Iso(6,3);
				i.addFurnMc( new lib.TableEleve(), true, 12,-6 );
				
				var i = new Iso(6,3);
				i.addFurnMc( new lib.Paper(), 6,-4 );
				i.setAmbiantDesc( 3,12, 8, Tx.Papers, Tx.PapersDesc1({_name:cinit._extra._userName}) );
				
				var i = new Iso(1,0);
				i.addFurnMc( new lib.Dossiers() );
				i.xr = 0.3;
				
				var i = new Iso(0,10);
				var mc = new lib.Dossiers();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				i.setAmbiantDesc(3,18, 8, Tx.File, Tx.FileDesc4);
				
				var i = new Iso(0,8);
				var mc = new lib.Casier();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				i.yr = 0.7;
				i.setAmbiantDesc(3,18, 7, Tx.FileYellow, Tx.FileYellowDesc);
				
				if( hasWorldMod("xmas") ) {
					// Sapin noel
					var i = new Iso(0,6);
					var mc = new lib.Sapin();
					mc.gotoAndStop(2);
					i.addFurnMc( mc, "tree", 13 );
				}
				else {
					var i = new Iso(0,6);
					var mc = new lib.Dossiers();
					mc.scaleX = -1;
					i.addFurnMc(mc);
					i.xr = 0.6;
					i.yr = 0;
					i.setAmbiantDesc(3,18, 8, Tx.File, Tx.FileDesc3);
				}
				
				var i = new Iso(0,1);
				i.addFurnMc( new lib.Paper(), true, 0,5 );
				i.setAmbiantDesc(3,18, 8, Tx.Papers, Tx.PapersDesc2);
				
				var i = new Iso(0,2);
				var mc = new lib.Dossiers();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				i.setAmbiantDesc(3,18, 8, Tx.File, Tx.FileDesc1);
				
				var i = new Iso(0,3);
				var mc = new lib.Dossiers();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				i.yr = 0.2;
				i.setAmbiantDesc(3,18, 8, Tx.File, Tx.FileDesc2);
				
				// Tableau en liège
				var i = new Iso(0,4);
				var mc = new lib.Liege();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				i.setStandPoint(1,0);
				i.glowClick = false;
				i.setClick(-4,12, 11, Tx.RankingLink, function() shortcut( i, cinit._extra._urlRanking) );
				
				// Einstein
				new iso.Einstein();
				
				// Chaise Eddy
				var i = new Iso(3,4);
				i.addFurnMc(new lib.ChaiseEleve(),1,-8);
				
				// Table centrale
				var i = new Iso(3,8);
				var mc = new lib.TableReu();
				i.zpriority = -1;
				mc.x = 0;
				mc.y = -10;
				i.addFurnMc( mc, "bigTable" );
				
				// Chaises
				var i = new Iso(5,8);
				var mc = new lib.ChaiseB1();
				mc.stop();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				
				var i = new Iso(5,6);
				var mc = new lib.ChaiseB1();
				mc.stop();
				mc.scaleX = -1;
				i.addFurnMc(mc);
				
				var i = new Iso(4,9);
				var mc = new lib.ChaiseB1();
				mc.stop();
				i.addFurnMc(mc);
				
				var i = new Iso(2,6);
				var mc = new lib.ChaiseEleve();
				mc.scaleX = -1;
				mc.x += 6;
				mc.y -= 6;
				i.collides = false;
				i.addFurnMc(mc);
				
				
				// Machine à café
				var i = new Iso(6,0);
				i.addFurnMc( new lib.Cafe() );
				i.setStandPoint(0,1);
				teacher.setInCasePos(i.getStandPoint(), 0.5, 0.8);
				i.glowClick = false;
				i.setClick(-5,16,10, Tx.DrinkCoffee, function() {
					gotoAndDo(i, function() {
						var t = teacher;
						if( t.cd.has("coffee") ) {
							t.say( tg.m_noMoreCoffee() );
							SBANK.error01().play();
							return;
						}
						lockActions = true;
						tip.hide();
						t.cd.set("coffee", 99999);
						var trash = furns.get("trash");
						function _launch() {
							var p = fx.projLaunch(t, trash, 0xE2E2E2, 3,2, 0.7, 5, 0);
							p.speed = 2.5;
							p.onEnd = function() {
								cm.signal("projEnd");
							}
						}
						var fall = SBANK.fall01();
						cm.create({
							t.setDir(0);
							t.setAnim(TA_Coffee1);
							150 >> SBANK.click().play();
							1200 >> SBANK.windShort().play(0.3);
							1400;
							t.setDir(1);
							t.setAnim(TA_Coffee2);
							3300 >> fx.word(t, Tx.T_Swallow);
							3300 >> SBANK.swallow().play();
							4400 >> t.say(tg.m_cafejames());
							4400;
							t.setAnim(TA_Throw);
							SBANK.windLong().play(0.2);
							500>>fall.play(0.2);
							150;
							_launch();
							250;
							t.setAnim();
							t.setDir(1);
							end("projEnd");
							fall.stop();
							SBANK.drop01().play();
							fx.papers( trash, 3);
							trash.pull(-0.02, 0.02);
							50;
							trash.pull(0, 0);
							500;
							lockActions = false;
						});
					});
				});
				
				// Distributeur
				var i = new Iso(5,0);
				i.addFurnMc( new lib.Distrib() );
				i.setStandPoint(0,1);
				teacher.setInCasePos(i.getStandPoint(), 0.5, 0.8);
				i.setAmbiantDesc(-5,16, 10, Tx.VendingMachine, Tx.VendingMachineDesc);
				
				
				for( a in teacher.data.actions ) {
					var a = a.data.id;
					switch(a) {
						/*case TAction.Coffee :
							var i = new Iso(5,0);
							i.addFurnMc( new lib.Cafe() );
							i.setStandPoint(0,1);
							i.setClickAction( -4,17,14,27, a);
							teacher.setInCasePos(i.getStandPoint(), 0.5, 0.8);*/
							
						case TAction.Coffee : // Se reposer (canapé)
							var i = new Iso(0,7);
							var mc = new lib.Canape2();
							mc.scaleX = -1;
							mc.x+=20;
							mc.y-=10;
							i.addFurnMc(mc, "sofa");
							i.setStandPoint(1,0);
							i.setClickAction(5,20, 16, a);
							teacher.setInCasePos({x:i.cx+1, y:i.cy-1}, 0.7, 0.5);
							teacher.setInCasePos({x:i.cx+1, y:i.cy}, 0.8, 0.5);
							teacher.setInCasePos({x:i.cx+1, y:i.cy+1}, 0.7, 0.5);
							
						case TAction.SRBonusReward :
							var i = new Iso(3,5);
							i.addFurnMc( new lib.Paper(), "paperCorrect", -4, -2 );
							i.zpriority = 2;
							i.setClickAction(-8,12, 10, a);
							teacher.setInCasePos({x:i.cx, y:i.cy+1}, 0.5, 0.8);
							
						case TAction.SRMoreXp :
							var i = new Iso(2,0);
							i.addFurnMc( new lib.Ordi(), "computer" );
							i.setStandPoint(1,1);
							i.setClickAction(-8,12, 10, a);
							teacher.setInCasePos({x:i.cx, y:i.cy+1}, 0.5, 0.8);
							
						case TAction.StartLesson :
							// Porte
							var i = new Iso(Const.EXIT.x, Const.EXIT.y);
							//i.setClickAction( 8,4, 16,24, a);
							door = {iso:i, spr:new lib.Porte()}
							i.sprite.addChild(door.spr);
							door.spr.scaleX = -1;
							door.spr.x = 16;
							door.spr.y = 17;
							closeDoor();
							furns.set("door", i);
							i.update();
							
							// Trou de la porte
							var mc = new lib.Portemask();
							bg.addChild(mc);
							var pt = Iso.isoToScreenStatic(Const.EXIT.x, Const.EXIT.y);
							pt.x += 16;
							pt.y += 17;
							mc.x = pt.x - bg.parent.x;
							mc.y = pt.y - bg.parent.y;
							mc.scaleX = -1;
							mc.blendMode = BlendMode.ERASE;
							bg.blendMode = BlendMode.LAYER;
							
						case TAction.UseObject, TAction.Buy :
							
						default :
							warning("TODO "+a);
					}
				}
				
				setScroll(scroll.cx+1, scroll.cy);
				
				
			case Home :
				//homeCustomizer = new HomeCustomizer(prod ? cinit._home._l : 999);
				homeCustomizer = new HomeCustomizer(cinit._home._l);
				homeCustomizer.setVisibility( !photoMode );
				
				if( sick )
					setPlasma(0x283216, 0x445B39);
				else
					setPlasma(0x793555, 0x201C37);
					
				// Bg
				var i = new Iso(0,0);
				var bg = new lib.Appart();
				i.zpriority = -99;
				i.sprite.addChild(bg);
				i.changeDepth(Const.DP_BG);
				i.update();
				homeCustomizer.associateData(bg._wallpaper, "roomWall");
				homeCustomizer.associateData(bg._ground1, "roomGround");
				homeCustomizer.associateData(bg._ground2, "bathGround");
				homeCustomizer.addReplication(bg._base, "base");
				
				// Mur devant
				var i = new Iso(0,0);
				i.zpriority = 99;
				var mc = new lib.MurAppart();
				i.sprite.addChild( mc );
				homeCustomizer.associateData(mc._wallbath, "bathWall");
				homeCustomizer.associateData(mc._baignoire, "bath");
				homeCustomizer.associateData(mc._lavabo, "sink");
				homeCustomizer.associateData(mc._wc, "wc");
				homeCustomizer.associateData(mc._wall, "base");
				
				// Mur salle de bains
				var i = new Iso(0,0);
				i.zpriority = 999;
				var mc = new lib.MurBain();
				i.sprite.addChild( mc );
				teacher.setInCasePos({x:4, y:Const.RHEI-2}, 0.3, 0.7); // lavabo
				homeCustomizer.addReplication(mc._wall, "base");

				if( hasWorldMod("xmas") ) {
					// Sapin noel
					var i = new Iso(4,3);
					var mc = new lib.Sapin();
					mc.gotoAndStop(1);
					i.addFurnMc( mc, "tree");
					i.collides = true;
				}
				
				// Baignoire
				var i = new Iso(3,9);
				i.setAmbiantDesc(1,5,12, Tx.Bath, Tx.BathDesc);
				
				// Lavabo
				var i = new Iso(4,6);
				i.setAmbiantDesc(-11,10,9, Tx.Lavabo, Tx.LavaboDesc);
				
				// Table de chevet
				var i = new Iso(0,1);
				i.addFurnMc( new lib.Chevet() );
				teacher.setInCasePos({x:i.cx+1, y:i.cy}, 0.7,0.5);
				i.setAmbiantDesc(3,23,7, Tx.NightTable, Tx.NightTableDesc);
		
				
				// Cadres des ancêtres
				initAncestor(bg._val1, 1, new Iso(0,5), 2,9, 6);
				initAncestor(bg._val2, 2, new Iso(0,2), -7,13, 5);
				initAncestor(bg._val3, 3, new Iso(0,2), 3,8, 5);
				initAncestor(bg._val4, 4, new Iso(0,1), 1,10, 5);
				initAncestor(bg._val5, 5, new Iso(0,1), 10,6, 5);
				initAncestor(bg._val6, 6, new Iso(0,1), 19,8, 5);
				initAncestor(bg._val7, 7, new Iso(2,0), -2,12, 5);
				initAncestor(bg._val8, 8, new Iso(2,0), 7,13, 5);
				
				
				// Table basse
				var i = new Iso(6,2);
				var mc = new lib.TableBasse();
				i.addFurnMc(mc);
				i.setAmbiantDesc(-1,20,9, Tx.TableHome, Tx.TableHomeDesc);
				homeCustomizer.associateData(mc, "smallTable");

				// Bureau
				var i = new Iso(5,4);
				i.addFurnMc( new lib.ChaiseEleve(), true, 6, -3 );
				i.collides = false;
				teacher.setInCasePos(i.getPoint(), 0.3, 0.7);
				var mc = new lib.BureauProf();
				var i = new Iso(6,4);
				i.addFurnMc( mc, "desk", true, 10,-5 );
				homeCustomizer.associateData(mc, "desk");
				var i = new Iso(6,4);
				i.addFurnMc( new lib.Paper2(), 9,-8 );
				var i = new Iso(6,5);
				i.addFurnMc( new lib.Paper(), true, -2,3 );
				var i = new Iso(7,4);
				i.addFurnMc( new lib.Paper(), 6,4 );
				i.collides = false;
				teacher.setInCasePos(i.getPoint(), 0.3, 0.5);
					
				// Halo de l'ordi
				var pt = Iso.isoToScreenStatic(4,1);
				var pt = buffer.localToGlobal(pt.x, pt.y);
				var s = new Sprite();
				s.graphics.beginFill(0x80FFFF, 1);
				s.graphics.drawCircle(0,0, 32);
				s.filters = [ new flash.filters.BlurFilter(32, 32) ];
				s.x = pt.x + 10;
				s.y = pt.y + 6;
				computerGlow = Lib.flatten(s,32, true);
				computerGlow.blendMode = BlendMode.OVERLAY;
				gscroller.addChild(computerGlow);
				setHomeLight(true);

				// Papiers
				var i = new Iso(1,0);
				var mc = new lib.Paper2();
				mc.scaleX = -1;
				i.addFurnMc(mc, "paper");
				i.yr = 0.9;
				teacher.setInCasePos({x:i.cx, y:i.cy+1}, 0.5, 0.6);
				mc.filters = [ new flash.filters.DropShadowFilter(2,-40, 0x0,0.25, 0,0) ];
				
				// Bureau
				var i = new Iso(4,0);
				i.addFurnMc( new lib.BureauOrdi() );
				teacher.setInCasePos({x:i.cx, y:i.cy+1}, 0.5, 0.8);
				
				// Ordi
				var i = new Iso(4,0);
				i.addFurnMc( new lib.OrdiJames(), "computer" );
				i.setStandPoint(-1,1);
								
				// Chaise bureau
				var i = new Iso(4,1);
				i.addFurnMc( new lib.Chaiseluxe(), "deskChair" );
				i.setStandPoint(1,0);
								
				// WC
				var i = new Iso(9,3);
				i.zpriority = 99;
				i.setAmbiantDesc(0,15, 21, Tx.WC, Tx.WCDesc);
				
				// Canapé
				var i = new Iso(5,0);
				var mc = new lib.Canape();
				i.addFurnMc(mc, "sofa");
				mc.x-=10;
				mc.y-=5;
				i.setStandPoint(1,1);
				teacher.setInCasePos({x:i.cx, y:i.cy+1}, 0.5,0.9);
				teacher.setInCasePos({x:i.cx+1, y:i.cy+1}, 0.5,0.9);
				teacher.setInCasePos({x:i.cx+2, y:i.cy+1}, 0.5,0.7);
				homeCustomizer.associateData(mc, "sofa");
				
				// Lit
				var i = new Iso(0,3);
				var mc = new lib.Lit();
				i.addFurnMc( mc, "bed" );
				i.setStandPoint(1,1);
				i.setAmbiantDesc(19,21,13, Tx.Bed, Tx.BedDesc);
				homeCustomizer.associateData(mc, "bed");
				
				// Interrupteur
				var i = new Iso(1,4);
				i.glowClick = i.glowOver = false;
				i.setClick(-3,1,6, Tx.LightSwitch, function() {
					gotoAndDo(i, function() {
						SBANK.click().play(0.6);
						fx.word(i, Tx.LightSwitchNoise);
						setHomeLight(!homeLight);
					});
				});
				//i.setAmbiantDesc(-3,1,6, Tx.LightSwitch, Tx.BedDesc);
				
				for( a in teacher.data.actions ) {
					var a = a.data.id;
					switch(a) {
						case TAction.WakeUp : // Journée suivante
							//var i = furns.get("bed");
							//i.setClickAction( 25,25,40,20, a );
							
						case TAction.Rest : // Repos
							var i = furns.get("sofa");
							i.setClickAction(7,25, 17, a);

						case TAction.HMoreXp : // Partager son expérience
							var i = furns.get("computer");
							i.setClickAction(-8,12, 12, a);
							
						case TAction.HBonusReward : // Corriger des exercices
							var i = furns.get("desk");
							i.setClickAction(-5,17, 12, a);
							
						case TAction.UseObject, TAction.Buy :
							
						default :
							debug("Action not linked to any furniture: "+a);
					}
				}
		}
		
		initPathFinders();
		updateEntities(true);
		
		if( homeCustomizer!=null ) {
			homeCustomizer.attachButtons();
			homeCustomizer.applyClientInit(cinit);
		}
		
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		root.stage.addEventListener(flash.events.MouseEvent.CLICK, onClick);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		root.stage.addEventListener("rightClick", onRightClick);
		//root.stage.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, onMouseWheel);

		if( at(Class) ) {
			setNeon(true);
			updateLight();
		}
		tw.terminateAll();
	}
	
	
	function formatTip(s:String) {
		if( s.indexOf("|")<0 )
			return s;
		var title = '<font color="#87B5E7">' + StringTools.trim( s.split("|")[0] ) + '</font>';
		var desc = '<font color="#C1C8D2">' + StringTools.trim( s.split("|")[1] ) + '</font>';
		return title+"\n"+desc;
	}
	
	function openDoor() {
		SBANK.doorOpen().play();
		door.spr.gotoAndStop("open");
		door.iso.allowClick = false;
		if( at(Class) )
			door.iso.zpriority = 0;
	}
	
	function closeDoor(?violent=false, ?sound=true) {
		if( sound )
			if( violent )
				SBANK.doorSlam().play();
			else
				SBANK.doorClose().play(0.5);
		door.spr.gotoAndStop("closed");
		door.iso.zpriority = -1;
		door.iso.allowClick = true;
		if( violent ) {
			if( furns.exists("earth") )
				furns.get("earth").furnMc.play();
			shake(0.5,900);
			fx.dustCeil(door.iso.sprite.x-5, door.iso.sprite.y+20, 15);
		}
		else
			shake(0.3, 300);
	}
	
	
	function setHomeLight(b:Bool) {
		homeLight = b;
		computerGlow.alpha = b ? 0.5 : 1;
		if( b )
			buffer.postFilters = [];
		else {
			buffer.postFilters.push( Color.getContrastFilter(-0.2) );
			buffer.postFilters.push( Color.getColorizeMatrixFilter(0x271C48, 0.4, 0.6) );
		}
	}
	
	function setNeon(b:Bool) {
		SBANK.click().play(0.6);
		fx.word(lightSwitch, Tx.LightSwitchNoise);
		lightSources.set("neon", b);
		neons.visible = lightSources.get("neon");
		updateLight();
	}
	
	function updateLight() {
		var lum = 0.9;
		for(k in lightSources.keys())
			if( k.indexOf("window")==0 && !lightSources.get(k) )
				lum-=0.2;
		if( lightSources.get("neon") )
			lum+=0.8;
		darkness.alpha = 1 - Math.min(1,Math.max(0,lum));
	}
	
	function onDataChange(s:Student) {
		if( overedStudent==s )
			showStudentTip(s);
	}

	function hideStudentTip() {
		if( studentTip==null )
			return;
			
		studentTipAnim.parent.removeChild(studentTipAnim);
		studentTipAnim = null;
		
		var bmp = studentTipMask;
		tw.create(bmp, "alpha", 0, TEaseOut, 200).onEnd = function() {
			bmp.bitmapData.dispose();
			bmp.parent.removeChild(bmp);
		};
		studentTipMask = null;
		
		//tw.terminate(studentName);
		//studentName.parent.removeChild(studentName);
		
		var spr = studentTip;
		tw.create(spr, "alpha", 0, TEaseOut, 200).onEnd = function() {
			spr.parent.removeChild(spr);
		};
		studentTip = null;
	}
	
	inline function interfaceLocked() {
		return
			!gameStarted ||
			curMessage!=null ||
			curPicture!=null ||
			curQuery!=null ||
			tuto.isVisible();
			//invCont!=null && invCont.visible ||
			//superCont!=null && superCont.visible;
	}
	
	function note(s:Student, reason:String) {
		if( cm.turbo )
			return;
		hideMessage();
		
		curMessage = new Sprite();
		curMessage.useHandCursor = curMessage.buttonMode = true;
		dm.add(curMessage, Const.DP_INTERF);

		var mask = new Sprite();
		curMessage.addChild(mask);
		mask.graphics.beginFill(Const.SHADOW_COLOR, 0.5);
		mask.graphics.drawRect(0,0,Const.WID,Const.HEI);
		mask.alpha = 0;
		tw.create(mask, "alpha", 1, TBurnIn, 500);
		
		var wrapper = new Sprite();
		curMessage.addChild(wrapper);
		var p = 20;
		
		var bg = new lib.Retard();
		wrapper.addChild(bg);
		bg.scaleX = bg.scaleY = 2;
		
		var tf = createField("", FBig);
		wrapper.addChild(tf);
		var str = Tx.LateNote({_name:s.data.firstname, _reason:reason});
		tf.textColor = 0x515868;
		str = StringTools.replace(str, "|", "\n\n");
		str = StringTools.replace(str, "[", "<font color='#6F1313'>");
		str = StringTools.replace(str, "]", "</font>");
		tf.htmlText = str;
		tf.x = 10;
		tf.y = 6;
		tf.width = 150;
		tf.height = 300;
		tf.multiline = tf.wordWrap = true;
		
		wrapper.x = Std.int(Const.WID*0.5 - wrapper.width*0.5);
		wrapper.y = Std.int(Const.HEI*0.5 - wrapper.height*0.5);
	}
	
	
	function hidePointer() {
		if( curPointer!=null ) {
			tw.terminate(curPointer);
			curPointer.parent.removeChild(curPointer);
			curPointer = null;
		}
	}
	
	function pointAt(x:Float, y:Float, str:String) {
		if( cm.turbo )
			return;
			
		hidePointer();
		
		var col = 0x572033;
		x = Math.max(20, Math.min(Const.WID-20, x));
		
		var wrapper = new Sprite();
		curPointer = wrapper;
		dm.add(wrapper, Const.DP_INTERF);
		wrapper.filters = [ new flash.filters.GlowFilter(0x0,0.5, 8,8, 1) ];
		
		var g = wrapper.graphics;
		
		var stf = new SuperText();
		wrapper.addChild(stf.wrapper);
		stf.x = 10;
		stf.y = 8;
		stf.setSize(200,500);
		stf.setFont(0xFFFFFF, "big", 16);
		stf.setBoldTag("<font color='0xFFC600'>","</font>");
		stf.setText(str);
		stf.autoResize();

		// Bg
		g.beginFill(col, 1);
		var w = stf.width+20;
		var h = stf.height+16;
		g.drawRect(0,0, w, h);
		g.endFill();
		
		wrapper.x = Std.int( Math.min( Const.WID-w-10, Math.max(10, x-w*0.5) ) );
		wrapper.y = Std.int( y - h - 10 );
		
		wrapper.y-=20;
		tw.create(wrapper, "y", wrapper.y+20, TEaseOut, 500).fl_pixel = true;
		
		// Flèche
		var ax = x - wrapper.x;
		g.beginFill(col, 1);
		g.moveTo(ax-6, h-2);
		g.lineTo(ax, h+8);
		g.lineTo(ax+6, h-2);
		g.endFill();
		g.lineStyle(1, 0xFFFFFF, 0.8);
		//g.moveTo(2, h-3);
		g.moveTo(ax-4, h-3);
		g.lineTo(ax, h+5);
		g.lineTo(ax+4, h-3);
		//g.lineTo(w-2, h-3);
		
		wrapper.useHandCursor = wrapper.buttonMode = true;
		wrapper.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
			cancelClick = true;
			hidePointer();
		});
	}
	
	
	function gameTip(key:String, x,y, msg:String) {
		if( delayedTip==null && !cd.hasSet(key, 999999) ) {
			delayedTip = function() {
				pointAt(x,y, msg);
			}
		}
	}
	
	
	function hideMessage() {
		if( curMessage!=null ) {
			lastDetails = null;
			//hideDofBlur();
			var s = curMessage;
			curMessage = null;
			tw.create(s, "alpha", 0, TEaseOut, 200).onEnd = function() {
				s.parent.removeChild(s);
			}

			if (curMessageRedirect != null) {
				gotoUrl(curMessageRedirect) ;
				curMessageRedirect = null ;
			}
		}
	}
	
	function message(?html:String, ?corner=false, ?redirect : String) {
		if( cm.turbo )
			return;
			
		hideMessage();
		
		if( html==null )
			return;

		curMessageRedirect = redirect ; //url redirect on hide message

		//showDofBlur();
			
		curMessage = new Sprite();
		curMessage.useHandCursor = curMessage.buttonMode = true;
		dm.add(curMessage, Const.DP_INTERF);
		
		var mask = new Sprite();
		curMessage.addChild(mask);
		mask.graphics.beginFill(Const.SHADOW_COLOR, 0.5);
		mask.graphics.drawRect(0,0,Const.WID,Const.HEI);
		mask.alpha = 0;
		tw.create(mask, "alpha", 1, TBurnIn, 500);
			
		var wrapper = new Sprite();
		curMessage.addChild(wrapper);
		var p = 15;
		
		var stf = new SuperText();
		stf.setFont(0xAFBAC7, "big", 16);
		stf.setBoldTag("<font color='0xFFFFFF'>", "</font>");
		stf.setSize(300, 400);
		stf.wrapper.x = p;
		stf.wrapper.y = p;
		stf.setText( html );
		stf.autoResize();
		
		var tf = createField(html, FBig);
		tf.textColor = 0xffffff;
		tf.htmlText = html;
		tf.wordWrap = tf.multiline = true;
		tf.x = p;
		tf.y = p;
		tf.width = 300;
		tf.height = 400;
		tf.width = tf.textWidth + 5;
		tf.height = tf.textHeight + 5;

		var bg = new Sprite();
		bg.graphics.beginFill(0x0, 0.8);
		bg.graphics.drawRect(0,0, tf.width+p*2, tf.height+p*2);
		
		wrapper.addChild(bg);
		wrapper.addChild(stf.wrapper);
		//wrapper.addChild(tf);
		
		if( corner ) {
			wrapper.x = -wrapper.width;
			wrapper.y = 10;
			tw.create(wrapper, "x", 0, TBurnIn, 250);
		}
		else {
			wrapper.x = Std.int(Const.WID*0.5 - wrapper.width*0.5);
			wrapper.y = Std.int(Const.HEI*0.4 - wrapper.height*0.5);
			//wrapper.y+=10;
			//tw.create(wrapper, "y", wrapper.y-10, TBurnIn, 250);
			wrapper.alpha = 0;
			tw.create(wrapper, "alpha", 1, TBurnIn, 200);
		}
	}
	
	
	function showPetAction(s:Student) {
		var adata = Common.getTActionData(s.data.petAction.a);
		var icon = new lib.Icons();
		icon.gotoAndStop(adata.frame);
		SuperText.registerGlobalImage("petAction", icon);
		message( Tx.PetActionUnlocked({
			_mood	: Common.getCharacterData(s.data.ownCharacter).name,
			_name	: adata.name,
			_desc	: adata.desc
		}).split("|").join("\n\n") );
		//message("<font size='32' color='0x439ECB'>{petAction} "+adata.name+"</font>\n\n"+adata.desc);
	}
	
	function getStateColor(sdata:SStateData) {
		return sdata.cleanable > 0 ? 0xBFFE01 : (sdata.cleanable<0 ? 0xFF5340 : 0xFFC140);
	}

	function getNextSickSFTime() {
		if (!sick)
			return "" ;

		var delta = sickInfos.next - Date.now().getTime() ;

		var d = DateTools.parse(delta) ;

		return Lib.leadingZeros(d.hours, 2) +":"+ Lib.leadingZeros(d.minutes, 2) ;
		
	}
	
	function setStudentHighlight(?s:Student) {
		if( s==null ) {
			arrow.target = null;
			arrow.spr.visible = false;
		}
		if( at(Class) && s!=null && s.fl_visible )
			arrow.target = s;
	}
	
	function showStudentDetails(s:Student) {
		if( lastDetails==s.data.id ) {
			SBANK.cancel().play(0.1);
			hideMessage();
			return;
		}
		
		SBANK.bip01().play(0.5);
		var l = [];
		l.push("<font color='0x59ACFF' size='32'>"+s.data.firstname+"</font>"); // TODO nom de famille
		l.push("<font color='0x395C91'>"+Tx.DetailsNote({_rank:noteDiv(s.data.note)})+"</font>");
		l.push("");
		
		// Caractère
		l.push( Tx.DetailsPersonality({_list:Common.getCharacterData(s.data.ownCharacter).name}) );
		//if( s.data.characters.length>0 ) {
			//var clist = Lambda.map(s.data.characters, function(c) return Common.getCharacterData(c).name);
			//clist = Lambda.filter(clist, function(c) return c!=null);
			//if( clist.length>0 )
				//l.push( Tx.DetailsPersonality({_list:clist.join(",")}) );
		//}

		// Santé
		if( at(Class) ) {
			if( s.isDone() ) {
				l.push("");
				l.push( "<font color='#C9E041'>" + (s.male() ? Tx.DetailsDoneMale : Tx.DetailsDoneFemale) + "</font>" );
			}
			else {
				l.push( Tx.DetailsLife({_life:s.data.life}) );
				if( s.data.boredom>0 )
					l.push( Tx.DetailsBoredom({_bore:s.data.boredom}) );
				else
					l.push( Tx.DetailsBoredomNone );
			}
			l.push("");
		}
		
		// Etats
		if( !s.isDone() )
			if( s.data.states.length>0 ) {
				for( s in s.data.states ) {
					var data =  Common.getStateData(s);
					var col = Color.intToHex( getStateColor(data) );
					var icon = data.cleanable>0 ? "buff" : "debuff";
					l.push( Std.format("<font color='${col}'><b>{${icon}} ${data.name}</b></font> : <font color='0xFFFFFF'>${data.desc}</font>") );
				}
				l.push("");
			}
		
		l.push("<font color='0x475463'>---------------------------------------------------------</font>");
		l.push("");

		// Action chouchou
		if( s.data.petAction!=null ) {
			if( s.data.petAction.k ) {
				// Connue
				var adata = Common.getTActionData(s.data.petAction.a);
				l.push("{petAction} <font size='32' color='0xF88614'>"+adata.name+"</font>");
				l.push("");
				l.push("<font color='0xDE4F0A'>"+adata.desc+"</font>");
				var icon = new lib.Icons();
				icon.gotoAndStop(adata.frame);
				SuperText.registerGlobalImage("petAction", icon);
			}
			else {
				// Inconnue
				l.push("{petAction} <font size='32' color='0x8F9EAF'>"+Tx.DetailsUnknownPetTitle+"</font>"); // TODO trad
				l.push("");
				l.push("<font color='0x617287'>"+Tx.DetailsUnknownPetDesc+"</font>");
				var icon = new lib.Icons();
				icon.gotoAndStop(220);
				SuperText.registerGlobalImage("petAction", icon);
			}
		}
		
		message( l.join("\n"), true );
		lastDetails = s.data.id;
	}
	
	function showStudentTip(s:Student) {
		var col = Color.capInt(s.color, 0.9, 0.4);
		var tcol = Color.brightnessInt(Color.setLuminosityInt(s.color, 1), 0.2);
		hideStudentTip();
		
		// Nom sous l'élève
		//var tf = createField(s.data.firstname, FBig, true);
		//tf.filters = [
			//new flash.filters.GlowFilter(0x0,0.7, 4,4,10),
		//];
		//tf.textColor = tcol;
		//studentName = Lib.flatten(tf, "studentName", 3);
		//var pt = s.getInScrollCoords();
		//studentName.x = Std.int( pt.x-tf.textWidth*0.5 );
		//studentName.y = Std.int( pt.y+40 );
		//studentName.alpha = 0;
		//tw.create(studentName, "alpha", 1, TLinear, 250);
		//gscroller.addChild(studentName);
		
		var states : Array<{color:Int, txt:String}> = [];
		
		// Etats
		if( s.data.getStates().length>0 )
			for(s in Lambda.map(s.data.getStates(), function(s) return Common.getStateData(s)) )
				states.push({color:getStateColor(s), txt:s.name});
				
		
		// Init
		var mw = 36;
		var w = 250;
		var h = 65 + (states.length>2 ? 5 : 0);
		var wrapper = new Sprite();
		
		// Bg
		var bg = new Sprite();
		wrapper.addChild(bg);
		bg.graphics.beginFill(col, 0.6);
		bg.graphics.drawRoundRect(-5,-2,w+10,h+4, 5,5);
		bg.graphics.endFill();
		bg.graphics.beginFill(0x0, 0.2);
		bg.graphics.drawRoundRect(-5, h-12+2, w+10, 12, 5,5);
		
		// Médaillon
		var face = new Sprite();
		wrapper.addChild(face);
		var b = new Bitmap(s.photo);
		b.x = 0;
		face.addChild(b);
		face.scaleX = -2;
		face.scaleY = 2;
		face.x = mw-3;
		face.y = -3;
		
		// Nom
		var tf = createField(s.data.firstname, FBig, true);
		wrapper.addChild(tf);
		tf.x = mw;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.9, 2,2) ];

		// Note
		var tf = createField(noteDiv(s.data.note)+"/" + noteDiv(20), FBig, true);
		wrapper.addChild(tf);
		tf.x = Std.int( w-tf.textWidth-2 );
		tf.y = 0;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.9, 2,2) ];
		
		
		if( !s.isDone() ) {
			// Barre de progression
			var jauge = new LifeJauge();
			wrapper.addChild(jauge);
			jauge.x = Std.int(mw+2);
			jauge.y = 19;
			jauge.life = s.data.life;
			jauge.resist = s.data.boredom;
			jauge.maxWidth = w-mw;
			jauge.maxResist = s.data.maxBoredom;
			jauge.update(false);
			
			// Attention & états
			var tf = createField("", states.length>2 ? FSmall : FBig );
			wrapper.addChild(tf);
			tf.multiline = tf.wordWrap = true;
			tf.width = w - mw;
			tf.height = 100;
			tf.textColor = 0xffffff;
			tf.htmlText = Lambda.map(states, function(s) return Std.format("<font color=\"${mt.deepnight.Color.intToHex(s.color)}\">${s.txt}</font>") ).join(", ");
			tf.x = mw;
			tf.y = 30;
			tf.filters = [
				new flash.filters.GlowFilter(0x000000,0.9, 2,2, 2),
				new flash.filters.DropShadowFilter(1,90, 0x0,0.9, 2,2, 1)
			];
		}

		// Capacité chouchou
		var adata = s.getPetAction();
		if( adata!=null ) {
			var tf = createField(adata.name, FSmall, true);
			wrapper.addChild(tf);
			tf.textColor = 0xFFC600;
			tf.x = w-tf.textWidth;
			tf.y = h-12;
		}

		var hasRightClick = Lib.getFlashVersion()>=11.2 && !Lib.isMac();

		// Tip clic droit
		var tf = createField(hasRightClick ? Tx.MoreInformation : Tx.MoreInformationNoRightClick, FSmall, true);
		wrapper.addChild(tf);
		tf.textColor = 0xE1C6AA;
		tf.x = 17;
		tf.y = h-12;
		
		// Finalisation
		studentTip = Lib.flatten(wrapper, "studentTip");
		dm.add(studentTip, Const.DP_INTERF);
		//studentTip.x = Std.int( WID*0.5-studentTip.width*0.5 );
		//studentTip.y = Std.int( HEI-h-110 );
		//studentTip.x = Std.int( Const.WID-studentTip.width-5 );
		studentTip.x = Std.int( 5 );
		studentTip.y = Std.int( 5 );
		
		// Icone clic droit
		studentTipAnim = tiles.getSprite("mouse");
		dm.add(studentTipAnim,Const.DP_INTERF);
		studentTipAnim.setCenter(0, 0.5);
		studentTipAnim.playAnim(hasRightClick ? "right" : "left");
		studentTipAnim.x = studentTip.x+13;
		studentTipAnim.y = studentTip.y+h-5;
		studentTipAnim.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2,1) ];
		studentTipAnim.alpha = 0;
		tw.create(studentTipAnim, "alpha", 1, 500);
				
		// Bg flou
		var ox = 7;
		var snap = new Bitmap( new BitmapData(Std.int(studentTip.width-ox), Std.int(h+4), false, 0x0) );
		dm.add(snap, Const.DP_MASK);
		var m = new flash.geom.Matrix();
		//m.translate(-studentTip.x-ox, -studentTip.y);
		m.translate(-studentTip.x, -studentTip.y+1);
		studentTip.visible = false;
		snap.bitmapData.draw(root, m);
		studentTip.visible = true;
		snap.x = studentTip.x+ox;
		snap.y = studentTip.y;
		snap.alpha = 0;
		tw.create(snap, "alpha", 0.9, TEase, 200);
		snap.bitmapData.applyFilter(snap.bitmapData, snap.bitmapData.rect, new flash.geom.Point(0,0),
			new flash.filters.BlurFilter(8,8,2) );
		studentTipMask = snap;
		
		// Anim fade in
		studentTip.alpha = 0;
		tw.create(studentTip,"alpha", 1, TEaseOut, 200);
		studentTip.y += 5;
		tw.create(studentTip,"y", studentTip.y-5, TEaseOut, 200);
	}

	
	inline function debug(msg:Dynamic) {
		if( !prod )
			trace(msg);
	}
	inline function warning(msg:Dynamic) {
		debug("WARNING : "+msg);
	}
	
	public function hasWorldMod(k:String) {
		return cinit._solverInit._wm == k;
	}
	
	function getSeats() {
		var l = [];
		for( i in teacher.data.items )
			l.push({x:i._x, y:i._y});
		return l;
	}
	
	function hasSeat(cx,cy) {
		for( s in getSeats() )
			if( s.x==cx && s.y==cy )
				return true;
		return false;
	}
	
	inline function getStudent(sid) {
		return students.get(sid);
	}
	
	function getPet() {
		for(s in students)
			if( s.data.isPet() )
				return s;
		return null;
	}
	
	function getOneStudent(?filter:Student->Bool) {
		if( filter==null )
			filter = function(s) return true;
		var a = [];
		for( s in students )
			if( s.fl_visible && filter(s) )
				a.push(s);
		return a[Std.random(a.length)];
	}
	
	//function getTableStudents(s:Student, includeHimself:Bool) {
		//var list = Lambda.map(s.data.getTableNeighbours(true), function(ns) return getStudent(ns.id));
		//if( includeHimself )
			//list.push(s);
		//return Lambda.filter(list, function(s) return !s.isDone());
	//}
	
	inline function shake(pow:Float, duration:Int) {
		if( !Const.LOWQ || fps<25 )
			tw.create(buffer.render, "y", buffer.render.y+5*pow, TShakeBoth, duration);
	}
	
	function getStudentAt(cx,cy) {
		for(s in students)
			if( s.cx==cx && s.cy==cy )
				return s;
		return null;
	}
	
	function getStudentBySeat(cx,cy) {
		if( at(Class) )
			for(s in students)
				if( s.data.seat.x==cx && s.data.seat.y==cy )
					return s;
		return null;
	}
	
	
	function removeQuery() {
		if( curQuery!=null ) {
			curQuery.parent.removeChild(curQuery);
			curQuery = null;
			hudWrapper.mouseChildren = hudWrapper.mouseEnabled = true;
		}
	}
	
	function query(?from:Iso, ?choiceSimple:Array<String>, ?choices:Array<{cost:Int, txt:String, desc:Null<String>}>, ?wid=150, ?addCancel=false, ?overrideCB:Int->Void) {
		if( choices==null )
			choices = Lambda.array( Lambda.map(choiceSimple, function(s) return {cost:-1, txt:s, desc:null}) );
			
		cancellableQuery = addCancel;
			
		if( cancellableQuery )
			choices.push({cost:-1, txt:Tx.Cancel, desc:null});
		
		SBANK.bip01().play(0.5);
			
		removeQuery();
		hudWrapper.mouseChildren = hudWrapper.mouseEnabled = false;
		var w = wid;
		var h = 22;
		lockActions = true;
		tuto.flushQueue();
		//setCine(false);
		curQuery = new Sprite();
		gscroller.addChild(curQuery);
		
		var col = 0x253949;
		
		var bg = new Sprite();
		curQuery.addChild(bg);
		bg.graphics.beginFill(col, 1);
		bg.graphics.drawRoundRect(0,0,w,choices.length*h, 5,5);
		bg.graphics.beginFill(0xffffff, 1);
		bg.graphics.moveTo(0,5);
		bg.graphics.lineTo(-7,10);
		bg.graphics.lineTo(0,15);
		bg.graphics.beginFill(col, 1);
		bg.graphics.moveTo(0,6);
		bg.graphics.lineTo(-6,10);
		bg.graphics.lineTo(0,14);
		bg.graphics.endFill();
		bg.filters = [
			//new flash.filters.GlowFilter(0x0,1, 2,2, 4),
			new flash.filters.GlowFilter(0xffffff,1, 2,2, 4),
			//new flash.filters.GlowFilter(0x0,1, 2,2, 4),
			new flash.filters.GlowFilter(0x0,1, 2,2, 6)
		];
		
		if( from==null ) {
			curQuery.x = Std.int( Const.WID*0.5 - curQuery.width*0.5 );
			curQuery.y = Std.int( Const.HEI*0.5 - curQuery.height*0.5 );
		}
		else {
			var pt = from.getInScrollCoords();
			curQuery.x = Std.int( pt.x + 25 );
			curQuery.y = Std.int( pt.y );
		}
		
		function addButton(cost:Int, str:String, desc:Null<String>) {
			var b = new Sprite();
			curQuery.addChild(b);
			b.graphics.beginFill(0x0, 0);
			b.graphics.drawRect(1,1,w-2, h-2);
			b.graphics.lineStyle(1, 0xffffff, 0.1);
			b.graphics.moveTo(0,h);
			b.graphics.lineTo(w-2, h);
			var obg = new flash.display.Sprite();
			b.addChild(obg);
			obg.graphics.beginFill(0xA94749, 1);
			obg.graphics.drawRoundRect(1,0,w-1,h, 5,5);
			obg.visible = false;
			//obg.filters = [ new flash.filters.GlowFilter(0xffffff,0.4, 4,4,1, 1, true) ];
			obg.filters = [ new flash.filters.BlurFilter(4,0, 2) ];
			var stf = new SuperText();
			stf.setSize(w, h);
			stf.setFont(0xFFFFFF, "big", 16);
			stf.y = 1;
			stf.setText(str);
			//stf.autoResize();
			if( cost<0 )
				// Aucun coût (-1)
				stf.x = Std.int(w*0.5 - stf.textWidth*0.5);
			else {
				// Avec coût (qui peut être 0)
				if( cost>0 ) {
					var ctf = createField(cost>0 ? Tx.Cost({_n:cost}) : Tx.CostFree, FSmall, true);
					b.addChild(ctf);
					ctf.x = w - 20 - ctf.textWidth;
					ctf.y = 2;
					ctf.textColor = 0xFFFF00;
					var icon = tiles.getSprite("life");
					b.addChild(icon);
					icon.x = w-7;
					icon.y = 1;
				}
				//var arrow = tiles.getSprite("queryArrow");
				//b.addChild(arrow);
				//arrow.x = 41;
				//arrow.y = 1;
				stf.x = 5;
			}
			b.addChild(stf.wrapper);
			b.buttonMode = b.useHandCursor = true;
			b.addEventListener(flash.events.MouseEvent.MOUSE_OVER, function(_) {
				obg.visible = true;
				if( desc!=null )
					tip.show(desc);
			});
			b.addEventListener(flash.events.MouseEvent.MOUSE_OUT, function(_) {
				obg.visible = false;
				tip.hide();
			});
			return b;
		}
		for(i in 0...choices.length) {
			var b = addButton(choices[i].cost, choices[i].txt, choices[i].desc);
			b.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
				removeQuery();
				if( cancellableQuery && i==choices.length-1 ) {
					SBANK.cancel().play();
					lockActions = false;
				}
				else
					if( overrideCB!=null ) {
						SBANK.actionSend().play(0.5);
						overrideCB(i);
					}
					else
						sendAction( TAction.Answer, [AT_Num(i)] );
				cancelClick = true;
			});
			b.y = i*h;
		}
		
		curQuery.x+=10;
		tw.create(curQuery, "x", curQuery.x-10, 300);
	}
	
	
	function setHandCursor(b:Bool) {
		buffer.render.buttonMode = buffer.render.useHandCursor = b;
	}
	
	
	function onMouseDown(_) {
		var m = getMouse();
		cancelClick = false;
		dragInfos = {s:scroll.cy, mx:m.x, my:m.y, sx:bscroller.x, sy:bscroller.y};
	}
	
	function onMouseUp(_) {
		dragInfos = null;
	}
	
	function onRightClick(_) {
		if( interfaceLocked() ) {
			onClick(null);
			return;
		}
			
		if( overedStudent==null ) {
			if( pendingAction!=null ) {
				SBANK.cancel().play(0.5);
				cancelAction();
			}
			return;
		}
			
			
		showStudentDetails(overedStudent);
	}
	
	function onMouseMove(_) {
		//if( dragInfos!=null ) {
			//var m = getMouse();
			//var d = Lib.distance(m.x, m.y, dragInfos.mx, dragInfos.my);
			//if( d>=10 )
				//cancelClick = true;
			//setScroll(
				//dragInfos.sx + (m.x-dragInfos.mx)/buffer.upscale,
				//dragInfos.sy + (m.y-dragInfos.my)/buffer.upscale
			//);
		//}
	}
	//function onMouseWheel(e:flash.events.MouseEvent) {
		//if( e.delta==0 )
			//return;
		//var d = -0.20 * e.delta;
		//setScroll( scroll.cx, scroll.cy+d );
	//}
	
	function setScroll(cx:Float, cy:Float) {
		tw.terminate(scroll);
		scroll.cx = cx;
		scroll.cy = cy;
		
		updateScroll();
	}
	
	function updateScroll() {
		var cx = scroll.cx+1;
		var cy = scroll.cy-2; // recal
		
		var pt = Iso.isoToScreenStatic(-cx, -cy);
		bscroller.x = Std.int( pt.x-buffer.width*0.5 ) ;
		bscroller.y = Std.int( pt.y-20 );
		
		var pt = buffer.localToGlobal(bscroller.x, bscroller.y);
		gscroller.x = Std.int( pt.x-buffer.render.x );
		gscroller.y = Std.int( pt.y-buffer.render.y );
		focus.mask.x = -bscroller.x;
		focus.mask.y = -bscroller.y;
	}
	
	inline function centerScroll(?duration:Int) {
		switch( curPlace ) {
			case Home :
				tweenScroll( Const.RWID*0.4-1, Const.RHEI*0.4-1, duration );
				
			case HQ :
				tweenScroll( Const.RWID*0.4-1, Const.RHEI*0.4-1, duration );
				
			case Class :
				tweenScroll( Const.RWID*0.4, Const.RHEI*0.4, duration );
		}
	}
	
	inline function tweenScroll(cx:Float, cy:Float, ?duration=2000) {
		if( cm.turbo )
			setScroll(cx,cy);
		else {
			tw.create(scroll, "cx", cx, TEase, duration).onUpdate = updateScroll;
			tw.create(scroll, "cy", cy, TEase, duration).onUpdate = updateScroll;
		}
	}
	
	function onClick(_) {
		if( cancelClick )
			return;
			
		if( curMessage!=null ) {
			message();
			cancelClick = true;
			cm.signal("message");
			return;
		}

		if( curPicture!=null ) {
			SBANK.windShort().play(0.5);
			hidePicture();
			lockActions = false;
			return;
		}
			

		if( !ready || lockActions )
			return;
			
		if( Key.isDown(Keyboard.SHIFT) ) {
			onRightClick(null);
			return;
		}
			
		// HACK : TESTS
		#if debug
		var t = teacher;
		var s = getOneStudent();
		//ring(false);
		//var pt = getMouseIso();
		//helper.goto(pt);
		//t.say(tg.m_history());
		//fx.row(5, 0xFFBF00);
		//ring(true);
		//death();
		//fx.itemRain(teacher, 20);
		//fx.lightning(s,t);
		//t.setAnim(TA_Shock);
		//var s : Student = null;
		//for(s2 in students) { s=s2; break; }
		//fx.bomb(t.sprite.x, t.sprite.y);
		//cm.create({
						//s.setAnim(SA_EvilGrin);
						//fx.smokeNova(s.getHead(), 0x0, 0.5, true, 1.3);
						//100 >> fx.blink(s, 0x0, 5, 600);
						//700;
						//s.jump(3);
						//s.setAnim(SA_EvilLaugh);
						//fx.nova(s.getHead(), 0x0, 2);
						//300 >> fx.smokeNova(s.getHead(), 0x0, 1.3, 1);
						//1000;
						//s.setAnim();
		//});
		#end

		// clic sur Iso intéractifs
		var pt = bmouse;
		if( overedIso!=null ) {
			overedIso.onClick();
			cancelClick = true;
			return;
		}
		//for(i in isos)
			//if( i.over(pt) ) {
				//i.onClick();
				//cancelClick = true;
				//return;
			//}
			
		// Déplacement prof
		var pt = getMouseIso(true);
		if( freeMove() && pt!=null ) {
			if( getPathCollision(tpf, pt.x, pt.y) ) {
				var deltas = [
					{dx:-1,dy:0}, {dx:1,dy:0}, {dx:0,dy:-1}, {dx:0,dy:1},
					{dx:-1,dy:-1}, {dx:1,dy:1}, {dx:1,dy:-1}, {dx:-1,dy:1},
				];
				for( d in deltas )
					if( !getPathCollision(tpf, pt.x+d.dx, pt.y+d.dy) ) {
						pt = { x : pt.x+d.dx, y : pt.y+d.dy }
						break;
					}
			}
			if( !getPathCollision(tpf, pt.x, pt.y) ) {
				var m = getMouse();
				fx.moveFeedBack( m.x-gscroller.x, m.y-gscroller.y );
				teacher.goto( pt );
			}
		}

		var a = getActiveTarget();
		if( a!=null ) {
			var found = false;
			for(t in targets)
				if(t==a.value) {
					found = true;
					targets.remove(t);
					break;
				}
				
			if( !found )
				targets.push(a.value);
				
			if( targets.length>=neededTargets )
				sendAction();
			else
				SBANK.actionSelect().play();
		}
		else {
			if( pendingAction!=null ) {
				SBANK.cancel().play(0.5);
				cancelAction();
			}
		}
		
		ActionBar.updateAll();
	}
	
	//function jsUpdateAverage(avg:Float) {
		//flash.external.ExternalInterface.call("_updateMark", avg);
	//}
	
	function jsUpdateMark(sid:Int, v:Float) {
		flash.external.ExternalInterface.call("_updateMark", sid, v, langDivisor);
	}
	
	function jsAddXp(v:Int) {
		flash.external.ExternalInterface.call("_updateXP", v);
	}

	function jsUpdateGold(v:Int) {
		flash.external.ExternalInterface.call("_updateGold", v);
	}

	function jsUpdateObject(id : Int, c:Int) {
		flash.external.ExternalInterface.call("_updateObject", id, c);
	}

	function jsCall(action:String, params:Array<Dynamic>) {
		switch(action.toLowerCase()) {
			case "studentinfo" :
				var id : Int = params[0];
				var s = getStudent(id);
				showStudentDetails(s);
				hideStudentTip();
				setStudentHighlight();
			case "studentover" :
				if( at(Class) && curMessage==null && curPicture==null ) {
					var id : Int = params[0];
					var s = getStudent(id);
					setStudentHighlight(s);
					showStudentTip(s);
				}
			case "studentout" :
				if( at(Class) ) {
					setStudentHighlight();
					hideStudentTip();
				}
			case "mousewheel" :
				//delta = Std.int(MathEx.clamp(delta, -1, 1));
				//if (superCont.visible)	superBar.moveScroll(delta);
				//else					invBar.moveScroll(delta);
				//mainBar.moveScroll(delta);
			case "soundstate" :
				applySoundState(params[0]);
		}
	}
	
	function applySoundState(?st:Int) {
		if( st==null )
			st = curSoundState;
			
		curSoundState = st;
		var mus = Std.int(curSoundState/10);
		var snd = curSoundState-mus*10;
		
		// Musique
		switch( mus ) {
			case 0 :
				Sfx.muteChannel(Const.MUSIC_CHANNEL);
			case 1 :
				Sfx.unmuteChannel(Const.MUSIC_CHANNEL);
				Sfx.setChannelVolume(Const.MUSIC_CHANNEL, Const.MUSIC_VOLUME*0.5);
			default :
				Sfx.unmuteChannel(Const.MUSIC_CHANNEL);
				Sfx.setChannelVolume(Const.MUSIC_CHANNEL, Const.MUSIC_VOLUME);
		}
		
		// Sons
		switch( snd ) {
			case 0 :
				Sfx.muteChannel(Const.SFX_CHANNEL);
			case 1 :
				Sfx.unmuteChannel(Const.SFX_CHANNEL);
				Sfx.setChannelVolume(Const.SFX_CHANNEL, 0.5);
			default :
				Sfx.unmuteChannel(Const.SFX_CHANNEL);
				Sfx.setChannelVolume(Const.SFX_CHANNEL, 1);
		}
		/*
		switch( st ) {
			case 0 : // rien
				Sfx.muteGlobal();
			case 1 : // sfx
				Sfx.unmuteGlobal();
				Sfx.muteChannel(Const.MUSIC_CHANNEL);
			//case 2 : // sfx + musique (réduite)
				//Sfx.unmuteGlobal();
				//Sfx.unmuteChannel(Const.MUSIC_CHANNEL);
				//music.setVolume(0.5);
			case 2 : // sfx + musique
				Sfx.unmuteGlobal();
				Sfx.unmuteChannel(Const.MUSIC_CHANNEL);
				music.setVolume(1);
			default :
			//default : throw "unknown soundstate "+st;
		}
		*/
	}
	
	
	function onClickAction(a:TActionData, ?target0:AcTarget, ?getTargetParam:Dynamic) {
		if( cancelClick || lockActions )
			return;
			
		var old = pendingAction;
		cancelAction();

		if( old!=null && old.a==a && (getTargetParam==null || getTargetParam==old.sub) ) {
			SBANK.cancel().play(0.5);
			return;
		}
			
		//if( a.id==TAction.WakeUp ) {
			//var choices = [] ;
			//choices.push({cost:0, txt:a.name+" ("+logic.Data.CONTINUE_COST+"_{budget})", desc:a.desc}); // TODO
			//choices.push({cost:0, txt:Tx.Cancel, desc:null});
//
//
			//query(teacher, choices, 220, function(i:Int) {
				//if( i < choices.length - 1 ) {
					//lockActions = false;
					//sendAction(a.id) ;
					//jsUpdateGold(teacher.data.gold - logic.Data.CONTINUE_COST) ;
				//}
				//else
					//lockActions = false;
			//});
			//return;
		//}
		
		var t = solver.getTargets(a.id, getTargetParam);
		pendingAction = {a:a, sub:getTargetParam, target0:target0};
		SBANK.actionSelect().play();
		
		pendingCursor = new Sprite();
		//pendingCursor.addChild(Lib.flatten(mainBar.getAction(a).icon));
		//pendingCursor.scaleX = pendingCursor.scaleY = 0.85;
		//pendingCursor.alpha = 0.6;
		//pendingCursor.blendMode = BlendMode.ADD;
		var tf = createField(a.name, true);
		tf.textColor = 0xFFE864;
		tf.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2,3) ];
		pendingCursor.addChild(tf);
		dm.add(pendingCursor, Const.DP_INTERF);
		
		switch( a.id ) {
			case TAction.Swap :
				var pt = mainBar.getActionCoordinate(TAction.Swap);
				tuto.showOnce(Tx.Tuto_Swap1, pt.x, pt.y);
				tuto.showOnce(Tx.Tuto_Swap2({_value:noteDiv(logic.Data.NOTE_REWARD_PER_LINE[0])}), 280,175, 80);
				tuto.showOnce(Tx.Tuto_Swap3({_value:noteDiv(logic.Data.NOTE_REWARD_PER_LINE[1])}), 355,130, 80);
				tuto.showOnce(Tx.Tuto_Swap4, 410,100, 80);
				tuto.showOnce(Tx.Tuto_Swap5);
			default :
		}
		
		for(p in potentialTargets) {
			switch(p.type) {
				case PT_Box(x,y,w,h, spr, detach) :
					if( detach )
						spr.parent.removeChild(spr);
					else
						spr.filters = [];
					
				case PT_Iso(i) :
					i.destroy();
				case PT_IsoGroup(l) :
					for(i in l)
						i.destroy();
			}
		}
		
		potentialTargets = new Array();
		neededTargets = 1;
		switch( t ) {
			case Teacher :
				sendAction();
				
			case All_Students :
				sendAction();
				
			case Choose_Student(n, with) :
				neededTargets = n;
				for(s in students)
					if( !s.isDone() )
						potentialTargets.push({
							type : PT_Box(s.sprite.x-10, s.sprite.y, 20,28, s.sprite, false),
							value : AT_Std(s.data.id),
						});
					
			case Choose_Seat(n) :
				neededTargets = n;
				for( seat in getSeats() ) {
					var s = getStudentAt(seat.x, seat.y);
					if( s==null ) {
						// Silhouettes
						var pt = Iso.isoToScreenStatic(seat.x, seat.y);
						pt.x = pt.x-12;
						pt.y = pt.y+4;
						var s = tiles.getSprite("silhouette");
						s.setCenter(0, 0);
						s.x = pt.x-4;
						s.y = pt.y-4;
						//s.alpha = 0.5;
						sdm.add(s, Const.DP_INTERF);
						potentialTargets.push({
							type : PT_Box(pt.x-2,pt.y-2,16,20, s, true),
							value : AT_Coord({_x:seat.x, _y:seat.y}),
						});
					}
					else
						if( !s.isDone() )
							potentialTargets.push({
								type : PT_Box(s.sprite.x-10, s.sprite.y, 20,28, s.sprite, false),
								value : AT_Coord({_x:s.cx, _y:s.cy}),
							});
				}
			
			case Choose_Num :
				debug("not implemented");
					
			case Choose_Column :
				var h = new IntHash();
				for (s in students)
					h.set(s.data.seat.x, true);
				for(x in h.keys()) {
					var group = new Array();
					for(y in 1...Const.RHEI-4) {
						var i = new Iso(tiles.getSprite("cursor"), x,y);
						group.push(i);
					}
					potentialTargets.push( {type:PT_IsoGroup(group), value:AT_Num(x)} );
				}
				
			case Choose_Line :
				var h = new IntHash();
				for (s in students)
					h.set(s.data.seat.y, true);
				for(y in h.keys()) {
					var group = new Array();
					for(x in 0...Const.RWID) {
						var i = new Iso(tiles.getSprite("cursor"), x,y);
						group.push(i);
					}
					potentialTargets.push( {type:PT_IsoGroup(group), value:AT_Num(y)} );
				}
		}
		ActionBar.updateAll();
	}
	
	
	inline function shortcut(i:Iso, url:String) {
		gotoAndDo( i, function() gotoUrl(url) );
	}
	
	inline function useEquipment(i:Iso, a:TAction) {
		//mainBar.onActionClicked( Common.getTActionData(a) );
		mainBar.onActionClicked( getAction(a) );
	}
	
	function gotoAndDo(i:Iso, cb:Void->Void) {
		if( sick )
			return;
			
		SBANK.bip01(0.5);
		if( teacher.waitingAt(i.getStandPoint()) )
			cb();
		else {
			teacher.goto( i.getStandPoint() );
			teacher.onArriveCB = cb;
		}
	}
	
	
	function sendAction(?a:TAction, ?tg:Array<AcTarget>) {
		#if !debug
		if (!serverIsOk) {
			message(Tx.ServerIsWaiting) ;
			cancelAction() ;
			return ;
		}
		#end
		
		hidePointer();

		if( tg==null )
			tg = targets;
		if( a==null ) {
			a = pendingAction.a.id;
			if( pendingAction.target0!=null )
				tg.insert(0, pendingAction.target0);
		}
		
		SBANK.actionSend().play(0.4);
		
		var last = tuto.getRecentKeys();
		tuto.clearRecentKeys();
		tuto.startQueuing();
		
		debug("sendaction "+a+" @ "+tg +"#"+solver.turn);
		teacher.ambiant();
		teacher.stopAmbiantSaying();
		
		//hideInventory();
		//hideSupers();
		setCine(true);
		tip.hide();

		var sa : SendAction = {	_r : solver.turn,
								_a : a,
								_t : Lambda.list(tg),
								_tu : last,
								_v : flash.system.Capabilities.version
							} ;
		logs = solver.doTurn(sa) ;
		serverIsOk = false ;

		#if !debug
			switch(a) {
				case StartLesson, WakeUp : //nothing to do => url
				default : tools.Codec.load("http://" + cinit._actionUrl, sa, onServerData, 5) ;
			}
		#end

		ActionBar.updateAll();
		cancelAction();
		playLog();
	}


	function onServerData(a : Answer) {
		debug("onServerData : " + Std.string(a) + " # teacher => pa : " + solver.teacher.pa + ", sc : " + solver.teacher.selfControl) ;

		if (!a._ok) {
			fatalError = true ;
			message( Tx.ServerError, false, "/") ;
			return ;
		} else
			serverIsOk = true ;

		if (a._url != null)
			gotoUrl(a._url._u) ;
		else {
			if (waitingUrl.length > 0)
				gotoUrl(waitingUrl[0]) ;
		}
	}
	
	function initPathFinders() {
		spf = new PathFinder(Const.RWID+Const.PF_PADDING*2, Const.RHEI+Const.PF_PADDING*2, false);
		spf.moveCost = function(fx,fy, tx,ty) {
			if( tx==Const.PF_PADDING+1 )
				return 4;
			if( ty>=Const.PF_PADDING+Const.DESK.y && tx>=Const.PF_PADDING+Const.DESK.x-2 )
				return 4;
			return getStudentBySeat(tx+Const.PF_PADDING,ty+Const.PF_PADDING)!=null ? 8 : 1;
		}
		
		tpf = new PathFinder(Const.RWID+Const.PF_PADDING*2, Const.RHEI+Const.PF_PADDING*2, false);
		tpf.moveCost = function(fx,fy, tx,ty) {
			return getStudentBySeat(tx-Const.PF_PADDING,ty-Const.PF_PADDING)!=null ? 8 : 1;
		}

		if( at(HQ) || at(Home) ) {
			tpf.fillAll(true);
			spf.fillAll(true);
			for (x in 0...Const.RWID)
				for (y in 0...Const.RHEI)
					setAllPathCollision( x, y, false );
		}

		var i = furns.get("bed");
		if( i!=null )
			setSquareCollision(tpf, i.cx, i.cy-1, 3,2, true);
			
		var i = furns.get("bigTable");
		if( i!=null )
			setSquareCollision(tpf, i.cx, i.cy-3, 2,4, true);
		
		for (i in isos)
			if( i.collides )
				setAllPathCollision( i.cx, i.cy );
			
		for (i in 0...Const.RWID) {
			setAllPathCollision( i, 0 );
			setAllPathCollision( i, Const.RHEI );
		}
		
		for (i in 0...Const.RHEI) {
			setAllPathCollision( 0, i );
			setAllPathCollision( Const.RWID, i );
		}
		
		if( at(Home) ) {
			// Salle de bains
			for(x in 0...Const.RWID)
				for(y in Const.RHEI-3...Const.RHEI)
					setAllPathCollision(x,y, true);
			for(x in [4,5,6])
				for(y in Const.RHEI-2...Const.RHEI+1)
					setAllPathCollision(x,y, false);
			setAllPathCollision(5, Const.RHEI-3, false);
			setAllPathCollision(3, Const.RHEI-2, false);
		}
		
		#if debug
		for(x in -3...Const.RWID+4)
			for(y in -3...Const.RHEI+4) {
				var i = new Iso(tiles.getSprite("collision"), x,y);
				i.sprite.alpha = getPathCollision(tpf, x,y) ? 0.7 : 0.1;
				i.zpriority = -10;
				i.setStandPoint(-999,-999);
			}
		#end
	}
	
	inline function setSquareCollision(pf:PathFinder, x,y,w,h, ?c=true) {
		pf.setSquareCollision(x+Const.PF_PADDING, y+Const.PF_PADDING, w,h, c);
	}
	inline function setPathCollision(pf:PathFinder, x,y, ?c=true) {
		pf.setCollision(x+Const.PF_PADDING, y+Const.PF_PADDING, c);
	}
	inline function setAllPathCollision(x,y, ?c=true) {
		setPathCollision(spf, x,y, c);
		setPathCollision(tpf, x,y, c);
	}
	inline function getPathCollision(pf:PathFinder, x,y) {
		return pf.getCollision(x+Const.PF_PADDING, y+Const.PF_PADDING);
	}
	
	function getPath(pf:PathFinder, from:Point, to:Point) {
		var f = {x:from.x+Const.PF_PADDING, y:from.y+Const.PF_PADDING}
		var t = {x:to.x+Const.PF_PADDING, y:to.y+Const.PF_PADDING}
		var p = pf.astar(f,t);
		var p2 = [];
		for(pt in p)
			p2.push( {x:pt.x-Const.PF_PADDING, y:pt.y-Const.PF_PADDING} );
		return p2;
	}
	
	public function getStudentPath(from:Point, to:Point) {
		return getPath(spf, from, to);
		//if ( to.x<0 || to.y<0 || to.x>=RWID || to.y>=RHEI )
			//return null;
		//else
			//return spf.astar(from,to);
	}
	
	public function getTeacherPath(from:Point, to:Point) {
		return getPath(tpf, from, to);
		//if ( to.x<0 || to.y<0 || to.x>=RWID || to.y>=RHEI )
			//return null;
		//else
			//return tpf.astar(from,to);
	}
	
	inline function globalToBuffer(x:Float,y:Float) {
		return buffer.globalToLocal( x-bscroller.x*buffer.upscale, y-bscroller.y*buffer.upscale );
	}
	
	inline function getMouseBuffer() {
		var m = getMouse();
		return globalToBuffer(m.x, m.y);
	}
	
	inline function getMouse() {
		return {x:root.mouseX, y:root.mouseY};
	}
	
	inline function getMouseIso(?yOffset=4, ?allowOutside=false) {
		var pt = Iso.globalToIso(buffer, root.mouseX,root.mouseY+yOffset);
		return
			if( !allowOutside && (pt.x<0 || pt.y<0 || pt.x>=Const.RWID || pt.y>=Const.RHEI) )
				null;
			else
				pt;
	}
		
	//function getStudentAtScreen(x:Float,y:Float ) {
		//var best : Student = null;
		//var pt = buffer.globalToLocal(x,y);
		//for (s in students)
			//if (s.fl_visible && pt.x>=s.sprite.x-8 && pt.x<s.sprite.x+8 && pt.y>=s.sprite.y+3 && pt.y<s.sprite.y+s.hei)
				//if(best==null || s.depth>best.depth)
					//best = s;
		//return best;
	//}
	
	function placeName(name:String, col:Int, scale:Float, ?dy=0) {
		var t = DateTools.format( Date.now(), "%H:%M" );
		var wrapper = new Sprite();

		// Nom
		var tf = createField(name, true);
		wrapper.addChild(tf);
		tf.textColor = col;
		wrapper.filters = [
			new flash.filters.GlowFilter(Color.setLuminosityInt(col,0.4),1, 2,2,10),
		];
		
		var bmp = Lib.flatten(wrapper, 4);
		buffer.dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = bmp.scaleY = scale;
		bmp.x = Std.int( buffer.width*0.5 - bmp.width*0.5 );
		bmp.y = -50 + -10 +  dy;
		tw.create(bmp, "y", bmp.y+50 + (photoMode?5:0), TEaseOut, 500).fl_pixel = true;
		delayer.add(function() {
			tw.create(bmp, "alpha", 0, TEase, 2500).onEnd = function() {
				bmp.bitmapData.dispose();
				bmp.parent.removeChild(bmp);
			}
		}, 2000);
	}
	
	function announce(str:String, ?col=0xFFFFFF) {
		var tf = createField(str);
		dm.add(tf, Const.DP_INTERF);
		tf.scaleX = tf.scaleY = 3;
		tf.textColor = col;
		tf.x = Std.int( Const.WID*0.5 - tf.textWidth*0.5*tf.scaleX );
		tf.y = Const.HEI;
		
		tf.filters = [ new flash.filters.GlowFilter(col, 0.7, 16,16,1) ];
		tf.alpha = 0;
		tw.create(tf, "alpha", 1, TEase, 300);
		tw.create(tf, "y", Std.int( Const.HEI*0.65 - tf.textHeight*0.5*tf.scaleY ), TEaseOut, 500).fl_pixel = true;
		delayer.add(function() {
			tw.create(tf, "x", tf.x+50, TEaseIn, 1200);
			tw.create(tf, "alpha", 0, TEase, 1200).onEnd = function() {
				tf.parent.removeChild(tf);
			}
		}, 1000);
	}
	
	public function createField(html:String, ?font:Font, ?size:Null<Int>, ?adjustSize=false) {
		if( font==null )
			font = FSmall;
		if( size==null )
			size = switch(font) {
				case FSmall : 8;
				case FBig : 16;
			}
		var f = new flash.text.TextFormat();
		f.font = switch( font ) {
			case FSmall : "small";
			case FBig : "big";
		};
		f.size = size;
		f.color = 0xffffff;
		
		var tf = new flash.text.TextField();
		tf.width = adjustSize ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = html;
		if( adjustSize ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}
		
		return tf;
	}
	
	
	function updateEntities(always:Bool) {
		// updates
		for (i in isos) {
			i.update();
			i.calcDepth();
		}
		
		// zsort
		if( always || time%2==0 ) {
			isos.sort( function(a,b) {
				return Reflect.compare(a.depth, b.depth);
			});
			for (i in isos)
				sdm.over(i.sprite);
		}
	}
	
	function createCopy(o:Dynamic) : Dynamic {
		var s = new haxe.Serializer();
		s.useCache = true;
		s.serialize(o);
		return haxe.Unserializer.run( s.toString() );
	}
	
	function syncData() {
		teacher.syncData();
		for( sid in students.keys() )
			getStudent(sid).syncData();
	}
	
	/*
	function updateKarma() {
		var k = teacher.data.stance;
		if( k>3 ) k = 3;
		if( k<-3 ) k = -3;
		tw.create(karmaBar.bar, "scaleX", -k/3, TEaseOut);
		var ct = if( k==0 ) Color.getColorizeCT(0xC0C0C0, 0.5);
			else if( k>0 ) Color.getColorizeCT(0xFFBF00, 0.5);
			else if( k<0 ) Color.getColorizeCT(0xEA1515, 0.5);
		karmaBar.bar.transform.colorTransform = ct;
		karmaBar.bg.transform.colorTransform = ct;
	}
	*/
	
	
	function onBeginTurn() {
		tuto.flushQueue();
		lockActions = false;
		setFocus();
		setTime(teacher.data.pa);
		
		var turn = teacher.data.maxPa-teacher.data.pa+1;
		if( at(Class) && lastTurn!=turn )
			announce( Tx.AnnounceTurn({_n:turn}) );
		if( !at(Class) && lastTurn!=turn && turn==1 )
			if( !sick && !photoMode )
				announce( Tx.AnnounceOneAction );
		lastTurn = turn;
		
		for(i in furns) {
			if( sick )
				i.allowClick = false;
			if( i.linkedAction!=null )
				i.allowClick = !sick && solver.teacher.canDo(i.linkedAction);
		}
				
		if( at(Class) ) {
			teacher.initAmbiantSaying();
			teacher.goto(Const.BOARD);
			teacher.onArriveCB = function() teacher.setAnim(TA_WriteBoard);
		}
		
		updateHud();
		
		// Tuto
		if( !photoMode )
			delayer.add( function() {
				if( teacher.hasHats() ) {
					var pt = teacher.getGlobalCoords();
					tuto.showOnce(Tx.Tuto_Hat1, pt.x, pt.y, 50);
					tuto.showOnce(Tx.Tuto_Hat2, pt.x, pt.y, 80);
				}
				if( at(HQ) ) {
					tuto.showOnce(Tx.Tuto_HQ1, 200,35, 270,165);
					tuto.showOnce(Tx.Tuto_HQ2, 250,285, 185,60);
					var pt = furns.get("sofa").getGlobalCoords();
					tuto.showOnce(Tx.Tuto_HQ3, pt.x, pt.y+40, 60);
					tuto.showOnce(Tx.Tuto_HQ4, 200,35, 270,165);
				}
				if( at(Home) ) {
					tuto.showOnce(Tx.Tuto_Home1, 200,35, 270,165);
					tuto.showOnce(Tx.Tuto_Home2, 250,285, 185,60);
					tuto.showOnce(Tx.Tuto_Home3, 180,35, 310,165);
					if( !homeCustomizer.isEmpty() )
						tuto.showOnce(Tx.Tuto_HomeCust1, 475,3, 200, 30);
				}
				if( at(Class ) ) {
					if( !tuto.hasShown(Tx.Tuto_Intro1) ) {
						tuto.showOnce(Tx.Tuto_Intro1);
						var pt = getOneStudent(function(s) return s.data.boredom>0).getGlobalCoords();
						pt.x-=15;
						pt.y+=15;
						tuto.showOnce(Tx.Tuto_Intro2, pt.x, pt.y);
						tuto.showOnce(Tx.Tuto_Intro3, pt.x, pt.y);
						tuto.showOnce(Tx.Tuto_Intro4, 200,35, 270,165);
						tuto.showOnce(Tx.Tuto_Intro5, 230,285, 225,60);
						tuto.showOnce(Tx.Tuto_Intro6, 140,326, 400,70);
					}
					if( teacher.data.selfControl <= teacher.data.maxSelfControl*0.8 )
						tuto.showOnce(Tx.Tuto_Life, 70,335, 90);
					if( teacher.data.pa <= teacher.data.maxPa*0.6 )
						tuto.showOnce(Tx.Tuto_Time, 615,340, 80);
					if( teacher.data.selfControl <= teacher.data.maxSelfControl*0.5 ) {
						var pt = getPotionCoordinates();
						if( pt!=null ) {
							tuto.showOnce(Tx.Tuto_LowLife1, pt.x, pt.y);
							tuto.showOnce(Tx.Tuto_LowLife2, 615, 340, 80);
						}
					}
					if( mainBar.getAction(TAction.ChoosePet)!=null ) {
						var pt = mainBar.getActionCoordinate(TAction.ChoosePet);
						tuto.showOnce(Tx.Tuto_Pet1, pt.x, pt.y);
						tuto.showOnce(Tx.Tuto_Pet2, 200,35, 270,165);
					}
				}
			}, 600 );
		
		// Conseils
		if( delayedTip!=null && !cm.turbo ) {
			var cb = delayedTip;
			delayedTip = null;
			delayer.add(cb, 600);
		}
	}
	
	function onEndLog() {
		if( curQuery==null )
			onBeginTurn();
		syncData();
		if( !cm.turbo )
			ActionBar.updateAll();
	}
	
	
	function getPotionCoordinates() {
		var pt = mainBar.getActionCoordinate( Type.enumIndex(TObject.Heal_0) );
		if( pt==null )
			pt = mainBar.getActionCoordinate( Type.enumIndex(TObject.Heal_1) );
		if( pt==null )
			pt = mainBar.getActionCoordinate( Type.enumIndex(TObject.Heal_2) );
		return pt;
	}
	
	inline function addSign(n:Float) {
		return n>0 ? "+"+n : Std.string(n);
	}
	
	//function addQueue(fn:Void->Void, ?autoNextDelay=-1) {
		//if( autoNextDelay>=0 )
			//queue.add(function() {
				//fn();
				//if( autoNextDelay==0 )
					//nextQueue();
				//else
					//delay.add( nextQueue, autoNextDelay );
			//});
		//else
			//queue.add(fn);
	//}
	//
	//function qwait(d:Int) {
		//q( function() delay.add( nextQueue, d ) );
	//}
	//
	//function nextQueue() {
		//if( queue.length>0 )
			//queue.pop()();
		//else if( logs.length>0 )
			//playLog();
	//}
	//
	
	//function setPause(b) {
		//lockPause = b;
		//return b;
	//}
	
	function doneAnim(s:Student, gain:Float) {
		if( cm.turbo ) {
			s.setDone();
			s.updatePose();
		}
		else
			parallelCM.create({
				300;
				s.setAnim(SA_Happy);
				s.jump(2);
				fx.done(s, Const.LEARN_TXT_COLOR);
				SBANK.levelUp().play();
				fx.grade(s, noteDiv(gain));
				jsUpdateMark(s.data.id, noteDiv(s.data.note+gain));
				if( !Const.LOWQ ) {
					//300 >> fx.smokeNova( s.getFeet(), 0xffffff );
					//300 >> fx.nova( s.getFeet(), 0xffffff );
					fx.explosion(s, 0xFFAD33) > 150;
					fx.flashBang(0.35, 600);
				}
				1100;
				s.setDone();
				s.data.knowledge = solver.getStudent(s.data.id).knowledge;
				s.updatePose();
				//s.knowledge.value = s.data.knowledge;
				s.bar.life = s.data.life;
				s.bar.update();
				s.data.note+=gain;
				onDataChange(s);
			});
	}
	
	function ring(win:Bool) {
		// Color mask
		gameEnded = true;
		var s = new Sprite();
		if( win )
			s.graphics.beginFill( 0xFFFF84, 0.4 );
		else
			s.graphics.beginFill( 0xFF0000, 0.7 );
		s.graphics.drawRect(0,0, Const.WID, Const.HEI);
		s.blendMode = BlendMode.ADD;
		tw.create(s, "alpha", 0, 3000).onEnd = function() {
			s.parent.removeChild(s);
		}
		dm.add(s, Const.DP_MASK);
		
		var i = 0;
		var pt = Iso.isoToScreenStatic(Const.EXIT.x, Const.EXIT.y);
		function ringRun(){
			for(s in students) {
				delayer.add(function() {
					s.setStuffVisibility(false);
					s.goto(Const.EXIT);
					if( Std.random(100)<50 )
						s.setAnim(SA_Talk);
					else
						s.setAnim(SA_Laugh);
				}, i*100 + Std.random(200));
				i++;
			}
		}
		cm.create({
			setFocus();
			shake(0.5, 1000);
			popAt(pt.x, pt.y, Tx.RingSound, 0xFFFF00, false) > 100;
			music.stop();
			SBANK.ring().play(0.9, -0.7);
			if( win ) {
				500;
				fx.bigText(Tx.Win, 0xFFDF00, 2000);
				200>>SBANK.explosion02().play();
				SBANK.applause().play();
			}
			else {
				500;
				fx.bigText(Tx.TimeOut, 0xDE0748, 2000);
				200>>SBANK.explosionLong().play();
			}
			fx.surprise(teacher);
			teacher.jump(2);
			teacher.setDir(3);
			900;
			teacher.setDir(0);
			100;
			teacher.goto(Const.DESK) > end;
			teacher.setDir(0);
			200;
			teacher.say(Tx.T_AllowExit);
			300;
			if( helper!=null )
				helper.leave();
			for(s in students)
				s.sprite.filters = [];
			openDoor();
			ringRun();
			200 >> SBANK.crowd().play(0.4);
			600;
			shake(1, 2000);
			1000;
			teacher.setDir(3);
			800;
			teacher.setDir(0);
			500;
			teacher.say( win ? tg.m_endGameWin() : tg.m_endGameLose() );
			500;
			teacher.goto(Const.EXIT, 0.6);
			end("teacher");
			teacher.fl_visible = false;
			200;
			if( lightSources.get("neon") ) {
				setNeon(false);
				300;
			}
			teacher.setPos(teacher.cx-2, teacher.cy);
			teacher.fl_visible = true;
			200;
			closeDoor();
			200;
			teacher.gotoXY(teacher.cx, teacher.cy+8);
			500;
			if( Std.random(100)<10 && iso.Skully.CURRENT!=null ) {
				iso.Skully.CURRENT.saySomething();
				3500;
			}
			gotoUrl(cinit._extra._urlNext);
			99999;
		});
	}
	
	
	function death() { // Pêtage de cable
		lockActions = true;
		var t = teacher;
		function _allLook(dx:Int) {
			for(s in students)
				s.lookAt(dx,0);
		}
		cm.create({
			t.setCrazy(true);
			t.say(Tx.T_Death1);
			t.goto(Const.ACT_SPOT) > end;
			t.setDir(0);
			SBANK.explosion03().play();
			music.stop();
			SBANK.death02().play();
			100;
			// Charge
			SBANK.death01().play(0.7);
			t.setAnim(TA_ChargeStand);
			shake(1, 500);
			1300;
			t.setDir(2);
			shake(0.3, 4000);
			fx.dustCeil(200,100,200);
			100 >> fx.charge(t, 0x0);
			t.say(Tx.T_Death2);
			t.setAnim(TA_Crazy);
			2000;
			// Explosion
			t.setAnim(TA_CrazyPose);
			SBANK.deathCry01().play(0.2);
			t.say(Tx.T_DeathCry);
			300;
			fx.smokeNova(t.getFeet(), 0x0, 0.7, 0.7);
			SBANK.death03().play(0.4);
			fx.flashBang(1, 2000);
			for(s in students) {
				s.setAnim(SA_Surprise);
				s.pull(0, -Lib.rnd(0.1,0.3), Lib.irnd(100,300));
			}
			800>>SBANK.explosionLong().play();
			1700;
			for(s in students)
				s.pull(0, 0, 400);
			// Message game over
			800 >> fx.bigText(Tx.GameOver, 0xFF0000, 2000);
			1000 >> SBANK.explosion02().play();
			1000 >> fx.flashBang(0.7, 2000);
			// Fuit
			fx.smokeBomb(t, 0x0, -10);
			t.goto(Const.EXIT) > end;
			t.fl_visible = false;
			t.say();
			openDoor();
			for(s in students)
				s.lookAt(-1,0);
			400;
			// Coure dans le couloir
			t.setPos(Const.EXIT.x-2, Const.EXIT.y);
			t.fl_visible = true;
			100;
			t.say(Tx.T_DeathCry);
			t.gotoXY(t.cx, t.cy+5, 1.5) > end;
			t.say();
			400;
			600 >> _allLook(1);
			// Coure dans la rue
			t.setPos(Const.RWID+2, Const.RHEI+3);
			t.say(Tx.T_DeathCry);
			t.zpriority = 8;
			t.gotoXY(t.cx, -6) > end;
			for(s in students) {
				100;
				s.lookAt(-1,0);
			}
			500;
			for(s in students) {
				100;
				s.lookAt(1,0);
			}
			1000;
			fx.fadeOut(Const.SHADOW_COLOR, 1000);
			1000;
			gotoUrl(cinit._extra._urlNext);
			99999;
		});
	}
	
	
	function setPyjama() {
		var t = teacher;
		cm.create({
			//t.gotoXY(2,4) > end;
			//t.gotoXY(5,Const.RHEI-1) > end;
			100;
			t.setDir(1);
			//fx.smoke(t, 0xCED6E3, 1.5);
			200;
			t.setAnim(TA_PickUp);
			200>>SBANK.windTriple().play(0.3);
			500;
			fx.smokeBomb(t, 0xCED6E3);
			SBANK.explosion01().play();
			t.setAnim();
			t.setPyjama(true);
			900;
			t.say();
			//t.gotoXY(1,4) > end;
			//t.setDir(3);
			//200;
			//SBANK.click().play(0.6);
			//fx.word(teacher, Tx.LightSwitchNoise);
			//t.jump(2);
			//setHomeLight(false);
			//600;
			//t.setDir(1);
		});

	}
	
	
	function setTime(v:Int, ?anim=true) {
		var loss = oldTime>v;
		var r = Math.max(0, Math.min( 1, 1 - v/teacher.data.maxPa ));
		if( !anim ) {
			hud._top.y = -27 + 22 * r;
			hud._bottom.y = 18 - 22 * r;
		}
		else {
			var d = 800;
			hud._fall.visible = true;
			hud._fall.alpha = 0;
			hud._fall.scaleX = 0;
			delayer.add(function() {
				fx.sand( hud, hud._fall.x, hud._fall.y-2, Const.AP_TXT_COLOR );
			}, loss ? d*0.25 : d*0.8 );
			tw.create(hud._fall, "alpha", 1, TLoop, d);
			if( loss ) {
				hud._fall.scaleX = 0;
				tw.create(hud._fall, "scaleX", 1, TLoop, d);
			}
			else  {
				hud._fall.scaleX = 1;
				tw.create(hud._fall, "scaleX", 0, TEaseIn, d);
			}
			tw.create(hud._top, "y", -27 + 22 * r, TEase, d);
			tw.create(hud._bottom, "y", 18 - 22 * r, TEase, d);
		}
		oldTime = v;
	}
	
	function setLife(v:Int, ?anim=true) {
		var r = Math.max(0, Math.min(1, v/teacher.data.maxSelfControl));
		if( !anim ) {
			hud._white.visible = false;
			hud._maskFeu.scaleY = r;
		}
		else {
			var loss = hud._maskFeu.scaleY > r;
			if( !hud._white.visible ) {
				tw.terminate(hud._maskWhite);
				if( loss )
					hud._maskWhite.scaleY = hud._maskFeu.scaleY;
				else
					hud._maskWhite.scaleY = r;
			}
					
			tw.terminate(hud._white);
			hud._white.visible = true;
			hud._white.alpha = 1;
			
			if( loss ) {
				hud._white.transform.colorTransform = Color.getColorizeCT(0xFFC600, 1);
				tw.create(hud._maskFeu, "scaleY", r, TBurnIn, 300);
				tw.create(hud._white, "alpha", 0, TEaseIn, 1500).onEnd = function() hud._white.visible = false;
				tw.create(hud._maskWhite, "scaleY", r, TEase, 2500).onEnd = function() hud._white.visible = false;
				for(x in 0...4)
					fx.shineMC(hud, hud._white.x-10+x*7, hud._white.y+21-hud._maskWhite.height, 0xFFC600, 10);
			}
			else {
				hud._white.transform.colorTransform = Color.getColorizeCT(0xffffff, 1);
				hud._maskWhite.scaleY = r;
				hud._white.alpha = 0;
				tw.create(hud._white, "alpha", 1, TEaseOut, 400);
				tw.create(hud._maskFeu, "scaleY", r, TEaseIn, 1500).onEnd = function() hud._white.visible = false;
				for(x in 0...4)
					fx.shineMC(hud, hud._white.x-10+x*7, hud._white.y+21-hud._maskWhite.height, 0xffffff, 10);
			}
		}
		updateHud();
	}
	
	function setLockActions(b) {
		if( globalTimer!=null ) {
			globalTimer.wrapper.mouseChildren = globalTimer.wrapper.mouseEnabled = !b;
			globalTimer.wrapper.alpha = b ? 0.1 : 1;
		}
		if( homeCustomizer!=null )
			if( b )
				homeCustomizer.lock();
			else
				homeCustomizer.unlock();
		
		if( b==lockActions )
			return b;
			
		lockActions = b;
		setCine(b);
		if( b || sick )
			ActionBar.lockAll();
		else
			ActionBar.unlockAll();
			
		return b;
	}
	
	
	function playLog() {
		lockActions = true;
		if( logs.length==0 ) {
			onEndLog();
			return;
		}
		
		var l = logs.pop();
		//#if debugProtocol
		//	if (getFlashVar("protDebug")=="2")
		//		debug(l);
		//#end
		switch(l) {
			case L_TeacherAction(a, t, affected) :
				cm.create({
					if( at(Class) && a!=TAction.UseObject && a!=TAction.MoreSlots )
						teacher.goto(Const.ACT_SPOT) > end;
					doTeacherAction(true, a, t, affected);
				});
				
			case L_EndTeacherAction(a, c, t, affected) : //c = nouveau cooldown de l'action
				doTeacherAction(false, a, t, affected);
				
			case L_TeacherHit(sid, d, from, type) :
				var s = getStudent(sid);
				switch(from) {
					case SAction.Event_Chewing : cm.create( fx.word(s, "*chomp chomp*") > 500 );
					case SAction.Atk_Ps_6 : fx.teint(teacher, 0x93B54A, 0.7, 1500); // odeur
					default :
				}
				var txt = addSign(-d);
				if( type!=null )
					switch(type) {
						case Resist : txt = Tx.Resist;
						case Critic : txt+="!!";
					}
				cm.create({
					if( d>0 ) {
						pop(teacher, txt, Const.DMG_TXT_COLOR);
						if( !teacher.cd.has("hitSkip") ) {
							teacher.jump(1);
							fx.surprise(teacher, Const.ATK_TXT_COLOR);
							fx.blink(teacher, Const.ATK_TXT_COLOR);
							teacher.pull(0, 0.1, 150);
							Sfx.playOne([SBANK.teacherHit01, SBANK.teacherHit02]);
							SBANK.bigHit03().play(0.5);
							teacher.setAnim(TA_Hit) > 400;
							teacher.setAnim();
							teacher.pull(0,0, 150);
							350;
						}
					}
					else
						pop(teacher, txt, Const.BASE_TXT_COLOR, false);
				});
				
			case L_TeacherHeal(v) :
				var dx = teacher.hasAnim(TA_SitSofa) ? -15 : 0;
				var pt = teacher.isoToScreen();
				pt.x+=dx;
				cm.create({
					200>>SBANK.heal01().play(0.4);
					fx.shine(teacher, Const.HEAL_TXT_COLOR, dx);
					500;
					250>>SBANK.heal02().play(1);
					popAt(pt.x, pt.y, addSign(v), Const.HEAL_TXT_COLOR);
					500;
				});
				
			case L_TriggerObject(o, v, kill) :
				switch( o ) {
					case TObject.LangageAid :
						if( assistant!=null )
							cm.create({
								fx.slices(assistant, 3, Const.ATK_TXT_COLOR);
								100;
								pop(assistant, "-"+v, Const.ATK_TXT_COLOR);
								SBANK.bigHit01().play();
								assistant.jump(2);
								500;
								if( kill ) {
									fx.smokeBomb(assistant, 0x0, 8);
									100>>fx.smokeBomb(assistant, 0x0, 0);
									100>>fx.dotsExplosion(assistant, 0xFF0000, 1);
									SBANK.explosion02().play();
									assistant.destroy();
								}
							});
					default :
						debug("WARNING : unexpected L_TriggerObject "+o);
				}
		
			case L_LockObjects(b) : // TODO à supprimer ?
				lockObjects = b;
				//if( b )
					//invBar.lock();
					
			case L_SetHostile(sid, v, from) :
				var s = getStudent(sid);
				s.setHostile(v);
				s.data.hostile = v;
				//if( v )
					//cm.create({
						//1000;
						//fx.blink(s, 0xFFB300, 3, 600);
						//400;
						//fx.wordEvent(s, Tx.StatusHostile, 0xFFB300);
						//s.updatePose();
						//200;
					//});
				//else
				s.updatePose();
				onDataChange(s);
				
				
			case L_Dead :
				death();
				
			case L_Success :
				ring(true);
				
			case L_Ring :
				setTime(0);
				updateHud();
				ring(false);
				
			case L_SuperAttack(n) :
				teacher.setBuff(n>0);
				
			case L_Cooldown(actions) :
				for( ca in actions ) {
					var ba = getAction(ca.a);
					if( ba!=null )
						ba.cd = ca.c;
				}
				mainBar.updateActions();


			case L_ExtraReward(notes) : // Corriger copies (effet)
				var s : Student;
				cm.create({
					for (n in notes) {
						s = getStudent(n.sid) ;
						pop(teacher, s.data.firstname+" +"+noteDiv(n.r), s.speechColor, false);
						SBANK.levelUp().play(0.5);
						400;
						SBANK.write().play( Lib.rnd(0.1, 0.4) );
						jsUpdateMark(s.data.id, noteDiv(s.data.note + n.r)) ;
						500;
					}
				});



			case L_AvActions(actions, moreSlotsIndex, shuffle) :
				updateActionBars(actions) ;
				
				if(moreSlotsIndex>=0 ) {
					var alist = randBar.getVisibles();
					for(i in 0...alist.length) {
						if( i>=moreSlotsIndex )
							randBar.shuffleAnim(alist[i].value) ;
					}
				}
				else if( shuffle )
					randBar.shuffleAnim();


			case L_RerollHelpers(av) :
				teacher.data.avHelpers.cur = av ;
				updateActionBars(lastActions) ;

				for (h in av)
					mainBar.shuffleAnim(h) ;


			case L_ChooseHelper(h) :
				var bmp = getHelperPhoto(h);
				var tx = bmp.x;
				bmp.x = -bmp.width;
				function _phone() {
					fx.words(teacher, ["Bip"], 6, 2);
					for(i in 0...6)
						delayer.add( function() SBANK.bip02(Lib.rnd(0.05,0.12)), i*Lib.rnd(80,100) );
				}
				var str = switch(h) {
					case Helper.Director : Tx.HelperCall_Director;
					case Helper.Dog : Tx.HelperCall_Dog;
					case Helper.Eddy : Tx.HelperCall_Eddy;
					case Helper.Einstein : Tx.HelperCall_Tizoc;
					case Helper.Inspector : Tx.HelperCall_Inspector;
					case Helper.Peggy : Tx.HelperCall_Peggy;
					case Helper.Skeleton : Tx.HelperCall_Duke;
					case Helper.Supervisor : Tx.HelperCall_Supervisor;
				}
				var call = str.split("|");
				cm.create({
					teacher.setDir(2);
					teacher.setAnim(TA_Phone);
					200>>SBANK.windShort(0.2);
					700>>_phone();
					1600;
					teacher.say( call[0] );
					1000;
					teacher.setDir(1);
					400;
					fx.flashBang(0.5, 1400);
					teacher.say( call[1] );
					1000;
					SBANK.windLong().play(0.3, -0.5);
					tw.create(bmp, "x", tx, TBurnOut, 400).onEnd = function() {
						SBANK.explosion02(0.5);
						shake(1,400);
						cm.signal();
					};
					end;
					300;
					100>>SBANK.handUp01(1);
					announce( Tx.HelperCalled({_name:getHelperName(h)}) );
					600;
					teacher.setAnim(TA_PhoneOff);
					500;
					updateActionBars(lastActions) ;
				});


			case L_HelperMoveTo(c) :
				helper.fl_visible = true ;
				cm.create({
					helper.gotoXY(c._x, c._y);
					end;
					helper.setAnim("stand");
					helper.updateDir(1,0) ;
				}) ;

			case L_TriggerHelper(h, p) :
				switch( h ) {
					case Helper.Peggy :
						cm.create({
							fx.smallExplosion(helper, 0xFFFF00);
							helper.jump(2) ;
							helper.say(Tx.PeggyTriggered);
							500;
							for(sid in p)
								fx.rainDots(getStudent(sid), 0xFFFF00);
							1000;
						});
					case Helper.Director :
						var slist = Lambda.map(p, function(sid) return getStudent(sid));
						cm.create({
							helper.say(Tx.DirectorTriggered);
							shake(1.5, 600);
							500;
							for(s in slist) {
								fx.slices(s, 3, 0xFF0000);
								SBANK.studentHit01(0.7);
								200;
							}
						});
					case Helper.Skeleton : // duke
						cm.create({
							fx.chargeGround(helper, 0x62B0FF);
							500>>helper.say(Tx.DukeTriggered1);
							200>>SBANK.powerUp01(0.5);
							fx.blink(helper, 0xFFFF00, 4, 700);
							1200;
							shake(0.5, 800);
							fx.flashBang(0.2, 1000);
							fx.explosion(helper, 0x62B0FF);
							SBANK.explosion01(1);
							1000;
							helper.event(Tx.DukeTriggered2);
							1000;
						});
					case Helper.Eddy :
						cm.create({
							helper.say(Tx.EddyTriggered);
							500;
							fx.blink(teacher, 0xFFFFFF, 3, 800);
							800;
						});
					case Helper.Einstein : // Tizoc
						var c = 0x80FF00;
						cm.create({
							200;
							helper.gotoXY(teacher.cx-1, teacher.cy);
							end;
							teacher.setAnim();
							teacher.setDir(3);
							helper.say(Tx.TizocTriggered);
							fx.flashBang(0.3, 1000);
							100;
							fx.charge(helper, c);
							400>>teacher.setAnim(TA_PointCool);
							SBANK.powerUp03(1);
							1300;
							teacher.setAnim();
							fx.dotsExplosion(teacher, c, 0.5);
							SBANK.heal01(1);
							pop(teacher, "+3", c, false);
							fx.flashBang(0.3, 1000);
							1500;
							helper.leave();
							400;
							teacher.say(Tx.ThanksTizoc);
							800;
							teacher.setDir(2);
							200;
						});
					default:
						trace("TODO");
				}


			case L_SupervisorChoice(seats) :
				var s = seats.first();
				supervisorSeats = Lambda.array( seats.map(function(s) return {cx:s._x, cy:s._y}) );
				cm.create({
					helper.gotoXY(s._x, s._y, 0.6);
					end;
					helper.updateDir(0,1);
					200;
				});

				//### ### ### ### ### ### ### ### ### ###
				//
				//### TODO TODO TODO TODO TODO TODO TODO
				//
				//### ### ### ### ### ### ### ### ### ###
			
				
			case L_Bought(cost, a, o) :
				if( o!=null ) {
					var odata = Common.getObjectData(o, teacher.data.comps);
					var id = Type.enumIndex(o);

					var idx = 0 ;
					for (i in 0...odata.cost.length) {
						if (cost == odata.cost[i]) {
							idx = i ;
							break ;
						}
					}

					teacher.data.objects.get(id).stock+=odata.pack[idx];
					var l = new iso.Livreur();
					var pt = teacher.isoToScreen();
					function _onBuy() {
						updateActionBars(lastActions);
						randBar.lock();
						mainBar.lock();
						mainBar.shuffleAnim(id);
						mainBar.getAction(id).setHighlight(true);
						//jsUpdateGold(teacher.data.gold - cost) ;
					}
					
					switch( curPlace ) {
						case Class :
							cm.create({
								l.setPos(Const.EXIT.x-2, 0);
								l.gotoXY(Const.EXIT.x-2, Const.EXIT.y);
								end;
								l.updateDir(1,0);
								100;
								openDoor();
								teacher.setDir(3);
								100;
								l.fl_visible = false;
								300;
								l.setPos(Const.EXIT);
								l.fl_visible = true;
								l.gotoXY(teacher.cx-1, teacher.cy, 0.6);
								end;
								l.sayDelivered();
								900;
								teacher.setAnim(TA_PointCool);
								200;
								l.setPackage(false);
								_onBuy();
								300;
								teacher.setDir(1);
								teacher.setAnim(TA_Pocket);
								800 >> teacher.setAnim();
								900 >> teacher.setDir(0);
								400;
								l.ambiant();
								l.goto(Const.EXIT, 0.8);
								end;
								l.fl_visible = false;
								200;
								l.setPos(Const.EXIT.x-2, Const.EXIT.y);
								l.fl_visible = true;
								100;
								closeDoor();
								100;
								l.gotoXY(l.cx, l.cy-6);
								end;
								l.destroy();
							});
							
						case Home :
							l.setPos(-20,-20);
							cm.create({
								300;
								teacher.gotoXY(Const.EXIT.x+2, Const.EXIT.y) > end;
								teacher.setDir(3);
								l.setPos(Const.EXIT);
								l.gotoXY(Const.EXIT.x+1, Const.EXIT.y) > end;
								100;
								l.sayDelivered();
								800;
								if( !teacher.hasPyjama() )
									teacher.setAnim(TA_PointCool);
								300;
								l.setPackage(false);
								teacher.setDir(1);
								if( !teacher.hasPyjama() )
									teacher.setAnim(TA_Pocket);
								500 >> _onBuy();
								1000;
								SBANK.doorOpen().play();
								l.ambiant();
								l.goto(Const.EXIT) > end;
								l.fl_visible = false;
								300;
								SBANK.doorClose().play(0.5);
								l.destroy();
								300;
							});
							
						case HQ :
							l.setPos(-20,-20);
							cm.create({
								300;
								teacher.gotoXY(Const.EXIT.x, Const.EXIT.y+2) > end;
								teacher.setDir(0);
								openDoor();
								l.setPos(Const.EXIT);
								l.gotoXY(Const.EXIT.x, Const.EXIT.y+1) > end;
								100;
								l.sayDelivered();
								800;
								teacher.setAnim(TA_PointCool);
								300;
								l.setPackage(false);
								teacher.setDir(1);
								teacher.setAnim(TA_Pocket);
								500 >> _onBuy();
								1000;
								l.ambiant();
								l.goto(Const.EXIT) > end;
								l.destroy();
								100;
								closeDoor();
								300;
							});
					}
				}
				jsUpdateGold(teacher.data.gold - cost) ;

			case L_StudentSay(sid, what) :
				var s = getStudent(sid);
				lastQuestion = what;
				
				switch( what ) {
					case HW_Out(time) :
						cm.create({
							s.say(tg.m_out(), true) > 1000;
							query(teacher, [Tx.Yes, Tx.No], 50);
						});
						
					case HW_Question(l) :
						var answers = [];
						for(e in l)  {
							var desc = switch( e.give ) {
								case QR_State(st) : Common.getStateData(st).desc;
								default : null;
							}
							var sReward = switch(e.give) {
								case QR_Hit(n) : n==0 ? Tx.QR_NoEffect : Tx.QR_Hit({_n:n});
								case QR_State(st) : Tx.QR_State({_state:Common.getStateData(st).name}) ;
								case QR_Clean : Tx.QR_Clean ;
								case QR_Heal(n) : Tx.QR_Heal({_n:n});
							}
							answers.push({cost:e.life, txt:sReward, desc:desc}) ;
						}
						
						function _tuto() {
							var pt = curQuery.localToGlobal(new flash.geom.Point(0,0) );
							tuto.showOnce(Tx.Tuto_StudentReply, pt.x-20, pt.y-20, curQuery.width+40, curQuery.height+40);
						}
						cm.create({
							s.say(Tx.S_Question, true) > 1000;
							query(teacher, answers, 300);
							_tuto();
						});


					case HW_Heal(n) :
						cm.create({
							if( teacher.hat>0 )
								s.say(tg.m_hat());
							else
								s.say(Tx.HW_Heal);
							1500;
							SBANK.flux01().play(0.4);
							fx.projDots(s,teacher, Const.HEAL_TXT_COLOR);
							500;
						});
						
					case HW_Cheat(sid) :
						cm.create({
							s.say(Tx.HW_Cheat({_name : getStudent(sid).data.firstname})); //TODO
							1000;
						});

					case HW_Note :
						cm.create({
							s.say(Tx.HW_Note);
							500;
							fx.illuminate(s, 0x00FFFF);
							1500;
						});

				}
				
			case L_AddState(sid, st) :
				var data = Common.getStateData(st);
				var s = getStudent(sid);
				s.data.states.push(st);
				onDataChange(s);
				
				var buff = data.cleanable > 0;
				
				cm.create({
					fx.word(s, data.name, 0xffffff) > 300;
					switch(st) {
						case SState.Pet : // Devient chouchou
							s.setPet(true);
							mainBar.shuffleAnim(TAction.ChoosePet);
							SBANK.laugh02().play(0.5);
							500;
							showPetAction(s);
						case SState.Invisibility :
							//s.alpha = 0.2;
							//var a = tw.create(s.sprite, "alpha", 0.2, 1000);
							//a.onUpdate = s.invalidate;
							//a.onEnd = function() {
								//s.alpha = 0.2;
								//cm.signal();
							//}
							s.updatePose();
							600;
						case SState.Sulk : // Boude
							fx.word(s, "...");
							600;
						case SState.Angry : // énervé
							fx.cloud(s, 0x111317);
							fx.teint(s, 0xAC1313, 0.5, 1000);
							//s.shake(0.4, 500);
							200;
							s.updatePose();
							fx.cloud(s, 0x111317);
							1000;
							fx.papers(s, 6);
							s.jump(2);
						case SState.Speak : // bavarde / discute
							s.data.speakers = solver.getStudent(sid).speakers;
						default:
					}
					s.updatePose();
					if( buff )
						SBANK.buff().play(0.8);
					else
						SBANK.debuff02().play(0.5);
				});
				var pt = s.getGlobalCoords();
				if( data.cleanable > 0 )
					tuto.showOnce(Tx.Tuto_Buff, pt.x, pt.y+10);
				else
					tuto.showOnce(Tx.Tuto_Debuff, pt.x, pt.y+10);
				
			case L_RemoveState(sid, st) :
				var s = getStudent(sid);
				s.data.states.remove(st);
				s.waitingCpt = 0;
				onDataChange(s);
				cm.create({
					switch(st) {
						case SState.Pet :
							s.setPet(false);

						case SState.Invisibility :
							fx.smokeBomb(s, 0xE5E5E5);
							s.alpha = 1;
							s.sprite.blendMode = BlendMode.NORMAL;
							s.jump(1.5);
							s.updatePose();
							600;
						default :
					}
					s.updatePose();
				});
				
			case L_StudentResist(sid) :
				pop(getStudent(sid), "Resist!", Const.BASE_TXT_COLOR); // TODO vraiment utile ?
				
			case L_GrabItem(sid, oid, o) : // L'élève ramasse un objet de collection passé
				var s = getStudent(sid);
				var obj = iso.DroppedObject.get(oid);
				cm.create({
					s.lookAt(0,1);
					500;
					s.goto(obj.getPoint(), 1.5);
					end;
					s.updateDir(1,0);
					300;
					fx.word(s, Tx.S_PickUpCollectionItem);
					obj.destroy();
					300;
					s.seatBack();
				});
				
			case L_LaunchItem(oid, o, fid, tid, success) : // Passe un objet de collection
				var from = getStudent(fid);
				var ts = getStudent(tid);
				var col = Color.randomColor(from.rseed.rand(), 0.6, 0.7);
				
				// Point de chute
				var spots = [
					{x:-1,	y:1},
					{x:1,	y:1},
					{x:0,	y:-1},
					{x:-1,	y:-1},
					{x:1,	y:-1},
					{x:0,	y:0},
				];
				while( spots.length>0 && getPathCollision(tpf, ts.cx+spots[0].x, ts.cy+spots[0].y) )
					spots.splice(0,1);
					
				// Item au sol
				var obj = new iso.DroppedObject(ts.cx+spots[0].x, ts.cy+spots[0].y, o, oid, col);
				obj.fl_visible = false;
				
				// Lancer
				function _launch() {
					var target = success ? ts.getHead() : obj.getFeet();
					var p = new Projectile(from.getHead().x, from.getHead().y+6);
					sdm.add(p, Const.DP_FX);
					p.drawBox(5, 3, col);
					p.setTarget(target.x, target.y-1);
					p.speed = p.tdist()>40 ? 2 : 1;
					p.setLinear();
					p.onUpdate = function() {
						var d = Math.sin( p.progress()*3.14 ) * 20;
						p.y -= d;
						p.filters = [
							new flash.filters.GlowFilter(0x0,1, 2,2, 3),
							new flash.filters.DropShadowFilter(d,90, 0x0,1, 4,4,1)
						];
					}
					p.dr = (8+Std.random(5)) * (Std.random(2)*2-1);
					p.onEnd = function() {
						if( success )
							obj.destroy();
						else
							obj.fl_visible = true;
						cm.signal("projEnd");
						SBANK.drop01().play();
					}
				}
				cm.create({
					500;
					from.jump(2);
					if( !success ) {
						100 >> from.setAnim(SA_Surprise);
						500 >> fx.word(from, "Oops!"); // TODO trad
					}
					SBANK.windShort().play(0.5);
					_launch();
					end("projEnd");
					if( success ) {
						fx.surprise(ts);
						ts.setAnim(SA_Happy);
						ts.jump(2);
						600 >> ts.setAnim();
					}
					else {
						ts.setAnim(SA_Surprise);
						fx.surprise(ts);
						600 >> ts.setAnim();
					}
					from.setAnim();
				});
				
			case L_StudentGoOut(sid) : // Sort de la classe
				var s = getStudent(sid);
				cm.create({
					s.jump(1);
					500;
					s.goto(Const.EXIT, !s.cd.has("forceCry") ? 1.8 : 0.8) > end;
					s.sprite.scaleX = 1;
					openDoor() > 500;
					closeDoor(true);
				});
				
			case L_StudentGoBack(sid, isNew, withGift) : // Revient en classe
				var s = getStudent(sid);
				var t = teacher;

				

				var giftId = (withGift != null) ? Type.enumIndex(withGift) : -1 ;
				if (withGift != null)
					teacher.data.objects.get(giftId).stock+= 1 ;
				function _onGift() {
					updateActionBars(lastActions);
					randBar.lock();
					mainBar.lock();
					mainBar.shuffleAnim(giftId);
					mainBar.getAction(giftId).setHighlight(true);
				}
			
				cm.create({
					SBANK.knock().play(0.6, -0.7);
					fx.symbols(door.iso, Tx.DoorKnockSound, 3, true);
					300;
					t.setAnim();
					t.setDir(3);
					1000;
					openDoor() > 300;
					s.fl_visible = true;
					200 >> closeDoor();
					if( s.late ) {
						// Retard
						s.gotoXY(teacher.cx, teacher.cy-3) > end;
						s.updateDir(-1,0);
						teacher.setDir(0);
						200;
						teacher.gotoXY(teacher.cx, teacher.cy-1);
						end;
						teacher.setAnim(TA_Wait);
						600;
						note(s, tg.m_retard());
						end("message");
						SBANK.actionSelect().play();
						s.setAnim();
						200;
						teacher.say("...");
						200;
						s.say("...");
						600;
						teacher.setAnim(TA_PointCool);
						teacher.say();
						300;
						s.say();
						s.seatBack(0) > end;
						s.setStuffVisibility(true);
						teacher.setAnim();
						teacher.goto(Const.BOARD)>end;
						500;
						s.late = false;
					}
					else if( s.newbie ) {
						// Nouvel élève
						s.gotoXY(s.cx+1, s.cy);
						end;
						s.event(s.male() ? Tx.NewStudentAnnounceMale : Tx.NewStudentAnnounceFemale, 0x697D1A);
						s.updateDir(1,0);
						fx.charge(s, 0xB0D12C);
						1000 >> fx.blink(s, 0xCFFF9F, 8, 3000);
						SBANK.powerUp02().play(1, -0.6);
						1600;
						s.gotoXY(teacher.cx, teacher.cy-3) > end;
						s.updateDir(-1,0);
						s.setAnim(SA_Grin);
						teacher.setDir(0);
						200;
						teacher.gotoXY(teacher.cx, teacher.cy-1);
						end;
						teacher.setAnim(TA_Wait);
						600;
						
						if (withGift == null)  {
							message( Tx.NewStudent({_name:s.data.firstname}) );
							end("message");
							teacher.say( Tx.T_WelcomeNewStudent({_name:s.data.firstname}) );
							1500;
							teacher.say();
							teacher.setAnim(TA_PointCool);
							100;
							s.jump(2);
							fx.surprise(s);
							SBANK.studentHit01().play(0.5);
							300;
						} else {
							message( Tx.NewStudentWithGift({_name:s.data.firstname}) );
							end("message");
							400;
							s.say(Tx.GiveGift) ;
							1500 ;
							s.say() ;
							t.event(Common.getObjectData(withGift, teacher.data.comps).name, 0x3D2C5C);
							fx.blink(t, 0xFFD900, 4, 1000);
							_onGift() ;
							500;
							teacher.setDir(1);
							teacher.setAnim(TA_Pocket);
							800 >> teacher.setAnim();
							900 >> teacher.setDir(0) ;
							1000;

						}
						s.say();
						s.seatBack(0) > end;
						s.setStuffVisibility(true);
						teacher.setAnim();
						teacher.goto(Const.BOARD)>end;
						500;
						s.newbie = false;
					}
					else {
						s.seatBack(0) > end;
						500;
					}
				});

			case L_Gift(g, u) : //nothing to do => server side only

			case L_CornerStart(sid, extraHeal) : // Va au coin
				// TODO : new arg extraHeal
				var c =
					if( getStudentAt(Const.CORNER1.x, Const.CORNER1.y)==null ) Const.CORNER1
					else if( getStudentAt(Const.CORNER2.x, Const.CORNER2.y)==null ) Const.CORNER2
					else throw "too many corners!";
				cm.create({
					getStudent(sid).goto(c);
					1000;
				});

			case L_CornerEnd(sid) :
				cm.create({
					getStudent(sid).seatBack();
				});
				
			case L_SwapTo(sid, c) : // échange de place
				var s = getStudent(sid);
				
				function _nextSwap() { // lecture immédiate du swap suivant
					if( logs.length>0 && Type.enumIndex(logs.first())==Type.enumIndex(l) )
						playLog();
				}
				cm.create({
					s.data.seat = {x : c._x, y : c._y} ;
					s.setStuffVisibility(false);
					if( s.fl_visible ) {
						200>>_nextSwap();
						s.goto(s.data.seat, 0.5) > end;
						s.updateStuffPosition();
						s.setStuffVisibility(true);
						s.updatePose();
						500;
					}
					else
						_nextSwap();
				});


			case L_SwapTable(from, to, sid) :

				var table = furns.get("table#" + from._x + "," + from._y) ;
				if (table == null)
					debug("unknown table " + Std.string(from)) ;

				var chair = furns.get("chair#" + from._x + "," + from._y) ;

				chair.fl_visible = false;
				chair.setPos(to._x, to._y) ;
				setAllPathCollision(from._x, from._y+1, false);
				setAllPathCollision(to._x, to._y+1, true);
				
				var s : Student = sid!=null ? getStudent(sid) : null;
				
				function _finalize() {
					table.pull(0,0);
					table.setPos(to._x, to._y+1);
					table.zpriority = 0;
					chair.fl_visible = true;
					if ( s!=null ) {
						s.canSit = true;
						cm.create({
							s.data.seat = {x : to._x, y : to._y} ;
							s.setStuffVisibility(false);
							if( s.fl_visible ) {
								s.goto(s.data.seat, 0.5) > end;
								s.updateStuffPosition();
								s.setStuffVisibility(true);
								s.updatePose();
								500;
							}
						});
					}
				}
				
				cm.create({
					if( s!=null ) {
						s.canSit = false;
						s.updatePose();
					}
					table.zpriority = 1;
					table.pull(0, 2, 1800);
					SBANK.chairDrag().play();
					1800>>SBANK.drop01().play();
					2000;
					_finalize();
				});
				
				furns.remove("table#" + from._x + "," + from._y) ;
				furns.remove("chair#" + from._x + "," + from._y) ;

				furns.set("table#" + to._x + "," + to._y, table) ;
				furns.set("chair#" + to._x + "," + to._y, chair) ;


			case L_SelfControl(d, from) :
				if( !at(Class) && d<0 )
					cm.create({
						//if( d>0 )
							//fx.shine(teacher, Const.HEAL_TXT_COLOR);
						pop(teacher, addSign(d), Const.HEAL_TXT_COLOR);
						500;
					});
				teacher.data.selfControl+=d;
				teacher.setTired( teacher.data.selfControl<teacher.data.maxSelfControl*0.5 );
				//life.tween(teacher.data.selfControl);
				setLife(teacher.data.selfControl);
				if(!sick && teacher.data.selfControl<=5 ) {
					var pt = getPotionCoordinates();
					if( pt!=null )
						gameTip("theal", pt.x, pt.y-10, Tx.Tip_UsePotion);
				}
				
			case L_TeacherReplay :
				announce(Tx.AnnouncePlayAgain, 0xBFFF00);


			case L_GoToIll :
				cm.create({
					teacher.setDir(1) ;
					teacher.jump(2) ;
					fx.surprise(teacher);
					teacher.setTired(true) ;
					1000;
					teacher.say( Tx.T_GoToIll);
					2000;
					if (at(Home)) {
						setPyjama();
						800;
						teacher.gotoXY(1,4);
						end;
						teacher.pull(0.65, -0.1, 250);
						250;
						teacher.setDir(2);
						250;
						teacher.setShadow(false);
						teacher.setAnim(TA_Bed);
					} else  {
						teacher.goto(Const.EXIT) > end;
						openDoor();
						teacher.fl_visible = false;
						500;
						closeDoor();
					}
					gotoUrl("/");
					
					999999;
				});
				
			case L_Time(d, from) :
				boughtSlotsRecently = false;
				//if( !at(Class) )
					//cm.create({
						//if( d>0 )
							//fx.shine(teacher, AP_TXT_COLOR);
						//pop(teacher, addSign(d), AP_TXT_COLOR);
						//500;
					//});
				teacher.data.pa+=d;
				if( teacher.data.pa<=3 && at(Class) )
					gameTip("ttime", 605, 290, Tx.Tip_TimeWarning({_n:3}));
				if( !at(Class) && teacher.data.pa<=0 )
					randBar.visible = false;
				
			case L_XP(sid, n) :
				cm.create({
					if( sid!=null ) {
						100 >> SBANK.flux01().play(0.2);
						fx.projDots(getStudent(sid), teacher, 0xACFF00);
					}
					800;
					fx.xp(teacher, n);
					200>>SBANK.xp().play();
					jsAddXp(n);
					//fx.smallExplosion(teacher, 0xACFF00);
					700;
				});
				
				
			case L_StudentHit(sid, dl, db, type, from, by, newNote) :
				var s = getStudent(sid);
				s.data.life-=dl;
				s.data.boredom-=db;
				var gain = newNote==null ? 0. : newNote - s.data.note;
				onDataChange(s);
				cm.create({
					if( from!=null )
						switch( from ) {
							case SAction.Atk_Ps_6 :
								fx.teint(s, 0x93B54A, 0.7, 1500) > 700; // odeur
							default :
								fx.blink(s, Const.ATK_TXT_COLOR, 1, 500);
						}
					if( dl>0 ) {
						fx.illuminate(s, Const.LEARN_TXT_COLOR);
						Sfx.playOne([SBANK.studentHit01, SBANK.studentHit02, SBANK.studentHit03]);
					}
					s.bar.life = s.data.life;
					s.bar.resist = s.data.boredom;
					s.bar.update();
					if( type!=null )
						switch( type ) {
							case Resist : fx.wordEvent(s, Tx.Resist, 0xFF9300);
							case Critic : fx.wordEvent(s, Tx.Critic, 0x0AD2F5);
						}
					if( dl!=0 || db!=0 )
						350;
					else
						150;
					if( newNote!=null ) {
						doneAnim(s, gain);
						500;
					}
				});
				if( newNote!=null ) {
					var pt = s.getGlobalCoords();
					tuto.showOnce(Tx.Tuto_Done1, pt.x,pt.y+20);
					tuto.showOnce(Tx.Tuto_Done2, pt.x,pt.y+20);
				}
				
				
			case L_HandUpStart(sid, what) : // Lève la main
				var s = getStudent(sid);
				cm.create({
					s.data.handUp = {hostile:false, what:what, k : 0}
					s.updatePose();
					s.jump(2);
					Sfx.playOne([SBANK.handUp01, SBANK.handUp02, SBANK.handUp03]);
					fx.airWaveVertical(s);
					400;
					s.say( tg.m_mister() );
				});
				//var tf = createField("?", FBig, true);
				//tf.textColor = mt.deepnight.Color.capInt(s.speechColor, 1, 0.3);
				//tf.x = Std.int(-tf.textWidth*0.5)-2;
				//tf.y = Std.int(-tf.textHeight*0.5)-2;
				var mc = tiles.getSprite("mouse");
				mc.playAnim("left");
				mc.setCenter(0.5,0.5);
				var bt = s.addSideButton(mc);
				bt.addEventListener(flash.events.MouseEvent.CLICK, function(_) {
					if( lockActions )
						return;
					s.removeButton();
					sendAction(TAction.What, [AT_Std(s.data.id)]);
				});
				var pt = s.getGlobalCoords();
				tuto.showOnce(Tx.Tuto_StudentQuestion1, pt.x, pt.y+30);
				tuto.showOnce(Tx.Tuto_StudentQuestion2, pt.x-25, pt.y+30, 25);
				
			case L_HandUpEnd(sid) :
				var s = getStudent(sid);
				s.removeButton();
				cm.create({
					s.data.handUp = null;
					s.updatePose();
					350;
				});
				
			case L_SetBoredom(sid,v, byUpdate) :  // Ennui
				var s = getStudent(sid);
				if( s.data.boredom!=v ) {
					cm.create({
						if( v<s.data.boredom )
							Sfx.playOne([SBANK.studentHit01, SBANK.studentHit02, SBANK.studentHit03]);
						else
							SBANK.debuff03().play();
						s.bar.resist = v;
						s.bar.update();
						s.data.boredom = v;
						onDataChange(s);
						350;
					});
				}
				/*
				var old = s.data.boredom ;
				var nw = v ;

				cm.create({
					if( old<nw ) {
						s.jump(1);
						fx.attention(s, true);
						fx.blink(s, 0xB1E930, 1, 1000);
					}
					else {
						fx.attention(s, false);
						fx.blink(s, 0xF84121, 1, 1000);
					}
					s.data.boredom = v;
					onDataChange(s);
					250;
					s.updatePose();
					200;
				});
				*/
				
			case L_ExerciceEnd(sid) :
				getStudent(sid).updatePose();
					
			case L_StudentAction(sid, a, t) :
				doStudentAction(getStudent(sid), a, t, true);
				
			case L_EndStudentAction(sid, a,t) :
				doStudentAction(getStudent(sid), a, t, false);
				
			case L_Wait(end) :
				if( at(Home) && !photoMode && globalTimer==null )
					cm.create({
						teacher.say(tg.m_endOfDay());
						1000;
						setPyjama();
						setGlobalTimer(end, true);
					});
					
				if( at(HQ) && globalTimer==null )
					setGlobalTimer(end, true);
				
			case L_Error(e) :
				cm.create({
					SBANK.error01().play();
					switch(e) {
						case SE_Invalid(e) :
							message( switch(e) {
								case _Err_ActionUnavailable(a): Tx._Err_ActionUnavailable({_name:Common.getTActionData(a).name});
								case _Err_CantMoveTable: Tx._Err_CantMoveTable;
								case _Err_CantSwapEmptySeats: Tx._Err_CantSwapEmptySeats;
								case _Err_CantSwapUnavailableStudent: Tx._Err_CantSwapUnavailableStudent;
								case _Err_CantTargetPet: Tx._Err_CantTargetPet;
								case _Err_CantUseObjectHere : Tx._Err_CantUseObjectHere;
								case _Err_NotEnoughMoney: Tx._Err_NotEnoughMoney;
								case _Err_ObjectUnavailable: Tx._Err_ObjectUnavailable;
								case _Err_StudentUnavailable: Tx._Err_StudentUnavailable;
								case _Err_UselessAction: Tx._Err_UselessAction;
								case _Err_UselessHeal: Tx._Err_UselessHeal;
								case _Err_NoMidLife: Tx._Err_NoMidLife;
							});
							
						case SE_Fatal(desc) :
							fatalError = true ;
							message( Tx.FatalError({_desc:desc}) );
					}
					1000;
				});
				
			default :
		}
		if( cm.isEmpty() )
			playLog();
	}
	
	
	function getTargetStudent(tlist:List<AcTarget>, ?skip=0) {
		for(t in tlist)
			switch( t ) {
				case AT_Std(i) : if( skip--<=0 ) return getStudent(i);
				default :
			}
		return null;
	}
	function getTargetNum(tlist:List<AcTarget>, ?skip=0) {
		for(t in tlist)
			switch( t ) {
				case AT_Num(i) : if( skip--<=0 ) return i;
				default :
			}
		return -1;
	}
	function getTargetPt(tlist:List<AcTarget>, ?skip=0) {
		for(t in tlist)
			switch( t ) {
				case AT_Coord(pt) : if( skip--<=0 ) return pt;
				default :
			}
		return null;
	}
	
	function doTeacherAction(start:Bool, a:TAction, tlist:List<AcTarget>, affectedList:Null<List<AcTarget>>) {
		if( affectedList==null )
			affectedList = new List();
		var targets = Lambda.array(tlist);
		var t = teacher;
		if( start ) {
			t.setAnim();
			t.say();
			if( at(Class) )
				setFocus(t);
		}
		var s = getTargetStudent(tlist);
		var num = getTargetNum(tlist);
		var pt = getTargetPt(tlist);
		
		var affected = Lambda.map(affectedList, function(tg) {
			switch( tg ) {
				case AT_Std(id) : return getStudent(id);
				default : return null;
			}
		});
		
		//if( start && s!=null )
			//cm.create({
				//s.event(Common.getTActionData(a).name, 0x0F3A71);
				//700;
			//});
		
		var lineStudents = function(i) {
			var list = [];
			for( s in students )
				if( s.data.seat.y==i && s.atSeat() )
					list.push(s);
			return list;
		}
		
		var resetTeacher = true;
		switch( a ) {
			case TAction.Swap : // Déplacement d'élève (échange)
				var pt1 = pt;
				var pt2 = getTargetPt(tlist,1);
				var slist : Array<Student> = [];
				if( getStudentAt(pt1._x, pt1._y)!=null ) slist.push(getStudentAt(pt1._x, pt1._y));
				if( getStudentAt(pt2._x, pt2._y)!=null ) slist.push(getStudentAt(pt2._x, pt2._y));
				var s1 = slist[0];
				var s2 = slist[1];
				if( start ) {
					var spt1 = Iso.isoToScreenStatic(pt1._x, pt1._y);
					var spt2 = Iso.isoToScreenStatic(pt2._x, pt2._y);
					cm.create({
						fx.hit(spt1.x-5, spt1.y+20, 0x8080FF);
						fx.risingDots(spt1.x-5, spt1.y+25, 0x8080FF);
						100;
						fx.hit(spt2.x-5, spt2.y+20, 0x8080FF);
						fx.risingDots(spt2.x-5, spt2.y+25, 0x8080FF);
						SBANK.windShort().play();
						t.setAnim(TA_PointCool);
						for(s in slist) {
							s.jump(2);
							SBANK.handUp02().play();
							200;
						}
						200;
						if( slist.length==1 ) {
							t.say( Tx.T_SwapOneStudent({_name:s1.data.firstname}) );
							400;
						}
						if( slist.length==2 ) {
							t.say( Tx.T_SwapTwoStudents({_name1:s1.data.firstname, _name2:s2.data.firstname}) );
							600;
						}
						t.setAnim(TA_Wait);
					});
				}
				else
					cm.create({
						for( s in slist )
							s.updatePose();
						t.setAnim();
						200;
					});
					
			case TAction.MoreSlots :
				boughtSlotsRecently = true;
				if( start )
					cm.create({
						t.setDir(1);
						t.setAnim(TA_Pocket);
						500;
						t.setAnim(TA_Listen);
						//t.setAnim(TA_PointCool);
						//fx.airWave(t, t.getDir());
						//600;
					});
				else
					cm.create({
						1000;
					});
				
			case TAction.MoreAttention, TAction.BestMoreAttention : // Concentration
				if( start ) {
					var ss = solver.getStudent(s.data.id);
					var sides = Lambda.filter(solver.studentNear(ss), function(n) { return n.seat.y == ss.seat.y && n.canBeTargeted() ;}) ; // blah, pas propre :(
					var sides = Lambda.map(sides, function(ss) return getStudent(ss.id));
					var c = 0xE70C9A;
					cm.create({
						t.say(Tx.T_Concentrate);
						500;
						t.setAnim(TA_PointCool);
						300;
						fx.airWave(t, 0);
						fx.palmLight(t, c, 0, 10);
						100;
						fx.multiHits(s, 6, c);
						500;
						t.setAnim(TA_Wait);
						
						for(ns in affected)
							fx.blink(ns, c, 5, 1000);
						
						for(ns in affected) {
							ns.setAnim(SA_Write);
							fx.sacredHalo(ns, c);
							SBANK.powerUp04().play();
							ns.jump(2);
							800;
						}
						200;
						for(ns in affected)
							ns.updatePose();
					});
				}
					
			case TAction.What : // Question
				if( start )
					cm.create({
						t.goto({x:Const.BOARD.x, y:Const.BOARD.y-1});
						t.say( Tx.T_What({_name:s.data.firstname}) ) > 500;
					});
				else {
					cm.create({1000;});
					resetTeacher = false;
				}
				
			case TAction.Grab : // Le prof ramasse un objet de collection
				if( start ) {
					//var obj = iso.DroppedObject.ALL.first();
					var obj = iso.DroppedObject.get(num) ;
					cm.create({
						t.goto(obj.getPoint(), 1.5);
						end;
						t.setDir(1);
						200;
						t.setAnim(TA_PickUp);
						200;
						obj.destroy();
						SBANK.grabItem().play();
						t.event(obj.getObjectName(), 0x3D2C5C);
						fx.blink(t, 0xFFD900, 4, 1000);
						1000;
						t.setAnim();
						100;
						t.setDir(2);
						1000;
						t.say(tg.m_pickUpObject());
						1000;
					});
				}
				
			case TAction.Buy : // Achat
				if( start ) {
					var odata = Common.getObjectData( Type.createEnumIndex(TObject,num), teacher.data.comps );
					cm.create({
						if( at(Class) || at(Home) ) {
							t.setDir(3);
							300;
							if( !t.hasPyjama() ) {
								t.pull(-0.2, 0);
								t.setAnim(TA_Point);
								fx.airWave(t, teacher.getDir());
							}
						}
						else {
							t.setDir(0);
							300;
							t.pull(0, -0.2);
							t.setAnim(TA_Point);
							fx.airWave(t, teacher.getDir());
						}
						200;
						t.say(Tx.T_Exclamation({_word:odata.name}));
						600;
						t.pull(0, 0, 200);
						100;
						t.setAnim();
					});
				}
				
				
			case TAction.WakeUp :
				throw "obsolete"; // TODO à supprimer
				
			case TAction.StartLesson :
				if( start )
					cm.create({
						t.goto(Const.EXIT) > end;
						openDoor();
						t.fl_visible = false;
						500;
						closeDoor();
						gotoUrl( cinit._extra._urlNext );
					});
				
			case TAction.Rest : // Se reposer (chez soi)
				var sofa = furns.get("sofa");
				if( start )
					cm.create({
						t.goto(sofa.getStandPoint()) > end;
						t.setDir(2);
						t.pull(0, -0.3, 100);
						100;
						t.setAnim(TA_UpSofa);
						300;
						t.setDir(1);
						t.setAnim(TA_SitSofa);
						200>>t.setShadow(false);
						t.pull(0.2, -1.2, 300);
						1000;
					});
				else {
					cm.create({
						600;
						t.setDir(2);
						t.pull(-0.5, -0.7);
						t.pull(-0.1, -0.5, 200);
						t.setAnim(TA_UpSofa);
						200>>t.setShadow(true);
						200;
						t.pull(0,0,100);
						t.setAnim();
						200;
					});
				}
				
			case TAction.Coffee : // Se reposer (salle des profs)
				var sofa = furns.get("sofa");
				if( start )
					cm.create({
						t.goto(sofa.getStandPoint());
						end;
						t.setDir(1);
						200;
						t.setAnim(TA_SitSofa);
						200>>t.setShadow(false);
						300>>SBANK.teacherHit01().play(0.3);
						1000;
					});
				else
					cm.create({
						600;
						t.setDir(1);
						t.pull(-0.5, 0.2);
						t.pull(-0.1, 0.2, 200);
						t.setAnim(TA_UpSofa);
						200>>t.setShadow(true);
						200;
						t.pull(0,0,100);
						t.setAnim();
						200;
					});
				
			case TAction.HBonusReward, TAction.SRBonusReward : // Corriger des exercices
				if( start )
					cm.create({
						if( at(Home) )
							t.gotoXY(5,3) > end;
						else
							t.gotoXY(2,5) > end;
						t.setDir(2);
						100;
						200 >> t.setDir(1);
						t.zpriority = 1;
						if( at(HQ) ) {
							t.pull(0.2, 0.8, 500);
							500;
							t.pull(0.4, 1, 150);
							200;
						}
						else {
							t.pull(0.3, 1, 500);
							500;
							t.pull(0.5, 1.2, 200);
							200;
						}
						t.setAnim(TA_Pocket);
						400;
						t.setAnim(TA_WriteDesk);
						SBANK.write().play(0.3);
						t.setShadow(false);
						t.zpriority = 2;
						200;
					});
				else
					cm.create({
						500;
						t.zpriority = 1;
						t.setShadow(true);
						t.setAnim(TA_Pocket);
						800;
						t.setAnim();
						t.pull(0,0, 600);
						200 >> t.setDir(0);
						600;
						t.zpriority = 0;
						checkMissionDone() ;
					});
					
			case TAction.SRMoreXp, TAction.HMoreXp : // Partager son expérience
				var chair = furns.get("deskChair");
				if( start )
					cm.create({
						t.goto( chair.getStandPoint() ) > end;
						SBANK.windShort().play(0.2);
						chair.pull(0, 0.65, 500);
						setPathCollision(tpf, chair.cx, chair.cy, false);
						t.goto(chair.getPoint()) > end;
						t.setDir(0);
						chair.zpriority = 10;
						SBANK.windShort().play(0.1);
						chair.pull(0, 0.4, 100);
						100;
						chair.fl_visible = false;
						t.setAnim(TA_Type);
						100;
						SBANK.keyboard().play(0.5);
						1200 >> SBANK.keyboard().play(0.5);
						fx.symbols(t, Tx.KeyboardTypeSound, 8, true, 34);
						1800;
					});
				else
					cm.create({
						600;
						chair.zpriority = 0;
						chair.pull(0,0.5);
						SBANK.windShort().play(0.2);
						chair.fl_visible = true;
						500 >> SBANK.windShort().play(0.1);
						500 >> chair.pull(0,0, 300);
						t.goto( chair.getStandPoint(), 1.2 ) > end;
						setPathCollision(tpf, chair.cx, chair.cy, true);
						checkLevelUp() ;
					});
				
			case TAction.Answer :
					if( start ) {
						removeQuery();
						s.data.handUp = null;
						s.say();
						if( lastQuestion!=null )
							switch( lastQuestion ) {
								case HW_Question(_) : // Réponse question
									cm.create({
										if( num==0 ) {
											t.say(Tx.T_DontKnow) > 500;
											s.updatePose() > 500;
											t.back()>end;
											t.setAnim(TA_WriteBoard);
											400;
											s.say("...");
											1000;
										}
										else {
											t.setAnim(TA_Explain);
											SBANK.powerUp05().play(0.3);
											fx.words(t, [Tx.T_Speach], 5, 1)>800;
											s.setAnim(SA_Write) > 1200;
											fx.smallExplosion(s, Const.LEARN_TXT_COLOR);
											SBANK.teacherAttack02().play();
											s.updatePose();
										}
									});
								case HW_Out(_) : // Réponse pour sortir
									cm.create({
										if( num==0 ) {
											t.say(Tx.T_Accept);
											700;
											s.setAnim(SA_Happy);
											SBANK.laugh03().play(0.5);
										}
										else {
											t.say(Tx.T_Refuse);
											700;
										}
									});
								default :
							}
					}
				
			case TAction.GoToBoard:
				if( start ) {
					function _listen() {
						cm.create({
							t.setAnim();
							200;
							t.goto( {x:Const.DESK.x-1, y:Const.DESK.y} )>end;
							t.setDir(1);
							100;
							t.setAnim(TA_Listen);
						});
					}
					cm.create({
						t.goto(Const.ACT_SPOT) > end;
						t.setDir(0);
						200;
						t.setAnim(TA_PointCool);
						100;
						t.say(Tx.T_ToTheBoard({_name:s.data.firstname})) > 800;
						_listen();
						500;
						s.goto(Const.BOARD) > end("student");
						s.setAnim(SA_Talk);
						1200;
					});
				}
				else {
					cm.create({
						t.setAnim(TA_Good);
						1200 >> t.setAnim();
						100;
						t.say(Tx.T_AllRight);
						1000;
						s.setAnim();
						s.seatBack() > 200;
						500;
						t.back();
						end("student");
					});
				}
					
			case TAction.HardTeach, TAction.HardTeach_0, TAction.HardTeach_1, TAction.BigHardTeach : // Hurler le cours
				if( start ) {
					var x = num ;
					cm.create({
						t.goto({x:x, y:Const.RHEI-2}, 1.5) > end;
						100;
						t.setDir(0);
						300;
						fx.chargeGround(teacher, 0xFF6C00);
						if( a==TAction.BigHardTeach )
							SBANK.powerUp03().play();
						else
							SBANK.powerUp01().play();
						200;
						shake(0.3, 1000);
						t.setAnim(TA_ChargeFloat);
						100;
						fx.chargeBall(t.getHead().x-10, t.getHead().y+3, 32, 0xFA2B05, 1.5);
						fx.chargeBall(t.getHead().x+4, t.getHead().y+6, 32, 0x0393FC, 1.5);
						t.pull(0, -0.1, 300);
						700;
						t.say(Tx.T_BigAttack) > 300;
						t.pull(0, -0.4, 100);
						t.setAnim(TA_DoublePalm);
						if( a==TAction.BigHardTeach )
							SBANK.explosionLong().play();
						else
							SBANK.explosion03().play();
						fx.palmLight(t, 0x00FFFF);
						fx.column(x, 1,teacher.cy-1, a==TAction.BigHardTeach ? 0xFF8000 : 0x00FFFF);
						fx.flashBang(0.1, 1000);
						//fx.airWave(t, t.getDir());
						shake(1,600);
						700;
						t.pull(0, 0, 250);
						t.setAnim();
					});
				}
					
			case TAction.Clean, TAction.Clean_0, TAction.Clean_1 : // Rappel à l'ordre (aka. Ta gueule)
				if( start ) {
					function _launch() {
						var pr = fx.projLaunch(t, s, 0xFFFFFF, 5,2, 0.5);
						pr.speed = 4;
						pr.onEnd = function() {
							fx.projHit(pr);
							cm.signal("projEnd");
						}
					}
					var c = 0x70DF00;
					cm.create({
						//t.setDir(0);
						//t.gotoXY(t.cx, t.cy-1) > end;
						fx.chargeGround(t, c);
						300;
						fx.smokeNova(t.getFeet(), 0x9EADC7, 1.0, true);
						100;
						t.setAnim(TA_Charge);
						100;
						fx.flashBang(0.1, 1500);
						//fx.chargeBall(t.getHead().x-8, t.getHead().y+1, 30, c, 0.7);
						fx.chargeBall(t.getHead().x+8, t.getHead().y+3, 30, c, 0.9);
						SBANK.powerUp03().play();
						t.pull(0, -0.1, 400);
						1000;
						t.pull(0, -0.5, 200);
						t.setAnim(TA_Palm);
						fx.flashBang(0.5, 500);
						fx.palmLight(t, c, 20,0);
						t.say( Tx.T_Exclamation({_word:s.data.firstname}) );
						fx.airWave(t, 0);
						100;
						_launch();
						//100 >> s.setAnim(SA_Surprise);
						end("projEnd");
						SBANK.projHit().play();
						SBANK.studentHit03().play();
						fx.flashBang(0.3, 200);
						shake(1.5, 600);
						//s.setAnim(SA_Surprise);
						fx.surprise(s);
						s.pull(0, -0.2, 100);
						s.jump(2.5);
						s.setAnim(SA_Surprise);
					});
				}
				else {
					cm.create({
						s.updatePose();
						400 >> s.pull(0, 0, 400);
						600 >> t.setAnim();
						700 >> t.pull(0,0, 200);
					});
					cm.create(1000);
				}
						
			case TAction.MathBump :
				if( start )
					cm.create({
						t.setAnim(TA_DoublePalm);
						fx.airWave(t, t.getDir());
						300;
						fx.smokeBomb(s, 0xB3C0CE);
						SBANK.bigHit01().play();
						fx.slices(s, 3, 0x8080C0);
						shake(1, 500);
					});
						
			case TAction.BigClean, TAction.OtherBigClean :
				if( start )
					cm.create({
						t.setAnim(TA_DoublePalm);
						fx.airWave(t, t.getDir());
						300;
						for(s in affected) {
							fx.rainLines(s, 0xFF6600);
							200;
							SBANK.bigHit04().play(0.7);
							fx.flashBang(0.5, 300);
							100;
						}
					});
					
					
			case TAction.Cogitate :
				if( start ) {
					cm.create({
						t.setDir(0) > 500;
						s.setAnim(SA_Surprise);
						s.jump(2);
						500;
						fx.projDots(t,s, Const.LEARN_TXT_COLOR, 40);
						1000;
						s.setAnim(SA_Write);
						200;
						fx.shine(s, Const.LEARN_TXT_COLOR);
						800;
						t.setDir(2);
					});
				}
				
			case TAction.ChoosePet :
				if( start )
					cm.create({
						t.setAnim(TA_PointCool);
						400;
						s.jump(2);
						s.setAnim(SA_Happy);
						SBANK.handUp03().play();
						600;
						SBANK.powerUp02().play();
						fx.explosion(s, 0xFFFF00, 0.5);
						300>>fx.blink(s, 0xFFFF00, 5, 1000);
						200;
					});
				else
					s.updatePose();
				
			case TAction.LifeTransfer :
				if( start )
					t.setAnim(TA_Palm);
				else
					cm.create({
						fx.projDots(t, s, 0x54B87E);
						fx.projLines(s, t, 0xDB2456);
						1000;
					});
				
			case TAction.Exercice :
				if( start ) {
					cm.create({
						t.setDir(0)>500;
						t.say(Tx.T_Exercice);
						for( s in students )
							s.jump(2)>50;
						1000;
						for( s in students )
							s.updatePose()>100;
					});
				}
				
			case TAction.Projector :
				if( start ) {
					cm.create({
						t.say(Tx.T_Projector1);
						1200;
						t.setDir(1);
						100;
						t.setDir(2);
						300;
						t.setAnim(TA_PointCool);
						fx.crossFade(0x0, 1200, 200);
						1200;
						t.say();
						t.setAnim(TA_Listen);
						1400;
						t.setAnim();
						t.setDir(1);
						100;
						t.setDir(0);
						t.say(Tx.T_Projector2);
						1000;
					});
				}
				
			case TAction.Exam :
				if( start ) {
					cm.create({
						t.setDir(0)>500;
						t.say(Tx.T_Punishment1);
						t.setAnim(TA_ChargeStand);
						fx.explosion(t, 0xFF0000);
						1000;
						t.setAnim(TA_DoublePalm);
						t.say(Tx.T_Punishment2);
						shake(1,500);
						fx.flashBang(0.4, 500);
						for( s in students ) {
							s.setAnim(SA_Surprise);
							s.jump(3);
							100;
						}
						1000;
						500 >> t.setAnim();
						for( s in students )
							s.setAnim(SA_Write);
						300;
					});
				}
				else
					cm.create({
						300;
						for( s in students )
							s.updatePose();
					});
				
			case TAction.Smite : //
				if( start ) {
					cm.create({
						s.lookAt(0,0);
						fx.words(t, [Tx.T_Speach], 5, 1);
						t.setAnim(TA_Explain);
						1000;
						t.setAnim(TA_Palm);
						fx.airWave(t, 0);
						fx.palmLight(t, 0x60FF00, 4, 20);
						SBANK.teacherAttack03().play();
						300>>SBANK.teacherAttack02().play();
						200;
						SBANK.bigHit01().play();
						s.lookAt(1,0);
						s.pull(0.2, 0);
						fx.slices(s, 1);
						fx.flashBang(0.25,500);
						s.setAnim(SA_Surprise);
						300;
						SBANK.bigHit02().play();
						s.lookAt(-1,0);
						s.pull(-0.1, 0);
						fx.slices(s, 1);
						fx.flashBang(0.5,500);
						t.setAnim(TA_ChargeStand);
					});
				}
				else
					cm.create({
						s.pull(0,0, 200);
						s.lookAt(0,0);
						s.updatePose();
					});
			case TAction.Teach, TAction.BigTeach : // Enseigner / Apprentissage avancé
				if( start ) {
					var c = a==TAction.Teach ? 0x10EFEA : 0xFF0000;
					cm.create({
						t.setAnim(TA_Explain);
						t.setDir(0) > 500;
						fx.symbols(t, Tx.T_Speach, 3, true, 0,-25);
						400;
						fx.airWave(t, 0);
						t.setAnim(TA_Point);
						fx.palmLight(t, c);
						SBANK.teacherAttack04().play();
						t.pull(0 ,-0.3, 500);
						shake(0.5, 200);
						150;
						300 >> t.setAnim();
						for(ns in affected) {
							ns.setAnim(SA_Surprise);
							ns.jump(2);
							fx.flashBang(0.1, 100);
							SBANK.bigHit02().play();
							fx.slices(ns, 5, c);
							200;
							200 >> ns.updatePose();
						}
						//fx.flashBang(0.4, 600);
					});
				}
									
			case TAction.BonusKill : // Coup de pouce
				if( start ) {
					cm.create({
						t.say( Tx.T_ComeOn({_name:s.data.firstname}) );
						t.setAnim(TA_PointCool);
						800;
						fx.blink(t, Const.LEARN_TXT_COLOR, 1, 500);
						500 >> fx.blink(t, Const.LEARN_TXT_COLOR, 5, 400);
						t.setAnim(TA_Charge);
						fx.chargeBall(t.getBodyCenter().x+8, t.getBodyCenter().y-4, 30, Const.LEARN_TXT_COLOR, 1.5);
						SBANK.powerUp04().play().tweenVolume(0,1500);
						900;
						SBANK.teacherAttack01().play();
						SBANK.explosion01().play();
						fx.flashBang(0.5, 500);
						t.setAnim(TA_Palm);
						fx.palmLight(t, Const.LEARN_TXT_COLOR);
						100;
						s.setAnim(SA_Surprise);
						fx.multiHits(s, 5, Const.LEARN_TXT_COLOR);
						s.jump(2);
						s.pull(0, -0.3, 300);
						400 >> s.pull(0,0, 500);
						300;
					});
				}
						
			/*case TAction.Reprimand : // Disputer
				if( start ) {
					var c = 0xFF550D;
					cm.create({
						t.setAnim(TA_Point);
						t.say(s.data.firstname+" !!!", 0x932C00);
						fx.flashBang(0.1, 500);
						100;
						fx.surprise(s);
						s.setAnim(SA_Surprise);
						500;
						t.setAnim();
						fx.projDots(s, t, c);
						100;
						t.setAnim(TA_ChargeStand);
						fx.chargeGround(t, c);
						300;
						fx.smokeNova(t.getFeet(), 1.0, true);
						//t.setAnim(TA_ChargeStand);
						t.pull(0, -0.1, 700);
						1300;
						//300;
						//t.pull(0, -0.5, 300);
						//t.setAnim(TA_Palm);
						//fx.palmLight(t, LEARN_TXT_COLOR, 20,0);
						//fx.airWave(t, 0);
						//800;
						s.updatePose();
						//t.setAnim();
						//200;
						//t.pull(0, 0, 100);
						//t.setAnim();
					});
				}
				*/
				
			/*case TAction.Test : // Interro !
				if( start ) {
					cm.create({
						t.setAnim(TA_Wait);
						1000;
						for( s in students ) {
							fx.word(s, "...");
							50;
						}
						600;
						t.setAnim(TA_Point);
						t.say(Tx.T_Test);
						fx.smokeNova(t.getFeet(), 0x9DCEFF);
						fx.airWave(t, 0);
						200;
						fx.flashBang(0.6, 1000);
						100;
						for( s in students ) {
							s.setAnim(SA_Surprise);
							s.lookAt(0,0);
							s.jump(2);
							100;
						}
						t.setAnim(TA_Wait);
						1000;
						for( s in students ) {
							s.setAnim(SA_Write);
							50;
						}
						2000;
						var n = 0;
						for( s in students ) {
							fx.paper(s, t);
							s.setAnim();
							s.jump(1);
							100;
							n++;
						}
						t.setAnim(TA_PointCool);
						600;
						fx.word(t, Tx.Sheets({_n:n}));
						t.setAnim();
						500;
						t.goto(DESK) > end;
						t.setDir(0);
						200;
						for( s in students ) {
							s.updatePose();
							50;
						}
					});
				}*/
				
			case TAction.TestTeach : // Interroger
				if( start ) {
					var c = Const.LEARN_TXT_COLOR;
					cm.create({
						400;
						t.setAnim(TA_PointCool);
						t.say(Tx.T_BeginTeach({_name : s.data.firstname}));
						800;
						s.jump(2);
						fx.surprise(s);
						300;
						t.setAnim(TA_Wait);
						s.setAnim(SA_Talk);
						100;
						fx.symbols(s, Tx.T_Speach, 5, true, 0,-14);
						1000;
						t.setAnim(TA_Palm);
						t.say(Tx.T_Good);
						150;
						fx.palmLight(t, c, 0, 10);
						fx.flashBang(0.05, 200);
						SBANK.teacherAttack03().play();
						//fx.projLines(t, s, c, 20, 1.3 );
						//fx.projDots(s, t, c, 30, 1 );
						400;
						//fx.multiHits(s, 10, 0xFF80FF);
						//600;
						shake(1, 400);
						fx.smallExplosion(s, Const.LEARN_TXT_COLOR);
						SBANK.bigHit02().play();
						fx.flashBang(0.3, 400);
						t.setAnim();
						s.updatePose();
						100;
					});
				}
					
			case TAction.UseObject :
				var o = Type.createEnumIndex(TObject,num);
				var odata = Common.getObjectData(o, teacher.data.comps);
				
				if( start )
					teacher.data.removeObject(Type.createEnumIndex(TObject,num)) ;
					
				if( !start )
					updateActionBars(lastActions);
					
				switch( Type.createEnumIndex(TObject,num) ) {
					case TObject.Sponge : // éponge
						if( start ) {
							function launch() {
								var pr = fx.projLaunch(t, s, 0xFFD900, 5,4, 0.2);
								pr.speed = 8.5;
								pr.onEnd = function() {
									fx.projHit(pr);
									cm.signal("projEnd");
								}
							}
							cm.create({
								t.setDir(0) > 200;
								t.setAnim(TA_Point);
								SBANK.windShort().play();
								launch();
								end("projEnd");
								SBANK.splash().play(0.3);
								fx.dotsExplosion(s, 0x53A6AC);
								s.setAnim(SA_Surprise);
								300>>SBANK.studentHit02().play();
								t.setAnim();
								s.jump(2);
								fx.hit(s.getHead().x, s.getHead().y);
								fx.surprise(s);
							});
						}
						
					case TObject.SuperAttack_0, TObject.SuperAttack_1 : // Twinoide
						if( start )
							cm.create({
								t.setDir(1);
								t.setAnim(TA_Twinoid);
								650>>SBANK.windShort().play(0.4);
								1800;
								t.setBuff(true);
								SBANK.explosion03().play();
								fx.nova(t.getFeet(), 0xFFD900, 1.5, BlendMode.ADD);
								fx.flashBang(0.5, 1000);
								shake(0.5, 1000);
								600;
							});
						else
							cm.create({
								SBANK.buff().play();
								pop(t, odata.name, 0xFFFF00, false);
								t.setAnim();
								200;
							});
							
					case TObject.Heal_0 : // Batoit 1
						if( start )
							cm.create({
								if( t.hasPyjama() ) {
									t.setDir(3);
									300;
								}
								else {
									t.setDir(1);
									t.setAnim(TA_DrinkHeal1);
									1700;
								}
							});
						else
							cm.create({
								t.setAnim();
								200;
							});
							
					case TObject.Heal_1 : // Batoit 2
						if( start )
							cm.create({
								t.setDir(1);
								t.setAnim(TA_DrinkHeal2);
								1700;
							});
						else
							cm.create({
								t.setAnim();
								200;
							});
							
					case TObject.Heal_2 : // Batoit 3
						if( start )
							cm.create({
								t.setDir(1);
								t.setAnim(TA_DrinkHeal3);
								1700;
							});
						else
							cm.create({
								t.setAnim();
								200;
							});

					default :
						debug("missing anim for item "+Type.createEnumIndex(TObject,num)+" (#"+num+")");
				}
				
			case TAction.Pet_Sleep : // Fusil hypodermique
				if( start )
					cm.create({
						t.setDir(1);
						t.setAnim(TA_Pocket);
						1000;
						t.setDir(0);
						t.setAnim(TA_Gun);
						500;
						for(s in students) {
							s.jump(2);
							s.setAnim(SA_Surprise2);
							50;
						}
						500;
						fx.flashBang(0.5, 700);
						fx.palmLight(t, 0xFFFF00, 10, 4);
						SBANK.gun02().play();
						100>>SBANK.studentHit01().play();
						s.pull(0, -0.15);
						fx.multiHits(s, 2, 0xFFFFFF);
						s.setAnim(SA_Surprise);
						180;
						fx.flashBang(0.8, 1000);
						fx.palmLight(t, 0xFFFF00, 10, 4);
						SBANK.gun02().play();
						100>>SBANK.studentHit02().play();
						s.pull(0, -0.4);
						fx.multiHits(s, 2, 0xFFFFFF);
						300;
						fx.bubbles(s);
						800;
						s.pull(0, -0.1, 800);
						s.setAnim(SA_EyesClosed);
						500;
						s.setAnim();
						100;
						s.setAnim(SA_Surprise2);
						200;
						s.setAnim(SA_EyesClosed);
					});
				else
					cm.create({
						s.pull(0,0);
						SBANK.drop01().play();
					});
					
					
			case TAction.Pet_Dring : // Réveil
				if( start ) {
					cm.create({
						t.setDir(1);
						t.setAnim(TA_Pocket);
						1000;
						t.setAnim();
						t.setDir(0);
						100;
						t.setAnim(TA_Point);
						SBANK.windLong().play();
						fx.airWave(t, t.getDir(), false);
						t.say(Tx.T_WakeUp);
						500;
						SBANK.alarm().playLoop(3).tweenVolume(0.5, 4000);
						shake(1.5, 1000);
						fx.flashBang(0.5, 1000);
						fx.palmLight(t, 0xFFB300);
						for(s in students) {
							s.jump(2);
							50;
						}
					});
				}
				else
					cm.create({
						2000;
						t.setDir(1);
						t.setAnim(TA_Pocket);
						1000;
						t.setAnim();
						200;
					});
				
			case TAction.Pet_ToTheCorner : // Au coin
				if( start )
					cm.create({
						t.setDir(0);
						t.say( Tx.T_Exclamation({_word:s.data.firstname}) );
						t.setAnim(TA_Point);
						200;
						s.jump(1.5);
						700;
						t.say(Tx.T_ToTheCorner, 0xB00000);
						t.setDir(1);
						t.setAnim(TA_Point);
						fx.airWave(t, t.getDir());
						shake(0.3, 400);
						500;
					});

			case TAction.Pet_ElbowHit : // Coup de coude
				if( start )
					cm.create({
						s.lookAt(0,0);
						300;
						fx.slices(s, 1, 0xFFFF00);
						SBANK.bigHit01().play();
						s.lookAt(1,0);
						s.pull(0, -0.2, 200);
					});
				else
					cm.create({
						s.pull(0,0, 500);
						s.lookAt(0,0);
						500;
					});
					
			case TAction.TeachingFlick : // Pichenette
				if( start )
					cm.create({
						t.goto(s.getClosePoint());
						end;
						t.setDirTo(s);
						600;
						fx.slices(s, 1);
						s.pull(0, 0.1);
						s.lookAt(0,1);
						s.setAnim(SA_Surprise2);
						SBANK.bigHit01().play();
						200;
					});
					
			case TAction.ExtensiveTeach : // Rafale de savoir
				if( start ) {
					cm.create({
						t.setAnim(TA_Charge);
						500;
						t.setAnim(TA_DoublePalm);
						fx.palmLight(t);
						SBANK.teacherAttack04().play();
						500;
						SBANK.explosion01().play();
						fx.row(num, 0x00FFFF);
					});
				}
					
			case TAction.Hypnotism : // Hypnotisme
				if( start )
					cm.create({
						t.setAnim(TA_DoublePalm);
						SBANK.powerUp05().play();
						fx.psyAttackTeacher(t, 0x00C6FF);
						s.lookAt(0,0);
						500;
						s.setAnim(SA_Surprise2);
						s.jump(3);
						1000;
						fx.bubbles(s);
					});
					
			case TAction.CoolTeach : // Explication apaisante
				if( start )
					cm.create({
						t.setAnim(TA_Explain);
						fx.words(t, [Tx.T_Speach], 10, 1);
						500;
						SBANK.powerUp05().play();
						fx.psyAttackTeacher(t, 0xFE5301);
						s.lookAt(0,0);
						1000;
						s.setAnim(SA_Happy);
						s.jump(2);
						fx.shine(s, 0xFFFF00);
						500;
					});
					
			case TAction.Anecdote : // Anecdote captivante
				if( start )
					cm.create({
						t.setAnim(TA_Explain);
						t.say(Tx.T_OldStory1);
						1500;
						fx.crossFade(0x0,700,200);
						800;
						t.setDir(1);
						t.setPos(t.cx+4, t.cy-1);
						t.setAnim(TA_Listen);
						t.say(Tx.T_OldStory2);
						2000;
					});
				else
					cm.create({
						
					});
			
			
			case TAction.Sacrifice :
				if( start ) {
					var c = 0xE36A6A;
					cm.create({
						t.setAnim(TA_ChargeStand);
						fx.charge(t, c);
						SBANK.powerUp03().play();
						800;
						t.setAnim(TA_ChargeFloat);
						400;
						SBANK.explosion02().play();
						200>>SBANK.teacherHit01().play();
						fx.multiHits(t, 5, c);
						fx.dotsExplosion(t, c);
						t.pull(0, 0.3, 300);
						200>>t.setAnim(TA_ChargeStand);
						fx.flashBang(0.5, 1000);
						fx.projDots(t, s, c);
						600;
						fx.slices(s, 3);
						SBANK.studentHit01();
						SBANK.bigHit02().play();
						s.pull(0, -0.1, 100);
						fx.flashBang(0.7, 1000);
						500;
						t.setAnim();
					});
				}
					
			
			case TAction.Seriously : // Un peu de sérieux
				if( start ) {
					cm.create({
						t.goto(s.getClosePoint());
						end;
						for(s in affected) {
							fx.slices(s, 1, 0xFF0000);
							s.lookAt(0,1);
							s.pull(-0.1, 0);
							SBANK.bigHit03().play(1, -0.5);
							fx.hit(s.getHead().x, s.getHead().y, 0xFF0000);
							s.setAnim(SA_Surprise2);
							400;
							200>>s.pull(0,0, 200);
							300>>s.lookAt(0,0);
						}
					});
				}
				else
					cm.create({
						for(s in affected) {
							s.pull(0,0, 200);
							s.lookAt(0,0);
						}
					});
					
			case TAction.BestTestTeach : // Question vicieuse
				if( start )
					cm.create({
						t.say( Tx.T_Exclamation({_word:s.data.firstname}) );
						t.setAnim(TA_Point);
						200;
						s.lookAt(0,0);
						s.setAnim(SA_Surprise2);
						500;
						t.setAnim(TA_Explain);
						t.event(Tx.HardQuestion);
						fx.words(t, [Tx.T_Speach], 10, 1.5);
						SBANK.debuff03().play();
						1200;
						fx.surprise(s);
						s.jump(2);
						s.shake(0.1,1000);
						s.say("...");
						500;
						s.shake(0.4,1000);
						s.setAnim(SA_Surprise);
						500;
						s.say(Tx.S_Illumination);
						s.setAnim(SA_VeryHappy);
						s.pull(0, -0.3);
						fx.dotsExplosion(s, 0xFFBF00);
						fx.smokeBomb(s, 0x3C0000, -10);
						SBANK.explosionLong().play();
						500;
					});
				else
					cm.create({
						s.pull(0,0, 500);
					});
			

			case TAction.Pet_Explication : // Explications (du pet)
				var p = getPet();
				if( p!=null )
					if( start )
						cm.create({
							fx.surprise(s);
							s.setAnim(SA_Surprise2);
							200;
							p.setAnim(SA_TalkHandUp);
							SBANK.handUp01().play();
							200;
							fx.words(p, [Tx.T_Speach], 10, 1.7);
							1200;
							p.setAnim();
							200;
							fx.slices(s, 2, Const.LEARN_TXT_COLOR);
							SBANK.teacherAttack03().play();
							100;
						});
					else
						p.updatePose();
			

			case TAction.LangageAid : // Assistant étranger
				if( start ) {
					assistant = new Iso();
					var mc = new lib.Assist();
					assistant.addFurnMc(mc, 0,-7);
					assistant.setPos(3, 10);
					assistant.fl_visible = false;
					assistant.setShadow(true);
					var rseed = new mt.Rand(cinit._solverInit._seed);
					mc.gotoAndStop( rseed.random(mc.totalFrames)+1 );
					cm.create({
						t.setDir(3);
						400;
						t.setAnim(TA_Point);
						t.say(Tx.T_AssistantInvocation);
						fx.charge(assistant, 0xA99EDA, 20);
						SBANK.powerUp05().play();
						1000;
						SBANK.explosion01().play();
						fx.flashBang(0.7, 500);
						fx.smokeBomb(assistant, 0xA99EDA);
						assistant.fl_visible = true;
					});
				}
			
			case TAction.Pet_Exclude : // Exclusion
				if( start )
					cm.create({
						SBANK.windLong().play();
						t.setAnim(TA_PointCool);
						100;
						fx.surprise(s);
						300;
						t.say( Tx.T_ExcludeStudent({_name:s.data.firstname}) );
						1000;
						t.setAnim();
						SBANK.studentHit03().play();
						s.say("!!");
						s.jump(2);
						s.setAnim(SA_SurpriseSad);
						s.pull(0, -0.1, 200);
						400>>s.pull(0, 0, 200);
						1500;
						fx.cry(s, 30);
						s.setAnim(SA_Cry);
						SBANK.debuff03().play();
						700;
						s.cd.set("forceCry", 90);
					});
					
			
			//
			//case TAction.SKILLNAME : // SKILLNAME
				//if( start )
					//cm.create({
					//});
				//else
					//cm.create({
						//
					//});
			//
			
			//
			// Ajouter les nouvelles animations ICI
			//

			default :
				debug("missing anim : "+a);
		}
		
		if( start && cm.isEmpty() )
			cm.create({
				t.setDir(1)>100;
				t.setDir(0)>500;
				t.gotoXY(t.cx, t.cy-1)>end;
				t.event(""+a);
				t.setAnim(TA_Palm)>500;
			});
			
		if( !at(Class) && !start && resetTeacher )
			cm.chainToLast({
				t.setAnim() > 300;
			});
			
		if( at(Class) && !start ) {
			if( affected!=null )
				for(ns in affected)
					ns.updatePose();
			if( resetTeacher )
				cm.chainToLast({
					t.setAnim();
					300;
					t.pull(0,0, 300);
					t.back();
					end;
					t.setDir(2);
					t.setAnim(TA_WriteBoard);
				});
				
			if( curQuery==null )
				cm.chainToLast({
					400;
					setFocus(true);
				});
		}
			
		
	}
	
	function doStudentAction(s:Student, a:SAction, targets:Array<Int>, start:Bool) {
		function ts(idx) : Student {
			return getStudent( targets[idx] );
		}
		var announce = start;
		if( start )
			setFocus(s);
		switch(a) {
			
			case SAction.Atk_N_0 : // chuchotement
				if( start )
					cm.create({
						s.setAnim(SA_Talk);
						s.lookAt(1,1);
						fx.symbols(s, Tx.S_Whisper,6, true, 0,-20);
						1200;
						s.setAnim();
						s.lookAt(0,0);
					});
					
			case SAction.Atk_N_1 : // rire sardonique (ricanement)
				if( start )
					cm.create({
						s.setAnim(SA_EvilLaugh);
						fx.symbols(s, Tx.S_Snigger, 6, true, 0, -20);
						SBANK.laugh01().play(0.6);
						1200;
						s.setAnim();
					});
			
			case SAction.Atk_N_2 : // bruit strident
				if( start )
					cm.create({
						400;
						s.setAnim(SA_EvilGrin);
						700;
						pop(s, Tx.S_HorribleNoise, 0xFFC600, 1500, true);
						SBANK.noise01().play(0.4);
						shake(0.5,1500);
						for(s2 in students)
							if( s2!=s && s2.fl_visible ) {
								200;
								s2.setAnim(SA_Surprise);
							}
						800;
					});
				else
					cm.create({
						s.setAnim(SA_EvilLaugh);
						SBANK.laugh03().play(0.2, 0.5);
						for(s2 in students)
							if( s2.fl_visible )
								s2.updatePose();
						700;
						s.setAnim();
					});
				
			case SAction.Atk_N_3 : // sonnerie portable
				if( start )
					cm.create({
						500;
						s.lookAt(0,0);
						s.setAnim(SA_Surprise);
						s.jump(1);
						fx.words(s, [Tx.S_PhoneRing, ""], 30, 1.8);
						Sfx.setChannelVolume(Const.MUSIC_CHANNEL, Const.MUSIC_VOLUME*0.2);
						ringTone.play();
						200;
						s.lookAt(1,0);
						600;
						fx.word(teacher, "...");
						s.lookAt(-1,0);
						500;
						s.lookAt(1,0);
						600;
						s.lookAt(-1,0);
						1200;
					});
				else
					cm.create({
						teacher.setAnim();
						1200;
						s.setAnim();
						s.lookAt(0,1);
						ringTone.setVolume(0.4);
						400;
						s.ambiant("...");
						300;
						fx.word(s, Tx.S_PhoneOff);
						SBANK.bip02().play(0.6);
						ringTone.stop();
						800;
						s.lookAt(0,0);
						applySoundState();
					});
			
			case SAction.Atk_N_5 : // pétard mammouth
				if( start ) {
					// Lancer
					var target = Iso.isoToScreenStatic(Const.EXIT.x+2, Const.EXIT.y);
					function _launch() {
						var p = new Projectile(s.getHead().x, s.getHead().y+6);
						sdm.add(p, Const.DP_FX);
						p.drawBox(5, 2, 0xD70000);
						p.setTarget(target.x, target.y-1);
						p.speed = 2;
						p.setLinear();
						p.onUpdate = function() {
							var d = Math.sin( p.progress()*3.14 ) * 40;
							p.y -= d;
							p.filters = [
								new flash.filters.GlowFilter(0x0,1, 2,2, 3),
								new flash.filters.DropShadowFilter(d,90, 0x0,0.6, 0,0,1)
							];
							fx.bombParts(p.x, p.y);
						}
						p.dr = (8+Std.random(5)) * (Std.random(2)*2-1);
						p.onEnd = function() {
							cm.signal("projEnd");
						}
					}
					cm.create({
						s.setAnim(SA_EvilGrin);
						500;
						s.jump(1);
						_launch();
						end;
						shake(3,1000);
						fx.flashBang(0.5,500);
						SBANK.explosionLong().play();
						fx.bomb(target.x, target.y);
						for(s2 in students)
							s2.jump(3);
						s.setAnim();
						fx.surprise(teacher);
						teacher.jump(3);
						300;
					});
				}
			
			case SAction.Atk_N_7 : // baillement
				if( start )
					cm.create({
						s.setAnim(SA_Yawn);
						fx.bubbles(s);
						500;
						fx.word(s, "Awwww...", Const.ATK_TXT_COLOR) > 600;
						fx.bubbles(s);
					});
				else
					s.setAnim();
			
			case SAction.Atk_N_8 : // fredonne
				if( start )
					cm.create({
						500;
						s.setAnim(SA_Talk);
						fx.notes(s, 8,1.2);
						1200;
						s.setAnim();
						200;
					});
			
			case SAction.Atk_N_9 : // pleure (ouin)
				if( start )
					cm.create({
						500;
						s.setAnim(SA_Cry);
						1200;
						s.setAnim();
						200;
					});
				else
					cm.create({
						
					});
			
			case SAction.Atk_Ph_0: // boulette
				if( start )
					cm.create({
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						300 >> s.setAnim(SA_Evil);
						300 >> s.lookAt(0,1);
						SBANK.windLong().play();
						fx.projObject(s,teacher, 3.5, 1.0, 0xEAE8DF,3,3);
						end("projEnd");
						SBANK.projHit().play();
						s.setAnim();
					});
				else
					s.lookAt(0,0);
			
			case SAction.Atk_Ph_1: // élastique
				if( start )
					cm.create({
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						300 >> s.setAnim(SA_Evil);
						300 >> s.lookAt(0,1);
						SBANK.elastic().play();
						for(i in 0...3) {
							i*100 >> s.jump(2);
							i*100 >> fx.projObject(s,teacher, 5, 0, 0xFFBF00,5,2);
						}
						end("projEnd");
						SBANK.projHit().play();
						s.setAnim();
						fx.flashBang(0.5, 400);
					});
				else
					s.lookAt(0,0);
			
			case SAction.Atk_Ph_2: // avion papier
				if( start ) {
					function _launch() {
						var p = fx.projObject(s,teacher, 2, 0.3, 0xB3B9CE,2,2);
						p.graphics.clear();
						p.graphics.beginFill(0xFFFFFF,1);
						p.graphics.moveTo(0,-3);
						p.graphics.lineTo(8,0);
						p.graphics.lineTo(0,0);
						p.graphics.beginFill(0xD2D2D2,1);
						p.graphics.moveTo(0,0);
						p.graphics.lineTo(8,0);
						p.graphics.lineTo(0,3);
						p.rotation = Lib.deg( Math.atan2(teacher.sprite.y-s.sprite.y, teacher.sprite.x-s.sprite.x) );
						p.filters = [ new flash.filters.DropShadowFilter(14,90, 0x0,0.3, 2,2) ];
						p.dr = 0;
					}
					cm.create({
						700;
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						300 >> s.setAnim(SA_Evil);
						300 >> s.lookAt(0,1);
						SBANK.windLong().play(0.3);
						_launch();
						end("projEnd");
						SBANK.projHit().play();
						s.setAnim();
					});
				}
				else
					s.lookAt(0,0);
			
			case SAction.Atk_Ph_3: // pavé sorbonne
				if( start ) {
					var fallSfx = SBANK.fall01();
					cm.create({
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						300 >> s.setAnim(SA_Evil);
						300 >> s.lookAt(0,1);
						SBANK.windShort().play();
						700>>fallSfx.play();
						fx.projObject(s,teacher, 2.5, 1, 0xC0C0C0,7,4);
						end("projEnd");
						fx.smokeBomb(teacher, 0x535353);
						fallSfx.stop();
						SBANK.projHit().play();
						SBANK.explosion02().play();
						s.setAnim();
						fx.flashBang(0.7, 1000);
					});
				}
				else
					s.lookAt(0,0);
			
			case SAction.Atk_Ph_5: // sac de punaises
				var to = ts(0);
				if( start ) {
					cm.create({
						700;
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						s.lookAt(0,1);
						s.setAnim(SA_Evil);
						fx.itemRain(to, 0xD9CEB9, 10);
						100;
						to.setAnim(SA_Surprise);
						to.lookAt(0,-1);
						300;
						to.jump(2);
						to.setAnim(SA_Sneeze);
						shake(0.2, 500);
						s.setAnim();
						800;
					});
				}
			
			case SAction.Atk_Ph_6: // éclair
				if( start )
					cm.create({
						s.setAnim(SA_EvilEyes);
						400;
						fx.flashBang(0.1, 1000);
						fx.charge(s, 0x00BFFF);
						400 >> s.setAnim(SA_EvilLaugh);
						1400;
						fx.lightning(s,teacher, 0x00BFFF);
						teacher.setAnim(TA_Shock);
						fx.smallExplosion(teacher, 0x00BFFF);
						fx.flashBang(0.2, 1500);
						teacher.cd.set("hitSkip", 30);
					});
				else
					cm.create({
						s.setAnim(SA_EvilLaugh);
						700;
						s.setAnim();
						300;
						teacher.setAnim();
					});
					
			case SAction.Atk_Ph_8: // postillons
				if( start ) {
					function _launch(i) {
						var p = fx.projObject(s,teacher, Lib.rnd(6,7), Lib.rnd(0,0.1), 0xFFFFFF,1,1);
						p.filters = [ new flash.filters.GlowFilter(0xFFFFFF,0.6, 4,2, 3) ];
						p.rotation = Math.atan2(p.dy, p.dx);
						p.dr = 0;
						p.pixel = true;
						p.delay = i*0.5;
					}
					cm.create({
						700;
						s.setAnim(SA_Surprise);
						400;
						shake(0.5,300);
						s.say(Tx.S_Sneeze);
						s.jump(2);
						s.lookAt(0,1);
						s.setAnim(SA_Sneeze);
						SBANK.spit().play();
						for(i in 0...10)
							_launch(i);
						end("projEnd");
						SBANK.projHit().play();
						s.setAnim();
						SBANK.bigHit02().play();
					});
				}
				else
					s.lookAt(0,0);
			
			case SAction.Atk_Ph_9: // lance pierre
				if( start ) {
					var sfx = SBANK.fall01();
					cm.create({
						700;
						s.setAnim(SA_EvilLaugh);
						400;
						s.jump(2);
						300 >> s.setAnim(SA_Evil);
						300 >> s.lookAt(0,1);
						SBANK.windLong().play();
						sfx.play(0.4);
						fx.projObject(s,teacher, 4, 0.3, 0xB3B9CE,5,5);
						end("projEnd");
						sfx.stop();
						SBANK.projHit().play();
						s.setAnim();
						fx.flashBang(0.7, 1000);
					});
				}
				else
					s.lookAt(0,0);
	
			case SAction.Atk_Ps_0 : // regard obsédant
				if( start )
					cm.create({
						s.setAnim(SA_EvilEyes);
						fx.psyAttack(s, 0xFFFF00, 6);
						fx.blink(s, 0x1EA2E1,3, 2000);
						1000;
						s.lookAt(0,1);
						700;
					});
				else
					cm.create({
						500;
						fx.word(teacher, "...");
						500;
						s.lookAt(0,0);
						400;
						s.setAnim();
					});
					
			case SAction.Atk_Ps_4 : // insulte
				if( start )
					cm.create({
						600;
						s.jump(2);
						s.setAnim(SA_Talk);
						s.say(tg.m_taunt());
						fx.surprise(s, 0xFF9300);
						1000;
						s.setAnim();
						s.updatePose();
					});
				else
					cm.create({
						s.setAnim(SA_Laugh);
						1000;
						s.setAnim();
						s.updatePose();
					});
						
			case SAction.Atk_Ps_2 : // grimace
				if( start )
					cm.create({
						s.jump(2);
						s.setAnim(SA_Tongue);
						fx.surprise(s);
						1000;
						s.setAnim(SA_EvilLaugh);
						500;
					});
					
			case SAction.Atk_Ps_6 : // nuage puant
				if( start )
					cm.create({
						tw.create(s, "shakeX", 0.2, TEaseIn, 1000).onEnd = function() s.shakeX = 0;
						1000;
						s.jump(2);
						fx.smoke(s, 0x8AB53C, 0.6, 8);
						fx.groundSmoke(s, 0x5F7B28);
						1000;
					});
				else
					cm.create({
						200;
						teacher.setDir(0) > 100;
						s.say("Oops.");
					});
				
			case SAction.LaughingGas : // gaz hilarant
				if( start )
					cm.create({
						300;
						s.setAnim(SA_EvilGrin);
						500;
						s.say(Tx.S_Grenade);
						teacher.setDir(0);
						1000;
						s.jump(3);
						fx.smallExplosion(s, 0xFFD900);
						fx.smokeNova(s.getFeet(), 0xFFD900, 1.5, 0.4);
						fx.flashBang(0.5, 200);
						shake(1, 1000);
						800;
					});
				else
					cm.create({
						s.updatePose();
					});
							
			case SAction.Dizzy: // malaise vagal
				if( start ) {
					cm.create({
						700;
						s.say("!!");
						s.jump(2);
						300>>fx.teint(s, 0x448127, 0.7, 1500);
						100>>s.setAnim(SA_Sad);
						800;
						s.say(Tx.S_Faint);
						1500;
					});
				}
				else
					cm.create({
						fx.bubbles(s);
					});
				
			case SAction.Add_Boredom : // ennui
				if( start )
					cm.create({
						s.setAnim(SA_Bored);
						s.lookAt(0,1);
						300;
					});
				else
					cm.create({
						500;
						s.say(Tx.S_Boredom);
						1000;
						s.lookAt(0,1);
						100;
						s.lookAt(0,0);
						100;
						s.setAnim();
						s.updatePose();
					});
					
			case SAction.Add_BoringGenerator : // démotivant
				if( start )
					cm.create({
						s.setAnim(SA_EvilGrin);
						fx.smokeNova(s.getFeet(), 0x0, 0.5, true, 1.3);
						100 >> fx.blink(s, 0x0, 5, 600);
						700;
						s.jump(3);
						s.setAnim(SA_EvilLaugh);
						fx.nova(s.getHead(), 0x0, 2);
						300 >> fx.smokeNova(s.getFeet(), 0x0, 1.3, 1);
						1000;
					});
				else
					cm.create({
						s.setAnim();
					});
					
			case SAction.Add_Invisibility :
				if( start )
					cm.create({
						fx.smoke(s, 0xE5E5E5, 0.8) > 300;
					});
					
			case SAction.LaunchThing :
					
			case SAction.Add_Asleep :
				if( start )
					cm.create({
						s.setAnim(SA_Tired);
						s.lookAt(-1,0);
						fx.bubbles(ts(0)) > 1400;
						s.lookAt(0,0);
					});
				else
					cm.create({
						fx.symbols(ts(0), "z", 6, true);
					});

			case SAction.HandUpQuestion, SAction.HandUpOut, SAction.HandUpCheat, SAction.HandUpHeal, SAction.HandUpNote :
				announce = false;
				
			case SAction.Add_Angry, SAction.Add_Slow, SAction.Add_Inverted, SAction.Add_Lol :
					
			default :
				if( start )
					cm.create({
						s.setAnim(SA_EvilGrin);
						fx.blink(s, 0xFF0000, 3);
						500;
					});
		}
		
		if( announce ) {
			var data = Common.getStudentActionData(a);
			s.event(data.name, 0xDD2100);
			SBANK.studentAttack().play(0.5);
		}
		
		if( !start )
			cm.chainToLast({
				1000;
				s.updatePose();
				s.lookAt(0,0);
			});
		
		if( cm.isEmpty() )
			playLog();
	}
	

	
	public function updateActionBars(act : Array<{a : TAction, c : Int}>) {
		lastActions = act;
		//KILL CURRENT ACTION BARS
		for (a in ActionBar.ALL)
			a.empty() ;

		var alist = Lambda.map( act, function(a) return Common.getTActionData(a.a) );
		
		// Actions
		for(adata in alist) {
			var act = new ActionBar.Action(adata.id, adata.name);


			if(!isLogged() && (adata.id==TAction.LockedSlot || adata.id==TAction.MoreSlots)) {
				act.onOver = function() tip.showAbove( act.spr, formatTip(adata.name#if debug +" ("+adata.id+")" #end+"|"+Tx.Subscribe_required) );
			} else {
				act.onOver = function() tip.showAbove( act.spr, formatTip(adata.name#if debug +" ("+adata.id+")" #end+"|"+adata.desc) );
			}
			act.onOut = function() tip.hide();
			act.onClick = function() onClickAction(adata);
			act.isPending = function() return pendingAction!=null && pendingAction.a.id==adata.id;
			act.isAvailable = function() {
				if( adata.id==TAction.LockedSlot || adata.id==TAction.MoreSlots) {
					return isLogged();
				}else
					return !sick && solver.teacher.canDo(adata.id);
			}
			act.isVisible = function() return isActionVisible(adata.id);
			act.priority = adata.prio;
			act.allowShuffleAnim = function() return adata.id!=TAction.MoreSlots;


			// Confirmation "moreSlots"
			if (Type.enumEq(adata.id, TAction.MoreSlots)) {
				function _buyMoreSlots() {
					if (teacher.data.gold >= logic.Data.MORESLOTS_COST)
						boughtSlots = true;
					sendAction(TAction.MoreSlots) ;
				}
				act.onClick = function() {
					if( boughtSlots )
						_buyMoreSlots();
					else {
						cancelAction();
						var choices = [] ;
						choices.push(Tx.BuyMoreSlots( {_cost:logic.Data.MORESLOTS_COST} )) ;

						query(teacher, choices, 200, true, function(i:Int) {
							lockActions = false;
							_buyMoreSlots();
						});
					}
				}
			}

			// Confirmation "LockedSlot"
			if (Type.enumEq(adata.id, TAction.LockedSlot)) {
				act.onClick = function() {
					if( interfaceLocked() || lockActions )
						return;
						
					cancelAction();
					var choices = [] ;
					choices.push(Tx.UnlockSlot) ;
					function _onBuy(i:Int) {
						lockActions = true;
						gotoBank();
					}
					query(teacher, choices, 200, true, _onBuy) ;
				}
			}

			// Confirmation "RerollHelpers"
			if (Type.enumEq(adata.id, TAction.SRRerollHelper) || Type.enumEq(adata.id, TAction.HRerollHelper)) {
				function _rerollHelpers() {
					sendAction(adata.id) ;
				}
				act.onClick = function() {
					cancelAction();
					var choices = [] ;
					choices.push(Tx.RerollHelpers( {_cost:logic.Data.REROLL_HELPERS_COST} )) ;

					query(teacher, choices, 200, true, function(i:Int) {
						lockActions = false ;
						_rerollHelpers() ;
					});
				}
			}



			switch( adata.stance ) {
				case Normal :
					if( adata.frame!=null ) {
						act.icon = new lib.Icons();
						act.icon.gotoAndStop( adata.frame );
					}
					if( adata.quick && adata.id!=TAction.MoreSlots )
						mainBar.addAction(act);
					else
						randBar.addAction(act);
						
				case Super, Extra : // TODO à supprimer
						
				case StaffRoom :
					if( !at(HQ) )
						warning("unexpected action "+adata);
					if( adata.frame!=null ) {
						act.icon = new lib.Icons();
						act.icon.gotoAndStop( adata.frame );
					}
					if( adata.quick )
						mainBar.addAction(act);
					else
						randBar.addAction(act);
						
				case House :
					if( !at(Home) )
						warning("unexpected action "+adata);
					if( adata.frame!=null ) {
						act.icon = new lib.Icons();
						act.icon.gotoAndStop( adata.frame );
					}
					if( adata.quick )
						mainBar.addAction(act);
					else
						randBar.addAction(act);
			}


			//gift number on icon
			if (Type.enumEq(adata.id, TAction.SROpenGift) || Type.enumEq(adata.id, TAction.HOpenGift)) {
				for (i in cinit._solverInit._extraInv) {
					switch(i._o) {
						case XmasGift :
							act.count = i._n ;
							break ;
						default : continue ;
					}
				}
				act.onClick = function() gotoUrl(cinit._extra._urlGift) ;
			}
		}
		
		// Objets consommables
		var n = 0;
		for(id in teacher.data.objects.keys()) {
			var count = teacher.data.objects.get(id).stock;

			jsUpdateObject(id, count) ;

			//if( count<=0 )
				//continue;
			var o = Type.createEnumIndex(TObject, id);
			var odata = Common.getObjectData( Type.createEnumIndex(TObject, id),  teacher.data.comps);
			var adata = Common.getTActionData(TAction.UseObject);
			var a = new ActionBar.Action(id, odata.name);
			a.priority = -id;
			a.count = count;
			a.cost = odata.cost[0];
			a.icon = new lib.Icons();
			var str = odata.name#if debug +" ("+id+")" #end+"|"+odata.desc ;
			if (isLogged())
				str += "\n\n<font color='0xC78761'>"+Tx.BuyTip({_n:odata.pack[0], _cost:odata.cost[0]})+"</font>" ;
			if (!isLogged() && count <= 0) {
				str += "\n\n<font color='0xC78761'>"+Tx.Subscribe_required+"</font>" ;
			}
			a.onOver = function() tip.showAbove( a.spr, formatTip(str) );
			a.onOut = function() tip.hide();
			a.onClick = function() {
				if( count==0 ) {
					// Demande d'achat
					cancelAction();
					
					var choices = [] ;
					for (i in 0...odata.cost.length)
						choices.push(Tx.BuyMore( {_n:odata.pack[i], _cost:odata.cost[i]} )) ;

					query(teacher, choices, 200, true, function(i:Int) {
						if( teacher.data.gold < odata.cost[i] )
							gotoBank();
						else {
							lockActions = false;
							sendAction(TAction.Buy, [AT_Num(id), AT_Num(i)]) ;
						}
						//onClickAction(Common.getTActionData(TAction.Buy), AT_Num(id), o);
					});
				}
				else
					onClickAction(adata, AT_Num(id), o);
			}
			a.isPending = function()
				return
					pendingAction!=null && pendingAction.target0!=null &&
					Type.enumIndex(pendingAction.a.id) == Type.enumIndex(TAction.UseObject) &&
					id == Type.enumIndex(pendingAction.sub);

			a.isAvailable = function() return (!isLogged() && count > 0) || (isLogged() && count>=0 && !sick && solver.teacher.canDo(adata.id, id));
			try { a.icon.gotoAndStop( odata.frame ); } catch(e:Dynamic) { a.icon.gotoAndStop(1); trace("WARNING: unknown item frame "+odata.name+" (f="+odata.frame+")"); }
			
			mainBar.addAction(a);
			n++;
		}


		// helpers
		if( !photoMode && teacher.data.avHelpers != null ) {
			n = 0;
			var selectedHelper = solver.helper != null ;

			for(h in teacher.data.avHelpers.cur) {
				var hdata = Common.getHelperData(h) ;
				var adata = Common.getTActionData(TAction.ChooseHelper) ;

				var a = new ActionBar.Action(h, hdata.name) ;
				a.priority = adata.prio - n ;
				a.cost = logic.Data.CHOOSE_HELPER_COST ;
				a.icon = new lib.Icons();
				var str = Tx.ChooseHelperTitle({_sname : hdata.shortName}) + "|" + hdata.desc ; //### ADD HERE MORE INFOS ABOUT WHAT A HELPER IS
				
				a.onOver = function() tip.showAbove( a.spr, formatTip(str) );
				a.onOut = function() tip.hide();
				a.onClick = function() {
						cancelAction();
					if (solver.helper != null && Type.enumEq(solver.helper, h)) {
						message(Tx.HelperAlreadyChosen({_sname : hdata.shortName})) ;
					} else {
						var choices = [] ;
						choices.push(Tx.ChooseHelperCost( {_cost:logic.Data.CHOOSE_HELPER_COST} )) ;
						query(teacher, choices, 200, true, function(i:Int) {
							lockActions = false ;
							sendAction(ChooseHelper, [AT_Num(Type.enumIndex(h))] );
						});
					}
				} ;
				
				//a.isPending = function() return pendingAction!=null && pendingAction.a.id==adata.id;
				a.isAvailable = function() return !sick && solver.teacher.canDo(ChooseHelper, Type.enumIndex(h)) ;
				try { a.icon.gotoAndStop( hdata.frame ); } catch(e:Dynamic) { a.icon.gotoAndStop(1); trace("WARNING: unknown item frame "+hdata.name+" (f="+hdata.frame+")"); }
				
				mainBar.addAction(a);

				if (selectedHelper && Type.enumEq(solver.helper, h))
					getHelperPhoto(h);

				n++;

			}
		}

			
		if (!Type.enumEq(curPlace, Class)) {
			randBar.sortActions(function(a,b) {
				return -Reflect.compare(a.priority, b.priority);
			});



		} else {
			//MoreSLots =< force to the end
			var ms = null ;
			for (a in randBar.actions) {
				if (Type.enumEq(a.value, MoreSlots)) {
					ms = a ;
					randBar.actions.remove(a) ;
					break ;
				}
			}
			if (ms != null)
				randBar.actions.push(ms) ;
		}
		mainBar.sortActions(function(a,b) {
			return -Reflect.compare(a.priority, b.priority);
		});

		for( b in ActionBar.ALL )
			b.attachActions();
		ActionBar.updateAll();
		
		//set cooldowns
		for( ca in act ) {
			var ba = getAction(ca.a);
			if( ba!=null )
				ba.cd = ca.c;
		}
		mainBar.updateActions();
		
		randBar.x = Std.int( Const.WID*0.5 - randBar.getWidth()*0.5 ) + 2;
		mainBar.x = Std.int( Const.WID*0.5 - mainBar.getWidth()*0.5 ) + 2;
	}
	
	
	public function getHelperName(h:Helper) {
		return Common.getHelperData(h).name;
	}
	
	public function helperAvailable(h:Helper) {
		if (solver.teacher.avHelpers == null)
			return false ;
		return Lambda.exists(solver.teacher.avHelpers.cur, function(x) { return Type.enumEq(x, h) ; });
	}

	
	public function getHelperPhoto(h:Helper) {
		var wrapper = new Sprite();
		var mc : MovieClip = null;
		var col = 0x212D3A;
		var hei = 34;
		var dy = 0;
		switch( h ) {
			case Peggy :
				col = 0x7B3775;
				mc = new lib.Peggy();
			case Eddy :
				col = 0x7B3775;
				mc = new lib.EddyStand();
			case Inspector :
				col = 0x656256;
				mc = new lib.Sherlock();
			case Einstein :
				col = 0x2B66A8;
				mc = new lib.Tizoc();
			case Skeleton :
				col = 0x820000;
				mc = new lib.Nuke();
			case Supervisor :
				col = 0x425829;
				mc = new lib.Dwayne();
			case Dog :
				col = 0xD68429;
				mc = new lib.Tippex();
				dy = -8;
			case Director :
				col = 0xE74D18;
				mc = new lib.Muzot();
		}
		wrapper.addChild(mc);
		mc.x = 15;
		mc.y = hei+dy;
		mc.scaleX = -1;
		mc.gotoAndStop("stand");
		
		wrapper.graphics.beginFill(col, 1);
		wrapper.graphics.drawRect(0,0, 30,hei);
		wrapper.filters = [
			new flash.filters.GlowFilter(0xDEE4ED,1, 2,2,20, 1,true),
			new flash.filters.DropShadowFilter(4,-90, 0xFFFFFF,1, 0,0,1, 1,true),
			new flash.filters.DropShadowFilter(mc.height*0.4,90, 0xFFFFFF,0.1, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,0.3, 2,2,3),
			Color.getSaturationFilter(-0.5),
		];
		
		var bmp = Lib.flatten(wrapper, 4);
		//var bmp = new Bitmap( new BitmapData(30,30, false, 0x0) );
		dm.add(bmp, Const.DP_INTERF);
		bmp.scaleX = bmp.scaleY = Const.UPSCALE;
		bmp.x = Const.WID - bmp.width-4;
		bmp.y = Const.HEI - bmp.height - 125;
		return bmp;
	}
	
	
	public inline function pop(iso:Iso, str:String, ?col=0xffffff, ?duration=0, ?lateral=true) {
		var pt = iso.isoToScreen();
		return popAt(pt.x, pt.y, str, col, duration, lateral);
	}

	public function popAt(x:Float,y:Float, str:String, ?col=0xffffff, ?duration=0, ?lateral=true) {
		var tf = createField(str);
		tf.width = 200;
		tf.textColor = Color.lighten(col, 0.4);
		tf.filters = [ new flash.filters.GlowFilter(Color.darken(col,0.5),1, 2,2, 5) ];
		tf.x = Std.int(x - tf.textWidth*0.5) + (lateral ? 10 : 0);
		tf.y = Std.int(y - (lateral ? 0 : 10));
		tf.alpha = 0;
		tw.create(tf,"alpha", 1, TEaseOut, 500);
		var a = lateral ? tw.create(tf,"x", tf.x-23, TBurnIn, 500) : tw.create(tf,"y", tf.y-10, TBurnIn, 500);
		a.fl_pixel = true;
		a.onEnd = function() {
			delayer.add(function() {
				tw.create(tf,"alpha", 0, TEaseIn, 1500);
				var a = tw.create(tf,"y", tf.y-5, TEaseIn, 1500);
				a.fl_pixel = true;
				a.onEnd = function() {
					tf.parent.removeChild(tf);
				}
			}, duration);
		}
		sdm.add(tf, Const.DP_INTERF);
		
		return tf;
	}
	
	public function getAction(?a:TAction, ?data:TActionData) {
		if( a==null )
			a = data.id;
		var act = mainBar.getAction(a);
		if( act==null )
			act = randBar.getAction(a);
		return act;
	}

	
	function getActiveTarget() {
		var m = bmouse;
		var mi = getMouseIso();
		for(p in potentialTargets) {
			switch(p.type) {
				case PT_Box(x,y,w,h, spr, _) :
					if( m.x>=x && m.x<x+w && m.y>=y && m.y<y+h )
						return p;
				case PT_Iso(i) :
					if( mi==null )
						return null;
					if( i.cx==mi.x && i.cy==mi.y )
						return p;
				case PT_IsoGroup(group) :
					if( mi==null )
						return null;
					for(i in group) {
						if( i.cx==mi.x && i.cy==mi.y )
							return p;
					}
			}
		}
		return null;
	}
	
	//function updateQuery() {
		//if( curQuery==null )
			//return;
		//curQuery.x =
	//}
	
	public function showTableValue() {
		for(s in getSeats()) {
			var tf = createField("+3", FSmall, true);
			sdm.add(tf, Const.DP_INTERF);
			var pt = Iso.isoToScreenStatic(s.x, s.y);
			//var pt = buffer.localToGlobal(pt.x, pt.y);
			tf.x = pt.x-20;
			tf.y = pt.y+12;
			tf.filters = [ new flash.filters.GlowFilter(0x0,0.8, 2,2,4) ];
		}
	}
	
	function cancelAction() {
		for(p in potentialTargets)
			switch(p.type) {
				case PT_Box(x,y,w,h, s, detach) :
					if( detach==true )
						s.parent.removeChild(s);
					else
						s.filters = [];
				case PT_Iso(i) :
					i.destroy();
				case PT_IsoGroup(g) :
					for(i in g)
						i.destroy();
			}
		
		targets = new Array();
		potentialTargets = new Array();
		pendingAction = null;
		if( pendingCursor!=null ) {
			pendingCursor.parent.removeChild(pendingCursor);
			pendingCursor = null;
		}
		ActionBar.updateAll();
	}
	
	function skip() {
		for( i in 0...3 ) {
			cm.skip();
			delayer.skip();
			mt.deepnight.Particle.clearAll();
			Projectile.clearAll();
			tw.terminateAll();
		}
	}
	
	
	function main(_) {
		mt.Timer.update();
		fps = Math.round(mt.Timer.fps());
		mouse = getMouse();
		bmouse = getMouseBuffer();
		
		tw.update() ;
		delayer.update();
		cm.update();
		parallelCM.update();
		
		if( pendingCursor!=null ) {
			pendingCursor.x = mouse.x+12;
			pendingCursor.y = mouse.y+5;
			pendingCursor.visible = mouse.y<=Const.HEI-60;
		}
		
		// Rollover infos élèves
		var m = bmouse;
		var over = null;
		if( !interfaceLocked() )
			for(s in students)
				if( s.fl_visible && m.x>=s.sprite.x-8 && m.x<=s.sprite.x+8 && m.y>=s.sprite.y && m.y<s.sprite.y+24 ) {
					over = s;
					break;
				}
		if( overedStudent!=over ) {
			if( over!=null )
				showStudentTip(over);
			else
				hideStudentTip();
			if( potentialTargets.length==0 )
				if( over!=null && !over.isDone() )
					over.filterTarget.filters = [
						//new flash.filters.GlowFilter(0x89CAFA, 0.5, 2,2, 3),
						new flash.filters.GlowFilter(0xffffff, 1, 2,2, 3),
					];
				if( overedStudent!=null && !overedStudent.isDone() )
					overedStudent.filterTarget.filters = [];
		}
		overedStudent = over;
		
		if( Key.isToggled(Keyboard.C) ) {
			if( teacher.hasHats() ) {
				teacher.nextHat();
				function _onReply(_) {}
				function _onError(_) { message(Tx.ServerError); }
				tools.Codec.load("http://" + cinit._extra._urlHat, {_hat:teacher.hat}, _onReply, _onError) ;
			}
			else {
				SBANK.error01().play();
				message(Tx.NoHat);
			}
		}
			
		if( !prod ) {
			if( Key.isDown(Keyboard.SPACE) )
				skip();
				
			
			if( Key.isDown(Keyboard.P) )
				trace("mouse="+getMouse().x+", "+getMouse().y+" teacher="+teacher.cx+","+teacher.cy);
		}
			
		// DEBUG
		if( Key.isToggled(Keyboard.D) )
			stats.visible = !stats.visible;
		if( Key.isToggled(Keyboard.Q) ) {
			Const.LOWQ = !Const.LOWQ;
			//pop(teacher, Const.LOWQ ? "Qualité réduite" : "Qualité normale", 0xFF00FF, false);
			pop(teacher, Const.LOWQ ? Tx.LowQuality : Tx.StandardQuality, 0xFF00FF, false);
		}
		
		
		var activeTarget = getActiveTarget();
		if( time%3==0 ) {
			// Cibles disponibles
			for(p in potentialTargets)
				switch(p.type) {
					case PT_Box(x,y,w,h, s, detach) :
						if( detach ) {
							s.alpha = 0.5;
							s.filters = [];
						}
						else
							s.filters = [ new flash.filters.GlowFilter(Const.OVER_COLOR,1, 2,2, 3) ];
					case PT_Iso(i) :
						i.filterTarget.filters = [];
					case PT_IsoGroup(g) :
						for(i in g)
							i.filterTarget.filters = [];
				}
			// Rollover cibles
			if( activeTarget!=null ) {
				switch( activeTarget.type ) {
					case PT_Box(x,y,w,h, s, detach) :
						if( detach ) {
							s.alpha = 1;
							s.filters = [
								new flash.filters.GlowFilter(Const.OVER_COLOR, 1, 2,2, 3),
							];
						}
						else
							s.filters = [
								new flash.filters.GlowFilter(Color.lighten(Const.OVER_COLOR,0.7), 1, 2,2, 10),
								new flash.filters.GlowFilter(Const.OVER_COLOR, 1, 8,8, 0.6),
							];
					case PT_Iso(i) :
						i.filterTarget.filters = [
							new flash.filters.GlowFilter(Color.lighten(Const.OVER_COLOR,0.7), 1, 2,2, 10),
							new flash.filters.GlowFilter(Const.OVER_COLOR, 1, 8,8, 0.6),
						];
					case PT_IsoGroup(g) :
						for(i in g)
							i.filterTarget.filters = [
								new flash.filters.GlowFilter(Color.lighten(Const.OVER_COLOR,0.7), 1, 2,2, 10),
								new flash.filters.GlowFilter(Const.OVER_COLOR, 1, 8,8, 0.6),
							];
				}
			}
			// Cibles activées
			for(p in potentialTargets)
				for(t in targets)
					if( p.value==t )
						switch(p.type) {
							case PT_Box(x,y,w,h, s, detach) :
								if( detach ) {
									s.alpha = 1;
									s.filters = [
										new flash.filters.GlowFilter(0xffffff, 1, 2,2, 2),
										new flash.filters.GlowFilter(Const.ACTIVE_COLOR, 1, 4,4, 3),
									];
								}
								else
									s.filters = [
										new flash.filters.GlowFilter(Color.lighten(Const.ACTIVE_COLOR,0.9), 1, 2,2, 10),
										new flash.filters.GlowFilter(Const.ACTIVE_COLOR, 1, 8,8, 2),
									];
							case PT_Iso(i) :
								i.filterTarget.filters = [
									new flash.filters.GlowFilter(Color.lighten(Const.ACTIVE_COLOR,0.7), 1, 8,8, 10),
								];
							case PT_IsoGroup(g) :
								for(i in g)
									i.filterTarget.filters = [
										new flash.filters.GlowFilter(Color.lighten(Const.ACTIVE_COLOR,0.7), 1, 3,3, 10),
									];
						}
		}
		
		updateEntities(false) ;
		
		// Rollover divers
		allOveredIsos.sort(function(a,b) return Reflect.compare(a.clickZone.y, b.clickZone.y));
		if( overedStudent==null && activeTarget==null && allOveredIsos.length>0 ) {
			var oi = allOveredIsos[0];
			if( oi!=overedIso )
				oi.onMouseOver();
			overedIso = oi;
		}
		else if( overedIso!=null) {
			tip.hide();
			overedIso.onMouseOut();
			overedIso = null;
		}
		
		// Neige
		if( at(Class) && hasWorldMod("xmas") && time%3==0 )
			fx.streetSnow();
		
		// Plasma
		var freq = Const.LOWQ ? 4 : 2;
		if( ready && time%freq==0 && plasma.visible ) {
			var s = 0.9;
			if( at(HQ) && !Const.LOWQ ) {
				if( hasWorldMod("xmas") )
					fx.backSnow();
				else
					fx.leaves(0xA2DEF0, s);
				if( Std.random(100)<4 )
					fx.plasmaLightning();
			}
			
			// Neige maison
			if( at(Home) && hasWorldMod("xmas") && !Const.LOWQ ) {
				fx.backSnow();
				if( Std.random(100)<4 )
					fx.plasmaLightning();
			}
			
			plasma.bitmapData.perlinNoise(
				24,12, 3,
				1,
				false, true, 1, true,
				[ new flash.geom.Point(s*time*0.1, s*time*0.05), new flash.geom.Point(-s*time*0.2, -s*time*0.15) ]
			);
		}
		
		if( arrow.target!=null ) {
			arrow.spr.visible = true;
			arrow.spr.x = arrow.target.getHead().x;
			arrow.spr.y = arrow.target.getHead().y - 11 + Math.abs(Math.sin(time*0.2)*4);
		}
		
		// Evènements de fond
		if( ready && bgEventTimer--<=0 ) {
			bgEventTimer = 32*10;
			switch( curPlace ) {
				case HQ :
					fx.floatingObject();
				case Class :
				case Home :
					if( sick )
						fx.floatingObject();
			}
		}
		
		// Chrono
		if( globalTimer!=null ) {
			if( time%15==0 )
				globalTimer.bg._blink.visible = time%30==0;
			if( time%30==0 )
				updateGlobalTimer();
		}
		
		// Particules HUD
		if( ready && time%6==0 && !interfaceLocked() )
			fx.orb(hud, hud._white.x, hud._white.y);
			
		if( at(Home) && sick ) {
			if( fps>=25 )
				buffer.postFilters = [
					new flash.filters.DisplacementMapFilter(buffer.getBitmap(), new flash.geom.Point(0,0), 1,4, 0,Math.cos(time*0.12)*1.5),
				];
			else
				buffer.postFilters = [];
		}
		
		Projectile.update();
		fx.update();
		DSprite.updateAll();
		Sfx.update();
		tuto.update();
		tip.update();
		buffer.update();
		cd.update();
		time+=1;
	}
}

