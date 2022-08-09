package net;
import Common;
import Protocol;

class Offline extends Api {

	var chunks : Array<Array<{ t : haxe.io.Bytes, diff : flash.utils.ByteArray, dirty : Bool }>>;
	var gt : flash.utils.ByteArray;
	var gen : gen.Generator;
	var genDone : Bool;
	
	public function new(planet) {
		super(null, planet);
		if( preventSave() )
			save = null;
		chunks = [];
		for( x in 0...planet.size ) {
			chunks[x] = [];
			for( y in 0...planet.size )
				chunks[x][y] = { t : null, diff : new flash.utils.ByteArray(), dirty : false };
		}
		gen = new gen.DetailsGenerator(planet.size << Const.BITS, planet.seed);
		var bd = Data.getBiome(planet.biome);
		gen.alloc(bd.water);
		gen.alloc(BMinIron);
		gen.alloc(BMinAluminium);
		for( s in bd.soils )
			gen.alloc(s);
		gen.startGenerate(planet.biome);
		planet.waterLevel = gen.getWaterInfos().level;
		process();
	}

	public dynamic function onGenError( code : Int ) {
	}
	
	function process() {
		var flag;
		if( flash.system.Capabilities.isDebugger )
			flag = gen.process();
		else try {
			flag = gen.process();
		} catch( e : Dynamic ) {
			var err = flash.Lib.as(e, flash.errors.Error);
			gen = null;
			onGenError(err == null ? 0 : err.errorID);
			return;
		}
		
		if( !flag ) {
			gt = gen.getBytes();
			gt.length += Const.SIZE * Const.SIZE * Const.ZSIZE * 2;
			gt.position = gt.length;
			gt.endian = flash.utils.Endian.LITTLE_ENDIAN;
			for( i in 0...256 ) {
				var b = gen.blocks[i];
				gt.writeShort(b == null ? 0 : b.index);
			}
			planet.waterTotal = gen.getWaterInfos().total;
//			trace("TOTAL = " + planet.waterTotal);
			return;
		}
		haxe.Timer.delay(process, 1);
	}
	
	
	override function requestChunk(x,y) {
		var c = chunks[x][y];
		if( c.t == null ) {
			haxe.Timer.delay(callback(makeChunk, x, y), 1);
			return;
		}
		haxe.Timer.delay(callback(onCommand, SChunk(x, y, c.t.sub(0,c.t.length), false, c.diff == null ? null : haxe.io.Bytes.ofData(c.diff))), 100);
	}

	override function putBlock(x, y, z, bid, index) {
		setBlock(x, y, z, bid);
	}

	override function breakBlock(x, y, z, bid, process) {
		setBlock(x, y, z, 0);
	}
	
	override function processBlock(x, y, z, bid, old) {
		setBlock(x, y, z, bid);
	}
	
	function setBlock(x, y, z, bid) {
		var cx = x >> Const.BITS;
		var cy = y >> Const.BITS;
		var c = chunks[cx][cy];
		c.diff.position = c.diff.length;
		c.diff.writeByte(x&Const.MASK);
		c.diff.writeByte(y&Const.MASK);
		c.diff.writeByte(z);
		c.diff.writeByte(bid & 0xFF);
		c.diff.writeByte(bid >> 8);
		c.dirty = true;
	}
	
	function makeChunk(gx, gy) {
		if( gt == null ) {
			haxe.Timer.delay(callback(makeChunk, gx, gy), 100);
			return;
		}
		var t = new flash.utils.ByteArray();
		flash.Memory.select(gt);
		var chunkSize = Const.SIZE * Const.SIZE * Const.ZSIZE;
		var totalSize = planet.size * planet.size * chunkSize;
		var blockPos = totalSize + chunkSize * 2;
		flash.Memory.select(gt);
				
		var write = totalSize;
		var read = (gx + gy * planet.size * Const.SIZE) * Const.SIZE * Const.ZSIZE;
		var jump = (planet.size - 1) * Const.SIZE * Const.ZSIZE;
		for( y in 0...Const.SIZE ) {
			for( i in 0...Const.SIZE*Const.ZSIZE ) {
				flash.Memory.setI16(write, flash.Memory.getUI16(blockPos + (flash.Memory.getByte(read++) << 1)));
				write += 2;
			}
			read += jump;
		}
		t.writeBytes(gt, totalSize, chunkSize * 2);
		chunks[gx][gy].t = haxe.io.Bytes.ofData(t);
		requestChunk(gx, gy);
	}

	
	function preventSave() {
		return true;
	}
	
}