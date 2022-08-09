package fx.as;

/**
 * ...
 * @author de
 */

class Pulse extends FX
{
	var mc: flash.display.DisplayObject;
	
	public function new(mc)
	{
		super( null );
		this.mc = mc;
	}
	
	public override function update()
	{
		mc.alpha = MathEx.clamp( 0.2 + 0.5 + Math.sin( StdEx.time() * 8) * (0.5), 0, 1);
		return super.update();
	}
	
	public override function onKill()
	{
		super.onKill();
		mc = null;
	}
	
}