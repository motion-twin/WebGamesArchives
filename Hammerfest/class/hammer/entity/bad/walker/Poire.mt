class entity.bad.walker.Poire extends entity.bad.Shooter
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
//		setJumpUp(3) ;
		setJumpH(100) ;
		setClimb(100,1);
//		setFall(20) ;
		setShoot(4) ;
		initShooter(50, 8) ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_POIRE];
		var mc : entity.bad.walker.Poire = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	EVENT: TIR
	------------------------------------------------------------------------*/
	function onShoot() {
		var s = entity.bomb.bad.PoireBomb.attach(game, x,y) ;
		var spd = 10 ;
		if ( dir<0 ) {
			s.moveToAng(-135,spd) ;
		}
		else {
			s.moveToAng(-45,spd) ;
		}
		setNext(null,null,shootDuration,Data.ACTION_FALLBACK) ;
	}

}

