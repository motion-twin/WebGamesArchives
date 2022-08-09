package mt.deepnight.slb.assets;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import mt.deepnight.slb.BLib;

#end

//this definition can invade other module, so let's stick to privacy for now
private typedef Slice = {
	var name	: String;
	var frame	: Int;
	var x		: Int;
	var y		: Int;
	var wid		: Int;
	var hei		: Int;
	var offX	: Int;
	var offY	: Int;
	var fwid	: Int;
	var fhei	: Int;
}


class TexturePacker {
	@:noCompletion public static var SLICES : Array<Slice> = new Array();


	/**
	 * Import the specified TexturePacker data using OpenFl Assets
	 *
	 * @param xmlUrl		You really don't understand this parameter?
	 * @param ?treatFoldersAsPrefixes	If TRUE, folder names in sub-texture names will be used as part of the identifier. If FALSE, the folder names are just discarded.
	 */
	public static macro function importXmlOpenFl(xmlUrl:String, ?treatFoldersAsPrefixes:Bool=false) {
		var p = Context.currentPos();

		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var basePath = ( xmlUrl.indexOf("/") >= 0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "" ) ;
		if ( basePath.length > 0 )
			basePath += "/";
		var id = AssetTools.cleanUpString(xmlUrl);

		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker XML not found: "+xmlUrl, p); null; }
		var xml = new haxe.xml.Fast( Xml.parse(sys.io.File.getContent(file)) );
		Context.addResource("_XML_"+id, sys.io.File.getBytes(file));

		// Bitmap source declaration
		var imgName = xml.node.TextureAtlas.att.imagePath;
		var imgUrl = basePath + imgName;
		try Context.resolvePath(imgUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker image not found: "+imgUrl, p); null; }

		Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(xmlUrl));
		Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(imgUrl));

		// New lib declaration
		var blockContent : Array<Expr> = [];
		var folderFlagExpr = Context.makeExpr(treatFoldersAsPrefixes, p);
		var rscIdExper = Context.makeExpr("_XML_"+id, p);
		var rscGetter = macro haxe.Resource.getString($rscIdExper);
		var imgUrlExpr = { pos:p, expr:EConst(CString(imgUrl)) }
		var newImgExpr = macro openfl.Assets.getBitmapData($imgUrlExpr,true);
		blockContent.push( macro var _lib = mt.deepnight.slb.assets.TexturePacker.parseXml($rscGetter, $newImgExpr, $folderFlagExpr) );
		blockContent.push( macro _lib );

