package game.viewer;

import game.Resolver;
import game.Event;

/*
 * Produce a result similar to neko's GamePrinter, usefull neko/swf game resolver behaviour for comparison.
 * Triggered by txtOnly html parameter.
 */
class Bufferer implements GameListener {

	public static var IMMEDIATE_FLUSH = false;

	var oldTrace : Dynamic;
	var buf : StringBuf;
	var resolver : game.Resolver;

	public function new(){
		oldTrace = haxe.Log.trace;
		haxe.Log.trace = trace;
		buf = new StringBuf();
		var dataUrl = "/sample.txt?v=2";
		var params = flash.Lib.current.loaderInfo.parameters;
		if (Reflect.field(params, "dataUrl") != null){
			dataUrl = Reflect.field(params, "dataUrl");
		}
		var request = new haxe.Http(dataUrl);
		request.onData = onData;
		request.request(true);
	}

	function flush(){
		haxe.Firebug.trace(buf.toString(), null);
		buf = new StringBuf();
	}

	function trace(v:Dynamic, ?infos:haxe.PosInfos):Void {
		buf.add(infos.fileName);
		buf.add(":");
		buf.add(infos.lineNumber);
		buf.add(": ");
		buf.add(v);
		buf.add("\n");
		if (IMMEDIATE_FLUSH)
			flush();
	}

	function onData(str){
		var data = haxe.Unserializer.run(str);
		resolver = new game.Resolver(data);
		resolver.addEventListener(this);
		while (resolver.next()){
		}
		printBoard(resolver.board);
		if (!IMMEDIATE_FLUSH)
			flush();
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
		if (IMMEDIATE_FLUSH)
			flush();
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
		if (IMMEDIATE_FLUSH)
			flush();
	}
}

