
class Manager {
	public var bytes : flash.utils.ByteArray;
	public function new() {
		bytes = new flash.utils.ByteArray();
	}
	public function alloc( size : Int ) : VirtualBuffer {
		var pos = bytes.length;
		bytes.length += size;
		return cast pos;
	}
	public function add( b : flash.utils.ByteArray ) : VirtualBuffer {
		var pos = bytes.length;
		bytes.writeBytes(b);
		trace(b.length);
		trace(bytes.length);
		return cast pos;
	}
	public function copy( b : flash.utils.ByteArray, pos : Int, to : VirtualBuffer, len : Int ) {
		bytes.position = to.getPos();
		bytes.writeBytes(b, pos, len);
	}
	public function select() {
		if( bytes.length < 1024 ) bytes.length = 1024;
		flash.Memory.select(bytes);
	}
}

@:native("Int") extern class VirtualBuffer {
	public inline function getPos() : Int {
		return cast this;
	}
	public inline function getByte( p : Int ) : Int {
		return flash.Memory.getByte(p + getPos());
	}
	public inline function getInt( p : Int ) : Int {
		return flash.Memory.getI32((p << 2) + getPos());
	}
	public inline function getFloat( p : Int ) : Float {
		return flash.Memory.getFloat((p << 2) + getPos());
	}
	public inline function getDouble( p : Int ) : Float {
		return flash.Memory.getDouble((p << 3) + getPos());
	}
	public inline function setByte( p : Int, v : Int ) : Void {
		flash.Memory.setByte(p + getPos(), v);
	}
	public inline function setInt( p : Int, v : Int ) : Void {
		flash.Memory.setI32((p << 2) + getPos(), v);
	}
	public inline function setFloat( p : Int, v : Float ) : Void {
		flash.Memory.setFloat((p << 2) + getPos(), v);
	}
	public inline function setDouble( p : Int, v : Float ) : Void {
		flash.Memory.setDouble((p << 3) + getPos(), v);
	}
}