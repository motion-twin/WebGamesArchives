import MapCommon;

class FlashMap implements mt.Protect{
	public static var MANAGER	: Manager = null;

	static var cnx 				: haxe.remoting.ExternalConnection = null;
	static var ctx 				: haxe.remoting.Context = new haxe.remoting.Context();
	static var info = null;

	public static function connect() {
		Boot.log("FlashMap creates js connection!");
		ctx.addObject("api",FlashMap);
		try {
			cnx = haxe.remoting.ExternalConnection.jsConnect("cnx", ctx);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (onReady): "+e);
		}
	}

	public static function isFlashReady() {
		MANAGER.onAskedMeIfReady();
		return true;
	}

	public static function isJsReady() : Bool{
		try {
			Boot.log("isJsReady check! "+cnx.api.isJsReady);
			var r:Bool = cnx.api.isJsReady.call(null);
			Boot.log("result:" + r);
			return r;
		} catch(e:Dynamic) {
			Manager.fatal("JsConnexion FAILED !");
			return false;
		}
	}

	public static function reboot() {
		try {
			cnx.api.reboot.call([]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (reboot): "+e);
		}
	}

	public static function askInfos() {
		try {
			var raw = cnx.api.getInfo.call([]);
			onResponse(raw);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (getInfo): "+e);
		}
	}

	public static function checkInfo() {
		if( MANAGER.onResponse != null ) {
			return;
		}

		try {
			cnx.api.hasInfo.call(null);
		} catch(e:Dynamic) {
			Manager.fatal("err : "+e);
		}
	}

	public static function move(zid:Int,dx:Int,dy:Int) {
		try {
			cnx.api.move.call([zid,dx,dy]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (move): "+e);
		}
	}

	public static function dispose() {
		MANAGER.dispose();
	}

	public static function sendCoord(cityX:Int,cityY:Int, x:Int,y:Int) {
		try {
			cnx.api.sendCoord.call([cityX,cityY, x,y]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (sendCoord): "+e);
		}
	}

	public static function onResponse(r:String) {
		if( r == null )
			throw "null response";

		try {
			var raw = MapCommon.decode( StringTools.urlDecode(r) );
			MANAGER.onResponse( haxe.Unserializer.run( raw ) );
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (onResponse): "+haxe.Stack.exceptionStack().join( "\n"));
		}
	}
}
