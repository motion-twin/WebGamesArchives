import haxe.remoting.Connection;
import flash.display.BitmapData;
import flash.Key;
import mt.Timer;
import mt.bumdum.Lib;
import mt.bumdum.Bmp;
import mt.flash.Volatile;

import Protocol;
import Types;
import MissionGen;
import GNetwork;
import data.VirusXml;
import data.AntivirusXml;
import data.ValuablesXml;
import data.ChipsetsXml;

typedef BubbleMC = {
	> flash.MovieClip,
	field	: flash.TextField,
	title	: flash.TextField,
	l		: flash.MovieClip,
	r		: flash.MovieClip,
	bg		: flash.MovieClip,
}

typedef BarMC = {
	> flash.MovieClip,
	flash	: flash.MovieClip,
}

typedef Sfx = {
	id		: String,
	url		: String,
	data	: flash.Sound,
	channel	: Int,
	vol		: Float,
}

typedef SoundAnim = {
	s		: Sfx,
	target	: Float,
	current	: Float,
	dir		: Float,
}

typedef Time = { seconds : Int, ms : Float, minutes : Int, hours : Int, days : Int };

class UserTerminal {
	static var CIN_DELAYS = [32,25,32,20,45];
	static var MAX_SHIELD = 30;
	static var MAX_LOG_LENGTH = 18;
	static var MAX_STORAGE = 10;
	static var COOKIE_VERSION = 3;
	static var ALARM_DURATION = 60;

	public static var CNX : haxe.remoting.ExternalConnection = null;

	var fl_generated	: Bool;
	public var bg		: flash.MovieClip;
	var animList		: Array<Anim>;
	var fxList			: Array<AnimFx>;
	var lifeBar			: BarMC;
	var manaBar			: BarMC;
	var kl				: Dynamic;
	var popMC			: { >MCField, bg:flash.MovieClip };
	var mask			: flash.MovieClip;
	var cineList		: List<flash.MovieClip>;
	var sysGameList		: Array<flash.MovieClip>;
	var cptCin			: Float;
	var logLines		: List<{t:Float,ta:Int,mc:flash.MovieClip}>;
	var logHistory		: Array<HistoryLine>;
	var logBmp			: Bmp;
	var logMC			: flash.MovieClip;
	var pwin			: { >flash.MovieClip, field:flash.TextField, input:flash.TextField };
	var cmdLine			: MCField;
	var ffield			: flash.TextField;
	var forcedCaret		: Int;		// bug avec le focus et l'utilisation de la flèche du haut...
	var caretIdx		: Int;
	var bmc				: BubbleMC;
	var boot			: {>MCField, field2:flash.TextField};
	var bootCooldown	: Int;
	var gtimerMC		: MCField;
	var lastTimer		: Time;
	var comboMc			: flash.MovieClip;
	var cmenu			: flash.MovieClip;
	var moreLog			: flash.MovieClip;
	var nextStack		: List<Void->Void>;
	var apps			: List<WinApp>;
	var cmdHistory		: Array<String>;
	var historyPos		: Int;
	var compList		: List<MCField>;
	var fpsAvg			: Float;

	public var aliases	: Hash<String>;

	#if debug
	var dtimer			: Float;
	#end
//	public var spamLog			: MCField;

	var seed				: Volatile<Int>;
	public var net			: GNetwork;
	public var fs			: GFileSystem;
	public var vman			: VirusMan;
	public var mdata		: MissionData;
	public var dock			: Dock;
	public var avman		: AntivirMan;
	var briefing			: String;
	var chipset				: Volatile<ChipsetData>;
	public var cookie		: flash.SharedObject;
	public var ls			: LocalSettings;

	public var fl_success	: Volatile<Bool>;
	public var fl_busted	: Volatile<Bool>;
	public var fl_end		: Volatile<Bool>;
	public var fl_lowq		: Bool;
	public var fl_leet		: Bool;

	public var channelPrefs	: Array<Bool>;

	public var gameLevel	: Volatile<Int>;
	public var gameDiff		: Volatile<Int>;
	public var username		: String;
	var speed				: Volatile<Float>;
	var maxCombo			: Volatile<Int>;
	public var dspeed		: Float;
	public var storage		: Array<FSNode>;
	public var virList		: List<Virus>;
	var passFile			: FSNode;
	public var ueffects		: List<{source:Virus, type:UserEffectType, cpt:Int}>;
	var gtimer				: Volatile<Float>;
	var timerLimit			: Volatile<Float>;
	var tick				: Volatile<Int>;
	var alarmTimer			: Volatile<Int>;
	public var alarmOrigin	: NetNode;
	public var kills		: Volatile<Int>;

	public var life			: Volatile<Int>;
	public var lifeTotal	: Volatile<Int>;
	public var mana			: Volatile<Int>;
	public var manaTotal	: Volatile<Int>;
	public var moneyFiles	: List<Valuable>;
	public var goals		: Volatile<Hash<{g:String, n:Int}>>;

	#if debug
	public var fl_adminTest	: Bool;
	#end

	public var missionCpt	: Volatile<Int>;

	public var unlockedPass	: Hash<Bool>; // utilisé pour la reward "mot de passe trouvé"

	var sfxBank				: Hash<Sfx>;
	var soundContainer		: flash.MovieClip;
	var loadingSteps		: Int;
	var totalSteps			: Int;
	var soundAnims			: List<SoundAnim>;
	var localSounds			: List<String>;
	var rythmes				: Array<Sfx>;
	var drones				: Array<Sfx>;
	var electro				: Array<Sfx>;


	public function new() {
		var ctx = new haxe.remoting.Context();
		ctx.addObject("_Com",_Com);

		cookie = flash.SharedObject.getLocal("intrusionSettings");
		ls = loadSettings();

		CNX = haxe.remoting.ExternalConnection.jsConnect("hackerConnect",ctx);
		CNX.JsMain.initCnx.call([]);
		Tutorial.init(this);
		Live.term = this;
		fl_generated = false;
		fl_success = false;
		fl_busted = false;
		fl_end = false;
		#if debug fl_adminTest = false; #end
		storage = new Array();
		animList = new Array();
		fxList = new Array();
		cineList = new List();
		sysGameList = new Array();
		logLines = new List();
		logHistory = new Array();
		nextStack = new List();
		maxCombo = 0;
		lifeTotal = 0;
		kills = 0;
		life = 0;
		manaTotal = 0;
		missionCpt = 0;
		mana = 0;
		moneyFiles = new List();
		ueffects = new List();
		timerLimit = DateTools.minutes(1);
		tick = -1;
		fpsAvg = 32;
		apps = new List();
		#if debug
		dtimer = flash.Lib.getTimer();
		#end
		cmdHistory = new Array();
		historyPos = 0;
		forcedCaret = null;
		aliases = new Hash();
		goals = new Hash();
		unlockedPass = new Hash();
		loadingSteps = 1;
		soundAnims = new List();
		localSounds = new List();
		rythmes = new Array();
		drones = new Array();
		electro = new Array();

		seed = Manager.PARAMS._seed;
		gameLevel = Manager.PARAMS._gl;
		mdata = Manager.PARAMS._m;
		username = Manager.PARAMS._profile._uname;
		fl_lowq = Manager.PARAMS._profile._low;
		fl_leet = Manager.PARAMS._profile._leet;
		channelPrefs = new Array();
		channelPrefs[0] = Manager.PARAMS._profile._sfx;
		channelPrefs[1] = Manager.PARAMS._profile._ambiant;
		channelPrefs[2] = Manager.PARAMS._profile._beat;
		#if debugSound trace("channelPrefs = "+channelPrefs.join(",")); #end
		if ( Manager.PARAMS._chip!=null ) {
			chipset = ChipsetsXml.ALL.get( Manager.PARAMS._chip );
			if ( chipset==null )
				Manager.fatal("unknown chipset");
		}

		sfxBank = new Hash();
		// loops
		declareSfx("drone_01s", 1, 30, drones);
		declareSfx("drone_02", 1, 30, drones);
		declareSfx("drone_03", 1, 30, drones);
		declareSfx("electro_01", 1, 10, electro);
		declareSfx("electro_02", 1, 25, electro);
		declareSfx("electro_03", 1, 25, electro);
		declareSfx("electro_04", 1, 25, electro);
		declareSfx("electro_05", 1, 25, electro);
		declareSfx("electro_06", 1, 25, electro);
		declareSfx("rythme_01", 2, 25, rythmes);
		declareSfx("rythme_02", 2, 25, rythmes);
		declareSfx("rythme_03", 2, 30, rythmes);
		// sfx
		declareSfx("absorb_02", 0, 15);
		declareSfx("bleep_01", 0, 9);
		declareSfx("bleep_02", 0, 15);
		declareSfx("bleep_03", 0, 15);
		declareSfx("bleep_04", 0, 15);
		declareSfx("bleep_05", 0, 15);
		declareSfx("bleep_06", 0, 15);
		declareSfx("bleep_07", 0, 15);
		declareSfx("corrupt_01", 0, 30);
		declareSfx("corrupt_02", 0, 50);
		declareSfx("explode_01", 0, 25);
		declareSfx("explode_02", 0, 25);
		declareSfx("explode_03", 0, 15);
		declareSfx("explode_04", 0, 15);
		declareSfx("explode_05", 0, 15);
		declareSfx("single_01", 0, 15);
		declareSfx("single_02", 0, 15);
		declareSfx("single_03", 0, 5);
		declareSfx("single_04", 0, 7);
		declareSfx("hit_01", 0, 15);
		declareSfx("hit_02", 0, 15);
		declareSfx("hit_03", 0, 15);
		declareSfx("hit_04", 0, 15);
		declareSfx("bonus_01", 0, 15);
		declareSfx("bonus_02", 0, 15);
		declareSfx("shield", 0, 12);
		declareSfx("modem_03", 0, 20);
		declareSfx("progress_01", 0, 10);
		declareSfx("alarm_01", 0, 15);
		declareSfx("alarm_02", 0, 15);

		// on retire les loops dont on n'aura pas besoin pour cette mission)
		if ( gameLevel<6 )
			undeclareSfx(rythmes, "rythme_03"); // high level
		else
			undeclareSfx(rythmes, "rythme_01"); // low level
		var rseed = Data.newRandSeed(seed);
		restrictSfxList( rseed, drones, 2 );
		restrictSfxList( rseed, electro, 2 );
		restrictSfxList( rseed, rythmes, 2 );
		declareSfx("menu", 2, 30);

		startSfxLoading();
		soundContainer = Manager.DM.empty(Data.DP_BG);

		speed = if(hasChipset(ChipsetsXml.get.turbo)) 1.5 else 1;
		dspeed = if (hasChipset(ChipsetsXml.get.turbo)) 1.5 else 1;
		//#if debug
		//Manager.PARAMS._bios=3;
		//#end
		if (Manager.PARAMS._bios<4) {
			speed+=Manager.PARAMS._bios;
			dspeed+=Manager.PARAMS._bios*0.6;
		}

		gameDiff = switch(gameLevel) {
			case 1	: 10;
			case 2	: 10;
			case 3	: 10;
			case 4	: 20;
			case 5	: 30;
			case 6	: 40;
			case 7	: 55;
			case 8	: 70;
			case 9	: 90;
			default	: (gameLevel*gameLevel);
		}

		// boot screen
		totalSteps = loadingSteps;
		bootCooldown = 0;
		boot = cast Manager.DM.attach("bootScreen", Data.DP_TOPTOP);
		startAnim(A_FadeIn, boot).spd*=0.6;
		startAnim(A_Text, boot, boot.field.text, -0.8).cb = onBootReady;
		boot.field2.text = "";

		if ( fl_leet )
			parseConfig(Manager.PARAMS._profile._cfg);

		Manager.ROOT._quality = if(fl_lowq) "low" else "medium";
	}


	// *** DÉMARRAGE ET PROTOCOLE

	function onBootReady() {
		onLoadingStep();
	}

	function onLoadingStep() {
		loadingSteps--;
		boot.field2.text = "Loading system : "+Math.floor((1-loadingSteps/totalSteps)*100)+"%";
		if ( loadingSteps<=0 )
			onLoading();
	}

