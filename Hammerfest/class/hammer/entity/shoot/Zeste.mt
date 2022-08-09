class entity.shoot.Zeste extends entity.Shoot {

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		shootSpeed	= 6 ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_zest" ;
		var s : entity.shoot.Pepin = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	DÉPLACEMENT VERS LE BAS
	------------------------------------------------------------------------*/
	function moveDown(s) {
		super.moveDown(s) ;
		_yscale = -_yscale ;
		_yOffset = -Data.CASE_HEIGHT ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.PLAYER) > 0 ) {
			if (  Math.abs(e.x-x) <= Data.CASE_WIDTH*0.65 ) { // affinement
				var et : entity.Player = downcast(e) ;
				et.killHit( (e.x-x)*1.5 ) ;
				game.fxMan.attachExplodeZone(x,y,15) ;
			}
		}
	}
}
