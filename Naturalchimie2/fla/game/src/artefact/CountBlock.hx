package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import GameData._ArtefactId ;


class CountBlock extends EnforcedBlock {
	
	public function new (l : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super(l, dm, depth, noOmc, withBmp, sc) ;
		id = Const.getArt(_CountBlock(l)) ;
		
	}
	
	override public function onStageKill() {
		super.onStageKill() ;
		
		Game.me.log.count(getArtId()) ;
		Game.me.log.addReward(_CountBlock(1), _CountBlock(1)) ;
	}
	
	
	
}