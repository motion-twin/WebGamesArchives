class Phys extends Sprite {

	public var vx : Float ;
	public var vy : Float ;
	public var vz : Float ;
	public var vr : Float ;
	public var vsc:Float;
	public var friction : Float ;
	public var frv : Float ;
	public var groundFrict : Float ;
	public var groundRotFrict : Float ;
	public var bounceFrict : Float ;
	public var weight : Float ;
	public var onBounce:Void->Void;

	public function new(?mc) {
		super(mc) ;
		vx = 0 ;
		vy = 0 ;
		vz = 0 ;
		vr = 0 ;

		bounceFrict = 0.5;
		groundFrict = 0.5;
		groundRotFrict = 0.75;
	}

	public override function update() {
		if( friction != null) {
			var frict = Math.pow(friction, mt.Timer.tmod) ;
			vx *= frict ;
			vy *= frict ;
			vz *= frict ;
		}
		if(weight != null) {
			vz += weight * mt.Timer.tmod ;
		}
		if( vr != null) {
			if( friction != null)
				vr *= Math.pow(friction, mt.Timer.tmod) ;
			if( frv != null)
				vr *= Math.pow(frv, mt.Timer.tmod) ;
			root._rotation += vr * mt.Timer.tmod ;
		}

		x += vx * mt.Timer.tmod ;
		y += vy * mt.Timer.tmod ;
		z += vz * mt.Timer.tmod ;

		if( vsc != null) {
			root._xscale *= Math.pow(vsc, mt.Timer.tmod) ;
			root._yscale = root._xscale ;
		}

		if( bounceFrict != null && z > 0 ){
			z = 0;
			vz *= -bounceFrict;
			vx *= groundFrict;
			vy *= groundFrict;
			if(vr!=null)vr *= -groundRotFrict;
			onBounce();
		}

		super.update() ;
	}

	public function towardSpeed(t : {x : Float, y : Float}, c : Float, lim : Float) {
		var dx = t.x - x ;
		var dy = t.y - y ;
		vx += Phys.mm(-lim,dx*c,lim) ;
		vy += Phys.mm(-lim,dy*c,lim) ;
	}

	public static function mm(a, b, c) {
		return Math.min(Math.max(a, b), c) ;
	}
}
