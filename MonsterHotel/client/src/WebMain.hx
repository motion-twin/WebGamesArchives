#if !standalone
	#error "standalone flag required"
#end

/**
 * Entry point for standalone swf (for-the-web)
 */
class WebMain {

	function new() {
		#if !debug
		// static entry point
		flash.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener( flash.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onErrorEvent );
		#end

		#if !mobile
		mt.flash.Screenshot.setCallback(function(){
			return mt.flash.Screenshot.exportScene2d( Main.ME.scene );
		});
		flash.external.ExternalInterface.addCallback("onFriendRequest",onFriendRequest);
		mt.flash.MouseWheelTrap.captureAllEvents();
		#end
		com.Protocol.init();

		//var d = mt.net.Codec.getInitData();

		function onReady( client : mt.Page ) {
		}

		for(url in Const.DOMAINS)
			flash.system.Security.allowDomain(url);

		Main.main();
		//function onPrepared() {
			//new GameClient( onReady, d );
		//}
		//GameClient.prepare(onPrepared);
	}

	var hasError:Bool;
	function onErrorEvent(e:flash.events.UncaughtErrorEvent) {
		if ( hasError ) return;
		hasError = true;
		//
		var title:String = "";
		var stack:String = "";
		var message:String = "";
		//
		if( Std.is(e.error, flash.errors.Error) )
		{
			title = "Error";
			var error =  cast(e.error, flash.errors.Error);
			message = error.message;
			//on peut avoir la vraie stack
			stack = error.getStackTrace();
		}
		else if( Std.is(e.error, flash.events.ErrorEvent) )
		{
			title = "ErrorEvent";
			message = cast(e.error, flash.events.ErrorEvent).text;
			stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		}
		else
		{
			title = "Unknown";
			message = Std.string(e.error);
			stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
		}
		//
		haxe.Timer.delay( function() {
			var http = new mt.net.Http("/tid/logError" );
			var logs = mt.Console.dump();
			http.setParameter("err", title+"\n"+message+"\n" + stack+"\nCaps:"+mt.Lib.getNativeCaps()+"\nLogs:\n"+logs );
			http.request( true );
			new page.FatalError(title, message, stack);
		}, 1 );
	}

	function onFriendRequest(){
		if( Game.ME != null )
			Game.ME.inboxSync();
	}

}

