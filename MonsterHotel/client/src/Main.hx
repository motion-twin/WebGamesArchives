import flash.Lib;


import mt.MLib;
import h2d.Scene;
import h2d.SpriteBatch;
import h2d.TextBatchElement;
import com.Protocol;
import Data;


class Main extends mt.Process {
	public static var ME : Main;
	public static var TOUCH = #if mobile true #else false #end;

	#if connected
	public var hdata			: Null<com.Protocol.HotelData>;
	public var currentVisit		: Null<FriendHotel>;
	public var visitMyHotel		: Null<HotelState>;
	public var clientId			: Int;
	#end
	public var scene			: h2d.Scene;
	public var gameWrapper		: h2d.CachedBitmap;
	//public var gameWrapper		: h2d.Sprite;
	public var uiWrapper		: h2d.Layers;
	public var uiTilesSb		: SpriteBatch;
	public var uiTextSb			: SpriteBatch;
	public var gameScale(default,null)	: Float;
	var clientActive			: Bool;

	//#if flash
	//public var pendingCmdsCookie: Null<String>; // used if SharedObjects don't work
	//#end

	#if( !prod && !mobile && !trailer )
	var stats					: mt.flash.Stats;
	#end
	#if console
	public var console			: ui.Console;
	#end

	var engineReady					: Bool;
	public var isTransitioning(default, null)	: Bool;
	var currentProc					: Null<H2dProcess>;
	public var avgFps(default,null)	: Float;
	var frames						: Float;
	var slowFrames					: Int;

	public var settings(get,never)	: Settings;
	#if !connected
	var localSettings				: Settings;
	#end


	#if mBase
	// mBase boot procedure
	public static function prepare(onReady:Void->Void) {
		new Main(function() {
			Main.ME.transition( function() {
				return new page.AssetsInit( function() {
					page.GameTitle.show( M_Loading );
					onReady();
				});
			});
		});
	}
	#else
	// Non-mbase boot procedure
	public static function main() {
		haxe.Timer.delay(function() {
			new Main( function() {
				Main.ME.transition( function() return new page.AssetsInit(function() {
					#if connected
					startGame( mt.net.Codec.getInitData() );
					#else
					startGame();
					#end
				}) );
			});
		}, 100); // iOS 6
	}
	#end


	public static function startGame(#if connected hdata:HotelData #end) {
		#if mBase
		Lang.init();
		#end

		#if (deviceEmulator && !mBase)
		DeviceEmulator.init();
		#end

		Data.load( mt.data.CastleLoader.getCdb("data.cdb","dataCdb") );

		ME.onAssetsReady();

		#if connected
		ME.clientId = Std.random(999999)+1;
		ME.hdata = hdata;
		Lang.init(); // second init with the right forced lang (taken from hdata.settings)
		#end


		#if preloaderTest
			var mc = new Preloader();
			flash.Lib.current.addChild(mc);
			var n = 0;
			ME.createTinyProcess(function(_) {
				if( !ME.cd.has("tick") ) {
					ME.cd.set("tick", Main.ME.rnd(5,10));
					if( n<100 )
						n++;
					mc.onUpdate(n,100);
				}
			});
		#else
			#if mBase
				// Mobile mBase
				SoundMan.ME.introMusic();
				Main.ME.transition( function() return new Game() );
			#else
				#if connected
				if( Main.ME.hdata.facebook )
					// Web Facebook
					page.GameTitle.show(M_ClickToPlay);
				else
					// Web
					Main.ME.transition(function() return new Game());
				#elseif prod
				// Local SWF (prod)
				page.GameTitle.show(M_ClickToPlay);
				#else
				// Local SWF (non-prod)
				Main.ME.transition(function() return new Game());
				#end
			#end
		#end
	}


	public dynamic function onReady() {}


