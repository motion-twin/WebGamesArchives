package mt.deepnight.deprecated.assets;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import mt.deepnight.deprecated.SpriteLibBitmap;

#end


class ShoeBox {
	public static macro function importXml(xmlUrl:String) {
		var p = Context.currentPos();
		
		xmlUrl = StringTools.replace(xmlUrl, "\\", "/");
		var path = xmlUrl.indexOf("/")>=0 ? xmlUrl.substr(0, xmlUrl.lastIndexOf("/")) : "";
		
		// XML parsing
		var file = try Context.resolvePath(xmlUrl) catch( e : Dynamic ) { AssetTools.error("File not found : "+xmlUrl, p); null; }
		var fileContent = sys.io.File.getContent(file);
		var xml = new haxe.xml.Fast( Xml.parse(fileContent) );
		var fileContentExpr = { expr:EConst(CString(fileContent)), pos:p }
		
		// Bitmap source declaration
		var sourceName = xml.node.TextureAtlas.att.imagePath;
		var sourceType = {
			pos : p,
			pack : [],
			name : "_BITMAP_"+AssetTools.cleanUpString(xmlUrl),
			meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(path+"/"+sourceName)), pos : p }] }],
			params : [],
			isExtern : false,
			fields : [],
			kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
		};
		Context.defineType(sourceType);
		
		var zeroExpr = { expr:EConst(CInt("0")), pos:p }
		var newSourceExpr = { expr : ENew({pack:sourceType.pack, name:sourceType.name, params:[]}, [zeroExpr,zeroExpr]), pos:p }
		
		
		// OPTIONAL: anim file
		var animFileExt = [".anims.xml", ".anim.xml"];
		var animUrl = "";
		var animFile = null;
		for(ext in animFileExt) {
			animUrl = StringTools.replace( xmlUrl, ".xml", ext );
			animFile = try Context.resolvePath(animUrl) catch( e : Dynamic ) { null; }
			if( animFile!=null )
				break;
		}
		
		// New lib declaration
		var blockContent : Array<Expr> = [];
		blockContent.push(
			macro var _lib = mt.deepnight.deprecated.assets.ShoeBox.parseXml($fileContentExpr, $newSourceExpr)
		);
		
		
		if( animFile!=null ) {
			var fileContent = sys.io.File.getContent(animFile);
			var xml = new haxe.xml.Fast( Xml.parse(fileContent).firstChild() );
			var ecalls : Array<Expr> = [];
			for( a in xml.nodes.a ) {
				// Anim parsing
				var group = a.att.group;
				var frames = try{ SpriteLibBitmap.parseAnimDefinition(a.innerHTML, a.has.timing ? Std.parseInt(a.att.timing):null); } catch(e:Dynamic) { AssetTools.error(animUrl+" parse error for group "+group.toUpperCase()+": "+e, p); null; };
				var egroup = { pos:p, expr:EConst(CString(group)) }
				var eframes = Lambda.array(Lambda.map( frames, function(f) return { pos:p, expr:EConst(CInt(""+f)) } ));
				var eframesArray = { pos:p, expr:EArrayDecl(eframes) };
				
				// Anim definition call
				blockContent.push(
					macro _lib.__defineAnim($egroup, $eframesArray)
				);
			}
		}

		// Block return
		blockContent.push( macro _lib );
		
		return { pos:p, expr:EBlock(blockContent) }
	}
	
	
	
	
	
	#if !macro
	public static function downloadXml(xmlUrl:String, imgUrl:String, onComplete:SpriteLibBitmap->Void) {
		var xml : String = null;
		var bd : flash.display.BitmapData = null;
		var steps = 0;
		
		function onError(msg, url) {
			throw SLBError.AssetImportFailed("Shoebox download failed:"+msg+" "+url);
		}
		
		function onOneDone() {
			steps++;
			if( steps>=2 ) {
				var lib = parseXml(xml, bd);
				onComplete(lib);
			}
		}
		
		// Load XML
		var r = new haxe.Http(xmlUrl);
		r.onError = function(msg) {
			onError(msg, xmlUrl);
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
	
	
	public static function parseXml(xmlString:String, source:flash.display.BitmapData) {
		var lib = new SpriteLibBitmap(source);
		var xml = new haxe.xml.Fast( Xml.parse(xmlString) );
		try {
			for(atlas in xml.nodes.TextureAtlas) {
				for(sub in atlas.nodes.SubTexture) {
					var id = sub.att.name;
					var x = Std.parseInt(sub.att.x);
					var y = Std.parseInt(sub.att.y);
					var wid = Std.parseInt(sub.att.width);
					var hei = Std.parseInt(sub.att.height);
					
					//if( sub.has.frameX )
						//throw "No support (yet) for trimming in ShoeBox sheets";
						
					var r = ~/\.(png|gif|jpeg|jpg)/gi;
					id = r.replace(id, "");
					
					// Import sequences as frames
					var r = ~/([0-9]*)$/;
					r.match(id);
					var frame = Std.parseInt(r.matched(1));
					if( !Math.isNaN(frame) ) {
						// Multiple frames
						var id2 = id.substr(0, r.matchedPos().pos);
						while( id2.length>0 && id2.charAt(id2.length-1)=="_" )
							id2 = id2.substr(0, id2.length-1);
						lib.sliceCustom(id2, frame, x,y, wid,hei);
					}
					else
						lib.slice(id, x,y, wid,hei );
				}
			}
		}
		catch(e:Dynamic) {
			throw SLBError.AssetImportFailed(e);
		}

		return lib;
	}
	
	#end
}