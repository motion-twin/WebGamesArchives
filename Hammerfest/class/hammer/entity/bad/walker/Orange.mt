class entity.bad.walker.Orange extends entity.bad.Jumper {

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpH(100) ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_ORANGE];
		var mc : entity.bad.walker.Orange = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}

}