	public function new(onReady:Void->Void) {
		super();
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		name = "Main";
		clientActive = true;
		engineReady = false;
		ME = this;
		frames = 0;
		slowFrames = 0;
		isTransitioning = false;
		avgFps = Const.FPS;
		this.onReady = onReady;

		gameScale = 1;

		#if( !prod && !mobile && !mBase && !trailer )
		stats = new mt.flash.Stats();
		flash.Lib.current.addChild(stats);
		#end

		#if touch
		mtnative.touch.TouchExtension.getInstance().add(GESTURE_PINCH);
		#end

		#if !connected
		try {
			localSettings = mt.deepnight.Lib.getCookie("cm2", "settings", getDefaultSettings());
		} catch(e:Dynamic) {
			localSettings = getDefaultSettings();
		}
		#end

		Lang.init();

		var engine = new h3d.Engine();
		#if( mobile || prod )
		engine.backgroundColor = alpha(0x0);
		#else
		engine.backgroundColor = alpha(0xFF00FF);
		#end
		engine.backgroundColor = 0x0;
		engine.onReady = onEngineReady;
		engine.onResized = mt.Process.resizeAll;
		engine.init();


		#if (flash || openfl)
		if( flash.Lib.current.stage==null )
			flash.Lib.current.addEventListener( flash.events.Event.ADDED_TO_STAGE, _onAddedToStage);
		else
			_onAddedToStage(null);
		#else
		_onAddedToStage(null);
		#end
	}

	function getDefaultSettings() : Settings {
		return {
			music		: false,
			sfx			: true,
			lowq		: false,
			confirmGems	: false,
			showStocks	: false,
			showStay	: false,
			forcedLang	: null,
			hideNotifs	: false,
		}
	}

	public function getClientVersion() {
		#if (flash && connected)
		return try{ Std.parseInt( flash.Lib.current.stage.loaderInfo.parameters.v ); } catch(e:Dynamic) { -1; }
		#else
		return 1;
		#end
	}

	public function gotoUrl(url:String, ?target="_self") {
		#if mBase
		App.current.dispatch(url);
		#else
		var r = new flash.net.URLRequest(url);
		flash.Lib.getURL(r, target);
		#end
	}


	public function isLogged() {
		#if connected
		return mt.device.User.isLogged();
		#else
		return true;
		#end
	}

	public function isAdmin() {
		#if( !connected || debug )
		return true;
		#else
		return hdata.admin;
		#end
	}

	function onEngineReady() {
		engineReady = true;

		scene = new Scene();

		gameWrapper = new h2d.CachedBitmap(scene, Std.int(w()), Std.int(h()));
		gameWrapper.targetScale = gameScale;
		gameWrapper.filter = true;
		gameWrapper.name = "gameWrapper";

		uiWrapper = new h2d.Layers(scene);
		uiWrapper.name = "uiWrapper";

		mt.flash.MouseWheelTrap.setup();
		Assets.minimalInit();

		#if console
		console = new ui.Console();
		#end
		hxd.System.setLoop(mainLoop);

		onReady();
	}


	function onAssetsReady() {
		uiTilesSb = new h2d.SpriteBatch(Assets.tiles.tile);
		uiWrapper.add(uiTilesSb, Const.DP_CTX_UI);
		uiTilesSb.name = "uiTilesSb";
		uiTilesSb.filter = true;

		uiTextSb = new h2d.SpriteBatch(Assets.fontHuge.tile);
		uiWrapper.add(uiTextSb, Const.DP_CTX_UI);
		uiTextSb.name = "uiTextSb";
		uiTextSb.filter = true;
	}


	var first = true;
	var transitionBmp : Null<h2d.Bitmap>;
	public function transition( initNext:Void->H2dProcess, ?onTransitionComplete:Void->Void ) {
		applyQuality();

		// Clear previous bitmap, if any
		if( transitionBmp!=null ) {
			transitionBmp.tile.dispose();
			transitionBmp.dispose();
			transitionBmp = null;
		}

		if ( !first ) {
			// Hack fix for chrome41 FP17: do not captureBitmap for the first transition
			//b = scene.captureBitmap();
			transitionBmp = mt.deepnight.Lib.h2dScreenshot(scene);
			scene.addChild(transitionBmp);
		}
		first = false;

		isTransitioning = true;

		if( currentProc!=null ) {
			currentProc.destroy();
			currentProc = null;
		}


		delayer.cancelById("transition");
		delayer.add("transition", function() {
			//forceGC(true);

			currentProc = initNext();

			if ( transitionBmp == null ) {
				isTransitioning = false;
				if( onTransitionComplete!=null )
					onTransitionComplete();
				return;
			}

			var a = tw.create(transitionBmp.alpha, 100|0, 500);
			a.onUpdate = function() {
				transitionBmp.width = w();
				transitionBmp.height = h();
			}
			a.onEnd = function() {
				transitionBmp.tile.dispose();
				transitionBmp.dispose();
				transitionBmp = null;
				isTransitioning = false;
				if( onTransitionComplete!=null )
					onTransitionComplete();
			}
		}, 100);
	}


