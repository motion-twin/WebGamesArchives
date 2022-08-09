package result ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import mt.bumdum.Sprite ;
import anim.Anim.AnimType ;
import anim.Transition ;
import CauldronData.CauldronResult ;
import Cauldron.Step ;
import GameData._ArtefactId ;
import result.Result.ResultStep ;
import Inventory.InvObject ;




class RaceDonation extends Result {
	
	var donation : Array<{_id : String, _qty : Int, _ok : Bool, _given : Int, _o : _ArtefactId}> ;
	var postUrl : String ;
	var done : Bool ;
	var useful : Bool ;
	
	public function new(toMaj, url, d) {
		super() ;
		
		step = Prepare ;
		mc._visible = false ;
		
		donation = toMaj ;
		useful = donation != null && donation.length > 0 ;
		postUrl = url ;
		done = d ;
		
		initMcs() ; 
		
		if (useful)  {
			var s = "" ;
			for (m in donation) {
				for (s in Cauldron.me.data._raceNeedState) {
					if (!Type.enumEq(m._o, s._o))
						continue ;
					s._qty = m._qty ;
				}

				if (s != "")
					s += "#" ;
				s += m._id + "," + m._qty + "," + (if (m._ok) "1" else "0") + "," + m._given ;
			}
			flash.external.ExternalInterface.call("_upra", s) ;
		}
	}
	
	
	override function initMcs() {
		super.initMcs() ;
		
		super.initMcResult(if (useful) 8 else 7) ; 

		if (useful) {
			(cast mcResult._result)._title.text = Const.RACE_USEFUL_TITLE ;
			(cast mcResult._result)._txt.text = Const.RACE_USEFUL_TEXT ;
		} else {
			(cast mcResult._result)._title.text = Const.RACE_FAIL_TITLE ;
			(cast mcResult._result)._txt.text = Const.RACE_FAIL_TEXT ;
		}

		
		mc.onRelease = initOut ;
		//if (useful)
			//mcResult._result.smc.smc._visible = done ; //###TO CHANGE
		
		makeClouds(mcResult._x, mcResult._y) ;

		mc._visible = true ;
		Cauldron.me.updateSprites() ;
		mcResult._visible = true ;
		
		mcMask.gotoAndPlay(1) ;
		
		step = Wait ;
	}

	
	override public function loop() {
		
		switch(step) {
			case Prepare, GoOut, Wait : 
				//nothing to do
			
			case Exit : 
				kill() ;
				
				if (postUrl != null) {
					var lv = new flash.LoadVars() ;
					lv.send(postUrl, "_self") ;
				} else 
					Cauldron.me.postResult() ;
		}
	}
	
	
	public function initOut() {
		if (Cauldron.me.dialog != null)
			return ;
		
		mc.onRelease = null ;
		Cauldron.me.resetRaceSubmitAnim() ;
		resultOut() ;
		var m = new anim.Anim(mcResult, Alpha(-1), Quint(-1), {x : 0, y : 0, speed : 0.05}) ;
		m.onEnd = callback(function(rd : result.RaceDonation) {
						rd.step = Exit ;
						rd.mcResult.removeMovieClip() ;
				}, this) ;
		m.start() ;
	}
	
	override public function kill() {
		super.kill() ;
		if (mc != null) {
			mc.removeMovieClip() ;
		}
		
		super.kill() ;
	}
	
}