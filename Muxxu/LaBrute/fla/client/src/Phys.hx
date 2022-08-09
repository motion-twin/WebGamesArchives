class Phys extends Sprite{//}


	public var groundRay:Float;

	public var vx : Float ;
	public var vy : Float ;
	public var vz : Float ;
	public var vr : Float ;
	public var vsc:Float;
	public var friction : Float ;
	public var groundFrict : Float ;
	public var bounceFrict : Float ;
	public var weight : Float ;


	public var alpha:Float;



	public function new(?mc) {

		super(mc) ;

		vx = 0 ;
		vy = 0 ;
		vz = 0 ;
		vr = 0 ;

		bounceFrict = 0.5;
		groundFrict = 0.5;
	}


	override function update() {
		Game.me.dm.over(root);

		if (friction != null) {
			var frict = Math.pow(friction, mt.Timer.tmod) ;
			vx *= frict ;
			vy *= frict ;
			vz *= frict ;
		}
		if(weight != null) {
			vz += weight * mt.Timer.tmod ;
		}
		if (vr != null) {
			if (friction != null)
				vr *= Math.pow(friction, mt.Timer.tmod) ;
			root._rotation += vr * mt.Timer.tmod ;
		}

		x += vx * mt.Timer.tmod ;
		y += vy * mt.Timer.tmod ;
		z += vz * mt.Timer.tmod ;

		if (vsc != null) {
			root._xscale *= Math.pow(vsc, mt.Timer.tmod) ;
			root._yscale = root._xscale ;
		}


		var lim = 0.0;
		if(groundRay!=null) 	lim = -groundRay;
		if(groundRay<0){
			var b = root.getBounds(root._parent);
			lim = (root._y-b.yMax);
		}

		if( bounceFrict!=null && z>lim ){
			z = lim;
			vz *= -bounceFrict;
			vx *= groundFrict;
			vy *= groundFrict;
			if(vr!=null){
				vr *= (Math.random()*2-1)*0.75;
			}
			onGroundHit();
		}


		super.update() ;

	}



	public function setAlpha(a){
		alpha = a;
		root._alpha = alpha*100;
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
	public dynamic function onGroundHit(){

	}


//{
}