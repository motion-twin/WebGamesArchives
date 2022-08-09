import entity.PlayerController ;

class entity.Player extends entity.Physics
{
	var name			: String;

	var ctrl			: PlayerController ;
	var specialMan		: SpecialManager ;

	var baseColor		: int; // hexa
	var darkColor		: int; // hexa

	var baseWalkAnim	: {id:int, loop:bool};
	var baseStopAnim	: {id:int, loop:bool};

	var speedFactor		: float ;
	var fl_lockControls	: bool ;
	var fl_entering		: bool;

	var score			: int ;
	var scoreCS			: int;

	var dbg_lastKey		: int ;
	var dbg_grid		: int ;

	var currentWeapon	: int ;
	var maxBombs		: int ;
	var initialMaxBombs	: int;
	var dir				: int ;
	var coolDown		: float ;
	var lastBomb		: int;

	var lives			: int;
	var fl_shield		: bool;
	var shieldTimer		: float;
	var oxygen			: float;

	var fl_knock		: bool;
	var knockTimer		: float;

	var extendList		: Array<bool> ;
	var extendOrder		: Array<int>;

	var pid				: int ;

	var debugInput		: String ;

	var shieldMC		: Animation;

	var startX			: float ;
	var extraLifeCurrent: int;

	var edgeTimer		: float;
	var waitTimer		: float;

	var fl_chourou		: bool;
	var fl_carot		: bool;
	var fl_candle		: bool;
	var fl_torch		: bool;
	var head			: int;
	var defaultHead		: int;
	var bounceLimit		: int;

	var lockTimer		: float;

	var skin			: int;

	var recentKicks		: Array< {t:float, bid:int} >;





	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		name			= "$Igor".substring(1);

		baseWalkAnim	= Data.ANIM_PLAYER_WALK;
		baseStopAnim	= Data.ANIM_PLAYER_STOP;
		score			= 0;
		dir				= 1;
		speedFactor		= 1.0;
		fallFactor		= 1.1;
		extraLifeCurrent= 0;
		fl_teleport		= true;
		fl_portal		= true;
		fl_wind			= true;
		fl_strictGravity= false;
		fl_bump			= true;

		fl_chourou		= false;
		fl_carot		= false;
		fl_candle		= false;
		defaultHead		= Data.HEAD_NORMAL;
		head			= defaultHead;

		fl_knock		= false;
		knockTimer		= 0;
		bounceLimit		= 2;
		skin			= 1;
		oxygen			= 100;

		recentKicks	= new Array();

		currentWeapon	= Data.WEAPON_B_CLASSIC;
		lastBomb		= 1;
		initialMaxBombs	= 1;
		if ( GameManager.CONFIG.hasFamily(100) ) {	initialMaxBombs++; }
		maxBombs		= initialMaxBombs;
		coolDown		= 0;
		lives			= 1;
		if ( GameManager.CONFIG.hasFamily(102) ) {	lives++; } // coeur 1
		if ( GameManager.CONFIG.hasFamily(103) ) {	lives++; } // coeur 2
		if ( GameManager.CONFIG.hasFamily(104) ) {	lives++; } // coeur 3
		if ( GameManager.CONFIG.hasFamily(105) ) {	lives++; } // ig'or
		if ( GameManager.CONFIG.hasFamily(108) ) {	lives++; } // carotte

		if ( GameManager.CONFIG.hasFamily(106) ) {	fl_candle = true; }
		if ( GameManager.CONFIG.hasFamily(107) ) {	fl_torch = true; }
		if ( GameManager.CONFIG.hasFamily(108) ) {	fl_carot = true; }

		baseColor		= Data.BASE_COLORS[0];
		darkColor		= Data.DARK_COLORS[0];
		fl_lockControls	= false;
		fl_entering		= false;
		extendList		= new Array();
		extendOrder		= new Array();

		pid = 0 ;

		edgeTimer	= 0;
		waitTimer	= 0;

		dbg_grid	= 11;
		debugInput	= "";

	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g) ;
		ctrl = new PlayerController(this) ;
		register(Data.PLAYER) ;

