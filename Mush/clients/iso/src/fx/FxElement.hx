package fx;

/**
 * ...
 * @author de
 */

class FxElement extends mt.fx.Fx
{
	public var el:ElementEx;
	public var onUpdate : Void->Void;
	
	public function new(?m,el) 
	{
		super(m);
		this.el = el;
	}
	
	public override function update()
	{
		if (onUpdate != null) onUpdate();
	}
	
}