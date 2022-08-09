import Common;

class Process {

	var kube : Kube;
	var level : Level;
	var flooding : flash.utils.ByteArray;
	var time : Float;
	
	public function new(k) {
		time = 0;
		this.kube = k;
		this.level = k.level;
		flooding = new flash.utils.ByteArray();
	}
	
	public function update(dt:Float) {
		time += dt;
		if( time < 0.5 ) return false;
		time -= 0.5;
		if( flooding.length == 0 )
			return false;
		var flood = flooding;
		flood.position = 0;
		flooding = new flash.utils.ByteArray();
		for( i in 0...Std.int(flood.length / 6) ) {
			var x : Int = flood.readUnsignedShort();
			var y : Int = flood.readUnsignedShort();
			var z : Int = flood.readUnsignedShort();
			var k = level.get(x, y, z);
			if( k == null ) continue;
			var b = level.getBlock(k);
			if( b.type != BTWater ) continue;
			this.flood(real(x - 1), y, z, b);
			this.flood(real(x + 1), y, z, b);
			this.flood(x, real(y - 1), z, b);
			this.flood(x, real(y + 1), z, b);
			if( z < kube.waterLevel ) this.flood(x, y, z + 1, b);
			if( z > 0 ) this.flood(x, y, z - 1, b);
		}
		return true;
	}
	
	function flood(x, y, z, b) {
		if( !level.has(x, y, z) ) {
			level.set(x, y, z, b);
			kube.r3d.builder.updateKube(x, y, z,b);
			flooding.writeShort(x);
			flooding.writeShort(y);
			flooding.writeShort(z);
		}
	}
	
	function real(p) {
		var v = p + kube.planetSize;
		while( v >= kube.planetSize ) v -= kube.planetSize;
		return v;
	}

	public function set(x, y, z, b) {
		if( b == null ) {
			checkFlood(x - 1, y, z);
			checkFlood(x + 1, y, z);
			checkFlood(x,y - 1, z);
			checkFlood(x,y + 1, z);
			checkFlood(x, y, z + 1);
			checkFlood(x, y, z - 1);
		}
	}
	
	function checkFlood(x, y, z) {
		x = real(x);
		y = real(y);
		if( z >>> Const.ZBITS != 0 ) return;
		var k = level.get(x, y, z);
		if( k != null && level.getBlock(k).type == BTWater ) {
			flooding.writeShort(x);
			flooding.writeShort(y);
			flooding.writeShort(z);
		}
	}
	
}