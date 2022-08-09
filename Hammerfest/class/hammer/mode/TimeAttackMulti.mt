class mode.TimeAttackMulti extends mode.TimeAttack
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id) ;
		_name = "$timeMulti"
	}


	/*------------------------------------------------------------------------
	RÉCUPÈRE L'ID DE COURSE
	------------------------------------------------------------------------*/
	function initRunId() {
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_MTA_0) ) {	runId = 0;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_MTA_1) ) {	runId = 1;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_MTA_2) ) {	runId = 2;	}
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		addWorld("xml_multitime");
	}


	/*------------------------------------------------------------------------
	INITIALISATION PARTIE
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();

		destroyList(Data.PLAYER);
		cleanKills();

		var px = world.current.$playerX;
		var py = world.current.$playerY;

		var p1 = insertPlayer(px,py);
		p1.ctrl.setKeys(Key.UP, Key.DOWN, Key.LEFT, Key.RIGHT, Key.ENTER) ;

		var p2 = insertPlayer(Data.LEVEL_WIDTH*0.5+(Data.LEVEL_WIDTH*0.5-px),py);
		p2.ctrl.setKeys(90/*Z*/, 83/*S*/, 81/*A*/, 68/*D*/, 65/*A*/) ;


		initializePlayers();
	}


	/*------------------------------------------------------------------------
	INITIALISATION JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(p) {
		super.initPlayer(p);

		p.baseColor = Data.BASE_COLORS[p.pid];
		if ( p.pid==1 ) {
			p.skin = 2;
			p.defaultHead = Data.HEAD_SANDY;
			p.head = p.defaultHead;
		}
	}
}
