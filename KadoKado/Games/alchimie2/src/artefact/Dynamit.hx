package artefact ;

import mt.bumdum.Lib ;
import mt.bumdum.Phys ;
import Game.GameStep ;
import StageObject.DestroyMethod ;
import GameData.ArtefactId ;

//dynamite classique

class Dynamit extends StageObject {
	
	public var value : Int ;
	public var vertical : Bool ;
	public var horizontal : Bool ;
	public var dTimer : Float ;
	
	
	public function new(v : Int, ?dm : mt.DepthManager, ?depth : Int = 2, ?noOmc = false) {
		super() ;
		value = v ;
		id = Dynamit(v) ;
		vertical = v > 0 ;
		horizontal = v != 1 ;
		
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		if (noOmc)
			return ;
				
		omc = new ObjectMc(id, pdm,depth) ;
	}
	
	
	override public function onGround() {
		super.onGround() ;
		
		effectTimer = 100 ;
		effectStep = 0 ;
		Game.me.setStep(ArtefactInUse, this) ;
		
		return true ;
	}
	
	
	
	override public function updateEffect() {
		switch (effectStep) {
			case 0 :
				if (warm(8.0)) {
					effectStep = 1 ;
					effectTimer = 100 ;
				}
				
			case 1 : 
				if (blink()) {
					effectStep = 2 ;
					for (i in 0...2)
						setHalo(null, 1.3 + i, 6) ;
				}
				
			case 2 : 
				var dt = 1.2 ;
				var t = 1 ;
				if (vertical) {
					for(dy in 0...Stage.HEIGHT) {
						var o = Game.me.stage.grid[x][dy] ;
						if (o != null)
							o.toDestroy(Flame(false), Math.abs((y - dy) * dt) + t + Math.random()) ;
					}
				}
				if (horizontal) {
					for(dx in 0...Stage.WIDTH) {
						var o = Game.me.stage.grid[dx][y] ;
						if (o != null)
							o.toDestroy(Flame(false), Math.abs((x - dx) * dt) + t + Math.random()) ;
					}
				}
				
				//self explosion
				
				var c = getCenter() ;
				var mc = Game.me.mdm.attach("explosion", Const.DP_ANIM) ;
				mc._x = c.x ;
				mc._y = c.y ;
				mc._rotation = Math.random() * 360 ;
				
				Game.me.stage.setShake(8, null) ;
				
				//flamewall
				var sens = [] ;
				if (horizontal)
					sens.push(false) ;
				if (vertical)
					sens.push(true) ;
				for (s in sens) {
					var wall = Game.me.mdm.attach("flameWall", Const.DP_ANIM) ;
						wall.setMask(Game.me.stage.animMasks[if (s) 0 else 1]) ;
					if (s)
						wall._rotation = 90 ;
					wall._x = c.x ;
					wall._y = c.y ;
				}
				
				Game.me.releaseArtefact(this) ;
				Game.me.setStep(Destroy) ;
		}
	}
}