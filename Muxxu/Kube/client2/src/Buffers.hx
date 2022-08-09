import mt.m3d.T;
import Shaders.DefShader;

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
}

class BlockBuffer extends VirtualBuffer.ObjectBuffer<BlockMem> {
}

class CellBuffer {
	public var x : Int;
	public var y : Int;
	public var z : Int;
	public var frame : Int;
	public var viewX : Int;
	public var viewY : Int;
	public var dirty : Bool;
	public var buffers : Array<BufferCursor>;
	public function new(x, y) {
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

class FreeCell {
	public var pos : Int;
	public var count : Int;
	public var next : FreeCell;
	public function new(pos,count,next) {
		this.pos = pos;
		this.count = count;
		this.next = next;
	}
}

class BufferManager {
	
	public static inline var MAX_SIZE = 65400;
	static inline var MAX_MEMORY = 200 << 20; // MB
	
	var ctx : Context;
	var empty : flash.utils.ByteArray;
	public var bufferCount : Int;
	public var buffers : DrawBuffer;
	public var ibuf : IBuf;
	
	public function new(ctx) {
		this.ctx = ctx;
		buffers = null;
		
		empty = new flash.utils.ByteArray();
		empty.length = MAX_SIZE * DefShader.STRIDE * 4;

		var indices = new flash.Vector<UInt>();
		for( i in 0...MAX_SIZE )
			indices[i] = i;
		ibuf = ctx.createIndexBuffer(MAX_SIZE);
		ibuf.uploadFromVector(indices, 0, MAX_SIZE);
	}
	
	public dynamic function garbage() {
		throw "GC";
	}
	
	public function alloc( bytes : flash.utils.ByteArray, pos, nvect ) {
		var b = buffers, free = null;
		while( b != null ) {
			free = b.free;
			while( free != null ) {
				if( free.count >= nvect )
					break;
				free = free.next;
			}
			if( free != null ) break;
			b = b.next;
		}
		// second try : half size
		if( b == null ) {
			b = buffers;
			while( b != null ) {
				free = b.free;
				while( free != null ) {
					if( free.count >= nvect>>1 )
						break;
					free = free.next;
				}
				if( free != null ) break;
				b = b.next;
			}
		}
		if( b == null ) {
			if( (bufferCount + 1) * MAX_SIZE * DefShader.STRIDE * 4 > MAX_MEMORY ) {
				garbage();
				return alloc(bytes, pos, nvect);
			}
			var v = ctx.createVertexBuffer(MAX_SIZE, DefShader.STRIDE);
			b = new DrawBuffer(v, MAX_SIZE);
			b.next = buffers;
			buffers = b;
			bufferCount++;
			free = b.free;
		}
		var alloc = nvect > free.count ? free.count : nvect;
		var fpos = free.pos;
		free.pos += alloc;
		free.count -= alloc;
		b.v.uploadFromByteArray(bytes, pos, fpos, alloc);
		var b = new BufferCursor(b, fpos, alloc);
		nvect -= alloc;
		if( nvect > 0 )
			b.next = this.alloc(bytes, pos + alloc * DefShader.STRIDE * 4, nvect);
		return b;
	}
	
	public function finalize() {
		var b = buffers;
		while( b != null ) {
			if( !b.written ) {
				b.written = true;
				if( b.free.count > 0 )
					b.v.uploadFromByteArray(empty, 0, b.free.pos, b.free.count);
			}
			b = b.next;
		}
	}
	
	public function dispose() {
		ibuf.dispose();
		ibuf = null;
		var b = buffers;
		while( b != null ) {
			b.v.dispose();
			b = b.next;
		}
		buffers = null;
	}
}

class BufferCursor {
	public var b : DrawBuffer;
	public var pos : Int;
	public var nvect : Int;
	public var next : BufferCursor;
	
	public function new(b, pos, nvect) {
		this.b = b;
		this.pos = pos;
		this.nvect = nvect;
	}
	public function dispose() {
		b.freeCursor(pos, nvect);
		b = null;
		if( next != null ) next.dispose();
	}
}

class DrawBuffer {
	public var written : Bool;
	public var v : VBuf;
	public var free : FreeCell;
	public var next : DrawBuffer;
	public function new(v, size) {
		written = false;
		this.v = v;
		this.free = new FreeCell(0,size,null);
	}
	public function freeCursor( pos, nvect ) {
		var prev : FreeCell = null;
		var f = free;
		var end = pos + nvect;
		while( f != null ) {
			if( f.pos == end ) {
				f.pos -= nvect;
				f.count += nvect;
				if( prev != null && prev.pos + prev.count == f.pos ) {
					prev.count += f.count;
					prev.next = f.next;
				}
				return;
			}
			if( f.pos > end ) {
				var n = new FreeCell(pos, nvect, f);
				if( prev == null ) free = n else prev.next = n;
				return;
			}
			prev = f;
			f = f.next;
		}
		throw "assert";
	}
	
	public function dispose() {
		v.dispose();
		v = null;
	}
}