	function onLoading() {
		boot.field2.text += " -- Core system loaded.\nReading data :";
		playSound("single_04");
		if ( channelPrefs[2] && !MissionGen.isTutorial(mdata) )
			startLocalLoop("menu", false);
		else
			if ( seed%2==0 )
				startLocalLoop( getDrone(seed), false );
			else
				startLocalLoop( getElectro(seed), false );
		nextStack.add(initGenerate);
	}

	function initGenerate() {
		try {
			TD.init();
			TD.setSeed(seed);

			// bordures
			var b1 = Manager.DM.attach("border", Data.DP_TOP);
			b1._y = -11;
//			var b2 = Manager.DM.attach("border", Data.DP_TOP);
//			b2._yscale *= -1;
//			b2._y = Data.HEI + 18;

			// lien historique
			moreLog = Manager.DM.attach("more", Data.DP_TOP);
			moreLog.stop();
			moreLog._x = 1;
			moreLog._y = Data.HEI - moreLog._height+2;
			moreLog.onRelease = showLogHistory;
			var me = this;

			var cbOver = function() { me.moreLog.gotoAndStop(2); }
			var cbOut = function() { me.moreLog.gotoAndStop(1); }
			bubble( moreLog, Lang.get.Tooltip_History, cbOver, cbOut );

			// mission
			#if debug
				if ( Manager.STANDALONE ) {
					var mg = new MissionGen(TD.texts, TD.fsNames, TD.names);
					mdata = mg.generate(gameLevel,seed);
					Manager.PARAMS._m = mdata;
					for (i in 0...5)
						mdata._cards.add("1234 "+Std.random(9999999));
				}
			#end

			// tip of the day
			if ( MissionGen.isTutorial(mdata) && fl_leet )
				fl_leet = false;

			// tip of the day
			if ( !MissionGen.isTutorial(mdata) )
				printTip();



			// structures
			vman = new VirusMan(this);
			vman.check();
			avman = new AntivirMan(this);
			AntivirusXml.check();
			net = new GNetwork(this);



			// virus deck
			dock = new Dock(this);
			virList = new List();
			if ( MissionGen.isTutorial(mdata) ) {
				for (v in data.VirusXml.getStartingViruses())
					virList.add( VirusXml.createInstance(v.id) );
				dock.registerDeck("Tutorial", virList);
			}
			else {
				var missionVirus = vman.getMissionVirus();
				if ( missionVirus!=null )
					virList.add(missionVirus);
				#if debug
				// debug
				virList.add(VirusXml.get.debug);
				virList.add(VirusXml.get.fdebug);
				#end

				// création des decks
				for (deck in Manager.PARAMS._decks) {
					var dvList = new List();
					for (id in deck._content) {
						var v = VirusXml.createInstance(id);
//						if ( !VirusXml.isUnlocked(v, Manager.PARAMS._profile._ulevel) )
//							Manager.fatal("unknown virus "+id);
						dvList.add(v);
						virList.add(v);
					}
					if ( missionVirus!=null )
						dvList.add(missionVirus);
					#if debug
					dvList.add(VirusXml.get.debug);
					dvList.add(VirusXml.get.fdebug);
					#end

					dock.registerDeck(deck._name, dvList);
				}
			}
			for ( v in VirusXml.getCategory("hidden", gameLevel, true) )
				virList.add(v);


//			dock.registerVirus(virList);
			dock.attach();
			dock.lock();
			dock.hide();


			// init diverses
			timerLimit = MissionGen.getTime(mdata, fl_leet);

			TD.texts.set("corp",mdata._corp);
			TD.texts.set("hacker",username);

			printBriefing(mdata._short, mdata._details);
			try {
				CNX.JsMain.lockBar.call( [] );
			}catch(e:Dynamic) {}
			briefing = "OBJECTIF : "+mdata._short+"\n\nDETAILS : "+mdata._details;

			// dock

			// interface
			bg = Manager.DM.attach("bg",0);
			Col.setPercentColor( bg, 100, mdata._color );
			lifeBar = cast Manager.DM.attach("barTerm", Data.DP_TOP);
			lifeBar._x = Math.round( Data.WID-lifeBar._width-2 );
			lifeBar._y = Math.round( Data.HEI-36 );
			lifeBar.flash._alpha = 0;

			manaBar = cast Manager.DM.attach("barTerm", Data.DP_TOP);
			manaBar._x = lifeBar._x;
			manaBar._y = lifeBar._y+lifeBar._height-2;
			manaBar.flash._alpha = 0;
			Col.setPercentColor(manaBar.smc, 55, 0x0000ff);

			gtimerMC = cast Manager.DM.attach("timer", Data.DP_TOP);
			gtimerMC._x = Math.round( lifeBar._x+lifeBar._width*0.5 );
			gtimerMC._y = lifeBar._y;
			gtimerMC.field.text = "";

			updateBars();

			if ( fl_leet )
				attachCmdLine();

//			spamLog = cast Manager.DM.attach("spamLog",Data.DP_TOPTOP);
//			spamLog._x = Data.WID-5;
//			spamLog._y = 165;
//			spamLog.blendMode = "screen";
//			spamLog._alpha = 10;
//			spamLog.field.text = "";
//			spamLog._visible = false;

			logMC = Manager.DM.empty(Data.DP_TOP);
			logBmp = new Bmp( logMC, Data.WID, Data.HEI );
		}
		catch(e:String) {
			Manager.fatal("UserTerminal.generate : "+e);
		}
	}


	public function onGenerate() {
		fl_generated = true;
		Manager.stopLoading();
		TD.names.set("corp",net.owner);

		startGame();
	}

	function startGame() {
		try {
			CNX.JsMain.lockBar.call( [] );
		}catch(e:Dynamic) {}
		#if debug
			if ( Manager.STANDALONE )
				onStartData({
					_error		: null,
					_init		: Manager.PARAMS,
				});
			else {
				try {
					Codec.load( Manager.PARAMS._startUrl, null, onStartData );
				}
				catch(e:String) {
					Manager.fatal("startGame : "+e);
				}
			}
		#else
			try {
				Codec.load( Manager.PARAMS._startUrl, null, onStartData );
			}
			catch(e:String) {
				Manager.fatal("startGame : "+e);
			}
		#end
	}

	function onStartData(d:PStart) {
		#if debugProtocol
			trace("onStartData");
			trace(d);
		#end
		if ( d._error!=null )
			Manager.fatal(d._error);
		else {
			if ( d==null || Std.is(d,String) || d._init==null ) {
				Manager.fatal("onStartData d="+d);
				return;
			}
			if ( d._init._seed!=seed || d._init._gl!=gameLevel )
				Manager.fatal("onStartData : DATA MISMATCH d="+Std.string(d));
			else
				onStartGame();
		}
	}

	function onStartGame() {
		startAnim(A_FadeRemove,boot,-0.5).spd*=0.5;
		boot.field2.text+=" "+TD.texts.get("bootResult");
		gtimer = flash.Lib.getTimer();
		dock.show();

		updateStats();

		kl = {};
		Reflect.setField(kl, "onKeyDown", onKey);
		Key.addListener(kl);
		playSound("single_04");

		log(Lang.get.Log_ConnectedGlobal);
		if ( chipset!=null )
			log( Lang.fmt.Log_Chipset({_c:chipset.name.toUpperCase(), _id:chipset.id.toLowerCase()}) );

		haxe.Timer.delay( onStartGameDelayed, Std.int(DateTools.seconds(1)) );

//		var me = this;
//		a.cb = function() {
//			me.bigLog(Lang.fmt.Welcome({_name:me.username}),true);
//		}
	}

	function onStartGameDelayed() {
		bigLog(Lang.get.BigConnected);
		var t = MissionGen.getTutorial(mdata);
		if ( t!=null )
			Tutorial.start(t);
	}

	public function abandon() {
		if ( fs!=null )
			disconnectFS(true);
		logout(true);
	}

	function endGame(?fl_abandon=false) {
		if ( fl_end )
			return;

		#if debug
		if ( fl_adminTest ) {
			fl_abandon = false;
			winGoal( "crash", 7 );
			winGoal( "corrup", 10 );
			winGoal( "log", 20 );
			winGoal( "av", 50 );
			winGoal( "eextra", 5 );
			winGoal( "passwd", 3 );
		}
		#end

		try {
			// packs
			var vfList = new List();
			for(vf in moneyFiles)
				vfList.add(vf.id);
			// fichiers copiés
			var slist = saveStorage();
			// goals
			var glist = new List();
			for (wg in goals)
				glist.add({
					_gid	: wg.g,
					_n		: wg.n,
				});

			var c = new Codec();
			var k : Int = kills;
			var data : PEnd = {
				_init		: Manager.PARAMS,
				#if debugProtocol
				_success	: true,
				#else
				_success	: !fl_abandon && checkMissionStatus(),
				#end
				_kills		: k,
				_rt			: Std.int( getRemainingTime()/1000 ),
				_valuables	: vfList,
				_storage	: slist,
				_goals		: glist,
				_fps		: Std.int(fpsAvg),
			}

			#if debugProtocol
				trace("*** endGame data ********************");
				trace(data);
			#end

			var msg : _Message = MISSION_RESULT(data);
			Codec.load(Manager.PARAMS._endUrl, msg, onEndData);

//			var c = new Codec();
//			var edata = c.serialize( msg );
//			var lv = new flash.LoadVars();
//			lv.sendAndLoad( Manager.PARAMS._endUrl, edata, "post" );

			fl_end = true;
			bigLog(Lang.get.BigEnd, true, true);

			#if debugProtocol
				trace("**** endGame sent ***********");
			#end
		}
		catch(e:String) {
			Manager.fatal("endGame : "+e);
		}
	}

	function onEndData(m:_Message) {
		#if debugProtocol
			trace("onEndData m="+m);
		#end
		switch(m) {
			case SEND_OK(url) :
				#if debugProtocol
					trace("SEND_OK url="+url);
				#end
//				var lv = new flash.LoadVars();
//				lv.sendAndLoad(url, "_self", "POST");
//				var r = new haxe.Http(url);
//				var list = saveStorage();
//				var nlist = new List();
//				for (f in list)
//					nlist.add(f._name);
//				r.setParameter("cfiles", nlist.join(","));
//				#if debug
//					Manager.ROOT.onRelease = callback(r.request,true);
//				#else
//					r.request(true);
//				#end
				flash.Lib.getURL(url);
			case SEND_NOT_OK(url, error, stack) :
				#if debug
					Manager.fatal(error);
				#else
					flash.Lib.getURL(url);
				#end
			case MISSION_RESULT(end) :
				#if debug
					trace(end);
				#end
		}
	}


	function updateStats() {
		maxCombo = if ( hasChipset(ChipsetsXml.get.combo) ) 5 else 3;

		lifeTotal = 100;
		life = lifeTotal;

		manaTotal = 250;
		if ( hasChipset(ChipsetsXml.get.mana) )
			manaTotal = 350;
		if ( hasChipset(ChipsetsXml.get.smana) )
			manaTotal = 500;
		mana = manaTotal;

		updateBars();
	}


	public function registerApp(a:WinApp) {
		apps.add(a);
		if ( apps.length>0 )
			hideCmdLine();
	}

	public function unregisterApp(a:WinApp) {
		apps.remove(a);
		if ( apps.length==0 )
			showCmdLine();
	}


	function parseConfig(cfg:String) {
		aliases = new Hash();
		for (line in cfg.split("\n")) {
			// clean up
			line = StringTools.replace(line,"\t"," ");
			line = StringTools.replace(line,"\r","");
			line = Data.trim(line," ");
			while ( line.indexOf("  ")>=0 )
				line = StringTools.replace(line,"  "," ");
			if ( line.length==0 )
				continue;
			var original = line;

			// commentaires
			if ( line.indexOf("#")>=0 )
				line = line.substr(0, line.indexOf("#"));
			if ( line.length==0 )
				continue;

			// extraction
			var command = line.split(" ")[0].toLowerCase();
			var params = line.substr(command.length+1);
			switch (command) {
				case "alias" :
					var from = Data.trimSpaces( params.split("=")[0] );
					var to = Data.trimSpaces( params.split("=")[1] );
					if ( from!=null && to!=null )
						aliases.set(from,to);
				default :
					Manager.fatal(Lang.get.InvalidConfigFile+"\n"+original);
			}
		}
	}


