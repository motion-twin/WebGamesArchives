class GameManager
{
	static var BASE_VOLUME	= 50;
	static var CONFIG		= null;
	static var KEY			= Std.random(999999)*Std.random(999999);
	static var HH			= new Hash();

	static var SELF			= null; // "this" context for fatal static call

	var fVersion	: int;
	var fps			: float;
	var uniq		: int;
	var fileServ	: FileServer;

	var current		: Mode;
	var child		: Mode;

	var root		: MovieClip;
	var progressBar	: MovieClip;
	var csKey		: int;

	var depthMan	: DepthManager;
	var soundMan	: SoundManager;

	var fl_flash8	: bool;
	var fl_cookie	: bool;
	var fl_debug	: bool;
	var fl_local	: bool;

//	var fl_tutorial	: bool;
//	var fl_soccer	: bool;
//	var fl_multiCoop: bool;
//	var fl_ta		: bool;
//	var fl_taMulti	: bool;
//	var fl_bossRush	: bool;

	var cookie		: Cookie;

	var history		: Array<String>;

	var musics		: Array<Sound>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(mc, initObj) {
		root			= mc;
		uniq			= 666;
		SELF			= this;

		this.fl_local	= initObj.fl_local;
		musics			= initObj.musics;
		history			= new Array();

		logAction("$B"+__TIME__);

		Lang.init(initObj.rawLang);
		Data.init(this);

		// Dev mode
		if ( isDev() ) {
			fl_debug = true;
		}

		if ( isTutorial() || Loader.BASE_SCRIPT_URL==null ) {
			logAction("$using sysfam");
			initObj.families="0,7,1000,18";
			if ( isDev() ) {
				initObj.families="0,7,1000,1001,1002,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19";
			}
		}

		CONFIG = new GameParameters( Std.getRoot(), this, initObj.families, initObj.options );
		if ( fl_local ) {
			cookie = new Cookie(this);
		}

		Log.setColor(0xcccccc);
		Log.tprint._x = Data.DOC_WIDTH*0.7;
		Log.tprint._y = 4;
		Log.tprint.textColor = 0xffff00;

		depthMan	= new DepthManager(root);
		fl_cookie	= fl_debug && fl_local;

		// Flash 8 features
		var strVersion = downcast(Std.getRoot()).$version;
		fVersion = Std.parseInt( strVersion.split(" ")[1].split(",")[0],10 );
		fl_flash8 = (fVersion!=null && !Std.isNaN(fVersion) && fVersion>=8);
		if ( !fl_flash8 ) {
			fatal(Lang.get(15)+"\nhttp://www.macromedia.com/go/getflash");
			return;
		}
		flash.Init.init();

		if (  isMode(null) || isMode("") ) {
			fatal("Veuillez vider votre cache internet (voir page Support Technique en bas du site).");
			return;
//			Std.setVar(Std.getRoot(),"$mode", "$solo".substring(1));
		}

		// Sounds channels
		var volume = CONFIG.soundVolume*100;
		soundMan = new SoundManager( depthMan.empty(Data.DP_SOUNDS), 0 );
		soundMan.setVolume( Data.CHAN_MUSIC,	CONFIG.musicVolume*100 );
		soundMan.setVolume( Data.CHAN_PLAYER,	volume );
		soundMan.setVolume( Data.CHAN_BOMB,		volume );
		soundMan.setVolume( Data.CHAN_ITEM,		volume );
		soundMan.setVolume( Data.CHAN_FIELD,	volume );
		soundMan.setVolume( Data.CHAN_BAD,		Math.max(0,volume-10) );
		soundMan.setVolume( Data.CHAN_INTERF,	Math.max(0,volume-10) );
		for ( var i=0;i<musics.length;i++ ) {
			musics[i].setVolume( CONFIG.musicVolume*100 );
		}
		if ( !CONFIG.hasMusic() ) {
			soundMan.loop("sound_kick", Data.CHAN_MUSIC);
			soundMan.setVolume( Data.CHAN_MUSIC,	0);
		}

		registerClasses();

		var h = HH;
h.set("$8d6fff6186db2e4f436852f16dcfbba8","$4768dc07c5f8a02389dd5bc1ab2e8cf4");h.set("$3bb529b9fb9f62833d42c0c1a7b36a43","$53d55e84334a88faa7699ef49647028d");h.set("$9fa2a5eb602c6e8df97aeff54eecce7b","$0d3258c27fa25f609757dbec3c4d5b40");h.set("$041ccec10a38ecef7d4f5d7acb7b7c46","$9004f8d219ddeaf70d806031845b81a8");h.set("$51cc93b000b284de6097c9319221e891","$b04ce150619f8443c69122877c18abb9");h.set("$38fe1fbe22565c2f6691f1f666a600d9","$05a8015ab342ed46b92ef29b88d30069");h.set("$0255841255b29dd91b88a57b4a27f422","$14460ca82946da41bc53c89e6670b8c0");h.set("$1def3777b79eb80048ebf70a0ae83b77","$8783468478de453e70eeb3b3cb1327cf");h.set("$a1a9405afb4576a3bceb75995ad17d09","$d4a546d78441aba69dc043b9b23dc068");h.set("$8c49e07bc65be554538effb12eced2c2","$3c5fee37f81ebe52a1dc76d7bbdd2c07");h.set("$bfe3df5761159d38a6419760d8613c26","$e701d0c9283358ab44c899db4f13a3fb");

		// Lance le mode correspondant aux données disponibles
		startDefaultGame();

	}



	/*------------------------------------------------------------------------
	REGISTER CLASSES
	------------------------------------------------------------------------*/
	function registerClasses() {
		// *** Items
		Std.registerClass("hammer_item_score", entity.item.ScoreItem);
		Std.registerClass("hammer_item_special", entity.item.SpecialItem);

		// *** Bads
		Std.registerClass(Data.LINKAGES[Data.BAD_POMME],	entity.bad.walker.Pomme);
		Std.registerClass(Data.LINKAGES[Data.BAD_CERISE],	entity.bad.walker.Cerise);
		Std.registerClass(Data.LINKAGES[Data.BAD_BANANE],	entity.bad.walker.Banane);
		Std.registerClass(Data.LINKAGES[Data.BAD_ANANAS],	entity.bad.walker.Ananas);
		Std.registerClass(Data.LINKAGES[Data.BAD_BOMBE],	entity.bad.walker.Bombe);
		Std.registerClass(Data.LINKAGES[Data.BAD_ORANGE],	entity.bad.walker.Orange);
		Std.registerClass(Data.LINKAGES[Data.BAD_FRAISE],	entity.bad.walker.Fraise);
		Std.registerClass(Data.LINKAGES[Data.BAD_ABRICOT],	entity.bad.walker.Abricot);
		Std.registerClass(Data.LINKAGES[Data.BAD_POIRE],	entity.bad.walker.Poire);
		Std.registerClass(Data.LINKAGES[Data.BAD_CITRON],	entity.bad.walker.Citron);
		Std.registerClass(Data.LINKAGES[Data.BAD_FIREBALL],	entity.bad.FireBall);
		Std.registerClass(Data.LINKAGES[Data.BAD_BALEINE],	entity.bad.flyer.Baleine);
		Std.registerClass(Data.LINKAGES[Data.BAD_SPEAR],	entity.bad.Spear);
		Std.registerClass(Data.LINKAGES[Data.BAD_CRAWLER],	entity.bad.ww.Crawler);
		Std.registerClass(Data.LINKAGES[Data.BAD_TZONGRE],	entity.bad.flyer.Tzongre);
		Std.registerClass(Data.LINKAGES[Data.BAD_SAW],	entity.bad.ww.Saw);
		Std.registerClass(Data.LINKAGES[Data.BAD_KIWI],		entity.bad.walker.Kiwi);
		Std.registerClass(Data.LINKAGES[Data.BAD_LITCHI],	entity.bad.walker.Litchi);
		Std.registerClass(Data.LINKAGES[Data.BAD_LITCHI_WEAK],	entity.bad.walker.LitchiWeak);
		Std.registerClass(Data.LINKAGES[Data.BAD_FRAMBOISE],entity.bad.walker.Framboise);
		Std.registerClass("hammer_boss_bat",				entity.boss.Bat);
		Std.registerClass("hammer_boss_human",				entity.boss.Tuberculoz);

		// *** Shoots
		Std.registerClass("hammer_shoot_pepin", entity.shoot.Pepin);
		Std.registerClass("hammer_shoot_fireball", entity.shoot.FireBall);
		Std.registerClass("hammer_shoot_arrow", entity.shoot.PlayerArrow);
		Std.registerClass("hammer_shoot_ball", entity.shoot.Ball);
		Std.registerClass("hammer_shoot_zest", entity.shoot.Zeste);
		Std.registerClass("hammer_shoot_player_fireball", entity.shoot.PlayerFireBall);
		Std.registerClass("hammer_shoot_player_pearl", entity.shoot.PlayerPearl);
		Std.registerClass("hammer_shoot_boss_fireball", entity.shoot.BossFireBall);
		Std.registerClass("hammer_shoot_firerain", entity.shoot.FireRain);
		Std.registerClass("hammer_shoot_hammer", entity.shoot.Hammer);
		Std.registerClass("hammer_shoot_framBall2", entity.shoot.FramBall);

		// *** Bombs
		Std.registerClass("hammer_bomb_classic", entity.bomb.player.Classic);
		Std.registerClass("hammer_bomb_black", entity.bomb.player.Black);
		Std.registerClass("hammer_bomb_blue", entity.bomb.player.Blue);
		Std.registerClass("hammer_bomb_green", entity.bomb.player.Green);
		Std.registerClass("hammer_bomb_red", entity.bomb.player.Red);
		Std.registerClass("hammer_bomb_poire_frozen", entity.bomb.player.PoireBombFrozen);
		Std.registerClass("hammer_bomb_mine_frozen", entity.bomb.player.MineFrozen);
		Std.registerClass("hammer_bomb_soccer", entity.bomb.player.SoccerBall);
		Std.registerClass("hammer_bomb_repel", entity.bomb.player.RepelBomb);

		Std.registerClass("hammer_bomb_poire", entity.bomb.bad.PoireBomb);
		Std.registerClass("hammer_bomb_mine", entity.bomb.bad.Mine);
		Std.registerClass("hammer_bomb_boss", entity.bomb.bad.BossBomb);

		// *** Supas
		Std.registerClass("hammer_supa_icemeteor", entity.supa.IceMeteor);
		Std.registerClass("hammer_supa_smoke", entity.supa.Smoke);
		Std.registerClass("hammer_supa_ball", entity.supa.Ball);
		Std.registerClass("hammer_supa_bubble", entity.supa.Bubble);
		Std.registerClass("hammer_supa_tons", entity.supa.Tons);
		Std.registerClass("hammer_supa_item", entity.supa.SupaItem);
		Std.registerClass("hammer_supa_arrow", entity.supa.Arrow);

		// *** Misc
		Std.registerClass("hammer_player", entity.Player);
		Std.registerClass("hammer_player_wbomb", entity.WalkingBomb);
		Std.registerClass("hammer_fx_particle", entity.fx.Particle);

		// *** GUI
		Std.registerClass("hammer_editor_button", gui.SimpleButton);
		Std.registerClass("hammer_editor_label", gui.Label);
		Std.registerClass("hammer_editor_field", gui.Field);
	}



	/*------------------------------------------------------------------------
	RENVOIE TRUE SI UN SET XML DE LEVEL EXISTE
	------------------------------------------------------------------------*/
	function setExists(n) {
		var data = Std.getVar(root, n);
		return (data!=null)
	}




	/*------------------------------------------------------------------------
	AFFICHE UNE BARRE DE PROGRESSION
	------------------------------------------------------------------------*/
	function progress(ratio:float) {
		// remove
		if ( ratio==null || ratio>=1 ) {
			progressBar.removeMovieClip();
			progressBar = null;
			return;
		}
		// attach
		if ( progressBar==null ) {
			progressBar = depthMan.attach("lifeBar",Data.DP_INTERF);
			progressBar._x = Data.GAME_WIDTH/2;
			progressBar._y = Data.GAME_HEIGHT-40;
		}

		downcast(progressBar).bar._xscale = ratio*100;
	}


	/*------------------------------------------------------------------------
	ERREUR CRITIQUE
	------------------------------------------------------------------------*/
	static function fatal(msg:String) {
		Log.setColor(0xff0000);
		Log.trace("*** CRITICAL ERROR *** "+msg);
		SELF.current.destroy();
		SELF.root.stop();
		SELF.root.removeMovieClip();
	}


	/*------------------------------------------------------------------------
	AVERTISSEMENT
	------------------------------------------------------------------------*/
	static function warning(msg:String) {
		Log.trace("* WARNING * "+msg);
	}


	/*------------------------------------------------------------------------
	REDIRECTION HTTP
	------------------------------------------------------------------------*/
	function redirect(url,params:String) {
		current.lock();
		Std.getGlobal("exitGame")(url,params);
	}


	/*------------------------------------------------------------------------
	SIGNALE UNE OPÉRATION ILLÉGALE
	------------------------------------------------------------------------*/
	function logIllegal(str) {
		logAction("$!"+str)
	}

	/*------------------------------------------------------------------------
	LOG DE PARTIE
	------------------------------------------------------------------------*/
	function logAction(str) {
		str = Tools.replace(str,"$","");
		str = Tools.replace(str,":",".");
		history.push(str);
	}




	// *** MODES

	/*------------------------------------------------------------------------
	LANCE UN MODE
	------------------------------------------------------------------------*/
	function transition(prev:Mode,next:Mode) {
		next.init();


		if ( prev==null ) {
			current = next;
		}
		else {
			// skips transition animation
			prev.destroy();
			current = next;
//			var m = new mode.ModeSwitcher(this);
//			m.initSwitcher(prev,next);
//			current = upcast(m);
		}
	}


	/*------------------------------------------------------------------------
	LANCE UN MODE "ENFANT"
	------------------------------------------------------------------------*/
	function startChild(c:Mode) {
		if ( child!=null ) {
			fatal("another child process is running!");
		}
		if ( current.fl_lock ) {
			fatal("process is locked, can't create a child");
		}
		current.lock();
		current.onSleep();
		current.hide();
		child = c;
		child.fl_runAsChild = true;
		child.init();
		return child;
	}

	/*------------------------------------------------------------------------
	INTERROMPT LE PROCESS ENFANT (AVEC RETOUR OPTIONNEL)
	------------------------------------------------------------------------*/
	function stopChild(data:'a)  //'
	{
		var n = child._name;
		child.destroy();
		child = null;
		current.unlock();
		current.show();
		current.onWakeUp(n, data);
	}


	/*------------------------------------------------------------------------
	LANCE UN MODE
	------------------------------------------------------------------------*/
	function startMode( m:Mode ) {
		transition(current,m);
	}

	/*------------------------------------------------------------------------
	LANCE UN MODE DE JEU
	------------------------------------------------------------------------*/
	function startGameMode(m:mode.GameMode) {
		transition(current,m);
	}


	/*------------------------------------------------------------------------
	MODES DE JEU
	------------------------------------------------------------------------*/
	function isAdventure() {
		return isMode("$solo");
	}

	function isTutorial() {
		return isMode("$tutorial");
	}

	function isSoccer() {
		return isMode("$soccer");;
	}

	function isMultiCoop() {
		return isMode("$multicoop");;
	}

	function isTimeAttack() {
		return isMode("$timeattack");;
	}

	function isMultiTime() {
		return isMode("$multitime");;
	}

	function isBossRush() {
		return isMode("$bossrush");;
	}

	function isDev() {
		return setExists("xml_dev") && !isFjv();
	}

	function isFjv() {
		return false; // hack anti fjv
		return setExists("xml_fjv");
	}


	function isMode(modeName) {
		return Std.getVar(Std.getRoot(),"$mode") == modeName.substring(1);
	}



	/*------------------------------------------------------------------------
	LANCE LE MODE DE JEU PAR DÉFAUT, SELON LES SETS DISPONIBLES
	------------------------------------------------------------------------*/
	function startDefaultGame() {
		if ( isTutorial() ) {
			startGameMode( new mode.Tutorial(this) );
			return;
		}
		if ( isSoccer() ) {
			startMode( new mode.Soccer(this,0) );
			return;
		}
		if ( isMultiCoop() ) {
			startGameMode( new mode.MultiCoop(this,0) );
			return;
		}
		if ( isTimeAttack() ) {
			startGameMode( new mode.TimeAttack(this,0) );
			return;
		}
		if ( isMultiTime() ) {
			startGameMode( new mode.TimeAttackMulti(this,0) );
			return;
		}
		if ( isBossRush() ) {
			startGameMode( new mode.BossRush(this,0) );
			return;
		}
		if ( isFjv() ) {
			startMode( new mode.FjvEnd(this,false) );
			return;
		}
		if ( isAdventure() ) {
			startGameMode( new mode.Adventure(this,0) );
//			startGameMode( new mode.Tutorial(this) );
//			startGameMode( new mode.Fjv(this,0) );
//			startGameMode( new mode.MultiCoop(this,0) );
//			startGameMode( new mode.BossRush(this, 0) );
//			startGameMode( new mode.TimeAttack(this,0) );
//			startMode( new mode.Test(this) );
//			startMode( new mode.SoccerSelector(this) );
			return;
		}

		fatal("Invalid mode '"+Std.getVar(Std.getRoot(),"$mode")+"' found.");
	}



	// *** MAIN

	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		// Timer
		Timer.update();
		fps = Timer.fps();
		Timer.tmod = Math.min(2.8,Timer.tmod);
		Std.setGlobal("tmod",Timer.tmod);
		Std.setGlobal("Debug",Log);

		// Sons
		soundMan.main();

		// Modes
		current.main();
		if ( child!=null ) {
			child.main();
		}

	}
}
