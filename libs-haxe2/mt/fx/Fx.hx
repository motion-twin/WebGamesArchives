package mt.fx;

class Fx {
	//do not ever modify me
	public static var DEFAULT_MANAGER:Manager;
	public var manager:Manager;
	
	public var dead:Bool;
	public var coef:Float;
	public var onFinish:Void->Void;
	public var poolBack:Void->Int;
	public var curve:Float->Float;
	
	public function new(?pManager:Manager) {
		if ( pManager == null && DEFAULT_MANAGER == null ) throw "no default manager!";
		if ( pManager == null ) pManager = DEFAULT_MANAGER;
		
		this.manager = pManager;
		manager.add(this);
		curve = function(n) { return n ; } ;
		coef = 0;
		dead = false;
	}
	
	public function update() { }

	public function kill() {
		if( dead ) {
			#if debug
			throw("fx already dead");
			#else
			trace("Warning : fx already dead");
			#end
			return;
		}
		dead = true;
		if( onFinish != null ) onFinish();
		if( poolBack != null ) poolBack();
		manager.remove(this);
	}

	// SHORTCUT
	public function curveIn(pow) {
		curve = function(c) { return Math.pow(c, pow); };
	}
	
	public function curveInOut() {
		curve = function(c) { return 0.5 - Math.cos(c * 3.14 ) * 0.5; };
	}
	
	public function reverse() {
		var old = curve;
		curve = function(n) return 1 - old(n);
	}
	
	public function uTurn() {
		coef = 1 - coef;
		reverse();
	}
}
