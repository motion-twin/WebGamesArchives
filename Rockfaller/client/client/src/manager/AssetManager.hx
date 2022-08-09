package manager;

import mt.deepnight.slb.assets.TexturePacker;
import mt.deepnight.slb.BLib;

/**
 * ...
 * @author Tipyx
 */

typedef WorldBG = {
	id: String,
	path: String,
	height: Int,
	width: Int,
	minLevel: Int
}

class AssetManager {
	public static var WIDTH : Int = #if standalone 666 #else 1024 #end;
	public static var BG_WIDTH : Int = WIDTH;

	public static var WORLDS : Array<Array<WorldBG>>;

	public static function INIT() {
		WORLDS = [
			[{id: "beginning", path: "worlds/beginning.png", height: 650, width: WIDTH, minLevel: 120},
			{id: "worldClassic", path: "worlds/worldClassic.png", height: 2048, width: WIDTH, minLevel: 120},
			{id: "worldIce", path: "worlds/worldIce.png", height: 2048, width: WIDTH, minLevel: 120},
			{id: "worldMagma", path: "worlds/worldMagma.png", height: 2048, width: WIDTH, minLevel: 120},
			{id: "worldWater", path: "worlds/worldWater.png", height: 2048, width: WIDTH, minLevel: 120},
			{id: "worldCiv", path: "worlds/worldCiv.png", height: 2048, width: WIDTH, minLevel: 120},
			{id: "worldCore", path: "worlds/worldCore.png", height: 2048, width: WIDTH, minLevel: 120}],

			[{id: "worldCorebegin", path: "worlds/worldCorebegin.png", height: 2048, width: WIDTH, minLevel: 150},
			{id: "worldNightmare", path: "worlds/worldNightmare.png", height: 2048, width: WIDTH, minLevel: 150},
			{id: "worldLimbo", path: "worlds/worldLimbo.png", height: 2048, width: WIDTH, minLevel: 150},
			{id: "worldTree", path: "worlds/worldTree.png", height: 2048, width: WIDTH, minLevel: 180},
			{id: "worldTreeEnd", path: "worlds/worldTreeEnd.png", height: 2048, width: WIDTH, minLevel: 180},]
		];

		for (arW in WORLDS ) {
			for (w in arW) {
				var meta = haxe.Json.parse(openfl.Assets.getText(w.path.split(".png").join(".meta.json")));
				#if standalone
				w.width = Reflect.field(meta, "width");
				w.height = Reflect.field(meta,"height");
				#else
				w.width = meta.width;
				w.height = meta.height;
				#end
				BG_WIDTH = w.width;				
			}
		}
	}

	public static function GET_BD( id:String ) : WorldBitmap {
		var p = null;
		for (ar in WORLDS) {
			p = Lambda.find(ar, function(o) return o.id == id);
			if (p != null)
				break;
		}
		if( p == null )
			throw "No BitmapData with the id : " + id;

		var bmp = new WorldBitmap( p.path, WIDTH, p.height );
		return bmp;
	}
}

class WorldBitmap extends h2d.Bitmap {
	var path : String;
	var active : Bool;
	public var isReady(default,null) : Bool;

	static var lock : Bool = false;

	public function new( path : String, w: Int, h: Int ) {
		super( h2d.Tile.fromColor(0x0, w, h) );
		this.path = path;
		this.filter = true;
	}

	public function activate() {
		if( active )
			return;

		active = true;
		var f;
		var task = new mt.Worker.WorkerTask(function() {
			f = mt.Assets.getTile(path);
		});
		task.onComplete = function() {
			if( !active ) {
				// cancel (TODO: cancel without uploading to GPU)
				f().dispose();
			}else{
				tile = f();
				isReady = true;
			}
			lock = false;
			#if cpp
			cpp.vm.Gc.run( true );
			#end
		}
		var tryEnqueue = null;
		tryEnqueue = function(){
			if( lock ){
				haxe.Timer.delay(tryEnqueue,50);
				return;
			}
			Main.getWorker().enqueue(task);
			lock = true;
		}
		tryEnqueue();
	}

	public function deactivate() {
		if( !active )
			return;

		active = false;
		if( isReady ) {
			var t = tile;
			tile.dispose();
			tile = h2d.Tile.fromColor( 0x0, t.width, t.height );
			isReady = false;
		}
	}
}
