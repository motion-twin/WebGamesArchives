package net;

import Common;
import Protocol;

class Api {

	var sender : Sender;
	public var planet : PlanetInfos;
	var save : flash.net.SharedObject;
	var lastPos : UserPos;
	var stats : UserStats;
	var waitResults : Array<Dynamic -> Void>;
	
	public function new(send, planet) {
		this.sender = send;
		this.planet = planet;
		waitResults = [];
		if( sender != null ) sender.onData = onData;
		save = flash.net.SharedObject.getLocal("save");
	}
	
	function flush() {
		try save.flush() catch( e : Dynamic ) { };
	}
	
	public function setStats(s) {
		stats = s;
	}
	
	public function isWaiting() {
		return false;
	}
	
	public function isOffline() {
		return sender == null;
	}
	
	public function clearLocalChanges() {
	}
	
	function onData( cmd : ServerAction ) {
		switch( cmd ) {
		case SResult(v):
			var r = waitResults.shift();
			if( r == null ) throw "Unexpected Result Answer";
			r(v);
		case SMult(cmd):
			for( c in cmd )
				onData(c);
		case SConnect(_):
			sender.disableBatching();
			onCommand(cmd);
		default:
			onCommand(cmd);
		}
	}
	
	public dynamic function onCommand( cmd : ServerAction ) {
	}
	
	public dynamic function onSetBlock( x : Int, y : Int, z : Int, b : Int ) {
	}
	
	public dynamic function onCancelInventory( b : Int, index : Int, use : Bool ) {
	}
	
	public function requestChunk( x : Int, y : Int ) {
	}

	// edits
	
	public function putBlock( x : Int, y : Int, z : Int, bid : Int, iindex : Int ) {
	}

	public function breakBlock( x : Int, y : Int, z : Int, bid : Int, process : Bool ) {
	}
	
	public function craftBlock( x : Int, y : Int, z : Int, bid : Int, iindex : Int ) {
	}
	
	public function processBlock( x : Int, y : Int, z : Int, bid : Int, old : Int ) {
	}
	
	public function getDummy( b : Int, index : Int ) {
	}
	
	// ---
	
	function realDist( v : Float ) {
		var size = planet.size << Const.BITS;
		v %= size;
		if( (v<0?-v:v) > size>>1 ) v += (v<0)?size:-size;
		return v;
	}

	function getKey() {
		return "#"+planet.id;
	}
	
	public function getPosition( last : UserPos ) : UserPos {
		if( last == null )
			last = {
				x : Const.SIZE * 0.5 + 0.5,
				y : Const.SIZE * 0.5 + 0.5,
				z : 0.,
				a : 0.,
				az : 0.,
				life : 100.,
				flags : cast 0,
				mouseCtrl : false,
			};
		lastPos = last;
		var ser : String = if( save == null ) null else Reflect.field(save.data, "position");
		if( ser == null || ser.substr(ser.length-32,32) != haxe.Md5.encode(ser.substr(0,ser.length-32)+getKey()) )
			return last;
		var old : UserPos = try haxe.Unserializer.run(ser) catch( e : Dynamic ) null;
		if( old == null )
			return last;
		var arr : Array<Dynamic> = [old.x, old.y, old.z, old.a, old.az, old.flags, old.life];
		for( v in arr )
			if( Math.isNaN(v) )
				return last;
		lastPos = old;
		return old;
	}
	
	public function forcePosSave() {
		lastPos.x = 1000000;
		lastPos.y = 1000000;
		lastPos.z = 1000000;
	}

	public function savePosition( pos : UserPos ) {
		var dx = realDist(pos.x - lastPos.x);
		var dy = realDist(pos.y - lastPos.y);
		var dz = realDist(pos.z - lastPos.z);
		var dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
		if( dist < 1 )
			return false;
		lastPos = pos;
		var ser = haxe.Serializer.run(lastPos);
		ser += haxe.Md5.encode(ser + getKey());
		if( save != null )
			save.setProperty("position",ser);
		return true;
	}
	
	public function send( act : ClientAction, ?onResult : Dynamic -> Void ) {
		if( onResult != null ) waitResults.push(onResult);
		if( sender != null ) sender.send(act);
	}
	
	public function disconnect() {
		if( sender != null )
			sender.disconnect();
	}

}
