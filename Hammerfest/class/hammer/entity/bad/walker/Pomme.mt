class entity.bad.walker.Pomme extends entity.bad.Shooter {

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;

		setJumpUp(3) ;
		setJumpH(100) ;
		setClimb(100,1);
		setFall(20) ;
		setShoot(2) ;

		initShooter(20, 12) ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_POMME];
		var mc : entity.bad.walker.Pomme = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	EVENT: TIR
	------------------------------------------------------------------------*/
	function onShoot() {
		var s = entity.shoot.Pepin.attach(game, x,y) ;
		if ( dir<0 ) {
			s.moveLeft(s.shootSpeed) ;
		}
		else {
			s.moveRight(s.shootSpeed) ;
		}
	}

}

