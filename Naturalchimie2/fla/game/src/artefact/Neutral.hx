package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

//bloc neutre, transmutable en rien, disparait en cas de transmutation à côté

class Neutral extends StageObject {
	
	public var rid : Int ;
	
	public function new(?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?r : Int, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Neutral) ;
		rid = if (r == null) (Std.random(20) + 1) else r ; //random head
		checkHelp() ;
		autoFall = false ;
		isParasit = true ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_Neutral, pdm,depth, null, null, rid, withBmp, sc) ;
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
					Game.me.log.count(getArtId()) ;
					Game.me.stage.remove(this) ;
					return false ;
				}				
		}
		return true ;
	}
		
		
}
	
	
	
	
	
