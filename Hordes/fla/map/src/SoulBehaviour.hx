package ;

class SoulBehaviour
{
	public var mc : flash.MovieClip;
	var _ox:Float;
	var _oy:Float;
	var _px:Float;
	var _py:Float;
	var _dir: flash.geom.Point<Float>;
	var _matrix : flash.geom.Matrix;
	var time : Float;
	var angle : Float;
	var _target : flash.geom.Point<Float>;
	var scale : Float;
	
	public function new( mc : flash.MovieClip, scale=1.0)
	{
		this.mc = mc;
		this._dir = new flash.geom.Point<Float>(Math.random() - .5, Math.random() - .5);
		this._dir.normalize(scale * (Math.random() * .2 + .2));
		this._target = _dir.clone();
		this._ox = mc._x;
		this._oy = mc._y;
		
		this._px = _ox + _target.y;
		this._py = _oy + _target.y;
		updateSoul(mc._x, mc._y);
		
		this.time = 0.0;
		this.angle = 0;
		this.scale = scale;
		this._matrix = new flash.geom.Matrix();
				
		Boot.addListener( this.run );
	}
	
	function updateSoul(px:Float, py:Float)
	{
		mc._rotation = Math.atan2( _py - py, _px - px ) * 180 / Math.PI - 90;
		mc._x = _px;
		mc._y = _py;
	}
	
	public function run()
	{
		var px = _px;
		var py = _py;
		_dir.x = (time * _dir.x) + (1.0 - time) * _target.x;
		_dir.y = (time * _dir.y) + (1.0 - time) * _target.y;
		_dir.normalize((.2 + Math.random() * .2) * scale);
		
		_px += _dir.x;
		_py += _dir.y;
		
		updateSoul(px, py);
		
		time -= 0.012;
		if( time <= 0 )
		{
			var radius = 30 * scale;
			var dist = (_px - _ox) * (_px - _ox) + (_py - _oy) * (_py - _oy);
			if( dist > radius )
			{
				_target.x = ((_px > _ox) ? -1 : 1) * Math.random() * radius * 2;
				_target.y = ((_py > _oy) ? -1 : 1) * Math.random() * radius * 2;
				_target.normalize(1);
				time = 1.0;
			}
		}
	}
	
	public function dispose()
	{
		Boot.removeListener( this.run );
		mc.removeMovieClip();
	}
}