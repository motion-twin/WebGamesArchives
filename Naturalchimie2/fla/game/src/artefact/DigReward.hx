package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData._ArtefactId ;

//fait disparaitre tous les éléments d'id eid

class DigReward extends StageObject {
	
	var reward : _ArtefactId ;
	
	
	public function new(o : _ArtefactId, ?dm : mt.DepthManager, ?depth : Int, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
	
		id = Const.getArt(_DigReward(o)) ;
		reward = o ;
		
		isPickable = true ;
	
		pdm = if (dm != null) dm else Game.me.stage.dm ;
		
		if (noOmc)
			return ;
		omc = new ObjectMc(o, pdm, depth, null, null, null, withBmp, sc) ;
		postMc() ;
	}
	
	
	public function postMc() {
		Filt.grey(omc.mc) ;
		Filt.glow(omc.mc, 5, 3, 0x000000) ;
	}
	
	
	override public function setOmc(no : ObjectMc) {
		super.setOmc(no) ;
		postMc() ;
	}
	
	
	override public function initPickUp(t, ?force = false) {
		pickQty = Game.me.log.addReward(reward, reward) ;
		
		super.initPickUp(t, true) ;
	}
	

	
	
	
}