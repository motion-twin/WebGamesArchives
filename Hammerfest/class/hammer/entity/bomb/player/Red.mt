class entity.bomb.player.Red extends entity.bomb.PlayerBomb
{

	var JUMP_POWER : int;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration = 38;
		power = 30;
		JUMP_POWER = 32;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_red";
		var mc : entity.bomb.player.Red = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb(g, x,y);
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

		// freeze bads
		var l = bombGetClose(Data.BAD);
		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]);
			e.setCombo(uniqId);
			e.freeze(Data.FREEZE_DURATION);
			shockWave( e, radius, power);
			if ( e.dy<0 ) {
				e.dy*=3;
				if ( distance(e.x,e.y)<=radius*0.5 ) {
					e.dx *= 0.5;
					e.dy *= 2;
				}
			}
		}

//		// freeze bad bombs
//		l = bombGetClose(Data.BAD_BOMB);
//		for (var i=0;i<l.length;i++) {
//			var b : entity.bomb.BadBomb = downcast(l[i]);
//			if ( !b.fl_explode ) {
//				var bf = b.getFrozen(uniqId);
//				if ( bf!=null ) {
//					shockWave( bf, radius, power );
//					b.destroy();
//				}
//			}
//		}

		// fx
		game.fxMan.inGameParticles(Data.PARTICLE_ICE, x,y, Std.random(2)+2);
		game.fxMan.attachExplodeZone(x,y,radius);


		// player bomb jump
		l = game.getList(Data.PLAYER) ;
		for (var i=0;i<l.length;i++) {
			var e : entity.Player = downcast(l[i]);
			var distX = (e.x-x);
			var distY = (e.y-y);

			// Facilite le bomb jump
			if ( fl_stable ) {
				distX *= 1.5;
				distY *= 0.5;
			}
			else {
				distX *= 0.9;
				distY *= 0.35;
			}

			var dist = Math.sqrt( distX*distX + distY*distY );
			if ( dist <= 40 ) {
				if ( e.dy > 0 ) {
					e.dy = 0;
				}
				e.dy -= JUMP_POWER;
				if ( e.dy<=-35 ) {
					game.shake(10,3);
					game.fxMan.attachExplodeZone(e.x,e.y-40, 50);
					game.fxMan.attachExplodeZone(e.x,e.y-80, 40);
					game.fxMan.attachExplodeZone(e.x,e.y-120, 30);
				}
			}
			else {
				if ( e.distance(x,y)<=radius ) {
					shockWave( e, radius, power );
				}
			}
		}

	}
}

