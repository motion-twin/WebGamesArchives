package fx;
import fx.FXManager;

/**
 * ...
 * @author de
 */

class DelayProc extends FX
{
	var p : Void->Void;
	
	//d in in second
	public function new(d : Float,ap:Void->Void)
	{
		super(d);
		proc( ap );
	}
	
	function proc( ap : Void->Void )
	{
		p = ap;
		Debug.NOT_NULL(p);
	}
	
	public override function kill()
	{
		super.kill();
		//Debug.MSG("procing");
		Debug.NOT_NULL(p);
		p();
		p = null;
	}
}