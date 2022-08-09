package fx;


class ExtraBonus extends mt.fx.Fx
{

	
	var timer :Int;
	
	public var mc : { > flash.display.Sprite, _txt1:flash.text.TextField, _txt2:flash.text.TextField };
	
	public function new(_dm:mt.DepthManager,_x:Float,_y:Float)
	{
		super();
		
		timer = 60;
		mc = cast new gfx.Bonus();
		mc.x = _x;
		mc.y = _y;
		_dm.add(mc,Level.DM_FX);
	}
	
	override function update() {
		
		super.update();
		
		timer --;
		
		
		if(timer > 40) {
			mc.visible = timer % 4 > 1;
		}else if( timer > 20) {
			mc.visible = true;
		}else {
			mc.alpha = (timer / 20);
		}
		
		mc.y--;
		
		
		if(timer == 0) {
			kill();
		}
		
	}
	
	override function kill() {
		try {
			if(mc.parent!=null) mc.parent.removeChild(mc);
			super.kill();
		}catch(e:Dynamic){}
	}
	
}