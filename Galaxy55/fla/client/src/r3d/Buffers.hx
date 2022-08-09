package r3d;

class BlockMem extends VirtualBuffer.MemoryObject {
	public var tag : Int;
	public var shadeX : Float;
	public var shadeY : Float;
	public var shadeUp : Float;
	public var shadeDown : Float;
	public var tu : Int;
	public var td : Int;
	public var tlr : Int;
	public var special : Int;
	public var modelPos : Int;
	public var modelSize : Int;
	public var lightIndex : Int;
}

class BlockBuffer extends VirtualBuffer.ObjectBuffer<BlockMem> {
}

class CellBuffer {
	public var level : Builder.BuilderLevel;
	public var x : Int;
	public var y : Int;
	public var z : Int;
	public var frame : Int;
	public var viewX : Int;
	public var viewY : Int;
	public var viewZ : Int;
	public var dirty : Bool;
	public var buffers : Array<h3d.impl.Buffer>;
	public function new(l, x, y) {
		level = l;
		this.x = x;
		this.y = y;
		dirty = true;
		buffers = [];
	}
	public inline function getBuffer( t : Common.BlockType ) {
		return buffers[Type.enumIndex(t)];
	}
	public function dispose() {
		for( b in buffers )
			if( b != null ) b.dispose();
		buffers = [];
		dirty = true;
	}
}