	public function loadSettings() {
		var s : LocalSettings = cookie.data.settings;
		if ( s==null || s.version!=COOKIE_VERSION ) {
			s = {
				version			: COOKIE_VERSION,
				wheelSpeed		: 5,
				shortcuts		: new Array(),
			}
			for (i in 0...9)
				s.shortcuts[i] = 49+i;
			s.shortcuts[9] = 48;
		}
		saveSettings(s, false);
		return s;
	}

	public function saveSettings(s:LocalSettings, ?fl_verbose=true) {
		cookie.data.settings = s;
		cookie.flush();
		if ( fl_verbose )
			log( Lang.get.OptSaved );
		ls = s;
	}


	// *** GESTION DES SONS

	function declareSfx(id:String, channel:Int, v:Float, ?list:Array<Sfx>) {
		if ( channelPrefs[channel]!=true || v<=0 )
			return;
		#if debugSound trace("declareSfx "+id); #end
		var url =  Manager.PARAMS._sfxUrl + id + ".wav.mp3?v=" + if(channel==2) Manager.PARAMS._musicVer else Manager.PARAMS._sfxVer;
		#if debugSound trace("  "+url); #end
		var fs = new flash.Sound( soundContainer );
		id = id.toLowerCase();
		var me = this;
		var sdata : Sfx = {
			id		: id,
			url		: url,
			data	: fs,
			channel	: channel,
			vol		: Math.max(0, Math.min(100, if(channel==0) v else v*2)),
		};
		fs.onLoad = function(success) { me.onLoadSfx(success, sdata); };

		sfxBank.set(id, sdata);
		if ( list!=null )
			list.push(sdata);
		loadingSteps++;
	}

	function undeclareSfx(list:Array<Sfx>, id:String) {
		var s = findSound(id);
		if ( s!=null ) {
			list.remove(s);
			sfxBank.remove(s.id);
			loadingSteps--;
		}
	}

	function restrictSfxList(rseed:mt.Rand, list:Array<Sfx>, max:Int) {
		while ( list.length>max )
			undeclareSfx( list, list[rseed.random(list.length)].id );
	}

	function startSfxLoading() {
		for (s in sfxBank.iterator()) {
			#if debugSound trace("loading : "+s.id); #end
			s.data.loadSound( s.url, false );
		}
	}

	function onLoadSfx(fl_ok:Bool, s:Sfx) {
		if ( !fl_ok )
			Manager.fatal("failed to load "+s.url);
		else
			onLoadingStep();
	}

	public function playSound(id, ?offset=0.0) {
		#if debugSound trace("playSound "+id); #end
		var s = findSound(id);
		if ( s!=null ) {
			s.data.stop();
			s.data.start(offset, 1);
			s.data.setVolume(s.vol);
		}
	}

	public function stopSound(id, ?fl_fade=false) {
		#if debugSound trace("stopSound "+id); #end
		var s = findSound(id);
		if ( s!=null )
			if (fl_fade) {
				var sa = startSoundAnim(s, s.data.getVolume(), 0);
				sa.dir*=2;
			}
			else
				s.data.stop();
	}

	public function startLoop(id:String, ?fl_fade=true) {
		var s = findSound(id);
		#if debugSound trace("startLoop id="+id+" s="+s); #end
		if ( s!=null ) {
//			var v = if(vol!=null) vol else s.vol;
			s.data.stop();
			s.data.start(0,9999);
			if ( fl_fade )
				startSoundAnim(s, 0, s.vol);
			else
				s.data.setVolume( s.vol );
		}
	}

	public function stopLoop(id, ?fl_fade=true) {
		#if debugSound trace("stopLoop "+id); #end
		var s = findSound(id);
		if ( s!=null )
			if ( fl_fade )
				startSoundAnim(s, Std.int(s.data.getVolume()), 0);
			else
				s.data.stop();
	}



//	public function unmute(id) {
//		var s = findSound(id);
//		if ( s!=null )
//			s.data.setVolume(s.vol);
//	}
//
//	public function mute(id) {
//		stopSound(id);
////		setVolume(id,0);
//	}
//
//	public function muteAll() {
//		for(s in sfxBank.iterator())
//			mute(s.id);
//	}


	function startSoundAnim(s:Sfx, from:Float, to:Float) {
		// rappel sur un son déjà en train de fader ?
		for (sa in soundAnims)
			if ( sa.s.id==s.id ) {
				from = sa.s.data.getVolume();
				soundAnims.remove(sa);
			}

		#if debugSound trace("startSoundAnim "+s.id+" from="+from+" to="+to+" (len="+soundAnims.length+")"); #end

		s.data.setVolume(from);
		var sa : SoundAnim = {
			s		: s,
			current	: from,
			target	: to,
			dir		: if(from<to) 0.5 else -0.5,
		};
		soundAnims.add(sa);
		return sa;
	}

	function stopSoundAnim(sanim:SoundAnim, ?fl_stop=false) {
		if ( sanim.target<=0 || fl_stop )
			sanim.s.data.stop();
		soundAnims.remove(sanim);
	}


	function setVolume(id:String,vol:Int) {
		var s = findSound(id);
		if ( s!=null )
			s.data.setVolume(vol);
	}

	public function findSound(id:String) : Sfx {
		return sfxBank.get( id.toLowerCase() );
	}

	function startLocalLoop(id, ?fl_fade=true) {
		startLoop(id, fl_fade);
		localSounds.add(id);
	}

	public function stopLocalLoops() {
		for (id in localSounds)
			stopLoop(id);
		localSounds = new List();
	}

	public function inheritLoop( id:String ) {
		localSounds.add(id);
	}

	public function getDrone(seed:Int) {
		var rseed = Data.newRandSeed(seed);
		return drones[ rseed.random(drones.length) ].id;
	}

	public function getElectro(seed:Int) {
		var rseed = Data.newRandSeed(seed);
		return electro[ rseed.random(electro.length) ].id;
	}

	public function getRythm(seed:Int) {
		var rseed = Data.newRandSeed(seed);
		return rythmes[ rseed.random(rythmes.length) ].id;
	}

	// *** MISSIONS

	public function checkMission() {
		if ( fl_busted )
			fl_success = false;
		if ( !fl_success ) {
			fl_success = checkMissionStatus();
			if ( fl_success ) {
				bigLog(Lang.get.MissionComplete,true,30);
				log( Lang.get.Log_MissionComplete, Data.BLUE );
			}

		}
		return fl_success;
	}

	function checkMissionStatus() {
		#if debug
			if ( fl_adminTest )
				return true;
		#end
		if ( fl_busted )
			return false;

		if ( hasChipset(ChipsetsXml.get.scout) )
			return false;
		var mnodes = net.getTargetNodes();
		var n = mnodes[0];
		switch(mdata._type) {
			case _MModerate(str)		: return !n.system.fl_crashed && n.system.countFilesByExt("mp3") + n.system.countFilesByExt("video") == 0;
			case _MDelete(owner,fname)	: return n.system.countTargetFiles()==0;
			case _MDeleteAll(owner,ext)	: return n.system.countFilesByExt(ext)==0;
			case _MCopy(owner,fname)	: return hasFileByName(fname,owner);
			case _MSteal(owner,fname)	: return hasFileByName(fname,owner) && n.system.countTargetFiles()==0;

			case _MCrashPrinter(str)	: return n.system.fl_crashed;
			case _MCrashTerminal(str)	: return n.system.fl_crashed;
			case _MCrashDB(str)			: return n.system.fl_crashed;
			case _MCleanTerminal(owner)	: return !n.system.fl_crashed && n.system.getFilesByExt("antivir").length==0;

			case _MCopyMail(owner,sender)	: return hasFileByExt("mail",sender);
			case _MFindMails(owner,n)		: return hasTargetFiles(n);
			case _MPasswords(str)			: return hasTargetFiles(1);
			case _MCleanSecurity :
				for (mn in mnodes)
					if ( !mn.system.fl_crashed )
						return false;
				return true;
			case _MCamRec(fname)		: return hasTargetFiles(1);
			case _MCleanCriminal(name)	: return !n.system.fl_crashed && n.system.countTargetFiles()==0;
			case _MSpy(name)			:
				if ( n.system.fl_crashed )
					return false;
				for (f in n.system.getFilesByKey("file.core"))
					if ( !f.hasEffect(E_Mission) )
						return false;
				return true;
			case _MCompromiseMail(owner) :
				if ( n.system.fl_crashed )
					return false;
				for (f in n.system.getFilesByExt("mail"))
					if ( f.hasEffect(E_Mission) && f.parent.key=="/mail" )
						return true;
				return false;
			case _MFalsifyCam(sector) :
				if ( n.system.fl_crashed )
					return false;
				for (f in n.system.getFilesByKey("archive.video"))
					if ( !f.hasEffect(E_Mission) )
						return false;
				return true;
			case _MSpyCam :
				for (mn in mnodes) {
					if ( mn.system.fl_crashed )
						return false;
					for (f in mn.system.getFilesByKey("file.core"))
						if ( !f.hasEffect(E_Mission) )
							return false;
				}
				return true;
			case _MArrest(name) :
				if ( n.system.fl_crashed )
					return false;
				if ( n.system.countFilesByExt("log")>0 )
					return false;
				for (f in n.system.getFilesByExt("data"))
					if ( f.hasEffect(E_Mission) && f.parent.key=="/subcrimedata" )
						return true;
				return false;
			case _MCorruptDisplay(place) :
				if ( n.system.fl_crashed )
					return false;
				var parent = n.system.getFilesByKey("/playlist")[0];
				var list = Lambda.filter( n.system.getFolderFiles(parent), function(f) {
					return !f.fl_deleted;
				});
				if ( list.length==0 )
					return false;
				for (f in list)
					if ( !f.hasEffect(E_Mission) )
						return false;
				return true;
			case _MDeliverFile(parentKey, pname, file,to) :
				if ( n.system.fl_crashed )
					return false;
				for (f in n.system.getFilesByExt("doc"))
					if ( f.hasEffect(E_Mission) && f.parent.key==parentKey )
						return true;
				return false;
			case _MOverwriteFiles(owner,ext) :
				for (n in mnodes)
					for (f in n.system.getTargetFiles())
						if ( f.ext(ext) && !f.hasEffect(E_Mission) && !f.fl_deleted )
							return false;
				return true;
			case _MGameHack(g,s,c) :
				if ( n.system.fl_crashed )
					return false;
				for (f in n.system.getTargetFiles())
					if ( !f.hasEffect(E_Mission) )
						return false;
				return true;
			case _MInfectNet(v) :
				for (n in mnodes)
					for (f in n.system.getTargetFiles(true))
						if ( f.fl_deleted || !f.hasEffect(E_Mission) )
							return false;
				return true;
			case _MGetVirus(v,ext,total) :
				return missionCpt >= total;
			case _MTutorial :
				return n.system.fl_crashed;
			case _MTutorialDelete(ext,total) :
				if ( missionCpt >= total )
					Tutorial.play( Tutorial.get.second, "deletedAll" );
				return missionCpt >= total;
			case _MTutorialBypass(f) :
				return hasTargetFiles(1);
			case _MTV(tf,tt) :
				var list = n.system.getFilesByKey("tvprog.data");
				if ( list.length==0 )
					return false;
				for (f in list)
					if ( f.fl_deleted || !f.hasEffect(E_Mission) )
						return false;
				return true;
			case _MTVTheft(tv,p) :
				return hasTargetFiles(1);
			case _MTVCrash(tv) :
				for (ntv in net.getNodes(Tv)) {
					if ( ntv!=n && ntv.system.fl_crashed )
						return false;
				}
				return n.system.fl_crashed;
		}
		return false;
	}

	inline function getRemainingTime() {
		return timerLimit-(flash.Lib.getTimer() - gtimer);
	}

	public function onDeleteFile(f:FSNode) {
		switch(mdata._type) {
			case _MTutorialDelete(ext,total) :
				if ( missionCpt>=total || !f.ext(ext) )
					return;
				missionCpt++;
				if ( Tutorial.play(Tutorial.get.second, "showLog") )
					Tutorial.point( Manager.DM, 70, Data.HEI-30 );
				log( Lang.fmt.Log_MissionRemaining({_n:missionCpt, _total:total}) );
			default :
		}
	}



	// *** OUTILS

