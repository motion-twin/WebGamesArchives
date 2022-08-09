import Common;

class Watch implements haxe.Public {
	var x : Int;
	var y : Int;
	var level : Level;
	var proto : tora.Protocol;
	var data : haxe.io.Bytes;
	var topMap : haxe.io.Bytes;
	var topHeight : haxe.io.Bytes;
	var updated : Bool;

	public var waitAnswers : Int;
	public var waitClose : Bool;

	function new(l,x,y) {
		waitAnswers = 0;
		this.level = l;
		this.x = x;
		this.y = y;
	}

	function update(x,y,z,k) {
		var invisible = Type.enumIndex(BInvisible) + 1;
		data.set(level.addr(x,y,z),k);
		// update minimap
		z = (1 << GameConst.ZBITS) - 1;
		var addr = level.addr(x,y,z);
		while( true ) {
			k = data.get(addr);
			if( k != 0 && k != invisible )
				break;
			addr -= 1 << Level.Z;
			z--;
		}
		var pos = (y << GameConst.XYBITS) | x;
		if( topMap.get(pos) != k || topHeight.get(pos) != z ) {
			topMap.set(pos,k);
			topHeight.set(pos,z);
			return true;
		}
		return false;
	}

	function initMap() {
		var pos = 0;
		var invisible = Type.enumIndex(BInvisible) + 1;
		topMap = haxe.io.Bytes.alloc(1<<(GameConst.XYBITS*2));
		topHeight = haxe.io.Bytes.alloc(topMap.length);
		for( y in 0...Level.XYSIZE )
			for( x in 0...Level.XYSIZE ) {
				var k = 0, z = (1 << GameConst.ZBITS) - 1;
				var addr = level.addr(x,y,z);
				while( true ) {
					k = data.get(addr);
					if( k != 0 && k != invisible )
						break;
					addr -= 1 << Level.Z;
					z--;
				}
				topMap.set(pos,k);
				topHeight.set(pos,z);
				pos++;
			}
	}

	inline function getColorIndex( px : Int, py : Int ) {
		px -= x << GameConst.XYBITS;
		py -= y << GameConst.XYBITS;
		var a = (py << GameConst.XYBITS) | px;
		return (topMap.get(a)<<Interface.CBITS) | (topHeight.get(a) >> (GameConst.ZBITS-Interface.CBITS));
	}

	public function getBlock( ax : Int, ay : Int, az : Int ) {
		var b = level.blocks[data.get(level.addr(ax - (x<<GameConst.XYBITS),ay - (y<<GameConst.XYBITS),az))];
		return (b == null) ? null : b.k;
	}

}
