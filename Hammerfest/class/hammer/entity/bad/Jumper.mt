class entity.bad.Jumper extends entity.bad.Walker
{
	var jumpTimer : float;

	var fl_jUp : bool;
	var fl_jDown : bool;
	var fl_jH : bool
	var fl_jumper : bool; // flag résumant les 3 précédents
	var fl_climb : bool;


	private var chanceJumpH : float;
	private var chanceJumpUp : float;
	private var chanceJumpDown : float;
	private var chanceClimb : float;

	var maxClimb : int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		jumpTimer = 0;
		setJumpUp(null);
		setJumpDown(null);
		setJumpH(null);
		setClimb(null, null);
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
	}


	/*------------------------------------------------------------------------
	DÉFINI LES SAUTS AUTORISÉS
	------------------------------------------------------------------------*/
	// Haut
	function setJumpUp(chance) {
		if ( chance==null ) {
			fl_jUp = false;
		}
		else {
			fl_jUp = true;
			chanceJumpUp = chance*10;
		}
		setJumper();
	}

	// Bas
	function setJumpDown(chance) {
		if ( chance==null ) {
			fl_jDown = false;
		}
		else {
			fl_jDown = true;
			chanceJumpDown = chance*10;
		}
		setJumper();
	}

	// Horizontal
	function setJumpH(chance) {
		if ( chance==null ) {
			fl_jH = false;
		}
		else {
			fl_jH = true;
			chanceJumpH = chance*10;
		}
		setJumper();
	}

	// Escalade
	function setClimb(chance, max) {
		if ( chance==null ) {
			fl_climb = false;
			maxClimb = 0;
		}
		else {
			fl_climb = true;
			maxClimb = max;
			chanceClimb = chance*10;
		}
		setJumper();
	}

	// Général
	function setJumper() {
		fl_jumper = fl_jUp || fl_jDown || fl_jH;
	}



	// *** IA: DÉCISIONS

	function decideJumpUp() {
		if ( fl_playerClose ) {
			return player.cy<cy && Std.random(1000)<chanceJumpUp*chaseFactor && isReady();
		}
		else {
			return Std.random(1000)<chanceJumpUp && isReady();
		}
	}

	function decideJumpDown() {
		if ( fl_playerClose ) {
			return player.cy>cy && Std.random(1000)<chanceJumpDown*chaseFactor && isReady();
		}
		else {
			return Std.random(1000)<chanceJumpDown && isReady();
		}
	}

	function decideClimb() {
		var d = Math.abs(player.cy-cy);
		var fl_good  =  d>=3 || ( d<3 && ((player.cx<cx && dx<0) || (player.cx>cx && dx>0)) );
		var fl_stairway =
			( world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) || world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) ) &&
			world.checkFlag( {x:cx,y:cy}, Data.IA_SMALL_SPOT) ;
		if ( fl_playerClose ) {
			return isReady() && ( fl_stairway || ( fl_good && Std.random(1000)<chanceClimb*chaseFactor ) );
		}
		else {
			return isReady() && ( fl_stairway || Std.random(1000)<chanceClimb );
		}
	}



	/*------------------------------------------------------------------------
	LANCE UN SAUT
	------------------------------------------------------------------------*/
	function jump(dx,dy,delay) {
		halt();
		//    x = oldX;
		//    y = oldY;
		setNext(dx,dy,delay,Data.ACTION_MOVE);
		if (delay>0) {
			playAnim( Data.ANIM_BAD_THINK );
		}
	}


	/*------------------------------------------------------------------------
	TESTE SI LE BAD PEUT GRIMPER
	------------------------------------------------------------------------*/
	function checkClimb() {
		if ( decideClimb() ) {

			// Gauche
			if ( dx<0 && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_LEFT) ) {
				var h;
				if (  world.checkFlag( {x:cx,y:cy}, Data.IA_TILE_TOP)  ) {
					h = world.getWallHeight( cx-1,cy, Data.IA_CLIMB );
				}
				else {
					h = world.getStepHeight( cx,cy, Data.IA_CLIMB );
				}
				if ( h<= maxClimb ) {
					var wait = (h>1)?Data.SECOND:0;
					if ( world.checkFlag( {x:cx,y:cy}, Data.IA_TILE_TOP) ) {
						jump( -Data.BAD_VJUMP_X_CLIFF, -Data.BAD_VJUMP_Y_LIST[h-1], wait );
					}
					else {
						jump( -Data.BAD_VJUMP_X, -Data.BAD_VJUMP_Y_LIST[h-1], wait );
						x = oldX;
					}
					fl_stopStepping = true;
				}
			}

			// Droite
			if ( dx>0 && world.checkFlag( {x:cx,y:cy}, Data.IA_CLIMB_RIGHT) ) {
				var h;
				if (  world.checkFlag( {x:cx,y:cy}, Data.IA_TILE_TOP)  ) {
					h = world.getWallHeight( cx+1,cy, Data.IA_CLIMB );
				}
				else {
					h = world.getStepHeight( cx,cy, Data.IA_CLIMB );
				}
				if ( h<= maxClimb ) {
					var wait = (h>1)?Data.SECOND:0;
					if ( world.checkFlag( {x:cx,y:cy}, Data.IA_TILE_TOP) ) {
						jump( Data.BAD_VJUMP_X_CLIFF, -Data.BAD_VJUMP_Y_LIST[h-1], wait );
					}
					else {
						jump( Data.BAD_VJUMP_X, -Data.BAD_VJUMP_Y_LIST[h-1], wait );
						x = oldX;
					}
					fl_stopStepping = true;
				}
			}
		}
	}

	/*------------------------------------------------------------------------
	EVENT: ORDRE SUIVANT
	------------------------------------------------------------------------*/
	function onNext() {
		if ( next.action == Data.ACTION_MOVE && next.dy!=0 ) {
			playAnim( Data.ANIM_BAD_JUMP );
		}

		super.onNext();
	}


	/*------------------------------------------------------------------------
	EVENT: SUR LE POINT DE TOMBER
	------------------------------------------------------------------------*/
	function onFall() {
		if ( fl_jumper ) {
			if ( isReady() && fl_jH ) {

				// Au bord du vide et décide de se laisser tomber
				// (le fait de ne pas sauter ici fait que le Walker se laissera
				// tomber). Note: ceci est un patch bien porc.
				if ( fl_fall && decideFall() ) {
					if ( world.checkFlag( {x:cx,y:cy},Data.IA_ALLOW_FALL) ) {
						fl_willFallDown = true;
					}
				}

				// Descente d'une petite marche (hauteur 1)
				if ( fl_fall && fl_climb ) {
					if (	world.checkFlag( {x:cx,y:cy+1}, Data.IA_CLIMB_LEFT ) ||
							world.checkFlag( {x:cx,y:cy+1}, Data.IA_CLIMB_RIGHT ) ) {
						fl_willFallDown = true;
					}
				}

				if ( !fl_willFallDown ) {

					// Saut gauche
					if ( dx<0 && world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_LEFT ) ) {
						jump( -Data.BAD_HJUMP_X, -Data.BAD_HJUMP_Y, 0);
						adjustToRight();
					}
					// Saut droite
					if ( dx>0 && world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_RIGHT ) ) {
						jump( Data.BAD_HJUMP_X, -Data.BAD_HJUMP_Y, 0);
						adjustToLeft();
					}

					// Escalade
					if ( fl_climb ) {
						checkClimb();
					}
				}
			}
		}
		super.onFall();
	}


	/*------------------------------------------------------------------------
	EVENT: RENCONTRE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		// Escalade
		if ( fl_climb ) {
			checkClimb();
		}

		super.onHitWall();

	}


	/*------------------------------------------------------------------------
	EVENT: FREEZE
	------------------------------------------------------------------------*/
	function onFreeze() {
		super.onFreeze();
		fl_skipNextGround = false;
	}


	/*------------------------------------------------------------------------
	EVENT: FREEZE
	------------------------------------------------------------------------*/
	function onKnock() {
		super.onKnock();
		fl_skipNextGround = false;
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();
		// Saut vertical
		if ( fl_jumper ) {
			updateCoords();

			// Haut
			if ( fl_jUp ) {
				if ( decideJumpUp() ) {
					if ( world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_UP) ) {
						jump( 0, -Data.BAD_VJUMP_Y, Data.SECOND);
						fl_stopStepping = true;
					}
				}
			}

			// Bas
			if ( fl_jDown ) {
				if ( decideJumpDown() ) {
					if ( world.checkFlag( {x:cx,y:cy}, Data.IA_JUMP_DOWN) ) {
						jump( 0, -Data.BAD_VDJUMP_Y, Data.SECOND);
						fl_skipNextGround = true;
						fl_stopStepping = true;
					}
				}
			}

		}
	}


}
