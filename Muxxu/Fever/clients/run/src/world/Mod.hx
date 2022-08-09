package world;
import Protocole;
import mt.bumdum9.Lib;

class Mod extends flash.display.Sprite{//}
	
	var ww:Int;
	var hh:Int;
	public var dm:mt.DepthManager;
	
	public function new() {
		super();
		Inter.me.setFreeze(true);
	
		dm = new mt.DepthManager(this);
		World.me.dm.add( this, World.DP_INTER );
		centerAll();
		
		//
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.CLICK, click);
		flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, update);
	}
	
	function centerAll() {
		x = Std.int((Cs.mcw*0.5 - ww) * 0.5);
		y = Std.int((Cs.mcrh * 0.5 - hh) * 0.5);
	}
	function center() {
		var mcw = Cs.mcw * 0.5;
		var mch = Inter.me.getScreenHeight();
		
		x = (mcw - ww) * 0.5;
		y = Std.int(Inter.BH + (mch - hh) * 0.5);
	}
	
	function drawBg(color) {
		graphics.beginFill(color);
		graphics.drawRect(0, 0, ww, hh);

	}
	
	function click(e) {
		
	}
	
	public function update(e) {
	
	}
		
	
	// FX
	function getDust() {
		var p = new pix.Part();
		p.setAnim(Gfx.fx.getAnim("spark_twinkle"));
		//p.setAnim(Gfx.fx.getAnim("twinkle_gray"));
		//Col.overlay( p, Col.objToCol( Col.getRainbow2(Math.random()) ) );
		p.frict = 0.95;
		p.weight = 0.05 + Math.random() * 0.05;
		p.timer = 12 + Std.random(12);
		p.anim.gotoRandom();
		return p;
	}
	
	//
	public function kill() {
		flash.Lib.current.stage.removeEventListener(flash.events.MouseEvent.CLICK, click);
		flash.Lib.current.stage.removeEventListener(flash.events.Event.ENTER_FRAME, update);
		parent.removeChild(this);
		Inter.me.setFreeze(false);
		
	}
	
	
	
	
//{
}








