package game.viewer;
import game.Resolver;
import game.Event;

class Tester implements GameListener {

	static var n = 0;
	static var instance : Tester;
	static var request : haxe.Http;

	public static function main(){
		flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, loop);
	}

	public static function loop(_){
		if (request != null)
			return;
		if (instance == null)
			nextMatch();
		else if (instance.done){
			haxe.Log.clear();
			haxe.Log.trace(++n);
			instance = null;
			nextMatch();
		}
	}

	public static function nextMatch(){
		request = new haxe.Http("/admin/tester?next=1");
		request.onData = function(str){
			Tester.instance = new Tester(str);
			Tester.request = null;
		}
		request.request(true);
	}

	var url : String;
	var done : Bool;
	var oldTrace : Dynamic;
	var buf : StringBuf;
	var resolver : game.Resolver;

	public function new( url:String ){
		this.url = url;
		done = false;
		oldTrace = haxe.Log.trace;
		haxe.Log.trace = trace;
		buf = new StringBuf();
		var request = new haxe.Http(url);
		request.onData = onData;
		request.request(true);
	}

	function trace(v:Dynamic, ?infos:haxe.PosInfos):Void {
		buf.add(infos.fileName);
		buf.add(":");
		buf.add(infos.lineNumber);
		buf.add(": ");
		buf.add(v);
		buf.add("\n");
	}

	static function boardEquals(a:ScoreBoard, b:ScoreBoard):Bool {
		for (i in 0...a.length)
			for (j in 0...a[i].length)
				if (b[i][j] != a[i][j])
					return false;
		return true;
	}

	function onData(str){
		var data = haxe.Unserializer.run(str);
		var error = false;
		try {
			resolver = new game.Resolver(Reflect.field(data, "$data".substr(1)));
			resolver.addEventListener(this);
			while (resolver.next()){
			}
		}
		catch (e:Dynamic){
			haxe.Firebug.trace(Std.string(e));
			haxe.Firebug.trace(haxe.Stack.exceptionStack().join("\n"));
			error = true;
		}
		var r = if (error){
			haxe.Firebug.trace("err "+url);
			new haxe.Http(url+";ok=-1");
		}
		else if (boardEquals(resolver.board, Reflect.field(data, "$board".substr(1)))){
			haxe.Firebug.trace("ook "+url);
			new haxe.Http(url+";ok=1");
		}
		else {
			haxe.Firebug.trace("dif "+url);
			haxe.Firebug.trace("expect="+Reflect.field(data, "$board".substr(1)));
			haxe.Firebug.trace("actual="+resolver.board);
			haxe.Firebug.trace(buf.toString());
			new haxe.Http(url+";ok=0");
		}
		var me = this;
		r.onData = function(_){
			me.done = true;
		}
		r.request(true);
	}

	public function onEvent( e:game.Event ){
		switch (e){
			case DefStart:
				buf.add("** Init\n");
			case NextAttempt(round,team,bat,attempt):
				buf.add("** "+Std.string(e)
				+" ---------------------------------------- ROUND="+round
				+" TEAM="+team+" BAT="+bat+" ATTEMPT="+attempt+"\n");
			default:
				buf.add("- ["+resolver.time+"] "+Std.string(e)+"\n");
		}
	}

	public function printBoard( b:ScoreBoard ){
		buf.add("** GameOver\n");
		for (i in 0...2){
			var team = b[i];
			buf.add("|");
			buf.add(i);
			buf.add("|");
			buf.add(team.join("|"));
			buf.add("|\n");
		}
	}
}