	public function winGoal(ngId:String, ?delta=1) {
		if ( goals.get(ngId)==null )
			// new value
			goals.set( ngId, {
				g	: ngId,
				n	: delta,
			});
		else {
			// existing goal
			goals.set( ngId, {
				g	: ngId,
				n	: goals.get(ngId).n + delta,
			} );
		}
	}

	public function chrono(str:String) {
		#if debug
			var now = flash.Lib.getTimer();
			trace( str+" : "+(now-dtimer) );
			dtimer = now;
		#end
	}

	public function copyFile(f:FSNode) {
		if ( hasFile(f) ) return;
		storage.push( f.createCopy() );
		dock.onStorageChange();
	}

	public function updateCopies(uf:FSNode) {
		for (f in storage)
			if ( f.id==uf.id )
				f.copyData(uf);
	}

	public function getMaxStorage() {
		if ( hasChipset(ChipsetsXml.get.storag) )
			return MAX_STORAGE*2;
		else
			return MAX_STORAGE;
	}

	function hasFile(file:FSNode) {
		for (f in storage)
			if ( file.name==f.name && file.id==f.id ) return true;
		return false;
	}

	function hasFileByName(fname:String,owner:String) {
		for (f in storage)
			if ( f.name==fname && f.getOwner()==owner ) return true;
		return false;
	}

	function hasFileByExt(ext:String,owner:String) {
		ext = ext.toLowerCase();
		for (f in storage) {
			if (f.name.indexOf("."+ext)>=0 && f.getOwner()==owner ) return true;
		}
		return false;
	}

	public function hasFileByOwner(owner:String) {
		owner = owner.toLowerCase();
		for (f in storage)
			if (f.getOwner().toLowerCase()==owner ) return true;
		return false;
	}

	function hasTargetFiles(n:Int) {
		var cpt = 0;
		for (f in storage)
			if (f.fl_target) cpt++;
		return cpt>=n;
	}

	public function hasChipset(c:ChipsetData) {
		return chipset.id == c.id;
//		return ChipsetsXml.isAvailable(c, gameLevel) && chipset.id==c.id;
	}

	public function saveStorage() : List<SimpleFile> {
		var list : List<SimpleFile> = new List();
		for (f in storage)
			if ( f.getContent()!=null && !f.fl_target )
				list.add({
					_name		: f.name,
					_content	: Data.htmlize( f.getContent() ),
					_embed		: f.embedData,
				});

		return list;
	}

	public function disconnectFS(?fl_stealth=false) {
		if ( fs==null )
			return;
//		if ( fs.fl_crashed )
//			popUp(Lang.get.SystemCrashed);
//		else
//			popUp(Lang.get.Disconnected);
		if ( !fl_stealth )
			avman.onDisconnect();
		log(Lang.get.Disconnected);
		if ( fl_stealth && life>0 )
			log(Lang.get.Log_Stealth);
		detachSystemGame();
		detachPass();
		hideCmdLine();
		dock.lock();
		dock.showSwitcher();
		fs.disconnect();
		fs = null;
//		net.curNode = null;
		net.updateVisibility();
		net.unlock();
		net.refresh();
//		avman.setScanLevel(0);
		clearEffect(UE_Furtivity);
		clearEffect(UE_MoveFurtivity);
		bigLog(Lang.get.BigDisconnected,-30);
//		furtivity = 0;
//		spamLog._visible = false;
	}

	public function logout(?fl_abandon=false) {
		Manager.loading(Lang.get.LP_Logout);
		stopLocalLoops();
		Tutorial.print();
		dock.hide();
		#if debug
			if ( Manager.STANDALONE ) {
				if ( checkMissionStatus() )
					bigLog("logout : Well done ! You win ! :)");
				else
					bigLog("logout : FAILED !");
				fl_end = true;
			}
			else
				endGame(fl_abandon);
		#else
			endGame(fl_abandon);
		#end
	}

	public function getSpeed() {
		var s = speed;
		if ( fs!=null )
			s*=fs.speed;
		return s;
	}



	// *** FOCUS TEXTE

	function hasFocus() {
		var path = ffield._name;
		var par : flash.MovieClip = cast ffield;
		do {
			par = par._parent;
			path = par._name+"."+path;
		} while (par._name!="" && par!=null);
		path = path.substr(1);

		var current = flash.Selection.getFocus();
		current = current.substr( current.indexOf(".")+1 );

		return current==path;
	}

	function focus(?cidx:Int) {
		if ( popMC!=null ) return;
		flash.Selection.setFocus(ffield);
		if ( cidx!=null )
			if ( cidx<0 )
				caretIdx = ffield.text.length;
			else
				caretIdx = cidx;
		flash.Selection.setSelection(caretIdx,caretIdx);
	}

	function unfocus() {
		flash.Selection.setFocus(null);
	}

	function setFocus(f:flash.TextField) {
		ffield = f;
		caretIdx = 0;
	}


	// *** STATS

	public function damage(n,?fl_canBeBlocked=true) {
		if(n<=0) return;
		var real = n;
		if ( fl_canBeBlocked )
			while (real>0 && hasEffect(UE_Shield)) {
				removeEffect(UE_Shield);
				real--;
			}

		if ( real>0 ) {
			life-=real;
			if ( life<0 )
				life = 0;
			startAnim(A_Shake, lifeBar);
			popNumber(-real,lifeBar._x+lifeBar._width*0.5,lifeBar._y-20);
			if ( lifeBar.flash._alpha<=50 )
				lifeBar.flash._xscale = lifeBar.smc._xscale;
			lifeBar.flash._alpha = 100;
			startAnim(A_FadeOut,lifeBar.flash).spd*=0.2;
			playSound("hit_03");
		}
		else
			playSound("shield");
		if ( real<n )
			log( Lang.fmt.Log_Shield({_n:n-real}) );
		updateBars();
	}


	public function loseMana(n:Int) {
		if ( n<=0 ) return;
		if ( mana<n )
			Manager.fatal("can't lose "+n+" mana");

		if ( manaBar.flash._alpha<=30 )
			manaBar.flash._xscale = manaBar.smc._xscale;
		Col.setPercentColor(manaBar.flash, 100, 0xffffff);
		manaBar.flash._alpha = 100;
		startAnim(A_FadeOut,manaBar.flash).spd*=0.6;
		mana-=n;
		if ( mana<=0 && fs!=null ) {
			log(Lang.get.Log_OOM);
			disconnectFS();
		}
		updateBars();
	}

	public function gainMoney(money) {
		var vf = ValuablesXml.getByValue(money);
		if ( vf==null )
			Manager.fatal("unknown valuable "+money);
		moneyFiles.add(vf);
		log( Lang.fmt.Log_FoundValuable({_name:vf.name}), Data.BLUE );
		return vf;
	}

	public function gainTime(s:Int) {
		if ( fl_busted || Manager.PARAMS._c )
			return;
		timerLimit+=DateTools.seconds(s);
		lastTimer = null;
		updateTimer();

		log( Lang.fmt.Log_GainedTime({_n:s}), Data.BLUE );
		popNumber(s," secondes", manaBar._x+manaBar._width*0.5, manaBar._y-20);
	}

	public function gainLife(n) {
		life+=n;
		popNumber(n,lifeBar._x+lifeBar._width*0.5, lifeBar._y-20);
		if ( life>lifeTotal )
			life = lifeTotal;
		startAnim(A_StrongBlink,lifeBar);
		log( Lang.fmt.Log_GainedLife({_n:n}), Data.BLUE );
		updateBars();
	}

	public function gainMana(n, ?fl_silent=false) {
		if ( n<=0 ) return;
		manaBar.flash._alpha = 0;
		mana+=n;
		if ( mana>manaTotal )
			mana = manaTotal;
		if ( !fl_silent ) {
			popNumber(n,manaBar._x+manaBar._width*0.5, manaBar._y-20);
			log( Lang.fmt.Log_GainedMana({_n:n}), Data.BLUE );
		}
		startAnim(A_StrongBlink,manaBar);
		updateBars();
	}


	// *** EFFETS

	public function hasEffect(et:UserEffectType) {
		for (e in ueffects)
			if ( e.type==et )
				return true;
		return false;
	}

	public function countEffect(et:UserEffectType) {
		var n = 0;
		for (e in ueffects)
			if ( e.type==et )
				return e.cpt;
		return 0;
	}

	public function gainCombo(n=1) {
		addEffect(UE_Combo,n);
		updateBars();
		startAnim(A_Shake, comboMc);
	}

	public function loseCombo() {
		clearEffect(UE_Combo);
		updateBars();
	}


	public function addEffect(?source:Virus, et:UserEffectType, ?cpt=1, ?max=9999) {
		if ( et==UE_Shield )
			playSound("shield");
		if ( et==UE_Combo )
			max = maxCombo;
		if ( cpt>max )
			cpt = max;
		for (e in ueffects)
			if ( e.type==et ) {
				e.cpt+=cpt;
				if ( e.cpt>max )
					e.cpt = max;
				dock.displayEffects();
				return;
			}
		ueffects.push({
			source	: source,
			type	: et,
			cpt		: cpt,
		});
		dock.displayEffects();
	}

	public function removeEffect(et:UserEffectType,fl_update=true) {
		for (e in ueffects)
			if ( e.type==et ) {
				e.cpt--;
				if ( e.cpt<=0 )
					ueffects.remove(e);
			}
		dock.displayEffects();
		if (fl_update)
			updateBars();
	}

	public function getEffectSource(et:UserEffectType) {
		for(e in ueffects)
			if(e.type==et)
				return e.source;
		return null;
	}

	public function clearEffect(et:UserEffectType) {
		while (hasEffect(et))
			removeEffect(et,false);
		updateBars();
	}


	public function startAnim(type:AnimType, mc:flash.MovieClip, ?str:String, ?delay=0.0, ?fl_linkToProgress=false) {
		var spd = 0.06;
		for (a in animList)
			if ( a.type==type && a.mc==mc ) // TODO : à vérifier si pb d'animations...
				endAnim(a);
		var data : Float = null;
		var tx = Std.int(mc._x);
		var ty = Std.int(mc._y);

		switch (type) {
			case A_PlayFrames :
				mc.gotoAndStop(1);
			case A_Text :
				var mcc : MCField = cast mc;
				mcc.field.text = "";
			case A_HtmlText :
				var mcc : MCField = cast mc;
				mcc.field.htmlText = "";
			case A_EraseText :
				var mcc : MCField = cast mc;
				str = mcc.field.text;
			case A_Decrypt :
				spd*=0.6;
			case A_FadeIn :
				mc._alpha = 0;
			case A_FadeOut :
			case A_BlurIn :
				mc.filters = [ new flash.filters.BlurFilter(16,16) ];
				mc._alpha = 0;
			case A_FadeRemove :
			case A_Delete :
				spd*=0.7;
			case A_Shake :
			case A_Blink :
				spd*=2;
			case A_StrongBlink :
			case A_Connect :
				mc._x = 50;
				mc._y = 60;
				var mcc : { >MCField, bg:flash.MovieClip } = cast mc;
				mcc.bg.blendMode = "screen";
				mcc.field.text = "Connecting "+str+"...\n";
				mcc.bg._width = 230;
				mcc.bg._height = 150;
				spd+=Std.random(500)/1000;
			case A_Auth :
				spd*=0.25;
				mc._x = Std.random(300)+50;
				mc._y = Std.random(300)+30;
				var mcc : { >MCField, bg:flash.MovieClip } = cast mc;
				mcc.bg.blendMode = "screen";
				mcc.field.text = "";
				mcc.bg._width = 230;
				mcc.bg._height = 150;
			case A_BubbleIn :
				spd*=4.5;
				mc._visible = false;
//				mc._xscale = 5;
				mc._yscale = 5;
				mc._alpha = 0;
			case A_Move :
			case A_Bump :
				data = -6;
				spd = 0;
				ty = Std.int(mc._y);
				mc._y--;
			case A_MenuIn :
				tx = Std.int(mc._x);
				mc._x-=30;
				mc._alpha = 0;
		}
		var a : Anim = {
			mc	: mc,
			spd	: spd,
			x	: Std.int(mc._x),
			y	: Std.int(mc._y),
			tx	: tx,
			ty	: ty,
			txt	: str,
			t	: if (fl_linkToProgress) null else delay,
			kill: false,
			type: type,
			data: data,
			cb	: null,
			fl_killFilters	: true,
		};
		animList.push(a);
		return a;
	}

