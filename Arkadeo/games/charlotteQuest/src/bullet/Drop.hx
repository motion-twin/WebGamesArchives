package bullet;

class Drop extends Bullet {
	public var mc			: lib.Blood;
	var scale				: Float;
	
	public function new() {
		super();
		
		hitPlayer = true;
		autoKill = Entity.KillCond.LeaveScreen;
		color = 0xC40000;
		radius = 6;
		range = 600;
		gravity = 0.008;
		scale = 0.7;
		frictX = 0.95;
		frictY = 0.98;
		trailWid = 0;
		
		followScroll = false;
		mc = new lib.Blood();
		spr.addChild(mc);
		mc.scaleX = mc.scaleY = 0;
		mc._smc.scaleY = 0.1;
		mc.y = -7;
		//mc.alpha = 0;
		//mc.y = -7;
		//mc.blendMode = flash.display.BlendMode.ADD;
	}
	
	public override function update() {
		super.update();
		if( mc.scaleX<scale ) {
			mc.scaleX+=0.06;
			if( mc.scaleX>scale )
				mc.scaleX = scale;
			mc.scaleY = mc.scaleX;
		}
		mc.rotation *= 0.95;
		if( mc._smc.scaleY<3 )
			mc._smc.scaleY+=gravity*27;
	}
}
