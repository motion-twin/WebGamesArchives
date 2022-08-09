class entity.shoot.PlayerPearl extends entity.Shoot
{

	var shotList			: Array<int>;
	var fl_bounceBorders	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		shootSpeed	= 8.5;
		coolDown	= Data.SECOND*2;
		shotList	= new Array();
		_yOffset	= -16;
		fl_bounceBorders	= false;
	}


	function init(g) {
		super.init(g);
		register(Data.PLAYER_SHOOT) ;
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_player_pearl";
		var s : entity.shoot.PlayerPearl = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) );
		s.initShoot(g, x, y);
		return s;
	}


	/*------------------------------------------------------------------------
	VÉRIFIE SI UN UNIQID DE BAD EST DÉJÀ DANS LA LISTE DES BADS TOUCHÉS
	------------------------------------------------------------------------*/
	function hasBeenShot(id) {
		for (var i=0;i<shotList.length;i++) {
			if ( shotList[i]==id ) {
				return true;
			}
		}
		return false;
	}


	/*------------------------------------------------------------------------
	ANIM AU CONTACT D'UN BORD LATÉRAL
	------------------------------------------------------------------------*/
	function hitWallAnim() {
		game.fxMan.inGameParticles(Data.PARTICLE_ICE, x,y,2);
		game.fxMan.inGameParticles(Data.PARTICLE_STONE, x,y,3);
		if ( dx<0 ) {
			game.fxMan.attachFx(x+Data.CASE_WIDTH*0.5,y+_yOffset,"hammer_fx_icePouf");
		}
		else {
			game.fxMan.attachFx(x-Data.CASE_WIDTH*0.5,y+_yOffset,"hammer_fx_icePouf");
		}
	}


	/*------------------------------------------------------------------------
	EVENT: REBOND BORDS LATÉRAUX
	------------------------------------------------------------------------*/
	function onSideBorderBounce() {
		super.onSideBorderBounce();
		hitWallAnim();
	}


	/*------------------------------------------------------------------------
	EVENT: FIN DE VIE
	------------------------------------------------------------------------*/
	function onLifeTimer() {
		game.fxMan.attachFx(x,y,"hammer_fx_pop");
		super.onLifeTimer();
	}


	/*------------------------------------------------------------------------
	UPDATE GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( dy!=0 ) {
			rotation = Math.atan2( dy, dx ) * 180/Math.PI;
		}

		super.endUpdate();
	}


	function destroy() {
		if ( !fl_bounceBorders ) {
			hitWallAnim();
		}
		super.destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.BAD) > 0 ) {
			var et : entity.Bad = downcast(e);
			if ( !hasBeenShot(et.uniqId) ) {
				et.setCombo(uniqId);
				et.freeze(Data.FREEZE_DURATION);
				et.dx = dx*2;
				et.dy -= 3;
				shotList.push(et.uniqId);
			}
		}
	}


}

