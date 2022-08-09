class entity.shoot.Ball extends entity.Shoot
{

	var targetCatcher : Entity;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		shootSpeed = 8.5;
		_yOffset = 0;
		setLifeTimer(Data.BALL_TIMEOUT);
		fl_alphaBlink = false;
		fl_borderBounce = true;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.BALL);
	}



	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_ball";
		var s : entity.shoot.Ball = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) );
		s.initShoot(g, x, y);
		return s;
	}


	/*------------------------------------------------------------------------
	EVENT: TIMER DE VIE ATTEINT (et pas catché, à priori)
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		// Ré-attribution d'une balle perdue
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT/2, "hammer_fx_pop");

		var bad : entity.bad.walker.Fraise = downcast(game.getOne(Data.CATCHER));
		bad.assignBall();

		super.onLifeTimer();
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et : entity.Player = downcast(e);
			et.killHit(dx);
		}
		if ( (e.types & Data.CATCHER) > 0 && targetCatcher==downcast(e) ) {
			downcast(e).catchBall(this);
		}
	}
}
