import Protocole;
import mt.bumdum9.Lib;


class Module  extends flash.display.Sprite {//}

	static var MARGIN = 52;
	
	public var mid:Int;
	var mcw:Int;
	var mch:Int;
	
	public function new() {
		mcw = Collection.WIDTH - MARGIN;
		mch = Collection.HEIGHT;
		super();
		x  = MARGIN;
		Collection.me.addChild(this);
	}
	
	public function init() {
		
	}
	
	// UPDATE
	public function update() {
		
	}
	
	public function kill() {
		Collection.me.removeChild(this);
	}

	public function getTitle(str) {
		var field =  Snk.getField(Gfx.col("green_0", 50), 20, -1, "upheaval");
		field.text = str;
		field.width = field.textWidth+4;
		field.x = Std.int((mcw - field.width) * 0.5);
		return field;
		//page.addChild(field);
		
	}
	

	
//{
}








