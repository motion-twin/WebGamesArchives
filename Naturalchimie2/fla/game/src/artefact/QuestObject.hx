package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;


class QuestObject extends StageObject {
	
	var index : String ;
	var rid : Int ;
	
	public function new (nid : String, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?param : Int, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		this.index = nid ;
		this.id = Const.getArt(_QuestObj(nid)) ;
		rid = if (param == null) (Std.random(20) + 1) else param ; //random head
		checkHelp() ;
		switch(nid) {
			
			default : 
				isPickable = true ;
		}
		
		pdm = if (dm != null) dm else Game.me.stage.dm ;
		if (noOmc)
			return ;
		omc = new ObjectMc(_QuestObj(nid), pdm, depth, null, null, rid, withBmp, sc) ;
	}
	
	
	override public function initPickUp(t, ?force = false) {
		switch(index) {
			default : 
				pickQty = Game.me.log.addReward(_QuestObj(index), _QuestObj(index)) ;
			
		}
		
		super.initPickUp(t, force) ;
	}
	

	override public function isCollateral(?e : _ArtefactId) : Bool {
		switch(index) {
			case "feuille", "pickRedSkat" : //feuille ultra-menthol, red skat ne réagit qu'aux feuilles mentholées normales ou élément supérieur
				switch(e) {
					case _Elt(n) :
						return n >= 4 ;
					
					default :
						return false ;
				}

			case "corb" : //on récupère un corbeau en créant un foleil à côté. 
				switch(e) {
					case _Elt(n) :
						return n == 4 ;
					
					default :
						return false ;
				}
			default :
				return true ;
		}
	}
	
	
	override public function onStageKill() {
		super.onStageKill() ;
		
		switch(index) {
			case "pickSkat", "pickRedSkat" : Game.me.log.count(getArtId()) ;
			
		}
		
		
	}

	
	
}