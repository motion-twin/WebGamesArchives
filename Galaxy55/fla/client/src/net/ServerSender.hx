package net;
import Protocol;

class ServerSender extends Sender {

	var other : Sender;
	var sentBlocks : Array<haxe.io.Bytes>;
	var blocks : haxe.io.BytesOutput;
	var blockTime : Int; // the oldest pending block time
	var blockCount : Int;
	var batching : Bool;
	var batchingTimer : haxe.Timer;
	
	public function new(other) {
		super();
		batching = true;
		sentBlocks = [];
		this.other = other;
		other.onData = onServerData;
		batchingTimer = new haxe.Timer(30);
		batchingTimer.run = checkFlush;
	}
	
	public dynamic function onBlockResult( b : haxe.io.Bytes, sent  : haxe.io.Bytes ) {
	}
	
	override function disableBatching() {
		batching = false;
	}

	public function isWaiting() {
		return blockCount > 30 && sentBlocks.length > 3;
	}
	
	public function addBlock(code,x,y,z,bid) {
		var first = blocks == null;
		if( first ) {
			blocks = new haxe.io.BytesOutput();
			blockTime = flash.Lib.getTimer();
		}
		blocks.writeByte(code);
		blocks.writeByte(z);
		blocks.writeUInt16(x);
		blocks.writeUInt16(y);
		blocks.writeUInt16(bid);
		blockCount++;
	}
	
	function checkFlush() {
		// nothing to flush
		if( blocks == null )
			return;
		// wait for batching timeout
		if( batching && flash.Lib.getTimer() - blockTime < 1000 )
			return;
		// make sure we don't have pending sets (prevent flooding the server)
		if( sentBlocks.length > 1 )
			return;
		// flush
		flushBlocks();
	}
	
	function flushBlocks() {
		if( blocks == null )
			return;
		var bytes = blocks.getBytes();
		blocks = null;
		send(CSet(bytes));
	}
	
	override function send(act) {
		switch( act ) {
		case CSet(bytes):
			sentBlocks.push(bytes);
		case CSavePos(_):
			// no need to flush blocks in these cases
		default:
			flushBlocks();
		}
		other.send(act);
	}
	
	function onServerData( c : ServerAction ) {
		switch( c ) {
		case SSetResult(bytes):
			var sent = sentBlocks.shift();
			if( sent == null ) throw "Unexpected block results";
			blockCount -= Std.int(sent.length / 8);
			flushBlocks();
			onBlockResult(bytes, sent);
		case SMult(m):
			for( c in m )
				onServerData(c);
		default:
			onData(c);
		}
	}
	
}