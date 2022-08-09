package fx;
import Protocol;
import mt.bumdum9.Lib;


class LifeBar extends mt.fx.Fx {

	static var HEIGHT = 4;
	
	var bad:Bad;
	public var timer:Int;

	var base:SP;
	var bg:SP;
	var bar:SP;
	
	public function new(b) {
		super();
		bad = b;
		bad.lifeBar = this;
		
		var ww = b.ray*0.75;
		var ma = 1;
		
		base = new SP();
		
		bg = new SP();
		bg.graphics.beginFill(0,0.5);
		bg.graphics.drawRect( -ww-ma, -ma, (ww+ma) * 2, HEIGHT+2*ma);
		
		bar = new SP();
		bar.graphics.beginFill(0xFF0000);
		bar.graphics.drawRect( 0, 0, ww * 2, HEIGHT);
		bar.x = -ww;
		
		Filt.glow(bar, 4, 0.5, 0xFF0000);
		
		
		base.addChild(bg);
		base.addChild(bar);
		bad.root.addChild(base);
		
		base.y = -bad.ray-6;
	}

	override function update() {
		super.update();
		bar.scaleX = bad.life / bad.data.life;
		if( timer-- == 0 ) kill();
	}

	override function kill() {
		super.kill();
		bad.root.removeChild(base);
		bad.lifeBar = null;
	}
}
