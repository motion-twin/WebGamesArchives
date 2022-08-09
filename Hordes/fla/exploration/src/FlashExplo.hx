import MapCommon;

class FlashExplo implements mt.Protect {
	
	public static var MANAGER	: Manager = null;

	static var cnx 				: haxe.remoting.ExternalConnection = null;
	static var ctx 				: haxe.remoting.Context = new haxe.remoting.Context();
	static var info = null;

	public static function connect() {
		ctx.addObject("api", FlashExplo);
		try {
			cnx = haxe.remoting.ExternalConnection.jsConnect( "explocnx", ctx);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (onReady): " + e);
		}
	}

	public static function isFlashReady() {
		MANAGER.onAskedMeIfReady();
		return true;
	}

	public static function isJsReady() : Bool {
		try {
			return cnx.api.isJsReady.call(null);
		} catch(e:Dynamic) {
			trace("FAILED !");
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
	
	public static function refresh() {
		try {
			cnx.api.refresh.call([]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (refresh): "+e);
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
			trace("err : "+e);
		}
	}

	public static function enterRoom() {
		try {
			cnx.api.enterRoom.call([]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (enterRoom): "+e);
		}	
	}
	
	public static function unlockDoor() {
		try {
			cnx.api.unlockDoor.call([]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (unlockDoor): "+e);
		}	
	}
	
	public static function leaveRoom() {
		try {
			cnx.api.leaveRoom.call([]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (leaveRoom): "+e);
		}	
	}
	
	public static function move(zid:Int,dx:Int,dy:Int) {
		try {
			cnx.api.move.call([zid, dx, dy]);
		} catch(e:Dynamic) {
			Manager.fatal("remoting call error (move): "+e);
		}
	}

	public static function dispose() {
		MANAGER.dispose();
	}

	public static function onResponse(r:String) {
		if( r == null )
			throw "null response";
		try {
			var raw = ExploCommon.decode( StringTools.urlDecode(r) );
			MANAGER.onResponse( haxe.Unserializer.run( raw ) );
		} catch(e : Dynamic) {
			Manager.fatal("remoting call error (onResponse): "+haxe.Stack.exceptionStack().join( "\n"));
		}
	}
}