	function endAnim(a:Anim) {
		a.kill = true;
		if ( a.fl_killFilters )
			a.mc.filters = [];
		if ( a.cb!=null )
			a.cb();
		switch(a.type) {
			case A_Shake :
				a.mc._x = a.tx;
				a.mc._y = a.ty;
			case A_Move :
				a.mc._x = a.tx;
				a.mc._y = a.ty;
			case A_Bump :
				a.mc._y = a.ty;
			case A_MenuIn :
				a.mc._x = a.tx;
			default:
		}
	}

	public function hasAnim(mc,?minProgress=1.0) {
		for (a in animList)
			if( (a.mc==mc || a.mc==mc._parent) && a.t<=minProgress)
				return true;
		return false;
	}


	public inline function countFx() {
		var n = fxList.length;
		if ( fl_lowq )
			return if(n>5) 9999 else n;
		else
			return n;
	}

	public function addIconRain(?dm:mt.DepthManager, ?links:Array<String>, ?chance=75, mc:flash.MovieClip) {
		if ( links==null || links.length==0 )
			links = ["fx_binary"];
		var n = if ( fl_lowq ) Std.random(5)+5 else Std.random(15)+20;
		for (i in 0...n)
			addFx(
				dm,
				AFX_Binary,
				if (Std.random(100)<chance) links[Std.random(links.length)] else "fx_binary",
				mc._x+35,
				mc._y+50
			);
	}

	public function addSpark(?dm:mt.DepthManager) {
		addFx(dm, AFX_Spark, "fx_spark", 0,0 );
	}

	public function addFx(?dm:mt.DepthManager, ?depth:Int, type:AnimFxType, ?link="fx", x:Float,y:Float) {
		if ( depth==null )
			depth=Data.DP_FX;
		if ( dm==null )
			dm = Manager.DM;
		var mc = dm.attach(link,depth);
		mc.gotoAndStop(Std.random(mc._totalframes)+1);
		mc._x = x;
		mc._y = y;
		var fx : AnimFx = {
			type	: type,
			mc		: mc,
			dx		: 0.0,
			dy		: 0.0,
			gx		: 0.0,
			gy		: 0.0,
			timer	: 0.0,
			data	: 0.0,
		}

		switch(fx.type) {
			case AFX_PopUp :
				fx.dy = -1;
			case AFX_Binary :
				mc._x+=Std.random(28) * (Std.random(2)*2-1);
				mc._y+=Std.random(10);
				mc._alpha = Std.random(70)+30;
				fx.dy = -Std.random(20)/10-0.3;
				fx.data = Std.random(314)/100;
			case AFX_PlayFrames :
				mc.gotoAndStop(Std.random(fx.mc._totalframes));
				mc.smc.stop();
				if ( link=="fx_glight" ) {
					var s = Std.random(70)+30;
					mc._xscale = (Std.random(2)*2-1) * s;
					mc._yscale = (Std.random(2)*2-1) * s;
					mc._alpha = Std.random(60)+40;
					mc.filters = [ new flash.filters.GlowFilter(0xffffff,0.7, 8,8,3) ];
				}
			case AFX_Spark :
				fx.dx = (Std.random(30)+30);
				fx.dy = fx.dx*0.5;
				mc._xscale = 50+Std.random(30);
				mc._yscale = mc._xscale;
				switch(Std.random(2)) {
					case 0 :
						mc._x = -650+Std.random(50);
						mc._y = 800;
						fx.dy*=-1;
					case 1 :
						mc._x = 550+Std.random(50);
						mc._y = 200;
						fx.dx*=-1;
				}
//				mc._x = -600+Std.random(50);
//				mc._y = 800;
//				fx.dx*=1;
//				fx.dy*=-1;

				if ( fx.dx>0 && fx.dy>0 ) {
					mc._xscale*=-1;
					mc._yscale*=-1;
				}
				if ( fx.dx>0 && fx.dy<0 )
					mc._xscale*=-1;
				if ( fx.dx<0 && fx.dy>0 )
					mc._yscale*=-1;
				mc._alpha = Std.random(35)+15;
		}

		fxList.push(fx);
		return fx;
	}


	public function popNumber(?dm:mt.DepthManager, ?icon:String, n:Int, ?extra:String, x:Float,y:Float) {
		extra = (extra==null?"":" "+extra);
		var str = (n>0?"+":"")+n+extra;
		var col = (n<0?Data.CORRUPT:Data.GREEN);
		return popString(dm, icon, str, col, x,y);
	}

	public function popString(?dm:mt.DepthManager, icon:String, str:String, col:Int, x:Float,y:Float) {
		if ( dm==null )
			dm = Manager.DM;

		var fx = addFx(dm,Data.DP_TOP, AFX_PopUp, "fx_pop", x,y);
		var mc : MCField = cast fx.mc;

		var wid = 0.0;

		if ( icon!=null ) {
			var mcIcon = mc.attachMovie("sicon", "sicon_"+Data.UNIQ, Data.UNIQ++);
			mcIcon.gotoAndStop(icon);
			mcIcon._y += 6;
			mc.field._x = mcIcon._width+3;
			wid+=mcIcon._width;
		}
		mc.field.text = str;
		mc.field.textColor = col;
		mc.field._width = mc.field.textWidth+5;
		wid+=mc.field.textWidth;
		mc._x = Math.round(mc._x - wid*0.5);

		// anti-recouvrement des txt
		if ( str.length<5 ) {
			var list = new List();
			for (f in fxList)
				if ( f.type==AFX_PopUp )
					list.add(f.mc);
			disoverlap(mc,list);
		}


		if ( str.length>3 ) {
			var a = startAnim(A_Text, mc, str);
			a.spd*=2;
			a.tx = null;
			a.ty = null;
		}
		return mc;
	}


	function disoverlap(mc:flash.MovieClip, list:List<flash.MovieClip>, ?recur=0) {
		if ( recur>=150 ) {
			#if debug
				trace("disoverlap FAILED !");
			#end
			return;
		}
		for (mc2 in list)
			if ( mc!=mc2 && overlap(mc,mc2) ) {
				mc._x+= (Std.random(2)*2-1) * mc2._width;
				disoverlap(mc,list,recur+1);
				return;
			}
	}

	function overlap(a:flash.MovieClip, b:flash.MovieClip) {
		return a._name!=b._name &&
			 b._x<a._x+a._width && b._x+b._width>a._x &&
			 b._y<a._y+a._height && b._y+b._height>a._y;
	}

	public function cinematic(link:String) {
		var mc = Manager.DM.attach(link, Data.DP_TOP);
		mc._x = 100;
		mc._y = 100;
		mc._alpha = 0;
		mc.stop();
		mc.blendMode = "layer";
		mc.filters = [
			new flash.filters.GlowFilter( 0x0, 1, 8,8, 600, 1, true ),
			new flash.filters.GlowFilter( 0xffffff, 1, 6,6, 600, 1, true ),
			new flash.filters.GlowFilter( 0x0, 1, 3,3, 600),
		];
		cptCin = 0;
		cineList.push(mc);
	}

	function detachPop() {
		detachMask();
		if ( fl_generated )
			startAnim(A_FadeRemove, popMC).spd*=2;
		else
			popMC.removeMovieClip();
		popMC = null;
		if ( fs!=null )
			dock.unlock();
		dock.show();
	}

	public function popUp(str:String,?cb:Void->Void) {
		detachPop();
		dock.lock();
		dock.hide();

		str = StringTools.replace(str,"__","\n----------------------------------------------\n");

		if ( cb==null )
			attachMask(detachPop);
		else {
			var me = this;
			attachMask( function() {
				me.detachPop();
				cb();
			} );
		}
		popMC = cast Manager.DM.attach("pop", Data.DP_TOP);
		popMC.field.text = str;
		popMC.bg._width = popMC.field.textWidth+13;
		popMC.bg._height = popMC.field.textHeight+10;
		popMC._x = Data.WID*0.5 - popMC.bg._width*0.5;
		popMC._y = Data.HEI*0.5 - popMC.bg._height*0.5;
		if ( fl_generated )
			startAnim( A_Text, popMC, str );
//		startAnim( A_BubbleIn, popMC ).spd*=0.8;
	}


	public function printSide(title:String,str:String,?f:FSNode) {
		str = Data.htmlize(str);
		if ( f!=null ) {
			var name = f.name;
			str = "<div class='file_"+name.substr(name.lastIndexOf(".")+1)+"'>"+str+"</div>";
		}
		CNX.JsMain.print.call([title,str]);
	}

	public function printBriefing(short,full) {
		CNX.JsMain.printBriefing.call( [short, full] );
	}

	public function detachSide() {
		printSide("","");
	}

	public function bubble(mc:flash.MovieClip, title:String, ?str:String, ?delay=0.0, ?cbOver:Void->Void, ?cbOut:Void->Void) {
		if ( delay==0 ) delay = -0.6;
		if ( str==null ) {
			str = title;
			title = null;
		}
		var me = this;
		mc.onRollOver = function() {
			me.attachBubble(mc,str,title,delay);
			cbOver();
		}
		mc.onRollOut = function() {
			me.detachBubble();
			cbOut();
		}
		mc.onReleaseOutside = mc.onRollOut;
	}

	function attachBubble(mc,str,title,d:Float) {
//		if ( Progress.isRunning() )
//			return;
		if ( hasAnim(mc,0.2) )
			return;
		detachBubble();
		bmc = cast Manager.DM.attach("bubble",Data.DP_TOP);

//		// local to global...
//		var x = mc._x;
//		var y = mc._y;
//		var ref = mc;
//		while(ref._parent!=Manager.ROOT && ref!=null) {
//			ref = ref._parent;
//			if ( ref!=null ) {
//				x+=ref._x;
//				y+=ref._y;
//			}
//		}
//
//		bmc._x = x;
//		bmc._y = y;
		if ( title!=null )
			bmc.title.text = title;
		else
			bmc.title.text = "";
		bmc.field.text = str;
		var maxWid = Math.max(bmc.field.textWidth,bmc.title.textWidth);
		var totHei = bmc.field.textHeight + bmc.title.textHeight;
		bmc.title._y = -Math.round(totHei*0.5);
		bmc.field._y = bmc.title._y+bmc.title.textHeight;
		bmc.bg._width = 10 + maxWid;
		bmc.bg._height = 10 + bmc.field.textHeight + bmc.title.textHeight;
		bmc.l._height = bmc.bg._height+6;
		bmc.r._height = bmc.l._height;
		bmc.r._x = bmc.bg._width+5;
		bmc.field._width = bmc.field.textWidth+5;
		bmc.field._height = bmc.field.textHeight+5;
		bmc.title._width = bmc.title.textWidth+5;
		bmc.title._height = bmc.title.textHeight+5;
		updateBubble();

		if ( !fl_lowq )
			startAnim(A_BubbleIn, bmc, d);
//		var a = startAnim(A_Text, bmc, str);
//		a.spd*=2;
	}

	public function detachBubble() {
		if ( bmc._visible )
			if ( fl_lowq )
				bmc.removeMovieClip();
			else
				startAnim(A_FadeRemove,bmc).spd*=2.5;
		else
			bmc.removeMovieClip();
		bmc = null;
	}


	public function detachMask(fl_anim=false) {
		if ( fl_anim ) {
			startAnim(A_FadeRemove,mask);
			mask = null;
		}
		else
			mask.removeMovieClip();
	}

	public function attachMask(?cb:Void->Void, ?dp:Int) {
		if ( dp==null )
			dp = Data.DP_FS;
		mask = Manager.DM.attach("mask",dp);
		mask._alpha = 50;
		if ( cb!=null )
			mask.onRelease = cb;
		else
			mask.onRelease = function() {};
	}

	public function askPass(f:FSNode) {
		detachPass();
		hideCmdLine();
		attachMask(detachPass);

		passFile = f;
		pwin = cast Manager.DM.attach("password", Data.DP_TOP);
		pwin.field.text = Lang.fmt.AskPass({_f:passFile.name});
		pwin._x = Std.int(Data.WID*0.5 - pwin._width*0.5);
		pwin._y = Std.int(Data.HEI*0.5 - pwin._height*0.5);
		pwin.input.text = "";
		var me = this;
		pwin.input.onChanged = function(tf) {
			me.startAnim( A_Blink, cast tf ).spd*=1.5;
		}
		startAnim(A_Text, pwin, pwin.field.text);
		startAnim(A_BubbleIn, pwin);
		setFocus(pwin.input);
		playSound("bleep_07");
	}

