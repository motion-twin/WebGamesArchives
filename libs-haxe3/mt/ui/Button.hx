package mt.ui;

import flash.events.Event;
import mt.Console;
import mt.flash.EventTools;
import mt.MLib;
import mt.Ticker;

class Button<T:flash.display.Sprite> 
{
	public static var DEFAULT_MOVE_CANCEL:Float = 30;
	static var UP_LIST:List<Button<Dynamic>> = new List();
	static var moveCanceled:Bool;
	static var clickPositionX:Float;
	static var clickPositionY:Float;
	
	static var initialized = false;
	static function initialize()
	{
		if ( initialized ) return;
		EventTools.listen( flash.Lib.current.stage, EventTools.UP_EVENT, _onStageUp );
		EventTools.listen( flash.Lib.current.stage, EventTools.DOWN_EVENT, _onStageDown );
		initialized = true;
	}
	
	static function _onStageDown(e:Event)
	{
		mt.Console.log("Button::mouseDown");
		clickPositionX = flash.Lib.current.stage.mouseX;
		clickPositionY = flash.Lib.current.stage.mouseY;
		Ticker.global.listen(checkMove);
	}
	
	static function _onStageUp(e:Event)
	{
		mt.Console.log("Button::mouseUp  listeners:"+UP_LIST.length);
		var target = e.target;
		var copy = Lambda.list(UP_LIST);
		UP_LIST = new List();
		for ( b in copy )
		{
			b.onUp(target);
		}
		moveCanceled = false;
		Ticker.global.unlisten(checkMove);
	}
	
	static function checkMove()
	{
		var mx = flash.Lib.current.stage.mouseX, my = flash.Lib.current.stage.mouseY;
		moveCanceled = MLib.fabs(mx - clickPositionX) > DEFAULT_MOVE_CANCEL || MLib.fabs(my - clickPositionY) > DEFAULT_MOVE_CANCEL;
		if( moveCanceled )
		{
			Ticker.global.unlisten(checkMove);
		}
	}
	
	public var onClick(default, set):Null < Void->Void > ;
	function set_onClick(f) { onClick = f; return f; }
	
	public var onCanceled(default, set):Null < Void->Void > ;
	function set_onCanceled(f) { onCanceled = f; return f; }
	
	public var onOver(default, set):Null < Void->Void > ;
	function set_onOver(f) { onOver = f; return f; }
	
	public var onOut(default, set):Null < Void->Void > ;
	function set_onOut(f) { onOut = f; return f; }
	
	public var onSelected(default, set):Null < Void->Void > ;
	function set_onSelected(f) { onSelected = f; return f; }
	
	public var onReleased(default, set):Null < Void->Void > ;
	function set_onReleased(f) { onReleased = f; return f; }
	
	public var onEnabled(default, set):Null < Void->Void > ;
	function set_onEnabled(f) { onEnabled = f; return f; }
	
	public var onDisabled(default, set):Null < Void->Void > ;
	function set_onDisabled(f) { onDisabled = f; return f; }
	
	//if the button requires a double validation (MOBILE !)
	public var doubleValidation:Bool;
	//graphics object attached to that button
	public var root(default, null):T;
	//if the button is currently selected
	public var selected(default, null):Bool;
	//enable/disable the button.  onEnabled/onDisabled calback are dispatched
	public var enabled(default, set):Bool;
	//drag mode does makes out/over event be disabled
	public var dragged(default, set):Bool;
	var numClick:Int;
	
	public function new( p_mc:T ) 
	{
		if( !initialized ) initialize();
		root = p_mc;
		root.mouseChildren = false;
		root.mouseEnabled = true;
		doubleValidation = false;
		init();
	}
	
	public function init() 
	{
		if( root == null ) return;
		enabled = true;
		selected = false;
		moveCanceled = false;
		numClick = 0;
	}
	
	public function clean() 
	{
		onClick = onOut = onOver = onSelected = onReleased = null;
	}
	
	public function dispose()
	{
		if( root == null ) return;
		EventTools.unlisten( root, EventTools.DOWN_EVENT, _onSelected );
		EventTools.unlisten( root, EventTools.OUT_EVENT, _onOut );
		EventTools.unlisten( root, EventTools.OVER_EVENT, _onOver );
		root = null;
		numClick = 0;
	}
	
	function _onOver(e:flash.events.Event) 
	{
		if( !enabled || moveCanceled ) return;
		if( onOver != null ) onOver();
		EventTools.listen( root, EventTools.OUT_EVENT, _onOut );
		EventTools.unlisten( root, EventTools.OVER_EVENT, _onOver );
	}
	
	function _onOut(e:flash.events.Event)
	{
		if( !enabled ) return;
		if( onOut != null ) onOut();
		EventTools.listen( root, EventTools.OVER_EVENT, _onOver );
		EventTools.unlisten( root, EventTools.OUT_EVENT, _onOut );
		numClick = 0;
	}
	
	function _onSelected(e:flash.events.Event) 
	{
		if( !enabled || moveCanceled ) return;
		if( !doubleValidation && onSelected != null) onSelected();
		selected = true;
		UP_LIST.add(this);
	}
	
	function onUp(p_target:flash.display.DisplayObject)
	{
		if( enabled )
		{
			if( p_target == root && !moveCanceled )
			{
				if( onReleased != null ) onReleased();
				if( doubleValidation && numClick == 0 )
				{
					numClick++;
					if( onSelected != null ) onSelected();
					UP_LIST.add(this);
				} 
				else
				{
					#if mobile
					if( onOut != null ) onOut();
					#end
					if ( onClick != null )
					{
						mt.Console.log("We click button " + mt.flash.Lib.printHierarchy(root));
						onClick();
					}
					
					numClick = 0;
				}
			}
			else
			{
				#if mobile
				if( onOut != null ) onOut();
				#end
				if( onCanceled != null ) onCanceled();
				numClick = 0;
			}
		}
	}
	
	function set_enabled(p_value:Bool):Bool 
	{
		if ( root == null ) 
			return false;
		
		if( p_value && enabled != p_value )
		{
			EventTools.listen( root, EventTools.DOWN_EVENT, _onSelected );
			EventTools.listen( root, EventTools.OVER_EVENT, _onOver );
		}
		else if( !p_value && enabled != p_value ) 
		{
			if( selected ) 
			{
				UP_LIST.remove(this);
				selected = false;
			}
			EventTools.unlisten( root, EventTools.DOWN_EVENT, _onSelected );
			EventTools.unlisten( root, EventTools.OVER_EVENT, _onOver );
			EventTools.unlisten( root, EventTools.OUT_EVENT, _onOut );
		}
		numClick = 0;
		enabled = p_value;
		root.buttonMode = enabled;
		
		if( enabled && onEnabled != null ) onEnabled();
		else if( !enabled && onDisabled != null ) onDisabled();
		
		return enabled;
	}
	
	inline function set_dragged(p_value:Bool):Bool 
	{
		if ( root == null || !enabled ) 
			return false;
		
		if ( dragged != p_value ) 
		{
			dragged = p_value;
			if ( dragged ) 
			{
				EventTools.unlisten( root, EventTools.OUT_EVENT, _onOut );
				EventTools.unlisten( root, EventTools.OVER_EVENT, _onOver );
			} 
			else 
			{
				EventTools.listen( root, EventTools.OUT_EVENT, _onOut );
				EventTools.listen( root, EventTools.OVER_EVENT, _onOver );
			}
		}
		return dragged;
	}
}
