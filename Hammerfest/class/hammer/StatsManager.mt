class StatsManager
{

	var game : mode.GameMode;
	var stats : Array<Stat>;
	var extendList : Array<int>;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(g:mode.GameMode) {
		game = g;
		stats = new Array();
		for (var i=0;i<50;i++) {
			stats[i] = new Stat();
		}
	}


	/*------------------------------------------------------------------------
	LECTURE
	------------------------------------------------------------------------*/
	function read(id) {
		return stats[id].current;
	}
	function getTotal(id) {
		return stats[id].total;
	}

	/*------------------------------------------------------------------------
	ÉCRITURE
	------------------------------------------------------------------------*/
	function write(id,n) {
		stats[id].current = n;
	}
	function inc(id,n) {
		stats[id].inc(n);
	}


	/*------------------------------------------------------------------------
	REMISE À 0 DES CURRENTS
	------------------------------------------------------------------------*/
	function reset() {
		for (var i=0;i<stats.length;i++) {
			stats[i].reset();
		}
	}


	/*------------------------------------------------------------------------
	DISTRIBUTION DES EXTENDS POUR LE NIVEAU EN COURS
	------------------------------------------------------------------------*/
	function countExtend() {
		var nb = 1;
//		if ( read(Data.STAT_SUPAITEM)>=1 ) {
//			nb++;
//		}
		if ( read(Data.STAT_MAX_COMBO)>=2 ) {
			nb += read(Data.STAT_MAX_COMBO)-1;
		}
		return Math.min(7,nb);
	}


	/*------------------------------------------------------------------------
	CALCULE LES EXTENDS POUR LE NIVEAU EN COURS
	------------------------------------------------------------------------*/
	function spreadExtend() {
		var nb = countExtend();

		if ( nb>0 ) {
			game.world.scriptEngine.insertExtend();

			extendList = new Array();
			var l = new Array();

			for (var i=0;i<nb;i++) {
				var id;
				do {
					id = game.randMan.draw(Data.RAND_EXTENDS_ID);
				}
				while (l[id]==true);
				l[id]=true;
				extendList.push(id);
			}
		}
	}


	/*------------------------------------------------------------------------
	ATTACH: LETTRE D'EXTEND
	------------------------------------------------------------------------*/
	function attachExtend() : entity.item.SpecialItem {
		if ( game.fl_clear ) {
			return null;
		}
		var pt = game.world.getGround( Std.random(Data.LEVEL_WIDTH), Std.random(Data.LEVEL_HEIGHT) );
		var x = Entity.x_ctr(pt.x);
		var y = Entity.y_ctr(pt.y);
		var id = extendList[Std.random(extendList.length)];
		var mc = entity.item.SpecialItem.attach(game, x,y, 0, id );
		return mc;
	}


}

