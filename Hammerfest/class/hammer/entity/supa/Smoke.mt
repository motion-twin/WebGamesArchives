class entity.supa.Smoke extends entity.Supa
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_blink = false;
	}


	/*------------------------------------------------------------------------
	INIT
	------------------------------------------------------------------------*/
	function initSupa(g,x,y) {
		super.initSupa(g,x,y);
		scale(265);
		setLifeTimer(Data.SECOND*3);
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode) {
		var linkage = "hammer_supa_smoke";
		var mc : entity.supa.Smoke = downcast( g.depthMan.attach(linkage,Data.DP_SUPA) );
		mc.initSupa(g, Data.GAME_WIDTH/2,Data.GAME_HEIGHT/2 );
		return mc;
	}

}

