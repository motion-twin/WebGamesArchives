class entity.bad.walker.LitchiWeak extends entity.bad.Jumper {

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpH(100) ;
		setJumpUp(10);
		setJumpDown(6);
		setClimb(25,3);
		setFall(25);
	}


	/*------------------------------------------------------------------------
	EVENT: FIN D'ANIM
	------------------------------------------------------------------------*/
	function onEndAnim(id:int) {
		super.onEndAnim(id);
		if ( id==Data.ANIM_BAD_SHOOT_START.id ) {
			playAnim(Data.ANIM_BAD_WALK);
			walk();
		}
	}

	/*------------------------------------------------------------------------
	MARCHER
	------------------------------------------------------------------------*/
	function walk() {
		if ( animId!=Data.ANIM_BAD_SHOOT_START.id ) {
			super.walk();
		}
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_LITCHI_WEAK];
		var mc : entity.bad.walker.LitchiWeak = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


}

