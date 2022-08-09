package ;

/**
 * ...
 * @author de
 */

class TweenEx extends mt.fx.Tween
{
	public var onKill : flash.display.DisplayObject->Void;
	
	public override function kill()
	{
		super.kill();
		if(onKill != null )
			onKill(root);
	}
	
}


class VanishEx extends mt.fx.Vanish
{
	public var onKill : flash.display.DisplayObject->Void;
	
	public override function kill()
	{
		super.kill();
		if( onKill != null )
			onKill(root);
		
	}
	
	override function update() {
		if( root.parent == null ) {
			kill();
			return;
		}
		if( timer-- < fadeLimit ) {
			setVisibility(curve(timer / fadeLimit));
			if( timer == 0 )
			{
				//root.visible = false;
				kill();
			}
		}

	}
}