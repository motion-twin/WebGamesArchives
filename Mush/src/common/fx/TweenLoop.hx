package fx;

/**
 * ...
 * @author de
 */

class TweenLoop<T> extends FX
{
	var v0 : T;
	var vx : T ;
	var proc : T -> Void;
	var period : Float;
	
	//func is a get set
	public function new(d, v0 : T, vx : T, func : T -> Void  )
	{
		super(null);
		this.v0 = v0;
		this.vx = vx;
		this.proc = func;
		period = d;
	}
	
	public inline function interp( func : T -> T -> Float -> T )
	{
		interpolator = func;
	}
	
	//t is [0,1]
	dynamic function interpolator(v0 : T, v1 : T, t : Float) : T
	{
		Debug.BREAK("interp not set");
		return null;
	}
	
	public override function update()
	{
		var ratio = (this.date() % period) / period;
		ratio = MathEx.clamp( ratio, 0.0, 1.0 );
		proc( interpolator( v0, vx, ratio ));
		
		return super.update();
	}
	
}