//		box = downcast(game.depthMan.attach("hammer_interf_player", Data.DP_TOP)) ;
//		box.init(this) ;

		specialMan = new SpecialManager(game, this) ;
		game.manager.logAction("$P:"+lives);
	}


	/*------------------------------------------------------------------------
	INITIALISATION: JOUEUR
	------------------------------------------------------------------------*/
	function initPlayer(g:mode.GameMode,x:float,y:float) {
		init(g) ;
		moveTo(x,y) ;
		if ( game.fl_nightmare ) {
			speedFactor = 1.3;
		}
		if ( game._name!="$time" && GameManager.CONFIG.hasOption(Data.OPT_BOOST) ) { // cadeau quete manettes
			speedFactor = 1.3;
			if ( game.fl_nightmare ) {
				speedFactor = 1.6;
			}
		}
		endUpdate() ;
	}


	/*------------------------------------------------------------------------
	TOUCHES DE DEBUG
	------------------------------------------------------------------------*/
	function getDebugControls() {
		// Dernière touche enfoncée
		if ( dbg_lastKey>0 && !Key.isDown(dbg_lastKey) ) {
			dbg_lastKey = 0 ;
		}


		// Saisie d'un nb sur le pavé num
		for (var i=0;i<10;i++) {
			if ( Key.isDown(96+i) && dbg_lastKey!=96+i ) {
				debugInput+=string(i) ;
				dbg_lastKey = 96+i ;
			}
		}
		if (debugInput.length>=3) {
			var n = Std.parseInt(debugInput,10) ;
			if ( Key.isDown(Key.CONTROL) ) {
				game.forcedGoto(n);
			}
			else {
				if ( Key.isDown(Key.ALT) ) {
					entity.item.ScoreItem.attach(game, x+dir*30,y, n,null) ;
				}
				else {
					entity.item.SpecialItem.attach(game, x+dir*30,y, n,null) ;
				}
			}
			debugInput = "" ;
		}
		if ( Key.isDown(Key.BACKSPACE) ) {
			debugInput="" ;
		}

		if ( debugInput.length>0 ) {
			var str = debugInput ;
			while ( str.length<3 ) {
				str+="$_".substring(1);
			}
			Log.print("INPUT: "+str) ;
			Log.print("(backspace to clear)");
		}

		// Niveau suivant "n"
		if ( Key.isDown(78) && dbg_lastKey!=78 ) {
			game.nextLevel() ;
			dbg_lastKey = 78 ;
		}

		// Se pêter de clés "k"
		if ( Key.isDown(75) && dbg_lastKey!=75 ) {
			for (var i=0;i<50;i++) {
				game.giveKey(i);
			}
			dbg_lastKey = 75;
		}

		// Spawn d'item "i"
		if ( Key.isDown(73) && dbg_lastKey!=73 ) {
			entity.item.SpecialItem.attach(
				game,
				Std.random(200)+200,
				20,
				game.randMan.draw(Data.RAND_ITEMS_ID),
				0
			);
			dbg_lastKey = 73 ;
		}

		// Force les hurry-ups "/"
		if ( Key.isDown(111) && dbg_lastKey!=111 ) {
			game.huTimer=9999999 ;
			game.huState++ ;
			dbg_lastKey = 111;
		}

		// Anger more "+"
		if ( Key.isDown(107) && dbg_lastKey!=107 ) {
			var l = game.getBadList() ;
			for (var i=0;i<l.length;i++) {
				l[i].angerMore() ;
			}
			dbg_lastKey = 107 ;
		}

		// Anger more "-"
		if ( Key.isDown(109) && dbg_lastKey!=109 ) {
			var l = game.getBadList() ;
			for (var i=0;i<l.length;i++) {
				l[i].calmDown() ;
			}
			dbg_lastKey = 109 ;
		}

		// Affiche une grid de map "g"
		if ( Key.isDown(71) && dbg_lastKey!=71 ) {
			world.view.detachGrid() ;
			world.view.attachGrid( Math.round(Math.pow(2,dbg_grid)), true ) ;
			GameManager.warning("grid: "+Data.GRID_NAMES[dbg_grid]);
			dbg_grid++ ;
			if ( Data.GRID_NAMES[dbg_grid]==null ) {
				dbg_grid = 0;
			}
			dbg_lastKey = 71 ;
		}

		// Change d'arme "w"
		if ( Key.isDown(87) && dbg_lastKey!=87 ) {
			currentWeapon++ ;
			if ( currentWeapon>9 ) {
				currentWeapon=1;
			}
			changeWeapon(currentWeapon) ;
			dbg_lastKey = 87 ;
		}

		// Tue tous les bads "*"
		if ( Key.isDown(106) && dbg_lastKey!=106) {
			var l = game.getBadList() ;
			for (var i=0;i<l.length;i++) {
				l[i].destroy() ;
			}
			dbg_lastKey = 106 ;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var mc : entity.Player = downcast( g.depthMan.attach("hammer_player",Data.DP_PLAYER) ) ;
		mc.initPlayer(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	CONTACT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.ITEM) > 0 ) {
			var et : entity.Item = downcast(e) ;
			et.execute(this);
			if ( et.id==Data.CONVERT_DIAMANT ) { // perle
//				if ( specialMan.actives[81] || specialMan.actives[96] || specialMan.actives[97] || specialMan.actives[98] ) {
					specialMan.onPickPerfectItem();
//				}
			}
		}

	}


	/*------------------------------------------------------------------------
	TUE LE JOUEUR, SI POSSIBLE
	------------------------------------------------------------------------*/
	function forceKill(dx) {
		fl_shield = false ;
		killHit(dx) ;
	}


	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		if ( fl_kill || fl_shield ) {
			return ;
		}

		fl_knock = false;
