class entity.shoot.FramBall extends entity.Shoot
{
	var turnSpeed			: float;
	public var owner		: entity.bad.walker.Framboise;
	var ang					: float;
	var fl_arrived			: bool;
	var white				: float;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		shootSpeed = 5+Std.random(3) ;
		turnSpeed = 0.03 + Std.random(10)/100 + shootSpeed*0.02;
		_yOffset = -2 ;
		setLifeTimer(Data.SECOND*4);
		fl_checkBounds = false;
		fl_blink = false;
		fl_arrived = false;
		fl_anim = false;
		this.gotoAndStop("1");
		ang = Std.random(314);
		white = 0;
	}


	function setOwner(b) {
		owner = b;
		var tang = Math.atan2(owner.ty-y,owner.tx-x);
		ang = -tang + (Std.random(168)/100) * (Std.random(2)*2-1);
		if ( owner.anger>0 ) {
			shootSpeed*=(1 + owner.anger*0.5);
		}
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_framBall2" ;
		var s : entity.shoot.FramBall = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et : entity.Player = downcast(e) ;
			et.killHit(dx) ;
		}
	}


	function adjustAngRad(a) {
		if ( a<-Math.PI ) return a+Math.PI*2;
		if ( a>Math.PI ) return a-Math.PI*2;
		return a;
	}


	function onLifeTimer() {
		onArrived();
		super.onLifeTimer();
	}


	function onArrived() {
		if ( fl_arrived ) {
			return;
		}
		fl_arrived = true;
		owner.onArrived(this);
	}


	/*------------------------------------------------------------------------
	GRAPHICAL UPDATE
	------------------------------------------------------------------------*/
	public function endUpdate() {
		super.endUpdate();
//		if ( white>0 ) {
//			setColorHex(Math.round(100*white), 0xffffff);
//	    	var f = new flash.filters.GlowFilter();
//			f.color = 0xffffff;
//	    	f.strength	= white*3;
//	    	f.blurX		= 8;
//	    	f.blurY		= f.blurX;
//	    	this.filters = [f];
//		}
	}

	public function infix() {
		super.infix();
		// slow down if close
		var d = distance(owner.tx,owner.ty);
		if ( d<40 ) {
			turnSpeed*=1.1;
		}
		if ( d<20 ) {
			shootSpeed*=0.9;
			if ( shootSpeed<=5.8 || owner.anger>0 ) {
				onArrived();
			}
			white+=0.1*Timer.tmod;
			white = Math.min(1,white);
		}
		turnSpeed = Math.min(1,turnSpeed);
		shootSpeed = Math.max(2,shootSpeed);
	}

	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	public function update() {

		// targetting
		var tang = Math.atan2(owner.ty-y,owner.tx-x);
		if ( adjustAngRad(tang-ang)>0 ) {
			ang+=turnSpeed*Timer.tmod;
		}
		if ( adjustAngRad(tang-ang)<0 ) {
			ang-=turnSpeed*Timer.tmod;
		}

		dx = Math.cos(ang)*shootSpeed * Timer.tmod;
		dy = Math.sin(ang)*shootSpeed * Timer.tmod;
		super.update();
	}
}
