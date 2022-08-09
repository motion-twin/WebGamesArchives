package net;
import Protocol;

class ToraSender extends Sender {
	
	var url : String;
	var cache : Array<ClientAction>;
	var proto : tora.Protocol;
	var http : HttpSender;
	var connecting : Bool;
	var sentCount : Int;

	public function new(url, pid, visible) {
		super();
		this.url = url;
		cache = [];
		connecting = true;
		sentCount = 1;
		proto = tools.Codec.connect(url, CConnect(pid,visible), onToraData, onToraError);
	}
	
	override function hasPending() {
		return http == null ? sentCount > 0 : http.hasPending();
	}
	
	override function send(act) {
		if( connecting )
			cache.push(act);
		else if( http != null )
			http.send(act);
		else {
			if( version > 0 )
				act = CVersion(version, act);
			sentCount++;
			tools.Codec.send(proto, url, act);
		}
	}
	
	function flushCache() {
		connecting = false;
		var cache = cache;
		this.cache = [];
		for( a in cache )
			send(a);
	}
	
	function onToraData( r : ServerAction ) {
		switch( r ) {
		case SToraResult(r):
			sentCount--;
			onData(r);
			if( connecting )
				flushCache();
		default:
			onData(r);
		}
	}
	
	function onToraError( e : Dynamic ) {
		// failed to connect : ignore error
		if( connecting ) {
			flash.external.ExternalInterface.call("eval", "$('#offline_tcp').css({display:''}); null");
			proto.close();
			proto = null;
			http = new HttpSender(url);
			http.onData = onData;
			flushCache();
		} else
			onError(e);
	}
	
}