	function detachPass() {
		ffield = null;
		pwin.removeMovieClip();
		pwin = null;
		detachMask();
		showCmdLine();
	}

	function validatePass(str:String,pf:FSNode) {
		if ( ffield==null )
			return;
		detachPass();
		if ( Data.trimSpaces(str)==Data.trimSpaces(fs.mpass) ) {
			for (f in fs.getFolderFiles(pf))
				if ( f.av==AntivirusXml.get.passwd )
					f.disableAV();
			pf.password = null;
			log(Lang.get.LoginSuccess);
			if ( unlockedPass.get(fs.mpass)==null )
				winGoal( "passwd" );
			unlockedPass.set(fs.mpass,true);
			pf.redraw();
			addIconRain( fs.sdm, ["fx_lock"], pf.mc);
			playSound("bleep_06");
		}
		else
			popUp(Lang.get.LoginFailed);
	}

	public function hideCompletion() {
		for (mc in compList)
			startAnim(A_FadeRemove, mc).spd*=1.5;
		compList = new List();
	}

	function showCompletion(list:List<String>) {
		hideCompletion();
		for (m in list) {
			var mc : MCField = cast Manager.DM.attach("compSuggest", Data.DP_TOPTOP);
			mc.field.text = m;
			mc._x = cmdLine._x+50;
			mc._y = cmdLine._y - compList.length*17;
			startAnim(A_Text, mc, mc.field.text).spd*=2;
			compList.add(mc);
		}
	}


	public function attachCmdLine() {
		if ( !fl_leet )
			return;
		cmdLine.removeMovieClip();
		cmdLine = cast Manager.DM.attach("cmdLine", Data.DP_TOPTOP);
		cmdLine._x = 16;
		cmdLine._y = Data.HEI-cmdLine._height+2;
		cmdLine.field.text = "";
		cmdLine._alpha = 90;
//		var me = this;
//		cmdLine.field.onChanged = function(tf) {
//			me.startAnim( A_Blink, me.cmdLine ).spd*=1.5;
//		}
		hideCmdLine();
	}

	public function showCmdLine() {
		if ( !fl_leet || fs==null )
			return;
		cmdLine._visible = true;
		cmdLine.field.text = "";
		setFocus(cmdLine.field);
	}

	public function hideCmdLine() {
		if ( !fl_leet )
			return;
		cmdLine._visible = false;
		cmdLine.field.text = "";
		setFocus(null);
	}

	function autoComplete(parent:FSNode, str:String) {
		hideCompletion();
		var original = str;
		str = Data.trimSpaces(str);
		while ( str.indexOf("  ")>=0 )
			str = StringTools.replace( str, "  ", " " );
		var end = str.indexOf(" ");
		if ( end<0 )
			end = 999;
		var virusId = str.substr(0,end).toLowerCase();
		var target = str.substr(end+1).toLowerCase();

		// liste de complétion
		var clist = new List();
		if ( target==null || target.length==0 ) {
			// virus
			for (v in dock.getCurrentViruses())
				if ( v.id.toLowerCase().indexOf(virusId)==0 && v.target!="_net" && (v.uses==null || v.uses>0) )
					clist.add(v.id);
			// masqués
			for (v in VirusXml.getCategory("hidden", gameLevel, true))
				if ( v.id.toLowerCase().indexOf(virusId)==0 && v.target!="_net" )
					clist.add(v.id);
		}
		else {
			// fichiers
			for (f in fs.getFolderFiles(parent))
				if ( !f.fl_deleted && !f.hasEffect(E_Masked) && f.name.toLowerCase().indexOf(target)==0 )
					clist.add(f.name);
		}

		// aliases
		for (from in aliases.keys())
			clist.add(from);

		// on vire les doublons
		for (a in clist) {
			var n = 0;
			for (b in clist)
				if (a==b) n++;
			while (n>1) {
				clist.remove(a);
				n--;
			}
		}


		if ( clist.length==0 )
			return original;
		else {
			if ( target.length>0 ) {
				var comp = getCompletion(target, clist);
				if ( comp.isBest )
					return virusId + " " + comp.result + " ";
				else {
					showCompletion(comp.all);
					return virusId + " " + comp.result;
				}
			}
			else {
				var comp = getCompletion(virusId, clist);
				if ( comp.isBest )
					return comp.result + " ";
				else {
					showCompletion(comp.all);
					return comp.result;
				}
			}
		}
//			if ( clist.length==0 )
//				original
//			else {
//				var best = clist[0];
//				if ( clist.length>1 ) {
//					var fl_found = false;
//					while(!fl_found) {
//						var i = 0;
//						fl_found = true;
//						for (w in clist)
//							if ( w.indexOf(best)<0 ) {
//								fl_found = false;
//								best = best.substr(0,best.length-1);
//								break;
//							}
//					}
////					log( Lang.fmt.Log_AutoComplete({_list:list.join(", ")}) );
//					words[words.length-1] = best;
//				}
//				else
//					words[words.length-1] = best+" ";
//				words.join(" ");
//			}
	}


	function getCompletion(str:String, list:List<String>) {
		var matches = new List();
		for (w in list)
			if ( w.toLowerCase().indexOf(str.toLowerCase()) == 0 )
				matches.add(w);

		if ( matches.length==0 )
			return {
				isBest	: false,
				all		: matches,
				result	: str,
			}

		if ( matches.length==1 )
			return {
				isBest	: true,
				all		: matches,
				result	: matches.first(),
			}

		// plusieurs matches possibles, on renvoie la plus petite partie commune
		var common = "";
		var i = 0;
		while( i<matches.first().length ) {
			var c = matches.first().charAt(i).toLowerCase();
			if ( c==null || c.length==0 )
				break;
			var fl_match = true;
			for (m in matches)
				if ( m.toLowerCase().charAt(i)!=c )
					fl_match = false;
			if ( !fl_match )
				break;
			common+=c;
			i++;
		}
		return {
			isBest	: false,
			all		: matches,
			result	: common,
		}
	}



	public function showSystemGame(file:FSNode) {
		detachSystemGame();
		dock.lock();
		dock.hide();
		attachMask(callback(detachSystemGame,true));
		var list = new Array();
		for (y in 0...Data.MATRIX_WID)
			for (x in 0...Data.MATRIX_WID) {
				var mc = Manager.DM.attach("sysGameCube", Data.DP_TOP);
//				var pt = Data.toIso(x,y,60);
//				mc._x = pt.x+250;
//				mc._y = pt.y+200;
				var w = mc._width+1;
				mc._x = 100 + x*w;
				mc._y = 50 + y*w;
				mc.smc.stop();
				if (file.allowMatrix[x][y]) {
					mc.onRelease = callback(onActivateMatrix,file,mc,x,y);
//					mc.smc.gotoAndStop(3);
					mc.smc.filters = [ new flash.filters.GlowFilter(Data.GREEN,1, 10,10, 3,1, true) ];
				}
				// case activée
				mc.smc.gotoAndStop( if(fs.matrix[x][y]) 2 else 1 );
				sysGameList.push(mc);
				if ( Std.random(2)==0 )
					startAnim(A_BubbleIn, mc, -Std.random(120)/100);
				else
					startAnim(A_FadeIn, mc, -Std.random(120)/100).spd*=1.5;
			}
		Data.zsort(Manager.DM, sysGameList);
	}

	function onActivateMatrix(file:FSNode, mc:flash.MovieClip, x,y) {
		if ( fs.fl_auth )
			return;

		if ( fs.matrix[x][y])
			fs.matrix[x][y] = false;
		else {
			// vérif cpt
			var max = Data.MATRIX_WID-1;
			var n = 0;
			for (x in 0...Data.MATRIX_WID)
				for (y in 0...Data.MATRIX_WID)
					if ( fs.matrix[x][y] && file.allowMatrix[x][y] )
						n++;
			if ( n>=max ) {
				popUp("can't tag more than "+max+" slots");
				return;
			}
			// ok !
			fs.matrix[x][y] = true;
		}

		// validation
		if ( Data.hasLine(fs.matrix) ) {
			fs.corrupt();
			detachSystemGame(true);
		}
		mc.smc.gotoAndStop( if(fs.matrix[x][y]) 2 else 1 );
	}

	function detachSystemGame(?fl_unlock=false) {
		detachMask();
		for (mc in sysGameList)
			startAnim(A_FadeRemove, mc, -Std.random(50)/100).spd*=2;
		sysGameList = new Array();
		if ( fl_unlock ) {
			dock.unlock();
			fs.clearTarget();
		}
		dock.show();
	}


	public function detachCMenu() {
		startAnim(A_FadeRemove, cmenu).spd*=3;
		cmenu.onRelease = function() {};
	}


	public function showCMenu(?dm:mt.DepthManager, x:Float,y:Float, ?cancel:Void->Void, blist:Array<{label:String, cb:Void->Void}>) {
		if ( fl_end )
			return;
		if ( dm==null )
			dm = Manager.DM;
		detachCMenu();
		if ( blist==null || blist.length<=0 )
			return;
		playSound("bleep_07");
		blist.push({label:Lang.get.MenuCancel, cb:callback(onMenuItem,cancel)});
		cmenu = dm.empty(Data.DP_TOP);
		var i = 0;
		for (b in blist) {
			var mmc = cmenu.attachMovie("menuButton","menu_"+Data.UNIQ, Data.UNIQ++);
			var mc : MCField = cast mmc;
			mc._y = i*(mc.smc._height+2);
			mc.field.text = b.label;
			initStandardButton(mc, b.cb);
			startAnim(A_MenuIn, mc, -i*0.2).spd*=2;
			i++;
		}
		cmenu._x = Math.round(x);
		cmenu._y = Math.round(y+10);
	}

	public function initStandardButton(mc:MCField, cb:Void->Void) {
		mc.onRelease = callback(onMenuItem,cb);
		mc.onRollOver = callback(onMenuOver,mc);
		mc.onRollOut = callback(onMenuOut,mc);
		mc.onReleaseOutside = callback(onMenuOut,mc);
	}

	public function onMenuOver(mc:flash.MovieClip) {
		mc.smc.filters = [ new flash.filters.GlowFilter(0xffffff,1, 3,3,5) ];
	}

	public function onMenuOut(mc:flash.MovieClip) {
		mc.smc.filters = [];
	}

	function onMenuItem(cb:Void->Void) {
		detachCMenu();
		playSound("bleep_07");
		if ( cb!=null )
			cb();
	}


	public function decayLog() {
		var now = Date.now().getTime();

		var last = logLines.first();
		if ( now-last.t>=200 )
			for (l in logLines) {
				if ( l.mc._alpha==100 )
					l.ta=45;
				else
					l.ta-=20;
			}
	}

	public function log(str:String, ?color:Int) {
		if ( color==null )
			color = Data.GREEN;
		decayLog();


		var lmc : MCField = cast Manager.DM.attach("logLine",Data.DP_TOP);
		lmc.field.text = str;
		lmc.field.textColor = color;
		logMC._y+=lmc.field.textHeight;

		if ( color!=Data.GREEN )
			lmc.field.filters = [ new flash.filters.GlowFilter( color, 1, 8,8,1 ) ];

		var bmp = new BitmapData( Std.int(lmc.field.textWidth+5), Std.int(lmc.field.textHeight+5), true, 0x009900);
		bmp.draw(lmc);
		lmc.removeMovieClip();

		var mc = Manager.DM.empty(Data.DP_TOP);
		mc.attachBitmap(bmp,1);

		startAnim(A_Blink,mc);

		logHistory.push({col:color, str:str});
		logLines.push({
			ta:100,
			t:Date.now().getTime(),
			mc:mc,
		});

		if ( logHistory.length > MAX_LOG_LENGTH )
			logHistory.splice(0, logHistory.length-MAX_LOG_LENGTH);

		Manager.DM.over(moreLog);
		updateLog();
	}

	public function hideLog() {
		for (l in logLines)
			l.mc._visible = false;
		moreLog._visible = false;
	}

	public function showLog() {
		for (l in logLines)
			l.mc._visible = true;
		moreLog._visible = true;
	}

	function showLogHistory() {
		if (fl_end)
			return;
		var app = new WinAppLog(this);
		app.start();
		app.showLog( logHistory );
	}

