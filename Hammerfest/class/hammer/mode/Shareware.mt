class mode.Shareware extends mode.Adventure {


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id);
		_name = "$shareware";
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
//		super.initWorld();

		world = new levels.GameMechanics(manager,"xml_shareware");
		world.setDepthMan(depthMan);
		world.setGame(this);
	}

	/*------------------------------------------------------------------------
	INITIALISATION D'UNE PARTIE
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();
		var p : entity.Player = downcast( getOne(Data.PLAYER) );
		p.lives = 2;
		gi.setLives(p.pid, p.lives);
	}

	/*------------------------------------------------------------------------
	RETOUR AU SITE
	------------------------------------------------------------------------*/
	function endMode() {
		lock();
		var url = Std.getVar( Std.getRoot(), "$out" );
		manager.redirect(url,null);
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		endMode();
	}

	/*------------------------------------------------------------------------
	EVENT: GAME OVER
	------------------------------------------------------------------------*/
	function onGameOver() {
		endMode();
	}

	/*------------------------------------------------------------------------
	EVENT: LEVEL PRÊT
	------------------------------------------------------------------------*/
	function onLevelReady() {
		super.onLevelReady();
		if ( world.currentId==0 ) {
			fxMan.attachLevelPop( Lang.get(17), true );
		}
	}

	/*------------------------------------------------------------------------
	EVENT: PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		super.onPause();
		pauseMC.sector.text = Lang.get(14)+" «"+Lang.get(17)+"»";
	}

	/*------------------------------------------------------------------------
	FONCTIONS DÉSACTIVÉES
	------------------------------------------------------------------------*/
	function darknessManager() {}
}
