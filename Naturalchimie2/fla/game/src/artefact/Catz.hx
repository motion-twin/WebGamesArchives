package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

//idem Neutral, mais drop rare 

class Catz extends StageObject {
		
	public function new(?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Catz) ;
		checkHelp() ;
		autoFall = false ;
		isPickable = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc)
			return ;
		
		omc = new ObjectMc(_Catz, pdm,depth, null, null, null, withBmp, sc) ;
	}
	
	
	public function initKill() {
		effectTimer = 100 ;
		effectStep = 0 ;
	}
	
	
	public function updateKill() {
		switch (effectStep) {
			case 0 :
				if (warm()) {
					for (sp in explode()) {
						sp.vsc = 1.05 ;
						sp.fadeType = 0 ;
						sp.timer = 10 + Math.random() * 20 ;
					}
					effectStep = 1 ;
				}
			
			case 1 : 
				if (disappear()) {
					Game.me.stage.remove(this) ;
					return false ;
				}				
		}
		return true ;
	}
	

	override public function initPickUp(t, ?force = false) {
		pickQty = Game.me.log.addReward(_Catz, _Catz) ;
		
		super.initPickUp(t, force) ;
	}
	

	override public function isCollateral(?e : _ArtefactId) : Bool {		
		switch(e) {
			case _Elt(n) :
				//return n >= 7 ;
				return true ;
			default :
				return false ;
		}
	}	
		
}
	
	
	
	
	
