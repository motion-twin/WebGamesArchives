class entity.item.SpecialItem extends entity.Item
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
		super.init(g) ;
		register(Data.SPECIAL_ITEM) ;
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y, id, subId) {
		if ( g.fl_clear && id==0 ) { // pas d'extend si level clear
			return null;
		}
		var mc : entity.item.ScoreItem = downcast( g.depthMan.attach("hammer_item_special",Data.DP_ITEMS) );
		mc.initItem(g,x,y,id,subId) ;
		return mc;
	}


	/*------------------------------------------------------------------------
	ACTIVE L'ITEM AU PROFIT DE "P"
	------------------------------------------------------------------------*/
	function execute(p:entity.Player) {
		if ( id>0 ) {
			game.manager.logAction("$S"+id);
		}
		game.pickUpSpecial(id);
		p.specialMan.execute(this) ;
		game.soundMan.playSound("sound_item_special", Data.CHAN_ITEM);

		if ( id>0 ) {
			game.attachItemName( Data.SPECIAL_ITEM_FAMILIES, id );
		}
		super.execute(p) ;
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();
		if ( id!=0 ) {
			if ( Std.random(4)==0 ) {
				var a = game.fxMan.attachFx(
					x + Std.random(15)*(Std.random(2)*2-1),
					y - Std.random(10),
					"hammer_fx_star"
				);
				a.mc._xscale	= Std.random(70)+30;
				a.mc._yscale	= a.mc._xscale;
			}
		}
	}

}

