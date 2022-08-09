import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Goal {

	//public var level : Int ;
	public var toExplode : Bool ;
	public var explosionCount : mt.flash.Volatile<Int>;
	public var side : Int ;
	public var index : Int ;

	public var mc : flash.MovieClip ;
	var mcExplose : flash.MovieClip ;
	var mcPoints : {>flash.MovieClip, _field : flash.TextField} ;


	public function new() {
		//level = 0 ;
		toExplode = false ;
		explosionCount = 0 ;

		mc = Game.me.dm.attach("goal", Game.DP_GOALS) ;
		mc.smc.gotoAndStop(1) ;
		mc._xscale = 70 ;
		mc._yscale = 70 ;
	}


	public function setPos(s : Int, index : Int) {
		side = s ;
		this.index = index ;

		if (side == 0) {
			mc._x = Cs.BOARD_X + -1 * Cs.TILE_SIZE ;
			mc._xscale = -70 ;
		} else
			mc._x = Cs.BOARD_X + Cs.BOARD_WIDTH * Cs.TILE_SIZE ;

		mc._y = Cs.BOARD_Y + index * Cs.TILE_SIZE ;

		//mc.smc.gotoAndStop(/*side + 2*/1) ;


	}


	public function activate(?justLight : Int) {
		if (justLight == null || justLight == Cs.PARSE_IN) {
			toExplode = true ;
			Game.me.explode[side]++ ;
		}
		mc.smc.gotoAndStop(side + 2) ;

		mc.smc.smc.gotoAndPlay(Game.me.cTile.mc.smc.smc.smc._currentframe) ;

	}

	public function charge() {
		mc.smc.gotoAndStop(2) ;
		mc.smc.smc.gotoAndPlay(Game.me.cTile.mc.smc.smc.smc._currentframe) ;
		Filt.glow(mc, 10,2,0xFFFFFF) ;
		Game.parts(mc._x, mc._y) ;
	}


	public function shutdown() {
		toExplode = false ;
		mc.smc.gotoAndStop(1) ;
	}


	public function explode() {
		var points = KKApi.cmult(KKApi.cmult(Cs.GOAL_POINTS,  KKApi.const(Std.int(Math.max(Game.me.getExplosions(),1)))), KKApi.const(Cs.COMBO_MULT[Game.me.combo])) ;
		Game.me.addScore(points) ;
		prepare() ;
	}


	public function prepare() {
		toExplode = false ;
		unLight() ;
		explosionCount++ ;

	}


	public function unLight() {
		mc.filters = [] ;
		mc.smc.gotoAndStop(1) ;

	}

}