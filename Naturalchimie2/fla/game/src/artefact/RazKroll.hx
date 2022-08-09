package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Stage.TempEffect ;
import Game.GameStep ;
import GameData._ArtefactId ;
import anim.Transition ;
import anim.Anim.AnimType ;

/*
RazKroll => force le changement du prochain coup. 
Effet uniquement sur le click dans l'inventaire ingame
*/

class RazKroll extends StageObject {
	

	public function new ( ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_RazKroll) ;
		checkHelp() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
		omc = new ObjectMc(_RazKroll, pdm, depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function onClick(pos : Int) { //declencheur sur un clic de l'objet ==> utilisation depuis l'inventaire
		
		for(g in Game.me.stage.nexts) {
			var g = Game.me.stage.nexts.pop() ;
			g.kill() ;
		}
		var g = new Group() ;
		Game.me.stage.nexts.add(g) ;
		Game.me.sound.play("shake") ;
		
		g.mc._xscale = g.mc._yscale = 0 ;
		var a = new anim.Anim(g.mc, Scale, Elastic(-1, 0.8), {x : 100, y : 100, speed : 0.01}) ;
		a.start() ;
		
		kill() ;
		return true ;
	}
	
	

	
	
}