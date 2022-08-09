class entity.shoot.FireBall extends entity.Shoot
{


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		fl_largeTrigger		= true;
		shootSpeed			= 7 ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		playAnim(Data.ANIM_SHOOT_LOOP) ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_fireball" ;
		var s : entity.shoot.FireBall = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y-10) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT/2, "hammer_fx_pop") ;
		super.destroy() ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.PLAYER) > 0 ) {
			var p : entity.Player = downcast(e) ;
			var dist = distance(p.x,p.y);
			if ( dist<=Data.CASE_WIDTH*1.2 ) {
				game.fxMan.attachExplosion(x,y,25);
				p.killHit(dx) ;
			}
		}
	}

}
