package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData.ArtefactId ;

//bloc neutre, transmutable en rien, disparait en cas de transmutation à côté

class Neutral extends StageObject {
	

	
	public function new(?dm : mt.DepthManager, ?depth : Int = 2) {
		super() ;
		id = Neutral ;
		autoFall = false ;
		isParasit = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		omc = new ObjectMc(id, pdm,depth) ;
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
		
		
}
	
	
	
	
	
