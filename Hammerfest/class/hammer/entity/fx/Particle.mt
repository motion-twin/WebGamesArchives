class entity.fx.Particle extends entity.Mover
{

	var bounce		: float ;
	var sub			: MovieClip;
	var subFrame	: int;
	var skipWallsY	: float;
	var pid			: int;



	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setLifeTimer(Data.SECOND*2 + (Data.SECOND*2)*Std.random(100)/100);
		disableAnimator();
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		register(Data.FX);
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initParticle(g,frame:int,x,y) {
		init(g) ;
		pid = frame;

		if ( pid!=Data.PARTICLE_RAIN ) {
			bounce = Std.random(65)/10 + 1.5 ;
			setNext(
				(1+Std.random(50)/10) * (Std.random(2)*2-1),
				-bounce,
				0, Data.ACTION_MOVE
			);
		}

		this.gotoAndStop(""+pid);
		subFrame = Std.random(sub._totalframes)+1;
		sub.gotoAndStop(""+subFrame);

		scale(Std.random(50)+50);
		rotation = Std.random(360);

		moveTo(x,y) ;
		skipWallsY = y;
		bounceFactor = 0.6;

		switch (pid) {
			case Data.PARTICLE_SPARK:
				scale( scaleFactor*100 * 2 );
				updateLifeTimer( Data.SECOND );
			break;
			case Data.PARTICLE_STONE:
				scale(scaleFactor*150);
			break;
			case Data.PARTICLE_RAIN:
				_yscale		= 10;
				rotation	= 5;
				alpha		= Std.random(70)+30;
			break;
			case Data.PARTICLE_METAL:
				scale( Std.random(40)+80 );
				bounceFactor = 0.3;
			break;
			case Data.PARTICLE_LITCHI:
				bounceFactor = 0.4;
			break;
			case Data.PARTICLE_BUBBLE:
				fl_gravity	= false;
				fl_hitCeil	= true;
				fl_blink	= false;
				_alpha		= Std.random(80)+20;
				moveUp( 0.3 + Std.random(10)/10 );
				scale( Std.random(40)+30 );
				next = null;
				updateLifeTimer( Data.SECOND + Std.random(Data.SECOND*20)/10 );
			break;
			case Data.PARTICLE_ICE_BAD:
				bounceFactor = 0.5;
				next.dx *= 0.3;
				next.dy = -Math.abs(next.dy)
			break;
			case Data.PARTICLE_BLOB:
				gravityFactor	= 0.6;
				fallFactor		= gravityFactor;
				updateLifeTimer(Data.SECOND*3);
				fl_blink		= false;
			break;
		}

		endUpdate() ;
	}


	/*------------------------------------------------------------------------
	CONTACT
	------------------------------------------------------------------------*/
	function hit(e) {
		if ( pid!=Data.PARTICLE_RAIN ) {
			return;
		}
		if ( (e.types&Data.PLAYER)>0 ) {
			if ( !downcast(e).fl_shield ) {
				e.scale( 100*e.scaleFactor-1 );
				destroy();
			}
		}
	}


	/*------------------------------------------------------------------------
	PRÉFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		if ( y>skipWallsY ) {
			fl_hitWall = true;
		}
		else {
			fl_hitWall = false;
		}
		super.prefix();
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		fl_friction = false ;
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE LE SOL
	------------------------------------------------------------------------*/
	function onHitGround(h) {
		if ( pid==Data.PARTICLE_BLOB ) {
			recal();
			dx = 0;
			dy = 0;
			fl_gravity = false;
//			game.fxMan.attachExplosion(x,y,Std.random(10)+10);
//			destroy();
//			return;
		}
		if ( pid==Data.PARTICLE_RAIN ) {
			recal();
			var fx = game.fxMan.attachFx(x,y,"hammer_fx_water_drop");
			fx.mc._alpha = Std.random(50)+10;
			fx.mc._xscale = 100*(Std.random(2)*2-1);
			destroy();
			return;
		}

		skipWallsY = 0;
		fl_hitWall = true;

		setNext(dx,-dy*bounceFactor, 0, Data.ACTION_MOVE) ;
		if ( Math.abs(next.dy)<=1.5 ) {
			next.dx*=game.gFriction ;
		}
		fl_skipNextGravity = true ;
		super.onHitGround(h) ;

	}


	function onHitCeil() {
		destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( fl_hitWall ) {
			if ( pid==Data.PARTICLE_BLOB ) {
				dx = 0;
			}
			else {
				dx = -dx*0.5;
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		destroy() ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,frame,x,y) {
		var linkage = "hammer_fx_particle" ;
		var mc : entity.fx.Particle = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initParticle(g,frame,x,y) ;
		return mc ;
	}



	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( pid==Data.PARTICLE_RAIN ) {
			_yscale = Math.min( 100, _yscale+Timer.tmod*4 );
			rotation *= 0.93;
		}
		else {
			rotation+=dx*2 ;
		}

		super.endUpdate() ;

		if ( pid==Data.PARTICLE_BUBBLE && totalLife>0 ) {
			_alpha = Math.min(100, 150 * lifeTimer / totalLife);
		}

		if ( pid==Data.PARTICLE_BLOB && totalLife>0 ) {
			_xscale = 100 * scaleFactor * Math.min(1, 1.5 * lifeTimer / totalLife);
			_yscale = _xscale;
		}
	}



	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		if ( Math.abs(dx)<=0.5 && pid!=Data.PARTICLE_BLOB ) {
			lifeTimer-=Timer.tmod;
			if ( lifeTimer<=0 ) {
				onLifeTimer();
			}
		}
		super.update();
	}

}

