package net;
import Protocol;

class HttpSender extends Sender {

	var url : String;
	var pending : Array<ClientAction>;

	public function new(url) {
		super();
		this.url = url;
	}
	
	function doSend( act : ClientAction ) {
		if( version > 0 )
			act = CVersion(version, act);
		tools.Codec.load(url, act, onHttpData, callback(onActionResume,act));
	}
	
	override function send( act : ClientAction ) {
		if( pending == null ) {
			pending = [];
			doSend(act);
		} else
			pending.push(act);
	}
	
	function sendNext() {
		var next = pending.shift();
		if( next == null )
			pending = null;
		else
			doSend(next);
	}
	
	function onHttpData( cmd : ServerAction ) {
		sendNext();
		onData(cmd);
	}
	
	function onActionResume( act : ClientAction, err : Dynamic ) {
		var canRecover = false;
		if( Std.is(err, String) )
			canRecover = Std.string(err).toLowerCase().indexOf("lock wait timeout") >= 0;
		else if( Std.is(err, flash.errors.IOError) ) {
			var err : flash.errors.IOError = err;
			if( err.errorID == 2032 )
				canRecover = true;
		}
		switch( act ) {
		case CSavePos(_):
			if( canRecover ) {
				sendNext();
				return;
			}
		default:
		}
		onError(err);
	}
		
	
}