		return { pos:p, expr:EBlock(blockContent) }
	}
	
	#if h3d
	/**
	 * Import the specified TexturePacker data using Mt Assets
	 *
	 * @param xmlUrl		You really don't understand this parameter?
	 * @param ?treatFoldersAsPrefixes	If TRUE, folder names in sub-texture names will be used as part of the identifier. If FALSE, the folder names are just discarded.
	 */
	public static macro function importXmlMt(xmlUrl:String, ?treatFoldersAsPrefixes:Bool=false, ?texPath:String, ?defer:Bool=false, ?forceRetainTex:Bool=false ) {
		var p = Context.currentPos();

		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var basePath = ( xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "" );
		if ( basePath.length > 0 )
			basePath += "/";
		var id = AssetTools.cleanUpString(xmlUrl);

		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker XML not found: "+xmlUrl, p); null; }
		var xml = new haxe.xml.Fast( Xml.parse(sys.io.File.getContent(file)) );
		Context.addResource("_XML_"+id, sys.io.File.getBytes(file));

		// Bitmap source declaration
		var imgName = xml.node.TextureAtlas.att.imagePath;
		var imgUrl = basePath + imgName;
		//try Context.resolvePath(imgUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker image not found: "+imgUrl, p); null; }

		Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(xmlUrl));
		//Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(imgUrl));

		// New lib declaration
		var blockContent : Array<Expr> = [];
		var folderFlagExpr = Context.makeExpr(treatFoldersAsPrefixes, p);
		var rscIdExper = Context.makeExpr("_XML_"+id, p);
		var rscGetter = macro haxe.Resource.getString($rscIdExper);
		var imgUrlExpr = { pos:p, expr:EConst(CString(texPath==null?imgUrl:texPath)) }
		var forceRetainExpr = Context.makeExpr(forceRetainTex,p);

		if( defer ){
			var newImgExpr = macro mt.Assets.getTile($imgUrlExpr,$forceRetainExpr);

			blockContent.push( macro var _bmp = $newImgExpr );
			blockContent.push( macro var _fun = function() return  mt.deepnight.slb.assets.TexturePacker.parseXml($rscGetter,  null, $folderFlagExpr, _bmp() ) );
			blockContent.push( macro _fun );
		}else{
			var newImgExpr = macro mt.Assets.getTile($imgUrlExpr,$forceRetainExpr)();
			
			blockContent.push( macro var _lib = mt.deepnight.slb.assets.TexturePacker.parseXml($rscGetter,  null, $folderFlagExpr, $newImgExpr ) );
			blockContent.push( macro _lib );
		}
		return { pos:p, expr:EBlock(blockContent) }
	}

	public static macro function importXmlMtDeferred( name:String, worker:ExprOf<mt.Worker>, onComplete:ExprOf<BLib->Void>,?treatFoldersAsPrefixes:Bool=false, ?texPath:String, ?forceRetainTex:Bool=false ){
		var p = Context.currentPos();
		var nameExpr = Context.makeExpr(name,p);
		var treatFoldersAsPrefixesExpr = Context.makeExpr(treatFoldersAsPrefixes,p);
		var texPathExpr = Context.makeExpr(texPath,p);
		var forceRetainTexExpr = Context.makeExpr(forceRetainTex,p);

		return macro {
			var f : Void->BLib;
			var task = $worker.enqueue( new mt.Worker.WorkerTask(function(){
				f = TexturePacker.importXmlMt($nameExpr,$treatFoldersAsPrefixesExpr,$texPathExpr,true,$forceRetainTexExpr) ;
			}));
			task.onComplete = function(){
				$onComplete( f() );
			}
		}
	}


	#end

	/**
	 * Import the specified TexturePacker data using native Haxe Resource system
	 *
	 * @param xmlUrl		You really don't understand this parameter?
	 * @param ?treatFoldersAsPrefixes	If TRUE, folder names in sub-texture names will be used as part of the identifier. If FALSE, the folder names are just discarded.
	 */
	public static macro function importXml(xmlUrl:String, ?treatFoldersAsPrefixes:Bool=false) {
		var p = Context.currentPos();

		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var basePath = ( xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "" ) + "/";
		var id = AssetTools.cleanUpString(xmlUrl);

		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker XML not found: "+xmlUrl, p); null; }
		var xml = new haxe.xml.Fast( Xml.parse(sys.io.File.getContent(file)) );
		Context.addResource("_XML_"+id, sys.io.File.getBytes(file));

		// Bitmap type declaration
		var imgName = xml.node.TextureAtlas.att.imagePath;
		var imgUrl = basePath + imgName;
		try Context.resolvePath(imgUrl) catch( e : Dynamic ) { AssetTools.error("TexturePacker image not found: "+imgUrl, p); null; }

		var imgType = {
			pos : p,
			pack : [],
			name : "_BITMAP_"+id,
			meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(imgUrl)), pos : p }] }],
			params : [],
			isExtern : false,
			fields : [],
			kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
		};

		if( !AssetTools.typeExists("_BITMAP_"+id) )
			Context.defineType(imgType);

		Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(xmlUrl));
		Context.registerModuleDependency(Context.getLocalModule(), Context.resolvePath(imgUrl));

		// New lib declaration
		var blockContent : Array<Expr> = [];
		var folderFlagExpr = Context.makeExpr(treatFoldersAsPrefixes, p);
		var rscIdExper = Context.makeExpr("_XML_"+id, p);
		var rscGetter = macro haxe.Resource.getString($rscIdExper);
		var zeroExpr = { expr:EConst(CInt("0")), pos:p }
		var newImgExpr ={ expr : ENew({pack:imgType.pack, name:imgType.name, params:[]}, [zeroExpr,zeroExpr]), pos:p }
		blockContent.push( macro var _lib = mt.deepnight.slb.assets.TexturePacker.parseXml($rscGetter, $newImgExpr, $folderFlagExpr) );
		blockContent.push( macro _lib.initBdGroups() );
		blockContent.push( macro _lib );

		return { pos:p, expr:EBlock(blockContent) }
	}



	#if !macro

	static inline function makeChecksum(slice:Slice) : String {
		return slice.name+","+slice.x+","+slice.y+","+slice.wid+","+slice.hei+","+slice.offX+","+slice.offY+","+slice.fwid+","+slice.fhei;
	}

	@:noCompletion public static function parseXml(xmlString:String, source:flash.display.BitmapData, treatFoldersAsPrefixes:Bool #if h3d, ?tile:h2d.Tile#end) : BLib {
		var lib = new BLib(source #if h3d, tile #end);
		var xml = new haxe.xml.Fast( Xml.parse(xmlString) );
		var removeExt = ~/\.(png|gif|jpeg|jpg)/gi;
		var leadNumber = ~/([0-9]*)$/;
		try {
			// Parse frames
			var slices : Map<String, Int> = new Map();
			var anims : Map<String, Array<Int>> = new Map();
			for(atlas in xml.nodes.TextureAtlas) {
				var last : Slice = null;
				var frame = 0;
				for(sub in atlas.nodes.SubTexture) {
					// Read XML
					var slice : Slice = {
						name	: sub.att.name,
						frame	: 0,
						x		: Std.parseInt(sub.att.x),
						y		: Std.parseInt(sub.att.y),
						wid		: Std.parseInt(sub.att.width),
						hei		: Std.parseInt(sub.att.height),
						offX	: !sub.has.frameX ? 0 : Std.parseInt(sub.att.frameX),
						offY	: !sub.has.frameY ? 0 : Std.parseInt(sub.att.frameY),
						fwid	: !sub.has.frameWidth ? Std.parseInt(sub.att.width) : Std.parseInt(sub.att.frameWidth),
						fhei	: !sub.has.frameHeight ? Std.parseInt(sub.att.height) : Std.parseInt(sub.att.frameHeight),
					}

					// Clean-up name
					slice.name = removeExt.replace(sub.att.name, "");
					if( slice.name.indexOf("/")>=0 )
						if( treatFoldersAsPrefixes )
							slice.name = StringTools.replace(slice.name, "/", "_");
						else
							slice.name = slice.name.substr(slice.name.lastIndexOf("/")+1);

					// Remove leading numbers and "_"
					if( leadNumber.match(slice.name) ) {
						slice.name = slice.name.substr(0, leadNumber.matchedPos().pos);
						while( slice.name.length>0 && slice.name.charAt(slice.name.length-1)=="_" ) // trim leading "_"
							slice.name = slice.name.substr(0, slice.name.length-1);
					}

					// New serie
					if( last == null || last.name != slice.name)
						frame = 0;

					var csum = makeChecksum(slice);
					if( !slices.exists(csum) ) {
						// Not an existing slice
						slices.set(csum, frame);
						slice.frame = frame;
						lib.sliceCustom(slice.name, slice.frame, slice.x, slice.y, slice.wid, slice.hei, {x:slice.offX, y:slice.offY, realWid:slice.fwid, realHei:slice.fhei} );
						// Also slice using the raw name
						lib.sliceCustom(sub.att.name, 0, slice.x, slice.y, slice.wid, slice.hei, {x:slice.offX, y:slice.offY, realWid:slice.fwid, realHei:slice.fhei} );
						frame++;
					}

					var realFrame = slices.get(csum);
					if( !anims.exists(slice.name) )
						anims.set(slice.name, [realFrame]);
					else
						anims.get(slice.name).push(realFrame);

					SLICES.push(slice);

					last = slice;
				}
			}

			// Define anims
			for(k in anims.keys())
				lib.__defineAnim(k, anims.get(k));

		}
		catch(e:Dynamic) {
			throw SLBError.AssetImportFailed(e);
		}

		return lib;
	}
	#end


	#if !macro
	public static function downloadXml(xmlUrl:String, imgUrl:String, treatFoldersAsPrefixes:Bool, onComplete:BLib->Void, ?onCustomError:Void->Void = null) {
		var xml : String = null;
		var bd : flash.display.BitmapData = null;
		var steps = 0;
		
		function onError(msg, url) {
			throw SLBError.AssetImportFailed("TexturePacker download failed:"+msg+" "+url);
		}			

		function onOneDone() {
			steps++;
			if( steps>=2 ) {
				var lib = parseXml(xml, bd, treatFoldersAsPrefixes);
				onComplete(lib);
			}
		}

		// Load XML
		var r = new haxe.Http(xmlUrl);
		r.onError = function(msg) {
			if (onCustomError == null)
				onError(msg, xmlUrl);
			else
				onCustomError();
		};
		r.onData = function(data) {
			xml = data;
			onOneDone();
		}
		r.request(true);

		// Load bitmap
		var l = new flash.display.Loader();
		#if flash
		l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.NETWORK_ERROR, function(e) onError(e.text, imgUrl) );
		#end
		l.contentLoaderInfo.addEventListener( flash.events.IOErrorEvent.IO_ERROR, function(e) onError(e.text, imgUrl) );
		l.contentLoaderInfo.addEventListener( flash.events.Event.COMPLETE, function(_) {
			var bmp : flash.display.Bitmap = cast( l.contentLoaderInfo.content );
			bd = bmp.bitmapData;
			onOneDone();
		});
		var ctx = new flash.system.LoaderContext(true);
		var r = new flash.net.URLRequest(imgUrl);
		l.load(r, ctx);
	}
	#end
}
