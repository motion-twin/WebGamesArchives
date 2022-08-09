package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;

//bloc pour le dig mode

class DigBlock extends EnforcedBlock {
	
	public function new (l : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super(l, dm, depth, noOmc, withBmp, sc) ;
	}
	
	override public function onTransform() {
		Game.me.mode.addToScore(mode.Dig.SCORE_BY_BLOCK) ;
		return false ;
	}
	
	
	
}