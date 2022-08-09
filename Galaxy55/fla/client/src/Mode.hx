import Common;
import Protocol;

private class FakeConnection implements haxe.remoting.Connection {
	public function new() {
	}
	public function resolve( name : String ) : haxe.remoting.Connection {
		return this;
	}
	public function call(args:Array<Dynamic>) : Dynamic {
		return null;
	}
}

class Mode {
	
	public static var LOCAL = false;
	
	var cnx : haxe.remoting.Connection;
	var askCallback : Bool -> Void;
	var inventoryMode : Bool;
	public var lock : Bool;//locks update loop of client
	public var api : net.Api;
	public var root : flash.display.Sprite;
	public var engine : h3d.Engine;
	
	public function new(root, engine, api) {
		this.root = root;
		this.engine = engine;
		this.api = api;
		api.onCommand = onCommand;
		var ctx = new haxe.remoting.Context();
		var api : Dynamic = getJsApi();
		api._cmd = function(data:String) {
			var t = new tools.Codec();
			onCommand(t.unserialize(StringTools.urlDecode(data)));
		};
		api._askAnswer = function(b) {
			var cb = askCallback;
			askCallback = null;
			cb(b);
		};
		ctx.addObject('api',api);
		cnx = haxe.remoting.ExternalConnection.jsConnect('cnx', ctx).api;
		if( LOCAL ) cnx = new FakeConnection();
	}
	
	public function getJsApi() : Dynamic {
		return {};
	}
	
	public function onChunk( x : Int, y : Int, bytes : haxe.io.Bytes ) {
	}

	public function showHelpTip( ?tid : String, ?p : { } ) {
		if( tid == null ) cnx.showHelpTip.call([]) else cnx.showHelpTip.call([getText(tid, p)]);
	}
	
	function ask( txt : String, callb : Bool -> Void ) {
		if( LOCAL )
			haxe.Timer.delay(callback(callb, true), 1000);
		else {
			askCallback = callb;
			cnx.ask.call([txt]);
		}
	}
	
	public function getText( tid : String, ?p : {} ) {
		var t = try cnx.getText.call([tid]) catch( e : Dynamic ) null;
		if( t == null || t == "#"+tid ) {
			t = "#" + tid;
			if( p != null ) t += Std.string(p);
		} else if( p != null ) {
			for( v in Reflect.fields(p) )
				t = t.split("%" + v.substr(1) + "%").join(Std.string(Reflect.field(p, v)));
		}
		return t;
	}
	
	public function onCommand(cmd:ServerAction) {
		switch( cmd ) {
		case SOk:
		case SRedir(url):
			api.disconnect();
			haxe.Timer.delay(function() flash.Lib.getURL(new flash.net.URLRequest(url), "_self"),500);
		case SChunk(x, y, bytes, cmp, diff):
			var b = bytes.getData();
			if( cmp ) b.uncompress();
			if( diff != null ) {
				var i = 0;
				var diff = diff.getData();
				var len : Int = diff.length;
				flash.Memory.select(b);
				while( i < len ) {
					var x = diff[i++];
					var y = diff[i++];
					var z = diff[i++];
					var block = diff[i++] | (diff[i++] << 8);
					flash.Memory.setI16( Const.addr(x,y,z) << 1, block );
				}
			}
			onChunk(x, y, haxe.io.Bytes.ofData(b));
		case SLoadModule(url,inv):
			lock = true;
			inventoryMode = inv;
			cnx.loadModule.call([url,inv]);
		case SExitModule:
			lock = false;
			inventoryMode = false;
			cnx.exitModule.call([]);
		case SMessage(msg, next):
			askCallback = function(_) onCommand(next);
			cnx.prompt.call([msg]);
		default:
			tools.Codec.displayError("UNHANDLED " + Std.string(cmd));
		}
	}
	
}