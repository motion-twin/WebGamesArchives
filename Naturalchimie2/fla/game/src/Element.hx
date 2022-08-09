import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import mode.GameMode.TransformInfos ;
import GameData._ArtefactId ;



class Element extends StageObject {
	
	//public var eid : ArtefactId ;
	public var index : mt.flash.Volatile<Int> ;
	static var MAX_ROTATE = 40 ;
	
	var r : Float ;
	
	//update Effect
	var gTimer : Float ;
	var mcAnim : flash.MovieClip ;
	var transmutSoundDone : Bool ;
	
	
	public function new(e : Int, ?dm : mt.DepthManager, ?depth : Int, ?noOmc = false, ?fr : Float, ?withBmp : flash.display.BitmapData, ?sc : Int) {
		super() ;
		
		if (e < 0)
			return ;
		
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		r = 0.0 ;
		index = e ;
		id = Game.me.mode.chain[e] ;
		if (index == 0)
			r = if (fr != null) fr else (Std.random(2) * 2 - 1) * MAX_ROTATE * Math.random() ;
		
		if (!noOmc) {
			var f = callback(function(e) {e.postMc() ; }, this) ;
			omc = new ObjectMc(Const.fromArt(id), pdm, if (depth == null) 2 else depth, f, null, null, withBmp, sc) ;
		}
		setElement(e, false) ;
	}
	
	
	function initAnim() {
		mcAnim = omc.mc.attachMovie("oeil", "oeil", 5) ;
		mcAnim._x = 0.6 ;
		mcAnim._y = -3.2 ;
		if (Std.random(2) == 0) {
			mcAnim._xscale = -100 ;
			mcAnim._x = 31.0 ;
		}
		mcAnim._alpha = 0 ;
	}
	
	
	override public function onStage() {
		super.onStage() ;
		
		if (mcAnim != null) {
			omc.mc._b._alpha = 0 ;
			mcAnim._alpha = 100 ;
		}
		
	}
	
	
	override public function onFall() {
		if (mcAnim != null) {
			omc.mc._b._alpha = 0 ;
			mcAnim._alpha = 100 ;
		}
		return false ;
	}
	
		
	
	public function postMc() {
		omc.mc.smc.smc.smc._rotation =  r ;
	}
	
	
	override public function setOmc(no : ObjectMc) {
		super.setOmc(no) ;
		postMc() ;
	}
	
	
	public function setElement(e, ?updateMc = true) {
		index = e ;
		id = Game.me.mode.chain[e] ;
		
		switch(Const.fromArt(id)) {
			case _Elt(i) :
				if (i == 11 || i == 15) 
					gTimer = 0.0 ;
				
				if (i == 5) { //Eye anim
					initAnim() ;
					if (updateMc) {
						omc.mc._b._alpha = 0 ;
						mcAnim._alpha = 100 ;
					}
				
				} else {
					if (mcAnim != null) {
						mcAnim.removeMovieClip() ;
						omc.mc._b._alpha = 100 ;
					}
				}
			default :
		}
		
		if (updateMc && omc != null)
			omc.set(ObjectMc.getInfos(Const.fromArt(id))) ;
	}
	
	
	public function setArtefact(a : _ArtefactId) {
		
		var na = StageObject.get(a, pdm, 2, true) ;
		
		var mpos = {x : omc.mc._x, y : omc.mc._y} ;
		var pos = {x : x, y : y} ;
		
		Game.me.stage.remove(this, true) ;
		na.setOmc(omc) ;
		if (mcAnim != null) {
			mcAnim.removeMovieClip() ;
			omc.mc._b._alpha = 100 ;
		}
		
		this.omc = null ;
		na.place(pos.x, pos.y, mpos.x, mpos.y) ;
		Game.me.stage.add(na) ;
		
		na.effectTimer = 0 ;
		na.effectStep = 2 ;
		Game.me.stage.transforms.remove(this) ;
		Game.me.stage.transforms.push(na) ;
		na.tfParts = tfParts ;
		na.tfInfos = tfInfos ;
		na.tfInfos.e = na ;
		//na.omc.mc.filters = omc.mc.filters ;
		//Col.setPercentColor(na.omc.mc, 100, 0xFFFFFF) ;
		
		onStageKill() ;
		kill() ;
		
	}
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		var e : Element = null ;
		e = new Element(index, dm, depth, null, r) ;
		e.isFalling = isFalling ;
		
