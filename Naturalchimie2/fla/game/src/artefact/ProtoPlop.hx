package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData._ArtefactId ;

/*
ajout d'une ligne entière d'éléments au hasard (peut faire perdre la partie)
level 1 : pas d'éléments ajoutés sur les colonnes déjà pleines : on meurt pas
*/

class ProtoPlop extends StageObject {
	
	public var level : mt.flash.Volatile<Int> ; 
	var gTimer : Float ;
	var plops : Array<{e : Element, wait : Float}> ;
	
	
	public function new (l : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		id = Const.getArt(_Protoplop(l)) ;
		checkHelp() ;
		autoFall = true ;
		level = l ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		gTimer = 0.5 ;
		if (noOmc)
			return ;
		omc = new ObjectMc(_Protoplop(l), pdm,depth, null, null, null, withBmp, sc) ;
	}
	
	
	override public function update() { //visual effect like Sprites
		/*if (gTimer == null) {
			omc.mc.filters = [] ;
			return ;
		}
		
		gTimer += 0.06 ;
		var f = Math.sin(gTimer) ;
		if ( f < 0.5 ) {
			gTimer = 0.5 ;
			f=0.5 ;
		}
		omc.mc.filters = [new flash.filters.GlowFilter(0xffffff,f,10, 10,2)] ;*/
	}
	
	
	override public function onFall() {
		effectTimer = 100 ;
		effectStep = 0 ;
		
		plops = new Array() ;
		for (i in 0...Stage.WIDTH) {
			if (level == 1 && Game.me.stage.grid[i][Stage.LIMIT - 1] != null)
				continue ;
			else {
				var e = new Element(Game.me.mode.getRandomElement(), Game.me.stage.dm, Stage.HEIGHT - 3) ;
				e.omc.mc._alpha = 0 ;
				e.place(i, Stage.HEIGHT - 3, Stage.X + i * Const.ELEMENT_SIZE, Const.HEIGHT - (Stage.Y + (Stage.HEIGHT - 3) * Const.ELEMENT_SIZE +  Math.random() * 40)) ;
				Game.me.stage.add(e) ;
				plops.push({e : e, wait : Math.random() * 15}) ;
			}
		}
			
		Game.me.setStep(ArtefactInUse, this) ;
		return true ;
	}
	
	
	override public function updateEffect() {
		
		switch (effectStep) {
			case 0 :
				effectTimer = Math.max(effectTimer - 10 * mt.Timer.tmod, 0) ;
				omc.mc._alpha =effectTimer ;
				if (effectTimer == 0) {
					effectStep = 1 ;
					Game.me.stage.remove(this) ;
				}
				
			case 1 : 
				var t = mt.Timer.tmod ;
				var all = 0 ;
				for (o in plops) {
					if (o.wait <= 0) {
						if (all == 0)
							Game.me.sound.play("protoplop") ;
						all++ ;
						continue ;
					}
					
					o.wait -= t ;
					if (o.wait > 0)
						continue ;
					
					var c = o.e.getCenter() ;
					var explode = o.e.pdm.attach("transformExplosion", Const.DP_PART) ;
					explode.blendMode = "overlay" ;
					explode._rotation = Math.random()*360 ;
					explode._x = c.x ;
					explode._y = c.y ;
					explode._xscale = 80 ;
					explode._yscale = 80 ;
					
					o.e.omc.mc._alpha = 100 ;
				}
				
				if (all == plops.length) {
					Game.me.sound.play("chute") ;
					Game.me.releaseArtefact(this) ;
				}
		}
	}
	
	
	
	
	
	
	
}