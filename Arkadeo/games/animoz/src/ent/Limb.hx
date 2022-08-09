package ent;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import Protocol;

class Limb extends Part {
	
	var skin:gfx.Parts;
	var shuffle:Bool;
	var frame:Int;
	
	public function new(bt:BallType, fr:Int ) {
		super();
		frame = fr;
		skin = new gfx.Parts();
		skin.gotoAndStop(Type.enumIndex(bt) + 1);
		root.addChild(skin);
		shuffle = true;
		timer = 30 + Std.random(50);
		dropShadow(0.4);
		weight = 0.1 + Math.random() * 0.1;
		gy = 4;
		frict = 0.98;		
	}
	
	override function update() {
		super.update();
		if( shuffle ) {
			shuffle = false;
			skin.smc.gotoAndStop(frame);
		}
		
		var ec = function() return (Math.random() * 2 - 1) * 8;
		if( Std.random(6) == 0 ) {
			var co = 0.5 + Math.random() * 0.3;
			var p = new Blood(timer/40);
			p.setPos(x+ec(), y+ec(), z+ec());
			p.vx = vx * (0.8 + Math.random() * 0.3);
			p.vy = vy * (0.8 + Math.random() * 0.3);
			p.vz = vz * (0.8 + Math.random() * 0.3);
		}		
	}
}
