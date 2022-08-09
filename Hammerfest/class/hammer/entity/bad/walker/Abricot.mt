class entity.bad.walker.Abricot extends entity.bad.Jumper
{

	var fl_spawner : bool ;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		animFactor = 0.65 ;
		setJumpUp(5) ;
		setJumpH(100) ;
		setClimb(100,3);
		setFall(20) ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		if ( !fl_spawner ) {
			scale(75) ;
		}
		dir = -1 ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y, spawner) {
		var linkage = Data.LINKAGES[Data.BAD_ABRICOT];
		var mc : entity.bad.walker.Abricot = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.fl_spawner = spawner ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	EVENT: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		if ( fl_spawner ) {
			game.attachBad( Data.BAD_ABRICOT2, x-Data.CASE_WIDTH,-30);
			game.attachBad( Data.BAD_ABRICOT2, x+Data.CASE_WIDTH,-30);
//			entity.bad.walker.Abricot.attach( game, x-Data.CASE_WIDTH,-30, false ) ;
//			entity.bad.walker.Abricot.attach( game, x+Data.CASE_WIDTH,-30, false ) ;
		}
		super.onDeathLine() ;
	}

}

