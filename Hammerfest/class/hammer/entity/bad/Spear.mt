class entity.bad.Spear extends entity.Bad
{
	var skin			: int;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		disablePhysics();
		disableAnimator();
		skin = 2;
		realRadius = Data.CASE_WIDTH * 0.7;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		unregister( Data.BAD_CLEAR );
		register( Data.SPEAR );
	}


	/*------------------------------------------------------------------------
	INITIALISATION BADS
	------------------------------------------------------------------------*/
	function initBad(g,x,y) {
		super.initBad(g,x,y);
		if ( world.getCase( {x:cx,y:cy+1} )>0 ) {
			this.gotoAndStop("1");
		}
		else {
			if ( world.getCase( {x:cx,y:cy-1} )>0 ) {
				this.gotoAndStop("3");
			}
			else {
				if ( world.getCase( {x:cx-1,y:cy} )>0 ) {
					this.gotoAndStop("2");
				}
				else {
					if ( world.getCase( {x:cx+1,y:cy} )>0 ) {
						this.gotoAndStop("4");
					}
				}
			}
		}

		var ss = game.getDynamicVar("$SPEAR_SKIN");
		if ( ss==null ) {
			sub.gotoAndStop("1");
		}
		else {
			sub.gotoAndStop( ss );
		}

		if ( game.world.scriptEngine.cycle>Data.SECOND ) {
			game.fxMan.attachFx(x+Data.CASE_WIDTH*0.5,y+Data.CASE_HEIGHT*0.5, "hammer_fx_pop");
		}
	}

	function freeze(d) {}
	function knock(d) {}
	function killHit(dx) {}

	function burn() {
		var fx = game.fxMan.attachFx( x,y, "hammer_fx_pop" );
	}


	/*------------------------------------------------------------------------
	TOUCHE UNE ENTITÉ
	------------------------------------------------------------------------*/
	function hit(e) {
		super.hit(e);
		if ( (e.types & Data.BAD_CLEAR)>0 ) {
			var b : entity.Bad = downcast(e);
			if ( b.fl_physics && b.fl_trap ) {
				b.killHit(null);
			}
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_SPEAR];
		var mc : entity.bad.Spear = downcast( g.depthMan.attach(linkage,Data.DP_SPEAR) );
		mc.initBad(g,x,y);
		return mc;
	}

}

