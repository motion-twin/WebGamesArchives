class entity.bad.walker.Coward extends entity.bad.Jumper
{
	static var VCLOSE_DISTANCE	= Data.CASE_HEIGHT*2;
	static var CLOSE_DISTANCE	= Data.CASE_WIDTH*7;
	static var SPEED_BOOST		= 3;
	static var FLEE_DURATION	= Data.SECOND*4;

	static var FLEE_JUMP_FACTOR	= 25;


	var fleeTimer		: float;


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
		closeDistance	= 0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_BANANE];
		var mc : entity.bad.walker.Coward = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	SAUT: CHANGEMENT DE DÉLAI
	------------------------------------------------------------------------*/
	function jump(dx,dy,delay) {
		if ( delay!=null && delay>0 ) {
			delay = Data.SECOND*0.2;
		}
		super.jump(dx,dy, delay);
	}


	/*------------------------------------------------------------------------
	CALCUL DES CHANCES DE CHANGER D'ÉTAGE
	------------------------------------------------------------------------*/
	function decideJumpUp() {
		var fl_danger = player.y<y && fleeTimer>0;
		if ( vclose() && close() && fleeTimer>0 ) {
			return Std.random(1000)<chanceJumpUp*FLEE_JUMP_FACTOR && isReady();
		}
		else {
			if ( player.y<y ) {
				return !fl_danger && Std.random(1000)*0.5<chanceJumpUp && isReady();
			}
			else {
				return !fl_danger && Std.random(1000)<chanceJumpUp && isReady();
			}
		}
	}

	function decideJumpDown() {
		var fl_danger = player.y>y && fleeTimer>0;
		if ( vclose() && close() && fleeTimer>0 ) {
			return Std.random(1000)<chanceJumpDown*FLEE_JUMP_FACTOR && isReady();
		}
		else {
			if ( player.y>y ) {
				return !fl_danger && Std.random(1000)<chanceJumpDown*0.5 && isReady();
			}
			else {
				return !fl_danger && Std.random(1000)<chanceJumpDown && isReady();
			}
		}
	}


	/*------------------------------------------------------------------------
	CHANCE DE SE LAISSER TOMBER
	------------------------------------------------------------------------*/
	function decideFall() {
		var fall = world.fallMap[cx][cy];
		if ( fall>0 ) {
			if ( vclose() ) {
				return true;
			}
		}
		return false;
	}


	/*------------------------------------------------------------------------
	CHANCE DE GRIMPER UN MUR
	------------------------------------------------------------------------*/
	function decideClimb() {
		var fl_stairway =
			( world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) && world.getCase( {x:cx-1,y:cy-1} )<=0 ) ||
			( world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) && world.getCase( {x:cx+1,y:cy-1} )<=0 );

		var fl_danger =
			fleeTimer>0 && player.cy<cy &&
			(	( world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) && player.x<x ) ||
				( world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) && player.x>x ) );

		return !fl_danger && isReady() && ( fl_stairway || Std.random(1000)<chanceClimb );
	}


	/*------------------------------------------------------------------------
	CHANCE DE S'ENFUIR FACE AU JOUEUR
	------------------------------------------------------------------------*/
	function decideFlee() {
		if ( fl_stable && dx!=0 && next==null ) {
			if ( vclose() && close() ) {
				return fleeTimer<=0;
			}
			if ( distance(player.x,player.y)<=Data.CASE_WIDTH*4 ) {
				return fleeTimer<=0;
			}
		}
		return false;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE PLAYER EST PROCHE
	------------------------------------------------------------------------*/
	function vclose() {
		return Math.abs( player.y - y ) <= VCLOSE_DISTANCE;
	}


	function close() {
		return distance(player.x,player.y) <= CLOSE_DISTANCE;
	}


	/*------------------------------------------------------------------------
	CALCUL DE LA VITESSE DE MARCHE
	------------------------------------------------------------------------*/
	function calcSpeed() {
		super.calcSpeed();
		if ( fleeTimer>0 ) {
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

		if ( fl_stable && next==null && decideFlee() ) {
			flee();
		}
	}


	/*------------------------------------------------------------------------
	GESTION FUITE
	------------------------------------------------------------------------*/
	function flee() {
		if ( (player.x<=x && dir<0) || (player.x>=x && dir>0) ) {
			dir = -dir;
		}
		fleeTimer = FLEE_DURATION;
		updateSpeed();
	}

	function endFlee() {
		updateSpeed();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();
		if ( isHealthy() && fleeTimer>0 ) {
			if ( !fl_stick ) {
				var mc = game.depthMan.attach("curse", Data.DP_FX) ;
				mc.gotoAndStop(""+Data.CURSE_TAUNT) ;
				stick(mc,0,-Data.CASE_HEIGHT*2.5);
			}
		}
		else {
			unstick();
		}

		// Timer de fuite
		if ( fleeTimer>0 ) {
			fleeTimer-=Timer.tmod;
			if ( fleeTimer<=0 ) {
				endFlee();
			}
		}
	}


}

