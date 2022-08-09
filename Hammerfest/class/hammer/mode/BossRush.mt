class mode.BossRush extends mode.Adventure
{
	var chrono			: Chrono;
	var levelAvg		: float;
	var levelCount		: int;
	var levelTimer		: int;
	var lastLevelTimer	: int;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id);
		_name			= "$bossRush";
		fl_disguise		= false;
		fl_map			= true;
		fl_mirror		= false;
		fl_nightmare	= false;

		levelTimer		= 0;
		levelAvg		= 0;
		lastLevelTimer	= null;

		chrono		= new Chrono();
	}



	/*------------------------------------------------------------------------
	GESTION CHRONO
	------------------------------------------------------------------------*/
	function unlock() {
		super.unlock();
		chrono.start();
	}

	function lock() {
		super.lock();
		chrono.stop();
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(p) {
		super.initPlayer(p);
		upgradePlayer(p);
	}

	function upgradePlayer(p) {
		p.speedFactor = 1.5;
		p.maxBombs = 2;
		p.ctrl.fl_upKick = true;
	}


	/*------------------------------------------------------------------------
	EVENT: PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		super.onPause();
		pauseMC.gotoAndStop("4");
		pauseMC.title.text	= Lang.get(36);
		downcast(pauseMC).timeLabel.text = Lang.get(37);
		downcast(pauseMC).time.text = chrono.getStrShort();
		downcast(pauseMC).timeAvgLabel.text = Lang.get(38);
		if ( levelAvg>0 ) {
			downcast(pauseMC).timeAvg.text = chrono.formatTimeShort( Math.round(levelAvg) );
		}
		else {
			downcast(pauseMC).timeAvg.text = "--";
		}
	}


	/*------------------------------------------------------------------------
	EVENT: RÉSURRECTION
	------------------------------------------------------------------------*/
	function onResurrect() {
		super.onResurrect();
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			upgradePlayer(pl[i]);
		}
	}


	/*------------------------------------------------------------------------
	LANCE UN NIVEAU DONNÉ
	------------------------------------------------------------------------*/
	function goto(id) {
		if ( ((id-1)%10)==0 && id>1 ) {
			registerMapEvent( Data.EVENT_TIME, chrono.getStrShort() );
		}

		registerLevelTime();

		super.goto(id);
	}


	/*------------------------------------------------------------------------
	CHANGE DE DIMENSION
	------------------------------------------------------------------------*/
	function switchDimensionById( did, lid, pid ) {
		registerLevelTime();
		super.switchDimensionById(did,lid,pid);
	}


	/*------------------------------------------------------------------------
	STOCKE LE TEMPS DU LEVEL
	------------------------------------------------------------------------*/
	function registerLevelTime() {
		lastLevelTimer = chrono.get()-levelTimer;
		if ( levelAvg==0 ) {
			levelAvg = lastLevelTimer;
		}
		levelAvg = 0.5 * (levelAvg+lastLevelTimer);
	}


	/*------------------------------------------------------------------------
	DÉMARRE LE NIVEAU
	------------------------------------------------------------------------*/
	function startLevel() {
		super.startLevel();
		if ( !chrono.fl_init ) {
			chrono.reset();
		}
		else {
			displayTime( lastLevelTimer );
			lastLevelTimer = null;
		}
		levelTimer = chrono.get();
		levelCount++;
	}


	/*------------------------------------------------------------------------
	AFFICHE LE TEMPS EN COURS
	------------------------------------------------------------------------*/
	function displayTime(t) {
		var mc = fxMan.attachFx( 5, Data.DOC_HEIGHT-45, "hammer_interf_time" ).mc;
//		var mc : {>MovieClip, sub:{field:TextField}};
//		mc = downcast( depthMan.attach("hammer_interf_time", Data.DP_INTERF) );
//		mc._x = 5;
//		mc._y = Data.DOC_HEIGHT - 45;
		downcast(mc).sub.field.text = Lang.get(39)+" +"+chrono.formatTimeShort(t);
		FxManager.addGlow(mc,Data.DARK_COLORS[0],2);
	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		chrono.update();

		if ( manager.isDev() ) {
//			Log.print( chrono.getStr() );
		}

		super.main();
	}

}