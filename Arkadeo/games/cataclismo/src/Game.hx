import mt.bumdum9.Lib;

import api.AKApi;
import api.AKProtocol;
import api.AKConst;
import TitleLogo;

/**
 * MAYA
 */
class Game extends SP, implements game.IGame{
	
	public static var WIDTH = 600;
	public static var HEIGHT = 480;
	//var bg:SP;
	
	public var seed:mt.Rand;
	
	var timer:Int;
	var mode : GameMode;
	public var level:Level;
	public static var me :Game;
	var fxManager :mt.fx.Manager;
	public var tweener : mt.deepnight.Tweenie;
	
	
	
	public function new() {
		super();
		me = this;
		
		/* transaltion */
		var raw = haxe.Resource.getString("texts."+AKApi.getLang()+".xml");
		if( raw == null ) raw = haxe.Resource.getString("texts.en.xml");
		Text.init( raw );
		
		#if dev
		//haxe.Log.setColor(0xFFFFFF);
		haxe.Firebug.redirectTraces();
		#end
		timer = 0;
		fxManager = new mt.fx.Manager();
		mt.fx.Fx.DEFAULT_MANAGER = fxManager;
		
		tweener = new mt.deepnight.Tweenie();
		
		seed = new mt.Rand(AKApi.getSeed());
		
		//LEVEL
		level = new Level(AKApi.getLevel());
		addChild(level);
		
		/* mouse cursor */
		if(flash.ui.Mouse.supportsNativeCursor) {
			registerMouseCursor(new ui.OpenHandCursor(32, 32, true, 0), "open_hand");
			registerMouseCursor(new ui.ClosedHandCursor(32, 32, true, 0), "closed_hand");
			flash.ui.Mouse.cursor = "open_hand";
		}
	}
	
	/**
	 * init various mouse cursors from bitmap data
	 * @param	bmp
	 * @param	name
	 */
	function registerMouseCursor(bmp:flash.display.BitmapData,name:String) {
		var cvector = new flash.Vector<flash.display.BitmapData>();
		cvector[0] = bmp;
			
		var cdata = new flash.ui.MouseCursorData();
		cdata.hotSpot = new flash.geom.Point(10, 10);
		cdata.data = cvector;
			
		flash.ui.Mouse.registerCursor(name, cdata);
	}
	
	
	
	public static function random(i:Int) {
		return me.seed.random(i);
	}
	
	public function update(render:Bool) {
		
		//throw "poru";
		FTimer.update();
		level.update();
		fxManager.update();
		tweener.update();
	}
	
}
