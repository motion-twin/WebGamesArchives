class entity.shoot.FireRain extends entity.Shoot
{


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		shootSpeed		= 10+Std.random(5);
		fl_checkBounds	= false;
//		fl_hitWall		= true;
//		fl_hitGround	= true;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		playAnim(Data.ANIM_SHOOT_LOOP) ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_firerain" ;
		var s : entity.shoot.FireBall = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) ) ;
		s.initShoot(g, x, y-10) ;
		return s ;
	}


	/*------------------------------------------------------------------------
	EVENTS: LIGNE DU BAS
	------------------------------------------------------------------------*/
	function onDeathLine() {
		destroy();
	}



	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		super.destroy() ;
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.BAD_CLEAR) > 0 ) {
			var et : entity.Bad = downcast(e) ;
			game.fxMan.inGameParticles(Data.PARTICLE_SPARK,x,y,Std.random(5)+1);
			et.burn();
			destroy();
		}
	}


	/*------------------------------------------------------------------------
	EVENTS: CONTACT AVEC LE LEVEL
	------------------------------------------------------------------------*/
	function onHitWall() {
		hitLevel();
	}
	function onHitGround(h) {
		hitLevel();
	}


	/*------------------------------------------------------------------------
	TOUCHE UN DECOR
	------------------------------------------------------------------------*/
	function hitLevel() {
		game.fxMan.attachExplodeZone(x,y,30);
		game.fxMan.inGameParticles(Data.PARTICLE_STONE,x,y,Std.random(4));
		destroy();
	}


	/*------------------------------------------------------------------------
	ENTRÉE DANS UNE NOUVELLE CASE
	------------------------------------------------------------------------*/
//	function infix() {
//		super.infix();
//		if ( world.getCase( {x:cx,y:cy} )>0 && Std.random(10)==0 ) {
//			hitLevel();
//			fl_stopStepping = true;
//		}
//	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();
		if ( x<0 ) {
			hitLevel();
		}
	}

}