		if (mcAnim == null) 
			return e ;
		
		e.mcAnim.gotoAndPlay(mcAnim._currentframe) ;
		e.mcAnim._x = mcAnim._x ;
		e.mcAnim._xscale = mcAnim._xscale ;
		if (mcAnim._alpha > 0) {
			e.mcAnim._alpha = mcAnim._alpha ;
			e.omc.mc._b._alpha = 0 ;
		}
		
		return e ;
	}
	
	
	/*override public function update() {
	}*/
	
	
	override public function getArtId() : _ArtefactId {
		return Const.fromArt(id) ;
	}
	
	
	public function getId() : Int {
		switch(Const.fromArt(id)) {
			case _Elt(i) :
				return i ;
			default : 
				return null ;
		}
	}

	
	public function initTransform(t : TransformInfos) {		
		tfInfos = t ;
		effectTimer = 100.0 ;
		effectStep = 0 ;
		transmutSoundDone = false ;
		if (isTransformTarget())
			tfParts = new Array() ;
	}
	
	
	override public function updateTransform() {
		if (effectStep == null) {
			//trace(x + ", " + y + " don't want to be transformed ! ") ;
			return false ;
		}
				
		switch (effectStep) {
			case 0 :
				if (warm()) {
					tfInfos.e.tfParts = tfInfos.e.tfParts.concat(explode()) ;
					if(isTransformTarget()) {
						effectStep = 1 ;
						effectTimer = 24 ;
						//Game.me.sound.playTransmutEnd() ;
					}else
						effectStep = 3 ;
				}
			
			
			case 1 : //TRANSFORM IN NEW ELEMENT
				omc.mc._alpha = Math.max(omc.mc._alpha - 20 * mt.Timer.tmod, 0) ;
				var speed = 1.2 ;
			
				effectTimer -=  speed * mt.Timer.tmod ;
				if (isTransformTarget() && effectTimer < 20) {
					if (effectTimer < 10 && !transmutSoundDone) {
						Game.me.sound.playTransmutEnd() ;
						transmutSoundDone = true ;
					}
					var c = getCenter() ;
					for(sp in tfParts) {
						//sp.towardSpeed(c,0.1,0.8) ;
						sp.towardSpeed(c,speed / 8, speed * 1.35) ;
					}
				}
				
				
				if (effectTimer <= 0) {
					
					var c = getCenter() ;
					this.setHalo() ;
					
					//parts go to target
					for(sp in tfParts) {
						var a = sp.getAng(c) ;
						var d = sp.getDist(c) ;
						var c = Math.max(speed * 1.4, 16 - d) ; /*1.4*/
						
						var da = 180 * a / 3.14 ;
						sp.root._rotation = da ;
						
						sp.vx = -Math.cos(a) * c ;
						sp.vy = -Math.sin(a) * c ;
						sp.vsc = 1.05 ;
						sp.fadeType = 3 ;
						
						sp.timer = 8 + Math.random() * 10 ;
					}
					
					if (tfInfos.nextArt != null)
						setArtefact(tfInfos.nextArt) ;
					else 
						setElement(tfInfos.nextElt) ;
					omc.mc._alpha = 100 ;
					effectTimer = 0 ;
					effectStep = 2 ;
					
				}
			
			case 2 : 
				if (colder())
					return false ;
			case 3 : 
				if (disappear()) {
					Game.me.stage.remove(this) ;
					return false ;
				}
		}
		return true ;
	}
	
	
	public function isTransformTarget() {
		if (tfInfos == null)
			return false ;
		return tfInfos.e == this ;
	}
	
	
	public function addPart(p) {
		if (tfParts == null)
			throw x + ", " + y + " don't want his own particles ! " ;
		tfParts.push(p) ;
	}
	
	
	override public function kill() {
		if (mcAnim != null)
			mcAnim.removeMovieClip() ;
		super.kill() ;
	}

	
}