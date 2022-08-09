package;

/**
 * ...
 * @author Tipyx
 */

#if !standalone
	#error "standalone flag required"
#end

class WebMain
{

	static var START : Float = 0;

	public function new() 
	{
		
		START = haxe.Timer.stamp();

		#if !debug
			flash.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener( flash.events.UncaughtErrorEvent.UNCAUGHT_ERROR, onErrorEvent );
		#end
		
		flash.system.Security.allowDomain("fb.demo.rockfaller.com");
		flash.system.Security.allowDomain("fb.local.rockfaller.com");
		flash.system.Security.allowDomain("fb.rockfaller.com");
		flash.system.Security.allowDomain("demo.rockfaller.com");
		flash.system.Security.allowDomain("local.rockfaller.com");
		flash.system.Security.allowDomain("rockfaller.com");
		flash.system.Security.allowDomain("beta.rockfaller.com");

		mt.flash.Screenshot.setCallback(function() {
			return mt.flash.Screenshot.exportScene2d( mt.deepnight.deprecated.HProcess.GLOBAL_SCENE );
		});
		flash.external.ExternalInterface.addCallback("onFriendRequest",onFriendRequest);

		mt.flash.MouseWheelTrap.setup();
		
		new Main();
		//Main.PREPARE_FIRST_INIT(null);
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
			var t = try haxe.Timer.stamp() - START catch( e : Dynamic ) -1;
			http.setParameter("err", title+"\n"+message+"\nTime: "+t+"\n" + stack+"\nCaps:"+mt.Lib.getNativeCaps()+"\nLogs:\n"+logs );
			http.request( true );
			//Lib.current.addChild( new view.FatalError(GTexts.fatal_error_title, GTexts.fatal_error_body) );
			// TODO : Y'A UNE ERREUR
		}, 1 );
		
		process.ProcessManager.ME.showError();
	}

	function onFriendRequest() {
		if( Main.ME != null && Main.ME.gameIsLaunched )
			data.DataManager.DO_PROTOCOL(DoGetRequestsCount);
	}
}
