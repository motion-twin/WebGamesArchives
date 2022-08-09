import Protocole;


class Module
{//}

	public var width:Int;
	public var height:Int;
	public var root:flash.display.Sprite;
	public var dm :mt.DepthManager;

	var screen:pix.Screen;
	
	
	public function new() {
		
		root = new flash.display.Sprite();
		Main.module = this;
		dm = new mt.DepthManager(root);
		
		// SCREEN
		var scale = 2;
		screen = new pix.Screen(root, width * scale, height * scale, scale);
		Main.dm.add(screen, 0);
		
		// UPDATE
		var me = this;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, function(e) { me.update();} );
	}
	
	public function update() {
		screen.update();
		
	}

	
//{
}












