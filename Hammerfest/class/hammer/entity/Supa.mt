class entity.Supa extends entity.Mover
{

	var radius : float;
	var speed : float;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_hitGround	= false;
		fl_hitWall		= false;
		fl_gravity		= false;
		fl_friction		= false;
		fl_hitBorder	= false;
		fl_alphaBlink	= false;
		blinkColorAlpha	= 80;

		minAlpha = 0;

		speed = 0;
		radius = 0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g);
		register(Data.SUPA);

		disableAnimator();
	}

	/*------------------------------------------------------------------------
	INITIALISATION SUPA POWA
	------------------------------------------------------------------------*/
	function initSupa(g:mode.GameMode,x,y) {
		init(g);
		moveTo(x,y);
		endUpdate();
	}

	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function infix() {
		// no super
	}


	/*------------------------------------------------------------------------
	DÉSACTIVATION DE LA GESTION PAR TRIGGER
	------------------------------------------------------------------------*/
	function tAdd(cx:int,cy:int) {
		// do nothing
	}
	function tRem(cx:int,cy:int) {
		// do nothing
	}

}


