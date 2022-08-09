class entity.bad.ww.Crawler extends entity.bad.WallWalker
{
	static var SCALE_RECAL			= 0.2;
	static var CRAWL_STRETCH		= 1.8;
	static var COLOR				= 0xFF9146;
	static var COLOR_ALPHA			= 40;

	static var SHOOT_SPEED			= 6;
	static var CHANCE_ATTACK		= 10;
	static var COOLDOWN				= Data.SECOND * 2;
	static var ATTACK_TIMER			= Data.SECOND * 0.5;

	var fl_attack		: bool;
	var attackCD		: float;
	var attackTimer		: float;
	var colorAlpha		: float;

	var xscale			: float;
	var yscale			: float;

	var blobCpt			: float;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		speed			= 2;
		angerFactor		= 0.5;
		fl_attack		= false;
		attackCD		= Data.PEACE_COOLDOWN;
		blobCpt			= 0;
	}


	/*------------------------------------------------------------------------
	INITIALISATION BAD
	------------------------------------------------------------------------*/
	function initBad(g,x,y) {
		super.initBad(g,x,y);
		scale(90);
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_CRAWLER];
		var mc : entity.bad.ww.Crawler = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}




	/*------------------------------------------------------------------------
	MORT
	------------------------------------------------------------------------*/
	function killHit(dx) {
		super.killHit(dx);
		fl_attack		= false;
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI DISPONIBLE POUR UNE ACTION
	------------------------------------------------------------------------*/
	function isReady() {
		return super.isReady() && !fl_attack;
	}


	/*------------------------------------------------------------------------
	DÉMARRAGE ATTAQUE
	------------------------------------------------------------------------*/
	function prepareAttack() {
		dx			= 0;
		dy			= 0;
		fl_attack	= true;
		fl_wallWalk	= false;
		attackTimer	= ATTACK_TIMER;
		playAnim(Data.ANIM_BAD_SHOOT_START);
	}


	/*------------------------------------------------------------------------
	ATTAQUE
	------------------------------------------------------------------------*/
	function attack() {
		// Fireball
		var s = entity.shoot.FireBall.attach( game, x,y);
		s.moveTo(x,y);
		s.dx = -cp.x*SHOOT_SPEED;
		s.dy = -cp.y*SHOOT_SPEED;
		s.scale(70);
		var n = Std.random(3)+2;
		if ( cp.x!=0 ) {
			game.fxMan.inGameParticlesDir(Data.PARTICLE_BLOB, x,y, n, -cp.x);
		}
		else {
			game.fxMan.inGameParticles(Data.PARTICLE_BLOB, x,y, n );
		}
		game.fxMan.attachExplosion(x,y,20);

		sub._xscale = 150 + Math.abs(cp.x)*150;
		sub._yscale = 150 + Math.abs(cp.y)*150;
		colorAlpha = COLOR_ALPHA;
		setColorHex( Math.round(colorAlpha), COLOR );

		// Bomb
//		var b = entity.bomb.bad.PoireBomb.attach(game,x,y);
//		var bdx = (xSpeed!=0) ? -xSpeed/Math.abs(xSpeed)*5 : -cp.x*15;
//		var bdy = (cp.y==-1) ? 0 : -cp.y*10;
//		b.setNext(bdx,bdy, 0, Data.ACTION_MOVE);

		attackCD = COOLDOWN;
		playAnim(Data.ANIM_BAD_SHOOT_END);
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI DÉCIDE D'ATTAQUER
	------------------------------------------------------------------------*/
	function decideAttack() {
		if ( fl_attack ) {
			return false;
		}

		var fl_inSight = false;
		var factor = 1.0;

		// Player au dessus/dessous
		if ( cp.y!=0 && Math.abs(player.x-x)<=Data.CASE_WIDTH*2 ) {
			if ( cp.y>0 && player.y<y ) {
				fl_inSight = true;
			}
			if ( cp.y<0 && player.y>y ) {
				fl_inSight = true;
			}
		}

		// Player à gauche/droite
		if ( cp.x!=0 && Math.abs(player.y-y)<=Data.CASE_HEIGHT*2 ) {
			if ( cp.x>0 && player.x<x ) {
				fl_inSight = true;
			}
			if ( cp.x<0 && player.x>x ) {
				fl_inSight = true;
			}
		}

		if ( fl_inSight ) {
			attackCD -= Timer.tmod*4;
			factor = 8;
		}

		return isReady() && isHealthy() && attackCD<=0 && Std.random(1000) < CHANCE_ATTACK*factor;
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);

		if ( id==Data.ANIM_BAD_SHOOT_END.id ) {
			fl_attack = false;
			fl_wallWalk	= true;
			moveToSafePos();
			updateSpeed();
			if ( dx==0 && dy==0 ) {
				wallWalk();
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: GEL
	------------------------------------------------------------------------*/
	function onFreeze() {
		super.onFreeze() ;
		fl_attack = false;
	}

	/*------------------------------------------------------------------------
	EVENT: SONNÉ
	------------------------------------------------------------------------*/
	function onKnock() {
		super.onKnock() ;
		fl_attack = false;
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		super.onHitGround(h);
		if ( Math.abs(h)>=Data.CASE_HEIGHT*3 ) {
			sub._xscale = 2*100*scaleFactor;
			sub._yscale = 0.2*100*scaleFactor;
			sub._y = ySubBase+10;
			if ( !fl_freeze ) {
				game.fxMan.inGameParticles( Data.PARTICLE_BLOB, x,y, Std.random(3)+2 );
			}
		}
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();
		if ( fl_attack ) {
			// Vibration attaque
			_x += Std.random(15)/10 * (Std.random(2)*2-1);
			_y += Std.random(15)/10 * (Std.random(2)*2-1);
			xscale = scaleFactor * 100 + Std.random(20)*(Std.random(2)*2-1);
			yscale = scaleFactor * 100 + Std.random(20)*(Std.random(2)*2-1);
		}
		else {
			xscale = scaleFactor * 100;
			yscale = scaleFactor * 100;
		}

		if ( fl_wallWalk ) {
			// Etirement en déplacement
			if ( dx!=0 ) {
				xscale = 100 * scaleFactor * CRAWL_STRETCH;
			}
			if ( dy!=0 ) {
				yscale = 100 * scaleFactor * CRAWL_STRETCH;
			}
		}

		if ( isHealthy() ) {
			// Déformation blob cosinus
			xscale+= 10*Math.sin(blobCpt);
			yscale+= 10*Math.cos(blobCpt);
			blobCpt+=Timer.tmod*0.1;
		}


		sub._xscale += SCALE_RECAL * (xscale - sub._xscale);
		sub._yscale += SCALE_RECAL * (yscale - sub._yscale);

		if ( colorAlpha>0 ) {
			colorAlpha-=Timer.tmod*3;
			if ( colorAlpha<=0 ) {
				resetColor();
			}
			else {
				setColorHex( Math.round(colorAlpha), COLOR );
			}
		}


	}



	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( fl_attack ) {
			dx = 0;
			dy = 0;
		}

		super.update();

		// Cooldown d'attaque
		if ( attackCD>0 ) {
			attackCD-=Timer.tmod;
		}

		// Attaque
		if ( decideAttack() ) {
			if ( world.getCase( {x:cx+cp.x,y:cy+cp.y} ) > 0 ) {
				prepareAttack();
			}
		}

		if ( fl_attack && attackTimer>0 ) {
			attackTimer-=Timer.tmod;
			if ( attackTimer<=0 ) {
				attack();
			}
		}
	}

}

