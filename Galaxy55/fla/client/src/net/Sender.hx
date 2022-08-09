package net;
import Protocol;

class Sender {

	var version : Int;

	function new() {
		var linf = flash.Lib.current.loaderInfo;
		var r = ~/\/swf\/([0-9+])\//;
		if( r.match(linf.url) )
			version = Std.parseInt(r.matched(1));
		else
			version = Std.parseInt(linf.parameters.v);
	}
		
	public function disableBatching() {
	}

	public dynamic function onError( err : Dynamic ) {
		tools.Codec.displayError(err);
	}
	
	public dynamic function onData( c : ServerAction ) {
	}
	
	public function hasPending() {
		return false;
	}
	
	public function send( act : ClientAction ) {
	}
	
	public function disconnect() {
	}
	
}