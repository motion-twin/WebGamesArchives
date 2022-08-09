package;

import mt.deepnight.slb.*;
import mt.deepnight.slb.assets.TexturePacker;

import Protocol;

import data.*;
import manager.*;
import ui.Button;

/**
 * ...
 * @author Tipyx
 */

class PreloaderH2D extends mt.deepnight.deprecated.HProcess
{
	public static var ME			: PreloaderH2D;

	var onReady						: Void->Void;

	var slb							: BLib;

	var bg							: HSprite;
	var bmStar						: h2d.SpriteBatch;
	var arStar						: Array<HSpriteBE>;
	var titleLight					: HSprite;
	var title						: HSprite;
	var loadingLogo					: HSprite;
	var loadingBar					: HSprite;
	var loadingFill					: HSprite;

	var actualStep					: Int;
	var stepMax						: Int;
	var scaleXBar					: Float;

	var btnPlay						: Button;
	var btnConnect					: Button;
	var btnAreVisible				: Bool;

	public function new(onReady:Void->Void = null) {
		super();

		#if (android || ios)
		var mem = mtnative.device.Device.systemMemory();
		if( mem != null && mem < 512 )
			mt.Assets.USE_HALF_SIZE = true;
		if( mem != null && mem < 1536 && mt.Metrics.w() < 600 )
			mt.Assets.USE_HALF_SIZE = true;

		if( mt.Assets.USE_HALF_SIZE ){
			trace("Use half size texture");
		}
		#end

		ME = this;

		this.onReady = onReady;

		btnAreVisible = false;

		Settings.SET();

		slb = TexturePacker.importXmlMt("loader.xml", true);
		bg = slb.h_get("colorBg");
		root.addChild(bg);

		bmStar = new h2d.SpriteBatch(slb.tile);
		bmStar.filter = true;
		bmStar.blendMode = Add;
		root.addChild(bmStar);

		var rndStar = new mt.RandList(Std.random);
		rndStar.add("A", 50);
		rndStar.add("B", 10);
		rndStar.add("C", 3);

		arStar = [];

		for (i in 0...(rndStar.totalProba * 1)) {
			var t = rndStar.draw();
			var star = null;
			switch (t) {
				case "C" :
						star = slb.hbe_get(bmStar, "star" + t);
				case "B" :
					if (Std.random(2) == 0) {
						star = slb.hbe_get(bmStar, "star" + t);
						star.alpha = rnd(0.2, 0.4);
					}
					else {
						star = slb.hbe_get(bmStar, "star" + t);
						star.alpha = rnd(0.5, 0.8);
					}
				case "A" :
					star = slb.hbe_get(bmStar, "star" + t);
					star.alpha = rnd(0.2, 0.4);
			}
			if (star == null)
				throw "STAR IS NULL MOTHAFUCKA";
			star.setCenterRatio(0.5, 0.5);
			arStar.push(star);
		}

		for (s in arStar) {
			s.scaleX = s.scaleY = Settings.STAGE_SCALE * s.alpha;
			var wSqr = s.width * s.width * 2;
			var b = false;
			while (!b) {
				b = true;
				s.x = Std.random(Settings.STAGE_WIDTH);
				s.y = Std.random(Settings.STAGE_HEIGHT);
				for (st in arStar) {
					if (st != s && mt.deepnight.Lib.distanceSqr(s.x, s.y, st.x, st.y) < wSqr)
						b = false;
				}
			}
		}

		titleLight = slb.h_get("logoBg");
		titleLight.setCenterRatio(0.5, 0.5);
		root.addChild(titleLight);

		title = slb.h_get("logo");
		title.setCenterRatio(0.5, 0.5);
		root.addChild(title);

		onResize();
	}

	public function showLoadingLogo(){
		loadingLogo = Settings.SLB_FX2.h_getAndPlay("loading");
		loadingLogo.setCenterRatio(0.5, 0.5);
		root.addChild(loadingLogo);
	}