	public function bigLog(str:String,?fl_long=false, ?ydelta=0, ?fl_permanent=false) {
		var mc : MCField = cast Manager.DM.attach("bigField",Data.DP_TOP);
		mc.field.text = str;
		mc._x = Std.int(Data.WID*0.5);
		mc._y = Std.int(Data.HEI*0.3) + ydelta;
		var a = startAnim(A_Text,mc,str);
		a.spd*=1.5;
		var me = this;
		if ( !fl_permanent )
			a.cb = function() {
				me.startAnim(A_FadeRemove,mc,str,-2.5);
				a.spd *= if(fl_long) 0.2 else 1;
			}
		return a;
	}


	public static function printTip() {
		var tips = new Array();
		for (i in 0...40)
			tips.push( TD.texts.get("tips") );
		UserTerminal.CNX.JsMain.printTip.call([
			Lang.get.TipTitle, Data.htmlize( tips[Std.random(tips.length)] )
		]);
	}

	public function spam(str:String) {
//		var s = spamLog.field.text+str+"\n";
//		s = stripLines(s,9);
//		spamLog.field.text = s;
	}


	function onKey() {
		if ( apps.length > 0 )
			return;

		// touches spéciales
		var c = Key.getCode();
		switch (c) {
			case Key.ESCAPE :
				hideCompletion();
				if ( popMC!=null )
					detachPop();
				else if ( pwin!=null )
					detachPass();
				else if ( Progress.isRunning() ) {
					Progress.cancel();
					log(Lang.get.Log_Cancelled);
				}
				else if ( fl_leet )
					cmdLine.field.text = "";
			case Key.TAB :
				if ( cmdLine!=null ) {
					cmdLine.field.text = autoComplete( fs.curFolder, cmdLine.field.text );
					focus(-1);
				}
				else
					if ( fs!=null && pwin==null )
						fs.nextTarget();
			case Key.RIGHT :
				if ( Key.isDown(Key.CONTROL) && fs!=null && pwin==null )
					fs.nextTarget();
			case Key.LEFT :
				if ( Key.isDown(Key.CONTROL) && fs!=null && pwin==null )
					fs.prevTarget();
			case Key.UP :
				if ( fl_leet && fs!=null && popMC==null && pwin==null ) {
					if ( historyPos > 0 ) {
						historyPos--;
						cmdLine.field.text = cmdHistory[historyPos];
						forcedCaret = -1;
					}
				}
			case Key.DOWN :
				if ( fl_leet && fs!=null && popMC==null && pwin==null ) {
					if ( historyPos < cmdHistory.length-1 ) {
						historyPos++;
						cmdLine.field.text = cmdHistory[historyPos];
						forcedCaret = -1;
					}
				}
			case Key.ENTER :
				hideCompletion();
				if ( popMC!=null )
					detachPop();
				else if ( pwin!=null )
					validatePass(pwin.input.text,passFile);
				else if ( fl_leet && fs!=null ) {
					var cmd = cmdLine.field.text;
					try {
						vman.commandLine(cmd);
					}
					catch(e:String) {
						if (e!=null && e!="" )
							log(e);
					}
					cmdHistory.push(cmd);
					while ( cmdHistory.length>20 )
						cmdHistory.splice(0,1);
					historyPos = cmdHistory.length;
					cmdLine.field.text = "";
				}
			case Key.SPACE :
				if ( popMC==null && pwin==null && fs!=null && !fl_leet )
					fs.onGotoParent();
		}

		// scrolling au clavier
		if ( pwin==null ) {
			switch(c) {
				case Key.PGUP :
					if ( fs!=null && pwin==null ) {
						fs.scroll(-1);
						forcedCaret = caretIdx;
					}
				case Key.PGDN :
					if ( fs!=null && pwin==null ) {
						fs.scroll(1);
						forcedCaret = caretIdx;
					}
			}
		}

		// touches "lettres"
		if ( popMC==null && pwin==null ) {
			var char = String.fromCharCode(Key.getAscii()).toLowerCase();
			switch (char) {
				case "a" :
					#if debug
					if ( !fl_leet && !fl_adminTest ) {
						log("admin test ON");
						fl_adminTest = true;
						endGame();
					}
					#end
				case "c" :
					if ( fs==null )
						dock.switchDeck();

				case "d" :
					if ( Key.isDown(Key.CONTROL) && fs!=null )
						fs.clearTarget();

//				case 178 :
//					if ( fs!=null && Manager.PARAMS._profile._leet )
//						attachCmdLine();
			}

			// dock shortcuts
			if ( cmdLine==null )
				for (i in 0...ls.shortcuts.length)
					if ( c==ls.shortcuts[i] ) {
						dock.onShortcut(i);
						break;
					}

//			if ( c>=48 && c<=57 && cmdLine==null )
//				dock.onKeyShortcut(c-48);
		}
	}


	function stopGame() {
		fl_busted = true;
		for (a in apps)
			a.stop();
		disconnectFS(true);
		Progress.cancel();
	}

	public function onNodeStatusChanged(node:NetNode) {
		if ( node==alarmOrigin )
			stopAlarm();
		var alarm = net.getLinkedAlarm(node);
		if ( alarm!=null )
			startAlarm(alarm);
	}

	public function startAlarm(node:NetNode) {
		if ( alarmTimer!=null )
			return;
		var d = ALARM_DURATION;
		if ( net.isShielded(node) )
			d += ALARM_DURATION;
		if ( gameLevel>=9 )
			d += Std.int(ALARM_DURATION*0.5);
		alarmOrigin = node;
		alarmTimer = d+1;
	}

	public function stopAlarm() {
		playSound("alarm_01");
		var me = this;
		haxe.Timer.delay(
			function() { me.bigLog(Lang.get.AlarmStop, true, 60); },
			Std.int(DateTools.seconds(1))
		);
		alarmOrigin = null;
		alarmTimer = null;
	}

	public function onAlarmEnd() {
		stopGame();
		playSound("alarm_02");
		playSound("corrupt_02");
		popUp(Lang.get.AlarmEnd);
	}


	function onTimeOut() {
		stopGame();
		popUp(Lang.get.TimeOut);
	}

	function onDeath() {
		disconnectFS(true);
		Progress.cancel();
		popUp(Lang.get.YouAreDead);
	}

	// méthode appelée 1x par seconde si le timer est actif
	function onTick() {
		tick++;
		vman.onTick(tick);
		// regen mana
		if ( tick%5==0 && hasChipset(ChipsetsXml.get.regen) )
			if ( mana<manaTotal ) {
				mana++;
				updateBars();
			}
		// mana overflow
		if ( tick%4==0 && hasChipset(ChipsetsXml.get.smana) )
			damage(1,false);
		// alarme
		if ( alarmTimer!=null && !fl_busted ) {
			// feedback (son + msg)
			if ( alarmTimer%10 == 0 ) {
				bigLog( Lang.fmt.AlarmStatus({_n:alarmTimer}), 60 );
				if ( alarmTimer ==ALARM_DURATION )
					playSound("alarm_01");
				playSound("alarm_02");
			}
			// bleep sur réseau
			net.bleep(alarmOrigin);
			// décompte
			alarmTimer--;
			if ( alarmTimer<=0 )
				onAlarmEnd();
		}
	}

	public function isDisabled() {
		return fl_end || fl_busted || life<=0 || mana<=0;
	}

	public function getDisableReason() {
		if ( fl_busted )	return Lang.get.CantConnectWhenBusted;
		if ( life<=0 )		return Lang.get.CantConnectWhenDead;
		if ( mana<=0 )		return Lang.get.CantConnectWhenOOM;
		return "";
	}

	function stripLines(str:String,n:Int) {
		var lines = str.split("\r");
		while (lines.length>n)
			lines.shift();
		return lines.join("\n");
	}

	inline function binary(n:Int) {
		var str = "";
		for (i in 0...n)
			str+=""+Std.random(10);
		return str;
	}

	inline function normFact(f:Float,max:Float) {
		return Math.min( 1, f/max );
	}

	inline function factBetween(f:Float,a:Float,b:Float) {
		return Math.min( 1, Math.max(0,f-a)/(b-a) );
	}


	function updateAnims() {
		for (a in animList) {
			if ( a.mc._name==null ) {
				a.kill = true;
				continue;
			}
			var cpt =
				if (a.t==null)
					Progress.get();
				else {
					a.t += a.spd*dspeed;
					if ( a.t>1 )
						a.t=1;
					a.t;
				};
			if ( !a.kill && cpt>=0 ) {
				switch(a.type) {

					case A_PlayFrames :
						a.mc.gotoAndStop( Math.floor(cpt*a.mc._totalframes) );

					case A_FadeIn :
						a.mc._alpha = 100 * cpt;

					case A_FadeOut :
						a.mc._alpha = 100 * (1-cpt);

					case A_BlurIn :
						a.mc._alpha = 100 * normFact(cpt,0.4);
						a.mc.filters = [ new flash.filters.BlurFilter(16*(1-cpt),16*(1-cpt)) ];

					case A_FadeRemove :
						a.mc._alpha = 100 * (1-cpt);
						if ( cpt>=1 )
							a.mc.removeMovieClip();

					case A_Text :
						var mcc : MCField = cast a.mc;
						mcc.field.text = a.txt.substr(0, Math.floor(a.txt.length*cpt));
						if ( cpt<1 )
							mcc.field.text += "_";

					case A_HtmlText :
						var mcc : MCField = cast a.mc;
						mcc.field.htmlText = a.txt.substr(0, Math.floor(a.txt.length*cpt));
						if ( cpt<1 )
							mcc.field.htmlText += "_";

					case A_EraseText :
						var mcc : MCField = cast a.mc;
						mcc.field.text = a.txt.substr(0, Math.floor(a.txt.length*(1-cpt)));
						if ( cpt<1 )
							mcc.field.text += "_";
						else
							mcc.field.text = "";

					case A_Decrypt :
						var mcc : MCField = cast a.mc;
						var str = mcc.field.text;
						if ( str.indexOf("*")>=0 && Std.random(100)<65 ) {
							var n = -1;
							do {
								n = Std.random(str.length);
							} while (str.charAt(n)!="*");
							mcc.field.text = str.substr(0,n)+a.txt.charAt(n)+str.substr(n+1);
						}
						if ( str.indexOf("*")<0 )
							cpt = 1;
						if ( cpt>=1 ) {
							startAnim(A_Blink, a.mc);
							mcc.field.text = a.txt;
						}

					case A_Shake :
						var cpt2 = normFact(cpt,0.2);
						if ( cpt2<1 ) {
							a.mc._x = a.tx + (1-cpt2)*(2+Std.random(2)) * (Std.random(2)*2-1);
							a.mc._y = a.ty + (1-cpt2)*(2+Std.random(2)) * (Std.random(2)*2-1);
						}
						else
							a.kill = true;
					case A_Move :
						if ( a.tx!=null )
							a.mc._x = Math.floor( a.tx + (1-normFact(cpt,0.2)) * (a.x-a.tx) );
						if ( a.ty!=null )
							a.mc._y = Math.floor( a.ty + (1-normFact(cpt,0.2)) * (a.y-a.ty) );

					case A_Delete :
						a.mc.gotoAndStop( Math.floor((1-normFact(cpt,0.8))*a.mc._totalframes) );
						var cpt2 = factBetween(cpt,0.7,1);
						a.mc.filters = [ new flash.filters.BlurFilter(cpt2*64,cpt2*8) ];
						a.mc._alpha = 100*(1-factBetween(cpt,0.8,1));
						if ( cpt>=1 )
							a.mc._visible = false;

					case A_Blink :
						a.mc.filters = [ new flash.filters.GlowFilter( 0xffffff,(1-factBetween(cpt,0.5,1)), (1-cpt)*7, (1-cpt)*7, 1, true ) ];

					case A_StrongBlink :
						a.mc.filters = [ new flash.filters.GlowFilter( 0xffffff,(1-factBetween(cpt,0.3,1)), 3,3, 10 ) ];

					case A_Auth :
						var mcc : MCField = cast a.mc;
						if ( Std.random(2)==0 )
							mcc.field.text+=binary(30)+"\n";
						if ( cpt>=1 ) {
							mcc.field.text += "_________________\nACCESS GRANTED :-)\n";
							startAnim( A_FadeRemove, a.mc, -2 );
							TD.texts.set("user",fs.owner);
							popUp(TD.texts.get("welcome"));
						}
						mcc.field.text = stripLines(mcc.field.text,8);

					case A_Connect :
						var mcc : MCField = cast a.mc;
						if ( cpt>=0.4 && Std.random(7)==0 )
							if ( a.data==-1 )
								mcc.field.text+=TD.texts.get("error")+"\n";
							else {
								TD.texts.set("file",TD.fsNames.get("file.lib"));
								mcc.field.text+=TD.texts.get("connecting")+"\n";
							}
						if ( cpt>=1 ) {
							mcc.field.text += "Connected !\n";
							startAnim( A_FadeRemove, a.mc );
						}
						mcc.field.text = stripLines(mcc.field.text,8);

					case A_BubbleIn :
						if (!a.mc._visible)
							a.mc._visible = true;
						a.mc._alpha = normFact(cpt,0.2)*100;
//						a.mc._xscale = 5 + normFact(cpt,0.8)*95;
						a.mc._yscale = 5 + factBetween(cpt,0.2,0.6)*95;
						var mcc : BubbleMC = cast a.mc;
						var cpt2 = 1-factBetween(cpt,0.4,1);
						a.mc.filters = [
							new flash.filters.BlurFilter(32*cpt2,2*cpt2),
//							new flash.filters.DropShadowFilter(3,45, 0x0,0.5, 0,0),
						];
//						mcc.field.filters = [ new flash.filters.BlurFilter(32*cpt2,2*cpt2) ];
					case A_Bump :
						a.mc._y+=a.data;
						a.data+=3.5;
						if ( a.mc._y>=a.ty )
							a.kill = true;
					case A_MenuIn :
						a.mc._alpha = 100 * cpt;
						if ( a.mc._x<a.tx )
							a.mc._x = Math.floor( a.tx + (1-normFact(cpt,0.6)) * (a.x-a.tx) );
				}
				if ( cpt>=1 )
					a.kill = true;
			}
		}

		// garbage collector
		var i = 0;
		while(i<animList.length)
			if ( animList[i].kill ) {
				endAnim(animList[i]);
				animList.splice(i,1);
			}
			else
				i++;
	}


