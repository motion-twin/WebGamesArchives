class entity.Shoot extends entity.Physics
{
	var shootSpeed		: float ;
	var shootY			: float ;
	var coolDown 		: float ;
	var fl_borderBounce	: bool ;
	var fl_checkBounds	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		// Physics
		fl_hitWall		= false ;
		fl_hitBorder	= false ;
		fl_hitGround	= false ;
		fl_gravity		= false ;
		fl_friction		= false ;
		fl_borderBounce	= false ;
		fl_checkBounds	= true;
		fl_bump			= false;
		coolDown = 50 ;
	}

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		register(Data.SHOOT) ;
		setSub(this) ;
		playAnim(Data.ANIM_SHOOT) ;
	}

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initShoot(g:mode.GameMode, x:float,y:float) {
		init(g) ;
		moveTo(x,y) ;
		endUpdate() ;
	}


	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		// Flip horizontal
		if ( dy==0 ) {
			if ( dx<0 ) {
				_xscale = -Math.abs(_xscale) ;
			}
			else {
				_xscale = Math.abs(_xscale) ;
			}
		}

		super.endUpdate();
	}



	/*------------------------------------------------------------------------
	EVENT: REBOND AUX BORDS
	------------------------------------------------------------------------*/
	function onSideBorderBounce() {
		// do nothing
	}

	function onHorizontalBorderBounce() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update() ;

		// Hors-jeu
		if ( fl_checkBounds ) {
			if ( fl_borderBounce ) {
				// Rebonds aux bords du jeu
				if ( x<0 ) {
					onSideBorderBounce();
					dx = Math.abs(dx) ;
				}
				if ( x>=Data.GAME_WIDTH ) {
					onSideBorderBounce();
					dx = -Math.abs(dx) ;
				}

				if ( y<0 ) {
					onHorizontalBorderBounce();
					dy = Math.abs(dy) ;
				}
				if ( y>=Data.GAME_HEIGHT ) {
					onHorizontalBorderBounce();
					dy = -Math.abs(dy) ;
				}
			}
			else {
				// Destruction
				if ( !world.inBound(cx,cy) ) {
					destroy() ;
				}
			}
		}

	}

}

