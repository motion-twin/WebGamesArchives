import Protocole;
class Avatar extends flash.display.Sprite{//}

	var size:Int;
	var loaded:Int;
	var fdl:flash.display.Loader;
	
	public function new(size,url) {
		super();
		this.size = size;
		loaded = 0;
		load(url);
		
		//var gfx = graphics;
		//gfx.beginFill(0x888888);
		//gfx.drawEllipse(0, 0, size, size);
		
	}
	
	public function load( url ) {
		
		var loadContext = new flash.system.LoaderContext();
		loadContext.checkPolicyFile = true ;
		
		loaded = 0;
		fdl = new flash.display.Loader();
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.Event.INIT, onLoaded );
		fdl.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, error);
		fdl.load( new flash.net.URLRequest(url), loadContext );
		
	}
	function error(e) {
		//trace("avatar not found !");
	}
	function onLoaded(e) {
		loaded++;
		if( loaded == 2 ) {
			addChild(fdl);
			fdl.width = size;
			fdl.height = size;
		}
	}
	
	
//{
}

