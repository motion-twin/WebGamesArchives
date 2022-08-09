class entity.bad.walker.Fraise extends entity.bad.Shooter
{

	var fl_ball		: bool;
	var ballTarget	: Entity;
	var catchCD		: float; // cooldown apres récup de la balle


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();

		catchCD		= 0;
		animFactor	= 1.0;
		setShoot(4);

		initShooter(0,10);
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		fl_ball = false;

		// Attribution de la première balle
		assignBall();
		var l = game.getList(Data.CATCHER);
		for (var i=0;i<l.length;i++) {
			var b : entity.bad.walker.Fraise = downcast(l[i]);
			if ( b.fl_ball ) {
				fl_ball = false;
			}
		}


		if ( game.getList(Data.BALL).length > 0 ) {
			fl_ball = false;
		}

		register(Data.CATCHER);
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_FRAISE];
		var mc : entity.bad.walker.Fraise = downcast( g.depthMan.attach(linkage,Data.DP_BADS) );
		mc.initBad(g,x,y);
		return mc;
	}


	/*------------------------------------------------------------------------
	RÉCEPTION D'UNE BALLE
	------------------------------------------------------------------------*/
	function catchBall(b:entity.shoot.Ball) {
		if ( !isHealthy() ) {
			return;
		}
		next = null;
		walk();
		assignBall();
		b.destroy();
		ballTarget = null;
	}


	/*------------------------------------------------------------------------
	ASSIGNE LA BALLE À CE BAD
	------------------------------------------------------------------------*/
	function assignBall() {
		fl_ball = true;
		catchCD = Data.SECOND*1.5;
	}


	/*------------------------------------------------------------------------
	EVENT: TIR
	------------------------------------------------------------------------*/
	function onShoot() {
		super.onShoot();

		// Lanceur
		this.fl_ball = false;

		// Le receveur est un bad
		if ( (ballTarget.types&Data.BAD)>0 ) {
			var bad : entity.bad.Walker = downcast(ballTarget);
			bad.setNext(null,null, Data.BALL_TIMEOUT+5, Data.ACTION_WALK);
			bad.halt();
			bad.playAnim(Data.ANIM_BAD_THINK);
		}

		// Balle
		var s = entity.shoot.Ball.attach(game,x,y);
		s.moveToTarget( ballTarget, s.shootSpeed );
		s.targetCatcher = ballTarget;

	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id) {
		super.onEndAnim(id);
		ballTarget = null;
	}


	/*------------------------------------------------------------------------
	PRÉPARATION DU TIR (skippé)
	------------------------------------------------------------------------*/
	function startShoot() {
		if ( !fl_ball || catchCD>0 ) {
			return;
		}


		// Cherche un receveur
		var l = game.getListCopy(Data.CATCHER);
		var bad : entity.bad.Walker;
		do {
			var i = Std.random(l.length);
			bad = downcast(l[i]);
			l.splice(i,1);
		} while ( bad!=null && ( bad==this || !bad.isReady() ) );


		if ( bad!=null ) {
			ballTarget = upcast(bad);
		}
		else {
			if ( game.getList(Data.CATCHER).length==1 ) {
				// Vise le joueur
				ballTarget = game.getOne(Data.PLAYER);
				if ( ballTarget==null ) {
					return;
				}
			}
			else {
				return;
			}
		}

		super.startShoot();
	}

	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		if ( fl_ball ) {
			// Ré-attribution de la balle
			var bad : entity.bad.walker.Fraise = downcast(game.getAnotherOne(Data.CATCHER, this));
			if ( bad!=null ) {
				bad.assignBall();
			}
		}
		super.destroy();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();

		// Balle en main
		if ( fl_ball ) {
			downcast(sub).balle._visible = true;
		}
		else {
			downcast(sub).balle._visible = false;
		}

		// Se tourne dans la direction du tir
		if ( dx==0 && ballTarget.fl_destroy==false ) {
			if ( ballTarget.x > x ) {
				_xscale = Math.abs(_xscale);
			}
			if ( ballTarget.x < x ) {
				_xscale = -Math.abs(_xscale);
			}
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		if ( catchCD > 0 ) {
			catchCD -= Timer.tmod;
			if ( catchCD <= 0 ) {
				catchCD = 0;
			}
		}

		// Patch: perte de balle
		if ( game.countList(Data.BALL)==0 ) {
			var fl_lost = true;
			var bl = game.getList(Data.BAD_CLEAR);
			for ( var i=0;i<bl.length;i++) {
				if ( downcast(bl[i]).fl_ball ) {
					fl_lost = false;
				}
			}
			if ( fl_lost ) {
				assignBall();
			}
		}
	}


}

