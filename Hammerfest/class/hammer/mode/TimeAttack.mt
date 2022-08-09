class mode.TimeAttack extends mode.Adventure
{
	static var INFINITY	= 59*60*1000 + 59*1000 + 999;


	var gameTimer		: int;
	var suspendTimer	: int;
	var last			: int;
	var fl_chronoStop	: bool;
	var times			: Array<int>;
	var fl_alerts		: Array<bool>;

	var starter			: float;
	var mcStarter		: {>MovieClip, field:TextField};

	var frameTimer		: int; // currentframe time
	var prevFrameTimer	: int;

	var runId			: int;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id) ;

		runId = null;
		initRunId();
		if ( runId==null ) {
			GameManager.fatal("unknown run ID");
			return;
		}
		firstLevel = runId*9;

		_name			= "$time" ;
		suspendTimer	= null;
		times			= new Array();
		frameTimer		= Std.getTimer();
		fl_alerts		= new Array();
		fl_static		= true;
		fl_bullet		= false;
		fl_mirror		= false;
		fl_nightmare	= false;
	}


	/*------------------------------------------------------------------------
	RÉCUPÈRE L'ID DE COURSE
	------------------------------------------------------------------------*/
	function initRunId() {
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_TA_0) ) {	runId = 0;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_TA_1) ) {	runId = 1;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_TA_2) ) {	runId = 2;	}
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		addWorld("xml_time");
	}


	/*------------------------------------------------------------------------
	INITIALISATION PARTIE
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();

		initializePlayers();
		resetChrono();
	}


	/*------------------------------------------------------------------------
	PRÉPARE LES JOUEURS AU MODE MULTI
	------------------------------------------------------------------------*/
	function initializePlayers() {
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			p.getScore = null;
			p.getScoreHidden = null;
			p.lives = 3;
			gi.setLives(p.pid, p.lives);
		}
	}


	/*------------------------------------------------------------------------
	OBJET À POINTS RAMASSÉ
	------------------------------------------------------------------------*/
	function pickUpScore(id,sid) {
		var ret = super.pickUpScore(id,sid);
		if ( id==0 ) {

			var bonus = Data.getCrystalTime(sid);
			timeShift(bonus);

			var l = getPlayerList();
			for (var i=0;i<l.length;i++) {
				var p = l[i];
				fxMan.attachScorePop( p.baseColor, p.darkColor, p.x, p.y, "-"+bonus+" sec" );
			}

		}

		return ret;
	}


	/*------------------------------------------------------------------------
	FONCTIONS DÉSACTIVÉES
	------------------------------------------------------------------------*/
	function addLevelItems() {}


	/*------------------------------------------------------------------------
	LANCE UN NIVEAU
	------------------------------------------------------------------------*/
	function goto(id) {
		if ( world.isEmptyLevel(id,this) ) {
			onEndOfSet();
			return;
		}
		stopChrono();
		var t = Math.floor( prevFrameTimer-gameTimer );
		var lt = t;
		for (var i=0;i<times.length;i++) {
			lt-=times[i];
		}
		times.push(lt);
		display(formatTime(t));

		super.goto(id);
	}


	/*------------------------------------------------------------------------
	ENREGISTRE LE TEMPS
	------------------------------------------------------------------------*/
	function saveScore() {
		var t = 0;
		for (var i=0;i<times.length;i++) {
			t+=times[i];
		}
		Std.getGlobal("gameOver") (
			t,
			runId,
			{
				$reachedLevel	: 0,
				$item2			: null,
				$data			: null,
			}
		);
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE PARTIE
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		saveScore();
	}


	/*------------------------------------------------------------------------
	EVENT: MORT
	------------------------------------------------------------------------*/
	function onGameOver() {
		times = [ 3599999 ];
		saveScore();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE LEVEL
	------------------------------------------------------------------------*/
	function onLevelClear() {
		perfectOrder = null;  // pas de supa item
		super.onLevelClear();
	}


	/*------------------------------------------------------------------------
	EVENT: DEBUT DE LEVEL
	------------------------------------------------------------------------*/
	function onLevelReady() {
		super.onLevelReady();

		fxMan.levelName.removeMovieClip();

		// Indicateur de temps du level précédent
		if ( world.currentId!=firstLevel ) {
			displayLastTime();
		}


		if ( world.currentId==firstLevel ) {
			lock();
			display( formatTime(0) );
			starter = Data.SECOND*3.5;
			mcStarter = downcast( depthMan.attach("hammer_interf_starter",Data.DP_INTERF) );
			mcStarter._x = Data.DOC_WIDTH*0.5;
			mcStarter._y = Data.DOC_HEIGHT*0.5;
			mcStarter.field.text = "";
			resetChrono();
		}

	}


	/*------------------------------------------------------------------------
	EVENT: RÉSURRECTION
	------------------------------------------------------------------------*/
	function onResurrect() {
		super.onResurrect();
//		var l = getPlayerList();
//		for (var i=0;i<l.length;i++) {
//			l[i].speedFactor = 1.5;
//		}
	}


	/*------------------------------------------------------------------------
	RENVOIE LA VALEUR DU CHRONO ACTUEL (millisecondes)
	------------------------------------------------------------------------*/
	function getChrono() {
		return Math.floor( frameTimer-gameTimer );
	}


	/*------------------------------------------------------------------------
	MET À JOUR LE(s) CHRONO(s) DE L'INTERFACE
	------------------------------------------------------------------------*/
	function display(str) {
		var l = getPlayerList();
		for (var i=0;i<l.length;i++) {
			var p = l[i];
			gi.print( 0,str );
			gi.print( 1,str );
		}
	}


	/*------------------------------------------------------------------------
	AFFICHE LE TEMPS DU NIVEAU PRÉCÉDENT
	------------------------------------------------------------------------*/
	function displayLastTime() {
		var t = times[times.length-1];
		if ( t!=null ) {
			var mc : {>MovieClip, sub:{field:TextField}};
			mc = downcast( depthMan.attach("hammer_interf_time", Data.DP_INTERF) );
			mc._x = 20;
			mc._y = Data.DOC_HEIGHT - 50;
			mc.sub.field.text = "+ " + formatTime(t);
			FxManager.addGlow(mc,Data.DARK_COLORS[0],2);
	    }
	}


	/*------------------------------------------------------------------------
	RENVOIE LE CHRONO FORMATTÉ
	------------------------------------------------------------------------*/
	function formatTime(t:int) {
		var d = new Date();
		d.setTime( t );
		return
			Data.leadingZeros( d.getMinutes()+(d.getHours()-1)*60, 2 ) +"\" "+
			Data.leadingZeros( d.getSeconds(), 2 ) +"' "+
			Data.leadingZeros( d.getMilliseconds(),3 );
	}



	/*------------------------------------------------------------------------
	GESTION DU CHRONO
	------------------------------------------------------------------------*/
	function resetChrono() {
		last			= getChrono();
		fl_chronoStop	= false;
		suspendTimer	= null;
		gameTimer		= frameTimer;
	}

	function startChrono() {
		if ( suspendTimer!=null ) {
			var d = frameTimer-suspendTimer;
			gameTimer+=d;
		}
		fl_chronoStop = false;
		suspendTimer = null;
	}

	function stopChrono() {
		if ( fl_chronoStop ) {
			return;
		}
		fl_chronoStop = true;
		suspendTimer = frameTimer;
	}


	/*------------------------------------------------------------------------
	ARRÊTS / REPRISES
	------------------------------------------------------------------------*/
	function lock() {
		super.lock();
		stopChrono();
	}


	function unlock() {
		super.unlock();
		startChrono();
	}

	function switchDimensionById(id,lid,pid) {
		stopChrono();
		super.switchDimensionById(id,lid,pid);
	}



	/*------------------------------------------------------------------------
	GAIN DE TEMPS
	------------------------------------------------------------------------*/
	function timeShift(n) {
		gameTimer = int( Math.min( frameTimer, gameTimer+n*1000 ) );
	}


	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {

		// Pas de hurryup
		huTimer = 0;


		// Timer de départ
		if ( starter>0 ) {
			var old = Math.ceil(starter/32);
			starter-=Timer.tmod;
			var now = Math.ceil(starter/32);
			mcStarter._xscale	*= 0.99;
			mcStarter._yscale	= mcStarter._xscale;
			mcStarter._alpha	*= 0.95;
			if ( old!=now ) {
				mcStarter.field.text = "" + now;
				mcStarter._alpha	= 100;
				mcStarter._xscale	= 70 + 120-now*40;
				mcStarter._yscale	= mcStarter._xscale;
			}
			if ( starter<=0 ) {
				mcStarter.removeMovieClip();
				fxMan.attachAlert(Lang.get(20));
				unlock();
				resetChrono();
			}
		}

		prevFrameTimer = frameTimer;
		frameTimer = Std.getTimer();
		super.main();


		if ( !fl_chronoStop ) {
			// warning minutes
			if ( Math.floor(getChrono()/60000) != Math.floor(last/60000) ) {
				var m = Math.floor(getChrono()/60000);
				if ( m>0 && fl_alerts[m]!=true ) {
					var mc;
					fl_alerts[m] = true;
					if ( m>1 ) {
						mc = fxMan.attachAlert( m + " " + Lang.get(19) );
					}
					else {
						mc = fxMan.attachAlert( m + " " + Lang.get(18) ); // sans s
					}
					mc._y += 40;
				}
			}
			last = getChrono();

			// update d'interface
			if ( !fl_lock && starter<=0 ) {
				display( formatTime(getChrono()) );
			}
		}
	}


}
