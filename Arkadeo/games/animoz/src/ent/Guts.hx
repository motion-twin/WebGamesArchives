package ent;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import Protocol;

class Guts extends Part 
{
	var dist:Float;
	
	public function new() 
	{
		super();
		setScale(0.2 + Math.random() * 0.2);
		Game.me.dm.add(root, Game.DP_GROUND);
		timer = 40 + Std.random(30);
		frict = 0.9;
		var mc = new gfx.Guts();
		mc.gotoAndStop(Std.random(3) + 1);
		root.addChild(mc);
		dist = 0;
	}
	
	override function update()
	{
		super.update();
		var speed = Math.sqrt(vx * vx + vy * vy);
		dist += speed;
		if ( dist > 2.0 ) 
		{
			dist = 0;
			var p = new Blood(0.5 + speed / 2);
			p.setPos(x, y, 1);
		}
	}	
}
