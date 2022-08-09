package gfx;

import Lib;

@:bind("gfx.Arrows")
class Arrows extends MovieClip, implements mt.kiroukou.events.Signaler
{
	@:as3signal( flash.events.MouseEvent.CLICK, this )
	public function onClick() { }
	
	@:as3signal( flash.events.Event.ENTER_FRAME, this )
	function onFrame() { }
	
	public var dir : MoveDir;
	public var entity: InteractiveEntity;
	public var activated(default, null):Bool;
	
	var _mc : flash.display.SimpleButton;
	var _ox:Float;
	var _oy:Float;
	var _tx:Float;
	var _ty:Float;
	var _backward:Bool;
	
	public function new(entity : InteractiveEntity, move:MoveDir)
	{
		super();
		this.mouseEnabled = true;
		this.buttonMode = true;
		this.dir = move;
		this.entity = entity;
		this.hitArea = new Sprite();
	}
	
	public function show()
	{
		visible = true;
		alpha = 0.0;
		reset();
		alpha = 1.0;
	}
	
	public function hide()
	{
		visible = false;
	}
	
	inline public function clearHitArea()
	{
		hitArea.graphics.clear();
	}
	
	public function reset()
	{
		_mc.x = _ox;
		_mc.y = _oy;
	}
	
	public function updateHitArea( bounds : Rectangle )
	{
		clearHitArea();
		hitArea.graphics.beginFill(0, 0.);
		hitArea.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
		hitArea.graphics.endFill();
		addChild(hitArea);
	}
	
	override public function gotoAndStop( frame, ?scene )
	{
		super.gotoAndStop( frame );
		updateHitArea( getBounds(this) );
		_tx = _ox = Std.int(_mc.x);
		_ty = _oy = Std.int(_mc.y);
	}
	
	public function clean()
	{
		unbindAll();
	}
	
	public function isDir( move : MoveDir )
	{
		return dir == move;
	}
	
	public function deactivate()
	{
		activated = false;
	}
	
	public function activate()
	{
		if( activated ) return;
		// for security
		unbindOnFrame(update);
		
		activated = true;
		_backward = false;
		_tx = _ox;
		_ty = _oy;
		var offset = 10;
		switch( dir )
		{
			case MLeft: 	_tx = _ox - offset;
			case MRight: 	_tx = _ox + offset;
			case MUp: 		_ty = _oy - offset;
			case MDown: 	_ty = _oy + offset;
		}
		bindOnFrame(update);
	}
	
	function update()
	{
		var tx = _tx, ty = _ty;
		if( _backward )
		{
			tx = _ox;
			ty = _oy;
		}
		_mc.x = Std.int(_mc.x + MLib.fsgn(tx - _mc.x));
		_mc.y = Std.int(_mc.y + MLib.fsgn(ty - _mc.y));
		
		if( _mc.x == tx && _mc.y == ty )
		{
			if( _backward && !activated )
			{
				unbindOnFrame(update);
			}
			else
			{
				_backward = !_backward;
			}
		}
	}
	
	public function animate( cb : Void->Void )
	{
		clean();
		reset();
		//tween().to( 0.1, alpha = 0 ).onComplete( function(_) cb() );
		alpha = 0; cb();
	}
	
	public function dispose()
	{
		clean();
		if( this.parent != null )
			this.parent.removeChild(this);
	}
}
