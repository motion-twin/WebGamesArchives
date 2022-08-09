class entity.bad.Walker extends entity.Bad
{

	var speed			: float;
	var dir				: float;

	var fl_fall			: bool;
	var fl_willFallDown	: bool;
	var chanceFall		: float;

	var recentParticles	: float; // reduces frequency of ice particles when hitting walls


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		setFall(null);
		speed			= 2;
		fl_willFallDown	= false;
		recentParticles	= 0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g:mode.GameMode) {
		super.init(g);
		if ( game.fl_static ) {
			if ( x<=Data.GAME_WIDTH*0.5 ) {
				dir = 1
			}
			else {
				dir = -1
			}
		}
		else {
			dir = Std.random(2)*2-1;
		}
	}


	/*------------------------------------------------------------------------
	STOPPE LE MOUVEMENT DU BAD
	------------------------------------------------------------------------*/
	function halt() {
		if ( !fl_freeze && !fl_knock ) {
			dx=0;
		}
		dy=0;
	}


	/*------------------------------------------------------------------------
	CALCULE LA VITESSE DE MARCHE DU MONSTRE
	------------------------------------------------------------------------*/
	function walk() {
		var base = speedFactor * speed * game.speedFactor;

		if ( !isReady() ) {
			return;
		}

		if (dir==-1) { // gauche
			base = -base;
		}

		if ( fl_stable ) {
			playAnim( Data.ANIM_BAD_WALK );
		}
		setNext(base,0,0,Data.ACTION_MOVE);
	}


	/*------------------------------------------------------------------------
	DEMI-TOUR
	------------------------------------------------------------------------*/
	function fallBack() {
		dx = -dx;
		if ( !fl_freeze && !fl_knock ) {
			dir = -dir;
		}
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function infix() {
		if ( fl_stable && world.checkFlag( {x:cx,y:cy}, Data.IA_FALL_SPOT) ) {
			onFall();
			fl_stopStepping = true;
			return;
		}
		super.infix();
	}

	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix();

		// Désactivation de la friction pendant la marche
		if ( isReady() ) {
			fl_friction = false;
		}
		else {
			fl_friction = true;
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI LE BAD EST DISPOSÉ À AGIR
	------------------------------------------------------------------------*/
	function isReady() {
		return super.isReady() && isHealthy();
	}


	/*------------------------------------------------------------------------
	DÉFINI LES CHANCES DE SE LAISSER TOMBER
	------------------------------------------------------------------------*/
	function setFall(chance) {
		if ( chance==null ) {
			fl_fall = false;
		}
		else {
			fl_fall = true;
			chanceFall = chance*10;
		}
	}


	/*------------------------------------------------------------------------
	LE BAD RETROUVE SON CALME
	------------------------------------------------------------------------*/
	function calmDown() {
		super.calmDown();
		if ( animId==Data.ANIM_BAD_ANGER.id ) {
			playAnim( Data.ANIM_BAD_WALK );
		}

		if ( isReady() ) {
			halt();
			walk();
		}
	}

	/*------------------------------------------------------------------------
	ÉNERVEMENT
	------------------------------------------------------------------------*/
	function angerMore() {
		super.angerMore();
		if (isReady()) {
			halt();
			walk();
		}
	}


	/*------------------------------------------------------------------------
	CHANGEMENT DE VITESSE
	------------------------------------------------------------------------*/
	function updateSpeed() {
		super.updateSpeed();
		walk();
	}


	// *** IA: DÉCISIONS

	function decideFall() {
		var d = player.cy - cy;
		var fall = world.fallMap[cx][cy];
		var fl_good = fall>0 && d>0 && fall<=d+3;
		if ( fl_playerClose ) {
			return fl_good;
		}
		else {
			return Std.random(1000)<chanceFall;
		}
	}


//	function decideFallBack() { // *** NOT USED ! ***
//		if ( fl_playerClose ) {
//			// proche en Y
//			if ( Math.abs(player.cy - cy) < 3 ) {
//				// aucun obstacle entre le mob et le joueur
//				var inc = (player.cx<cx)?-1:1;
//				var fl_obst = false;
//				for (var i=cx ; i!=player.cx && !fl_obst ; i+=inc) {
//					if ( world.getCase( {x:i,y:cy} )>0 ) {
//						fl_obst = true;
//					}
//				}
//				return !fl_obst;
//			}
//			else {
//				return false;
//			}
//		}
//		else {
//			return false;
//		}
//	}



	// *** EVENTS

	/*------------------------------------------------------------------------
	SUIT LA DÉCISION SUIVANTE
	------------------------------------------------------------------------*/
	function onNext() {
		if ( next.action == Data.ACTION_WALK ) {
			next=null;
			walk();
		}
		if ( next.action == Data.ACTION_FALLBACK ) {
			next=null;
			walk();
			next.dx = -next.dx;
		}
		if ( next.action == Data.ACTION_MOVE && next.dy==0 ) {
			playAnim( Data.ANIM_BAD_WALK );
		}
		super.onNext();
	}


	/*------------------------------------------------------------------------
	EVENT: MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( !fl_stopStepping ) {
			if (world.getCase( {x:cx,y:cy} )!=Data.WALL) {
				if ( !isHealthy() || fl_stable ) {
					fallBack();
				}
			}
		}
		if ( GameManager.CONFIG.fl_detail && fl_freeze && Math.abs(dx)>=4 ) {
			if ( recentParticles<=0 ) {
				if ( GameManager.CONFIG.fl_shaky ) {
					game.shake(Data.SECOND*0.2,2);
				}
				game.fxMan.inGameParticles( Data.PARTICLE_ICE_BAD, x, y, Std.random(4)+1 );
				recentParticles=10;
			}
			if ( fl_stable ) {
				game.fxMan.dust(cx,cy+1);
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: ATTERRISSAGE
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		halt();
		walk();
	}


	/*------------------------------------------------------------------------
	EVENT: SUR LE POINT DE TOMBER
	------------------------------------------------------------------------*/
	function onFall() {
		if ( !isReady() ) {
			return;
		}

		// Ne reste pas sur une dalle merdique s'il peut s'en laisser tomber
		if ( world.checkFlag( Entity.rtc(oldX,oldY), Data.IA_SMALL_SPOT ) && world.checkFlag( {x:cx,y:cy}, Data.IA_ALLOW_FALL ) ) {
			halt();
			return;
		}

		// Se laisse tomber (NB: le Jumper peut avoir mis le flag à true)
		if ( fl_fall ) {
			if ( decideFall() ) {
				if ( world.checkFlag( {x:cx,y:cy},Data.IA_ALLOW_FALL) ) {
					fl_willFallDown = true;
				}
			}

			if ( fl_willFallDown ) {
				fl_willFallDown = false;
				halt();
				return;
			}
		}

		x = oldX;
		y = oldY;
		fallBack();
	}


	/*------------------------------------------------------------------------
	BAD FREEZÉ
	------------------------------------------------------------------------*/
	function onFreeze() {
		super.onFreeze();
		next=null;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE FREEZE
	------------------------------------------------------------------------*/
	function onMelt() {
		super.onMelt();
		walk();
		if ( !fl_stable ) {
			playAnim( Data.ANIM_BAD_JUMP );
		}
	}



	/*------------------------------------------------------------------------
	BAD SONNÉ
	------------------------------------------------------------------------*/
	function onKnock() {
		super.onKnock();
		next=null;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE KNOCK
	------------------------------------------------------------------------*/
	function onWakeUp() {
		super.onWakeUp();
		walk();
		if ( !fl_stable ) {
			playAnim( Data.ANIM_BAD_JUMP );
		}
	}



	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();

		// Flip gauche/droite du movie
		if ( !fl_freeze && !fl_knock ) {
			if ( dx<0 ) {
				dir = -1;
			}
			if ( dx>0 ) {
				dir = 1;
			}
			_xscale = dir*Math.abs(_xscale);
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		fl_willFallDown = false;
		if ( recentParticles>0 ) {
			recentParticles-=Timer.tmod;
		}
		super.update();
	}


}

