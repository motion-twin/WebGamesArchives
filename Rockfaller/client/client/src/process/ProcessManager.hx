package process;

import mt.deepnight.slb.HSprite;
import mt.deepnight.deprecated.HProcess;

import Protocol;

import data.LevelDesign;
import data.Settings;
import manager.SoundManager;
import process.*;
import process.popup.*;


/**
 * ...
 * @author Tipyx
 */

class ProcessTransition {
	var manager : ProcessManager;

	var oldProcess : HProcess;
	var c : Class<Dynamic>;
	var args : Null<Array<Dynamic>>;

	
	var subLoader : SubLoader;
	var waitReady : mt.deepnight.deprecated.TinyProcess;
	var newProcess : ProcessManaged;

	
	@:allow(process.ProcessManager)
	function new( manager:ProcessManager, oldProcess:HProcess, c:Class<Dynamic>, ?args:Array<Dynamic> ){
		this.manager = manager;
		this.oldProcess = oldProcess;
		this.c = c;
		this.args = args;

		manager.startLoading( onStarted, true, false );
	}

	function onStarted(){
		if (oldProcess != null)
			oldProcess.destroy();
		oldProcess = null;

		h3d.Engine.getCurrent().mem.startTextureGC();
		h3d.Engine.getCurrent().mem.cleanBuffers();
		#if cpp
		cpp.vm.Gc.run( true );
		#end

		if( c == process.Game ){
			SubLoader.disposeLevels();
			subLoader = SubLoader.prepareGame(args[0], onPrepared);
		}else if( c == process.Levels ){
			SubLoader.disposeGame();
			subLoader = SubLoader.prepareLevels(args[0], onPrepared);
		}
	}

	function onPrepared(){
		subLoader = null;

		newProcess = Type.createInstance(c, args);
		newProcess.root.visible = false;

		manager.root.toFront();
		if( PreloaderH2D.ME != null )
			PreloaderH2D.ME.root.toFront();

		waitReady = manager.createTinyProcess();
		waitReady.onUpdate = checkReady;
	}

	function checkReady(){
		if( newProcess.isReady ) {
			waitReady.destroy();
			waitReady = null;

			newProcess.root.visible = true;
			newProcess.onReady();
			manager.endLoading( onComplete );
		}
	}

	function onComplete(){
		manager.isTransiting = false;
		manager = null;
	}

}

class ProcessManager extends mt.deepnight.deprecated.HProcess
{
	public static var ME		: ProcessManager;

	var loadingScreen	: h2d.Interactive;
	var blackScreen		: h2d.Graphics;
	var logo			: h2d.Bitmap;
	var loadingTxt  	: h2d.Text;

	var arClouds		: Array<{hs:HSprite, tw:mt.motion.Tween}>;

	var tweener			: mt.motion.Tweener;

	@:allow(process.ProcessTransition)
	var isTransiting	: Bool;

	var loadingWithLogo : Bool;

	public function new() {
		super();

		ME = this;

		arClouds = [];

		isTransiting = false;

		loadingScreen = new h2d.Interactive(0,0);
		loadingScreen.visible = false;

		blackScreen = new h2d.Graphics(loadingScreen);
		logo = new h2d.Bitmap( Settings.TILE_LOADER_INGAME, loadingScreen );
		loadingTxt = new h2d.Text( Settings.FONT_MOUSE_DECO_80, loadingScreen );
		loadingTxt.text = data.Lang.T._("Chargement");

		root.addChild(loadingScreen);

		tweener = new mt.motion.Tweener();

		root.toFront();

		onResize();
	}

	public function goTo( oldProcess:HProcess, c:Class<Dynamic>, ?args:Array<Dynamic> ) {
		if (isTransiting)
			return;

		if (args == null)
			args = [];


		isTransiting = true;
		new ProcessTransition(this,oldProcess,c,args);
	}


	@:allow(process.ProcessTransition)
	#if mBase @:allow(App) #end
	function startLoading( onComplete:Void->Void, inclLogo:Bool, force:Bool ) {
		loadingWithLogo = inclLogo;

		if( (force || PreloaderH2D.ME == null) && !loadingScreen.visible ) {
			//trace("startLoading normal");
			root.toFront();
			loadingScreen.visible = true;
			onResize();

			var tw = tweener.create().to(0.2 * Settings.FPS, blackScreen.alpha = 1);
			if( loadingWithLogo )
				tw.onUpdate = logoLoadingupdate;
			else
				logo.alpha = loadingTxt.alpha = 0;
			tw.onComplete = onComplete;
		}else {
			//trace("bypass startLoading (loadingScreen.visible="+loadingScreen.visible+")");
			haxe.Timer.delay(onComplete, 1);
		}
	}

