class BulletTimer {
	
	static public var MIN_MOVE = 1.0 ; 
	static public var MIN_ROT = 2.0 ; 
	
	public var lastX : mt.flash.Volatile<Float> ;
	public var lastY : mt.flash.Volatile<Float> ;
	public var x : mt.flash.Volatile<Float> ;
	public var y : mt.flash.Volatile<Float> ;
	public var delta : {x : Float, y : Float} ;
	var mcRef : flash.MovieClip ;
	
		
	
	public function new() {
		mcRef = Game.me.root ;
		lastX = mcRef._xmouse ;
		lastY = mcRef._ymouse ;
		x = lastX ;
		y = lastY ;
		delta = {x : 0.0, y : 0.0} ;
	}
	
	
	public function isMoving() {
		var d = getDist() ;
		return d != null && d >= MIN_MOVE ;
	}
	
	
	public function isRotating() {
		var d = getDist() ;
		return d != null && d >= MIN_ROT ;
	}
	
	
	public function update() {
		var sx = x ;
		var sy = y ;
		
		lastX = x ;
		lastY = y ;
		
		//trace(lastX + ", " + lastY + " ==> " + mcRef._xmouse + ", " + mcRef._ymouse) ;
		
		x = mcRef._xmouse + delta.x ;
		y = mcRef._ymouse + delta.y ;
		
		if (!isMoving()) {
			x = sx ;
			y = sy ;
		}
		
		if (outOfGround())
			Game.me.setPause() ;
	}
	
	
	public function outOfGround() {
		return x < Cs.mcw[0] || x > Cs.mcw[1] || y < Cs.mch[0] || y > Cs.mch[1] ;
		//return x - delta.x < Cs.mcw[0] || x - delta.x > Cs.mcw[1] || y - delta.y < Cs.mch[0] || y - delta.y > Cs.mch[1] ;
	}
	
	
	public function getDist() : Float {		
		return Cs.getDist(x, y, lastX, lastY) ;
	}
	
	
}