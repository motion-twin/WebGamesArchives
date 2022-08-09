package mt.fx;
import mt.bumdum9.Lib;

class GotoAndStop extends Fx{//}

	var autoplay:Bool;
	var frame:Int;
	var parent:flash.display.DisplayObjectContainer;
	public var list:Array<String>;
	
	public function new(par, inst, n, autoplay = false) {
		super();
		this.autoplay = autoplay;
		frame = n;
		parent = par;
		list = [inst];
		update();
	}

	
	override function update() {
		var mc:flash.display.MovieClip = cast parent;
		for( str in list ) {
			mc = Reflect.field(mc, str);
			if( mc == null ) break;
		}
		
		if( mc != null ) {
			if( autoplay )		mc.gotoAndPlay(frame);
			else 				mc.gotoAndStop(frame);
			//trace("!!");
			kill();
		}

	}

	
	
//{
}