	public function forceGC(major:Bool) {
		if( major )
			h3d.Engine.getCurrent().mem.startTextureGC();

		#if cpp
		cpp.vm.Gc.run(major);
		#elseif flash
		flash.system.System.pauseForGCIfCollectionImminent(major ? 0.25 : 0.75);
		#end
	}


	function _onAddedToStage(_) {
		#if (flash || openfl)
		flash.Lib.current.removeEventListener( flash.events.Event.ADDED_TO_STAGE, _onAddedToStage);
		flash.Lib.current.stage.addEventListener( flash.events.Event.ACTIVATE, onActivate);
		flash.Lib.current.stage.addEventListener( flash.events.Event.DEACTIVATE, onDeactivate);
		#end
	}

	function onDeactivate(_) {
		if( clientActive ) {
			clientActive = false;
			mt.flash.Sfx.muteGlobal();

			#if mobile
			mt.flash.Timer.pause();
			if( engineReady ) {
				scene.visible = clientActive;
				renderScene();
			}
			#end
		}
	}

	function onActivate(_) {
		if( !clientActive ) {
			clientActive = true;
			mt.flash.Sfx.unmuteGlobal();

			#if mobile
			mt.flash.Timer.resume();
			if( engineReady ) {
				scene.visible = clientActive;
				renderScene();
			}
			#end
		}
	}


	override function onResize() {
		#if deviceEmulator
		if( scene!=null )
			scene.setScale( DeviceEmulator.ratio );
		#end

		super.onResize();

		if( !engineReady )
			return;

		#if !deviceEmulator
		engine.resize(w(), h());
		#end

		gameWrapper.width = MLib.ceil( w()*gameScale );
		gameWrapper.height = MLib.ceil( h()*gameScale );

		#if( !prod && !mobile && !mBase && !trailer )
		if( stats!=null ) {
			stats.x = w()-stats.width;
			stats.y = h()-stats.height;
		}
		#end
	}

	function setGameScale(s:Float) {
		s = MLib.fclamp(s, 0,1);
		if( gameScale!=s ) {
			gameScale = s;
			gameWrapper.targetScale = gameScale;
			mt.Process.resizeAll();
		}
	}

	public static function getScale(px:Float, ?cm=1.0) {
		#if responsive
		var wcm = mt.Metrics.px2cm( mt.Metrics.w() );
		return ( mt.Metrics.cm2px(cm)/px ) * ( wcm>=15 ? wcm/15 : 1 );
		#else
		return 1.0;
		#end
	}


	override function update() {
		super.update();
		#if console
		console.update();
		#end
		#if (deviceEmulator && !mBase)
		DeviceEmulator.update();
		#end
	}


	function renderScene() {
		if( engineReady ) {
			var e = h3d.Engine.getCurrent();
			e.render(scene);
			e.restoreOpenfl();
		}
	}

	public static inline function fps() return mt.flash.Timer.fps();


	inline function get_settings() {
		#if connected
		if( hdata==null )
			return getDefaultSettings();
		else {
			if( hdata.settings.hideNotifs==null )
				hdata.settings.hideNotifs = false;
			return hdata.settings;
		}
		#else
		return localSettings;
		#end
	}


	public function applyQuality() {
		if( settings==null )
			return;

		var low = settings.lowq;
		#if responsive
			#if flash
			// Fake mobile (air)
			setGameScale( low ? 0.65 : 1 );
			#else
			// Mobile
			setGameScale( low ? (mt.Metrics.dp2px(1)>=1.7 ? 0.5 : 0.6) : 0.75 );
			#end
		#else
		// Flash
		setGameScale( low ? 0.65 : 1 );
		#end
	}

	static function mainLoop() {
		#if mobile
		if( !ME.clientActive )
			return;
		#end

		mt.flash.Timer.update();
		mt.flash.Key.update();

		// Average FPS
		ME.avgFps += (mt.flash.Timer.fps() - ME.avgFps ) * 0.3;

		// H2D events
		ME.scene.checkEvents();

		// Updates + frame skips
		ME.frames += mt.flash.Timer.tmod;
		while( ME.frames>1 ) {
			mt.Process.updateAll(1);
			//mt.deepnight.Process.updateAll( ME.frames<2 );
			ME.frames--;
		}

		ME.renderScene();
	}
}

