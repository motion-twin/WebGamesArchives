package ;

import mt.pix.Element;

/**
 * ...
 * @author de
 */

class ElementEx extends mt.pix.Element
{
	static var guid = 0;
	var uid:Int;
	public var data : Dynamic;
	
	public function new() 
	{
		super();
		
		#if debug
		if (guid == -1)
			Debug.BREAK("break on alloc this one");
		uid = guid++;
		#end
		
		mouseEnabled = false;
		mouseChildren  = true;
		data = { };
	}
	
	public function mouseOver(f)
	{
		mouseEnabled = true;
		super.addEventListener(flash.events.MouseEvent.MOUSE_OVER, f);
	}
	
		
}