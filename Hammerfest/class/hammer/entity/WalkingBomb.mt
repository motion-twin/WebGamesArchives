class entity.WalkingBomb extends entity.Physics
{
	var left			: int;
	var right			: int;

	var fl_knock		: bool;
	var knockTimer		: float;
	var realBomb		: entity.bomb.PlayerBomb;
	var fl_unstable		: bool; // comportement bombe verte

	var dir				: int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();

		left	= Key.PGUP;
		right	= Key.PGDN;
		dir		= 1;

		fl_slide		= false;
		fl_teleport		= true;
		fl_wind			= true;
		fl_blink		= false;
		fl_portal		= true;
		fl_unstable		= false;

		fl_knock		= false;
	}

	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode, b:entity.bomb.PlayerBomb) {
		var linkage = "hammer_player_wbomb" ;
		var mc : entity.WalkingBomb = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) ) ;
		mc.initBomb(g, b) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initBomb(g, b) {
		init(g);
		register(Data.BOMB);

		realBomb = b;
		moveTo(realBomb.x, realBomb.y);
		setLifeTimer(b.lifeTimer);
		dx = realBomb.dx;
		dy = realBomb.dy;
		fl_unstable = realBomb.fl_unstable;

		updateCoords();
		playAnim( Data.ANIM_WBOMB_STOP );
	}


	/*------------------------------------------------------------------------
	AUTORISE L'APPLICATION DU PATCH COLLISION AU SOL (ESCALIERS)
	------------------------------------------------------------------------*/
	function needsPatch() {
		return true;
	}


	/*------------------------------------------------------------------------
	DÉTRUIT LA WALKING ET LA BOMBE RÉELLE
	------------------------------------------------------------------------*/
	function destroyBoth() {
		realBomb.destroy();
		destroy();
	}


	/*------------------------------------------------------------------------
	CONTACT
	------------------------------------------------------------------------*/
	function hit(e) {
		super.hit(e);
		if ( fl_unstable && (e.types&Data.BAD)>0 ) {
			onExplode() ;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		super.onDeathLine();
		destroyBoth();
	}


	/*------------------------------------------------------------------------
	EVENT: KICKÉE
	------------------------------------------------------------------------*/
	function onKick(p:entity.Player) {
		fl_stable = false;
	}


	/*------------------------------------------------------------------------
	EVENT: PORTAL
	------------------------------------------------------------------------*/
	function onPortal(pid) {
		super.onPortal(pid);
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT*0.5,"hammer_fx_shine");
		destroyBoth();
	}

	/*------------------------------------------------------------------------
	EVENT: PORTAL FERMÉ
	------------------------------------------------------------------------*/
	function onPortalRefusal() {
		super.onPortalRefusal();
		knock(Data.SECOND);
		dx = -dx*3;
		dy = -5;
		game.fxMan.inGameParticles( Data.PARTICLE_PORTAL, x,y,5 );
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE TIMER DE VIE
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		onExplode();
		super.onLifeTimer();
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		realBomb.moveTo(x,y);
		realBomb.updateCoords();
		realBomb.onExplode();
		destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		if ( fl_unstable && h>=10) {
			onExplode();
		}
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( fl_stable ) {
			// gauche
			if ( Key.isDown(left) && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) ) {
				var h = world.getWallHeight( cx-1,cy, Data.IA_CLIMB );
				if ( h<=1 ) {
					jump( Data.BAD_VJUMP_X_CLIFF, Data.BAD_VJUMP_Y_LIST[0] );
					centerInCase();
				}
			}
			// droite
			if ( Key.isDown(right) && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) ) {
				var h = world.getWallHeight( cx+1,cy, Data.IA_CLIMB );
				if ( h<=1 ) {
					jump( Data.BAD_VJUMP_X_CLIFF, Data.BAD_VJUMP_Y_LIST[0] );
					centerInCase();
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	CONTRÔLES
	------------------------------------------------------------------------*/
	function getControls() {
		// *** Gauche
		if ( Key.isDown(left) ) {
			dx=-Data.WBOMB_SPEED;
			dir = -1;
			if ( fl_stable ) {
				playAnim(Data.ANIM_WBOMB_WALK);
			}
		}

		// *** Droite
		if ( Key.isDown(right) ) {
			dx=Data.WBOMB_SPEED;
			dir = 1;
			if ( fl_stable ) {
				playAnim(Data.ANIM_WBOMB_WALK);
			}
		}

		// Anim d'arrêt
		if ( !Key.isDown(left) && !Key.isDown(right) ) {
			dx*=game.gFriction*0.9;
			if ( animId==Data.ANIM_WBOMB_WALK.id ) {
				playAnim(Data.ANIM_WBOMB_STOP);
			}
		}
	}


	/*------------------------------------------------------------------------
	ASSOME LA BOMBE
	------------------------------------------------------------------------*/
	function knock(d) {
		fl_knock = true;
		knockTimer = d;
		playAnim(Data.ANIM_WBOMB_STOP);
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();
		this._xscale = dir*Math.abs(this._xscale) ;
	}


	/*------------------------------------------------------------------------
	INFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();

		// Auto jump horizontal
		if ( fl_stable ) {
			// gauche
			if ( world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_LEFT) && dx<0 ) {
				jump(Data.BAD_HJUMP_X, Data.BAD_HJUMP_Y);
//				adjustToRight();
			}
			// droite
			if ( world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_RIGHT) && dx>0 ) {
				jump(Data.BAD_HJUMP_X, Data.BAD_HJUMP_Y);
//				adjustToLeft();
			}
		}

	}


	/*------------------------------------------------------------------------
	VÉRIFIE SI UN ESCALIER EST PRÉSENT ET S'IL PEUT ÊTRE MONTÉ
	------------------------------------------------------------------------*/
	function checkClimb() {
	}


	/*------------------------------------------------------------------------
	SAUT !
	------------------------------------------------------------------------*/
	function jump(jx,jy) {
		dx = dir*jx;
		dy = -jy;
		fl_stable = false;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Inhibe la bombe réelle
		realBomb.y = -1500;
		realBomb.lifeTimer = Data.SECOND*10;

		if ( fl_knock && knockTimer>0 ) {
			knockTimer-=Timer.tmod;
			if ( knockTimer<=0 ) {
				fl_knock = false;
			}
		}

		if ( fl_stable && !fl_knock ) {
			getControls();
		}
		else {
			if ( animId==Data.ANIM_WBOMB_WALK.id ) {
				playAnim(Data.ANIM_WBOMB_STOP);
			}
		}

		super.update();

		if ( realBomb._name==null ) {
			destroy();
		}
	}

}



