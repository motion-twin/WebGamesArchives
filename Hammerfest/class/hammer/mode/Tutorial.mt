class mode.Tutorial extends mode.GameMode {


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m) {
		super(m);
		_name = "$tutorial";
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		super.init();

		initGame();
		initInterface();
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU JEU
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();
		world.goto(0);

		var p = insertPlayer(world.current.$playerX, world.current.$playerY);
		p.lives = 99999;
	}

	/*------------------------------------------------------------------------
	INITIALISATION INTERFACE
	------------------------------------------------------------------------*/
	function initInterface() {
		super.initInterface();
		gi.lightMode();
	}


	/*------------------------------------------------------------------------
	INIT DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		super.initWorld();
		world = new levels.GameMechanics(manager,"xml_tutorial") ;
		world.setDepthMan(depthMan);
		world.setGame(this);
		world.fl_shadow = false;
		if(world.setName!="xml_tutorial") { GameManager.fatal("world.setName!=xml_tutorial");return; }
	}



	/*------------------------------------------------------------------------
	FIN DU MODE
	------------------------------------------------------------------------*/
	function endMode() {
		stopMusic();
		manager.startGameMode(  new mode.Shareware(manager,0)  );
	}

	/*------------------------------------------------------------------------
	EVENT: GAME OVER (APPUI SUR "ECHAP")
	------------------------------------------------------------------------*/
	function onGameOver() {
		if(world.setName!="xml_tutorial") { GameManager.fatal("");return; }
		fl_gameOver = true;
		lock();
		var url = Std.getVar( Std.getRoot(), "$out" );
		manager.redirect(url,null);
	}


	/*------------------------------------------------------------------------
	EVENT: PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		super.onPause();
		pauseMC.sector.text = Lang.get(14)+" �"+Lang.get(16)+"�";
	}


	/*------------------------------------------------------------------------
	FONCTIONS D�SACTIV�ES
	------------------------------------------------------------------------*/
	function onHurryUp() { return null; }
	function darknessManager() {}


	/*------------------------------------------------------------------------
	EVENT: LEVEL PR�T
	------------------------------------------------------------------------*/
	function onLevelReady() {
		super.onLevelReady();
		if ( world.currentId==0 ) {
			fxMan.attachLevelPop( Lang.get(16), false );
		}
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET DE LEVELS
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		super.onEndOfSet();
		manager.startGameMode( new mode.Shareware(manager,0) );
	}

}