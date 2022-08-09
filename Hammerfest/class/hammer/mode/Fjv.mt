class mode.Fjv extends mode.Adventure {

	var fCookie			: SharedObject;
	var scr				: {>MovieClip, field:TextField};
	var bg				: MovieClip;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id);
		fCookie = SharedObject.getLocal("$fjv_data");
		_name = "$fjv_special";
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
//		super.initWorld();

		world = new levels.GameMechanics(manager,"xml_fjv");
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
		Std.setVar( downcast(fCookie.data), "score", getPlayerList()[0].score );
		stopMusic();
		manager.startMode( new mode.FjvEnd(manager,false) );
	}


	/*------------------------------------------------------------------------
	EVENT: FINAL PORTAL
	------------------------------------------------------------------------*/
	function usePortal(pid,e) {
		stopMusic();
		Std.setVar( downcast(fCookie.data), "score", getPlayerList()[0].score );
		manager.startMode( new mode.FjvEnd(manager,true) );
		return true;
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
		else {
			fxMan.levelName.removeMovieClip();
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
