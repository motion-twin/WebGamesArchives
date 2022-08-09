package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

//idem Neutral, mais drop rare qu'on ramasse forcément quand on le transmute avec au moins une fleur. 

class NowelBall extends StageObject {
	
	public var rid : Int ;
		
	public function new(?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?r : Int, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_NowelBall) ;
		rid = if (r == null) (Std.random(4) + 1) else r ; //random ball
		checkHelp() ;
		autoFall = false ;
		if (Const.BOT_MODE)
			isParasit = true ;
		else
			isPickable = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
			
		if (noOmc)
			return ;
		
		omc = new ObjectMc(_NowelBall, pdm,depth, null, null, rid, withBmp, sc) ;
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
		Game.me.log.count(getArtId()) ;
		pickQty = Game.me.log.addReward(Const.fromArt(id), Const.fromArt(id)) ;
		
		super.initPickUp(t, force) ;
	}
	

	override public function isCollateral(?e : _ArtefactId) : Bool {		
		switch(e) {
			case _Elt(n) :
				return true ;
			default :
				return false ;
		}
	}	
		
}
	
	
	
	
	
