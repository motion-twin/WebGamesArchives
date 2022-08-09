class entity.bad.flyer.Tzongre extends entity.bad.Flyer
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		unregister( Data.BAD_CLEAR );
	}


	/*------------------------------------------------------------------------
	ANNULATION DE CERTAINES FONCTIONNALITÉS
	------------------------------------------------------------------------*/
	function freeze(d) {}
	function knock(d) {}
	function killHit(dx) {}


	/*------------------------------------------------------------------------
	RENCONTRE UNE AUTRE ENTITÉ
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		// Joueur
		if ( (e.types & Data.PLAYER) > 0 ) {
			var et : entity.Player = downcast(e) ;
			game.fxMan.attachFx(x,y-Data.CASE_HEIGHT,"hammer_fx_shine") ;
			et.getScore(this, 50000) ;
			this.destroy() ;
		}

		// Bads
		if ( (e.types & Data.BAD) >0 ) {
			var et : entity.Bad = downcast(e) ;
			et.knock(Data.KNOCK_DURATION) ;
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_TZONGRE];
		var mc : entity.bad.flyer.Tzongre = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		mc.setLifeTimer(Data.SECOND*60) ;
		return mc ;
	}
}

