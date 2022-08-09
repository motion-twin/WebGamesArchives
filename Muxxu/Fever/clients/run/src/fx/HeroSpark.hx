package fx;
import mt.bumdum9.Lib;
class HeroSpark extends mt.fx.Fx{//}
	
	
	var h:world.Hero;
	var timer:Int;


	
	public function new() {
		super();
		h = World.me.hero;
		timer = 200;

	}
	
	override function update() {
		super.update();
		
		var mod = 5 - Math.round(timer/50);
		
		if( timer % mod == 0 ) {
			
			var p = new pix.Part();
			p.visible = false;
			p.sleep = Std.random(12);
			p.drawFrame(Gfx.fx.get("spark_twinkle"));
			p.xx = h.root.x+Std.random(11)-5;
			p.yy = h.root.y + Std.random(11) - 9;
			p.updatePos();
			p.weight = -(0.05 + Math.random() * 0.1);
			p.timer = 10 + Std.random(10);
			p.frict = 0.95;
			h.island.dm.add(p, world.Island.DP_FX);
			
		}
		
		if( timer-- == 0 ) kill();
	}
	

	
//{
}








