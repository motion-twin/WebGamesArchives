package mt.deepnight.deprecated.assets;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

#else

import mt.deepnight.deprecated.SpriteLibBitmap;

#end

typedef Slice = {
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
	public static var SLICES : Array<Slice> = new Array();

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
		var sourceUrl = path+"/"+sourceName;
		try Context.resolvePath(sourceUrl) catch( e : Dynamic ) { AssetTools.error("Image "+sourceName+" not found", p); null; }
		var sourceType = {
			pos : p,
			pack : [],
			name : "_BITMAP_"+AssetTools.cleanUpString(xmlUrl),
			meta : [{ name : ":bitmap", pos : p, params : [{ expr : EConst(CString(sourceUrl)), pos : p }] }],
			params : [],
			isExtern : false,
			fields : [],
			kind : TDClass({ pack : ["flash","display"], name : "BitmapData", params : [] }),
		};
		Context.defineType(sourceType);
		
		var zeroExpr = { expr:EConst(CInt("0")), pos:p }
		var newSourceExpr = { expr : ENew({pack:sourceType.pack, name:sourceType.name, params:[]}, [zeroExpr,zeroExpr]), pos:p }
		
		
		// New lib declaration
		var blockContent : Array<Expr> = [];
		blockContent.push( macro var _lib = mt.deepnight.deprecated.assets.TexturePacker.parseXml($fileContentExpr, $newSourceExpr) );
		blockContent.push( macro _lib );
		
		return { pos:p, expr:EBlock(blockContent) }
	}
	
	
	#if !macro
	
	static inline function makeChecksum(slice:Slice) : String {
		return slice.name+","+slice.x+","+slice.y+","+slice.wid+","+slice.hei+","+slice.offX+","+slice.offY+","+slice.fwid+","+slice.fhei;
	}
	
	public static function parseXml(xmlString:String, source:flash.display.BitmapData) {
		var lib = new SpriteLibBitmap(source);
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
						slice.name = slice.name.substr(slice.name.lastIndexOf("/")+1);
					
					// Remove leading numbers and "_"
					if( leadNumber.match(slice.name) ) {
						slice.name = slice.name.substr(0, leadNumber.matchedPos().pos);
						while( slice.name.length>0 && slice.name.charAt(slice.name.length-1)=="_" ) // trim leading "_"
							slice.name = slice.name.substr(0, slice.name.length-1);
					}
					
					// New serie
					if( last==null || last.name!=slice.name)
						frame = 0;
					
					var csum = makeChecksum(slice);
					if( !slices.exists(csum) ) {
						// Not an existing slice
						slices.set(csum, frame);
						slice.frame = frame;
						lib.sliceCustom(slice.name, slice.frame, slice.x, slice.y, slice.wid, slice.hei, {x:slice.offX, y:slice.offY, realWid:slice.fwid, realHei:slice.fhei} );
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
}