class entity.supa.Ball extends entity.Supa
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		fl_gravity = true ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_supa_ball" ;
		var mc : entity.supa.Ball = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) ) ;
		mc.initSupa(g, Data.GAME_WIDTH,0 ) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y) ;
		speed = 2 ;
		radius = 40 ;
		fallFactor = 0.8 ;
		gravityFactor = 0.8 ;
		dx = speed ;
		moveTo(0,-50) ;
		scale(220) ;
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix() ;
		var l = game.getClose( Data.BAD, x,y, radius, false ) ;
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]) ;
			if ( !e.fl_knock ) {
				e.knock(Data.KNOCK_DURATION*3) ;
				e.dx = dx*2 ;
				e.dy = -5 ;
			}
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix() ;
		if ( dy>0 && y>=Data.GAME_HEIGHT ) {
			dy = -Math.abs(dy) ;
			game.shake(Data.SECOND*0.5,3);
		}
		if ( x>=Data.GAME_WIDTH+50 ) {
			destroy() ;
		}
	}

}
