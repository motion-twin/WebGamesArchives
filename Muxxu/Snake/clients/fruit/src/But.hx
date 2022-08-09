import Protocole;
import mt.bumdum9.Lib;


class But extends flash.display.Sprite {//}
	
	
	public var ww:Int;
	public var hh:Int;
	public var ax:Float;
	public var ay:Float;
	public var frames:Array<pix.Frame>;
	var gfx:pix.Element;
	var action:Void->Void;
	var active:Bool;

	public function new(f,fr) {
		
		action  = f;
		super();
		frames = fr;
		ax = 0.5;
		ay = 0.5;
		ww = 21;
		hh = 12;
		
		//
		gfx = new pix.Element();
		addChild(gfx);
		
				
		// BEHAVIOURS
		flash.Lib.current.stage.addEventListener( flash.events.MouseEvent.CLICK, click );
		
		//
		out();

	}
	
	
	public function update() {
		var pos = Snk.getMousePos(this);
		var isActive = Math.abs(pos.x) < ww * 0.5 && Math.abs(pos.y) < hh * 0.5 && Main.MOUSE_IN;
		if( active && !isActive ) out();
		if( !active && isActive ) over();
	}
	
	function over() {
		active = true;
		setState(1);
	}
	function out() {
		active = false;
		setState(0);

	}
	function click(e) {
		if(!active) return;
		over();
		action();
	}
	function setState(n:Int) {
		var fr = frames[n];
		if( fr == null ) return;
		gfx.drawFrame(fr, ax, ay);
		Main.screen.update();
	}
	
	
	public function setActive(act) {
		active = act;
		setState(active?0:2);
	}
	
	
	public function kill() {
		flash.Lib.current.stage.removeEventListener( flash.events.MouseEvent.CLICK, click );
		if( parent != null ) parent.removeChild(this);
	}
	
	

	
//{
}












