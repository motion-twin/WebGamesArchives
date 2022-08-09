package fx;
import mt.kiroukou.math.MLib;
class Fx implements mt.kiroukou.events.Signaler
{
	public var manager(default, setManager): fx.Manager;
	public var dead : Bool;
	var initialized : Bool;
	@:signal
	public function onFinish( fx: Fx ) { }
	
	public var progress : Float;
	public var speed : Float;
	var _coef : Float;
	var _ease : Float -> Float;
	
	public function new()
	{
		dead = false;
		_ease = mt.kiroukou.motion.Ease.Linear.easeNone;
		initialized = false;
	}
	
	public function setManager( manager : fx.Manager ) : fx.Manager
	{
		this.manager = manager;
		if( this.manager != null ) init();
		
		return this.manager;
	}
	
	function setEase( e : Float -> Float ) : Void
	{
		_ease = e;
	}
	
	function init()
	{
		if( manager == null ) throw "Particle must be attached to a manager before being initialized";
		initialized = true;
		_coef = 0.;
	}
	
	public function update()
	{
		_coef += speed;
		_coef = MLib.fclamp( _coef, 0, 1 );
		progress = _ease( _coef );
	}
	
	inline function getRealProgress()
	{
		return _coef;
	}

	public function kill()
	{
		if( dead )
		{
			#if debug
			throw("fx already dead");
			#else
			trace("Warning : fx already dead");
			#end
			return;
		}
		dead = true;
		dispatchOnFinish(this);
		manager.remove(this);
	}
}