//		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_shine");
		game.soundMan.playSound("sound_player_death", Data.CHAN_PLAYER);

		// recupère le signe de dx
		var sign = dx/Math.abs(dx);
		if ( Std.isNaN(sign) ) {
			sign = Std.random(2)*2-1;
		}

		if ( x>=0.85*Data.GAME_WIDTH ) {
			sign = -1;
		}
		if ( x<=0.15*Data.GAME_WIDTH ) {
			sign = 1;
		}

		playAnim(Data.ANIM_PLAYER_DIE) ;

		var power=20;
		if ( Timer.tmod<=0.6 ) {
			power=40;
		}

		super.killHit( sign*power ) ;
	}


	/*------------------------------------------------------------------------
	GAGNE DES POINTS
	------------------------------------------------------------------------*/
	function getScore(origin:Entity,value:int) {
		if ( origin != null ) {
			if ( specialMan.actives[95] ) { // effet sac à thunes
				game.fxMan.attachScorePop( baseColor, darkColor, origin.x, origin.y, ""+(value*2) );
			}
			else {
				game.fxMan.attachScorePop( baseColor, darkColor, origin.x, origin.y, ""+value );
			}
		}
		getScoreHidden(value);
	}

	function getScoreHidden(value:int) {
		if ( specialMan.actives[95] ) {
			value*=2;
		}
		var step = Data.EXTRA_LIFE_STEPS[extraLifeCurrent];
		if ( step!=null && score<step && score+value>=step ) {
			lives++;
			game.gi.setLives( pid, lives );
			game.manager.logAction("$EL"+extraLifeCurrent);
			extraLifeCurrent++;
		}
		if ( score!=0 && scoreCS^GameManager.KEY != score ) {
			game.manager.logIllegal("$SCS");
		}
		score+=value;
		scoreCS = score^GameManager.KEY;
		game.gi.setScore(pid,score);
	}


	/*------------------------------------------------------------------------
	GAGNE UNE LETTRE EXTEND
	------------------------------------------------------------------------*/
	function getExtend(id:int) {
		if ( extendList[id]!=true ) {
			game.gi.getExtend(pid,id);
		}

		// Perfect extend
		if ( !extendList[id] ) {
			extendOrder.push(id);
		}

		extendList[id] = true ;

		var complete = true ;
		for(var i=0;i<Data.EXTENDS.length;i++) {
			if ( extendList[i]!=true ) {
				complete = false ;
			}
		}

		// Terminé !
		if ( complete ) {
			var fl_perfect = true;
			for (var i=0;i<extendOrder.length;i++) {
				if ( extendOrder[i]!=i ) {
					fl_perfect = false;
				}
			}

			game.gi.clearExtends(pid);
			extendList = new Array();
			extendOrder = new Array();
			specialMan.executeExtend(fl_perfect);
		}
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function infix() {
		super.infix() ;

//		if ( fl_stable ) {
//			if ( world.checkFlag( {x:cx,y:cy}, Data.IA_TILE_TOP) ) {
//				downcast(game).tag(Data.TAG_PLAYER,cx,cy) ;
//			}
//		}

		// Changement d'arme
		var id = world.getCase( {x:cx,y:cy} ) ;
		if ( id>Data.FIELD_TELEPORT && id < 0 ) {
			if (currentWeapon!=int(Math.abs(id))) {
				var fx = game.fxMan.attachShine(x,y-Data.CASE_HEIGHT*0.5) ;
				fx.mc._xscale = 65 ;
				fx.mc._yscale = fx.mc._xscale ;
				game.soundMan.playSound("sound_field", Data.CHAN_FIELD);
			}
			changeWeapon(int(Math.abs(id))) ;
		}

		// Champ désarmement
		if ( id==Data.FIELD_PEACE ) {
			if (currentWeapon!=int(Math.abs(id))) {
				var fx = game.fxMan.attachShine(x,y-Data.CASE_HEIGHT*0.5) ;
				fx.mc._xscale = 65 ;
				fx.mc._yscale = fx.mc._xscale ;
				game.soundMan.playSound("sound_field", Data.CHAN_FIELD);
			}
			changeWeapon(Data.WEAPON_NONE);
		}


		if ( !fl_kill && !fl_destroy ) {
			game.world.scriptEngine.onEnterCase(cx,cy);
		}

		showTeleporters();
	}


	/*------------------------------------------------------------------------
	MORT DU JOUEUR
	------------------------------------------------------------------------*/
	function killPlayer() {
		// Strike fx
		game.fxMan.attachFx(  x, Data.GAME_HEIGHT, "hammer_fx_death_player"  );

		game.statsMan.inc(Data.STAT_DEATH,1) ;
		lives-- ;
		game.gi.setLives(pid,lives) ;
		if ( lives>=0 ) {
			resurrect() ;
		}
		else {
			// game over: il reste des vies chez un joueur  ?
			var fl_over = true;
			var l = game.getPlayerList();
			for (var i=0;i<l.length;i++) {
				if ( l[i].lives>=0 ) {
					fl_over = false;
				}
			}
			if ( !fl_over ) {
				// Partage de vies
				if ( GameManager.CONFIG.hasOption(Data.OPT_LIFE_SHARING) ) {
					var pl = game.getPlayerList();
					for (var i=0;i<pl.length;i++) {
						var p = pl[i];
						if ( p.uniqId!=uniqId && p.lives>0 ) {
							p.lives--;
							game.gi.setLives(p.pid,p.lives);
							resurrect();
							return;
						}
					}

				}
			}

			var pl = game.getPlayerList();
			for (var i=0;i<pl.length;i++) {
				game.registerScore(pl[i].pid, pl[i].score);
			}
			game.onGameOver();
//			game.fxMan.attachAlert( name+" "+Lang.get(43) );
			destroy() ;
		}
	}


	/*------------------------------------------------------------------------
	RÉSURRECTION
	------------------------------------------------------------------------*/
	function resurrect() {
		super.resurrect() ;
		game.manager.logAction("$R"+lives);
		// Joueur
		moveTo( Entity.x_ctr(world.current.$playerX), Entity.y_ctr(world.current.$playerY) ) ;
		dx = 0;
		dy = 0;
		shield(null);
		changeWeapon(1);
		oxygen = 100;
		fl_knock = false;

		// Effets actifs
		specialMan.clearTemp();
		specialMan.clearPerm();
		specialMan.clearRec();

		playAnim(Data.ANIM_PLAYER_RESURRECT);
		stickAnim();
		fl_lockControls = true;

		if ( game.fl_nightmare ) {
			speedFactor = 1.3;
		}
		if ( game._name!="$time" && GameManager.CONFIG.hasOption(Data.OPT_BOOST) ) { // cadeau quete manettes
			speedFactor = 1.3;
			if ( game.fl_nightmare ) {
				speedFactor = 1.6;
			}
		}

		game.onResurrect();

	}


	/*------------------------------------------------------------------------
	ACTIVE LE BOUCLIER
	------------------------------------------------------------------------*/
	function shield(duration:float) {
		if (duration==null) {
			duration = Data.SHIELD_DURATION ;
		}


		shieldMC.destroy();
		shieldMC = game.fxMan.attachFx(x,y,"hammer_player_shield");
		shieldMC.fl_loop = true;
		shieldMC.stopBlink();

		shieldTimer			= duration ;
		shieldMC.lifeTimer	= shieldTimer;
		fl_shield			= true ;
	}


	/*------------------------------------------------------------------------
	RETIRE LE BOUCLIER
	------------------------------------------------------------------------*/
	function unshield() {
		fl_shield	= false;
		shieldTimer	= 0;

		onShieldOut();
	}


	/*------------------------------------------------------------------------
	ASSOME LE JOUEUR
	------------------------------------------------------------------------*/
	function knock(d) {
		if ( fl_knock ) {
			return;
		}
		fl_lockControls = true;
		fl_knock = true;
		knockTimer = d;
	}


	/*------------------------------------------------------------------------
	AFFICHE/MASQUE LE JOUEUR
	------------------------------------------------------------------------*/
	function hide() {
		super.hide() ;
		shieldMC.mc._visible = false ;
	}
	function show() {
		super.show() ;
		shieldMC.mc._visible = true ;
	}


	/*------------------------------------------------------------------------
	REDIMENSIONNEMENT
	------------------------------------------------------------------------*/
	function scale(n) {
		super.scale(n);
		_xscale *= dir;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		game.registerScore(pid, score);
		specialMan.clearPerm() ;
		specialMan.clearTemp() ;
		specialMan.clearRec();
		super.destroy() ;
	}


	/*------------------------------------------------------------------------
	AFFICHE UNE "MALÉDICTION" AU DESSUS DU JOUEUR
	------------------------------------------------------------------------*/
	function curse(id:int) {
		var c = game.depthMan.attach("curse", Data.DP_FX);
		c._alpha = 70;
		c.gotoAndStop(""+id);
		stick(c,0,-Data.CASE_HEIGHT*2.5);
		setElaStick(0.25);
	}


	/*------------------------------------------------------------------------
	JOUE UNE ANIMATION
	------------------------------------------------------------------------*/
	function playAnim( a ) {
		if ( a.id==baseWalkAnim.id && speedFactor>1 ) {
			a = Data.ANIM_PLAYER_RUN;
		}

		if ( a.id==Data.ANIM_PLAYER_JUMP_DOWN.id && animId==Data.ANIM_PLAYER_AIRKICK.id ) {
			return;
		}

		if ( fl_knock ) {
			if ( a.id!=Data.ANIM_PLAYER_DIE.id && a.id!=Data.ANIM_PLAYER_KNOCK_IN.id ) {
				return;
			}
		}
		if ( animId==Data.ANIM_PLAYER_KICK.id && a.id==Data.ANIM_PLAYER_JUMP_DOWN.id ) {
			return;
		}

		if ( animId==Data.ANIM_PLAYER_CARROT.id ) {
			return;
		}

		super.playAnim( a );
	}


	/*------------------------------------------------------------------------
	CHANGE LES ANIMS DE DÉPLACEMENT DE BASE (null = pas de changement)
	------------------------------------------------------------------------*/
	function setBaseAnims( a_walk, a_stop ) {
		var fl_walk = false;
		var fl_stop = false;
		if ( animId == baseWalkAnim.id ) {
			fl_walk = true;
		}
		if ( animId == baseStopAnim.id ) {
			fl_stop = true;
		}
		if ( animId==Data.ANIM_PLAYER_WAIT1.id || animId==Data.ANIM_PLAYER_WAIT2.id ) {
			fl_stop = true;
		}

		if ( a_walk!=null ) {
			baseWalkAnim = a_walk;
		}
		if ( a_stop!=null ) {
			baseStopAnim = a_stop;
		}

		if ( fl_walk ) {
			playAnim(baseWalkAnim);
		}
		if ( fl_stop ) {
			playAnim(baseStopAnim);
		}
	}


	/*------------------------------------------------------------------------
	AUTORISE L'APPLICATION DU PATCH COLLISION AU SOL (ESCALIERS)
	------------------------------------------------------------------------*/
	function needsPatch() {
		return true;
	}


	/*------------------------------------------------------------------------
	ALLUME LES TÉLÉPORTEURS PROCHES DU JOUEUR
	------------------------------------------------------------------------*/
	function showTeleporters() {
		// Téléporteurs
		var tl = world.teleporterList;

		// Eteind tout
		for (var i=0;i<tl.length;i++) {
			world.hideField( tl[i] );
		}

		// Allume les téléporteurs proches
		for (var i=0;i<tl.length;i++) {
			var td = tl[i];
			var fl_close = false;
			if (td.dir==Data.VERTICAL) {
				if (  Math.abs(td.centerX-x)<=Data.TELEPORTER_DISTANCE && y>=td.startY-Data.CASE_HEIGHT*0.5 && y<=td.endY+Data.CASE_HEIGHT*0.5  ) {
					fl_close = true;
				}
			}
			else {
				if (  Math.abs(td.centerY-y)<=Data.TELEPORTER_DISTANCE && x>=td.startX-Data.CASE_WIDTH && x<=td.endX+Data.CASE_WIDTH  ) {
					fl_close = true;
				}
			}

			if ( fl_close ) {
				world.showField(td);
				var next = world.getNextTeleporter(td);
				if ( next!=null && !next.fl_rand ) {
					world.showField(next.td);
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	VERROUILLAGE DES CONTROLES POUR UNE DURÉE FIXE
	------------------------------------------------------------------------*/
	function lockControls(d:float) {
		lockTimer = d;
		playAnim(baseStopAnim);
		fl_lockControls = true;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LA BOMBE A ÉTÉ RÉCEMMENT KICKÉE PAR CE JOUEUR
	------------------------------------------------------------------------*/
	function isRecentKick(b:entity.Bomb) {
		var fl_recent = false;
		for (var i=0;i<recentKicks.length;i++) {
			if ( b.uniqId == recentKicks[i].bid ) {
				fl_recent = true;
			}
		}
		return fl_recent;
	}



	// *** ARMES

	/*------------------------------------------------------------------------
	POSE UNE BOMBE
	------------------------------------------------------------------------*/
	function attack():Entity {
		if ( specialMan.actives[91] || specialMan.actives[85] ) { // curse chapeau luffy
			return null;
		}

		switch (currentWeapon) {
			case Data.WEAPON_B_CLASSIC	: return drop(	entity.bomb.player.Classic.attach(game, x,y ) ) ; break;
			case Data.WEAPON_B_BLACK	: return drop(	entity.bomb.player.Black.attach(game, x,y ) ) ; break;
			case Data.WEAPON_B_BLUE		: return drop(	entity.bomb.player.Blue.attach(game, x,y ) ) ; break;
			case Data.WEAPON_B_GREEN	: return drop(	entity.bomb.player.Green.attach(game, x,y ) ) ; break;
			case Data.WEAPON_B_RED		: return drop(	entity.bomb.player.Red.attach(game, x,y ) ) ; break;
			case Data.WEAPON_B_REPEL	: return drop(	entity.bomb.player.RepelBomb.attach(game,x,y) ) ; break;

			case Data.WEAPON_S_ARROW	: return shoot(	entity.shoot.PlayerArrow.attach(game,x,y) ) ; break;
			case Data.WEAPON_S_FIRE		: return shoot(	entity.shoot.PlayerFireBall.attach(game,x,y) ) ; break;
			case Data.WEAPON_S_ICE		: return shoot(	entity.shoot.PlayerPearl.attach(game,x,y) ) ; break;

			default:
				GameManager.fatal("invalid weapon id : "+currentWeapon) ;
				return null ;
			break ;
		}
	}


	/*------------------------------------------------------------------------
	TESTE LE TYPE D'ARME ACTUEL
	------------------------------------------------------------------------*/
	function isBombWeapon(id) {
		return
			id == Data.WEAPON_B_CLASSIC ||
			id == Data.WEAPON_B_BLACK ||
			id == Data.WEAPON_B_BLUE ||
			id == Data.WEAPON_B_GREEN ||
			id == Data.WEAPON_B_RED ||
			id == Data.WEAPON_B_REPEL;
	}

	function isShootWeapon(id) {
		return
			id == Data.WEAPON_S_ARROW ||
			id == Data.WEAPON_S_FIRE ||
			id == Data.WEAPON_S_ICE;
	}


	/*------------------------------------------------------------------------
	POSE UNE BOMBE
	------------------------------------------------------------------------*/
	function drop(b:entity.bomb.PlayerBomb) {
		if ( !fl_stable ) {
			airJump();
		}
		game.statsMan.inc(Data.STAT_BOMB,1) ;
		b.setOwner(this);
		game.soundMan.playSound("sound_bomb_drop",Data.CHAN_PLAYER);
		if ( !fl_stable ) {
			kickBomb([upcast(b)], 1.0);
		}
//		b.x+=dir*Data.CASE_WIDTH*0.5;
//		if ( dir>0 ) {
////			b.moveToAng(-65,2);
//			b.moveRight(1.5);
//		}
//		else {
////			b.moveToAng(-115,2);
//			b.moveLeft(1.5);
//		}

		return b ;
	}


	/*------------------------------------------------------------------------
	SAUT SECONDAIRE EN L'AIR
	------------------------------------------------------------------------*/
	function airJump() {
		playAnim(Data.ANIM_PLAYER_JUMP_UP);
		if ( dy > 0) { // descendant
			dy=-Data.PLAYER_AIR_JUMP;
		}
		else { // ascendant
			if ( Math.abs(dy) < Data.PLAYER_AIR_JUMP ) {
				dy=-Data.PLAYER_AIR_JUMP;
			}
		}
	}


	/*------------------------------------------------------------------------
	TIR
	------------------------------------------------------------------------*/
	function shoot(s:entity.Shoot) {
		game.statsMan.inc(Data.STAT_SHOT,1) ;
		coolDown = s.coolDown ;
		if (dir<0) {
			s.moveLeft(s.shootSpeed) ;
		}
		else {
			s.moveRight(s.shootSpeed) ;
		}
		return s ;
	}

	/*------------------------------------------------------------------------
	DÉFINI L'ARME DU JOUEUR
	------------------------------------------------------------------------*/
	function changeWeapon(id:int) {
		if ( id==null ) {
			id = lastBomb;
		}

		// Pas une arme
		if ( id>0 && !isBombWeapon(id) && !isShootWeapon(id) ) {
			return;
		}

		// bombe -> tir
		if ( isBombWeapon(currentWeapon) && !isBombWeapon(id) ) {
			lastBomb = currentWeapon;
		}

		// ? -> bombe
		if ( isBombWeapon(id) ) {
			lastBomb = id;
		}

		currentWeapon = id ;
		replayAnim() ;
	}


	/*------------------------------------------------------------------------
	KICK UNE OU PLUSIEURS BOMBES
	------------------------------------------------------------------------*/
	function kickBomb(l:Array<entity.Bomb>, powerFactor:float) {
		var i=0 ;
		while ( i<l.length ) {
			var b = l[i] ;
			if ( !isRecentKick(b) ) {
				if (  ( b.fl_airKick || (!b.fl_airKick && b.fl_stable) ) && !b.fl_explode  )  {
					if ( !b.isType(Data.SOCCERBALL) ) {
						b.dx = dir * Data.PLAYER_HKICK_X;
					}
					else {
						b.dx = dir * Data.PLAYER_HKICK_X * powerFactor;
					}

					// Escalier Gauche
					if ( dir<0 && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) ) {
						var h = world.getWallHeight( cx-1,cy, Data.IA_CLIMB );
						if ( h<=1 ) {
							b.moveTo( b.x, b.y-Data.CASE_HEIGHT*0.5 );
						}
					}

					// Escalier Droite
					if ( dir>0 && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) ) {
						var h = world.getWallHeight( cx+1,cy, Data.IA_CLIMB );
						if ( h<=1 ) {
							b.moveTo( b.x, b.y-Data.CASE_HEIGHT*0.5 );
						}
					}

					if ( specialMan.actives[13] ) {
						b.dx*=2 ; // casque de moto
					}
					if ( game.fl_bombExpert && dx/b.dx>0 ) {
						b.dx*=2.5;
					}
					if ( specialMan.actives[115] ) {
						b.dx*=1.5; // casque volley
					}
					b.dy = -Data.PLAYER_HKICK_Y ;
					b.onKick(this);
					b.next = null;
					b.fl_bounce = true ;
					recentKicks.push( {t:game.cycle, bid:b.uniqId} );
	//				if ( fl_stable ) {
						playAnim(Data.ANIM_PLAYER_KICK);
	//				}
	//				else {
	//					playAnim(Data.ANIM_PLAYER_AIRKICK);
	//				}
					game.soundMan.playSound("sound_kick", Data.CHAN_PLAYER);
					game.statsMan.inc(Data.STAT_KICK,1) ;
					if ( specialMan.actives[92] ) { // chapeau rose
						if ( b.lifeTimer>0 ) {
							var b2 = b.duplicate();
							if ( b2.isType(Data.PLAYER_BOMB) ) {
								downcast(b2).owner = this;
							}
							b2.lifeTimer = b.lifeTimer ;
							b2.dx = -b.dx ;
							b2.dy = b.dy ;
							b2.fl_bounce = true ;
						}
					}
					if ( specialMan.actives[70] ) {// effet trefle
						getScore(this, 10) ;
					}
				}
			}
			i++ ;
		}
	}



	/*------------------------------------------------------------------------
	UP KICK
	------------------------------------------------------------------------*/
	function upKickBomb(l:Array<entity.Bomb>) {
		var i=0 ;
		while ( i<l.length ) {
			var b = l[i] ;
			if ( !isRecentKick(b) ) {
				if (  ( b.fl_airKick || (!b.fl_airKick && b.fl_stable) ) && !b.fl_explode  )  {
					b.dx *= 2;
					if ( Math.abs(b.dx)<= 1.5 ) {
						b.dx = 0.5*dir;
					}
					b.dy = -Data.PLAYER_VKICK;
					if ( specialMan.actives[13] ) {
						b.dy*=2 ; // casque de moto
					}
					if ( specialMan.actives[115] ) {
						b.dy*=2; // casque volley
						b.dx*=1.3;
					}
					b.next = null;
					b.onKick(this);
					b.fl_stable = false;
					b.fl_bounce = true;
					recentKicks.push( {t:game.cycle, bid:b.uniqId} );
					playAnim(Data.ANIM_PLAYER_KICK);
					game.soundMan.playSound("sound_kick", Data.CHAN_PLAYER);
					game.statsMan.inc(Data.STAT_KICK,1) ;
					if ( specialMan.actives[70] ) {// effet trefle
						getScore(this, 10) ;
					}
				}
			}
			i++ ;
		}
	}



	/*------------------------------------------------------------------------
	COMPTE LE NOMBRE DE BOMBES POSÉES
	------------------------------------------------------------------------*/
	function countBombs():int {
		var n = 0 ;
		var l = game.getList(Data.PLAYER_BOMB) ;
		for (var i=0;i<l.length;i++) {
			if ( !downcast(l[i]).fl_explode && l[i].parent == this ) {
				n++ ;
			}
		}
		return n ;
	}


	// *** EVENTS

	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id) ;

		// Se relève après un knock
		if ( id == Data.ANIM_PLAYER_KNOCK_OUT.id ) {
			fl_lockControls = false;
			playAnim(baseStopAnim);
		}

		if ( id == Data.ANIM_PLAYER_AIRKICK.id ) {
			animId = null;
			playAnim(Data.ANIM_PLAYER_JUMP_DOWN);
		}

		// Resurrection
		if ( id == Data.ANIM_PLAYER_RESURRECT.id ) {
			fl_lockControls = false;
			playAnim(baseStopAnim);
		}

		// Après un air kick
		if ( id == Data.ANIM_PLAYER_KICK.id && !fl_stable ) {
			animId = null;
			playAnim(Data.ANIM_PLAYER_JUMP_DOWN);
			return;
		}

		// Carotte!
		if ( id == Data.ANIM_PLAYER_CARROT.id ) {
			playAnim(baseStopAnim);
		}

		// Retour en anim normale après kick ou attack
		if ( id == Data.ANIM_PLAYER_KICK.id ||
			id == Data.ANIM_PLAYER_ATTACK.id ||
			id == Data.ANIM_PLAYER_WAIT1.id ||
			id == Data.ANIM_PLAYER_WAIT2.id ||
			id == Data.ANIM_PLAYER_JUMP_LAND.id ) {
				playAnim(baseStopAnim) ;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS ATTEINTE
	------------------------------------------------------------------------*/
	function onDeathLine() {
		super.onDeathLine() ;

		if ( fl_kill ) {
			killPlayer() ;
		}
		else {
			if ( game.checkLevelClear() ) {
				// Passage au level suivant
				dy = 0 ;
				game.nextLevel() ;
			}
			else {
				// Mort
				y = Data.LEVEL_HEIGHT*Data.CASE_HEIGHT-Data.CASE_HEIGHT-1 ;
				dx = 0;
				forceKill(0) ;
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE BOUCLIER
	------------------------------------------------------------------------*/
	function onShieldOut() {
		game.fxMan.attachFx(x,y,"popShield");
		shieldMC.destroy();
		checkHits();
	}

	/*------------------------------------------------------------------------
	EVENT: FIN DE KNOCK
	------------------------------------------------------------------------*/
	function onWakeUp() {
		fl_knock = false;
		if ( fl_stable ) {
			dx = 0;
			playAnim(Data.ANIM_PLAYER_KNOCK_OUT);
		}
		else {
			fl_lockControls = false;
			playAnim(Data.ANIM_PLAYER_JUMP_DOWN);
		}
	}



	/*------------------------------------------------------------------------
	EVENT: TÉLÉPORTATION
	------------------------------------------------------------------------*/
	function onTeleport() {
		super.onTeleport() ;
		dx = 0 ;
		dy = 0 ;
		if ( shieldMC!=null ) {
			shieldMC.mc._x = x;
			shieldMC.mc._y = y;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: CHANGEMENT DE LEVEL
	------------------------------------------------------------------------*/
	function onNextLevel() {
		changeWeapon(1) ;
		if ( fl_shield ) {
			shieldTimer = 1 ;
		}
		specialMan.clearTemp() ;
		specialMan.clearRec();
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		// Effet goldorak
		if ( specialMan.actives[90] ) {
			if ( !fl_knock && h>=Data.CASE_HEIGHT*2) {
				knock(Data.SECOND);
			}
		}

		super.onHitGround(h) ;

		// Hauteur de chute
		if ( h >= Data.DUST_FALL_HEIGHT ) {
			game.fxMan.dust(cx,cy+1);
		}
		game.fxMan.attachFx(x,y,"hammer_fx_fall");

		game.soundMan.playSound("sound_land",Data.CHAN_PLAYER);

		// Effet stonehead
		if ( specialMan.actives[39] ) {
			game.shake(10,2) ;
			var l = game.getBadClearList() ;
			for (var i=0;i<l.length;i++) {
				l[i].knock(Data.SECOND) ;
			}
		}

		showTeleporters();
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( fl_knock ) {
			dx = -dx*0.5;
			// Gros choc
			if ( Math.abs(dx)>=10 && world.getCase( {x:cx,y:cy} )<=0 ) {
				game.shake(Data.SECOND*0.7, 5);
				game.fxMan.inGameParticlesDir(Data.PARTICLE_STONE, x,y, 1+Std.random(3), dx);
				game.fxMan.inGameParticlesDir(Data.PARTICLE_CLASSIC_BOMB, x,y, 3+Std.random(5), dx);
			}
		}
		else {
			super.onHitWall();
		}
	}


	/*------------------------------------------------------------------------
	EVENT: DÉBUT DE NIVEAU
	------------------------------------------------------------------------*/
	function onStartLevel() {
		this.show() ;
		game.manager.logAction(world.currentId+","+Math.floor(score/1000));
		if ( game.world.fl_mainWorld ) {
			game.gi.setLevel(game.world.currentId);
		}
		else {
			if ( game.fakeLevelId==null ) {
				game.gi.hideLevel();
			}
			else {
				game.gi.setLevel(game.fakeLevelId);
			}
		}
		if ( fl_shield && shieldMC==null ) {
			shield(shieldTimer);
		}
		startX = x ;
		fl_entering = true;
	}


	/*------------------------------------------------------------------------
	EVENT: PORTAL WARP
	------------------------------------------------------------------------*/
	function onPortal(pid) {
		super.onPortal(pid);

		if ( !game.usePortal(pid, this) ) {
			onPortalRefusal();
		}
	}


	/*------------------------------------------------------------------------
	EVENT: PORTAIL FERMÉ
	------------------------------------------------------------------------*/
	function onPortalRefusal() {
		super.onPortalRefusal();
		x = oldX;
		y = oldY;
		dx = -dx;
		knock(Data.SECOND*0.5);
		game.fxMan.inGameParticles( Data.PARTICLE_PORTAL, x,y, Std.random(5)+5 );
		game.shake(Data.SECOND,3);
		fl_stopStepping = true;
	}


	function onBump() {
		super.onBump();
		fl_knock = false;
		knock(Data.SECOND*0.7);
	}



	// *** UPDATES

	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {

		super.endUpdate() ;

		if ( shieldMC!=null ) {
			if ( shieldTimer<=Data.SECOND*3 ) {
				shieldMC.blink();
			}
			shieldMC.mc._x	= shieldMC.mc._x + (this.x - shieldMC.mc._x)*0.75;
			shieldMC.mc._y	= shieldMC.mc._y + (this.y-20 - shieldMC.mc._y)*0.75;
		}

		this._xscale = dir*Math.abs(this._xscale) ;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Gestion des kicks
		for (var i=0;i<recentKicks.length;i++) {

			if ( game.cycle-recentKicks[i].t > 2 ) {
				recentKicks.splice(i,1);
				i--;
			}
		}

		// Poupée Guu
		if ( specialMan.actives[100] ) {
			game.fxMan.inGameParticles( Data.PARTICLE_RAIN, x + Std.random(20)*(Std.random(2)*2-1), y-60-Std.random(5), Std.random(2)+1 );
			scale( Math.min(100, (scaleFactor+0.002*Timer.tmod)*100) );
			if ( scaleFactor<=0.60 ) {
				killHit(null);
				specialMan.interrupt(100);
			}
		}


		// Oxygène
		if ( !fl_kill && game.fl_aqua ) {
			oxygen -= Timer.tmod*0.1;
			game.manager.progress(oxygen/100);
			if ( oxygen<=0 ) {
				killHit(0);
			}
		}


		// Effets spéciaux d'items
		specialMan.main() ;

		// Déplacement
		if ( !fl_kill && !fl_lockControls ) {
			if ( !fl_entering && _visible ) {
				ctrl.update() ;
			}
			if ( pid==0 && game.manager.fl_debug ) {
				getDebugControls() ;
			}
		}
		if ( fl_entering ) {
			if ( cy >= 0 ) {
				fl_entering = false;
			}
		}

		// Refroidissement du tir
		if ( coolDown>0 ) {
			coolDown-=Timer.tmod ;
			if ( coolDown<=0 ) {
				coolDown=0 ;
			}
		}

		// Sonné
		if ( fl_knock ) {
			knockTimer-=Timer.tmod;
			if ( knockTimer<=0 ) {
				onWakeUp();
			} else {
				if ( fl_stable && animId!=Data.ANIM_PLAYER_KNOCK_IN.id ) {
					playAnim(Data.ANIM_PLAYER_KNOCK_IN);
				}
				if ( !fl_stable && animId!=Data.ANIM_PLAYER_DIE.id ) {
					playAnim(Data.ANIM_PLAYER_DIE);
				}
			}
		}


		// Gestion de verrou de contrôles
		if ( fl_lockControls ) {
			if ( fl_stable && animId==baseStopAnim.id ) {
				fl_lockControls = false;
			}
		}

		if ( lockTimer>0 ) {
			lockTimer-=Timer.tmod;
			if ( lockTimer<=0 ) {
				fl_lockControls = false;
			}
			else {
				fl_lockControls = true;
			}
		}

		// Bouclier
		if ( fl_shield ) {
			shieldTimer-=Timer.tmod;
			if ( shieldTimer<=0 ) {
				unshield();
			}
		}


		// MàJ
		super.update() ;
		updateCoords() ;

		// RaZ des compteurs de glandage
		if ( dx!=0 || dy!=0 ) {
			edgeTimer = 0;
			waitTimer = 0;
		}

		if ( !fl_kill ) {
			// Animation de saut
			if ( !fl_stable && dy>=0 && animId!=Data.ANIM_PLAYER_JUMP_DOWN.id && !fl_lockControls ) {
				playAnim(Data.ANIM_PLAYER_JUMP_DOWN);
			}
			if ( animId == Data.ANIM_PLAYER_JUMP_DOWN.id && fl_stable ) {
				playAnim(Data.ANIM_PLAYER_JUMP_LAND);
			}

			// Anim d'attente
			if ( animId==Data.ANIM_PLAYER_STOP.id ) {
				if ( waitTimer<=0 ) {
					waitTimer = Data.WAIT_TIMER;
				}
				waitTimer-=Timer.tmod;
				if ( waitTimer<=0 ) {
					if ( Std.random(20)==0 ) {
						playAnim(Data.ANIM_PLAYER_WAIT1);
					}
					else {
						playAnim(Data.ANIM_PLAYER_WAIT2);
					}
				}
			}


			// Anim au bord du vide
			if ( fl_stable && dx==0 ) {
				if ( animId==baseStopAnim.id ) {
					var pt = Entity.rtc( x+dir*Data.CASE_WIDTH*0.3, y+Data.CASE_HEIGHT );
					if (  world.getCase(pt)<=0  &&  world.getCase( {x:cx+dir,y:cy} )==0  ) {
						if ( edgeTimer<=0 ) {
							edgeTimer = Data.EDGE_TIMER;
						}
						edgeTimer-=Timer.tmod;
						if ( edgeTimer<=0 ) {
							playAnim(Data.ANIM_PLAYER_EDGE);
						}
					}
				}
			}
		}

	}

}


