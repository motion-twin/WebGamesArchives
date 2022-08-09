import Protocole;
import mt.bumdum9.Lib;


class Main {
	
	public static var dev = false;
	
	public static var MOUSE_IN = false;
	public static var root:flash.display.Sprite;
	public static var MAX = 8;
	
	public static var buts:Array<But>;
	public static var screen:pix.Screen;
	public static var domain:String;
	public static var inter:Inter;
	
	
	static function main() {
		Gfx.init();
		Lang.init();
		root = new flash.display.Sprite();
		Codec.VERSION = Data.CODEC_VERSION ;
		// PARAMS
		var params = flash.Lib.current.loaderInfo.parameters;
		domain = Reflect.field( params, "dom" );
		var data:_HallOfFame = Codec.getData("data");
		buts = [];
		
		if( cast(data) == 1586 ) {
			dev = true;
			data = { _sections:[SS_FRIENDS, SS_GROUP("motion-twin"), SS_ARCHIVE, SS_TOP], _me:"Bumdum" };
			for( i in 0...2 ) data._sections.push(SS_DRAFT(i, i));
			data._sections.push(SS_RAINBOW);
		}
		
		inter = new Inter(data);
		
	
		// SCREEN
		screen = new pix.Screen(root, Inter.WIDTH*2, Inter.HEIGHT*MAX * 2, 2);
		flash.Lib.current.addChild(screen);
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);

		//
		initMouseTracker();
		
	}
	
	static public function update(e) {
		inter.update();
		for( b in buts ) b.update();
		screen.update();
	}
	static public function initMouseTracker() {

		var mc = flash.Lib.current.stage;
		mc.addEventListener( flash.events.Event.MOUSE_LEAVE,		function(e) { Main.MOUSE_IN = false;}, false, 0, true );
		mc.addEventListener( flash.events.MouseEvent.MOUSE_MOVE,	function(e) { Main.MOUSE_IN = true; }, false, 0, true );
		/*
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		*/

	}

	
}












