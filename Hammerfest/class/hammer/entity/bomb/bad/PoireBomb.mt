class entity.bomb.bad.PoireBomb extends entity.bomb.BadBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration = 45;
		power = 30;
		radius = Data.CASE_WIDTH*4;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_poire";
		var mc : entity.bomb.bad.PoireBomb = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb(g, x,y );
		return mc;
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return attach(game, x,y);
	}


	/*------------------------------------------------------------------------
	GÈLE LA BOMBE
	------------------------------------------------------------------------*/
//	function getFrozen(uid) {
//		var b = entity.bomb.player.PoireBombFrozen.attach(game, x, y);
//		b.uniqId = uid;
//		return b;
//	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();

		game.fxMan.attachExplodeZone(x,y,radius);

		var l = game.getClose(Data.PLAYER,x,y,radius,false);

		for (var i=0;i<l.length;i++) {
			var e : entity.Player = downcast(l[i]);
			e.killHit(0);
			shockWave( e, radius, power );
			if ( !e.fl_shield ) {
				e.dy = -10-Std.random(20);
			}
		}
	}


	/*------------------------------------------------------------------------
	EVENT: KICK (CES BOMBES SONT FACILEMENT REPOUSSABLES)
	------------------------------------------------------------------------*/
	function onKick(p) {
		super.onKick(p);
		setLifeTimer( lifeTimer + Data.SECOND*0.5 );
	}
}

