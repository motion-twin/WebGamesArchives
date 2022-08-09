package net;
import flash.net.NetStream;

typedef Init = {
	var id : String;
	var uid : Int;
	var name : String;
	var camera : Bool;
}

typedef State = {
	var x : Float;
	var y : Float;
	var z : Float;
	var a : Float;
	var g : Float;
	var az : Float;
	var select : Null<r3d.AbstractGame.GameEffectsSelect>;
}

class Entity {
	public var init : Init;
	public var state : State;
	public function new(i, s) {
		this.init = i;
		this.state = s;
	}
	public function sync( s : State ) {
		state = s;
	}
}

class MyNetStream<T> extends NetStream {
	public var targetID : String;
	public var connected : Bool;
	public var ent : T;
	public function new(cnx, id) {
		super(cnx, id);
		targetID = id;
	}
}

class RealTime<Ent:Entity> {

	var channel : Int;
	var net : flash.net.NetConnection;
	var stream : NetStream;
	var outCnx : Array<MyNetStream<Ent>>;
	var inCnx : Array<NetStream>;
	var makeEntity : Init -> State -> Ent;
	
	public var ent : Ent;
	public var entities : Array<Ent>;
	
	public function new( url : String, channel : Int, me : Ent, make ) {
		this.channel = channel;
		outCnx = [];
		inCnx = [];
		entities = [];
		makeEntity = make;
		this.ent = me;
		log("Connecting on "+url+"...");
		var t = new haxe.Timer(5000);
		t.run = function() {
			t.stop();
			if( stream == null ) {
				log("Timeout");
				onDisconnect();
			}
		};
		net = new flash.net.NetConnection();
		net.addEventListener(flash.events.NetStatusEvent.NET_STATUS, onStatus);
		net.connect(url);
		net.client = {
			onNewUser : function(id:String) {
				peerConnect(id);
			}
		};
	}
	
	public function isConnected() {
		return stream != null;
	}
	
	function onDisconnect() {
		flash.external.ExternalInterface.call("eval", "$('#offline_udp').css({display:''}); null");
	}
	
	public function sync( s : State ) {
		ent.state = s;
		if( stream != null ) {
			var b = new haxe.io.BytesOutput();
			b.writeFloat(s.x);
			b.writeFloat(s.y);
			b.writeFloat(s.z);
			b.writeFloat(s.g);
			b.writeFloat(s.a);
			b.writeFloat(s.az);
			
			if (s.select != null)
			{
				b.writeInt8( 66 );
				b.writeFloat( s.select.x );
				b.writeFloat( s.select.y  );
				b.writeFloat( s.select.z  );
				if ( s.select.laser != null)
				{
					b.writeInt8(67);
					b.writeInt8(s.select.laser);
				}
				else
					b.writeInt8(0);
					
				b.writeInt16( s.select.bx );
				b.writeInt16( s.select.by );
				b.writeInt16( s.select.bz );
				b.writeInt16( s.select.btype );
			}
			else 
				b.writeInt8(0);
				
			
			
			stream.send("_s", b.getBytes().getData());//remotely call _s on data
		}
	}
	
	function decodeState( b : flash.utils.ByteArray ) : State {
		var b = new haxe.io.BytesInput(haxe.io.Bytes.ofData(b));
		return {
			x : b.readFloat(),
			y : b.readFloat(),
			z : b.readFloat(),
			g : b.readFloat(),
			a : b.readFloat(),
			az : b.readFloat(),
			select : 
			{
				if ( b.readInt8() == 66)
				{
					{ 
						x:b.readFloat(), 
						y:b.readFloat(), 
						z:b.readFloat(),
						laser: (b.readInt8() == 67) ? b.readInt8() :null,
						
						bx:b.readInt16(),
						by:b.readInt16(),
						bz:b.readInt16(),
						btype:b.readInt16(),
					}
				}
				else null;
			},
		};
	}
	
	function log( v : Dynamic, ?pos : #if debug haxe.PosInfos #else Dynamic #end ) {
		Log.add(v, pos);
	}
	
	function addEntity( e : Ent ) {
		entities.push(e);
	}
	
	function removeEntity( e : Ent ) {
		entities.remove(e);
	}
	
	function peerConnect( id : String, retry = 0 ) {
		
		if( net == null )
			return false;
		
		for( c in outCnx )
			if( c.targetID == id )
				return false;
	
		var cnx = new MyNetStream(net, id);
		var connected = false;
		cnx.addEventListener(flash.events.NetStatusEvent.NET_STATUS, function(e:flash.events.NetStatusEvent) {
			if( Reflect.field(e.info,"code") == "NetStream.Play.Start" )
				cnx.connected = true;
		});
		var init = null;
		cnx.client = {
			_h : function(i:Init) {
				init = i;
				log("#" + init.uid + " has joined");
			},
			_s : function(s:flash.utils.ByteArray) {
				var s = decodeState(s);
				if( cnx.ent == null && init != null ) {
					cnx.ent = makeEntity(init,s);
					addEntity(cnx.ent);
				}
				if( cnx.ent != null ) {
					//log("sync #" + init.uid);
					cnx.ent.sync(s);
				}
			},
		};
		outCnx.push(cnx);
		cnx.play("cnx");
		
		haxe.Timer.delay(function() {
			if( cnx.connected )
				return;
			if( retry >= 10 ) {
				log("Failed to connect to peer");
				return;
			}
			cnx.close();
			outCnx.remove(cnx);
			peerConnect(id, retry+1);
		},1000 + retry * 100);
		
		return true;
	}
	
	function onStatus( e : flash.events.NetStatusEvent ) {
		var ns : NetStream = Reflect.field(e.info,"stream");
		var code = Reflect.field(e.info, "code");
		
		switch( code ) {
		case "NetConnection.Connect.Success":
			log("Connected");
			
			ent.init.id = net.nearID;
			
			stream = new NetStream(net, NetStream.DIRECT_CONNECTIONS);
			var client = { };
			Reflect.setField(client,"onPeerConnect",function(ns:NetStream) {
				inCnx.push(ns);
				log("Waiting for player...");
				// needs delay ?
				haxe.Timer.delay(function() ns.send("_h", ent.init), 1);
				// make sure to connect on it as well
				peerConnect(ns.farID);
				return true;
			});
			stream.client = client;
			stream.publish("cnx");
			
			net.call("ready", new flash.net.Responder(function(ids:Array<String>) {
				for( cid in ids )
					peerConnect(cid);
			}), channel);
			
		case "NetConnection.Connect.Closed":
			log("Disconnected");
			onDisconnect();
			net = null;
			
		case "NetStream.Connect.Success":
			
		case "NetStream.Connect.Closed":
			if( inCnx.remove(ns) ) {
				ns.close();
			} else {
				for( o in outCnx.copy() )
					if( o.farID == ns.farID ) {
						o.close();
						outCnx.remove(o);
						if( o.ent != null ) {
							log("#"+o.ent.init.uid + " has left");
							removeEntity(o.ent);
						}
					}
			}
		default:
			log(e.info);
		}
	}
		
}