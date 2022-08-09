package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

//bloc

class EnforcedBlock extends StageObject {
	
	var level : mt.flash.Volatile<Int> ;	
	
	public function new (l : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Block(l)) ;
		checkHelp() ;
		level = l ;
		autoFall = false ;
		isParasit = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc) 
			return ;
		omc = new ObjectMc(_Block(l), pdm,depth, null, null, null, withBmp, sc) ;
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
					
					level-- ;
					if (level > 0) {
						//omc.mc.smc.smc.smc.gotoAndStop(level) ;
						omc.updateId(_Block(level)) ;
						effectStep = 1 ;
						effectTimer = 0 ;
					} else
						effectStep = 2 ;
				}
			
			case 1 :
				if (colder()) {
					toKill = false ;
					return false ;
				}
				
			case 2 :
				if (disappear()) {
					Game.me.log.count(getArtId()) ;
					Game.me.stage.remove(this) ;
					return false ;
				}			
		}
		return true ;
	}
	
	
	
	
}