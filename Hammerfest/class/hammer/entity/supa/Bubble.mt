class entity.supa.Bubble extends entity.Supa
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_alphaBlink	= true;
		blinkAlpha		= 25;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_supa_bubble";
		var mc : entity.supa.Bubble = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.initSupa(g, Data.GAME_WIDTH,0 );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		speed = 8;
		radius = 80;
		moveTo(Data.GAME_WIDTH/2,Data.GAME_HEIGHT/2);
		moveToAng(
			45 + (Std.random(30))*(Std.random(2)*2-1) + (Std.random(4)+1)*90,
			speed+Std.random(5)
		);
		setLifeTimer(Data.SECOND*10);
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();
		var l = game.getClose( Data.BAD, x,y, radius, false );
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			if ( !e.fl_knock ) {
				e.knock(Data.KNOCK_DURATION*2);
				e.dx = dx*2;
				e.dy = -5;
				game.fxMan.inGameParticles( Data.PARTICLE_ICE, e.x,e.y-Data.CASE_HEIGHT, Std.random(5) );
//				e.dy = -Math.abs(dy*2);
			}
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix();

		// Rebonds
		if ( y<=0 ) {
			dy = Math.abs(dy);
		}
		if ( y>=Data.GAME_HEIGHT ) {
			dy = -Math.abs(dy);
		}
		if ( x<=0 ) {
			dx = Math.abs(dx);
		}
		if ( x>=Data.GAME_WIDTH ) {
			dx = -Math.abs(dx);
		}
	}


}
