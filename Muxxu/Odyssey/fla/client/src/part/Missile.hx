package part;
import Protocole;
import mt.bumdum9.Lib;



class Missile extends mt.fx.Arrow<SP> {//}
	

	public static var WAIT = 0;

	public var trg: { x:Float, y:Float };
	var anLim:Float;
	var anCoef:Float;
	public var onImpact:Void->Void;

	var sock:mt.fx.Sock;
	
	public function new() {
		var mc = new SP();
		mc.graphics.beginFill(0);
		mc.graphics.drawCircle(0, 0, 12);
		super(mc);
		
		//
		asp = 2;
		aspFrict = 0.95;
		
		anLim = 0.2;
		anCoef = 0.1;

		WAIT++;
		
		// SOCK
		sock = new mt.fx.Sock(this, 4, 1, 0.15);
		sock.rndCoef = 0.25;
		sock.frict = 0.9;
		sock.setGrav( -0.02);
		Scene.me.dm.add( sock.canvas, Scene.DP_BG );

		
		
	}


	// UPDATE
	override function update() {
		super.update();
		if ( trg != null ) seek();
		
		if ( y > Scene.HEIGHT - Scene.GH ) {
			y = Scene.HEIGHT - Scene.GH;
			vy = -vy;
			this.an = Math.atan2(vy, vx);
		}
		
		
	}
	function seek() {

		var dx = trg.x - x;
		var dy = trg.y - y;
		var da = Num.hMod(Math.atan2(dy, dx) - an, 3.14);
		an += Num.mm( -anLim, da * anCoef, anLim);
		aspAcc = (1 - Math.min(Math.abs(da), 0.75));
		
		if ( Math.sqrt(dx * dx + dy * dy) < 32 ) impact();

	}

	
	//
	function impact() {
		if ( onImpact != null ) onImpact();
		kill();
		sock.fadeOut(0.05);
		
		// FX
		var max = 16;
		for ( i in 0...max ) {
			var p = new mt.fx.Spinner(new FxSpark(),10+Std.random(30));
			var a = i / max * 6.28;
			var speed = Math.sqrt(vy*vy+vx+vx)*0.5;
			p.launch(a, speed, 0.5+Math.random()*4);
			p.setPos(x, y);
			p.frict = 0.99;
			p.timer = 10 + Std.random(60);
			Scene.me.dm.add(p.root, Scene.DP_FX);
		}
		
		var mc = new fx.RobotechImpact();
		mc.x = x;
		mc.y = y;
		mc.scaleX = mc.scaleY = 0.5;
		Scene.me.dm.add(mc, Scene.DP_FX);
		Filt.glow(mc, 10, 1, 0xFF6600);
		mc.blendMode = flash.display.BlendMode.ADD;
		
	}
	
	override function kill() {
		super.kill();
		WAIT--;
	}
	
	
	
//{
}