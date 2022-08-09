class mode.AdventureTest extends mode.Adventure {
	var testData : levels.Data;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m, l: levels.Data) {
		super(m,1);

		testData	= l;
		_name		= "$advTest";
	}


	/*------------------------------------------------------------------------
	DÉBUT DE NIVEAU
	------------------------------------------------------------------------*/
	function startLevel() {
		super.startLevel();
		var l = getPlayerList() ;
		for (var i=0;i<l.length;i++) {
			l[i].moveToCase( world.current.$playerX, world.current.$playerY );
		}


	}


	/*------------------------------------------------------------------------
	INITIALISATION MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		super.initWorld();
		world.raw[1] = world.serializeExternal(testData);
	}

	/*------------------------------------------------------------------------
	CHANGER DE NIVEAU MET FIN AU MODE
	------------------------------------------------------------------------*/
	function nextLevel() {
		endMode();
	}

	/*------------------------------------------------------------------------
	FIN DU MODE DE JEU
	------------------------------------------------------------------------*/
	function endMode() {
		stopMusic();
		world.destroy();
		manager.stopChild(null);
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE SET
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		endMode();
	}

	/*------------------------------------------------------------------------
	EVENT: MORT
	------------------------------------------------------------------------*/
	function onGameOver() {
		endMode();
	}


	/*------------------------------------------------------------------------
	MAIN LOOP
	------------------------------------------------------------------------*/
	function main() {
		Log.print( Math.round(Timer.fps())+"fps") ;
		super.main();
	}
}

