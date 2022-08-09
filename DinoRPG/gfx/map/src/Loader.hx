class Loader {

	var mapData : MapData;
	var count : Int;
	var scroll : flash.MovieClip;
	var map : flash.MovieClip;
	var loading : flash.MovieClip;

	function new( root : flash.MovieClip ) {
		scroll = root.createEmptyMovieClip("scroll",0);
		scroll._visible = false;
		map = scroll.createEmptyMovieClip("bg",0);
		loading = root.attachMovie("loading","loading",1);
		count = 2;
		loadData();
		loadMap();
	}

	function reportError( e : Dynamic ) {
		haxe.Log.trace(e,cast { fileName : "ERROR" });
	}

	function loadData() {
		var data = Reflect.field(flash.Lib._root,"data");
		if( data != null ) {
			onMapData(data);
			return;
		}
		
		var h = new haxe.Http(Reflect.field(flash.Lib._root,"url"));
		var me = this;
		h.onData = onMapData;
		h.onError = reportError;
		h.request(false);
	}

	function onMapData(data : String) {
		try {
			mapData = haxe.Unserializer.run(data);
		} catch( e : Dynamic ) {
			reportError(e);
			return;
		}
		done();
	}

	function loadMap() {
		var mcl = new flash.MovieClipLoader();
		var me = this;
		mcl.onLoadError = function(_,err) {
			me.reportError(err);
		}
		mcl.onLoadInit = function(_) {
			me.done();
		}
		mcl.loadClip(Reflect.field(flash.Lib._root, "map"), map);
	}

	function done() {
		if( --count > 0 )
			return;
		scroll._visible = true;
		loading.removeMovieClip();
		var inst = new Map(scroll, map, mapData);
		flash.Lib.current.onEnterFrame = inst.loop;
	}


	static function main() {
		new Loader(flash.Lib.current);
	}

}