class entity.bad.walker.Bombe extends entity.bad.Jumper
{
	static var RADIUS			= Data.CASE_WIDTH*5;
	static var EXPERT_RADIUS	= Data.CASE_WIDTH*8;
	static var POWER			= 30;

	var fl_overheat	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpUp(10) ;
		setJumpDown(6) ;
		setJumpH(100) ;
		setClimb(100,3);
//		setFall(50);
		fl_alphaBlink	= false;
		fl_overheat		= false;
		blinkColor		= 0xff9e5e;
		blinkColorAlpha	= 50;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		if ( game.fl_bombExpert ) {
			RADIUS = EXPERT_RADIUS;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_BOMBE];
		var mc : entity.bad.walker.Bombe = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	LOOP SUR L'ANIM DE RÉFLEXION
	------------------------------------------------------------------------*/
	function playAnim(obj) {
		if (fl_overheat ) {
			return;
		}
		super.playAnim(obj) ;
		if ( obj.id == Data.ANIM_BAD_THINK.id ) {
			fl_loop = true ;
		}
		if ( obj.id == Data.ANIM_BAD_JUMP.id ) {
			fl_loop = false ;
		}
	}


	/*------------------------------------------------------------------------
	DÉCLENCHEMENT EXPLOSION
	------------------------------------------------------------------------*/
	function trigger() {
		if ( fl_overheat ) {
			return;
		}
		halt();

		playAnim(Data.ANIM_BAD_DIE)
		fl_loop = false;
		fl_freeze = false;
//		fl_anim=false;

		var duration = Data.SECOND * ( 0.25 + (Std.random(10)/100) * (Std.random(2)*2-1) )
		setLifeTimer(Data.SECOND*3);
		updateLifeTimer(Data.SECOND);
		setNext(null,null,Data.SECOND*3,Data.ACTION_WALK);
		fl_overheat = true;
	}


	/*------------------------------------------------------------------------
	KAMIKAZE!!
	------------------------------------------------------------------------*/
	function selfDestruct() {
		// Onde de choc
		game.fxMan.attachExplodeZone(x,y,RADIUS) ;

		var l = game.getClose(Data.PLAYER,x,y,RADIUS,false) ;

		for (var i=0;i<l.length;i++) {
			var e : entity.Player = downcast(l[i]) ;
			e.killHit(0) ;
			shockWave( e, RADIUS, POWER ) ;
			if ( !e.fl_shield ) {
				e.dy = -10-Std.random(20) ;
			}
		}
		game.soundMan.playSound("sound_bomb_black", Data.CHAN_BOMB);

		// Item
		dropReward();

		game.fxMan.inGameParticles( Data.PARTICLE_METAL, x,y, Std.random(4)+5 );
		game.fxMan.inGameParticles( Data.PARTICLE_SPARK, x,y, Std.random(4) );
		onKill();
		destroy();
	}


	/*------------------------------------------------------------------------
	MORT DU BAD
	------------------------------------------------------------------------*/
	function killHit(dx) {
		trigger();
	}


	/*------------------------------------------------------------------------
	EVENT: FREEZE
	------------------------------------------------------------------------*/
	function onFreeze() {
		trigger() ;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE MONSTRE EST EN ÉTAT DE "JOUER"
	------------------------------------------------------------------------*/
	function isHealthy() {
		return !fl_overheat && super.isHealthy();
	}


	/*------------------------------------------------------------------------
	FIN DE TIMER DE VIE
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		selfDestruct();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function prefix() {
		if ( !fl_stable && fl_overheat ) {
			dx = 0;
		}
		super.prefix();
	}

}

