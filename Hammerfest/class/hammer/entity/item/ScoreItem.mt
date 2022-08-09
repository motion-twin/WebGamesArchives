class entity.item.ScoreItem extends entity.Item
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
	}

	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
	}

	function initItem(g,x,y,i,si) {
		super.initItem(g,x,y,i,si);
		if ( id==Data.CONVERT_DIAMANT ) {
			register(Data.PERFECT_ITEM);
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y, id, subId) {
		var mc : entity.item.ScoreItem = downcast( g.depthMan.attach("hammer_item_score",Data.DP_ITEMS) );
		if ( id>=1000 ) {
			id -= 1000;
		}
		mc.initItem(g,x,y,id,subId);
		return mc;
	}


	/*------------------------------------------------------------------------
	ACTIVE L'ITEM AU PROFIT DE "E"
	------------------------------------------------------------------------*/
	function execute(p:entity.Player) {
		var value : int = Data.ITEM_VALUES[id+1000];

		game.soundMan.playSound("sound_item_score", Data.CHAN_ITEM);

		if ( value==0 || value==null ) {

			switch (id) {
				case 0: // Cristaux
					value = Data.getCrystalValue(subId);
				break;
				case Data.DIAMANT: // Diamant par défaut
					value = 2000;
				break;
				case Data.CONVERT_DIAMANT: // Diamant de conversion de niveau
					value = Math.round(  Math.min( 10000, 75*Math.pow(subId+1,4) )  );
				break;
				default:
					GameManager.fatal("null value");
				break;
			}
		}

		p.getScore(this,value);
		game.pickUpScore(id,subId);

		// Recherche rarity
		var r		= null;
		var i		= 0;
		var family	= Data.SCORE_ITEM_FAMILIES;
		while (r==null && i<family.length) {
			var j=0;
			while (r==null && j<family[i].length) {
				if ( family[i][j].id == id+1000 ) {
					r = family[i][j].r;
				}
				j++;
			}
			i++;
		}

		if ( r>0 ) {
			game.attachItemName( Data.SCORE_ITEM_FAMILIES, id+1000 );
		}

		super.execute(p);
	}

}

