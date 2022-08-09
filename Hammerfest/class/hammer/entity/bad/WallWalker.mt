class entity.bad.WallWalker extends entity.Bad
{
	static var SUB_RECAL	= 0.2;


	var fl_wallWalk		: bool;
	var fl_intercept	: bool;
	var fl_lost			: bool;

	var cp				: {x:int,y:int}; // check-point (relative coords)
	var speed			: float;

	var xSpeed			: float;
	var ySpeed			: float;

	var xSub			: float;
	var ySub			: float;
	var xSubBase		: float;
	var ySubBase		: float;
	var subOffset		: float;

	var lastSafe			: {
			x		: float,
			y		: float,
			xSpeed	: float,
			ySpeed	: float,
			cp		: {x:int,y:int},
	};



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		speed			= 3;
		angerFactor		= 0.4;
		subOffset		= 8;
		fl_intercept	= false;
		fl_lost			= false;
		fl_largeTrigger	= true;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initBad(g,x,y) {
		super.initBad(g,x,y);
		xSub = sub._x;
		ySub = sub._y;
		xSubBase = xSub;
		ySubBase = ySub;
		wallWalk();
	}


	/*------------------------------------------------------------------------
	ACTIVE / DÉSACTIVE LE WALL-WALK
	------------------------------------------------------------------------*/
	function wallWalk() {
		if ( !isHealthy() || !isReady() ) {
			return ;
		}
		fl_wallWalk		= true;

		fl_gravity		= false;
		fl_friction		= false;
		fl_hitWall		= false;
		fl_hitGround	= false;
		fl_hitBorder	= false;
		var choices = [
			{x:1,y:0,	cpx:0,cpy:1}, // horizontal + bas
			{x:-1,y:0,	cpx:0,cpy:1},
			{x:1,y:0,	cpx:0,cpy:-1}, // horizontal + haut
			{x:-1,y:0,	cpx:0,cpy:-1},
			{x:0,y:1,	cpx:1,cpy:0}, // vertical + droite
			{x:0,y:-1,	cpx:1,cpy:0},
			{x:0,y:1,	cpx:-1,cpy:0}, // vertical + gauche
			{x:0,y:-1,	cpx:-1,cpy:0},
		];
		for (var i=0;i<choices.length;i++) {
			var ch = choices[i];
			if ( world.getCase( {x:cx+ch.x,y:cy+ch.y} )>0 || world.getCase( {x:cx+ch.cpx,y:cy+ch.cpy} )<=0 ) {
				choices.splice(i,1);
				i--;
			}
		}
		var choice = choices[ Std.random(choices.length) ];
		if ( choice!=null ) {
			setDir(choice.x,choice.y);
			setCP(choice.cpx,choice.cpy);
			playAnim(Data.ANIM_BAD_WALK);
		}
		else {
			suicide();
		}

		fl_softRecal	= false;
	}


	function land() {
		fl_wallWalk		= false;

		fl_gravity		= true;
		fl_friction		= true;
		fl_hitWall		= true;
		fl_hitGround	= true;
		fl_hitBorder	= true;
	}



	/*------------------------------------------------------------------------
	MODIFIE LA DIRECTION DE DÉPLACEMENT
	------------------------------------------------------------------------*/
	function setDir(xoff, yoff) {
		xSpeed = speed*xoff;
		ySpeed = speed*yoff;
		updateSpeed();
		x = Entity.x_ctr(cx);
		y = Entity.y_ctr(cy);
		activateSoftRecal();
		setNext(dx,dy,0,Data.ACTION_MOVE);
	}

	function setCP(xoff,yoff) {
		cp = {x:xoff, y:yoff};
	}


	/*------------------------------------------------------------------------
	CHANGEMENT DE VITESSE
	------------------------------------------------------------------------*/
	function updateSpeed() {
		super.updateSpeed() ;
		if ( fl_wallWalk && isReady() ) {
			dx = xSpeed*speedFactor;
			dy = ySpeed*speedFactor;
		}
	}




	/*------------------------------------------------------------------------
	INFIXE DE STEPPING
	------------------------------------------------------------------------*/
	function infix() {
		super.infix();

		if ( fl_wallWalk ) {
			wallWalkIA();
		}
	}


	/*------------------------------------------------------------------------
	GESTION DU DÉPLACEMENT AUX MURS
	------------------------------------------------------------------------*/
	function wallWalkIA() {
		if ( deathTimer>0 ) {
			return;
		}

		var dirX :int = Math.round( (dx==0) ? 0 : dx/Math.abs(dx) );
		var dirY :int = Math.round( (dy==0) ? 0 : dy/Math.abs(dy) );

		// Haut du niveau
		if ( cy==0 ) {
			if ( dy<0 ) {
				setDir(-cp.x, 0);
				setCP(0,-1);
			}
			else {
				if ( world.getCase( {x: cx+dirX, y: cy} )>0 ) {
					setDir(0,1);
					setCP(dirX,0);
				}
			}
		}
		else {
			// Coins convexes
			if ( world.getCase( {x: cx+cp.x, y: cy+cp.y} )<=0 ) {
				setDir(cp.x,cp.y);
				setCP(-dirX,-dirY);
			}
			else {
				// Coins non-convexes
				if ( world.getCase( {x:cx+dirX, y:cy+dirY} ) > 0 ) {
					setDir(-cp.x, -cp.y);
					setCP(dirX, dirY);
				}
			}
		}

		// Impasses
		var fl_deadEnd = true;
		var tries = 0;
		while ( fl_deadEnd && tries<4 ) {
			dirX = Math.round( (dx==0) ? 0 : dx/Math.abs(dx) );
			dirY = Math.round( (dy==0) ? 0 : dy/Math.abs(dy) );
			if ( world.getCase( {x:cx+dirX, y:cy+dirY} )>0 && world.getCase( {x: cx+cp.x, y: cy+cp.y} )>0 ) {
				setDir(-cp.x, -cp.y);
				setCP(dirX, dirY);
			}
			else {
				fl_deadEnd = false;
			}
			tries++;
		}

		// Bloqué ? Suicide !
		if ( fl_deadEnd && !(deathTimer>0) ) {
			suicide();
		}


	}


	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		super.killHit(dx);
		land();
		fl_hitGround	= false;
		fl_hitWall		= false;
	}


	/*------------------------------------------------------------------------
	SUICIDE!
	------------------------------------------------------------------------*/
	function suicide() {
		if ( deathTimer>0 ) {
			return;
		}
		dx = 0;
		dy = 0;
		land();
		fl_lost			= true;
		deathTimer		= Data.SECOND*3;
	}


	/*------------------------------------------------------------------------
	RECALAGE EN POSITION SÛRE
	------------------------------------------------------------------------*/
	function moveToSafePos() {
		if ( x!=lastSafe.x || y!=lastSafe.x ) {
			x			= lastSafe.x;
			y			= lastSafe.y;
			cp			= lastSafe.cp;
			xSpeed		= lastSafe.xSpeed;
			ySpeed		= lastSafe.ySpeed;
			updateCoords();
		}
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI DISPONIBLE POUR UNE ACTION
	------------------------------------------------------------------------*/
	function isReady() {
		return isHealthy() && !fl_lost;
	}



	/*------------------------------------------------------------------------
	EVENT: GEL
	------------------------------------------------------------------------*/
	function onFreeze() {
		super.onFreeze() ;
		if ( fl_wallWalk ) {
			fl_intercept = true;;
		}
		land();
	}

	/*------------------------------------------------------------------------
	EVENT: SONNÉ
	------------------------------------------------------------------------*/
	function onKnock() {
		super.onKnock() ;
		land();
	}

	/*------------------------------------------------------------------------
	EVENT: DÉGEL
	------------------------------------------------------------------------*/
	function onMelt() {
		super.onMelt() ;
		wallWalk() ;
	}

	/*------------------------------------------------------------------------
	EVENT: RÉVEIL
	------------------------------------------------------------------------*/
	function onWakeUp() {
		super.onWakeUp() ;
		wallWalk() ;
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( !fl_wallWalk ) {
			if (world.getCase( {x:cx,y:cy} )!=Data.WALL) {
				dx = -dx ;
			}
			return ;
		}
	}

	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		fl_intercept = false;
		if ( fl_lost ) {
			fl_lost = false;
			deathTimer = null;
			wallWalk();
		}
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();

		if ( isHealthy() ) {
			// Excentrage
			xSub = xSubBase + cp.x*subOffset;
			ySub = ySubBase + cp.y*subOffset;
			if ( cp.y>0 ) {
				ySub = ySubBase + subOffset*0.5;
			}
		}
		else {
			xSub = xSubBase;
			if ( fl_freeze ) {
				ySub = ySubBase;
			}
			else {
				ySub = ySubBase + subOffset*0.5;
			}
		}
		sub._x += SUB_RECAL * (xSub - sub._x) * speedFactor;
		sub._y += SUB_RECAL * (ySub - sub._y) * speedFactor;
	}



	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Radius auto (pour décapiter ^^)
		if ( game.getOne(Data.PLAYER).y>y ) {
			realRadius = Data.CASE_WIDTH*1.4;
		}
		else {
			realRadius = Data.CASE_WIDTH;
		}

		super.update();

		// Perte du point de fixation
		if ( lastSafe!=null && world.getCase( {x: Entity.x_rtc(lastSafe.x)+lastSafe.cp.x, y: Entity.y_rtc(lastSafe.y)+lastSafe.cp.y} )<=0 ) {
			lastSafe = null;
			fl_gravity		= true;
			fl_wallWalk		= false;
			fl_hitGround	= true;
			fl_friction		= true;
			fl_lost			= true;
		}

		// Position sûre
		if ( world.getCase( {x: cx+cp.x, y: cy+cp.y} )>0 ) {
			lastSafe = {
				x		: x,
				y		: y,
				xSpeed	: xSpeed,
				ySpeed	: ySpeed,
				cp		: {x:cp.x, y:cp.y},
			}
		}
	}



}

