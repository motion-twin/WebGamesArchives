class mode.Soccer extends mode.MultiCoop {
	static var BOOST_DISTANCE		= 180;
	static var MAX_BOOST			= 1.5;
	static var MATCH_DURATION		= 5 * (1000*60); // millisec
	static var WARNING_TIME			= 1 * (1000*60);
	static var BLINK_COLOR			= 0xffbbaa;
	static var BLINK_GLOWCOLOR		= 0x990000;

	static var GOAL_OFFTIME			= 5 * Data.SECOND;
	static var START_OFFTIME		= 3 * Data.SECOND;
	static var END_TIMER			= 13 * Data.SECOND;

	var fl_party		: bool;
	var fl_match		: bool;
	var fl_end			: bool;
	var fl_help			: bool;
	var scores			: Array<int>;
	var teams			: Array< Array<entity.Player> >;

	var ball			: entity.bomb.player.SoccerBall;
	var blinkTimer		: float;

	var chrono			: Chrono;
	var offPlayTimer	: float;
	var finalTimer		: float;
	var winners			: int; // id team gagnante (null si ex-aequo)


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,id) {
		id = null;
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_SOC_0) ) {	id = 0;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_SOC_1) ) {	id = 1;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_SOC_2) ) {	id = 2;	}
		if ( GameManager.CONFIG.hasOption(Data.OPT_SET_SOC_3) ) {	id = 3;	}
		if ( id==null ) {
			GameManager.fatal("unknown soccermap ID");
			return;
		}

		super(m,id);


		_name		= "$soccer";
		fl_disguise	= false;
		fl_map		= false;

		fl_help		= true;
		fl_party	= false;
		fl_match	= false;
		fl_end		= false;
		fl_nightmare= false;

		blinkTimer	= 0;

		chrono		= new Chrono();
		scores		= new Array();
		teams		= new Array();

		manager.fl_debug = false;
	}


	/*------------------------------------------------------------------------
	INITIALISATION DU JEU
	------------------------------------------------------------------------*/
	function initGame() {
		super.initGame();

		if ( fl_party ) {
			var p1 = insertPlayer(6,10);
			p1.ctrl.setKeys(79, 76, 75, 77, 73) ; // OKLM
			var p2 = insertPlayer(14,10);
			p2.ctrl.setKeys(101/*Z*/, 98/*S*/, 97/*A*/, 99/*D*/, 100/*A*/) ;
		}


		// Construction teams
		var pl = getPlayerList();
		teams = [ [], [] ];
		for (var i=0;i<pl.length;i++) {
			if ( i<pl.length/2 ) {
				teams[0].push(pl[i]);
			}
			else {
				teams[1].push(pl[i]);
			}
		}


		scores	= [0,0];

		var mc = depthMan.empty(Data.DP_INTERF);
		var t = Std.createTextField(mc,1);
		t._width	= 300;
		t._height	= 50;
		t._x		= Data.GAME_WIDTH*0.5 - t._width*0.5;
		t._y		= Data.GAME_HEIGHT-20;
		t.textColor	= 0xffffff;
		t.html		= true;
		t.htmlText	= '<P ALIGN="CENTER"><FONT COLOR="#FFFFFF">'+Lang.get(33)+"</FONT></P>";
		t.wordWrap	= false;
		t.selectable= false;

	}


	/*------------------------------------------------------------------------
	INITIALISATION INTERFACE
	------------------------------------------------------------------------*/
	function initInterface() {
		gi.destroy();
		gi = Std.cast( new gui.SoccerInterface(this) );
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
	CHANGEMENT DE LEVEL
	------------------------------------------------------------------------*/
	function forcedGoto(id) {
		super.forcedGoto(id);
		cleanKills();
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			initPlayer(pl[i]);
		}

	}



	/*------------------------------------------------------------------------
	INITIALISATION JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(p) {
		super.initPlayer(p);

		p.baseColor = Data.BASE_COLORS[ getTeam(p)+1 ];
		p.skin		= p.pid+3;
		if ( p.skin==4 ) {
			p.defaultHead = Data.HEAD_SANDY;
			p.head = p.defaultHead;
		}
//		p.setColorHex( 30+22*getTeamPos(p), p.baseColor );
		p.baseWalkAnim			= Data.ANIM_PLAYER_SOCCER;
		p.ctrl.fl_upKick		= true;
		p.ctrl.fl_powerControl	= GameManager.CONFIG.hasOption(Data.OPT_KICK_CONTROL);
		p.lives					= 0;
		p.dx					= 0;
		p.dy					= 0;
		p.unshield();
		if ( p.fl_knock ) {
			p.onWakeUp();
		}

		if ( getTeam(p)==0 ) {
			p.moveTo( Entity.x_ctr(world.current.$playerX+getTeamPos(p)), Entity.y_ctr(world.current.$playerY) );
		}
		else {
			p.moveTo( Entity.x_ctr(Data.LEVEL_WIDTH - world.current.$playerX -1 - getTeamPos(p)), Entity.y_ctr(world.current.$playerY) );
		}

		if ( GameManager.CONFIG.hasOption(Data.OPT_SOCCER_BOMBS) ) {
			p.changeWeapon( Data.WEAPON_B_REPEL );
		}
		else {
			p.changeWeapon( Data.WEAPON_NONE );
		}

	}


	/*------------------------------------------------------------------------
	INITIALISATION INTERFACE
	------------------------------------------------------------------------*/
