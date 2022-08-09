class entity.bad.walker.Kiwi extends entity.bad.Shooter
{
	var mineList		: Array<entity.bomb.bad.Mine>;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new() {
		super() ;
		setJumpUp(10) ;
		setJumpDown(20)//6) ;
		setJumpH(50) ;
		setClimb(100,3);

		setShoot(3) ;
		initShooter(Data.SECOND*1, Data.SECOND*0.6) ;

		speed *= 0.7;
		angerFactor *= 2.5;
		calcSpeed();
		shootCD = 0;

		mineList = new Array();
	}


	/*------------------------------------------------------------------------
	ATTACHEMENT
	------------------------------------------------------------------------*/
	static function attach(g:mode.GameMode,x,y) {
		var linkage = Data.LINKAGES[Data.BAD_KIWI];
		var mc : entity.bad.walker.Kiwi = downcast( g.depthMan.attach(linkage,Data.DP_BADS) ) ;
		mc.initBad(g,x,y) ;
		return mc ;
	}


	/*------------------------------------------------------------------------
	EVENT: POSE DE MINE
	------------------------------------------------------------------------*/
	function onShoot() {
		var m = entity.bomb.bad.Mine.attach(
			game,
			x+dir*Data.CASE_WIDTH*1.1,
			y
		);
		mineList.push(m);
	}


	/*------------------------------------------------------------------------
	EFFACE TOUTES LES MINES POSÉES PAR CE BAD
	------------------------------------------------------------------------*/
	function clearMines() {
		for (var i=0;i<mineList.length;i++) {
			var m = mineList[i];
			if ( !m.fl_trigger ) {
				m.setLifeTimer( Std.random( Math.round(Data.SECOND*0.7) ) );
			}
		}
		mineList = new Array();
	}
}

