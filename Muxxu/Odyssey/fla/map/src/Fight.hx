import Protocol;

class Fight {

	static var clientDomain : flash.system.ApplicationDomain;

	var m : Main;
	var fid : Int;
	var client : flash.display.Sprite;
	var fheal : String;
	var gmain : Dynamic;
	
	public function new(m,fid,fdata) {
		this.m = m;
		this.fid = fid;
		client = new flash.display.Sprite();
		m.htmlLock(true);
		fheal = Main.DATA.texts.get("fight_heal");
		preload(callback(init, fdata));
	}
	
	function init(fdata) {
		gmain = clientDomain.getDefinition(__unprotect__("Main"));
		gmain.startGame(fdata, client, onClientWon, onTip);
		m.uiClip.visible = false;
		onTip(null);
	}
	
	function onTip( t ) {
		if( fheal == null ) {
			m.tip(t);
			return;
		}
		if( t == null ) {
			m.js.setHTML.call(["actionBox", fheal]);
			m.tip();
		} else {
			m.clearActions();
			m.tip(t);
		}
	}
	
	public function update() {
	}
	
	public function result(r) {
		switch( r ) {
		case RHealGame(fid, tokens):
			if( fid != this.fid )
				return;
			fheal = null;
			m.clearActions();
			onTip(null);
			m.js.setHTML.call(["utoken", tokens]);
			gmain.refill();
			return;
		default:
		}
		throw "assert";
	}
	
	public function mouseMove() {
	}
	
	public function display(world:mt.DepthManager) {
		world.add(client, 0);
	}
	
	public function click(x, y) {
	}
	
	public function cleanup() {
		m.uiClip.visible = true;
	}
	
	public function action(act) {
		if( act == "runes" ) {
			if( !gmain.isMyTurn() )
				m.onResult(RMessage("runes", Main.DATA.texts.get("runes_turn")));
			else if( !gmain.isRefillable() )
				m.onResult(RMessage("runes", Main.DATA.texts.get("runes_cancel")));
			else
				m.command(AHealRunes(fid));
		}
		return true; // ignore
	}

	function onClientWon( win : Bool, data : String ) {
		m.htmlLock(false);
		m.fight = null;
		m.transition();
		m.clearActions(Main.DATA.texts.get("saving"));
		untyped m.mode.lock = true;
		m.command(AEndFight(fid, data));
	}

	public static function preload( onReady : Void -> Void ) {
		if( clientDomain != null ) {
			onReady();
			return;
		}
		var l = new flash.display.Loader();
		var done = 0;
		var next = function(_) {
			done++;
			if( done == 2 ) {
				l.parent.removeChild(l); // remove from stage
				onReady();
			}
		};
		clientDomain = new flash.system.ApplicationDomain();
		l.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, next);
		l.contentLoaderInfo.addEventListener(flash.events.Event.INIT, next);
		l.contentLoaderInfo.addEventListener(flash.events.ProgressEvent.PROGRESS, function(e:flash.events.ProgressEvent) {
			var p = Std.int(e.bytesLoaded * 100 / e.bytesTotal);
		});
		l.visible = false;
		flash.Lib.current.addChild(l);
		l.contentLoaderInfo.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e:flash.events.IOErrorEvent) Codec.displayError(e.text));
		l.load(new flash.net.URLRequest(Main.DATA.cli), new flash.system.LoaderContext(false, clientDomain));
	}
		
}