	function updateFx() {
		var i = 0;
		while (i<fxList.length) {
			var fx = fxList[i];
			fx.mc._x = (fx.mc._x + fx.dx*Timer.tmod);
			fx.mc._y = (fx.mc._y + fx.dy*Timer.tmod);
			fx.dx+=fx.gx*Timer.tmod;
			fx.dy+=fx.gy*Timer.tmod;
			fx.timer+=Timer.tmod;

			var fl_kill = false;
			switch (fx.type) {
				case AFX_PopUp :
					if ( fx.timer>=Data.SECONDS(1) )
						fx.mc._alpha-=Timer.tmod*4;
					fl_kill = fx.mc._alpha<=0;
				case AFX_Binary :
					fx.data+=0.2;
					fx.mc._xscale = Math.cos(fx.data)*100;
					if ( fx.timer>=Data.SECONDS(1) )
						fx.mc._alpha-=Timer.tmod*4;
					fl_kill = fx.mc._alpha<=0;
				case AFX_PlayFrames :
					fl_kill = fx.mc.smc._currentframe==fx.mc.smc._totalframes;
					fx.mc.smc.nextFrame();
				case AFX_Spark :
					if ( fx.timer>=Data.SECONDS(2) )
						fx.mc._alpha -= Timer.tmod*4;
					fl_kill = fx.mc._alpha<=0;
			}
			if ( fl_kill ) {
				fx.mc.removeMovieClip();
				fxList.splice(i,1);
			}
			else
				i++;
		}
	}


	function updateCinematics() {
		for (mc in cineList) {
			if ( mc._currentframe==1 && mc._alpha<100 ) {
				mc._alpha+=Timer.tmod*6;
				if ( mc._alpha>100 )
					mc._alpha = 100;
				continue;
			}

//			cptCin+=Timer.tmod;
//			if ( cptCin>=CIN_DELAYS[mc._currentframe-1] ) {
//				if ( mc._currentframe<mc._totalframes )
//					cptCin = 0;
				mc.nextFrame();
//			}
//			else
//				continue;

			if ( mc._currentframe==mc._totalframes ) {
				mc._alpha-=Timer.tmod*3;
				if ( mc._alpha<=0 ) {
					mc.removeMovieClip();
					cineList.remove(mc);
				}
			}

		}
	}

	function updateLog() {
		logMC._x = Std.random(20);
		if ( logMC._y>0 )
			logMC._y--;
		var now = Date.now().getTime();
		var n = 0;
		for (l in logLines) {
//			if ( now-l.t>=DateTools.seconds(3) && l.mc._alpha==100 )
//				l.ta=65;
			l.mc._x = 16;
			l.mc._y = Data.HEI - 20 - n*16;
			if ( fl_leet )
				l.mc._y -= 20;
			if ( l.mc._alpha>l.ta ) {
				l.mc._alpha-=Timer.tmod*2;
				if ( l.mc._alpha<l.ta )
					l.mc._alpha = l.ta;
			}
			if ( l.mc._alpha<=0 ) {
				l.mc.removeMovieClip();
				logLines.remove(l);
			}
			n++;
		}
//		logBmp.fillRect(logBmp.rectangle,0);
//		var age = 0;
//		var prevT = Date.now().getTime();
//		var n = 1;
//		for (l in logLines) {
//			if ( Math.abs(prevT-l.t)>=100 )
//				age++;
//			if ( age>=3 ) {
//				logLines.remove(l);
//				continue;
//			}
//			prevT = l.t;
//			var lmc : MCField = cast Manager.DM.attach("logLine",Data.DP_TOP);
//			lmc.field.text = l.str;
//			lmc._alpha = 100-age*40;
//			logBmp.drawMc(lmc,0,Data.HEI-4-n*16);
//			lmc.removeMovieClip();
//			n++;
//		}
	}

	function updateBubble() {
		var xoff=5;
		var yoff=-10;
		var xm = Manager.ROOT._xmouse;
		var ym = Manager.ROOT._ymouse;
		var rwid = bmc._width * (1/(bmc._xscale/100));
		var rhei = bmc._height * (1/(bmc._yscale/100));

		bmc._x = Math.floor(xm-rwid*0.5)+xoff;
		bmc._y = Math.floor(ym-5-rhei*0.5)+yoff;

		if ( bmc._x+rwid>=Data.WID-30 )
			bmc._x = Data.WID-rwid-30;
		if ( bmc._x<=10 )
			bmc._x = 10;
		if ( ym<=50 && bmc._y-rhei*0.5<=50 )
			bmc._y = 48+rhei*0.5;
		if ( bmc._y-rhei*0.5<=0 )
			bmc._y = rhei*0.5;
		bmc._x = Std.int(bmc._x);
		bmc._y = Std.int(bmc._y);
	}


	function updateTimer() {
		if ( !MissionGen.hasTimer(mdata) )
			return;
		if ( Progress.isRunning() )
			gtimerMC._alpha = 30;
		else
			gtimerMC._alpha = 100;

		if ( fl_end ) {
			gtimerMC.field.text = "--:--";
			return;
		}

		var t = getRemainingTime();
		if ( t<0 ) {
			if ( !fl_busted )
				onTimeOut();
			t = 0;
		}
		var tdata : Time = DateTools.parse(t);
		if ( lastTimer.seconds!=tdata.seconds ) {
			onTick();
			var str = tdata.minutes+":"+Data.leadingZeros(tdata.seconds);
			gtimerMC.field.text = str;
			if ( lastTimer.minutes!=tdata.minutes ) {
				startAnim(A_Blink, gtimerMC).spd*=0.6;
				var me = this;
				var a = startAnim(A_EraseText, gtimerMC);
				a.spd*=4;
				a.cb = function() { me.startAnim(A_Text, me.gtimerMC, str).spd*=4; };
			}
		}
		lastTimer = tdata;
	}


	function updateBars() {
		lifeBar.smc._xscale = 100*life/lifeTotal;
		manaBar.smc._xscale = 100*mana/manaTotal;
		comboMc.removeMovieClip();
		comboMc = Manager.DM.empty(Data.DP_TOP);
		bubble(lifeBar, Lang.fmt.Tooltip_Life({_n:life,_total:lifeTotal}),-1.5);
		bubble(manaBar, Lang.fmt.Tooltip_Mana({_n:mana,_total:manaTotal}),-1.5);

		// combo points
		if ( hasEffect(UE_Combo) ) {
			var n = countEffect(UE_Combo);
			for (i in 0...n) {
				var mc = comboMc.attachMovie("combo","combo_"+Data.UNIQ,Data.UNIQ++);
				mc._x = lifeBar._x - 7;
				mc._y = lifeBar._y + 2 + 6*i;
			}
			comboMc.filters = [new flash.filters.GlowFilter(0x444d5d, 1, 4,4,10)];
			comboMc.cacheAsBitmap = true;
			bubble(comboMc, Lang.fmt.Tooltip_Combo({_n:n,_total:maxCombo}), -1.5);
		}
	}


	function updateSoundAnims() {
		for (sa in soundAnims) {
			var sound = sa.s.data;
			var v = sa.current + sa.dir;
			var fl_done = false;
			if ( sa.dir<0 && v<=sa.target )
				fl_done = true;
			if ( sa.dir>0 && v>=sa.target )
				fl_done = true;

			sa.current = v;
			sound.setVolume(v);
			if ( fl_done )
				stopSoundAnim(sa);
		}
	}


	public function update() {
		fpsAvg = (fpsAvg+Timer.fps())*0.5;
		for (fn in nextStack)
			fn();
		nextStack = new List();

		// fades sons
		updateSoundAnims();


//		if ( spamLog._name!=null && Std.random(100)<10 )
//			spam(TD.texts.get("spamLine"));

		if ( forcedCaret!=null && ffield!=null ) {
			focus(forcedCaret);
			forcedCaret = null;
		}

		Progress.update();

		if ( fl_generated ) {
			if ( fs!=null )
				fs.update();
			updateLog();
			updateTimer();
		}
		// NOTE 1 : attention, log et timer déplacés avant cinematics ! pas de bug à signaler ?
		// NOTE 2 : net.update et dock.update se trouvaient juste après Progress.update !
		for (a in apps)
			a.update();
		net.update();
		dock.update();

		// virus & antivirus
		vman.onEndTurn();
		avman.onEndTurn();

		// flood dans l'écran de boot
		if ( bootCooldown>0 )
			bootCooldown--;
		if ( loadingSteps<=0 && boot._name!=null && !hasAnim(boot) && Std.random(100)<80 && bootCooldown<=0 ) {
			var str = boot.field2.text;
			str+=" "+TD.texts.get("bootResult")+"\n"+TD.texts.get("bootLine");
			str = stripLines(str,11);
			boot.field2.text = str;
			playSound("single_04");
			bootCooldown = 4;
		}

		updateAnims();
		updateFx();
		updateCinematics();

		if ( bmc._name!=null )
			updateBubble();

		if ( ffield!=null ) {
			if ( !hasFocus() )
				focus();
			caretIdx = flash.Selection.getCaretIndex();
		}

		if ( fs!=null && life==0 )
			onDeath();
		if ( Tutorial.at(Tutorial.get.first, "mana") )
			Tutorial.point( Manager.DM, manaBar._x+manaBar._width*0.5-50, manaBar._y, -30 );
		if ( Tutorial.at(Tutorial.get.second, "life") )
			Tutorial.point( Manager.DM, lifeBar._x+lifeBar._width*0.5-50, lifeBar._y, -50 );
		if ( Tutorial.at(Tutorial.get.first, "briefing") )
			Tutorial.point( Manager.DM, Data.WID*0.5, Data.HEI );
//		if ( Tutorial.at(Tutorial.get.first, "welcome") )
//			Tutorial.point( Manager.DM, Data.WID, 50, -90);
		if ( Tutorial.at(Tutorial.get.second, "showLog2") )
			Tutorial.point( Manager.DM, moreLog._x+16, moreLog._y, 30 );
	}
}

class _Com {
	static function _nextTutoStep() {
		Tutorial.onAutoNext();
	}
	static function _anotherTip() {
		UserTerminal.printTip();
	}
}
