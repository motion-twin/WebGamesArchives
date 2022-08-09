import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

import Common;
import Protocol;

#if !standalone
	#error "standalone flag required"
#end

/**
 * Entry point for standalone swf (for the web)
 */
class Main {

	public static var ME		: Main;
	
	var engine					: h3d.Engine;
	
	public var MAIN_SCENE		: h2d.Scene;
	
	public var input			: Input;
	
	public var stats	: mt.flash.Stats;
	public var d				: ProtocolCom;
	
	function new() {
		ME = this;

		mt.deepnight.Lib.redirectTracesToConsole();
		
		Protocol.init();
		
		d = null;
		
		#if debug
		if ( !Reflect.hasField(flash.Lib.current.stage.loaderInfo.parameters,"data") ) {
			// standalone - debug mode
			d = ProtocolCom.DoTestLE(1);
		}
		#end
		
		if( d == null )
			d = mt.net.Codec.getInitData();
			
		trace(d);
		
		function onReady( client : mt.Page ){
			flash.Lib.current.addChild( client );
			flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, function(_) client.update() );
		}
		//
		//function onPrepared(){
			//new SampleGame( onReady, d );
		//}
		
		//SampleGame.prepare(onPrepared);
			
		input = new Input();
		
		engine = new h3d.Engine();
		engine.onReady = initData;
		engine.backgroundColor = 0x101222;
		engine.init();
		
		stats = new mt.flash.Stats();
		stats.y = 30;
		//flash.Lib.current.addChild(stats);
		
		flash.Lib.current.stage.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, function(d) { } );
		
		//#if flash
			//flash.Lib.current.addChild(new openfl.display.FPS(10, 10, 0xFFFFFF));
		//#end
	}
	
	function initData() {
		MAIN_SCENE = new h2d.Scene();
		mt.deepnight.HProcess.GLOBAL_SCENE = MAIN_SCENE;
		
		mt.fx.Fx.DEFAULT_MANAGER = new mt.fx.Manager();
		
		Settings.CREATE();
		DataManager.CREATE();
	}
	
	public function init() {
		var le = new LE();
		
		hxd.System.setLoop(update);		
	}
	
	function update() {
		mt.deepnight.Process.updateAll();
		
		DataManager.UPDATE();
		
		engine.render(MAIN_SCENE);
	}
}
