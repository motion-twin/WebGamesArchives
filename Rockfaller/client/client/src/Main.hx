import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

import Protocol;

import process.ProcessManager;
import data.*;
import process.*;
import manager.SoundManager;
import manager.LifeManager;
import manager.TutoManager;

class Main {

// STATIC
	public static var ME		: Main;

	static var engine					: h3d.Engine;
	public static var MAIN_SCENE		: h2d.Scene;
	public static var INPUT				: Input;


	var tmodOffset		: Float = 0;
	public var gameIsLaunched(default,null)	: Bool;

	var hsLoading		: mt.deepnight.slb.HSprite;

	public var avgFps	: Float;

	#if mBase @:allow(App) #end
	var ACTIVE			: Bool;

	static var workers			: Null<Array<mt.Worker>> = null;
	static var workerCounter	: Int = 0;

	public function new() {
		ME = this;
		
		ACTIVE = true;

		gameIsLaunched = false;

	#if standalone
		PREPARE_FIRST_INIT(null);
	#end
	}

	public static function PREPARE_FIRST_INIT(onReady:Void->Void) {
		h2d.Drawable.DEFAULT_FILTER = true;
		initWorkers();

		if (Main.ME == null)
			new Main();

		INPUT = new Input();

		engine = new h3d.Engine();
		engine.onReady = function() {
			MAIN_SCENE = new h2d.Scene();
			mt.deepnight.deprecated.HProcess.GLOBAL_SCENE = MAIN_SCENE;

			new PreloaderH2D(onReady);
			PreloaderH2D.ME.showPreloader();

			engine.onResized = function () {
				Settings.RESIZE();
			}

			hxd.System.setLoop(ME.update);
		};

		engine.init();

	#if debug
		var stats = new mt.flash.Stats();
		stats.y = Std.int(mt.Metrics.h() * 0.5);
		//flash.Lib.current.addChild(stats);
	#end
	}

#if mBase
	public function getInitData() {
		LevelDesign.LOAD_USERLOCAL();

		var forceRetry = false;
		if( LevelDesign.AR_LEVEL.length == 0 ){
			//trace("no levels data => forceRetry");
			forceRetry = true;
		}
		if( LevelDesign.USER_LOCAL==null || LevelDesign.USER_LOCAL.mobileID==null ){
			//trace("no USER_LOCAL or mobileId => forceRetry");
			forceRetry = true;
		}
		if( LevelDesign.USER_DATA == null ){
			//trace("no USER_DATA => forceRetry");
			forceRetry = true;
		}

		function onFromServer(d:ProtocolCom) {
			trace(d);
			switch (d) {
				case ProtocolCom.SendInitData(d) :
					LevelDesign.URL_AVATAR = d.avatar;
					LevelDesign.SET_AR_LEVEL( d.levels );
					if( d.mobileId != null ){
						LevelDesign.USER_LOCAL.mobileID = d.mobileId;
						LevelDesign.USER_LOCAL.numGames = 0;
					}
					LevelDesign.FRIENDS = d.friends;
					LevelDesign.UPDATE_USER_DATA(d.userData);
					launchGame();
				default :
			}
		}
		function onError(d) {
			//trace("getInitData failed, forceRetry: "+forceRetry);
			trace(d);
			if( forceRetry )
				haxe.Timer.delay(getInitData, 1000); // retry in 1s
			else
				launchGame();
		}
		
		var ul = LevelDesign.USER_LOCAL;
		var genMobileId = ul.mobileID==null;
		if( ul.mobileID != null && ul.numGames > 0xFFFF-0x400 )
			genMobileId = true;

		MobileServer.SEND_PROTOCOL( ProtocolCom.DoGetInitData(genMobileId, LevelDesign.MAX_LEVEL_CLIENT), onFromServer, onError, forceRetry ? 3 : 0 );
	}

	public function showConnect() {
		if (PreloaderH2D.ME == null)
			new PreloaderH2D(null);
		PreloaderH2D.ME.showConnect();
	}

	public function killGame() {
		if (gameIsLaunched) {
			gameIsLaunched = false;
			
			ProcessManager.DESTROY_POPUP();

			if (Game.ME != null)
				Game.ME.destroy();

			if (Levels.ME != null)
				Levels.ME.destroy();
			
			mt.motion.FlumpTP.DESTROY();

			hsLoading.dispose();
			hsLoading = null;
		}
	}
#end

