class entity.shoot.Pepin extends entity.Shoot
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		shootSpeed = 5 ;
		_yOffset = -2 ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_pepin" ;
		var s : entity.shoot.Pepin = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et : entity.Player = downcast(e) ;
			et.killHit(dx) ;
		}
	}
}
