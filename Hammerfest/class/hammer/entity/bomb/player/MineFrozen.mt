class entity.bomb.player.MineFrozen extends entity.bomb.PlayerBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration = Std.random(20)+15;
		power = 30;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_mine_frozen";
		var mc : entity.bomb.player.MineFrozen = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
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
	REBONDS AUX MURS
	------------------------------------------------------------------------*/
	function onHitWall() {
		dx = -dx;
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();

		game.fxMan.attachExplodeZone(x,y,radius);

		var l = bombGetClose(Data.BAD);
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			e.setCombo(uniqId);
			e.freeze(Data.FREEZE_DURATION);
			shockWave( e, radius, power);
		}


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

