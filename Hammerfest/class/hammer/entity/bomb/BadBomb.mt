class entity.bomb.BadBomb extends entity.Bomb
{
	var owner : entity.Bad;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		fl_airKick = true;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.BAD_BOMB);
	}

	/*------------------------------------------------------------------------
	INITIALISATION BOMBE
	------------------------------------------------------------------------*/
	function initBomb(g,x,y) {
		super.initBomb(g,x,y);
		if ( game.fl_bombExpert ) {
			radius*=1.4;
		}
	}


	/*------------------------------------------------------------------------
	DÉFINI LE BAD PARENT DE LA BOMBE
	------------------------------------------------------------------------*/
	function setOwner(b) {
		owner = b;
	}


	/*------------------------------------------------------------------------
	GÈLE LA BOMBE ET LA REND DANGEUREUSE POUR LE BAD
	------------------------------------------------------------------------*/
	function getFrozen(uid:int) : entity.Bomb {
		return null; // do nothing
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();
		if ( game.getDynamicVar("$BAD_BOMB_TRIGGER")!=null ) {
			game.onExplode(x,y,radius);
		}
	}

	/*------------------------------------------------------------------------
	EVENT: KICK (BOMBES FACILES À REPOUSSER)
	------------------------------------------------------------------------*/
	function onKick(p) {
		super.onKick(p);
		dx*=3;
	}
}

