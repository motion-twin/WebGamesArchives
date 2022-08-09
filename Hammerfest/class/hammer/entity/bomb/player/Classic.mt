class entity.bomb.player.Classic extends entity.bomb.PlayerBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration = 45;
		power = 30;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_classic";
		var mc : entity.bomb.player.Classic = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
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
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();

		if ( GameManager.CONFIG.fl_shaky ) {
			game.shake(Data.SECOND*0.35, 1.5);
		}

		var l = bombGetClose(Data.BAD);

		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			e.setCombo(uniqId);
			e.freeze(Data.FREEZE_DURATION);
			shockWave( e, radius, power);
		}
		game.fxMan.inGameParticles(Data.PARTICLE_ICE, x,y, Std.random(2)+2);

		l = bombGetClose(Data.BAD_BOMB);
		for (var i=0;i<l.length;i++) {
			var b : entity.bomb.BadBomb = downcast(l[i]);
			if ( !b.fl_explode ) {
				var bf = b.getFrozen(uniqId);
				if ( bf!=null ) {
					shockWave( bf, radius, power );
					b.destroy();
				}
			}
		}

	}
}

