package ent;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;
import Protocol;

class Blood extends Part 
{
	var fly:Bool;
	var size:Float;
	
	public function new(size = 1.0) 
	{
		super();
		weight = (0.05 + Math.random() * 0.1) * 2.5;
		onGroundBounce = splash;
		fly = true;
		fadeLimit = 20;
		this.size = size;
		Game.me.bloodsafe = 0;
	}
	
	override function update()
	{
		var ox = x;
		var oy = y;
		var oz = z;
		super.update();
		
		if ( fly )
		{
			root.graphics.clear();
			root.graphics.lineStyle(size, 0xFF0000);
			root.graphics.moveTo(0, 0);
			root.graphics.lineTo(ox-x, (oy-y)+(oz-z));
		}
	}
	
	function splash()
	{
		root.graphics.clear();
		var skin = new gfx.BloodDrop();
		skin.scaleX = skin.scaleY = 0.35 * size;
		skin.rotation = Math.random() * 360;
		var mc = new SP();
		mc.addChild(skin);
		mc.scaleY = 0.7;
		root.addChild(mc);
		skin.gotoAndStop(Math.round(Math.max(1,5 - size)));
		
		timer = 10;
		fly = false;
		vx = vy = vz = weight = 0;
		
		Game.me.blood.draw(root, root.transform.matrix);
		kill();
	}
}
