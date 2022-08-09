class Live {
	static var VIDEO_URL = "http://gdata.youtube.com/feeds/api/videos?q=%%&orderby=viewCount&max-results=1";
	static var IMAGE_URL = "http://search.yahooapis.com/ImageSearchService/rss/imageSearch.xml?appid=yahoosearchimagerss&query=%%";
	public static var term		: UserTerminal = null;

	// TODO implémenter un timeout pour éviter
	// qu'on se recoive une requête tardivement et que ca zappe le panel de droite...

	public static function loadVideo(f:FSNode) {
		var keywords = getKeywords(f);
		var url = VIDEO_URL.split("%%").join(keywords);
		var r = new haxe.Http(url);
		r.onData = function(data) {
			onVideoData(data,f);
		}
		r.request(true);
	}

	public static function onVideoData(data:String, f:FSNode) {
		try {
			var xml = Xml.parse(data);
			var doc = new haxe.xml.Fast(xml.firstChild());
			var node = doc.node.entry.node.id;
			var id = node.innerData.split("/").pop();
			if ( id==null )
				throw "no id";
			f.embedData = "video|"+id;
			term.updateCopies(f);
			Manager.delay( callback(UserTerminal.CNX.JsMain.embedVideo.call, [f.name, id]), Std.random(1000)+2000 );
		}
		catch(e:String) {
			#if debug trace("FAILURE : "+e); #end
			UserTerminal.CNX.JsMain.print.call([f.name,Lang.get.ExternalError]);
		}
	}

	// ***

	public static function loadImage(f:FSNode) {
		var keywords = getKeywords(f);
		var url = IMAGE_URL.split("%%").join(keywords);
		var r = new haxe.Http(url);
		r.onData = function(data) {
			onImageData(data,f);
		}
		r.request(true);
	}

	public static function onImageData(data:String, f:FSNode) {
		try {
			var xml = Xml.parse(data);
			var doc = new haxe.xml.Fast(xml.firstChild());
			var items = doc.node.channel.nodes.item;
			if ( items==null )
				throw "no item";
			var list = new Array();
			for (item in items) {
				var thumb = item.node.resolve("media:thumbnail").att.url;
				var big = item.node.link.innerData;
				if ( thumb==null || big==null )
					continue;
				list.push({thumb:thumb, big:big});
			}
			if ( list.length==0 )
				throw "result list is empty, no big nor thumb";
			var pic = list[f.id%list.length];
			f.embedData = "image|"+pic.thumb+"|"+pic.big;
			term.updateCopies(f);
			Manager.delay( callback(UserTerminal.CNX.JsMain.embedImage.call, [f.name, pic.thumb, pic.big]), Std.random(1000)+1000 );
		}
		catch(e:String) {
			#if debug trace("FAILURE : "+e); #end
			UserTerminal.CNX.JsMain.print.call([f.name,Lang.get.ExternalError]);
		}
	}

	// ***

	static function getKeywords(f:FSNode) {
		return StringTools.htmlEscape( f.name.split(".")[0] );
	}

}
