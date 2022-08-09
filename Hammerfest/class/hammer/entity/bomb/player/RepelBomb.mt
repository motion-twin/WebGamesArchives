class entity.bomb.player.RepelBomb extends entity.bomb.PlayerBomb
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		duration	= 38;
		power		= 20;
		radius		= Data.CASE_WIDTH*3;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = "hammer_bomb_repel";
		var mc : entity.bomb.player.RepelBomb = downcast( g.depthMan.attach(linkage,Data.DP_BOMBS) );
		mc.initBomb(g, x,y);
		return mc;
	}


	/*------------------------------------------------------------------------
	DUPLICATION
	------------------------------------------------------------------------*/
	function duplicate() {
		return attach(game, x,y);
	}


	function onKick(p) {
		super.onKick(p);
		dx*=2.5;
	}


	/*------------------------------------------------------------------------
	EVENT: EXPLOSION
	------------------------------------------------------------------------*/
	function onExplode() {
		super.onExplode();

		// fx
		game.fxMan.inGameParticles(Data.PARTICLE_ICE, x,y, Std.random(2)+2);
		game.fxMan.attachExplodeZone(x,y,radius);


		// Players
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			var p = pl[i];
			var dist = distance( p.x, p.y );
			if ( dist<=radius ) {
				var ratio = (radius-dist)/radius;
				p.knock( Data.SECOND + Data.SECOND*ratio );
				var ang = Math.atan2( p.y-y, p.x-x );
				p.dx = Math.cos(ang)*power*ratio;
				p.dy = Math.sin(ang)*power*ratio;
			}
		}


		// Ballon
		var l = game.getList(Data.SOCCERBALL);
		for (var i=0;i<l.length;i++) {
			var ball : entity.bomb.player.SoccerBall = downcast(l[i]);
			var dist = distance( ball.x, ball.y );
			if ( dist<=radius ) {
				ball.lastPlayer = owner;
				var ratio = (radius-dist)/radius;
				var ang = Math.atan2( ball.y-y, ball.x-x );
				ball.dx = Math.cos(ang)*power*ratio*1.5;
				ball.dy = Math.sin(ang)*power*ratio*1.5;
				if ( ball.dy<4 && ball.dy>-8 ) {
					ball.dy = -8;
				}
				ball.burn();
				if ( ball.fl_stable ) {
					ball.dx *= 2;
				}
				else {
					ball.dx *= 1.5;
				}
			}
		}

	}
}

