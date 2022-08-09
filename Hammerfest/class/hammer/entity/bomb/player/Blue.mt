class entity.bomb.player.Blue extends entity.bomb.PlayerBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration = 45;
		power = 20;
		explodeSound="sound_bomb_blue";
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_blue";
		var mc : entity.bomb.player.Blue = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb( g, x,y );
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

		var l = bombGetClose(Data.BAD);

		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			e.setCombo(uniqId);
			e.knock(Data.KNOCK_DURATION*0.75);
			shockWave(e,radius,power);
			e.dx *= 0.3;
			e.dy = -6;
			e.yTrigger = e.y+Data.CASE_HEIGHT*1.5;
			e.fl_hitGround = false;
		}
	}

}

