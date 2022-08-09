class entity.bad.ww.Saw extends entity.bad.WallWalker
{
	static var ROTATION_RECAL	= 0.3;
	static var STUN_DURATION	= Data.SECOND*3;
	static var BASE_SPEED		= 3;
	static var ROTATION_SPEED	= 10;

	var fl_stun				: bool;
	var fl_stop				: bool;
	var fl_updateSpeed		: bool;
	var stunTimer			: float;
	var rotSpeed			: float;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		speed				= BASE_SPEED;
		angerFactor			= 0;
		subOffset			= 2;
		rotSpeed			= 0;
		fl_stun				= false;
		fl_stop				= false;
		fl_updateSpeed		= false;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		unregister(Data.BAD_CLEAR);
	}



	/*------------------------------------------------------------------------
	INITIALISATION BAD
	------------------------------------------------------------------------*/
	function initBad(g,x,y) {
		super.initBad(g,x,y);
		scale(80);
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_SAW];
		var mc : entity.bad.ww.Saw = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	INTERRUPTION
	------------------------------------------------------------------------*/
	function stun() {
		if ( fl_stop ) {
			return;
		}
		game.fxMan.attachExplosion( x,y-Data.CASE_HEIGHT*0.5, 30);
		if ( !fl_stun ) {
			game.fxMan.inGameParticlesDir( Data.PARTICLE_METAL, x,y, 5, dx);
			game.fxMan.inGameParticlesDir( Data.PARTICLE_STONE, x,y, Std.random(4), dx);
		}
		fl_stun		= true;
		fl_wallWalk	= false;
		stunTimer	= STUN_DURATION;
		dx			= 0;
		dy			= 0;
	}


	/*------------------------------------------------------------------------
	ARRÊT / MARCHE
	------------------------------------------------------------------------*/
	function halt() {
		if ( fl_stop ) {
			return;
		}
		fl_stop		= true;
		fl_wallWalk	= false;
		dx			= 0;
		dy			= 0;
	}

	function run() {
		if ( !fl_stop ) {
			return;
		}
		fl_stop		= false;
		fl_wallWalk	= true;
		updateSpeed();
	}


	/*------------------------------------------------------------------------
	RENVOIE TRUE SI "EN BONNE SANTÉ"
	------------------------------------------------------------------------*/
	function isHealthy() {
		return !fl_kill && !fl_stun && !fl_stop;
	}


	/*------------------------------------------------------------------------
	TOUCHE UNE ENTITÉ
	------------------------------------------------------------------------*/
	function hit(e) {
		if ( isHealthy() ) {
			if ( e.isType(Data.PLAYER) ) {
				game.fxMan.inGameParticles( Data.PARTICLE_CLASSIC_BOMB, x,y, Std.random(5)+3 );
			}
		}

		super.hit(e);

		if ( isHealthy() ) {

			if ( e.isType(Data.BOMB) && !e.isType(Data.BAD_BOMB) ) {
				var b : entity.Bomb = downcast(e);
				b.setLifeTimer(Data.SECOND*0.6);
				b.dx = (dx!=0 )		? -dx		: -cp.x*4;
				b.dy = (cp.y!=0)	? -cp.y*13	: -8;
				game.fxMan.inGameParticlesDir( Data.PARTICLE_SPARK, b.x,b.y, 2, b.dx );
			}

//			if ( e.isType(Data.BAD_CLEAR) ) {
//				downcast(e).killHit(-dx);
//			}
		}
	}

	/*------------------------------------------------------------------------
	MODE GRAVITÉ "NORMALE" DES WALLWALKERS DÉSACTIVÉ
	------------------------------------------------------------------------*/
	function land() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	IMMORTALITÉ
	------------------------------------------------------------------------*/
	function killHit(dx) {
		stun();
	}
	function knock(d) {
		stun();
	}
	function freeze(d) {
		stun();
	}


	/*------------------------------------------------------------------------
	EVENT: RÉVEIL
	------------------------------------------------------------------------*/
	function onWakeUp() {
		// specific to stun effect
		fl_wallWalk	= true;
		moveToSafePos();
		updateSpeed();
		game.fxMan.inGameParticles( Data.PARTICLE_STONE, x,y, 3);
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();
		if ( fl_stun ) {
			var f = 1-stunTimer/STUN_DURATION;
			_x = x + f*(Std.random(20)/10) * (Std.random(2)*2-1);
			_y = y + f*(Std.random(20)/10) * (Std.random(2)*2-1);
		}
		if ( fl_wallWalk || fl_stop ) {
			var ang = Math.atan2( cp.y,cp.x );
			var angDeg = 180 * ang/Math.PI - 90;
			var delta = angDeg-sub._rotation;
			if ( delta<-180 ) {
				delta+=360;
			}
			if ( delta>180 ) {
				delta-=360;
			}
			sub._rotation += (delta)*ROTATION_RECAL;
		}
		else {
			if ( fl_kill ) {
				sub._rotation += Timer.tmod*14.5;
			}
			else {
				if ( isHealthy() ) {
					sub._rotation += (0-sub._rotation)*(ROTATION_RECAL*0.25);
				}
			}
		}

		if ( fl_stop || fl_stun ) {
			rotSpeed *= 0.9;
		}
		else {
			rotSpeed = Math.min(ROTATION_SPEED, rotSpeed+Timer.tmod);
		}
		downcast(sub).sub._rotation += rotSpeed;
	}



	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {

		// Controle par variables dynamiques
		var dyn_sp = game.getDynamicInt("$SAW_SPEED");
		var old = speed;
		if ( Std.isNaN(dyn_sp) || dyn_sp<0 ) {
			speed = BASE_SPEED;
			run();
		}
		else {
			if ( dyn_sp==0 ) {
				halt();
			}
			else {
				speed = dyn_sp;
				run();
			}
		}
		if ( old!=speed ) {
			fl_updateSpeed = true;
		}

		if ( fl_updateSpeed && isHealthy() ) {
			fl_updateSpeed = false;
			updateSpeed();
		}



		if ( fl_stop || fl_stun ) {
			dx = 0;
			dy = 0;
		}

		if ( fl_stun ) {
			if ( Std.random(10)==0 ) {
				game.fxMan.inGameParticles(Data.PARTICLE_SPARK, x,y, 1);
			}
			stunTimer-=Timer.tmod;
			if ( stunTimer<=0 ) {
				fl_stun = false;
				onWakeUp();
			}
		}
		super.update();
	}

}


