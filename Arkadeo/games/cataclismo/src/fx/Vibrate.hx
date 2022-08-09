package fx;

/**
 * Shake element.
 *
 * modes : normal, fade in , fade out
 *
 */
class Vibrate extends mt.fx.Fx
{

	public var mc:flash.display.DisplayObject;
	
	public var baseX:Float;
	public var baseY:Float;
	
	var fx :Int;
	var fy	:Int;
	
	public var timer : Int;
	var length:Int;
	var mode:String;
	
	public function new(mc:flash.display.DisplayObject,xStrength=4,yStrength=4,_length=80,_mode='normal')
	{
		super();
		this.mc = mc;
		baseX = mc.x;
		baseY = mc.y;
		fx = xStrength;
		fy = yStrength;
		mode = _mode; //flat / in / out
		
		length = timer = _length;
	}
	
	override public function update()
	{
		super.update();
		
		switch(mode) {
			case 'normal':
				mc.x = baseX + (Math.random() * fx);
				mc.y = baseY + (Math.random() * fy);
			case 'out':
				mc.x = baseX + (Math.random() * fx) * (1 - (timer / length));
				mc.y = baseY + (Math.random() * fy) * (1 - (timer / length));
			case 'in' :
				mc.x = baseX + (Math.random() * fx) * ((timer / length));
				mc.y = baseY + (Math.random() * fy) * ((timer / length));
		}
		
		if(timer > 0) {
			timer--;
		}else {
			kill();
		}
		
	}
	
	override function kill() {
		mc.x = baseX;
		mc.y = baseY;
		super.kill();
	}
	
}