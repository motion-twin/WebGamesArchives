package mt.flash;

class LoadVars {

	var t : haxe.Timer;
	var lvs : Array<flash.LoadVars>;
	var url : String;
	var done : Bool;
	var timeout : Float;

	public function new( ?timeout ) {
		this.timeout = (timeout == null)?30.0:timeout;
		lvs = new Array();
	}

	public dynamic function onData( data : String ) {
		return false;
	}

	public function load( url : String ) {
		this.url = url;
		this.done = false;
		t = new haxe.Timer(Std.int(timeout * 1000));
		t.run = onTimer;
		t.run();
	}

	function onTimer() {
		var lv = new flash.LoadVars();
		lv.onData = onReceiveData;
		lv.load(url);
		lvs.push(lv);
	}

	function onReceiveData( data ) {
		if( done )
			return;
		if( data == null )
			return;
		try {
			done = onData(data);
		} catch( e : Dynamic ) {
			trace(e);
		}
		if( done ) t.stop();
	}

}