	function logoLoadingupdate(_){
		if( logo!=null && loadingTxt!=null && blackScreen!=null )
			logo.alpha = loadingTxt.alpha = blackScreen.alpha;
	}

	@:allow(process.ProcessTransition)
	function endLoading( onComplete : Void -> Void ) {

		if( loadingScreen.visible ) {
			//trace("endLoading normal");
			var tw = tweener.create().to(0.2 * Settings.FPS, blackScreen.alpha = 0);
			if( loadingWithLogo )
				tw.onUpdate = logoLoadingupdate;
			
			tw.onComplete = function() {
				if( loadingScreen != null )
					loadingScreen.visible = false;
				onComplete();				
			};
		}else if( PreloaderH2D.ME != null ) {
			//trace("endLoading normal H2D");
			startLoading( function() {
				if( PreloaderH2D.ME != null )
					PreloaderH2D.ME.destroy();
				endLoading(onComplete);
			}, false, true);
		}else {
			//trace("bypass endLoading");
			haxe.Timer.delay(onComplete, 1);
		}
	}

	public function cancelLoading() {
		if( loadingScreen.visible ) {
			//trace("cancelLoading");
			loadingScreen.visible = false;
			blackScreen.alpha = 0;
		}else {
			//trace("ignore cancelLoading");
		}

	}

	public function showPause(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.Pause(hp);
	}

	public function hidePause(parent:HProcess, pauseScreen:process.popup.Pause) {
		delayer.addFrameBased(function () {
			parent.resume();
			pauseScreen.destroy();
			pauseScreen = null;
		}, 1);
	}

	public function showCollection(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.Collection(hp);
	}

	public function hideCollection(parent:HProcess, collectionScreen:process.popup.Collection) {
		delayer.addFrameBased(function () {
			parent.resume();
			collectionScreen.destroy();
			collectionScreen = null;
		}, 1);
	}

	public function showShop(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.Shop(hp);
	}

	public function hideShop(parent:HProcess, shopScreen:process.popup.Shop) {
		delayer.addFrameBased(function () {
			parent.resume();
			shopScreen.destroy();
			shopScreen = null;
		}, 1);
	}

	public function showPickaxeShop(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.BoosterPickaxe(hp);
	}

	public function hidePickaxeShop(parent:HProcess, shopScreen:process.popup.BoosterPickaxe) {
		delayer.addFrameBased(function () {
			parent.resume();
			shopScreen.destroy();
			shopScreen = null;
		}, 1);
	}

	public function showLife(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.Life(hp);
	}

	public function hideLife(parent:HProcess, lifeScreen:process.popup.Life) {
		delayer.addFrameBased(function () {
			parent.resume();
			lifeScreen.destroy();
			lifeScreen = null;
		}, 1);
	}

	public function showMail(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.Mail(hp);
	}

	public function hideMail(parent:HProcess, mailScreen:process.popup.Mail) {
		delayer.addFrameBased(function () {
			parent.resume();
			mailScreen.destroy();
			mailScreen = null;
		}, 1);
	}