	public function showPreloader() {
		if (Settings.SLB_FX2 == null)
			TexturePacker.importXmlMtDeferred("fx2.xml", Main.getWorker(), function(l) { Settings.SLB_FX2 = l; showLoadingLogo(); onResize(); }, true);
		else
			showLoadingLogo();

		loadingFill = slb.h_get("progressBarBg");
		loadingFill.setCenterRatio(0.5, 0.5);
		root.addChild(loadingFill);

		loadingBar = slb.h_get("progressBar");
		loadingBar.setCenterRatio(0.5, 0.5);
		root.addChild(loadingBar);

	//	START LOADING
		#if standalone
			var d = mt.net.Codec.getInitData();
		#else
			var d = null;
		#end

		if (d != null)
			Settings.INIT_CLIENT = d;

		#if standalone
			var l = flash.Lib.current.stage.loaderInfo.parameters.lang;
		#else
			var l = App.current.lang;
		#end
		data.Lang.INIT( l == null?"en":l );
		actualStep = 0;

		mt.Assets.USE_CACHE = false;

		var sndWorker = Main.getWorker();

		//
		var STEPS = [
			function() { sndWorker.enqueue( new mt.Worker.WorkerTask(function() { SoundManager.CREATE_PART_1(); loadBar(); } ) ); },
			function() { sndWorker.enqueue( new mt.Worker.WorkerTask(function() { SoundManager.CREATE_PART_2(); loadBar(); } ) ); },
			function() { sndWorker.enqueue( new mt.Worker.WorkerTask(function() { SoundManager.CREATE_PART_3(); loadBar(); } ) ); },
			function() { sndWorker.enqueue( new mt.Worker.WorkerTask(function() { SoundManager.CREATE_PART_4(); loadBar(); } ) ); },
			function() { sndWorker.enqueue( new mt.Worker.WorkerTask(function() { SoundManager.CREATE_PART_5(); loadBar(); } ) ); },
			
			function(){
				TexturePacker.importXmlMtDeferred("assets1.xml", Main.getWorker(), function(l) { Settings.SLB_GRID = l; loadBar(); }, true);
			},
			#if standalone
			function(){
				getSLBTaupi();
				loadBar();
			},
			#end
			function(){
				TexturePacker.importXmlMtDeferred("design.xml", Main.getWorker(), function(l){ Settings.SLB_UI = l; Settings.SLB_UI.texture.flags.set(NoGC); loadBar(); }, true);
			},
			function(){
				TexturePacker.importXmlMtDeferred("design2.xml", Main.getWorker(), function(l){ Settings.SLB_UI2 = l; Settings.SLB_UI2.texture.flags.set(NoGC); loadBar(); }, true);
			},
			function(){
				TexturePacker.importXmlMtDeferred("fx.xml", Main.getWorker(), function(l){ Settings.SLB_FX = l; Settings.SLB_FX.texture.flags.set(NoGC); loadBar(); }, true);
			},
			function(){
				TexturePacker.importXmlMtDeferred("noTrim.xml", Main.getWorker(), function(l){ Settings.SLB_NOTRIM = l; loadBar(); }, true);
			},
			function(){
				TexturePacker.importXmlMtDeferred("birminghamFont.xml", Main.getWorker(), function(l){ Settings.SLB_FONT_BIRM = l; loadBar(); });
			},
			function(){
				TexturePacker.importXmlMtDeferred("benchNineFont.xml", Main.getWorker(), function(l){ Settings.SLB_FONT_BENCH = l; loadBar(); });
			},
			function(){
				mt.Assets.getTileDeferred("loaderIngame.png",Main.getWorker(),function(t){ t.getTexture().flags.set(NoGC); Settings.TILE_LOADER_INGAME=t.center(); loadBar();  });
			},
			function(){
				#if standalone
				Settings.SLB_LANG = TexturePacker.importXmlMt("lang_en.xml");
				if (data.Lang.LANG != "en")
					getSLBLang();
				loadBar();
				#else
				Settings.SLB_LANG_IS_DL = true;

				switch (Lang.LANG) {
					case "fr" :	TexturePacker.importXmlMtDeferred("lang_fr.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
					case "pt" :	TexturePacker.importXmlMtDeferred("lang_pt.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
					case "es" :	TexturePacker.importXmlMtDeferred("lang_es.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
					case "it" :	TexturePacker.importXmlMtDeferred("lang_it.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
					case "de" :	TexturePacker.importXmlMtDeferred("lang_de.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
					default :	TexturePacker.importXmlMtDeferred("lang_en.xml",Main.getWorker(),function(l){ Settings.SLB_LANG = l; loadBar(); });
				}

				#end
			},
			function(){
				AssetManager.INIT();
				loadBar();
			},
			function(){
				TutoManager.INIT();
				loadBar();
			},

			#if standalone
			function(){
				getInitData();
			},
			#end

			#if mBase
			function(){
				data.LevelDesign.LOAD_AR_LEVEL( loadBar );
			}
			#end
		];
		stepMax = STEPS.length;
		var start = haxe.Timer.stamp();
		var p = createTinyProcess();
		var skip = 2;
		p.onUpdate = function(){
			if( skip > 0 ){
				skip--;
				return;
			}
			var f = STEPS.shift();
			if( f != null )
				f();

			if( actualStep == stepMax ){
				p.destroy();
				Settings.RESIZE( endLoading, true );

				trace( "Total init time: "+(haxe.Timer.stamp()-start) );
			}
		}

		onResize();
	}

	public function removePreloader() {
		if (loadingLogo != null)
			loadingLogo.dispose();
		loadingLogo = null;

		removeLoadingBar();
	}

	function removeLoadingBar(){
		if (loadingBar != null)
			loadingBar.dispose();
		loadingBar = null;

		if (loadingFill != null)
			loadingFill.dispose();
		loadingFill = null;
	}

	#if standalone
	function onFromServer(d:ProtocolCom) {
		trace(d);
		switch (d) {
			case ProtocolCom.SendInitData(d) :
				LevelDesign.URL_AVATAR = d.avatar;
				LevelDesign.SET_AR_LEVEL( d.levels );
				LevelDesign.UPDATE_USER_DATA(d.userData);
				LifeManager.setServerTime(d.now);
				LevelDesign.FRIENDS = d.friends;

				loadBar();
			default :
		}
	}
	#end

	var tryLang	: Int = 0;
	function getSLBLang() {
		if (tryLang < 5) {
			tryLang++;
			TexturePacker.downloadXml(Settings.INIT_CLIENT.urlImages + "lang_" + data.Lang.LANG + ".xml", Settings.INIT_CLIENT.urlImages + "lang_" + data.Lang.LANG + ".png", false, function (bl) {
				if (bl != null) {
					Settings.SLB_LANG = bl;
					Settings.SLB_LANG_IS_DL = true;
				}
			}, function() { haxe.Timer.delay(getSLBLang, 500); } );
		}
	}
	
	var tryTaupi : Int = 0;
	function getSLBTaupi() {
		if (tryTaupi < 5) {
			tryTaupi++;
			TexturePacker.downloadXml(Settings.INIT_CLIENT.urlImages + "taupinotron.xml", Settings.INIT_CLIENT.urlImages + "taupinotron.png", true, function (bl) {
				if (bl != null) {
					Settings.SLB_TAUPI = bl;
				}
			}, function() { haxe.Timer.delay(getSLBTaupi, 500); } );
		}
	}

	#if standalone
	function getInitData() {
		var cmd = ProtocolCom.DoGetInitData(null, LevelDesign.MAX_LEVEL_CLIENT);
		mt.net.Codec.requestUrl( data.DataManager.API_URL() + "/" + Type.enumIndex(cmd), cmd, onFromServer, function(d) {
			trace(d);
			// retry in 1s
			haxe.Timer.delay(getInitData, 1000);
		});
	}
	#end

	function loadBar() {
		actualStep++;

		updateLoadingBar();
	}

	function updateLoadingBar(){
		loadingBar.scaleX = (1 - (actualStep / stepMax)) * scaleXBar;
	}

	function endLoading() {
		new process.ProcessManager();
	#if standalone
		Main.ME.launchGame();
	#else
		if (onReady != null)
			onReady();
	#end
		removeLoadingBar();
	}

#if mBase
	public function showConnect() {
		removePreloader();

		if (!btnAreVisible) {
			btnAreVisible = true;

			btnPlay = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBPlay), function () {
				hideConnect();
				mt.device.User.play("/start/");
			});
			root.addChild(btnPlay);

			btnConnect = new Button("btOrange", data.Lang.GET_BUTTON(TypeButton.TBLogIn), function () {
				mt.device.User.login();
			});
			root.addChild(btnConnect);
		}

		onResize();
	}

	function hideConnect() {
		if( !btnAreVisible )
			return;

		btnPlay.destroy();
		btnPlay = null;

		btnConnect.destroy();
		btnConnect = null;

		btnAreVisible = false;

		showLoadingLogo();
		onResize();
	}
#end

	override function onResize() {
		bg.scaleX = mt.Metrics.w() / bg.frameData.wid;
		bg.scaleY = mt.Metrics.h() / bg.frameData.hei;

		if( loadingFill != null && loadingBar != null ){
			loadingFill.x = Std.int(mt.Metrics.w() * 0.5);
			loadingFill.y = Std.int(mt.Metrics.h() * 0.8);
			scaleXBar = 1;
			loadingFill.setScale( 1 );
			loadingFill.scaleY *= 1.5;
			if (loadingFill.scaleX > (Settings.STAGE_WIDTH * 0.75) / loadingFill.width)
				scaleXBar = loadingFill.scaleX = (Settings.STAGE_WIDTH * 0.75) / loadingFill.width;

			loadingBar.setScale( 1 );
			loadingBar.scaleY *= 1.5;
			loadingBar.x = loadingFill.x;
			loadingBar.y = loadingFill.y;
			if (loadingBar.scaleX > (Settings.STAGE_WIDTH * 0.75) / loadingBar.width)
				loadingBar.scaleX = (Settings.STAGE_WIDTH * 0.75) / loadingBar.width;
			updateLoadingBar();
		}

		titleLight.x = title.x = Std.int(mt.Metrics.w() * 0.5);
		titleLight.y = title.y = Std.int(mt.Metrics.h() * 0.3);
		title.scaleX = title.scaleY = Settings.STAGE_SCALE;
		if (title.scaleX > (Settings.STAGE_WIDTH * 0.8) / title.frameData.wid)
			title.scaleX = title.scaleY = (Settings.STAGE_WIDTH * 0.8) / title.frameData.wid;
		titleLight.scaleX = titleLight.scaleY = title.scaleX * 2;

		if (loadingLogo != null){
			loadingLogo.setScale( 1 );
			loadingLogo.scaleX = loadingLogo.scaleY = Settings.STAGE_WIDTH * 0.25 / loadingLogo.width;
			loadingLogo.x = Std.int(mt.Metrics.w() * 0.5);
			loadingLogo.y = Std.int(mt.Metrics.h() * 0.6);
		}

		if (btnPlay != null) {
			btnPlay.resize();
			btnPlay.x = Std.int((Settings.STAGE_WIDTH - btnPlay.w) * 0.5);
			btnPlay.y = Std.int(Settings.STAGE_HEIGHT * 0.6);
		}

		if (btnConnect != null) {
			btnConnect.resize();
			btnConnect.x = Std.int((Settings.STAGE_WIDTH - btnConnect.w) * 0.5);
			btnConnect.y = Std.int(Settings.STAGE_HEIGHT * 0.7);
		}

		super.onResize();
	}

	override function unregister() {
		bg.dispose();
		bg = null;

		bmStar.dispose();
		bmStar = null;

		for (s in arStar) {
			s.dispose();
			s = null;
		}

		arStar = [];

		titleLight.dispose();
		titleLight = null;

		title.dispose();
		title = null;

		if (loadingLogo != null)
			loadingLogo.dispose();
		loadingLogo = null;

		if (loadingBar != null)
			loadingBar.dispose();
		loadingBar = null;

		if (loadingFill != null)
			loadingFill.dispose();
		loadingFill = null;

		if (btnPlay != null)
			btnPlay.destroy();
		btnPlay = null;

		if (btnConnect != null)
			btnConnect.destroy();
		btnConnect = null;

		slb.texture.dispose();

		slb.destroy();
		slb = null;

		ME = null;

		super.unregister();
	}

	override function update():Void {
		if( Settings.SLB_FX2 != null )
			Settings.SLB_FX2.updateChildren();
	}
}
