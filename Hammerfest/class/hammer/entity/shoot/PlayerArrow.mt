class entity.shoot.PlayerArrow extends entity.Shoot
{
	var fl_livedOneTurn	: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super();
		shootSpeed	= 4;
		coolDown	= Data.SECOND*2;
		_yOffset	= -15;
		fl_hitWall	= true;
		fl_teleport	= true;
		fl_livedOneTurn	= false;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g);
		register(Data.PLAYER_SHOOT) ;
		playAnim(Data.ANIM_SHOOT_LOOP);
	}


	/*------------------------------------------------------------------------
	ATTACH
	------------------------------------------------------------------------*/
	static function attach( g:mode.GameMode, x,y ) {
		var linkage = "hammer_shoot_arrow";
		var s : entity.shoot.PlayerArrow = downcast( g.depthMan.attach(linkage,Data.DP_SHOTS) );
		s.initShoot(g, x, y);
		return s;
	}


	/*------------------------------------------------------------------------
	EVENT: TOUCHE UN MUR
	------------------------------------------------------------------------*/
	function onHitWall() {
		if ( fl_livedOneTurn ) {
			var fx = game.fxMan.attachFx(x,y+_yOffset, "hammer_fx_arrowPouf");
			if ( dx<0 ) {
				fx.mc._xscale = -fx.mc._xscale;
			}
		}
		else {
			game.fxMan.attachFx(x,y-Data.CASE_HEIGHT*0.5, "hammer_fx_pop");
		}
		destroy();
	}


	/*------------------------------------------------------------------------
	EVENT: HIT
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( (e.types & Data.BAD) > 0 ) {
			var et : entity.Bad = downcast(e);
			et.setCombo(uniqId);
			et.killHit(dx);
			game.fxMan.attachFx(x,y-Data.CASE_HEIGHT*0.5, "hammer_fx_pop");
			destroy();
		}
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();
		fl_livedOneTurn	= true;
	}

}

