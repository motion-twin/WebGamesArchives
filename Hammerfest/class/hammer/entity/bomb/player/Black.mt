class entity.bomb.player.Black extends entity.bomb.PlayerBomb {

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		duration = 100 ;
		power = 20 ;
		explodeSound="sound_bomb_black";
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_black" ;
		var mc : entity.bomb.player.Black = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) ) ;
		mc.initBomb(g, x,y ) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return attach(game, x,y) ;
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode() ;

		var l = bombGetClose(Data.BAD) ;
		game.shake(10,4) ;
		game.fxMan.attachExplodeZone(x,y,radius);

		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]) ;
			e.setCombo(uniqId) ;
			e.killHit(0);
			shockWave( e, radius, power) ;
			e.dy = -10-Std.random(20) ;
		}
	}

}

