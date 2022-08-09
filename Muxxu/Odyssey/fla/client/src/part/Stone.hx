package part;
import Protocole;
import mt.bumdum9.Lib;



class Stone extends mt.fx.Part<McDirt> {//}
	
	
	
	public function new() {

		var mc = new McDirt();
		mc.gotoAndStop(Std.random(mc.totalFrames) + 1);
		Scene.me.dm.add(mc, Scene.DP_GROUND);
		super(mc);
	
		frict = 0.99;
		weight = 0.15 + Math.random() * 0.3;
		setScale(0.8 + weight * 2);
		root.rotation = Math.random() * 360;
		
		fadeType = 2;
	
		this.setGround(Scene.HEIGHT, 0.5, 0.8);
		onBounceGround  = bounce;
		
	}

	// UPDATE
	override function update() {
		super.update();

		
	}
	
	public function launch(angle,power:Float) {
		vx += Math.cos(angle) * power;
		vy += Math.sin(angle) * power;
	}
	
	function bounce() {
		vr *= 0.5;
		vr = (Math.random() * 2 - 1) * (Math.abs(vx) + Math.abs(vy));
		if( timer <= -1 ) timer = 40+Std.random(50);
	}
	
	
	
	
//{
}