	public function launchGame() {
		#if mobile
		mt.net.Http.DEFAULT_TIMEOUT = 60;
		data.LevelDesign.SAVE_USERLOCAL();
		#end

		if (!gameIsLaunched) {
			gameIsLaunched = true;

		// UPDATE GAME
			hsLoading = Settings.SLB_FX2.h_getAndPlay("loading");
			hsLoading.filter = true;
			hsLoading.setCenterRatio(0.5, 0.5);
			hsLoading.visible = false;
			MAIN_SCENE.addChild(hsLoading);
			hideLoading();

			mt.fx.Fx.DEFAULT_MANAGER = new mt.fx.Manager();

			LevelDesign.CREATE();

			avgFps = Settings.FPS;
			mt.flash.Timer.wantedFPS = Settings.FPS;

			SoundManager.SET_VOLUME();

			LifeManager.INIT();
		}

		if (Settings.INIT_CLIENT != null && Settings.INIT_CLIENT.level > -1) {
			#if debug
				ProcessManager.ME.goTo(null, process.Game, [Settings.INIT_CLIENT.level, false]);
			#else
				ProcessManager.ME.goTo(null, process.Levels, [LevelDesign.USER_DATA.levelMax, false]);
				//ProcessManager.ME.goTo(null, process.Home, true);
			#end
		}
		else {
			if (LevelDesign.USER_DATA.levelMax < 2)
				ProcessManager.ME.goTo(null, process.Game, [1, true]);
			else
				ProcessManager.ME.goTo(null, process.Levels, [LevelDesign.USER_DATA.levelMax, false]);
				//ProcessManager.ME.goTo(null, process.Levels, [7, true]);
				//ProcessManager.ME.goTo(null, process.Levels, [1, true]);
				//ProcessManager.ME.goTo(null, process.Game, [96, false]);
		}
	}

	public function showLoading() {
		if (hsLoading != null && !hsLoading.visible) {
			hsLoading.toFront();
			hsLoading.visible = true;

			hsLoading.scaleX = hsLoading.scaleY = Settings.STAGE_SCALE / 2;
			hsLoading.x = Std.int(Settings.STAGE_WIDTH / 2);
			hsLoading.y = Std.int(Settings.STAGE_HEIGHT - hsLoading.frameData.hei * hsLoading.scaleY);
		}
	}

	public function hideLoading() {
		if (hsLoading != null && hsLoading.visible) {
			hsLoading.visible = false;
		}
	}

	public function onDeactivate() {
	#if mobile
		ACTIVE = false;
		mt.flash.Timer.pause();
		MAIN_SCENE.visible = ACTIVE;
	#end
	}

	public function onActivate() {
	#if mobile
		ACTIVE = true;
		mt.flash.Timer.resume();
		MAIN_SCENE.visible = ACTIVE;
	#end
	}

	var c = 0;
	public function update() {
		if (!ACTIVE)
			return;

		if( workers != null )
			for( w in workers )
				w.checkDone();

		if (INPUT == null || !INPUT.p) {
			hxd.Timer.update();

			mt.flash.Timer.update();

			avgFps += (mt.flash.Timer.fps() - avgFps ) * 0.3;

			tmodOffset += hxd.Timer.tmod;

			for (i in 0...Std.int(tmodOffset)) {
				if (gameIsLaunched)
					LifeManager.UPDATE();

				mt.deepnight.deprecated.Process.updateAll();

				if (mt.fx.Fx.DEFAULT_MANAGER != null)
					mt.fx.Fx.DEFAULT_MANAGER.update();

				tmodOffset--;
			}

			if (c == Settings.FPS) {
				c = 0;
				showFPS();
			}
			c++;

			engine.render(MAIN_SCENE);

			engine.restoreOpenfl();
		}

		SoundManager.UPDATE();
	}

	static function initWorkers(){
		if( workers != null )
			return;

		workers = [];
		for( i in 0...2 )
			workers.push( new mt.Worker() );
	}

	public static function getWorker(){
		return workers[ (workerCounter++)%workers.length ];
	}

	var textFPS:h2d.Text;
	function showFPS() {
		//if (Settings.FONT_BENCH_NINE_90 != null) {
			//if (textFPS == null) {
				//textFPS = new h2d.Text(Settings.FONT_BENCH_NINE_90, MAIN_SCENE);
				//textFPS.y = Std.int(Settings.STAGE_HEIGHT * 0.25);
				//textFPS.textColor = 0xFFFFFFFF;
			//}
			//if (textFPS != null) {
				//textFPS.text = Std.string(Std.int(avgFps * 100) / 100);
				//textFPS.toFront();
			//}
		//}
	}

	public function destroyTextFPS() {
		if (textFPS != null)
			textFPS.dispose();
		textFPS = null;
	}

	var dpStart = 0;
	var dpOld : h2d.Sprite  = null;
	public function showDrawProfiler() {
		var scene = mt.deepnight.deprecated.HProcess.GLOBAL_SCENE;
		hxd.DrawProfiler.TIP_FG_COL = 0x00FF32;
		hxd.DrawProfiler.TIP_SHADOW = false;
		hxd.DrawProfiler.BG = 0x7f000000;
		if ( dpOld != null) dpOld.remove();
		var t = hxd.DrawProfiler.analyse( scene );
		t = t.slice( dpStart );
		dpStart += 10;
		dpOld = hxd.DrawProfiler.makeGfx( t );
		scene.addChild( dpOld );
	}

	public function resetDrawProfiler() {
		dpStart = 0;
		if ( dpOld != null) dpOld.remove();
	}
}
