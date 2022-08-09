import flash.display.MovieClip;

/**
 * ...
 * @author de
 */

class Mouse
{
	var root : flash.display.MovieClip;
	
	var evtMouseClicked : Bool;
	
	public var wasDown(default,null) : Bool;
	public var isDown(default,null)  : Bool;
	
	public var onClick(default,null)  : Bool;
	public var onHold(default,null)  : Bool;
	public var onDown(default,null)  : Bool;
	
	public var oldPos : { x:Int, y:Int };
	public var pos : { x:Int, y:Int };
	
	public function init()
	{
		//flash.Lib.current.addChild( root );
		
		evtMouseClicked = false;
		flash.Lib.current.addEventListener( flash.events.MouseEvent.MOUSE_DOWN,function(e)
		{
			evtMouseClicked = true;
			//Debug.MSG("mouse down");
		});
		flash.Lib.current.addEventListener(  flash.events.MouseEvent.MOUSE_UP,function(e)
		{
			evtMouseClicked = false;
			//Debug.MSG("mouse up");
		});
		
		oldPos = { x:-1, y:-1 };
		pos = { x:-1, y:-1 };
	}
	
	public function new()
	{
		root = new MovieClip();
		init();
	}
	
	public function update()
	{
		oldPos.x = pos.x;
		oldPos.y = pos.y;
		
		pos.x = Std.int(root.mouseX);
		pos.y = Std.int(root.mouseY);
		
		wasDown = isDown;
		isDown = evtMouseClicked;
		
		onClick = wasDown && !isDown;
		onHold = wasDown && isDown;
		onDown = !wasDown && isDown;
		//Debug.MSG("mpos " + pos.x +" " + pos.y);
	}
	
}