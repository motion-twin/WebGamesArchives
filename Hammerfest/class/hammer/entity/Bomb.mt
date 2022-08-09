class entity.Bomb extends entity.Mover
{

	var radius		: float;
	var power		: float;
	var duration	: float;

	var fl_explode	: bool;
	var fl_airKick	: bool;
	var fl_bumped	: bool;

	var explodeSound: String;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();

		explodeSound	 = "sound_bomb";

		radius		= Data.CASE_WIDTH*3;
		power		= 0;
		duration	= 0;

		fl_slide	= false;
		fl_bounce	= false;
		fl_teleport = true;
		fl_wind		= true;
		fl_blink	= false;
		fl_explode	= false;
		fl_airKick	= false;
		fl_portal	= true;
		fl_bump		= true;
		fl_bumped	= false; // true si a passé un bumper au - une fois
		fl_strictGravity	= false;
		slideFriction		= 0.98;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initBomb(g, x,y ) {
		init(g);
		register(Data.BOMB);
		moveTo(x,y);
		setLifeTimer(duration);
		updateCoords();
		playAnim( Data.ANIM_BOMB_DROP );
	}


	/*------------------------------------------------------------------------
	AUTORISE L'APPLICATION DU PATCH COLLISION AU SOL (ESCALIERS)
	------------------------------------------------------------------------*/
	function needsPatch() {
		return true;
	}



	/*------------------------------------------------------------------------
	RENVOIE LES ENTITÉS AFFECTÉES PAR LA BOMBE
	------------------------------------------------------------------------*/
	function bombGetClose(type:int):Array<Entity> {
		return game.getClose(type, x,y, radius, fl_stable);
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		playAnim( Data.ANIM_BOMB_EXPLODE );
		if ( explodeSound!=null ) {
			game.soundMan.playSound(explodeSound,Data.CHAN_BOMB);
		}
		rotation = 0;
		fl_physics = false;
		fl_explode = true;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);
		if ( id==Data.ANIM_BOMB_DROP.id ) {
			playAnim(Data.ANIM_BOMB_LOOP);
		}
		if ( id==Data.ANIM_BOMB_EXPLODE.id ) {
			destroy();
		}
	}


	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( !fl_stable ) {
			var ang = 30;
			if ( dx>0 ) {
				rotation += 0.02*(ang-rotation);
			}
			else {
				rotation -= 0.02*(ang-rotation);
			}
			rotation = Math.max(-ang,Math.min(ang,rotation));
		}
		super.endUpdate();
	}


	/*------------------------------------------------------------------------
	EVENT: TIMER DE VIE
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		stopBlink();
		onExplode();
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		super.onDeathLine();
		destroy();
	}

	function onKick(p:entity.Player) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( fl_bumped ) {
			dx = -dx*0.7;
		}
		else {
			super.onHitWall();
		}
	}


	/*------------------------------------------------------------------------
	EVENT: PORTAL
	------------------------------------------------------------------------*/
	function onPortal(pid) {
		super.onPortal(pid);
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT*0.5,"hammer_fx_shine");
		destroy();
	}

	/*------------------------------------------------------------------------
	EVENT: PORTAL FERMÉ
	------------------------------------------------------------------------*/
	function onPortalRefusal() {
		super.onPortalRefusal();
		dx = -dx*3;
		dy = -5;
		game.fxMan.inGameParticles( Data.PARTICLE_PORTAL, x,y,5 );
	}


	/*------------------------------------------------------------------------
	EVENT: BUMPER
	------------------------------------------------------------------------*/
	function onBump() {
		fl_bumped = true;
	}


	/*------------------------------------------------------------------------
	DUPLIQUE LA BOMBE EN COURS
	------------------------------------------------------------------------*/
	function duplicate():entity.Bomb {
		return null ; // do nothing
	}

}

