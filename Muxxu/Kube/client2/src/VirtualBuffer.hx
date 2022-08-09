#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else

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
	public function allocFirst( size : Int ) : VirtualBuffer0 {
		if( bytes.length != 0 ) throw "assert";
		bytes.length += size;
		return cast 0;
	}
	public function add( b : flash.utils.ByteArray ) : VirtualBuffer {
		var pos = bytes.length;
		bytes.writeBytes(b);
		return cast pos;
	}
	public function copy( b : flash.utils.ByteArray, pos : Int, to : AbstractBuffer, len : Int ) {
		bytes.position = to.getPos();
		bytes.writeBytes(b, pos, len);
	}
	public function select() {
		if( bytes.length < 1024 ) bytes.length = 1024;
		flash.Memory.select(bytes);
	}
}

@:native("Int") extern class AbstractBuffer {
	public inline function getPos() : Int {
		return cast this;
	}
}

@:native("Int") extern class VirtualBuffer0 extends AbstractBuffer {

	public inline function getByte( p : Int ) : Int {
		return flash.Memory.getByte(p);
	}
	public inline function getUI16( p : Int ) : Int {
		return flash.Memory.getUI16(p << 1);
	}
	public inline function getInt( p : Int ) : Int {
		return flash.Memory.getI32(p << 2);
	}
	public inline function getFloat( p : Int ) : Float {
		return flash.Memory.getFloat(p << 2);
	}
	public inline function getDouble( p : Int ) : Float {
		return flash.Memory.getDouble(p << 3);
	}
	public inline function setByte( p : Int, v : Int ) : Void {
		flash.Memory.setByte(p, v);
	}
	public inline function setUI16( p : Int, v : Int ) : Void {
		flash.Memory.setByte(p<<1, v);
	}
	public inline function setInt( p : Int, v : Int ) : Void {
		flash.Memory.setI32(p << 2, v);
	}
	public inline function setFloat( p : Int, v : Float ) : Void {
		flash.Memory.setFloat(p << 2, v);
	}
	public inline function setDouble( p : Int, v : Float ) : Void {
		flash.Memory.setDouble(p << 3, v);
	}
}

@:native("Int") extern class VirtualBuffer extends AbstractBuffer {

	public inline function getByte( p : Int ) : Int {
		return flash.Memory.getByte(p + getPos());
	}
	public inline function getUI16( p : Int ) : Int {
		return flash.Memory.getUI16((p << 1) + getPos());
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
	public inline function setUI16( p : Int, v : Int ) : Void {
		flash.Memory.setI16((p << 1) + getPos(), v);
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

@:autoBuild(Macro.build()) extern class MemoryObject extends AbstractBuffer {
}

@:autoBuild(Macro.buildBuffer()) extern class ObjectBuffer<T> extends AbstractBuffer {
}

#end

class Macro {
	#if macro
	
	public static function buildBuffer() {
		var fields = Context.getBuildFields();
		var c = switch( Context.getLocalType() ) {
		case TInst(c, _): c.get();
		default: throw "assert";
		}
		var pt = c.superClass.params[0];
		var ct = switch( Context.follow(pt) ) {
		case TInst(c, _): c.get();
		default: Context.error("Unsuported type parameter", c.pos);
		}
		var size = null;
		for( m in ct.meta.get() )
			if( m.name == ":size" && m.params.length == 1 ) {
				switch( m.params[0].expr ) {
				case EConst(c):
					switch(c) {
					case CInt(i): size = Std.parseInt(i);
					default:
					}
				default:
				}
			}
		if( size == null )
			Context.error("Type parameter is not a MemoryObject", c.pos);
			
		c.meta.add(":native", [ { expr : EConst(CString("Int")), pos : c.pos } ], c.pos);
		c.exclude();
		
		var tint = TPath( { name : "Int", pack : [], params : [], sub : null } );
		var tmanager = TPath( { name : "VirtualBuffer", pack : [], params : [], sub : "Manager" } );
		
		fields.push({
			name : "get",
			doc : null,
			access : [APublic,AInline],
			pos : c.pos,
			meta : [],
			kind : FFun( {
				args : [{ name : "i", opt : false, type : tint, value : null }],
				ret : TPath( { name : ct.name, params : [], pack : ct.pack, sub : null } ),
				params : [],
				expr : Context.parse("return cast getPos() + i * "+size, c.pos),
			}),
		});
		
		fields.push( {
			name : "alloc",
			doc : null,
			access : [APublic, AStatic, AInline],
			pos : c.pos,
			meta : [],
			kind : FFun( {
				args : [ { name : "manager", opt : false, type : tmanager, value : null }, { name : "count", opt : false, type : tint, value : null } ],
				ret : TPath( { name : c.name, params : [], pack : c.pack, sub : null } ),
				params : [],
				expr : Context.parse("return cast manager.alloc(count * "+size+")",c.pos),
			}),
		});
		
		return fields;
	}
	
	public static function build() {
		var fields = Context.getBuildFields();
		var c = switch( Context.getLocalType() ) {
		case TInst(c, _): c.get();
		default: throw "assert";
		}
		
		var pos = 0;
		for( f in fields ) {
			if( Lambda.has(f.access,AStatic) )
				Context.error("Statics are not supported", f.pos);
			switch( f.kind ) {
			case FProp(_):
				Context.error("Not supported", f.pos);
			case FFun(_):
				if( !Lambda.has(f.access,AInline) )
					Context.error("Only inline method are supported", f.pos);
			case FVar(t, e):
				var tname = switch( t ) {
				case TPath(p):
					switch( p.name ) {
					case "Float": "Float";
					case "Int": "I32";
					default: null;
					}
				default: null;
				}
				if( tname == null ) {
					Context.error("Not supported", f.pos);
					continue;
				}
				f.kind = FProp("get_" + f.name, "set_" + f.name, t, e);
				fields.push({
					name : "get_" + f.name,
					doc : null,
					access : [AInline,APrivate],
					pos : f.pos,
					meta : [],
					kind : FFun( {
						args : [],
						ret : t,
						params : [],
						expr : Context.parse("return flash.Memory.get"+tname+"(getPos()+"+pos+")", f.pos),
					}),
				});
				fields.push({
					name : "set_" + f.name,
					doc : null,
					access : [AInline,APrivate],
					pos : f.pos,
					meta : [],
					kind : FFun( {
						args : [ { name : "v", opt : false, type : t, value : null } ],
						ret : t,
						params : [],
						expr : Context.parse("{ flash.Memory.set"+tname+"(getPos()+"+pos+",v); return v; }", f.pos),
					}),
				});
				pos += 4;
			default:
			}
		}
		
		var esize = { expr : EConst(CInt(Std.string(pos))), pos : c.pos };
		fields.push({
			name : "SIZE",
			doc : null,
			access : [APublic, AStatic, AInline],
			pos : c.pos,
			meta : [],
			kind : FVar(null,esize),
		});
		
		c.meta.add(":native", [ { expr : EConst(CString("Int")), pos : c.pos } ], c.pos);
		c.meta.add(":size", [esize], c.pos);
		c.exclude();
		
		return fields;
	}
	#end
}
