class entity.supa.Tons extends entity.Supa
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_gravity = true;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_supa_tons";
		var mc : entity.supa.Tons = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.initSupa(g, Data.GAME_WIDTH,0 );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		speed = 0;
		radius = 40;
		moveTo(Std.random(Data.GAME_WIDTH),-40);
		fallFactor = 0.3;
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();

		var l;

		// Bads
		l = game.getClose( Data.BAD, x,y, radius, false );
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			if ( !e.fl_kill ) {
				e.killHit( (Std.random(2)*2-1)*Std.random(5) );
				e.dy=-25;
			}
		}

		// Player
		l = game.getClose( Data.PLAYER, x,y, radius, false );
		for (var i=0;i<l.length;i++) {
			var e : entity.Player = downcast(l[i]);
			if ( !e.fl_kill ) {
				e.killHit( (Std.random(2)*2-1)*Std.random(5) );
				e.dy=-25;
			}
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix();
		if ( y>=Data.GAME_HEIGHT*2 ) {
			moveTo(Std.random(Data.GAME_WIDTH),-40);
			dy = 0;
		}
	}

}
