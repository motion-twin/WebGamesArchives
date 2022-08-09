package part;

class Ashes extends Part
{
	var dm:mt.DepthManager;
	var clip:flash.MovieClip;
	var angle:Float;
	var flFall:Bool;
	var ampl:Float;
	var dir:Int;
	
	public function new(mc){
		super(mc);
		dm = new mt.DepthManager(mc);
		this.vr = 0.0;
		this.bounceFrict = 0.0;
		this.groundFrict = 0.0;
		ampl = 90 + Math.random() * 90;
		angle = (Math.random() * ampl);
		dir = 1;
		flFall = true;
		clip = dm.attach("leaf", 1);
	}
	
	inline static var TO_RAD = Math.PI / 180;
	
	public override function update() {
		super.update();
		if(  flFall ) {
			if(  Math.abs(angle) > ampl )
				dir *= -1;
			var dist = mt.Timer.tmod * (1+Math.random());
			angle += dir * (.5 + Math.random()) * TO_RAD;
			vx = Math.cos(angle) * dist;
			root._rotation = (1 -(vx / dist)) * 45;
		}
		
		if( flFall && z >= 0 ){
			vx = 0;
			vy = 0;
			vz = 0;
			weight = 0;
			if(root.smc!=null)root.smc.stop();
			root._rotation = 0;
			flFall = false;
		}
	}
}
	
}