class entity.bad.walker.Hunter extends entity.bad.Jumper
{
	static var VCLOSE_DISTANCE	= Data.CASE_HEIGHT*2;
	static var CLOSE_DISTANCE	= Data.CASE_WIDTH*8;
	static var SPEED_BOOST		= 2.2;

	var prey			: entity.Physics;
	var fl_hunt			: bool;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpUp(5) ;
		setJumpDown(5) ;
		setJumpH(100) ;
		setClimb(100,Data.IA_CLIMB);
		setFall(5) ;
		chaseFactor = 12;
		fl_hunt		= false;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		prey = downcast(game.getOne(Data.PLAYER));
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_BANANE];
		var mc : entity.bad.walker.Hunter = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE PLAYER EST PROCHE
	------------------------------------------------------------------------*/
	function vclose() {
		return Math.abs( prey.y - y ) <= VCLOSE_DISTANCE;
	}

	function close() {
		return distance(prey.x,prey.y) <= CLOSE_DISTANCE;
	}


	/*------------------------------------------------------------------------
	CALCUL DE LA VITESSE DE MARCHE
	------------------------------------------------------------------------*/
	function calcSpeed() {
		super.calcSpeed();
		if ( isHealthy() && close() ) {
			speedFactor *= SPEED_BOOST;
		}
	}


	/*------------------------------------------------------------------------
	ÉNERVEMENT DÉSACTIVÉ
	------------------------------------------------------------------------*/
	function angerMore() {
		anger = 0;
	}


	/*------------------------------------------------------------------------
	INFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();

		if ( fl_stable && next==null && decideHunt() ) {
			hunt();
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI UNE TRAQUE EST À LANCER
	------------------------------------------------------------------------*/
	function decideHunt() {
		return close();
	}


	/*------------------------------------------------------------------------
	LANCE UNE TRAQUE
	------------------------------------------------------------------------*/
	function hunt() {
		if ( vclose() ) {
			if ( (dir>0 && prey.x<x) || (dir<0 && prey.x>x) ) {
				dir = -dir;
			}
		}
		fl_hunt = true;
		updateSpeed();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( fl_hunt ) {
			if ( isReady() && !close() ) {
				updateSpeed();
				fl_hunt = false;
			}
		}
		super.update();
	}


}

