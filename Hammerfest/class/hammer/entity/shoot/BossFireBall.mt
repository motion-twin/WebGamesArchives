class entity.shoot.BossFireBall extends entity.Shoot
{
	var maxDist		: float;

	var bat			: entity.boss.Bat;
	var ang			: float;	// angle radians
	var dist		: float;

	var distSpeed	: float;
	var turnSpeed	: float;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_checkBounds	= false;
		fl_largeTrigger	= true;
		turnSpeed		= 0.025;
		distSpeed		= 2;
		dist			= Data.CASE_WIDTH*0.2;
		maxDist			= Data.CASE_WIDTH*5;
		disablePhysics();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		playAnim(Data.ANIM_SHOOT_LOOP) ;
	}


	/*------------------------------------------------------------------------
	INITIALISE LE TIR SPÉCIFIQUEMENT AU BOSS
	------------------------------------------------------------------------*/
	function initBossShoot( b, a ) { // angle en degré
		bat		= b;
		ang		= a*Math.PI/180;

		center();
	}


	/*------------------------------------------------------------------------
	PLACE LA FIREBALL AUTOUR DU BOSS
	------------------------------------------------------------------------*/
	function center() {
		moveTo(
			bat.x + Math.cos(ang)*dist,
			bat.y + Math.sin(ang)*dist
		);
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_boss_fireball" ;
		var s : entity.shoot.BossFireBall = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y-10) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		game.fxMan.attachExplodeZone(x,y,Data.CASE_WIDTH*2);
		super.destroy() ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.BOMB) > 0 ) {
			var et : entity.Bomb = downcast(e) ;
			if ( !et.fl_explode ) {
				game.fxMan.attachFx(et.x,et.y-Data.CASE_HEIGHT,"hammer_fx_pop")
				et.destroy();
				game.fxMan.inGameParticles(Data.PARTICLE_CLASSIC_BOMB, x,y,6);

				destroy();
				return;
			}
		}
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et : entity.Player = downcast(e) ;
			et.killHit(dx) ;
		}
	}


	/*------------------------------------------------------------------------
	PRÉFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		var ocx = cx;
		var ocy = cy;
		ang		+= Timer.tmod * turnSpeed;
		dist	+= Timer.tmod * distSpeed;
		dist	= Math.min( dist, maxDist );
		center();
		if ( ocx!=cx || ocy!=cy ) {
			checkHits();
		}
	}

}
