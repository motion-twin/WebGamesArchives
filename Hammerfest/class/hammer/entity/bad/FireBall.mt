class entity.bad.FireBall extends entity.Bad
{
	var eyes : MovieClip ;
	var body : MovieClip ;

	var ang : float ;
	var tang : float ;
	var speed : float ;
	var angSpeed : float ;

	var angerTimer : float ;
	var summonTimer : float ;
	var fl_summon : bool ;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		disableAnimator() ;
		fl_hitGround = false ;
		fl_hitWall = false ;
		fl_gravity = false ;
		fl_hitBorder = false ;

		fl_alphaBlink = true;

		speed		= 2.5 ;
		angSpeed	= 1.5 ;
		ang			= 270 ;

		summonTimer = 85 ;
		fl_summon = true ;
		blink(Data.BLINK_DURATION) ;

		angerTimer = 0 ;
		angerFactor = 0.05 ;
		maxAnger = 9999;
	}


	/*------------------------------------------------------------------------
	INITIALISATION
	------------------------------------------------------------------------*/
	function init(g) {
		super.init(g) ;
		register( Data.HU_BAD ) ;
		unregister( Data.BAD_CLEAR );
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode, p:entity.Player) {
		var linkage = Data.LINKAGES[Data.BAD_FIREBALL]; ;
		var mc : entity.bad.FireBall = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		var n = g.countList(Data.PLAYER);
		var offs = (n==1) ? 0 : -30+p.pid*60;

		mc.initBad( g, Data.GAME_WIDTH/2+offs, Data.GAME_HEIGHT+10 );
		mc.hate(p);
		return mc ;
	}


	/*------------------------------------------------------------------------
	ANNULATION D'EVENT
	------------------------------------------------------------------------*/
	function playAnim(o) {
		// do nothing
	}
	function freeze(d) {
		// do nothing
	}
	function knock(d) {
		// do nothing
	}
	function killHit(dx) {
		// do nothing
	}


	/*------------------------------------------------------------------------
	AJOUT SUPPLÉMENTAIRE DANS LES LISTES D'INVENTAIRE
	------------------------------------------------------------------------*/

	function tAdd(cx,cy) {
		super.tAdd(cx,cy) ;
		tAddSingle(cx,cy+1) ;
	}
	function tRem(cx,cy) {
		super.tRem(cx,cy) ;
		tRemSingle(cx,cy+1) ;
	}



	/*------------------------------------------------------------------------
	MISE À JOUR GRAPHIQUE
	------------------------------------------------------------------------*/
	function endUpdate() {
		super.endUpdate() ;
		body._rotation = ang ;
		eyes.gotoAndStop( ""+ (Math.round(ang/360*eyes._totalframes)+1) ) ;
	}


	/*------------------------------------------------------------------------
	INTÉRACTION
	------------------------------------------------------------------------*/
	function hit(e:Entity) {
		if ( fl_summon ) {
			return ;
		}

		if ( (e.types&Data.PLAYER)>0 ) {
			var et : entity.Player = downcast(e) ;
			if ( et.animId!=Data.ANIM_PLAYER_DIE.id ) {
				et.fl_shield = false ;
				et.killHit(dx) ;
			}
		}

		if ( (e.types&Data.BOMB)>0 ) {
			var b : entity.Bomb = downcast(e) ;

			if (!b.fl_kill && !b.fl_explode) {
				b.onExplode() ;
			}
		}
	}

	/*------------------------------------------------------------------------
	EFFETS DE L'ENERVEMENT
	------------------------------------------------------------------------*/
	function angerMore() {
		super.angerMore();
		angSpeed*=1.15;
	}


	/*------------------------------------------------------------------------
	EVENT: HURRY UP!
	------------------------------------------------------------------------*/
	function onHurryUp() {
		// do nothing
	}
	function onDeathLine() {
		// do nothing
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		// Mal d'invocation
		if ( fl_summon ) {
			summonTimer-=Timer.tmod ;
			if ( summonTimer<=0 ) {
				fl_summon = false ;
				stopBlink() ;
			}
		}

		// Mort de la cible
		if ( player.fl_kill || player._name==null) {
			game.fxMan.attachShine(x,y) ;
			game.fxMan.attachExplodeZone(x,y,4*Data.CASE_WIDTH) ;
			game.shake(Data.SECOND*1,5);
			destroy() ;
			return ;
		}

		// Auto-énervement
		angerTimer+=Timer.tmod*game.diffFactor;
		if ( angerTimer>=Data.AUTO_ANGER ) {
			angerTimer = 0 ;
			angerMore() ;
		}

		// Angle vers la cible
		tang = Math.atan2( player.y-y, player.x-x ) ;
		tang = adjustAngle( tang*180/Math.PI ) ;

		// Recalage des angles trop grands
		if ( ang-tang>180 ) {
			ang-=360 ;
		}
		if ( tang-ang>180 ) {
			ang+=360 ;
		}

		// Vise le player
		if ( ang<tang ) {
			ang+=angSpeed*speedFactor*Timer.tmod ;
			if ( ang>tang )
			ang = tang ;
		}
		if ( ang>tang ) {
			ang-=angSpeed*speedFactor*Timer.tmod ;
			if ( ang<tang )
			ang = tang ;
		}

		// Déplacement
		ang = adjustAngle(ang) ;
		moveToAng(ang,speed*speedFactor) ;

		super.update() ;
	}

}