//	function initInterface() {
//		gi.destroy();
//	}


	/*------------------------------------------------------------------------
	RENVOIE LE NUMÉRO DE TEAM D'UN JOUEUR
	------------------------------------------------------------------------*/
	function getTeam(p) {
		var tid = 0;
		for (var i=0;i<teams[1].length;i++) {
			if ( teams[1][i].pid == p.pid ) {
				tid = 1;
			}
		}
		return tid;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE NUMÉRO DE TEAM D'UN JOUEUR
	------------------------------------------------------------------------*/
	function getTeamPos(p) {
		var tid = getTeam(p);
		var pos = 0;
		for (var i=0;i<teams[tid].length;i++) {
			if ( p.pid == teams[tid][i].pid ) {
				pos = i;
			}
		}
		return pos;
	}


	/*------------------------------------------------------------------------
	RENVOIE LE SCORE D'UNE TEAM
	------------------------------------------------------------------------*/
	function getTeamScore(tid) {
		return scores[tid];
	}


	/*------------------------------------------------------------------------
	INIT DU MONDE
	------------------------------------------------------------------------*/
	function initWorld() {
		addWorld("xml_soccer");
	}



	/*------------------------------------------------------------------------
	FONCTIONS DÉSACTIVÉES
	------------------------------------------------------------------------*/
	function onHurryUp() {return null; }
	function darknessManager() {}
	function getDebugControls() {}
	function addLevelItems() {}


	/*------------------------------------------------------------------------
	MARQUAGE DE BUT
	------------------------------------------------------------------------*/
	function goal(tid:int) {
		var shooter = ball.lastPlayer;
		var pl = getPlayerList();
		scores[tid]++;
		pl[tid].getScoreHidden(1);

		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			p.head = p.defaultHead;
			p.speedFactor = 1;
			if ( getTeam(p)==tid ) {
				p.setBaseAnims( Data.ANIM_PLAYER_WALK_V, Data.ANIM_PLAYER_STOP_V );
			}
			else {
				p.setBaseAnims( Data.ANIM_PLAYER_SOCCER, Data.ANIM_PLAYER_STOP );
			}
		}

		if ( tid==getTeam(shooter) ) {
			// but normal
			soundMan.playSound("sound_item_score", Data.CHAN_FIELD);
			fxMan.attachAlert(Lang.get(22)+" ("+getTeamScore(0)+" - "+getTeamScore(1)+")");
			if ( shooter.skin==4 ) {
				shooter.head = Data.HEAD_SANDY_CROWN;
			}
			else {
				shooter.head = Data.HEAD_CROWN;
			}
		}
		else {
			// but contre son camp
			soundMan.playSound("sound_player_death", Data.CHAN_FIELD);
			fxMan.attachAlert(Lang.get(23));
			if ( shooter.skin==4 ) {
				shooter.head = Data.HEAD_SANDY_LOSE;
			}
			else {
				shooter.head = Data.HEAD_LOSE;
			}

		}
		shooter.replayAnim();
		fxMan.inGameParticlesDir( Data.PARTICLE_CLASSIC_BOMB, ball.x,ball.y, 10, -ball.dx);
		fxMan.attachFx( ball.x, ball.y-Data.CASE_HEIGHT, "hammer_fx_shine" ) ;

		offPlayTimer = GOAL_OFFTIME;
	}


	/*------------------------------------------------------------------------
	FIN DU MATCH
	------------------------------------------------------------------------*/
	function endMatch() {
		fxMan.clear();
		fxMan.inGameParticles( Data.PARTICLE_CLASSIC_BOMB, ball.x,ball.y, 10 );
		ball.destroy();
		fxMan.attachAlert( Lang.get(25) );

		offPlayTimer = 99999;
		fl_end = true;

		// Détermine l'équipe gagnante
		if ( getTeamScore(0) > getTeamScore(1) ) {
			winners = 0;
		}
		if ( getTeamScore(0) < getTeamScore(1) ) {
			winners = 1;
		}
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			p.speedFactor = 1;
			p.setBaseAnims( Data.ANIM_PLAYER_SOCCER, Data.ANIM_PLAYER_STOP );
		}

	}


	/*------------------------------------------------------------------------
	AFFICHE LE RÉSULTAT DU MATCH
	------------------------------------------------------------------------*/
	function showResults() {
		// Message de résultat
		if ( winners==0 ) {
			fxMan.attachAlert( Lang.get(26) );
		}
		if ( winners==1 ) {
			fxMan.attachAlert( Lang.get(27) );
		}
		if ( winners==null ) {
			fxMan.attachAlert( Lang.get(28) );
		}


		shake(Data.SECOND, 5);

		// Anims de fin
		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			if ( winners!=null && getTeam(p)==winners ) {
				p.speedFactor = 1;
				p.setBaseAnims( Data.ANIM_PLAYER_WALK_V, Data.ANIM_PLAYER_STOP_V );
			}
			else {
				p.speedFactor = 0.3;
				p.setBaseAnims( Data.ANIM_PLAYER_WALK_L, Data.ANIM_PLAYER_STOP_L );
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LEVEL PRÊT
	------------------------------------------------------------------------*/
	function onLevelReady() {
		super.onLevelReady();
		fl_match = false;
		offPlayTimer = START_OFFTIME;

		onPause();
		pauseMC.onRelease	= callback( this, onUnpause );
		pauseMC.click.text	= Lang.get(6);
		fxMan.levelName.removeMovieClip();
	}


	/*------------------------------------------------------------------------
	EVENT: MISE EN PAUSE
	------------------------------------------------------------------------*/
	function onPause() {
		super.onPause();

		pauseMC.gotoAndStop("2");
		pauseMC.move.text			= Lang.get(29);
		pauseMC.attack.text			= Lang.get(30);
		downcast(pauseMC).up.text	= Lang.get(31);
		pauseMC.tip.text			= Lang.get(32);
		pauseMC.click.text			= "";
	}


	function onUnpause() {
		super.onUnpause();
		if ( fl_help ) {
			fxMan.attachAlert(Lang.get(21));
			fl_help = false;
		}
	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function onEndMode() {
		endMode();
	}

	function endMode() {
		var url = Std.getVar( Std.getRoot(), "$out" );
		manager.redirect(url,null);
	}

	function onGameOver() {
		endMode();
	}


	/*------------------------------------------------------------------------
	AJOUTE LE BALLON
	------------------------------------------------------------------------*/
	function insertBall() {
		var s = world.current.$specialSlots[ Std.random(world.current.$specialSlots.length) ];
		ball = entity.bomb.player.SoccerBall.attach(
			this,
			Entity.x_ctr(s.$x),
			Entity.y_ctr(s.$y)
		);

		fxMan.inGameParticles( Data.PARTICLE_CLASSIC_BOMB, ball.x,ball.y, 9);
		fxMan.inGameParticles( Data.PARTICLE_ICE, ball.x,ball.y, 5);

		var pl = getPlayerList();
		for (var i=0;i<pl.length;i++) {
			pl[i].setBaseAnims( Data.ANIM_PLAYER_SOCCER, Data.ANIM_PLAYER_STOP );
		}

		soundMan.playSound("sound_pop", Data.CHAN_FIELD);

	}



	/*------------------------------------------------------------------------
	BOUCLE MAIN
	------------------------------------------------------------------------*/
	function main() {
		chrono.update();
		if ( !fl_match ) {
			chrono.reset();
		}

		if ( manager.isDev() && Key.isDown(Key.SHIFT) ) {
			chrono.timeShift(-1);
		}


		var t;
		if ( chrono.fl_stop ) {
			t = MATCH_DURATION-(chrono.suspendTimer-chrono.gameTimer);
		}
		else {
			t = MATCH_DURATION-chrono.get();
		}
		t = int( Math.max(0,t) );
		downcast(gi).setTime( chrono.formatTimeShort(t) );



		// Blink chrono
		if ( t<WARNING_TIME ) {
			blinkTimer-=Timer.tmod;
			if ( blinkTimer<=0 ) {
				var tf : TextField = downcast(gi).time;
				if ( tf.textColor==BLINK_COLOR || t==0 ) {
					tf.textColor = 0xffffff;
					FxManager.addGlow( downcast(tf), gui.SoccerInterface.GLOW_COLOR, 2 );
				}
				else {
					tf.textColor = BLINK_COLOR;
					FxManager.addGlow( downcast(tf), BLINK_GLOWCOLOR, 2 );

				}
				blinkTimer = 15 * (t/WARNING_TIME);
			}
		}



		if ( !fl_lock ) {
			// Gestion off-play
			if ( offPlayTimer>0 ) {
				offPlayTimer-=Timer.tmod;
			}

			// Remise en jeu
			if ( ball._name == null && offPlayTimer<=0 ) {
				fl_match = true;
				fxMan.attachAlert(Lang.get(24));
				insertBall();
				chrono.start();
			}

			// Speed boost
			if ( ball._name!=null ) {
				var pl = getPlayerList();
				for (var i=0;i<pl.length;i++) {
					var p = pl[i];
					var dist = p.distance(ball.x,ball.y);
					if ( dist > BOOST_DISTANCE ) {
						var ratio = Math.min(MAX_BOOST, dist/BOOST_DISTANCE);
						p.speedFactor = ratio;
					}
					else {
						p.speedFactor = 1;
					}
				}
			}
		}

		super.main();

		fxMan.detachExit();

		// Fin de match
		if ( !fl_lock ) {
			if ( chrono.get()>=MATCH_DURATION && !fl_end ) {
				endMatch();
				finalTimer = Data.SECOND * 3;
			}

			// Résultat final
			if ( finalTimer>0 ) {
				finalTimer -= Timer.tmod;
				if ( finalTimer<=0 ) {
					showResults();
					endModeTimer = END_TIMER;
				}
			}

			// Particules pour les gagnants
			if ( endModeTimer>0 ) {
				var pl = getPlayerList();
				for (var i=0;i<pl.length;i++) {
					var p = pl[i];
					if ( getTeam(p)==winners ) {
						if ( p.dx!=0 ) {
							fxMan.inGameParticlesDir( Data.PARTICLE_SPARK, p.x,p.y-Std.random(40), Std.random(3), -p.dir );
						}
						else {
							fxMan.inGameParticles( Data.PARTICLE_SPARK, p.x,p.y-Std.random(40), Std.random(2) );
						}
					}
				}
			}
		}
	}

}
