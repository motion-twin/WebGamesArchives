class entity.bomb.player.Green extends entity.bomb.PlayerBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		duration		= 200 ;
		power			= 25 ;
		fl_blink		= true;
		fl_alphaBlink	= false;
		fl_unstable		= true;
		explodeSound	= "sound_bomb_green";
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_green" ;
		var mc : entity.bomb.player.Green = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) ) ;
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
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate() ;
		rotation = 0 ;
		_rotation = rotation ;
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		if ( fl_explode ) return;

		game.soundMan.playSound("sound_bomb", Data.CHAN_BOMB);

		super.onExplode() ;


		var l = bombGetClose(Data.BAD) ;

		for (var i=0;i<l.length;i++) {
			var e : entity.Bad = downcast(l[i]) ;
			e.setCombo(uniqId) ;
			e.freeze(Data.FREEZE_DURATION) ;
			shockWave( e, radius, power) ;
		}
		game.fxMan.inGameParticles(Data.PARTICLE_ICE, x,y, Std.random(2)+2) ;

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

