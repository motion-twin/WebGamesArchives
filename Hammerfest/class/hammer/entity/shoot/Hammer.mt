class entity.shoot.Hammer extends entity.Shoot
{
	var player	: entity.Player;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		shootSpeed = 0 ;
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
		var linkage = "hammer_shoot_hammer" ;
		var s : entity.shoot.Hammer = downcast( g.depthMan.attach(linkage,Data.DP_SPEAR) ) ;
		s.initShoot(g, x, y-10) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		player.specialMan.interrupt(85);
		game.fxMan.attachFx(x,y-Data.CASE_HEIGHT/2, "hammer_fx_pop") ;
		super.destroy() ;
	}


	/*------------------------------------------------------------------------
	DÉFINI LE PORTEUR
	------------------------------------------------------------------------*/
	function setOwner(p) {
		player = p;
	}


	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate();
		if ( player.dir>0 && _xscale<0 ) {
			_xscale = Math.abs(_xscale);
		}
		if ( player.dir<0 && _xscale>0 ) {
			_xscale = -Math.abs(_xscale);
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		var hx = player.x + player.dir*Data.CASE_WIDTH*0.7;
		hx = Math.min(Data.GAME_WIDTH-1,hx);
		hx = Math.max(1,hx);
		var hy = player.y-Data.CASE_HEIGHT*0.7;
		hx = Math.max( 1, Math.min(Data.GAME_WIDTH-1, hx) );
		hy = Math.max( 20, Math.min(Data.GAME_HEIGHT-1, hy) );
		moveTo(
			hx,
			hy
		);
		super.update();

		// Contact
		var l = game.getClose(Data.BAD, x,y, Data.CASE_WIDTH*2, false);
		for (var i=0;i<l.length;i++) {
			downcast(l[i]).killHit(player.dir*9);
		}

		if ( player.fl_kill || game.fl_clear || !player.specialMan.actives[85] ) {
			destroy();
		}
	}

}
