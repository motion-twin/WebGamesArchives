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
		//only in debug because it can cause crashes in production in case of early terminations.
		#if debug
		if ( pManager == null && DEFAULT_MANAGER == null ) {
			trace("no manager, this fx will go into the void...");
		}
		#end
		
		if ( pManager == null ) pManager = DEFAULT_MANAGER;

		if( pManager != null) {
			this.manager = pManager;
			manager.add(this);
		}
	
		curve = function(n) { return n ; } ;
		coef = 0;
		dead = false;
	}

	public function update() { }

	public function kill() {
		if( dead ) {
			#if debug
			trace("Warning : fx already dead");
			#end
		}
		dead = true;
		if( onFinish != null ) onFinish();
		if( poolBack != null ) poolBack();
		if( manager!=null)
			manager.remove(this);
	}

	/**
	 * Ease in
	 * @param	pow = 3
	 */
	public function curveIn(?pow = 3) {
		curve = function(c) { return Math.pow(c, pow); };
	}

	/**
	 * Ease out
	 * @param	pow = 3
	 */
	public function curveOut(?pow = 3) {
		curve = function(c) { return 1 - Math.pow(1 - c, pow); } ;
	}

	/**
	 * Ease in out
	 * @param	pow = 3
	 */
	public function curveInOut(?pow = 3) {
		curve = function(c) {
			return (c <= 0.5) ? Math.pow(2 * c, pow) / 2 : ((2 - Math.pow(2 * (1 - c), pow)) / 2) ;
		} ;
		//curve = function(c) { return 0.5 - Math.cos(c * 3.14 ) * 0.5; };
	}


	public function bounceOut() {
		curve = function(c) {
			var cf = 1 - c ;

			var value = 0.0 ;
			var a = 0.0 ;
			var b = 1.0 ;
			while(true) {
				if (cf >= (7 - 4 * a) / 11) {
					value = -Math.pow((11 - 6 * a - 11 * cf) / 4, 2) + b * b ;
					break ;
				}
				a += b ;
				b /= 2.0 ;
			}
			return 1 - value ;
		} ;
	}

	public function elasticOut(?boing = 1.0) {
		curve = function(c) {
			var cf = 1 - c ;
			return 1 - Math.pow(2, 10 * --cf) * Math.cos(20 * cf * 3.14 * boing / 3) ; } ;
	}

	public function reverse() {
		var old = curve;
		curve = function(n) return 1 - old(1 - n);
	}

	public function uTurn() {
		coef = 1 - coef;
		reverse();
	}
}
