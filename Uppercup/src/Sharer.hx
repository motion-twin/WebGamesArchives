#if !noShareANE
import com.doitflash.air.extensions.shareBtn.Share;
import com.doitflash.air.extensions.shareBtn.ShareEvent;
import flash.external.ExtensionContext;
#end
import mt.deepnight.Lib;

class Sharer {
	static var initDone = false;
	#if !noShareANE
	static var s : Share = null;
	#end
	static var fallback : Null<Void->Void>;


	public static function init() {
		initDone = false;
		#if !noShareANE
		try {
			_init();
		}
		catch(e:Dynamic) {
			#if !prod
			//trace(e);
			#end
		}
		#end
	}


	#if !noShareANE
	static function _init() {
		s = new Share();
		s.addEventListener(ShareEvent.ERROR, onError);
		s.addEventListener(ShareEvent.RETURNED_TO_APP, onReturn);
		initDone = true;
	}
	#end


	#if !noShareANE
	public static function generic(str:String) {
		if( ready() )
			s.shareMessage("dialogTitle", "msgTitle", str);
	}
	#end


	public static function toTwitter(str:String, ?url:String, ?hashTags:Array<String>, ?forceFallback=false) {
		fallback = null;
		if( !ready() || forceFallback ) {
			var u = "http://www.twitter.com/share?text="+StringTools.urlEncode(str);
			if( url!=null ) {
				if( url.charAt(url.length-1)!="/" )
					url+="/";
				u+="&url="+url;
			}
			if( hashTags!=null && hashTags.length>0 )
				u+="&hashtags="+hashTags.join(",");
			gotoUrl(u);
		}
		else {
			if( url!=null )
				str+=" "+url;
			if( hashTags!=null && hashTags.length>0 )
				str+=" #"+hashTags.join(" #");
			twitter(str);
			fallback = function() toTwitter(str,url,hashTags,true);
		}
	}

	static function twitter(str:String) { // avoid Flash crashes
		#if !noShareANE
		s.shareViaTwitter(str);
		#end
	}


	public static function toFacebook(url:String, ?forceFallback=false) {
		fallback = null;
		if( !ready() || forceFallback )
			gotoUrl("https://www.facebook.com/sharer.php?u="+url);
		else {
			fb();
			fallback = function() toFacebook(url,true);
		}
	}
	static function fb() { // avoid Flash crashes
		#if !noShareANE
		s.shareViaFacebook();
		#end
	}

	static function ready() {
		try {
			flash.external.ExtensionContext;
			return initDone;
		}catch( e:Dynamic ) {
			return false;
		}
	}

	static function gotoUrl(url:String) {
		var r = new flash.net.URLRequest(url);
		flash.Lib.getURL(r);
	}

	#if !noShareANE
	static function onError(e:ShareEvent) {
		#if !prod
		trace("ERROR: "+e);
		#end
		if( fallback!=null )
			fallback();
	}

	static function onReturn(e:ShareEvent) {}
	#end
}
