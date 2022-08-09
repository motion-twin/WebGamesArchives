class mode.MultiCoop extends mode.Adventure
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m,id) ;
		_name			= "$multi" ;
		fl_bullet		= false;
		fl_disguise		= false;
		fl_nightmare	= GameManager.CONFIG.hasOption(Data.OPT_NIGHTMARE_MULTI);
		fl_mirror		= GameManager.CONFIG.hasOption(Data.OPT_MIRROR_MULTI);
		fl_map			= true;
		fl_bombControl	= GameManager.CONFIG.hasOption(Data.OPT_BOMB_CONTROL);
	}


	/*------------------------------------------------------------------------
	INITIALISATION PARTIE
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();

		destroyList(Data.PLAYER);
		cleanKills();

		var p1 = insertPlayer(5,-2);
		p1.ctrl.setKeys(Key.UP, Key.DOWN, Key.LEFT, Key.RIGHT, Key.ENTER) ;

		if ( !fl_bombControl ) {
			var p2 = insertPlayer(14,-2);
			p2.ctrl.setKeys(82/*R*/, 70/*F*/, 68/*D*/, 71/*G*/, 65/*A*/) ;
		}
		else {
			p1.ctrl.setAlt(p1.ctrl.attack, Key.CONTROL);
		}
	}

	/*------------------------------------------------------------------------
	EVENT: MISE EN PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		super.onPause();

		pauseMC.gotoAndStop("3");
		pauseMC.move.text			= Lang.get(29);
		pauseMC.attack.text			= Lang.get(42);
		pauseMC.click.text			= "";

		var tip	= Lang.get(301 + tipId++);
		if ( tip==null ) {
			tipId = 0;
			tip	= Lang.get(301 + tipId++);
		}

		pauseMC.tip.html = true;
		pauseMC.tip.htmlText = "<b>" + Lang.get(300) +"</b>"+ tip;
	}


	/*------------------------------------------------------------------------
	INITIALISATION JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(p) {
		super.initPlayer(p);

		p.baseColor = Data.BASE_COLORS[p.pid];
		p.darkColor = Data.DARK_COLORS[p.pid];
		p.lives = Math.ceil(p.lives*0.5);
		if ( p.pid==1 ) {
			p.name			= "$Sandy".substring(1);
			p.skin			= 2;
			p.defaultHead	= Data.HEAD_SANDY;
			p.head			= p.defaultHead;
		}
//		p.ctrl.fl_upKick = false;
	}


	/*------------------------------------------------------------------------
	ENVOI DU RÉSULTAT DE LA PARTIE
	------------------------------------------------------------------------*/
	function saveScore() {
		var pl = getPlayerList();
		Std.getGlobal("gameOver") (
			-1,
			null,
			{
				$reachedLevel	: dimensions[0].currentId,
				$item2			: getPicks2(),
				$data			: { $s0:savedScores[0], $s1:savedScores[1] },
			}
		);
	}


}
