import Protocole;
import mt.bumdum9.Lib;


class But extends flash.display.Sprite {//}

	public var ww:Int;
	public var hh:Int;
	var action:Void->Void;
	
	public var sleepAlpha:Float;
	
	var active:Bool;
	var highlight:Bool;
	var sleep:Bool;


	public function new(f:Void->Void) {
		action  = f;
		super();
		sleep = false;
		active = false;
		highlight = false;
		ww = 10;
		hh = 10;
		sleepAlpha = 1;
		
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, mouseDown );
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.MOUSE_UP, mouseUp );
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, click );
	}
	
	
	public function update() {
		if( sleep ) return;
		
		var pos = Snk.getMousePos(this);
		var on = Math.abs(pos.x) < ww * 0.5 && Math.abs(pos.y) < hh * 0.5 ;
	
		if( active && !on ) out();
		if( !active && on ) over();
	}
	
	function over() {
		active = true;
		setState(1);
	}
	function out() {
		active = false;
		setState(highlight?3:0);
	}
	function mouseDown(e) {
		if( sleep || !active ) return;
		setState(2);
	}
	function mouseUp(e) {
		if( sleep ) return;
		if(active) 	over();
		else		out();
	}
	
	function click(e) {
		if(!active) return;
		over();
		action();
	}
	function setState(n) {
		
	}
	

	public function setHighlight(flag) {
		highlight = flag;
		setState(highlight?3:0);
	}
	public function setSleep(flag) {
		alpha = flag?sleepAlpha:1;
		sleep = flag;
		active = false;
		setState(sleep?4:0);
	}
		
	
	public function setSize(w,h) {
		ww = w;
		hh = h;
		setState(0);
	}
	
	
	public function kill() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.MOUSE_DOWN, mouseDown );
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.MOUSE_UP, mouseUp );
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		if( parent != null ) parent.removeChild(this);
	}
	
	

	
//{
}












