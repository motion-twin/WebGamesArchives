class entity.bad.walker.Framboise extends entity.bad.Shooter {
	static var FRAGS = 6;
	static var MAX_TRIES = 1000;
	var tx			: float;
	var ty			: float;
	var fl_phased	: bool;
	var arrived		: int;
	var white		: float;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;

		setJumpUp(3) ;
		setJumpDown(6) ;
		setJumpH(100) ;
		setClimb(100,3);
		setFall(20) ;
		setShoot(0.7) ;

		initShooter(20, 12) ;

		white = 0;
		fl_phased = false;
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
		var linkage = Data.LINKAGES[Data.BAD_FRAMBOISE];
		var mc : entity.bad.walker.Framboise = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	APPROXIMATIVE COORDS
	------------------------------------------------------------------------*/
	function aroundX(base) {
		return base + Std.random(Data.CASE_WIDTH) * (Std.random(2)*2-1);
	}

	function aroundY(base) {
		return base - Std.random(Data.CASE_HEIGHT);
	}


	function isReady() {
		return super.isReady() && !fl_phased;
	}


	/*------------------------------------------------------------------------
	BAD'S EVENTS
	------------------------------------------------------------------------*/
	function freeze(d) {
		phaseIn();
		super.freeze(d);
	}

	function knock(d) {
		phaseIn();
		super.knock(d);
	}

	function killHit(dx) {
		phaseIn();
		super.killHit(dx);
	}

	function destroy() {
		clearFrags();
		super.destroy();
	}

	function onHitGround(h) {
		super.onHitGround(h);
		if ( h>=Data.CASE_HEIGHT*2 ) {
			game.fxMan.inGameParticles( Data.PARTICLE_FRAMB_SMALL, x,y, Std.random(4)+2 );
		}
	}


	/*------------------------------------------------------------------------
	A FRAGMENT HAS ARRIVED
	------------------------------------------------------------------------*/
	function onArrived(fb) {
		show();
		moveTo( tx, ty );
		fb.destroy();
		if ( fb._currentframe>=5 ) {
			if ( fb._currentframe==5 ) {
				downcast(this.sub).o1._visible = true;
			}
			else {
				downcast(this.sub).o2._visible = true;
			}
		}
		else {
			this.sub.nextFrame();
		}

		arrived++;
		if ( arrived>=FRAGS ) {
			phaseIn();
		}
	}


	/*------------------------------------------------------------------------
	DELETE ALL FRAGS
	------------------------------------------------------------------------*/
	function clearFrags() {
		var sl = game.getList(Data.SHOOT);
		for (var i=0;i<sl.length;i++) {
			var s=sl[i];
			if ( downcast(s).owner==this ) {
				s.destroy();
			}
		}
	}


	/*------------------------------------------------------------------------
	PHASING
	------------------------------------------------------------------------*/
	function phaseOut() {
		game.fxMan.inGameParticles( Data.PARTICLE_FRAMB_SMALL, x,y, Std.random(3)+2 );
		game.fxMan.attachExplosion(x,y,40);
		fl_phased = true;
		dx = 0;
		dy = 0;
		disableShooter();
		disableAnimator();
		this.gotoAndStop("15");
		this.sub.stop();
		downcast(this.sub).o1._visible = false;
		downcast(this.sub).o2._visible = false;
		hide();
	}

	function walk() {
		if ( !fl_phased ) super.walk();
	}

	function phaseIn() {
		clearFrags();
		fl_phased = false;
		enableAnimator();
		enableShooter();
		var a = game.fxMan.attachExplosion(x,y,40);
//		a.mc.blendMode = BlendMode.NORMAL;
//		white = 1;
	}


	/*------------------------------------------------------------------------
	EVENT: TIR
	------------------------------------------------------------------------*/
	function onShoot() {
		var tries = 0;
		var ctx;
		var cty;
		var d;
		var fl_inv;
		do {
			fl_inv = false;
			ctx = Std.random(Data.LEVEL_WIDTH);
			cty = Std.random(Data.LEVEL_HEIGHT);
			tries++;
			d = distanceCase(ctx,cty);
			if ( d<=7 ) fl_inv = true;
			if ( !game.world.checkFlag( {x:ctx,y:cty}, Data.IA_TILE_TOP) ) fl_inv = true;
			if ( game.world.checkFlag( {x:ctx,y:cty}, Data.IA_SMALL_SPOT) ) fl_inv = true;
			if ( game.getListAt(Data.SPEAR,ctx,cty).length>0 ) fl_inv = true;
		} while ( tries<MAX_TRIES && fl_inv );
		if ( tries>=MAX_TRIES ) {
			return;
		}
		tx = Entity.x_ctr(ctx);
		ty = Entity.y_ctr(cty);
		arrived = 0;
		phaseOut();

		var s;
		for (var i=0;i<FRAGS;i++) {
			s = entity.shoot.FramBall.attach(game, aroundX(x),aroundY(y)) ;
			s.setOwner(this);
			s.gotoAndStop(""+(i+1));
		}
	}

	/*------------------------------------------------------------------------
	GRAPHICAL UPDATE
	------------------------------------------------------------------------*/
	public function endUpdate() {
		super.endUpdate();
		if ( white>0 ) {
			setColorHex(Math.round(100*white), 0xffffff);
	    	var f = new flash.filters.GlowFilter();
			f.color = 0xffffff;
	    	f.strength	= white*2;
	    	f.blurX		= 4;
	    	f.blurY		= f.blurX;
	    	this.filters = [f];
	    	white-=Timer.tmod*0.1;
	    	if ( white<=0 ) {
	    		this.filters = [];
	    	}
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	public function update() {
		if ( !_visible ) {
			moveTo(100,-200);
			if ( !isHealthy() ) {
				show();
				moveTo( tx, ty );
				phaseIn();
			}
		} else {
			var bl = game.getClose(Data.PLAYER_BOMB, x,y, 90, false);
			if ( isReady() && bl.length>=1 ) {
				startShoot();
			}
		}

		super.update();
	}

}

