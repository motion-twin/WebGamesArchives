package net;

import Common;
import Protocol;

class Server extends Api {

	var ssend : ServerSender;
	var pid : Null<Int>;
	var needSavePos : Bool;
	var lastSavePos : UserPos;
	
	public function new(send, planet) {
		if( send != null ) {
			ssend = new ServerSender(send);
			ssend.onBlockResult = onBlockResult;
		}
		super(ssend, planet);
	}
		
	override function requestChunk(x, y) {
		send(CRequestChunk(pid, x, y));
	}
	
	override public function getPosition(last:UserPos) {
		if( last != null && last.flags.has(CameraMode) )
			pid = planet.id;
		return super.getPosition(last);
	}
	
	override function savePosition(pos:UserPos) {
		var flag = super.savePosition(pos);
		if( !flag )
			return false;
		if( lastSavePos == null )
			lastSavePos = pos;
		if( !needSavePos ) {
			var dx = realDist(lastSavePos.x - pos.x);
			var dy = realDist(lastSavePos.y - pos.y);
			var dz = realDist(lastSavePos.z - pos.z);
			var dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
			if( dist > 10 )
				needSavePos = true;
		}
		if( !needSavePos )
			return false;
		if( sender != null && !sender.hasPending() ) {
			needSavePos = false;
			lastSavePos = pos;
			send(CSavePos(pos,stats));
		}
		return true;
	}
	
	function onBlockResult( result : haxe.io.Bytes, bytes : haxe.io.Bytes ) {
		if( (result.length >> 1) * 8 != bytes.length )
			throw "Block bytes mismatch ("+result.length+";"+bytes.length+")";
		var blocks = new haxe.io.BytesInput(bytes);
		var rids = new haxe.io.BytesInput(result);
		for( i in 0...result.length >> 1 ) {
			var code = blocks.readByte();
			var z = blocks.readByte();
			var x = blocks.readUInt16();
			var y = blocks.readUInt16();
			var bid = blocks.readUInt16();
			var old = rids.readUInt16();
			if( old == 0 )
				continue;
			// undo get
			if( code == 0x01 )
				onCancelInventory(bid, x, false);
			else {
				onSetBlock(x, y, z, old - 1);
				// undo put
				if( code & 192 == 64 )
					onCancelInventory(bid, code & 63, true);
			}
		}
	}
	
	function setBlock( code, x, y, z, bid ) {
		if( ssend != null ) ssend.addBlock(code, x, y, z, bid);
	}
	
	override function isWaiting() {
		return ssend != null && ssend.isWaiting();
	}
	
	override function putBlock(x, y, z, bid, index) {
		setBlock((index & 31) | 64, x, y, z, bid);
	}
	
	override function breakBlock(x, y, z, bid, process) {
		setBlock(process ? 2 : 0, x, y, z, bid);
	}
	
	override function getDummy(bid,index) {
		setBlock(1, index, 0, 0, bid);
	}
	
	override function craftBlock(x, y, z, bid, index) {
		setBlock((index & 31) | 32, x, y, z, bid);
	}
	
	override function processBlock(x, y, z, bid, old) {
		var h = Const.quickHash(x,y,z) ^ Const.quickHash(old,bid, 0);
		setBlock((h%127) | 128, x, y, z, bid);
	}
	
	static var VERSION_KEY = null;
	public static function getVersionKey() {
		if( VERSION_KEY == null ) {
			var bytes = flash.Lib.current.loaderInfo.bytes;
			// some error on chrome plugin with null bytes
			VERSION_KEY = if( bytes == null ) "UNKNOWN" else format.tools.MD5.make(haxe.io.Bytes.ofData(bytes)).toHex();
		}
		return VERSION_KEY;
	}
	
}
