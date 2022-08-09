package net;

import Common;
import Protocol;

class EditShip extends Api {
	
	var inf : EditShipInfos;
	var level : haxe.io.Bytes;
	
	public function new(url,inf) {
		super(url,{ waterTotal : 0, waterLevel : 0, waterFlood : 0, size : 1, seed : 0, id : null, biome : BIShed });
		this.inf = inf;
		initLevel();
		if( isOffline() ) {
			flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, function(e:flash.events.KeyboardEvent) {
				if( e.keyCode == flash.ui.Keyboard.F1 )
					loadShip(flash.external.ExternalInterface.call("eval","document.getElementById('log').value"));
			});
		}
	}
	
	function initLevel() {
		var ground = Type.enumIndex(BShedGround);
		var wall = Type.enumIndex(BShedWall);
		var wallCol = Type.enumIndex(BShedWallColumn);
		var wallLight = Type.enumIndex(BShedWallLight);
		var light = Type.enumIndex(BShedLight);
		var arrow = Type.enumIndex(BShedGroundArrow);
		var glass = Type.enumIndex(BShedGlass);
		level = haxe.io.Bytes.alloc(Const.TSIZE * 2);
		for( x in 0...Const.SIZE )
			for( y in 0...Const.SIZE )
				set(x, y, 0, if(y%3==0) arrow else glass);
		// inner size
		var size = { x : inf.size.x + 4, y : inf.size.y + 4, z : inf.size.z + 2 };
		for( x in 0...size.x )
			for( y in 0...size.y ) {
				if( x == 1 || y == 1 || x == size.x - 2 || y == size.y - 2 ) {
					set(x, y, 0, wall);
					set(x, y, size.z-1, wall);
				}
				else
					if( x % 4 == 2 && y % 4 == 2 )
						set(x, y, size.z - 1, light);
					else
						set(x, y, size.z - 1, glass);
			}
		var hmin = size.y >> 1;
		var hmax = ((size.y - 1) >> 1) + 1;
		if( hmin == hmax ) {
			hmin--;
			hmax++;
		}
		for( z in 0...size.z ) {
			for( x in 0...size.x ) {
				var b = if(z==3 && x%3==0) wallLight else wall;
				set(x, 0, z, b);
				set(x, size.y - 1, z, b);
			}
			for( y in 0...size.y ) {
				var b = if( y % 3 == 0 ) wallCol else wall;
				set(size.x - 1, y, z, b);
				var x = (y < hmin || y > hmax) ? 0 : Const.SIZE - 2;
				set(x, y, z, b);
			}
			set(Const.SIZE-1, hmin - 1, z, wall);
			set(Const.SIZE-1, hmax + 1, z, wall);
		}
		
		var exit = Type.enumIndex(BShipEntry);
		for( x in 0...2 )
			for( y in hmin...hmax + 1 ) {
				set((Const.SIZE - x) & Const.MASK, y, 0, exit);
				set((Const.SIZE - x) & Const.MASK, y, size.z-1, glass);
			}
			
		
		var s = inf.ship;
		if( s == null ) return;
		if( s.get(0) == 0x78 ) {
			var data = new flash.utils.ByteArray();
			data.writeBytes(s.getData());
			data.uncompress();
			s = haxe.io.Bytes.ofData(data);
		}
		var sx = s.get(0), sy = s.get(1), sz = s.get(2);
		if( sx * sy * sz * 2 + 3 != s.length )
			throw "Invalid size";
		if( sx > inf.size.x || sy > inf.size.y || sz > inf.size.z )
			throw "Shed size reduced";
		var dx = 2 + ((inf.size.x - sx) >> 1);
		var dy = 2 + ((inf.size.y - sy) >> 1);
		var stride = sz * 2;
		var dz = 1;
		var pos = 3;
		for( y in 0...sy )
			for( x in 0...sx ) {
				level.blit(Const.addr(dx + x, dy + y, dz) << 1, s, pos, stride);
				pos += stride;
			}
	}
	
	function loadShip( data : String ) {
		var bytes : haxe.io.Bytes = haxe.Unserializer.run(data);
		var data = bytes.getData();
		data.uncompress();
		var sx = data[0], sy = data[1], sz = data[2];
		if( sx*sy*sz*2 + 3 != Std.int(data.length) )
			throw "Invalid size";
		inf.ship = haxe.io.Bytes.ofData(data);
		initLevel();
		requestChunk(0, 0);
	}
	
	function set(x, y, z, b) {
		var p = Const.addr(x, y, z) << 1;
		level.set(p, b & 0xFF);
		level.set(p+1, b >> 8);
	}
	
	override public function requestChunk(x:Int, y:Int)	{
		haxe.Timer.delay(function() onCommand(SChunk(x, y, level, false, haxe.io.Bytes.alloc(0))), 100);
	}

	override function getPosition( last : UserPos ) : UserPos {
		return { x : -0.5, y : inf.size.y * 0.5 + 2.5, z : 1., a : 0., az : 0., flags : haxe.EnumFlags.ofInt(0), life : 100., mouseCtrl : last == null ? false : last.mouseCtrl };
	}
	
	override function savePosition( pos : UserPos) : Bool {
		return true;
	}
	
	override function putBlock( x : Int, y : Int, z : Int, bid : Int, iindex : Int ) {
		saveShip();
		onSetBlock(x, y, z, bid);
	}

	override function breakBlock( x : Int, y : Int, z : Int, bid : Int, process : Bool ) {
		saveShip();
		onSetBlock(x, y, z, 0);
	}
	
	override function processBlock( x : Int, y : Int, z : Int, bid : Int, old : Int ) {
		saveShip();
		onSetBlock(x, y, z, bid);
	}
	
	function getShipData() {
		var size = inf.size;
		var stride = size.z * 2;
		var data = haxe.io.Bytes.alloc(stride * size.y * size.x + 3);
		data.set(0, size.x);
		data.set(1, size.y);
		data.set(2, size.z);
		var pos = 3;
		for( y in 0...size.y )
			for( x in 0...size.x ) {
				data.blit(pos, level, Const.addr(2 + x, 2 + y, 1) << 1, stride);
				pos += stride;
			}
		var bytes = data.getData();
		bytes.compress();
		return haxe.io.Bytes.ofData(bytes);
	}
	
	function setCoord(x:Float,y:Float) {
		flash.external.ExternalInterface.call("eval","document.getElementById('coord').value = '"+x+","+y+"'");
	}
	
	function saveShip() {
		if( !isOffline() )
			return;
		flash.external.ExternalInterface.call("eval","document.getElementById('log').value = '"+haxe.Serializer.run(getShipData())+"'");
	}
	
	override function send( a : ClientAction, ?onResult : Dynamic -> Void ) {
		switch( a ) {
		case CSaveShip(_, inv):
			a = CSaveShip(getShipData(), inv);
		case CDrop(_):
			haxe.Timer.delay(callback(onResult,0),10);
			return;
		case CPickLoot(id, _), CSetLootPos(id, _, _, _):
			if( id == 0 )
				return;
		default:
		}
		super.send(a, onResult);
	}
	
}

