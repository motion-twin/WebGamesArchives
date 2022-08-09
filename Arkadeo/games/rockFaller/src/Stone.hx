
import mt.bumdum9.Lib ;
import mt.bumdum9.Tools;

import api.AKApi ;
import api.AKProtocol ;
import api.AKConst ;



class Stone {

	public static var POINTS = [100, 100, 100, 100, 100, 100, 100] ;


	public var mc : {>MC, _stone : MC, _pk : MC} ;
	public var id : mt.flash.Volatile<Int> ;
	public var rfx : mt.fx.Fx ;
	public var isNew : Bool ;

	var akInfo : Null<api.SecureInGamePrizeTokens> ; 



	public function new(?hide = false) {
		mc = cast (new gfx.Stone()) ;
		Game.me.dm.add(mc, Game.DP_STONES) ;
		draw() ;
		mc._pk.visible = false ;
		isNew = false ;
	}

	public function setPK() {
		akInfo = Game.me.getNextKPoint() ;
		if (akInfo == null)
			return ;

		mc._pk.gotoAndStop(akInfo.frame) ;
					
		/*switch(akInfo.frame) {
			case 1 : 
				mc._pk.gotoAndStop(1) ;
			case 2 : 
				mc._pk.gotoAndStop(2) ;
			case 3 : 
				mc._pk.gotoAndStop(3) ;
			case 4 : 
				mc._pk.gotoAndStop(4) ;
		}*/
		mc._pk.visible = true ;
	}


	public static function getStoneNeeds(lvl : Int) : Int {
		var nb = switch(lvl) {
						case 0, 1, 2		: 1 ;
						default 			: 2 ; // ### TODO
					}
		return nb + if (Game.me.rand(100) < 4 ) 1 else 0 ;
	}


	static public function getMaxId() {
		return 4 ;
	}


	public function breakIt() {
		if (!isNew)
			return ;
		isNew = false ;

		//initParts() ;
		/*mc.smc.visible = false ;
		mc._stone.visible = true ;*/

		/*var a = new mt.fx.FadeTo(mc._stone, 0.09, 0, 0x001b21) ;
		a.curveIn(5) ;
		a.reverse() ;*/
	}


	public function draw() {
		setId( Game.me.rand( getMaxId() )) ;
	}


	public function setId(i : Int) {
		id = i ;
		mc.gotoAndStop(id + 1) ;
	} 


	public function isStone() : Bool {
		return id >= 10 ; 
	}


	public function getPoints() {
		return POINTS[id] ; 
	}


	public function kill() {
		if (akInfo != null) {
			api.AKApi.takePrizeTokens(akInfo) ;
			akInfo = null ;
		}

		if (mc != null && mc.parent != null)
			mc.parent.removeChild(mc) ;
	}


}