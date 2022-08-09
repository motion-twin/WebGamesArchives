package fx;


class Tween<T> extends FX
{
	var v0 : T;
	var vx : T ;
	var proc : T -> Void;
	
	//func is a get set
	public function new( queue:String=null,d:Float, v0 : T, vx : T, func : T -> Void  )
	{
		super(queue,d);
		this.v0 = v0;
		this.vx = vx;
		this.proc = func;
	}
	
	public function end( func : Tween<T> -> Void )
	{
		onKill = func.bind( this );
		return this;
	}
	
	public inline function interp( func : T -> T -> Float -> T )
	{
		interpolator = func;
		return this;
	}
	
	//t is [0,1]
	dynamic function interpolator(v0 : T, v1 : T, t : Float) : T
	{
		return v0;
	}
	
	public override function update()
	{
		var ratio : Float = MathEx.clamp( t(), 0.0, 1.0 );
		proc( interpolator( v0, vx, ratio ));
		
		return super.update();
	}
	
	
}