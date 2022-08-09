package exp;

import ExploreProtocol;

class ServerCall {
	
	var infos : ExploreInfos;
	
	public function new(infos) {
		this.infos = infos;
	}
	
	public function startGeneratePlanet( inf : SystemPlanetInfos, onProgress : Float -> Void, onDone : Void -> Void ) {
		#if standalone
		var progress = 0.;
		var t = new haxe.Timer(10);
		t.run = function() {
			progress += Math.random() * 0.01;
			if( progress > 1 ) {
				t.stop();
				onDone();
			}
			else
				onProgress(progress);
		}
		#else
		var pinfos = { id : inf.id, size : inf.size, waterTotal : 0, waterLevel : 0, waterFlood : 0, seed : inf.seed, biome : inf.biome };
		var api = new net.Offline(pinfos);
		var t = new haxe.Timer(10);
		var maxChunks = inf.size * inf.size;
		var sentChunks = 0;
		var level = new Level(inf.size);
		var chunks = [];
		onProgress(0);
		api.onGenError = function(code) {
			sendAction(APlanetError(inf.id, code));
		};
		t.run = function() {
			onProgress(untyped api.gen.progress * 0.99);
		};
		function sendPos() {
			var pos = level.getStartPlace(pinfos);
			if( pos == null ) {
				onProgress(0.5 + Math.random() * 0.3);
				return;
			}
			t.stop();
			onProgress(1);
			sendAction(AInitPlanet(inf.id, { sx : pos.x, sy : pos.y, sz : pos.z, water : pinfos.waterTotal, wlevel : pinfos.waterLevel } ), onDone);
		}
		function sendChunk() {
			var c = chunks.pop();
			if( c == null ) {
				t.run = sendPos;
				return;
			}
			sendAction(ASendChunk(inf.id, c.x, c.y, c.bytes), function() { onProgress( (1 - chunks.length / maxChunks) ); sendChunk(); } );
		}
		api.onCommand = function(cmd) {
			switch( cmd ) {
			case SChunk(x, y, bytes, _, _):
				var cdata = new flash.utils.ByteArray();
				cdata.writeBytes(bytes.getData());
				cdata.compress();
				level.add(x, y, bytes.getData());
				var cbytes = haxe.io.Bytes.ofData(cdata);
				if( cbytes.length > 150000 ) throw "Too much data " + [inf.seed, Type.enumIndex(inf.biome), x, y]+ " = "+cbytes.length;
				chunks.push( { x : x, y : y, bytes : cbytes } );
				if( chunks.length == maxChunks ) {
					sendChunk();
					t.run = function() {};
				}
			default:
			}
		}
		for( x in 0...inf.size )
			for( y in 0...inf.size )
				api.requestChunk(x, y);
		#end
	}
	
	public function sendAction( act : ExploreAction, ?callb ) {
		if( infos.url == null ) {
			// emulate
			if( callb != null )
				haxe.Timer.delay( callb, 500 );
			return;
		}
		#if !standalone
		tools.Codec.load(infos.url, act, if( callb == null ) onReply else function(v) if( v == COk ) callb() else onReply(v));
		#end
	}
	
	function onReply(e:ExploreCommand) {
//		trace(e);
		switch(e) {
		case COk :
		case CGoto(url):
			flash.Lib.getURL(new flash.net.URLRequest(url), "_self");
		default:
			throw "TODO "+e;
		}
	}
}