	public function showAskLife(hp:HProcess, frt:FriendRequestType) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.AskLife(hp, frt);
	}

	public function hideAskLife(parent:HProcess, askLifeScreen:process.popup.AskLife) {
		delayer.addFrameBased(function () {
			parent.resume();
			askLifeScreen.destroy();
			askLifeScreen = null;
		}, 1);
	}

	public function showAskLog(hp:HProcess, laterAvailable:Bool) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.AskLog(hp, laterAvailable);
	}

	public function hideAskLog(parent:HProcess, askLogScreen:process.popup.AskLog) {
		delayer.addFrameBased(function () {
			parent.resume();
			askLogScreen.destroy();
			askLogScreen = null;
		}, 1);
	}

	public function showAskMobile(hp:HProcess) {
		if (hp != null)
			hp.pause();
		else
			throw "No HProcess Active";
		new process.popup.AskMobile(hp);
	}

	public function hideAskMobile(parent:HProcess, askMobileScreen:process.popup.AskMobile) {
		delayer.addFrameBased(function () {
			parent.resume();
			askMobileScreen.destroy();
			askMobileScreen = null;
		}, 1);
	}

	public function showError(?pe:ProtocolError = null) {
		Main.MAIN_SCENE.disposeAllChildren();

		new process.popup.Error(null, pe);
	}

	public function initClouds() {
		//var widCloud = Settings.SLB_PLANET.getFrameData("cloud", 0).wid * Settings.STAGE_SCALE * 2;
		//
		//var maxJ = Std.int(Settings.STAGE_WIDTH / widCloud) + 1;
		//
		//SoundManager.CLOUDS_SFX();
		//
		//for (i in -1...5) {
			//for (j in 0...maxJ) {
				//var cloud1 = Settings.SLB_PLANET.h_get("cloud", 0);
				//cloud1.filter = true;
				//cloud1.scaleX = cloud1.scaleY = Settings.STAGE_SCALE * 4;
				//cloud1.y = Std.int(i * (cloud1.height / 2));
				//root.addChild(cloud1);
				//
				//var tw = tweener.create();
				//
				//if (i % 2 == 0) {
					//cloud1.x = Std.int(Settings.STAGE_WIDTH + (j * cloud1.width / 2));
					//tw.to(1 * Settings.FPS, cloud1.x -= (Settings.STAGE_WIDTH + 2 * cloud1.width));
					//if (i == 4 && j == maxJ - 1) {
						//function onUpdate(e) {
							//if (cloud1.x < Settings.STAGE_WIDTH - cloud1.width && Home.ME != null)
								//process.ProcessManager.ME.goTo(Home.ME, Levels, [LevelDesign.USER_DATA.levelMax, false]);
						//}
						//function onComplete() {
							//for (c in arClouds) {
								//c.hs.dispose();
								//c.hs = null;
								//
								//c.tw.dispose();
								//c.tw = null;
							//}
							//
							//arClouds = [];
						//}
						//tw.onUpdate = onUpdate;
						//tw.onComplete = onComplete;
					//}
				//}
				//else {
					//cloud1.setCenterRatio(1, 0);
					//cloud1.x = -Std.int((j * cloud1.width / 2));
					//tw.to(1 * Settings.FPS, cloud1.x += (Settings.STAGE_WIDTH + 2 * cloud1.width));
				//}
				//
				//arClouds.push( { hs:cloud1, tw:tw } );
			//}
		//}
	}

	override function onDeactivate() {
		super.onDeactivate();

		Main.ME.onDeactivate();
	}

	override function onActivate() {
		super.onActivate();

		Main.ME.onActivate();
	}

	override function onResize() {
		if( blackScreen == null )
			return;

		blackScreen.clear();
		blackScreen.beginFill( 0xFF000000 );
		blackScreen.drawRect( 0,0, Settings.STAGE_WIDTH, Settings.STAGE_HEIGHT);
		blackScreen.endFill();

		logo.x = mt.Metrics.w() * 0.5;
		logo.y = mt.Metrics.h() * 0.35;
		logo.setScale( mt.Metrics.w()*0.5 / logo.tile.width );

		loadingTxt.font = Settings.FONT_MOUSE_DECO_80;
		loadingTxt.textColor = 0xFFffe48d;
		loadingTxt.x = Std.int(mt.Metrics.w() * 0.5 - loadingTxt.textWidth/2);
		loadingTxt.y = Std.int(mt.Metrics.h() * 0.5);

		super.onResize();
	}

	override function unregister() {
		blackScreen.dispose();

		for (c in arClouds) {
			c.hs.dispose();
			c.hs = null;

			c.tw.dispose();
			c.tw = null;
		}

		tweener.dispose();

		ME = null;

		super.unregister();
	}

	override function update() {
		tweener.update();

		super.update();
	}
	
// STATIC
	public static function DESTROY_POPUP() {
		if (Pause.ME != null)
			Pause.ME.destroy();

		if (Collection.ME != null)
			Collection.ME.destroy();
		
		if (Shop.ME != null)
			Shop.ME.destroy();
		
		if (BoosterPickaxe.ME != null)
			BoosterPickaxe.ME.destroy();
		
		if (Life.ME != null)
			Life.ME.destroy();
		
		if (Mail.ME != null)
			Mail.ME.destroy();
		
		if (AskLife.ME != null)
			AskLife.ME.destroy();
		AskLife.CLEAR_CACHE();
	}
}
