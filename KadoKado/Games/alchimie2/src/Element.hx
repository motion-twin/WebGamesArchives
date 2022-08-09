import mt.bumdum.Lib ;
import mt.bumdum.Sprite ;
import mt.bumdum.Phys ;
import mode.GameMode.TransformInfos ;
import GameData.ArtefactId ;



class Element extends StageObject {
	
	public var index : mt.flash.Volatile<Int> ;
		
	static var MAX_ROTATE = 40 ;
	
	var r : Float ;
	
	//update Effect
	var gTimer : Float ;
	
	
	public function new(e : Int, ?dm : mt.DepthManager, ?depth : Int, ?fr : Float) {
		super() ;
		pdm = if (dm != null) dm else Game.me.stage.dm ; 
		r = 0.0 ;
		index = e ;
		id = Game.me.mode.chain[e] ;
		
		switch(id) {
			case Elt(i) :
				if (i < 4 && (fr != null || Std.random(1) == 0))
					r = if (fr != null) fr else (Std.random(2) * 2 - 1) * MAX_ROTATE * Math.random() ;
				else 
					r = 0 ;
			default :
			}
		
			
		var f = callback(function(e, rr) {e.omc.mc.smc.smc.smc._rotation =  rr ; }, this, r) ;
		
		omc = new ObjectMc(id, pdm, if (depth == null) 2 else depth, f) ;
		setElement(e, false) ;
	}
	
	public function setElement(e : Int, ?updateMc : Bool) {
		
		if (updateMc == null)
			updateMc = true ;
		
		index = e ;
		id = Game.me.mode.chain[e] ;
		switch(id) {
			case Elt(i) :
				if (i == 11 || i == 15) //gold or flocinne (ça fait purée vico, "flocinne")
					gTimer = 0.0 ;
			default :
		}
		
		if (updateMc && omc != null)
			omc.set(ObjectMc.getInfos(id)) ;
	}
	
	
	override public function copy(dm : mt.DepthManager, ?depth : Int) : StageObject {
		depth = if (depth == null) 2 else depth ;
		var e : Element = null ;
		e = new Element(index, dm, depth, r) ;
		e.isFalling = isFalling ;
		return e ;
	}
	
	
	/*override public function update() {
	}*/
	
	
	override public function getArtId() : ArtefactId {
		return id ;
	}
	
	
	public function getId() : Int {
		switch(id) {
			case Elt(i) :
				return i ;
			default : 
				return null ;
		}
	}

	
	public function initTransform(t : TransformInfos) {		
		tfInfos = t ;
		effectTimer = 100.0 ;
		effectStep = 0 ;
		if (isTransformTarget())
			tfParts = new Array() ;
	}
	
	
	override public function updateTransform() {
		if (effectStep == null) {
			return false ;
		}
				
		switch (effectStep) {
			case 0 :
				if (warm()) {
					tfInfos.e.tfParts = tfInfos.e.tfParts.concat(explode()) ;
					if(isTransformTarget()) {
						effectStep = 1 ;
						effectTimer = 24 ;
					}else
						effectStep = 3 ;
				}
			
			
			case 1 : //TRANSFORM IN NEW ELEMENT
				omc.mc._alpha = Math.max(omc.mc._alpha - 20 * mt.Timer.tmod, 0) ;
			var speed = 1.2 ;
			
				effectTimer -= speed * mt.Timer.tmod ;
				if (isTransformTarget() && effectTimer < 20) {
					var c = getCenter() ;
					for(sp in tfParts) {
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
						var c = Math.max(speed * 1.4, 16 - d) ;
						var da = 180 * a / 3.14 ;
						sp.root._rotation = da ;
						
						sp.vx = -Math.cos(a) * c ;
						sp.vy = -Math.sin(a) * c ;
						sp.vsc = 1.05 ;
						sp.fadeType = 3 ;
						
						sp.timer = 8 + Math.random() * 10 ;
					}
					
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
	
}