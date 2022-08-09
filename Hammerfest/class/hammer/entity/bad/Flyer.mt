class entity.bad.Flyer extends entity.Bad
{

	var xSpeed			: float ;
	var ySpeed			: float ;
	var fl_fly			: bool ;
	var fl_intercept	: bool; // true si gelé en plein vol
	var speed			: float ;
	var dir				: float ;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		speed = 4 ;
		angerFactor = 0.5;
		// attention changement: contenu déplacé dans init()
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		xSpeed = Math.cos(Math.PI*0.25)*speed ;
		ySpeed = Math.sin(Math.PI*0.25)*speed ;
		if ( game.fl_static ) {
			dir = -1;
		}
		else {
			dir = (Std.random(2)*2-1);
		}
		fly() ;
	}


	/*------------------------------------------------------------------------
	ENVOL
	------------------------------------------------------------------------*/
	function fly() {
		if ( !isHealthy() ) {
			return ;
		}

		if ( anger>0 ) {
			playAnim(Data.ANIM_BAD_ANGER);
		}
		else {
			playAnim(Data.ANIM_BAD_WALK);
		}

		dx = dir*xSpeed*speedFactor ;
		dy = -ySpeed*speedFactor ;
		fl_fly			= true ;
		fl_intercept	= false;
		fl_gravity		= false ;
		fl_friction		= false ;
		fl_hitCeil		= true ;
	}


	/*------------------------------------------------------------------------
	STOPPE LE VOL
	------------------------------------------------------------------------*/
	function land() {
		fl_fly = false ;
		fl_gravity = true ;
		fl_friction = true ;
		fl_hitCeil = false ;
	}

	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		super.killHit(dx) ;
		land() ;
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function infix() {
		super.infix() ;
		if ( fl_fly && y>=Data.GAME_HEIGHT ) {
			y = Data.GAME_HEIGHT ;
			dy = -ySpeed*speedFactor ;
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix() ;
		if ( fl_fly ) {
			fl_friction = false ;
		}
	}
	//
	//
	///*------------------------------------------------------------------------
	//    DÉFINI L'ACTION SUIVANTE
	// ------------------------------------------------------------------------*/
	//  function setNext(dx,dy,delay,act) {
	//    if ( !fl_fly )
	//      super.setNext(dx,dy,delay,act) ;
	//  }


	function playAnim(a) {
		if ( a.id!=Data.ANIM_BAD_JUMP.id ) {
			super.playAnim(a);
		}
	}


	/*------------------------------------------------------------------------
	CHANGEMENT DE VITESSE
	------------------------------------------------------------------------*/
	function updateSpeed() {
		super.updateSpeed() ;
		if ( fl_fly ) {
			dx = dir*xSpeed*speedFactor ;
			if ( dy<0 ) {
				dy = -ySpeed*speedFactor ;
			}
			else {
				dy = ySpeed*speedFactor ;
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: ACTION SUIVANTE
	------------------------------------------------------------------------*/
	function onNext() {
		if ( !fl_fly ) {
			super.onNext() ;
		}
	}



	/*------------------------------------------------------------------------
	EVENT: ATTERRISSAGE
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		if ( !fl_fly ) {
			fl_intercept = false;
			super.onHitGround(h) ;
			return ;
		}
		fl_stopStepping = true ;
		dy = -ySpeed*speedFactor ;
	}


	/*------------------------------------------------------------------------
	EVENT: ATTERRISSAGE
	------------------------------------------------------------------------*/
	function onHitCeil() {
		if ( !fl_fly ) {
			super.onHitCeil() ;
			return ;
		}
		fl_stopStepping = true ;
		dy = ySpeed*speedFactor ;
	}



	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( !fl_fly ) {
			if (world.getCase( {x:cx,y:cy} )!=Data.WALL) {
				dx = -dx ;
			}
			return ;
		}
		fl_stopStepping = true ;
		dir = -dir ;
		dx = dir*xSpeed*speedFactor ;
	}


	/*------------------------------------------------------------------------
	EVENT: GEL
	------------------------------------------------------------------------*/
	function onFreeze() {
		super.onFreeze() ;
		if ( fl_fly ) {
			fl_intercept = true;;
		}
		land() ;
	}

	/*------------------------------------------------------------------------
	EVENT: SONNÉ
	------------------------------------------------------------------------*/
	function onKnock() {
		super.onKnock() ;
		land() ;
	}

	/*------------------------------------------------------------------------
	EVENT: DÉGEL
	------------------------------------------------------------------------*/
	function onMelt() {
		super.onMelt() ;
		fly() ;
	}

	/*------------------------------------------------------------------------
	EVENT: RÉVEIL
	------------------------------------------------------------------------*/
	function onWakeUp() {
		super.onWakeUp() ;
		fly() ;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		// Collisions haut du niveau
		if ( fl_fly && dy<0 && y<=Data.CASE_HEIGHT ) {
			dy = Math.abs(dy);
		}
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate() ;
		_xscale = dir*Math.abs(_xscale) ;
	}
}

