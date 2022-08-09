class entity.supa.Arrow extends entity.Supa
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_supa_arrow";
		var mc : entity.supa.Arrow = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.initSupa(g, Data.GAME_WIDTH,-50 );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		speed = 10;
		radius = 50;
		moveLeft(speed);
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();
		var l = game.getClose( Data.BAD, x,y, radius, false );
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			if ( e.y>=y-Data.CASE_HEIGHT && e.y<=y+Data.CASE_HEIGHT*2 ) {
				if ( !e.fl_kill ) {
					e.killHit(-speed*1.5);
				}
			}
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix();
		if ( !world.shapeInBound(this) ) {
			moveTo( Data.GAME_WIDTH, Std.random(int(Data.GAME_HEIGHT*0.7))+40 );
		}
	}

}
