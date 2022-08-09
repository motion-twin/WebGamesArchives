package net;

import Common;
import Protocol;

class Local extends Offline {
	
	var saving : Bool;
	var waterId : Int;
	var floodFlag : Bool;
	
	public function new(planet) {
		super(planet);
		
		waterId = Type.enumIndex(Data.getBiome(planet.biome).water);
		
		var sign = haxe.Md5.encode(Type.enumIndex(planet.biome)+":"+planet.seed+":"+planet.size);
		var useDiff = save == null ? false : save.data._levelSign == sign;
		if( save != null )
			save.setProperty("_levelSign", sign);
		for( x in 0...planet.size ) {
			for( y in 0...planet.size ) {
				var diff : flash.utils.ByteArray = null;
				var prop = "diff_" + x + "_" + y;
				if( useDiff )
					diff = Reflect.field(save.data, prop);
				else if( save != null )
					save.setProperty(prop, null);
				if( diff != null )
					chunks[x][y].diff = diff;
			}
		}
		flush();
	}
	
	override function preventSave() {
		return false;
	}

	override function processBlock(x, y, z, bid, old) {
		super.processBlock(x, y, z, bid, old);
		if( bid == waterId ) {
			planet.waterFlood++;
			if( !floodFlag && planet.waterFlood >= planet.waterTotal / planet.waterLevel ) {
				floodFlag = true;
				haxe.Timer.delay(reduceWater, 1);
			}
		}
	}
	
	function reduceWater() {
		var w = 0;
		var twater = Type.enumIndex(BWater);
		for( x in 0...planet.size )
			for( y in 0...planet.size ) {
				var t = chunks[x][y].t;
				flash.Memory.select(t.getData());
				var z = planet.waterLevel;
				for( x in 0...Const.SIZE )
					for( y in 0...Const.SIZE ) {
						var addr = Const.addr(x, y, z) << 1;
						if( flash.Memory.getUI16(addr) == twater )
							w++;
					}
			}
		planet.waterLevel--;
		planet.waterFlood -= w;
//		trace("REDUCE " + planet.waterLevel+ "("+w+")");
		floodFlag = false;
		onCommand(SReduceWater);
	}
	
	override function setBlock(x, y, z, bid) {
		super.setBlock(x, y, z, bid);
		if( !saving ) {
			saving = true;
			haxe.Timer.delay(doSaveChunks, 1);
		}
	}
	
	function doSaveChunks() {
		saving = false;
		for( x in 0...planet.size )
			for( y in 0...planet.size ) {
				var c = chunks[x][y];
				if( !c.dirty ) continue;
				c.dirty = false;
				save.setProperty("diff_" + x + "_" + y, c.diff);
			}
		flush();
	}
	
	override function clearLocalChanges() {
		for( x in 0...planet.size )
			for( y in 0...planet.size ) {
				var c = chunks[x][y];
				if( c.diff.length == 0 ) continue;
				c.diff = new flash.utils.ByteArray();
				c.dirty = true;
				requestChunk(x, y);
			}
		doSaveChunks();
	}
	
	public override function send( act : ClientAction, ?onResult : Dynamic -> Void ) {
		switch( act ) {
		case CTalk( msg ):
			haxe.Timer.delay( function() onData( STalk( 0, msg) ), 100);
		case CGetProperties(x, y, z):
			haxe.Timer.delay(function() {
				var p : BlockProperties = {
					id : -1,
					max : 64,
					content : [ { k : Block.get(BLamp).index, n : 60 }, null, null, null],
				};
				onData( SResult(p) );
			},1000);
		default:
		}
		super.send( act, onResult);
	}
}
