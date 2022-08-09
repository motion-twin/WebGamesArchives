package mt.heaps.slib.assets;

import mt.heaps.slib.SpriteLib;

class Atlas {
	static inline function trim(s:String, c:String) {
		while( s.charAt(0)==c )
			s = s.substr(1);
		while( s.charAt(s.length-1)==c )
			s = s.substr(0, s.length-1);
		return s;
	}

	public static function load(atlasPath:String) : SpriteLib {
		var res = hxd.Res.load(atlasPath);
		var basePath = atlasPath.indexOf("/")<0 ? "" : atlasPath.substr(0, atlasPath.lastIndexOf("/")+1);

		// Load source image separately
		var r = ~/^([a-z0-9_\-]+)\.((png)|(jpg)|(jpeg)|(gif))/igm;
		var raw = res.toText();
		var bd : hxd.BitmapData = null;
		if( r.match(raw) )
			bd = hxd.Res.load(basePath + r.matched(0)).toBitmap();

		// Create SLib
		var atlas = res.toAtlas();
		var lib = convertToSlib(atlas, bd);
		res.watch( function() {
			var l = convertToSlib(atlas, bd);
			lib.reloadUsing(l);
		});

		return lib;
	}

	static function convertToSlib(atlas:hxd.res.Atlas, bd:Null<hxd.BitmapData>) {
		var contents = atlas.getContents();

		var tex = contents.iterator().next()[0].t.getTexture();
		var tile = h2d.Tile.fromTexture(tex);
		var lib = new mt.heaps.slib.SpriteLib(tile, bd);

		var ids = new Map();
		var frameReg = ~/[a-z_\-]+([0-9]+)$/gi;
		for( originalId in contents.keys() ) {
			var e = contents.get(originalId)[0];

			// Original ID
			lib.sliceCustom(
				originalId, 0,
				e.t.x, e.t.y, e.t.width, e.t.height,
				{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
			);
			ids.set(originalId,originalId);

			// Original ID but parse terminal number
			var k = originalId;
			var f = 0;
			if( frameReg.match(k) ) {
				var s = frameReg.matched(1);
				f = Std.parseInt(s);
				k = trim( k.substr(0, k.lastIndexOf(s)), "_" );
			}
			lib.sliceCustom(
				k, f,
				e.t.x, e.t.y, e.t.width, e.t.height,
				{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
			);
			ids.set(k,k);

			// Remove folders and parse terminal number
			var k = originalId;
			if( k.indexOf("/")>=0 )
				k = k.substr( k.lastIndexOf("/")+1 );
			if( frameReg.match(k) ) {
				var s = frameReg.matched(1);
				k = trim( k.substr(0, k.lastIndexOf(s)), "_" );
			}
			lib.sliceCustom(
				k, f,
				e.t.x, e.t.y, e.t.width, e.t.height,
				{ x:-e.t.dx, y:-e.t.dy, realWid:e.width, realHei:e.height }
			);
			ids.set(k,k);
		}

		for( id in ids.keys() ) {
			var frames = [];
			for(i in 0...lib.countFrames(id))
				frames.push(i);
			lib.__defineAnim(id, frames);
		}

		return lib;
	}
}
