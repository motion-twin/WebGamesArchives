package mt.heaps.slib.assets;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#else
import mt.heaps.slib.SpriteLib;
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
	
	macro public static function stream(worker:ExprOf<mt.Worker>, onComplete:ExprOf<SpriteLib->Void>, xmlPath:String){
		var e = macro {
			var libcb;
			var xmlContent, xml, img;
			
			var xmlTask = new mt.Worker.WorkerTask(function() {
				xmlContent = hxd.Res.load($v{xmlPath}).toText();
				xml = new haxe.xml.Fast( Xml.parse(xmlContent) );
			});
			$worker.enqueue(xmlTask);
			
			var textureTask = new mt.Worker.WorkerTask(function() {
				var imgPath = xml.node.TextureAtlas.att.imagePath;
				img = hxd.Res.load(imgPath);
			});
			$worker.enqueue(textureTask);
			
			var libTask = new mt.Worker.WorkerTask(function() {
				libcb = function() return mt.heaps.slib.assets.TexturePacker.parseXml(xml, img.toTile(), img.toBitmap(), false);
			});
			//probleme, c'est le parsing qui est le process le plus couteux et lui on ne peut l'executer sur le thread du worker
			//comme c'est deprecated à venir, je laisse ceci de côté
			libTask.onComplete = function(){ $onComplete( libcb() ); }
			$worker.enqueue(libTask);
		}
		
		//var p = new haxe.macro.Printer();
		//trace(p.printExpr(e));
		return e;
	}

	#if !macro
	@:noCompletion public static var SLICES : Array<Slice> = new Array();
	public static function load(xmlPath:String, ?treatFoldersAsPrefixes:Bool=false) : SpriteLib {
		var xmlContent = hxd.Res.load(xmlPath).toText();
		var xml = new haxe.xml.Fast( Xml.parse(xmlContent) );
		var imgPath = xml.node.TextureAtlas.att.imagePath;
		var img = hxd.Res.load(imgPath);
		return parseXml(xmlContent, img.toTile(), img.toBitmap(), treatFoldersAsPrefixes);
	}
	
	static inline function makeChecksum(slice:Slice) : String {
		return slice.name+","+slice.x+","+slice.y+","+slice.wid+","+slice.hei+","+slice.offX+","+slice.offY+","+slice.fwid+","+slice.fhei;
	}

	@:noCompletion public static function parseXml(?xml:haxe.xml.Fast, ?xmlString:String, t:h2d.Tile, bd:hxd.BitmapData, treatFoldersAsPrefixes:Bool) : SpriteLib {
		var lib = new SpriteLib(t,bd);
		if( xml == null ) xml = new haxe.xml.Fast( Xml.parse(xmlString) );
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
}
