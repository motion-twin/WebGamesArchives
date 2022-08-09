class mode.Adventure extends mode.GameMode
{

	var perfectOrder	: Array<int>;
	var perfectCount	: int;

	var firstLevel		: int;

	var fl_warpStart	: bool;

	var trackPos		: float;

	static var BUCKET_X			= 11;
	static var BUCKET_Y			= 19;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		super(m);
		firstLevel	= id;

		fl_warpStart	= false;
		fl_map			= true;
		_name 			= "$adventure";
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init() {
		super.init();

		initGame();

		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			initPlayer(pl[i]);
		}

		initInterface();



	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function destroy() {
		super.destroy();
	}


	/*------------------------------------------------------------------------
	CONTRÔLES DE JEU
	------------------------------------------------------------------------*/
	function getDebugControls() {
		super.getDebugControls();
		if ( Key.isDown(Key.SHIFT) && Key.isDown(Key.CONTROL) && Key.isDown(77) ) { //  Ctrl+Shift+M
			manager.startGameMode( new mode.MultiCoop(manager,0) );
		}
	}


	/*------------------------------------------------------------------------
	PLACE LES ITEMS STANDARDS DU NIVEAU
	------------------------------------------------------------------------*/
	function addLevelItems() {
		super.addLevelItems();
		var n,pt;

		// Extends
		if ( world.current.$specialSlots.length>0 ) {
			statsMan.spreadExtend();
		}

		// Special
		if ( world.current.$specialSlots.length>0 ) {
			n = Std.random(world.current.$specialSlots.length);
			pt = world.current.$specialSlots[n];
			world.scriptEngine.insertSpecialItem(
				randMan.draw(Data.RAND_ITEMS_ID),
				null,
				pt.$x,
				pt.$y,
				Data.SPECIAL_ITEM_TIMER,
				null,
				false,
				true
			);
		}

		// Score
		if ( world.current.$scoreSlots.length>0 ) {
			n = Std.random(world.current.$scoreSlots.length);
			pt = world.current.$scoreSlots[n];
			world.scriptEngine.insertScoreItem(
				randMan.draw(Data.RAND_SCORES_ID),
				null,
				pt.$x,
				pt.$y,
				Data.SCORE_ITEM_TIMER,
				null,
				false,
				true
			);

			if ( globalActives[94] ) {
				var cx = Std.random(Data.LEVEL_WIDTH);
				var cy = Std.random(Data.LEVEL_HEIGHT-5);
				var ptC = world.getGround(cx,cy);
				world.scriptEngine.insertScoreItem(
					randMan.draw(Data.RAND_SCORES_ID),
					null,
					ptC.x,
					ptC.y,
					Data.SCORE_ITEM_TIMER,
					null,
					false,
					true
				);
			}
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT BAD: GESTION DU PERFECT ORDER POUR LE SUPA ITEM
	------------------------------------------------------------------------*/
	function attachBad(id,x,y) {
		var b = super.attachBad(id,x,y);
		if ( (b.types&Data.BAD_CLEAR)>0 ) {
			perfectOrder.push(b.uniqId);
			perfectCount++;
		}
		return b;
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		super.initWorld();

		addWorld("xml_adventure");
		addWorld("xml_deepnight");
		addWorld("xml_hiko");
		addWorld("xml_ayame");
		addWorld("xml_hk");
		if ( manager.isDev() ) {
			addWorld("xml_dev");
		}
	}


	/*------------------------------------------------------------------------
	INITIALISATION PARTIE
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();
		playMusic(0);
		world.goto(firstLevel);
		insertPlayer(world.current.$playerX, world.current.$playerY);
	}


	/*------------------------------------------------------------------------
	CHANGEMENT DE LEVEL
	------------------------------------------------------------------------*/
	function goto(id) {
		perfectOrder = new Array();
		perfectCount = 0;

		super.goto(id);
	}


	/*------------------------------------------------------------------------
	DÉMARRE LE NIVEAU
	------------------------------------------------------------------------*/
	function startLevel() {
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			pl[i].setBaseAnims(Data.ANIM_PLAYER_WALK, Data.ANIM_PLAYER_STOP);
		}
		perfectOrder = new Array();
		perfectCount = 0;
		super.startLevel();

		// Boss 1
		if ( world.fl_mainWorld && world.currentId == Data.BAT_LEVEL ) {
			entity.boss.Bat.attach(this);
			fl_clear = false;
		}

		// Boss 2
		if ( world.fl_mainWorld && world.currentId == Data.TUBERCULOZ_LEVEL ) {
			entity.boss.Tuberculoz.attach(this);
			fl_clear = false;
		}

		// Pas de fleche au level 0
		if ( world.fl_mainWorld && world.currentId==0 ) {
			fxMan.detachExit();
		}
	}

	/*------------------------------------------------------------------------
	LANCE LE NIVEAU SUIVANT
	------------------------------------------------------------------------*/
	function nextLevel() {

		super.nextLevel();

		if ( fl_warpStart ) {
			world.currentId = 0;
			unlock();
			world.view.detach();
			forcedGoto(10);
		}

	}


	/*------------------------------------------------------------------------
	ENVOI DU RÉSULTAT DE LA PARTIE
	------------------------------------------------------------------------*/
	function saveScore() {
		if(GameManager.HH.get("$"+Md5.encode(world.setName))!="$"+Md5.encode(""+world.csum)) {GameManager.fatal("argh"); return;}
		if(world.setName!="xml_adventure") { GameManager.fatal("");return; }
		Std.getGlobal("gameOver") (
			savedScores[0],
			null,
			{
				$reachedLevel	: dimensions[0].currentId,
				$item2			: getPicks2(),
				$data			: manager.history,
			}
		);
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE POUR LES LEVELS DE BOSS
	------------------------------------------------------------------------*/
	function isBossLevel(id) {
		return
			super.isBossLevel(id) ||
			world.fl_mainWorld && (
				( id>=30 && (id % 10)==0 ) ||
				id==Data.BAT_LEVEL ||
				id==Data.TUBERCULOZ_LEVEL
			);
	}



	/*------------------------------------------------------------------------
	EVENT: LEVEL PRÊT À ÊTRE JOUÉ (APRES SCROLL)
	------------------------------------------------------------------------*/
	function onLevelReady() {
		super.onLevelReady();
		if ( fl_warpStart ) {
			if ( world.fl_mainWorld ) {
				var p = getOne(Data.PLAYER);
				world.view.attachSprite(
					"$door_secret",
					Entity.x_ctr( world.current.$playerX ),
					Entity.x_ctr( world.current.$playerY ) + Data.CASE_HEIGHT*0.5,
					true
				);
			}
			fl_warpStart = false;
		}
		if ( !world.isVisited() ) {
			fxMan.attachLevelPop( Lang.getLevelName(currentDim,world.currentId), world.currentId>0 );
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LEVEL TERMINÉ
	------------------------------------------------------------------------*/
	function onLevelClear() {
		super.onLevelClear();
		if ( !world.isVisited() && perfectOrder.length==0 && world.scriptEngine.cycle>=10 ) {
			var pl = getPlayerList();
			for (var i=0;i<pl.length;i++) {
				pl[i].setBaseAnims(Data.ANIM_PLAYER_WALK_V, Data.ANIM_PLAYER_STOP_V);
			}
			entity.supa.SupaItem.attach(this, perfectCount-1);
			statsMan.inc(Data.STAT_SUPAITEM,1);
		}
	}



	/*------------------------------------------------------------------------
	EVENT: MORT D'UN BAD
	------------------------------------------------------------------------*/
	function onKillBad(b) {
		super.onKillBad(b);

		// Boss Tuberculoz
		if ( world.fl_mainWorld && world.currentId==Data.TUBERCULOZ_LEVEL ) {
			downcast( getOne(Data.BOSS) ).onKillBad();
		}

		// Perfect order
		if ( badCount>1 && b.uniqId==perfectOrder[0] ) {
			perfectOrder.splice(0,1);
		}
	}


	/*------------------------------------------------------------------------
	LOOPS ON ADVENTURE MODE
	------------------------------------------------------------------------*/
//	function endMode() {
//		world.destroy();
//		manager.startGameMode(  new mode.Adventure(manager)  );
//	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION D'UNE BOMBE DE JOUEUR
	------------------------------------------------------------------------*/
	function onExplode(x,y,radius) {
		super.onExplode(x,y,radius);

		if ( world.fl_mainWorld && world.currentId==Data.TUBERCULOZ_LEVEL ) {
			downcast(getOne(Data.BOSS)).onExplode(x,y,radius);
		}

	}


	/*------------------------------------------------------------------------
	EVENT: FIN DU SET DE LEVELS
	------------------------------------------------------------------------*/
	function onEndOfSet() {
		super.onEndOfSet();
		exitGame();
	}


	/*------------------------------------------------------------------------
	EVENT: GAME OVER
	------------------------------------------------------------------------*/
	function onGameOver() {
		super.onGameOver();
		manager.logAction(
			"$t="+Math.round(duration/Data.SECOND);
		);

		var fl_illegal = ( manager.history.join("|").indexOf("!",0)>=0 );

		manager.history = [
			"F="+downcast(Std.getRoot()).$version,
			"T="+gameChrono.get()
		];
		if ( fl_illegal ) {
			manager.history.push("$illegal".substring(1));
		}


		stopMusic();

		saveScore();
	}

	/*------------------------------------------------------------------------
	EVENT: HURRY UP !
	------------------------------------------------------------------------*/
	function onHurryUp() {
		var mc = super.onHurryUp();
		if ( GameManager.CONFIG.hasMusic() && currentTrack==0 ) {
			trackPos = manager.musics[currentTrack].position;
			playMusic(2);
		}
		return mc;
	}


	/*------------------------------------------------------------------------
	FIN DE HURRY UP
	------------------------------------------------------------------------*/
	function resetHurry() {
		super.resetHurry();
		if ( currentTrack==2 ) {
			playMusic(0);
//			playMusicAt(0,trackPos);
		}
	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function endMode() {
		stopMusic();
		manager.startMode( new mode.Editor(manager,world.setName,world.currentId) );
	}



}
