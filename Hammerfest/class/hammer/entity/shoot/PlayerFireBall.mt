class entity.shoot.PlayerFireBall extends entity.Shoot
{

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		shootSpeed = 8;
		coolDown = Data.SECOND*2;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.PLAYER_SHOOT) ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_player_fireball";
		var s : entity.shoot.PlayerFireBall = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) );
		s.initShoot(g, x, y);
		return s;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.BAD_CLEAR) > 0 ) {
			var et : entity.Bad = downcast(e);
			et.setCombo(uniqId);
			et.burn();
		}
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		game.fxMan.inGameParticles(Data.PARTICLE_SPARK, x,y,3);
		game.fxMan.inGameParticles(Data.PARTICLE_STONE, x,y,4);
		super.destroy();
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();

		// Trainées
		if ( Std.random(3)==0 ) {
			game.fxMan.inGameParticles(Data.PARTICLE_SPARK, x,y,Std.random(3));
		}
	}

}

