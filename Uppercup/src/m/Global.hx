package m;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.deepnight.Color;
import mt.deepnight.Lib;
import mt.deepnight.FParticle;
import mt.MLib;
import mt.Metrics;
import mt.deepnight.Process;
import mt.deepnight.FProcess;
import mt.deepnight.slb.assets.TexturePacker;
import mt.deepnight.slb.BLib;
import mt.flash.Sfx;
import mt.flash.Timer;
import googleAnalytics.Stats;
import Const;


@:bitmap("assets/splashNoBall.png") class GfxSplashNoBall extends flash.display.BitmapData {}


class Global extends FProcess {
	public static var SBANK = mt.flash.Sfx.importDirectory("sfx");
	static var FADEOUT = 250;
	static var FADEIN = 350;
	public static var ME		: Global;

	var mwrapper			: Sprite;
	var mask				: Bitmap;
	var loading				: Bitmap;
	public var tiles		: BLib;
	public var playerCookie	: PlayerCookie;

	var music				: Sfx;
	public var variant		: GameVariant;

	#if !prod
	public var dstats		: mt.flash.Stats;
	#end

	public function new(p:flash.display.Sprite) {
		super(p);

		ME = this;

		//should defer on next frame ?
		Ga.init();
		Chartboost.init();

		//try Sharer.init() catch(e:Dynamic) {trace("init failed");}
		Sharer.init();

		new IapMan();

		TeamInfos.readXml();

		playerCookie = new PlayerCookie();
		variant = Normal;

		// Restore sound states
		if( !playerCookie.data.sfx )
			Sfx.muteChannel(0);

		if( !playerCookie.data.crowdSfx )
			Sfx.muteChannel(Crowd.CHANNEL);

		if( !playerCookie.data.music )
			Sfx.muteChannel(1);

		setLang(playerCookie.data.lang);
		music = getLocalizedMusic();
		music.setChannel(1);
		Sfx.setChannelVolume(1, 1);


		// Tilesheet
		tiles = TexturePacker.importXml("gear.xml");
		tiles.initBdGroups();

		mwrapper = new Sprite();
		root.addChild(mwrapper);
		FProcess.DEFAULT_PARENT = mwrapper;

		#if !prod
		dstats = new mt.flash.Stats();
		//root.addChild(dstats);
		#end

		mask = new Bitmap( new GfxSplashNoBall(0,0) );
		root.addChild(mask);

		initLoading();

		onResize();

		#if prod
		new Logo();
		#else
		//new Logo();
		//new Intro();
		//new Credits();
		new StageSelect(4);
		//new Settings(false);
		//new Thanks();
		//new Unlocked(Lang.UnlockedEpic);
		//new MatchIntro(5);
		//new MatchEnd(TeamInfos.getByLevel(16, Normal), true, 3);
		//new BuyScreen();
		//new EndGame();
		//new Rate(-1,false);
		//variant = Epic; new Game(4);
		//new Game(TeamInfos.getByLevel(15, Normal), Normal);
		//new Multiplayer();
		//new LangSelect();
		//new HandModeSelect(1);
		//new Twinoid();
		#end

		if ( playerCookie.data.nbLaunch == 1 ){
			Ga.event("general", "launch", "firstRun");

			#if ios
			Ga.event("general", "install", "ios");
			#elseif android
			Ga.event("general", "install", "android");
			#end
		}

		Ga.event("general", "launch", "run", playerCookie.data.nbLaunch);

		#if ios
		Ga.event("general", "launch", "ios");
		#elseif android
		Ga.event("general", "launch", "android");
		#end
	}


	public inline function getFont() {
		return switch( playerCookie.data.lang ) {
			case "ru" : {id:"int", size:16, cyrillic:true}
			default : {id:"big", size:16, cyrillic:false}
		}
	}

	public function getVariantName(v:GameVariant) {
		return switch( v ) {
			case Normal : Lang.Normal;
			case Hard : Lang.Hard;
			case Epic : Lang.Epic;
		}
	}


	inline function getLocalizedMusic() {
		return if( playerCookie.data.lang=="fr" )
			SBANK.music_fr();
		else
			SBANK.music_en();
	}


	public inline function isLowQuality() {
		return playerCookie.data.lowq;
	}


	public function getLang() {
		return playerCookie.data.lang;
	}

	public function setLang(id:String, ?temp=false) {
		var raw = haxe.Resource.getString(id);
		var en = haxe.Resource.getString("en");
		if( raw==null )
			raw = en;
		Lang.init(raw);
		Lang.initFallback(en);

		playerCookie.data.lang = id;

		if( !temp ) {
			playerCookie.save();

			if( music!=null && music.isPlaying() && hasMusic() ) {
				stopMusic();
				music = getLocalizedMusic();
				startMusic();
			}

			initLoading();
			onResize();
		}
	}


