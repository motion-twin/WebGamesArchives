class entity.supa.IceMeteor extends entity.Supa
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
		var linkage = "hammer_supa_icemeteor";
		var mc : entity.supa.IceMeteor = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.initSupa(g, Data.GAME_WIDTH,0 );
		return mc;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		speed = 10;
		radius = 50;
		moveToAng(130,speed);
		setLifeTimer(Data.SUPA_DURATION);
	}


	/*------------------------------------------------------------------------
	INFIXE
	------------------------------------------------------------------------*/
	function prefix() {
		super.prefix();
		var l = game.getClose( Data.BAD, x,y, radius, false );
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			if ( !e.fl_freeze ) {
				e.freeze(Data.FREEZE_DURATION);
				e.dx = dx*2;
				e.dy = -5;
			}
		}
	}


	/*------------------------------------------------------------------------
	POSTFIXE
	------------------------------------------------------------------------*/
	function postfix() {
		super.postfix();
		rotation-=7*Timer.tmod;
		if ( !world.shapeInBound(this) ) {
			moveTo(Data.GAME_WIDTH,0);
		}
	}

}
