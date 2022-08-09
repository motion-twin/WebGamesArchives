package fx;

/**
 * displays score / directions / PK
 */

class Pointer extends mt.fx.Fx
{

	
	var timer :Int;
	
	public var mc : { > flash.display.Sprite, _txt:flash.text.TextField, _txt1:flash.text.TextField, _txt2:flash.text.TextField };
	
	public function new(_type:Int,_amount:Int,_dm:mt.DepthManager,_x:Float,_y:Float)
	{
		super();
		
		timer = 50;
		if(_type < 5) {
			//mc = cast new gfx.Pointer();
			//mc.blendMode = flash.display.BlendMode.ADD;
			//mc.scaleX = mc.scaleY = 0.8;
			//mc.gotoAndStop(_type);
		}else if(_type == 6) {
			mc = cast new gfx.ScorePointer();
		}else if(_type == 5){
			mc = cast new gfx.PKPointer();
		}else if (_type == 7) {
			mc = cast new gfx.Bonus();
		}
		
		mc.x = _x;
		mc.y = _y;
		if(_type!=7)
			mc._txt.text = _amount>0?"+"+_amount:Std.string(_amount);
		
		_dm.add(mc,Level.DM_FX);
		
		/**
		 * type :
			 * 1 top right
			 * 2 top left
			 * 3 bottom right
			 * 4 bottom left
			 * 5 won pk
			 * 6 score
		 */
		
		
	}
	
	override function update() {
		
		super.update();
		
		timer --;
		mc.y--;
		mc.alpha = (timer / 50);
		
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