	function initLoading() {
		if( loading!=null ) {
			loading.bitmapData.dispose();
			loading.bitmapData = null;
			loading.parent.removeChild(loading);
			loading = null;
		}

		var tf = createField(Lang.Loading, FBig, true);
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x5A6F8D,1, 0,0),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
			new flash.filters.GlowFilter(0xFFFFFF,0.2, 2,2,10),
		];
		loading = Lib.flatten(tf);
		root.addChild(loading);
		loading.bitmapData = Lib.scaleBitmap(loading.bitmapData, 6, HIGH, true);
		loading.visible = false;
	}


	override function onActivate() {
		super.onActivate();
		Sfx.enable();
	}

	override function onDeactivate() {
		super.onDeactivate();
		Sfx.disable();
		Sfx.terminateTweens();
	}



	override function unregister() {
		super.unregister();

		tiles.destroy();
		loading.bitmapData.dispose(); loading.bitmapData = null;
		ME = null;
	}


	override function onResize() {
		super.onResize();

		if( mask==null ) return;

		var w = w();
		var h = h();

		Const.WID = w;
		Const.HEI = h;

		//mask.width = Const.WID;
		//mask.height = Const.HEI;

		var sx = w/mask.bitmapData.width;
		var sy = h/mask.bitmapData.height;
		mask.scaleX = mask.scaleY = MLib.fmax(sx,sy);
		mask.x = Std.int(w*0.5 - mask.width*0.5);
		mask.y = Std.int(h*0.5 - mask.height*0.5);

		loading.x = Std.int(Const.WID*0.5 - loading.width*0.5);
		loading.y = Std.int(Const.HEI*0.5 - loading.height*0.5);

		// Upscale
		var iw = 1500;
		var wratio = w/iw;

		var ih = 938;
		var hratio = h/ih;
		Const.UPSCALE = 3*MLib.fmin(wratio,hratio);
		if( Const.UPSCALE<1 )
			Const.UPSCALE = 1;

		//trace("wr="+Lib.prettyFloat(wratio)+" hr="+Lib.prettyFloat(hratio));
		//trace("RESIZE "+Const.WID+"x"+Const.HEI+" up="+Const.UPSCALE+" dpi="+Metrics.dpi()+" pdensity="+Metrics.pixelDensity());

		#if !prod
		dstats.x = Const.WID-60;
		dstats.y = Const.HEI-100;
		#end

		//Ga.event('option', 'resize', Std.string(Const.WID+"x"+Const.HEI) );
	}


	public function createField(str:String, font:Font, ?adjustSize=false) {
		var f = new flash.text.TextFormat();
		switch(font) {
			case FSmall : f.font = "small"; f.size = 16;
			case FBig : f.font = getFont().id; f.size = getFont().size; str = StringTools.replace(str, " ", "  ");
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


	public function setLowQuality() {
		if( playerCookie.data.lowq )
			return;
		playerCookie.data.lowq = true;
		playerCookie.save();
	}

	public function toggleQuality() {
		var flag = !playerCookie.data.lowq;
		playerCookie.data.lowq = flag;
		playerCookie.data.forcedQuality = true;
		playerCookie.save();
		return flag;
	}

	public function toggleSfx() {
		var flag = !playerCookie.data.sfx;
		playerCookie.data.sfx = flag;
		playerCookie.save();
		if( flag )
			Sfx.unmuteChannel(0);
		else
			Sfx.muteChannel(0);
		return flag;
	}

	public function toggleCrowdSfx() {
		var flag = !playerCookie.data.crowdSfx;
		playerCookie.data.crowdSfx = flag;
		playerCookie.save();
		if( flag )
			Sfx.unmuteChannel(Crowd.CHANNEL);
		else
			Sfx.muteChannel(Crowd.CHANNEL);
		return flag;
	}

	public function hasSfx() {
		return playerCookie.data.sfx;
	}

	public function hasCrowdSfx() {
		return playerCookie.data.crowdSfx;
	}

	public function toggleMusic(?autoStart=true) {
		var flag = !playerCookie.data.music;
		playerCookie.data.music = flag;
		playerCookie.save();
		if( flag )
			Sfx.unmuteChannel(1);
		else
			Sfx.muteChannel(1);

		if( flag && autoStart )
			startMusic();

		if( !flag )
			stopMusic();

		return flag;
	}

	public function hasMusic() {
		return playerCookie.data.music;
	}

	public function startMusic() {
		music.stop();
		music.playLoop();
		music.setVolume(1);
	}

	public function stopMusic() {
		music.stop();
	}

	function musicTransition(s:Sfx, ?loop=true, ?vol=1.0) {
		if( !hasMusic() )
			return;

		var m = music;
		m.fade(0, 400).onEnd = function() {
			m.stop();
		}
		delayer.add(function() {
			if( loop )
				s.playLoopOnChannel(1);
			else
				s.play();
		}, 150);
		music = s;
	}

	public function switchMusic_map() {
		musicTransition( SBANK.music_map_loop(), 0.7 );
	}

	public function switchMusic_intro() {
		musicTransition( getLocalizedMusic() );
	}

	//public function switchMusic_win() {
		//musicTransition( SBANK.music_Jingle_victoire_master(), false );
	//}

	//public function switchMusic_lose() {
		//musicTransition( SBANK.music_Jingle_defaite_master(), false );
	//}

	public function fadeOutMusic() {
		if( hasMusic() )
			music.fade(0, 3000).onEnd = function() {
				stopMusic();
			}
	}

	public function isBeatFrame() {
		if( hasMusic() && music.isPlaying() ) {
			var bpm = 489;
			var beatStart = 4000;
			var p = music.getPlayCursor() - beatStart;
			var ratio = p/bpm - Std.int(p/bpm);

			if( ratio>=0 && ratio<=0.2 ) {
				if( cd.has("beatFrame") )
					return false;
				else {
					cd.set("beatFrame", 5);
					return true;
				}
			}
			else
				cd.unset("beatFrame");
		}
		return false;
	}


	var CACHED_VERSION : String = null;
	public function getVersion() {
		if( CACHED_VERSION==null ) {
			var raw = haxe.Resource.getString("manifest");
			if( raw==null )
				return "Manifest?";
			var start = raw.indexOf("<versionNumber>") + "<versionNumber>".length;
			var end = raw.indexOf("</versionNumber>");
			var v = raw.substr(start,end-start);
			var device =
				if( Lib.isIos() ) "iOS";
				else if( Lib.isAndroid() ) "And";
				else "Flash";
			#if !prod
			device+="_dev";
			#elseif press
			device+="_press";
			#end
			CACHED_VERSION = device +"_"+ v;
		}
		return CACHED_VERSION;
	}


	public function exitApp() {
		Ga.event("general", "launch", "exit");
		destroy();
		flash.desktop.NativeApplication.nativeApplication.exit();
	}

	//public function onGameUnlocked(from:MenuBase) {
		//run( from, function() new Thanks(), true );
	//}

	public function fadeIn(?onEnd:Void->Void) {
		tw.terminateWithoutCallbacks(mask.alpha);
		tw.terminateWithoutCallbacks(loading.alpha);

		tw.create(loading.x,-loading.width, FADEIN);
		tw.create(loading.alpha, 1>0, FADEIN).onEnd = function() {
			loading.visible = false;
		}

		mask.visible = true;
		tw.create(mask.alpha, 1>0, FADEIN).onEnd = function() {
			mask.visible = false;
			if( onEnd!=null )
				onEnd();
		}
	}

	function fadeOut(?onEnd:Void->Void, showLoading:Bool) {
		tw.terminateWithoutCallbacks(mask.alpha);
		tw.terminateWithoutCallbacks(loading.alpha);

		loading.visible = showLoading;
		loading.x = Const.WID;
		tw.create(loading.alpha, 0>1, FADEOUT);
		tw.create(loading.x, Const.WID*0.5-loading.width*0.5, FADEOUT);


		mask.visible = true;
		tw.create(mask.alpha, 0>1, FADEOUT).onEnd = function() {
			if( onEnd!=null )
				onEnd();
		}
	}


	public inline function fps() {
		return Timer.fps();
	}


	public function run(toDestroy:FProcess, cb:Void->Void, showLoading:Bool) {
		if( toDestroy!=null ) {
			if( toDestroy.cd.has("fading") )
				return;

			toDestroy.cd.set("fading", 9999);
		}

		fadeOut(function() {
			if( toDestroy!=null ) {
				toDestroy.root.mouseChildren = toDestroy.root.mouseEnabled = false;
				toDestroy.destroy();
				FParticle.clearAll();
			}

			delayer.add( function() {
				cb();
			}, 2);
		}, showLoading);
	}

	override function update() {
		super.update();
		Sfx.update();
	}

	override function render() {
		super.render();
	}
}