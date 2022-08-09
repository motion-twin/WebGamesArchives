class mode.GameMode extends Mode
{
	static var WATER_COLOR		= 0x0000ff;


	var fxMan			: FxManager;
	var statsMan		: StatsManager;
	var randMan			: RandomManager;
	var fl_static		: bool; // si true, le comportement initial des monstres sera prévisible (random sinon)
	var fl_bullet		: bool;
	var fl_disguise		: bool;
	var fl_map			: bool;
	var fl_mirror		: bool;
	var fl_nightmare	: bool;
	var fl_bombControl	: bool;
	var fl_ninja		: bool;
	var fl_bombExpert	: bool;

	var fl_ice			: bool;
	var fl_aqua			: bool;

	var fl_badsCallback	: bool;

	var duration		: float;

	var gFriction		: float;
	var sFriction		: float;

	var speedFactor		: float;
	var diffFactor		: float;

	var lists			: Array<Array<Entity>>;
	var killList		: Array<Entity>;
	var unregList		: Array< {type:int,ent:Entity} >;
	var world			: levels.GameMechanics;

	var comboList		: Array<int>;
	var badCount		: int;
	var friendsLimit	: int;

	var fl_clear		: bool;
	var fl_gameOver		: bool;
	var fl_pause		: bool;

	var fl_rightPortal	: bool;

	var huTimer			: float;
	var huState			: int;

	var endModeTimer	: float;

	var shakeTotal		: float;
	var shakeTimer		: float;
	var shakePower		: float;
	var windSpeed		: float;
	var windTimer		: float;
	var fl_wind			: bool;
	var fl_flipX		: bool;
	var fl_flipY		: bool;
	var aquaTimer		: float;

	var keyLock			: int;

	var globalActives	: Array<bool>;
	var endLevelStack	: Array<void->void>;

	var popMC			: { > MovieClip, sub: { > MovieClip, field:TextField, header:TextField } };
	var pointerMC		: MovieClip;
	var radiusMC		: MovieClip;
	var darknessMC		: { > MovieClip, holes:Array<MovieClip> };
	var itemNameMC		: { > MovieClip, field:TextField };
	var pauseMC			: {
		> MovieClip,
		click	: TextField,
		move	: TextField,
		attack	: TextField,
		pause	: TextField,
		space	: TextField,
		title	: TextField,
		tip		: TextField,
		sector	: TextField,
	};
	var mapMC			: {
		> MovieClip,
		field	: TextField,
		ptr		: MovieClip,
		pit		: MovieClip,
	};
	var mapIcons		: Array<MovieClip>;
	var dfactor			: float;
	var targetDark		: float;
	var extraHoles		: Array< {x:float, y:float, d:float, mc:MovieClip} >;

	var lagCpt			: float;

	var tipId			: int;

	var bulletTimer		: float;

	var specialPicks	: Array<int>;
	var scorePicks		: Array<int>;
	var savedScores		: Array<int>;

	var dimensions		: Array<levels.GameMechanics>;
	var currentDim		: int;
	var portalId		: int;
	var latePlayers		: Array<entity.Player>;		// liste de players arrivant en retard d'un portal
	var portalMcList	: Array< {mc:MovieClip, x:float,y:float, cpt:float} >;

	var gi				: gui.GameInterface;
	var gameChrono		: Chrono;

	var mapEvents		: Array< {lid:int, eid:int, misc:String} >;
	var mapTravels		: Array< {lid:int, eid:int, misc:String} >;


	var dvars			: Hash<String>;

	var color			: Color;
	var colorHex		: int;

	var worldKeys		: Array<bool>;

	var forcedDarkness	: int;

	var nextLink		: levels.PortalLink;
	var fakeLevelId		: int;


	var perfectItemCpt	: int;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		duration		= 0;
		lagCpt			= 0;
		fl_static		= false;
		fl_bullet		= true;
		fl_disguise		= true;
		fl_map			= false;
		fl_mirror		= GameManager.CONFIG.hasOption(Data.OPT_MIRROR);
		fl_nightmare	= GameManager.CONFIG.hasOption(Data.OPT_NIGHTMARE);
		fl_ninja		= GameManager.CONFIG.hasOption(Data.OPT_NINJA);
		fl_bombExpert	= GameManager.CONFIG.hasOption(Data.OPT_BOMB_EXPERT);
		fl_bombControl	= false;
		savedScores		= new Array();

		xOffset			= 10;

		fxMan = new FxManager(this);
		statsMan = new StatsManager(this);
		randMan = new RandomManager();
		var old = Std.getTimer();
		randMan.register(Data.RAND_EXTENDS_ID,	Data.RAND_EXTENDS);
		randMan.register(
			Data.RAND_ITEMS_ID,
			Data.getRandFromFamilies(Data.SPECIAL_ITEM_FAMILIES, GameManager.CONFIG.specialItemFamilies)
		);
		randMan.register(
			Data.RAND_SCORES_ID,
			Data.getRandFromFamilies(Data.SCORE_ITEM_FAMILIES, GameManager.CONFIG.scoreItemFamilies)
		);

		speedFactor = 1.0; // facteur de vitesse des bads
		diffFactor	= 1.0;

		endModeTimer = 0;

		comboList = new Array();

		killList = new Array();
		unregList = new Array();
		lists = new Array();
		for(var i=0;i<200;i++) {
			lists[i] = new Array();
		}

		globalActives	= new Array();
		endLevelStack	= new Array();
		portalMcList	= new Array();
		extraHoles		= new Array();
		dfactor			= 0;

		shake(null,null);
		wind(null,null);
		aquaTimer = 0;

		bulletTimer = 0;

		fl_flipX	= false;
		fl_flipY	= false;
		fl_clear	= false;
		fl_gameOver	= false;
		huTimer		= 0;
		huState		= 0;
		tipId		= 0;

		_name		= "$abstractGameMode";

		specialPicks	= new Array();
		scorePicks		= new Array();

		currentDim	= 0;
		dimensions	= new Array();
		latePlayers	= new Array();
		mapIcons	= new Array();
		mapEvents	= new Array();
		mapTravels	= new Array();

		gameChrono	= new Chrono();

		clearDynamicVars();


		worldKeys = new Array();
		for (var i=5000;i<5100;i++) {
			if ( GameManager.CONFIG.hasFamily(i) ) {
				giveKey(i-5000);
			}
		}

	}


	/*------------------------------------------------------------------------
	INITIALISATION DE LA VARIABLE WORLD
	------------------------------------------------------------------------*/
	function initWorld() {
		// do nothing
	}

	/*------------------------------------------------------------------------
	INITIALISE LE JEU SUR LE PREMIER LEVEL
	------------------------------------------------------------------------*/
	function initGame() {
		initWorld();
	}


	/*------------------------------------------------------------------------
	INITIALISE L'INTERFACE DE JEU (non appelé dans la classe gamemode)
	------------------------------------------------------------------------*/
	function initInterface() {
		gi.destroy();
		gi = new gui.GameInterface(this);
	}


	/*------------------------------------------------------------------------
	INITIALISE LE LEVEL
	------------------------------------------------------------------------*/
	function initLevel() {
		if ( !world.isVisited() ) {
			resetHurry();
		}
		badCount		= 0;
		forcedDarkness	= null;
		fl_clear		= false;
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			l[i].onStartLevel();
			if ( l[i].y<0 ) {
				fxMan.attachEnter( l[i].x, 0);//l[i].pid );
			}
		}

	}


	/*------------------------------------------------------------------------
	INITIALISE UN JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(p:entity.Player) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	DÉCLENCHE UN TREMBLEMENT DE TERRE
	------------------------------------------------------------------------*/
	function shake(duration, power) {
		if ( duration==null ) {
			shakeTimer = 0;
			shakeTimer = 0;
		}
		else {
			if ( duration<shakeTimer || power<shakePower ) {
				return;
			}

			shakeTotal = duration;
			shakeTimer = duration;
			shakePower = power;

		}
	}


	/*------------------------------------------------------------------------
	DÉCLENCHE UN SOUFFLE DE VENT
	------------------------------------------------------------------------*/
	function wind(speed,duration) {
		if ( speed==null ) {
			fl_wind = false;
		}
		else {
			fl_wind = true;
			windSpeed = speed;
			windTimer = duration;
		}
	}


	/*------------------------------------------------------------------------
	INVERSION HORIZONTALE
	------------------------------------------------------------------------*/
	function flipX(fl:bool) {
		fl_flipX = fl;
		if (fl) {
			mc._xscale = -100;
			mc._x = Data.GAME_WIDTH+xOffset;
		}
		else {
			mc._xscale = 100;
			mc._x = xOffset;
		}
	}


	/*------------------------------------------------------------------------
	INVERSION VERTICALE
	------------------------------------------------------------------------*/
	function flipY(fl:bool) {
		fl_flipY = fl;
		if (fl) {
			mc._yscale = -100;
			mc._y = Data.GAME_HEIGHT+yOffset+20;
		}
		else {
			mc._yscale = 100;
			mc._y = yOffset;
		}
	}


	/*------------------------------------------------------------------------
	REMET LE HURRY UP À ZÉRO
	------------------------------------------------------------------------*/
	function resetHurry() {
		huTimer = 0;
		huState = 0;

		// Calcul variateur de difficulté
		var max = 0;
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			max = ( pl[i].lives>max ) ? pl[i].lives : max;
		}
		if ( max<4 ) {
			diffFactor = 1.0;
		}
		else {
			diffFactor = 1.0 + 0.05*(max-3)
		}
		if ( fl_nightmare ) {
			diffFactor *= 1.4;
		}


		destroyList(Data.HU_BAD);

		var l = getBadList();
		for (var i=0;i<l.length;i++) {
			l[i].calmDown();
		}

		// Boss
		var b = getOne(Data.BOSS);
		if ( b!=null ) {
			downcast(b).onPlayerDeath();
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LEVEL EST TERMINÉ
	------------------------------------------------------------------------*/
	function checkLevelClear():bool {
		if ( fl_clear ) {
			return true;
		}

		// Bads
		if ( countList(Data.BAD_CLEAR)>0 ) {
			return false;
		}

		// Boss
		if ( world.fl_mainWorld ) {
			if ( world.currentId==Data.BAT_LEVEL || world.currentId==Data.TUBERCULOZ_LEVEL ) {
				return false;
			}
		}

		onLevelClear();
		return true;
	}


	/*------------------------------------------------------------------------
	CONTROLES DE BASE
	------------------------------------------------------------------------*/
	function getControls() {
		super.getControls();

		// Pause
		if ( keyLock!=null && !Key.isDown(keyLock) ) {
			keyLock = null;
		}
		if (Key.isDown(80) && keyLock!=80) {
			if (fl_lock) {
				onUnpause();
			}
			else {
				onPause();
			}
			keyLock = 80;
		}


		// Carte
		if (fl_map && Key.isDown(67) && keyLock!=67) {
			if (fl_lock) {
				onUnpause();
			}
			else {
				onMap();
			}
			keyLock = 67;
		}


		// Musique
		if (!fl_lock && fl_music && Key.isDown(77) && keyLock!=77) {
			fl_mute = !fl_mute;
			if (fl_mute) {
				setMusicVolume(0);
			}
			else {
				setMusicVolume(1);
			}
			keyLock = 77;
		}


		// Suicide
		if ( Key.isDown(Key.SHIFT) && Key.isDown(Key.CONTROL) && Key.isDown(75) ) {
			if ( !fl_switch && !fl_lock && countList(Data.PLAYER)>0 ) {
				destroyList(Data.PLAYER);
				onGameOver();
			}
		}


		// Pause / quitter
		if (!fl_switch && Key.isDown(Key.ESCAPE) && !fl_gameOver && keyLock!=Key.ESCAPE ) {
			if ( manager.fl_local && !fl_lock ) {
				endMode();
			}
			else {
				if ( manager.fl_debug ) {
					if ( !fl_lock ) {
						destroyList(Data.PLAYER);
						onGameOver();
					}
				}
				else {
					if (fl_lock) {
						onUnpause();
					}
					else {
						onPause();
					}
				}
			}
			keyLock = Key.ESCAPE;
		}

		// Déguisements
		if ( fl_disguise && Key.isDown(68) && keyLock!=68 ) {
			var p = getPlayerList()[0];
			var old = p.head;
			p.head++
			if ( p.head==Data.HEAD_AFRO && !GameManager.CONFIG.hasFamily(109) ) p.head++; // touffe
			if ( p.head==Data.HEAD_CERBERE && !GameManager.CONFIG.hasFamily(110) ) p.head++; // cerbère
			if ( p.head==Data.HEAD_PIOU && !GameManager.CONFIG.hasFamily(111) ) p.head++; // piou
			if ( p.head==Data.HEAD_MARIO && !GameManager.CONFIG.hasFamily(112) ) p.head++; // mario
			if ( p.head==Data.HEAD_TUB && !GameManager.CONFIG.hasFamily(113) ) p.head++; // cape
			if ( p.head>6 ) {
				p.head = p.defaultHead;
			}
			if ( old!=p.head ) {
				p.replayAnim();
			}
			keyLock = 68;
		}

		// FPS
		if ( Key.isDown(70) ) {
			Log.print( Math.round(Timer.fps())+" FPS" );
			Log.print("Performances: "+Math.min(100,Math.round(100*Timer.fps()/30))+"%");
		}

		// Build time
		if ( Key.isDown(66) ) {
			Log.print("Dernière mise à jour:");
			Log.print( __TIME__ );
			Log.print("Version de Flash: "+manager.fVersion);
		}
	}


	/*------------------------------------------------------------------------
	CONTROLES DE DEBUG
	------------------------------------------------------------------------*/
	function getDebugControls() {
		super.getDebugControls();

		if (Key.isDown(Key.SHIFT)) {
			Timer.tmod = 0.3;
		}

		if (Key.isDown(Key.HOME)) {
			Timer.tmod = 1.0;
		}

	}


	/*------------------------------------------------------------------------
	AFFICHE DES INFOS DE DEBUG
	------------------------------------------------------------------------*/
	function printDebugInfos() {
//		printBetaInfos();return;
		Log.print("build:"+__TIME__);
		Log.print("lang="+Lang.lang+" debug="+Lang.fl_debug);
		Log.print("debug="+manager.fl_debug+" local="+manager.fl_local);
		Log.print("cookie="+manager.fl_cookie);
		Log.print("--- DATA ---");
		Log.print(GameManager.CONFIG.toString());
		Log.print("fl8 = "+manager.fl_flash8);
		Log.print("ent = "+countList(Data.ENTITY));
		Log.print("bad = "+countList(Data.BAD));

		var k = new Array();
		for (var i=0;i<worldKeys.length;i++) {
			if ( worldKeys[i] ) {
				k.push(i);
			}
		}
		Log.print("keys= "+k.join(", "));
		/***
		Log.print("details = "+GameManager.CONFIG.fl_detail);
		Log.print("--- PARAMS ---");
		Log.print(GameManager.CONFIG.families.join("\n~ "));
		Log.print("snd="+GameManager.CONFIG.soundVolume+" mus="+GameManager.CONFIG.musicVolume);
		if ( manager.fl_cookie ) {
			Log.print("--- COOKIE ---");
			var d = new Date();
			d.setTime( manager.cookie.data.lastModified );
			Log.print("ver = "+Cookie.VERSION);
			Log.print("date = "+d.getDate()+"/"+(d.getMonth()+1)+"/"+d.getFullYear() );
			Log.print("time = "+d.getHours()+":"+d.getMinutes()+":"+d.getSeconds() );
		}
		/***
		Log.print("--- SCRIPT ---");
		Log.print("fl_clear="+fl_clear);
		var node = world.scriptEngine.script.firstChild;
		while ( node!=null ) {
			if ( node.nodeName!=null ) {
				Log.print(node.nodeName);
			}
			node = node.nextSibling;
		}
		Log.print("--- HIST ---");
		Log.print(world.scriptEngine.history.join("\n"));
		/***/
	}


	/*------------------------------------------------------------------------
	AFFICHE DES INFOS DE BETA TEST
	------------------------------------------------------------------------*/
	function printBetaInfos() {
//		Log.print(manager.history.join("\n"));
//		return;
		Log.print("appuyez sur 'C' pour\ncopier ce texte dans le\npresse-papier");
		Log.print("--- VERSION ---");
		Log.print("beta 6.1+");
		Log.print("build:"+__TIME__);
		Log.print("f:"+GameManager.CONFIG.families.join("."));
		Log.print("--- DATA ---");
		Log.print("lvl= "+world.currentId);
		Log.print("bads= "+countList(Data.BAD));
		Log.print("bads_c= "+countList(Data.BAD_CLEAR));
		Log.print("clear= "+fl_clear);
		Log.print("cycle= "+Math.round(world.scriptEngine.cycle));
		Log.print("compile= "+world.scriptEngine.fl_compile);
		Log.print("--- SCRIPT ---");
		var node = world.scriptEngine.script.firstChild;
		while ( node!=null ) {
			if ( node.nodeName!=null ) {
				Log.print(node.nodeName);
			}
			node = node.nextSibling;
		}
		Log.print("--- HIST ---");
		Log.print("\n"+world.scriptEngine.history.join("\n*"));
		Log.print("------");
	}


	/*------------------------------------------------------------------------
	ITEMS PAR NIVEAU (DÉPENDANT DU MODE)
	------------------------------------------------------------------------*/
	function addLevelItems() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	DÉMARRE LE LEVEL
	------------------------------------------------------------------------*/
	function startLevel() {
		var n=0;
		n = world.scriptEngine.insertBads();
		if ( n==0 ) {
			fxMan.attachExit();
			fl_clear = true;
		}

		updateDarkness();

		if ( !world.isVisited() ) {
			addLevelItems();
		}

		statsMan.reset();
//		world.scriptEngine.compile();
		world.scriptEngine.onPlayerBirth();
		world.unlock();

		fl_badsCallback = false;

		if ( isBossLevel(world.currentId) ) {
			fxMan.attachWarning();
		}
	}


	/*------------------------------------------------------------------------
	PASSE AU NIVEAU SUIVANT
	------------------------------------------------------------------------*/
	function nextLevel() {
		fakeLevelId++;
		goto(world.currentId+1);
	}


	/*------------------------------------------------------------------------
	PASSAGE FORCÉ À UN NIVEAU
	------------------------------------------------------------------------*/
	function forcedGoto(id) {
		fakeLevelId += id-world.currentId;
		world.fl_hideBorders	= false;
		world.fl_hideTiles		= false;
		goto(id);

		var lp = getPlayerList();
		for (var i=0;i<lp.length;i++) {
			lp[i].moveTo(
				Entity.x_ctr(world.current.$playerX),
				Entity.y_ctr(world.current.$playerY-1)
			);
			lp[i].shield(Data.SHIELD_DURATION*1.3);
			lp[i].hide();
		}
	}


	/*------------------------------------------------------------------------
	VIDE LE NIVEAU EN COURS
	------------------------------------------------------------------------*/
	function clearLevel() {
		killPop();
		killPointer();
		killItemName();

		destroyList(Data.BAD);
		destroyList(Data.ITEM);
		destroyList(Data.BOMB);
		destroyList(Data.SUPA);
		destroyList(Data.SHOOT);
		destroyList(Data.FX);
		destroyList(Data.BOSS);

		clearDynamicVars();
	}


	/*------------------------------------------------------------------------
	CHANGE DE NIVEAU
	------------------------------------------------------------------------*/
	function goto(id:int) {
		if (fl_lock || fl_gameOver) {
			return;
		}



		if ( id>=world.levels.length ) {
			world.onEndOfSet();
			return;
		}

		var l : Array<Entity>;
		var lp : Array<entity.Player>;

		clearExtraHoles();
		world.lock();
		killPortals();
		clearLevel();

		lock();
		fl_clear = false;
		world.goto(id);

		l = getList(Data.ENTITY);
		for (var i=0;i<l.length;i++) {
			l[i].world = world;
		}

		// Le 1er player arrivé en bas débarque en 1er au level suivant
		lp = getPlayerList();
		var best : entity.Player = null;
		for (var i=0;i<lp.length;i++) {
			if ( best==null || lp[i].y > best.y ) {
				best = lp[i];
			}
		}
		for (var i=0;i<lp.length;i++) {
			lp[i].moveTo( best.x, -600 );
			lp[i].hide();
			lp[i].onNextLevel();
		}
		best.moveTo(best.x,-200);

		fxMan.onNextLevel();

		soundMan.playSound("sound_level_clear", Data.CHAN_INTERF);
	}


	function lock() {
		super.lock();
		gameChrono.stop();
	}

	function unlock() {
		super.unlock();
		gameChrono.start();
	}


	/*------------------------------------------------------------------------
	COMPTEUR DE COMBO POUR UN ID UNIQUE
	------------------------------------------------------------------------*/
	function countCombo(id) {
		if ( comboList[id]==null ) {
			comboList[id] = 0;
		}
		return ++comboList[id];
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE POP D'ITEM EST ENCORE AUTORISÉ
	------------------------------------------------------------------------*/
	function canAddItem() {
		return !fl_clear || world.current.$badList.length==0;
	}


	/*------------------------------------------------------------------------
	LANCE UN EFFET BULLET TIME
	------------------------------------------------------------------------*/
	function bulletTime(d) {
		if ( !fl_bullet ) {
			return;
		}
		bulletTimer = d;
	}


	/*------------------------------------------------------------------------
	MISE À JOUR DES VARIABLES DE FRICTIONS AU SOL
	------------------------------------------------------------------------*/
	function updateGroundFrictions() {
		gFriction = Math.pow(Data.FRICTION_GROUND, Timer.tmod) ; // x au sol
		sFriction = Math.pow(Data.FRICTION_SLIDE, Timer.tmod) ; // x sur sol glissant
	}


	/*------------------------------------------------------------------------
	COMPTAGE D'ITEMS
	------------------------------------------------------------------------*/
	function pickUpSpecial(id) {
		if ( specialPicks[id]==null ) {
			specialPicks[id]=0;
		}
		return ++specialPicks[id];
	}

	function pickUpScore(id,subId) {
		if ( scorePicks[id]==null ) {
			scorePicks[id]=0;
		}
		return ++scorePicks[id];
	}

	function getPicks() {
		var s = "";
		for (var i=0;i<specialPicks.length;i++) {
			if ( specialPicks[i]!=null ) {
				s+=i+"="+specialPicks[i]+"|";
			}
		}
		for (var i=0;i<scorePicks.length;i++) {
			if ( scorePicks[i]!=null ) {
				s+=(i+1000)+"="+scorePicks[i]+"|";
			}
		}
		if ( s.length>0 ) {
			s = s.substr(0,s.length-1);
		}

		return s;
	}


	function getPicks2() {
		var s : Array<int> = new Array();
		for (var i=0;i<specialPicks.length;i++) {
			if ( specialPicks[i]!=null ) {
				s[i] = specialPicks[i];
			}
		}
		for (var i=0;i<scorePicks.length;i++) {
			if ( scorePicks[i]!=null ) {
				s[i+1000] = scorePicks[i];
			}
		}


		return s;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE LEVEL COMPORTE UN BOSS
	------------------------------------------------------------------------*/
	function isBossLevel(id) {
		return false;
	}


	/*------------------------------------------------------------------------
	FLIP HORIZONTAL D'UN X, SI NÉCESSAIRE
	------------------------------------------------------------------------*/
	function flipCoordReal(x) {
		if ( fl_mirror ) {
			return Data.GAME_WIDTH-x-1;
		}
		else {
			return x;
		}
	}

	function flipCoordCase(cx) {
		if ( fl_mirror ) {
			return Data.LEVEL_WIDTH-cx-1;
		}
		else {
			return cx;
		}
	}


	/*------------------------------------------------------------------------
	AJOUTE UN ÉVÈNEMENT À LA CARTE
	------------------------------------------------------------------------*/
	function registerMapEvent( eid:int, misc ) {
		var lid = dimensions[0].currentId;

		if ( !world.fl_mainWorld ) {
			return;
		}

		// Filtre infos inutiles
		for (var i=0;i<mapEvents.length;i++) {
			var e = mapEvents[i];

			// aller-retour au meme level
			if ( e.lid==lid && e.eid==Data.EVENT_EXIT_RIGHT && eid==Data.EVENT_BACK_RIGHT ) {
				return;
			}
			if ( e.lid==lid && e.eid==Data.EVENT_EXIT_LEFT && eid==Data.EVENT_BACK_LEFT ) {
				return;
			}

			// sorti plusieurs fois au meme level
			if ( e.lid==lid && e.eid==Data.EVENT_EXIT_RIGHT && eid==Data.EVENT_EXIT_RIGHT ) {
				return;
			}
			if ( e.lid==lid && e.eid==Data.EVENT_EXIT_LEFT && eid==Data.EVENT_EXIT_LEFT ) {
				return;
			}
		}


		var e = {
			lid		: lid,
			eid		: eid,
			misc	: misc,
		};
		if ( eid==Data.EVENT_EXIT_LEFT || eid==Data.EVENT_EXIT_RIGHT || eid==Data.EVENT_BACK_LEFT || eid==Data.EVENT_BACK_RIGHT || eid==Data.EVENT_TIME ) {
			mapTravels.push(e);
		}
		else {
			mapEvents.push(e);
		}

	}


	/*------------------------------------------------------------------------
	RENVOIE LE Y SUR LA MAP POUR UN ID LEVEL DONNÉ
	------------------------------------------------------------------------*/
	function getMapY(lid) {
		return 84 + Math.min(350, lid*3.5);
	}



	/*------------------------------------------------------------------------
	DÉFINI UNE VARIABLE DYNAMIQUE
	------------------------------------------------------------------------*/
	function setDynamicVar(name,value) {
		dvars.set(name.toLowerCase(),value);
	}

	/*------------------------------------------------------------------------
	LIT UNE VARIABLE DYNAMIQUE
	------------------------------------------------------------------------*/
	function getDynamicVar(name) {
		return dvars.get( name.substring(1).toLowerCase() ); // le $ est retiré en interne
	}

	function getDynamicInt(name):int {
		return Std.parseInt(getDynamicVar(name),10);
	}


	/*------------------------------------------------------------------------
	EFFACE LES VARIABLES DYNAMIQUES
	------------------------------------------------------------------------*/
	function clearDynamicVars() {
		dvars = new Hash();
	}


	/*------------------------------------------------------------------------
	ENVOI DU RÉSULTAT DE LA PARTIE
	------------------------------------------------------------------------*/
	function saveScore() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	MÉMORISE LE SCORE D'UN JOUEUR
	------------------------------------------------------------------------*/
	function registerScore(pid,score) {
		if ( savedScores[pid]==null || savedScores[pid]<=0 ) {
			savedScores[pid] = score;
		}
	}


	/*------------------------------------------------------------------------
	DÉFINI UN FILTRE DE COULEUR (HEXADÉCIMAL)
	------------------------------------------------------------------------*/
	function setColorHex( a:int, col:int ) {
		var coo = {
			r:col>>16,
			g:(col>>8)&0xFF,
			b:col&0xFF
		};
		var ratio  = a/100;
		var ct = {
			ra:int(100-a),
			ga:int(100-a),
			ba:int(100-a),
			aa:100,
			rb:int(ratio*coo.r),
			gb:int(ratio*coo.g),
			bb:int(ratio*coo.b),
			ab:0
		};
		color = new Color(root);
		color.setTransform( ct );
		colorHex = col;
	}

	/*------------------------------------------------------------------------
	ANNULE UN FILTRE DE COULEUR
	------------------------------------------------------------------------*/
	function resetCol() {
		if ( color!=null ) {
			colorHex = null;
			color.reset();
			color = null;
		}
	}


	/*------------------------------------------------------------------------
	GESTION DES WORLD KEYS
	------------------------------------------------------------------------*/
	function giveKey(id:int) {
		worldKeys[id] = true;
	}

	function hasKey(id:int) {
		return worldKeys[id]==true || Std.isNaN(id);
	}



	// *** DIMENSIONS

	/*------------------------------------------------------------------------
	CHANGEMENT DE DIMENSION
	------------------------------------------------------------------------*/
	function switchDimensionById(id:int,lid:int,pid:int) {
//		if ( currentDim==id ) {
//			return;
//		}

		if ( !fl_clear ) {
			return;
		}

		resetHurry();

		latePlayers = new Array();
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			p.specialMan.clearTemp();
			p.specialMan.clearRec();
			p._xscale = p.scaleFactor*100;
			p._yscale = p._xscale;
			p.lockTimer = 0;
			p.fl_lockControls = false;
			p.fl_gravity = true;
			p.fl_friction = true;
			if ( !p.fl_kill ) {
				p.fl_hitWall = true;
				p.fl_hitGround = true;
			}
			p.changeWeapon(Data.WEAPON_B_CLASSIC);
			if ( world.getCase( {x:p.cx,y:p.cy} )!=Data.FIELD_PORTAL ) {
				latePlayers.push(p);
			}
			p.hide();
		}

		holeUpdate();


		clearExtraHoles();
		clearLevel();
		killPortals();
		fxMan.clear();
		cleanKills();
		currentDim = id;
		var ss = world.getSnapShot();
		world.suspend();
		world = dimensions[currentDim];
		world.darknessFactor = dfactor;
		lock();
		fl_clear = false;
		if ( pid<0 ) {
			world.fl_fadeNextTransition = true;
		}
		world.restoreFrom(ss,lid);
		updateEntitiesWorld();
		if ( !world.fl_mainWorld ) {
			fakeLevelId = 0;
		}
		else {
			fakeLevelId = null;
		}

		portalId = pid;
		nextLink = null;
	}


	/*------------------------------------------------------------------------
	INITIALISE ET AJOUTE UNE DIMENSION
	------------------------------------------------------------------------*/
	function addWorld(name) {
		var dim;
		dim = new levels.GameMechanics(manager,name);
		dim.fl_mirror = fl_mirror;
		dim.setDepthMan(depthMan);
		dim.setGame(this);
		if ( dimensions.length>0 ) {
			dim.suspend();
			dim.fl_mainWorld = false;
		}
		else {
			world = dim;
		}
		dimensions.push(dim);
		return dim;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE PT D'ENTRÉE APRES UN SWITCH DIMENSION
	------------------------------------------------------------------------*/
	function getPortalEntrance(pid:int) {
		var px = world.current.$playerX;
		var py = world.current.$playerY;
		var fl_unstable = false;

		if ( pid>=0 && world.portalList[pid]!=null ) {
			px = world.portalList[pid].cx;
			py = world.portalList[pid].cy;

			// Vertical
			if ( world.getCase({x:px,y:py+1})==Data.FIELD_PORTAL ) {
				while ( world.getCase({x:px,y:py+1})==Data.FIELD_PORTAL ) {
					py++;
				}
				// gauche
				if ( world.getCase({x:px-1,y:py})<=0 ) {
					px-=1;
				}
				else {
					if ( world.getCase({x:px+1,y:py})<=0 ) {
						px+=1;
					}
				}
			}
			else {
				// Horizontal
				if ( world.getCase({x:px+1,y:py})==Data.FIELD_PORTAL ) {
					py+=2;
				}
				fl_unstable = true;
			}
		}
		else {
			fl_unstable = true;
			// todo: vortex d'arrivée d'un portal
		}

		return {x:px, y:py, fl_unstable:fl_unstable};
	}


	/*------------------------------------------------------------------------
	UTILISE UN PORTAL (renvoie false si pas de correspondance)
	------------------------------------------------------------------------*/
	function usePortal(pid:int, e:entity.Physics) {
		if ( nextLink!=null ) {
			return false;
		}
		var link = Data.getLink(currentDim, world.currentId, pid);
		if ( link==null ) {
			return false;
		}

		var name = Lang.getLevelName(link.to_did, link.to_lid);

		if ( flipCoordReal(e.x)>=Data.GAME_WIDTH*0.5 ) {
			fl_rightPortal = true;
			registerMapEvent( Data.EVENT_EXIT_RIGHT, (world.currentId+1)+". "+name);
		}
		else {
			fl_rightPortal = false;
			registerMapEvent( Data.EVENT_EXIT_LEFT, (world.currentId+1)+". "+name);
		}

		if ( e==null ) {
			var pl = getPlayerList();
			for (var i=0;i<pl.length;i++) {
				var p = pl[i];
				p.dx = (portalMcList[pid].x-p.x)*0.018;
				p.dy = (portalMcList[pid].y-p.y)*0.018;
				p.fl_hitWall = false;
				p.fl_hitGround = false;
				p.fl_gravity = false;
				p.fl_friction = false;
				p.specialMan.clearTemp();
				p.unshield();
				p.lockControls(Data.SECOND*9999);
				p.playAnim(Data.ANIM_PLAYER_DIE);
			}
			nextLink = link;
		}
		else {
			switchDimensionById( link.to_did, link.to_lid, link.to_pid );
		}
		return true;
	}


	/*------------------------------------------------------------------------
	OUVRE UN PORTAIL FLOTTANT
	------------------------------------------------------------------------*/
	function openPortal(cx:int,cy:int,pid:int) {
		if ( portalMcList[pid]!=null ) {
			return false;
		}
		else {
			world.scriptEngine.insertPortal(cx,cy,pid);
			var x = Entity.x_ctr(flipCoordCase(cx));
			var y = Entity.y_ctr(cy)-Data.CASE_HEIGHT*0.5;
			var p = depthMan.attach("hammer_portal",Data.DP_SPRITE_BACK_LAYER);
			p._x = x;
			p._y = y;
			fxMan.attachExplosion(x,y, 40);
			fxMan.inGameParticles(Data.PARTICLE_PORTAL, x,y, 5);
			fxMan.attachShine(x,y);
			portalMcList[pid] = {x:x, y:y, mc:p, cpt:0};
			return true;
		}
	}



	// *** LISTES


	/*-----------------------------------------------------------------------
	RENVOIE UN ID DE LISTE D'ENTITÉ CALCULÉ SELON LE TYPE
	------------------------------------------------------------------------*/
	function getListId(type:int):int {
		var i = 0;
		var bin = 1<<i;
		while (type!=bin) {
			i++;
			bin = 1<<i;
		}
		return i;
	}


	/*------------------------------------------------------------------------
	RENVOIE LA LISTE D'ENTITÉS DU TYPE DEMANDÉ
	------------------------------------------------------------------------*/
	function getList(type:int) : Array<Entity> {
		return lists[getListId(type)];
	}

	function getListAt(type:int,cx,cy) : Array<Entity> {
		var l = getList(type);
		var res = new Array();
		for (var i=0;i<l.length;i++) {
			if ( l[i].cx==cx && l[i].cy==cy ) {
				res.push(l[i]);
			}
		}
		return res;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE NOMBRE D'ENTITÉS DU TYPE DEMANDÉ
	------------------------------------------------------------------------*/
	function countList(type:int) : int {
		return lists[getListId(type)].length;
	}



	/*------------------------------------------------------------------------
	RENVOIE DES LISTES SPÉCIFIQUES TYPÉES
	------------------------------------------------------------------------*/
	function getBadList() : Array<entity.Bad> {
		return Std.cast(getList(Data.BAD));
	}
	function getBadClearList() : Array<entity.Bad> {
		return Std.cast(getList(Data.BAD_CLEAR));
	}
	function getPlayerList() : Array<entity.Player> {
		return Std.cast(getList(Data.PLAYER));
	}


	/*------------------------------------------------------------------------
	RENVOIE UNE DUPLICATION D'UNE LISTE D'ENTITÉS
	------------------------------------------------------------------------*/
	function getListCopy(type:int) : Array<Entity> {
		var l = getList(type);
		var out = new Array();
		for (var i=0;i<l.length;i++) {
			out[i] = l[i];
		}

		return out;
	}


	/*------------------------------------------------------------------------
	RENVOIE LES ENTITÉS À PROXIMITÉ D'UN POINT DONNÉ
	------------------------------------------------------------------------*/
	function getClose(type:int, x:float,y:float, radius:float, fl_onGround:bool) : Array<Entity> {
		var l = getList(type);
		var out = new Array();
		var sqrRad = Math.pow(radius,2);

		for (var i=0;i<l.length;i++) {
			var e = l[i];
			var square = Math.pow(e.x-x,2) + Math.pow(e.y-y,2);
			if ( square <= sqrRad ) {
				if ( Math.sqrt(square) <= radius ) {
					if ( !fl_onGround || ( fl_onGround && e.y<=y+Data.CASE_HEIGHT) ) {
						out.push(e);
					}
				}
			}
		}

		return out;
	}



	/*------------------------------------------------------------------------
	RETOURNE UNE ENTITÉ AU HASARD D'UN TYPE DONNÉ, OU NULL
	------------------------------------------------------------------------*/
	function getOne(type:int) : Entity {
		var l = getList(type);
		return l[Std.random(l.length)];
	}


	/*------------------------------------------------------------------------
	RETOURNE UNE ENTITÉ AU HASARD D'UN TYPE DONNÉ, OU NULL
	------------------------------------------------------------------------*/
	function getAnotherOne(type:int,e:Entity) : Entity {
		var l = getList(type);
		if ( l.length<=1 ) {
			return null;
		}

		var i : int;
		do {
			i=Std.random(l.length);
		}
		while (l[i]==e);

		return l[i];
	}


	/*------------------------------------------------------------------------
	AJOUTE À UNE LISTE D'UPDATE
	------------------------------------------------------------------------*/
	function addToList( type:int, e:Entity ) {
		lists[getListId(type)].push(e);
	}


	/*------------------------------------------------------------------------
	RETIRE D'UNE LISTE D'UPDATE
	------------------------------------------------------------------------*/
	function removeFromList( type:int, e:Entity ) {
		lists[getListId(type)].remove(e);
	}


	/*------------------------------------------------------------------------
	DÉTRUIT TOUS LES MCS D'UNE LISTE
	------------------------------------------------------------------------*/
	function destroyList( type:int ) {
		var list = getList(type);
		for (var i=0;i<list.length;i++) {
			list[i].destroy();
		}
	}


	/*------------------------------------------------------------------------
	DÉTRUIT N ENTITÉ AU HASARD D'UNE LISTE
	------------------------------------------------------------------------*/
	function destroySome( type:int, n:int) {
		var l = getListCopy(type);
		while (l.length>0 && n>0) {
			var i = Std.random(l.length);
			l[i].destroy();
			l.splice(i,1);
			n--;
		}
	}


	/*------------------------------------------------------------------------
	NETTOIE LES LISTES DE DESTRUCTION
	------------------------------------------------------------------------*/
	function cleanKills() {
		// Dés-enregistrement d'entités détruites dans ce tour
		for (var i=0; i<unregList.length; i++) {
			removeFromList( unregList[i].type, unregList[i].ent );
		}
		unregList = new Array();

		// Suppression d'entités en fin de tour
		for (var i=0; i<killList.length; i++) {
			var e = killList[i];
//			if ( (e.types&Data.BAD_CLEAR) > 0 && !fl_lock) {
//				checkLevelClear();
//			}
			e.removeMovieClip();
		}
		killList = new Array();
	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function exitGame() {
		var codec = new PersistCodec();
		var out = codec.encode( codec.encode(specialPicks)+":"+codec.encode(scorePicks) );
		manager.redirect("endGame.html",out);
	}



	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		resetCol();
		killPortals();
		super.destroy();
	}


	// *** ATTACHEMENTS

	/*------------------------------------------------------------------------
	ATTACHE UN JOUEUR
	------------------------------------------------------------------------*/
	function insertPlayer(cx,cy) {
		// Calcul du PID
		var pid = 0;
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			if ( !pl[i].fl_destroy ) {
				pid++;
			}
		}

		var p = entity.Player.attach( this, Entity.x_ctr(cx) ,Entity.y_ctr(cy) );
		p.hide();
		p.pid = pid;

		return p;
	}

	/*------------------------------------------------------------------------
	ATTACH: ENNEMI
	------------------------------------------------------------------------*/
	function attachBad(id:int,x:float,y:float):entity.Bad {
		var bad=null;
		switch (id) {
			case Data.BAD_POMME			: bad = entity.bad.walker.Pomme.attach(this,x,y) ; break;
			case Data.BAD_CERISE		: bad = entity.bad.walker.Cerise.attach(this,x,y) ; break;
			case Data.BAD_BANANE		: bad = entity.bad.walker.Banane.attach(this,x,y) ; break;
			case Data.BAD_ANANAS		: bad = entity.bad.walker.Ananas.attach(this,x,y) ; break;
			case Data.BAD_ABRICOT		: bad = entity.bad.walker.Abricot.attach(this,x,y,true) ; break;
			case Data.BAD_ABRICOT2		: bad = entity.bad.walker.Abricot.attach(this,x,y,false) ; break;
			case Data.BAD_POIRE			: bad = entity.bad.walker.Poire.attach(this,x,y) ; break;
			case Data.BAD_BOMBE			: bad = entity.bad.walker.Bombe.attach(this,x,y) ; break;
			case Data.BAD_ORANGE		: bad = entity.bad.walker.Orange.attach(this,x,y) ; break;
			case Data.BAD_FRAISE		: bad = entity.bad.walker.Fraise.attach(this,x,y) ; break;
			case Data.BAD_CITRON		: bad = entity.bad.walker.Citron.attach(this,x,y) ; break;
			case Data.BAD_BALEINE		: bad = entity.bad.flyer.Baleine.attach(this,x,y) ; break;
			case Data.BAD_SPEAR			: bad = entity.bad.Spear.attach(this,x,y) ; break;
			case Data.BAD_CRAWLER		: bad = entity.bad.ww.Crawler.attach(this,x,y) ; break;
			case Data.BAD_TZONGRE		: bad = entity.bad.flyer.Tzongre.attach(this,x,y) ; break;
			case Data.BAD_SAW			: bad = entity.bad.ww.Saw.attach(this,x,y) ; break;
			case Data.BAD_LITCHI		: bad = entity.bad.walker.Litchi.attach(this,x,y) ; break;
			case Data.BAD_KIWI			: bad = entity.bad.walker.Kiwi.attach(this,x,y) ; break;
			case Data.BAD_LITCHI_WEAK	: bad = entity.bad.walker.LitchiWeak.attach(this,x,y) ; break;
			case Data.BAD_FRAMBOISE		: bad = entity.bad.walker.Framboise.attach(this,x,y) ; break;

			default :
				GameManager.fatal("(attachBad) unknown bad "+id);
			break;
		}

		if ( bad.isType(Data.BAD_CLEAR) ) {
			badCount++;
		}


		return bad;
	}


	/*------------------------------------------------------------------------
	ATTACH: POP UP IN-GAME
	------------------------------------------------------------------------*/
	function attachPop(msg,fl_tuto) {
		killPop();
		popMC = downcast( depthMan.attach("hammer_interf_pop", Data.DP_INTERF) );
		popMC._x = Data.GAME_WIDTH*0.5;

		if ( fl_tuto ) {
			popMC.sub.gotoAndStop("2");
			popMC.sub.header.text = Lang.get(2);
		}
		else {
			popMC.sub.gotoAndStop("1");
		}

		// Trims leading endLines
		while ( msg.charCodeAt(0)==10 || msg.charCodeAt(0)==13 ) {
			msg = msg.substring(1);
		}

		popMC.sub.field.html = true;
		popMC.sub.field.htmlText = Data.replaceTag(msg, "*","<font color=\"#f7e8d5\">","</font>");

		// Vertical centering
		var h = popMC.sub.field.textHeight;
		popMC.sub.field._y = -h*0.5 - 2;
	}


	/*------------------------------------------------------------------------
	ATTACH: POINTEUR DE CIBLAGE
	------------------------------------------------------------------------*/
	function attachPointer(cx,cy, ocx,ocy) {
		killPointer();
		var x = Entity.x_ctr(cx);
		var y = Entity.y_ctr(cy);
		var ox = Entity.x_ctr(ocx);
		var oy = Entity.y_ctr(ocy);
		pointerMC = depthMan.attach("hammer_fx_pointer", Data.DP_INTERF);
		pointerMC._x = x;
		pointerMC._y = y;
		var ang = Math.atan2(oy-y, ox-x) * 180 / Math.PI;
		pointerMC._rotation = ang-90;
	}


	/*------------------------------------------------------------------------
	ATTACH: CERCLE DE DEBUG
	------------------------------------------------------------------------*/
	function attachRadius(x,y,r) {
		killRadius();
		radiusMC = depthMan.attach("debug_radius", Data.DP_INTERF);
		radiusMC._x = x;
		radiusMC._y = y;
		radiusMC._width = r*2;
		radiusMC._height = radiusMC._width;
	}


	/*------------------------------------------------------------------------
	AFFICHE UN NOM D'ITEM SPÉCIAL RAMASSÉ
	------------------------------------------------------------------------*/
	function attachItemName(family:Array<Array<ItemFamilySet>>,id) {
		if ( id==null ) {// || popMC._name!=null ) {
			return;
		}

		// Recherche du nom
		var s	= null;
		var i	= 0;
		while (s==null && i<family.length) {
			var j=0;
			while (s==null && j<family[i].length) {
				if ( family[i][j].id == id ) {
					s = family[i][j].name;
				}
				j++;
			}
			i++;
		}

		if ( s!="" && s!=null ) {
			// Affichage
			killItemName();
			itemNameMC = downcast( depthMan.attach("hammer_interf_item_name", Data.DP_TOP) );
			itemNameMC._x = Data.GAME_WIDTH*0.5 + 20; // icon width
			itemNameMC._y = 15;//Data.GAME_HEIGHT-20; // 15;
			itemNameMC.field.text = s;

			// Item icon
			var icon;
			if ( id<1000 ) {
				icon = Std.attachMC( itemNameMC, "hammer_item_special",manager.uniq++);
				icon.gotoAndStop(""+(id+1));
			}
			else {
				icon = Std.attachMC( itemNameMC, "hammer_item_score",manager.uniq++);
				icon.gotoAndStop(""+(id-1000+1));
			}
			icon._x -= itemNameMC.field.textWidth*0.5 + 20;
			icon._y = 10;
			icon._xscale = 75;
			icon._yscale = icon._xscale;
			downcast(icon).sub.stop();
		}
	}


	/*------------------------------------------------------------------------
	DETACHEMENTS
	------------------------------------------------------------------------*/
	function killPop() {
		popMC.removeMovieClip();
	}

	function killPointer() {
		pointerMC.removeMovieClip();
	}

	function killRadius() {
		radiusMC.removeMovieClip();
	}

	function killItemName() {
		itemNameMC.removeMovieClip();
	}


	function killPortals() {
		for (var i=0;i<portalMcList.length;i++) {
			portalMcList[i].mc.removeMovieClip();
		}
		portalMcList = new Array();
	}


	/*------------------------------------------------------------------------
	ATTACH: ICON SUR LA CARTE
	------------------------------------------------------------------------*/
	function attachMapIcon(eid:int,lid, txt, offset:int, offsetTotal:int) {
		var x = Data.GAME_WIDTH*0.5;
		var y = getMapY(lid);
		if ( offset!=null ) {
			var wid = 8;
			x += offset*wid - 0.5*(offsetTotal-1)*wid;
		}

		if ( eid==Data.EVENT_EXIT_LEFT || eid==Data.EVENT_BACK_LEFT ) {
			x = Data.GAME_WIDTH*0.5 - 5;
		}
		if ( eid==Data.EVENT_EXIT_RIGHT || eid==Data.EVENT_BACK_RIGHT ) {
			x = Data.GAME_WIDTH*0.5 + 5;
		}

		var mc = depthMan.attach("hammer_interf_mapIcon", Data.DP_INTERF);
		mc.gotoAndStop(""+eid);
		mc._x = Math.floor(x);
		mc._y = Math.floor(y);

		if ( txt==null ) {
			txt = "?";
		}
		downcast(mc).field.text = txt;
		mapIcons.push(mc);
	}


	/*------------------------------------------------------------------------
	BOULE DE FEU DE HURRY UP
	------------------------------------------------------------------------*/
	function callEvilOne(baseAnger:int) {
		var lp = getPlayerList();
		for (var i=0;i<lp.length;i++) {
			if ( !lp[i].fl_kill ) {
				var mc = entity.bad.FireBall.attach(this, lp[i]);
				mc.anger = baseAnger-1;
				if ( baseAnger>0 ) {
					mc.fl_summon = false;
					mc.stopBlink();
				}
				mc.angerMore();
			}
		}
	}


	// *** EVENTS

	/*------------------------------------------------------------------------
	EVENT: LEVEL PRÊT À ÊTRE JOUÉ (APRÈS SCROLLING)
	------------------------------------------------------------------------*/
	function onLevelReady() {
//		if ( world.currentId==0 ) {
//			gameChrono.reset();
//		}
		unlock();
		initLevel();
		startLevel();

		updateEntitiesWorld();

		var l = getList(Data.PLAYER);
		for (var i=0;i<l.length;i++) {
			l[i].show();
		}
	}

	function onBadsReady() {
		if ( fl_ninja && getBadClearList().length>1 ) {
			var foe : entity.Bad = downcast( getOne(Data.BAD_CLEAR) );
			foe.fl_ninFoe = true;

			if ( fl_nightmare || !world.fl_mainWorld || world.fl_mainWorld && world.currentId>=20 ) {
				var lid = dimensions[0].currentId;
				friendsLimit = Math.floor( Math.max( 2, Math.floor( (lid-20)/10 ) ) );
			}
			else {
				friendsLimit = 1;
			}
			if ( fl_nightmare ) {
				friendsLimit++;
			}
			friendsLimit = Math.round( Math.min( getBadClearList().length-1, friendsLimit ) );
			while( friendsLimit>0 ) {
				var b : entity.Bad = downcast( getAnotherOne( Data.BAD_CLEAR, foe ) );
				if ( !b.fl_ninFriend ) {
					b.fl_ninFriend = true;
					friendsLimit--;
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LEVEL RESTAURÉ, PRÊT À ÊTRE JOUÉ
	------------------------------------------------------------------------*/
	function onRestore() {
		unlock();


		var pt = getPortalEntrance(portalId); // coordonnées case
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			p.moveToCase( pt.x,pt.y );
			p.show();
			p.unshield();
			if ( pt.fl_unstable ) {
				p.knock(Data.SECOND*0.6);
//				fxMan.attachExplosion( p.x,p.y-Data.CASE_HEIGHT, 45 );
			}
		}

		for (var i=0;i<latePlayers.length;i++) {
			var p = latePlayers[i];
			p.knock(Data.SECOND*1.3);
			p.dx = 0;
		}


		if ( world.fl_mainWorld ) {
			if ( pt.x>=Data.LEVEL_WIDTH*0.5 ) {
				registerMapEvent( Data.EVENT_BACK_RIGHT, null);
			}
			else {
				registerMapEvent( Data.EVENT_BACK_LEFT, null);
			}
		}
	}


	/*------------------------------------------------------------------------
 	MISE À JOUR VARIABLE WORLD DES ENTITÉS
	------------------------------------------------------------------------*/
	function updateEntitiesWorld() {
		var l;
		l = getList(Data.ENTITY);
		for (var i=0;i<l.length;i++) {
			l[i].world = world;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: NIVEAU TERMINÉ
	------------------------------------------------------------------------*/
	function onLevelClear() {
		if ( fl_clear ) {
			return;
		}

		world.scriptEngine.clearEndTriggers();

//		destroyList( Data.SUPA );
//		destroyList( Data.BAD_BOMB );
//		destroyList( Data.SPECIAL_ITEM );

		var l = getList(Data.SPECIAL_ITEM);
		for (var i=0;i<l.length;i++) {
			var it : entity.Item = downcast(l[i]);
			if ( it.id==0 ) {
				it.destroy();
			}
		}

		fl_clear = true;
		fxMan.attachExit();

		// Pile d'appel post-clear
		for (var i=0;i<endLevelStack.length;i++) {
			endLevelStack[i]();
		}
		endLevelStack = new Array();
	}


	/*------------------------------------------------------------------------
	EVENT: HURRY UP!
	------------------------------------------------------------------------*/
	function onHurryUp() {
		huState++;
		huTimer = 0;

		// Énervement de tous les bads
		var lb = getBadList();
		for (var i=0;i<lb.length;i++) {
			lb[i].onHurryUp();
		}

		// Annonce
		var mc = fxMan.attachHurryUp();

		if ( huState==1 ) {
			soundMan.playSound("sound_hurry", Data.CHAN_INTERF);
		}
		if ( huState==2 ) {
			callEvilOne(0);
		}
		return mc;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE PARTIE
	------------------------------------------------------------------------*/
	function onGameOver() {
		fl_gameOver = true;
	}


	/*------------------------------------------------------------------------
	EVENT: MORT D'UN BAD
	------------------------------------------------------------------------*/
	function onKillBad(b:entity.Bad) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		if ( fl_lock ) {
			return;
		}
		fl_pause = true;
		lock();
		world.lock();

		pauseMC.removeMovieClip();
		pauseMC = downcast(  depthMan.attach("hammer_interf_instructions", Data.DP_INTERF)  );
		pauseMC.gotoAndStop("1");
		pauseMC._x = Data.GAME_WIDTH*0.5;
		pauseMC._y = Data.GAME_HEIGHT*0.5;
		pauseMC.click.text	= "";
		pauseMC.title.text	= Lang.get(5);
		pauseMC.move.text	= Lang.get(7);
		pauseMC.attack.text	= Lang.get(8);
		pauseMC.pause.text	= Lang.get(9);
		pauseMC.space.text	= Lang.get(10);
		pauseMC.sector.text	= Lang.get(14)+"«"+Lang.getSectorName(currentDim, world.currentId)+"»";

		if ( !fl_mute ) {
			setMusicVolume(0.5);
		}

		// Tool tip
		var tip	= Lang.get(301 + tipId++);
		if ( tip==null ) {
			tipId = 0;
			tip	= Lang.get(301 + tipId++);
		}

		pauseMC.tip.html = true;
		pauseMC.tip.htmlText = "<b>" + Lang.get(300) +"</b>"+ tip;

	}


	/*------------------------------------------------------------------------
	EVENT: WORLD MAP
	------------------------------------------------------------------------*/
	function onMap() {
		fl_pause = true;
		lock();
		world.lock();
		if ( !fl_mute ) {
			setMusicVolume(0.5);
		}

		mapMC.removeMovieClip();
		mapMC = downcast( depthMan.attach("hammer_map", Data.DP_INTERF) );
		mapMC.field.text = Lang.getSectorName(currentDim, world.currentId);
		mapMC._x = -xOffset;

		var lid = dimensions[0].currentId;
		if ( lid==0 ) {
			mapMC.ptr._y = 70;
			mapMC.pit._visible = false;
		}
		else {
			mapMC.ptr._y = getMapY(lid);
			mapMC.pit.blendMode	= BlendMode.OVERLAY;
			mapMC.pit._alpha	= 75;
			mapMC.pit._yscale	= Math.min(100, 100 * (lid/100) );
		}


		// Traversées de portails
		for (var i=0;i<mapTravels.length;i++) {
			var e = mapTravels[i];
			attachMapIcon( e.eid, e.lid, e.misc, null,null );
		}

		// Icones
		for (var i=0;i<mapEvents.length;i++) {
			var e = mapEvents[i];
			var list = new Array();

			// Sélection sur le level courant
			for (var j=0;j<mapEvents.length;j++) {
				if ( mapEvents[j].lid == e.lid ) {
					list.push(mapEvents[j]);
				}
			}

			for (var j=0;j<list.length;j++) {
				attachMapIcon(
					list[j].eid,
					list[j].lid,
					list[j].misc,
					j,
					list.length
				);
			}
		}

	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE PAUSE
	------------------------------------------------------------------------*/
	function onUnpause() {
		if ( !fl_pause ) {
			return;
		}
		fl_pause = false;
		unlock();
		world.unlock();
		pauseMC.removeMovieClip();
		mapMC.removeMovieClip();
		if ( !fl_mute ) {
			setMusicVolume(1);
		}
		for (var i=0;i<mapIcons.length;i++) {
			mapIcons[i].removeMovieClip();
		}
		mapIcons = new Array();
	}


	/*------------------------------------------------------------------------
	EVENT: RÉSURRECTION
	------------------------------------------------------------------------*/
	function onResurrect() {
		registerMapEvent( Data.EVENT_DEATH, null );
		destroyList(Data.SUPA);
		resetHurry() ;
		updateDarkness();
		world.scriptEngine.onPlayerBirth();
		world.scriptEngine.onPlayerDeath();
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION D'UNE BOMBE (event pour les scripts)
	------------------------------------------------------------------------*/
	function onExplode(x,y,radius) {
		world.scriptEngine.onExplode(x,y,radius);
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET DE LEVELS
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	GÈRE L'OBSCURITÉ
	------------------------------------------------------------------------*/
	function updateDarkness() {


//		if ( forcedDarkness==null ) {
//
//			if ( world.fl_mainWorld && world.currentId<Data.MIN_DARKNESS_LEVEL ) {
//				darknessMC.removeMovieClip();
//				world.darknessFactor = 0;
//				return;
//			}
//			if ( world.fl_mainWorld && world.currentId>101 ) {
//				darknessMC.removeMovieClip();
//				world.darknessFactor = 0;
//				return;
//			}
////			if ( !world.fl_mainWorld ) {
////				darknessMC.removeMovieClip();
////				return;
////			}
//		}

		// Calcul darkness
		if ( forcedDarkness!=null ) {
			targetDark = forcedDarkness;
		}
		else {
			if ( world.fl_mainWorld ) {
				if ( world.currentId<Data.MIN_DARKNESS_LEVEL || world.currentId>101 ) {
					darknessMC.removeMovieClip();
					world.darknessFactor = 0;
					dfactor = 0;
					return;
				}
				else {
					targetDark = world.currentId;
				}
			}
			else {
				targetDark = world.darknessFactor;
			}
		}



		// Attachement
//		dfactor = (forcedDarkness==null) ? world.currentId*1.0 : forcedDarkness*1.0;
		if ( darknessMC._name==null ) {
			darknessMC = Std.cast( depthMan.attach("hammer_fx_darkness",Data.DP_BORDERS) );
			darknessMC._x -= xOffset;
			darknessMC.blendMode = BlendMode.LAYER;
			darknessMC.holes = new Array();
			darknessMC.holes.push( Std.cast(darknessMC).hole1 );
			darknessMC.holes.push( Std.cast(darknessMC).hole2 );
			for (var i=0;i<2;i++) {
				darknessMC.holes[i].blendMode = BlendMode.ERASE;
				darknessMC.holes[i]._y = -500;
			}
		}

		// Dimensions de base
		for (var i=0;i<2;i++) {
			darknessMC.holes[i]._xscale = 100;
			darknessMC.holes[i]._yscale = darknessMC.holes[i]._xscale;
		}

		// Spots de lumière supplémentaires
		detachExtraHoles();
		for (var i=0;i<extraHoles.length;i++) {
			var hole = Std.attachMC(darknessMC, "hammer_fx_darknessHole", manager.uniq++);
			hole._x = extraHoles[i].x;
			hole._y = extraHoles[i].y;
			hole._width = extraHoles[i].d;
			hole._height = extraHoles[i].d;
			hole.blendMode = BlendMode.ERASE;
			darknessMC.holes.push(hole);
			extraHoles[i].mc = hole;
		}

		// Effets des évolutions des joueurs
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			if ( l[i].fl_candle || l[i].specialMan.actives[68] ) { // bougie
				darknessMC.holes[i]._xscale = 150;
				darknessMC.holes[i]._yscale = darknessMC.holes[i]._xscale;
			}
			if ( l[i].fl_torch || l[i].specialMan.actives[26] ) { // ampoule
				if ( forcedDarkness==null ) {
					targetDark*=0.5;
				}
				else {
					targetDark*=0.75; // l'obscurité forcée est plus "opaque"
				}
			}
		}

		holeUpdate();
	}


	/*------------------------------------------------------------------------
	AJOUTE UN SPOT DE LUMIÈRE
	------------------------------------------------------------------------*/
	function addHole(x,y,diameter) {
		extraHoles.push( {x:x, y:y, d:diameter, mc:null} );
	}


	function detachExtraHoles() {
		for(var i=0;i<extraHoles.length;i++) {
			extraHoles[i].mc.removeMovieClip();
		}
		darknessMC.holes.splice(2,9999);
	}


	function clearExtraHoles() {
		detachExtraHoles();
		extraHoles = new Array();
	}


	/*------------------------------------------------------------------------
	MAIN: DARKNESS HALO
	------------------------------------------------------------------------*/
	function holeUpdate() {
		if ( darknessMC._name == null ) {
			return;
		}

		// Placements trous
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			var tx = p.x + Data.CASE_WIDTH*0.5;
			var ty = p.y - Data.CASE_HEIGHT;
			var hole = darknessMC.holes[i];
			if ( p._visible ) {
				hole._visible = true;
				hole._x += ( tx - hole._x )*0.5;
				hole._y += ( ty - hole._y )*0.5;
			}
			else {
				hole._visible = false;
				hole._x = tx;
				hole._y = ty;
			}
		}

		// Tweening luminosité
		dfactor = Math.round(dfactor);
		targetDark = Math.round(targetDark);
		if ( dfactor==null ) {
			dfactor = 0;
		}
		if ( dfactor<targetDark ) {
			dfactor+=2;
			if ( dfactor>targetDark ) {
				dfactor = targetDark;
			}
		}
		if ( dfactor>targetDark ) {
			dfactor-=2;
			if ( dfactor<targetDark ) {
				dfactor = targetDark;
			}
		}

		world.darknessFactor = dfactor;
		darknessMC._alpha = dfactor;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {
		// FPS
		if ( GameManager.CONFIG.fl_detail ) {
			if ( Timer.fps()<=16 ) { // lag manager
				lagCpt+=Timer.tmod;
				if ( lagCpt>=Data.SECOND*30 ) {
					GameManager.CONFIG.setLowDetails();
					GameManager.CONFIG.fl_shaky = false;
				}
			}
			else {
				lagCpt = 0;
			}
		}

		// Chrono
		gameChrono.update();

		// Pause
		if ( fl_pause ) {
			if ( manager.fl_debug ) {
				printDebugInfos();
			}
		}

		// Bullet time
		if ( fl_bullet && bulletTimer>0 ) {
			bulletTimer-=Timer.tmod;
			if ( bulletTimer>0 ) {
				Timer.tmod = 0.3;
			}
		}

		// Item name
		if ( itemNameMC._name!=null ) {
			itemNameMC._alpha -= (105 - itemNameMC._alpha)*0.01;
			if ( itemNameMC._alpha<=5 ) {
				itemNameMC.removeMovieClip();
			}
		}

		// Variables
		updateGroundFrictions();
		fl_ice = ( getDynamicVar("$ICE")!=null );
		fl_aqua = ( getDynamicVar("$AQUA")!=null );
//		if ( fl_aqua ) {
//			if ( GameManager.CONFIG.fl_detail && colorHex!=WATER_COLOR ) {
//				setColorHex(20, WATER_COLOR);
//			}
//		}
//		else {
//			resetCol();
//		}

		// Super
		super.main();


		// Level
		world.update();

		// Interface
		gi.update();

		// Lock
		if (fl_lock) {
			return;
		}

		if( getBadList().length>0 && fl_badsCallback==false) {
			onBadsReady();
			fl_badsCallback = true;
		}

		// Flottement des portails
		for (var i=0;i<portalMcList.length;i++) {
			var p = portalMcList[i];
			if ( p!=null ) {
				p.mc._y = p.y + 2 * Math.sin(p.cpt);
				p.cpt+=Timer.tmod*0.1;
				if ( Std.random(5)==0 ) {
					var a = fxMan.attachFx(
						p.x + Std.random(25)*(Std.random(2)*2-1),
						p.y + Std.random(25)*(Std.random(2)*2-1),
						"hammer_fx_star"
					);
					a.mc._xscale	= Std.random(70)+30;
					a.mc._yscale	= a.mc._xscale;
				}
			}
		}


		duration += Timer.tmod;

		// Timer de fin de mode auto
		if ( endModeTimer>0 ) {
			endModeTimer-=Timer.tmod;
			if ( endModeTimer<=0 ) {
				var pl = getPlayerList();
				for (var i=0;i<pl.length;i++) {
					registerScore(pl[i].pid,pl[i].score);
				}
				onGameOver();
			}
		}

		// FX manager
		fxMan.main();

		// Hurry up!
		huTimer += Timer.tmod;
		if ( Key.isDown(72) && manager.fl_debug ) { // H
			huTimer += Timer.tmod*20;
		}
		if ( huState<Data.HU_STEPS.length && huTimer>=Data.HU_STEPS[huState]/diffFactor ) {
			onHurryUp();
		}
		// RAZ status hurry up si la fireball a été détruite
		if ( huState>=Data.HU_STEPS.length ) {
			if ( countList(Data.HU_BAD)==0 ) {
				callEvilOne( Math.round(huTimer/Data.AUTO_ANGER) );
			}
		}

		// Mouvement des entités
		var l = getList(Data.ENTITY);
		for (var i=0; i<l.length; i++) {
			l[i].update();
			l[i].endUpdate();
		}
		holeUpdate();

		cleanKills();
		if ( !world.fl_lock ) {
			checkLevelClear();
		}

		// Joueurs en téléportation portail
		if ( nextLink!=null ) {
			var pl = getPlayerList();
			for (var i=0;i<pl.length;i++) {
				var p = pl[i];
				p._xscale*=0.85;
				p._yscale=Math.abs(p._xscale);
				if ( Math.abs(p._xscale)<=2 ) {
					switchDimensionById( nextLink.to_did, nextLink.to_lid, nextLink.to_pid );
					i = 9999;
					nextLink = null;
				}
			}
		}

		// Tremblement
		if ( shakeTimer>0 ) {
			shakeTimer-=Timer.tmod;
			if ( shakeTimer<=0 ) {
				shakeTimer = 0;
				shakePower = 0;
			}
			if ( fl_flipX ) {
				mc._x = Data.GAME_WIDTH+xOffset - Math.round( (Std.random(2)*2-1) * (Std.random(Math.round(shakePower*10))/10) * shakeTimer/shakeTotal );
			}
			else {
				mc._x = Math.round( xOffset + (Std.random(2)*2-1) * (Std.random(Math.round(shakePower*10))/10) * shakeTimer/shakeTotal );
			}
			if ( fl_flipY ) {
				mc._y = Data.GAME_HEIGHT + 20 + Math.round( yOffset + (Std.random(2)*2-1) * (Std.random(Math.round(shakePower*10))/10) * shakeTimer/shakeTotal );
			}
			else {
				mc._y = Math.round( yOffset + (Std.random(2)*2-1) * (Std.random(Math.round(shakePower*10))/10) * shakeTimer/shakeTotal );
			}
		}

		if ( fl_aqua ) {
			aquaTimer += 0.03*Timer.tmod;
			if ( !fl_flipY ) {
				mc._y = -7 + 7*Math.cos(aquaTimer);
				mc._yscale = 102 - 2*Math.cos(aquaTimer);
			}
		}
		else {
			if ( aquaTimer!=0 ) {
				aquaTimer = 0;
				flipY(fl_flipY);
			}
		}


		// Vent
		if ( windTimer>0 ) {
			windTimer-=Timer.tmod;
			if ( windTimer<=0 ) {
				wind(null,null);
			}
		}

		// Indication de sortie fausse
		if ( countList(Data.BAD_CLEAR)>0 ) {
			if ( fxMan.mc_exitArrow._name!=null ) {
				fxMan.detachExit();
			}
		}

		// Pas d'indicateur de sortie en tuto
		if ( fxMan.mc_exitArrow._name!=null ) {
			if ( manager.isTutorial() ) {
				fxMan.detachExit();
			}
		}


		// Enervement minimum
		if ( fl_nightmare ) {
			var bl = getBadList();
			for (var i=0;i<bl.length;i++) {
				var b = bl[i];
				if ( b.isType(Data.BAD_CLEAR) && b.anger==0 ) {
					b.angerMore();
				}
			}
		}

	}

}
