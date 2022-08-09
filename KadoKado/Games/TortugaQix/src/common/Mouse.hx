class Mouse {
	public static var x : Int;
	public static var y : Int;
	public static var over : Bool;
	public static var down : Bool;

	public static function init(root:flash.events.EventDispatcher){
		root.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.addEventListener(flash.events.MouseEvent.MOUSE_UP,   onMouseUp);
		root.addEventListener(flash.events.MouseEvent.MOUSE_OVER, onMouseOver);
		root.addEventListener(flash.events.MouseEvent.MOUSE_OUT,  onMouseOut);
	}

	static function onMouseMove(e:flash.events.MouseEvent){
		x = Math.round(e.stageX);
		y = Math.round(e.stageY);
	}
	static function onMouseDown(e:flash.events.MouseEvent){
		onMouseMove(e);
		down = true;
	}
	static function onMouseUp(e:flash.events.MouseEvent){
		onMouseMove(e);
		down = false;
	}
	static function onMouseOver(e:flash.events.MouseEvent){
		onMouseMove(e);
		over = true;
	}
	static function onMouseOut(e:flash.events.MouseEvent){
		onMouseMove(e);
		over = false;
	}
}