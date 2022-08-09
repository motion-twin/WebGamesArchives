class entity.bad.walker.Litchi extends entity.bad.Jumper {

	var child	: entity.bad.walker.LitchiWeak;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		speed*=0.8;
		setJumpH(100) ;
		setJumpUp(10);
		setJumpDown(6);
		setClimb(25,3);
		setFall(25);
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_LITCHI];
		var mc : entity.bad.walker.Litchi = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	OVERRIDE DES CONDITIONS DE MORT
	------------------------------------------------------------------------*/
	function freeze(d) {
		weaken();
	}
	function killHit(dx) {
		if ( !fl_knock ) {
			knock(Data.KNOCK_DURATION);
//			if ( dx<0 ) {
//				moveToAng(-135, 8);
//			}
//			else {
//				moveToAng(-45, 8);
//			}
		}
	}


	/*------------------------------------------------------------------------
	HACK: PERMET UNE MORT INSTANTANÉE
	------------------------------------------------------------------------*/
	function forceKill(dx) {
		super.killHit(dx);
	}


	/*------------------------------------------------------------------------
	PERTE D'ARMURE
	------------------------------------------------------------------------*/
	function weaken() {
		if ( child._name != null ) {
			return;
		}
		child = entity.bad.walker.LitchiWeak.attach(game,x,y-Data.CASE_HEIGHT);
		child.angerMore();
		child.updateSpeed();
		child.halt();
		child.dir = dir;
		child.fl_ninFoe = fl_ninFoe;
		child.fl_ninFriend = fl_ninFriend;
		game.fxMan.inGameParticles(
			Data.PARTICLE_LITCHI,
			x + Std.random(20)*(Std.random(2)*2-1),
			y-Std.random(20),
			Std.random(3)+5
		);
		child.playAnim(Data.ANIM_BAD_SHOOT_START);
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function update() {
		super.update();
		if ( !fl_kill && fl_knock && child==null && dy<=-Data.BAD_VJUMP_Y*0.6 ) {
			dy = -Data.BAD_VJUMP_Y*0.6;
		}
	}


	/*------------------------------------------------------------------------
	HACK POUR UTILISER LE DX/DY APRES SHOCKWAVE DU LITCHI GELÉ
	------------------------------------------------------------------------*/
	function endUpdate() {
		if ( child!=null ) {
//			child.dx = dx*0.5;
			child.dy = -7; // -13
			destroy();
		}
		else {
			super.endUpdate();
		}
	}

}

