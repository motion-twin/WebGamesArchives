class entity.bad.flyer.Baleine extends entity.bad.Flyer
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_BALEINE];
		var mc : entity.bad.flyer.Baleine = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}
}

