package mt.flash;
import format.swf.Data;
import format.abc.Data;
import format.as1.Data;

class F8Emu {

	var exports : IntHash<String>;
	var scripts : IntHash<Array<Array<Action>>>;
	var topTags : Array<SWFTag>;
	var stack : Array<PushItem>;
	var hregs : Hash<Int>;
	var regs : Array<String>;
	
	public function new() {
		exports = new IntHash();
		topTags = new Array();
		scripts = new IntHash();
	}
	
	function timer(name) {
		/*
		var t0 = flash.Lib.getTimer();
		return function() {
			trace(name + " " + (flash.Lib.getTimer() - t0));
		};
		*/
		return function() { };
	}
	
	function mapTags( stags : Array<SWFTag>, clipId : Null<Int> ) {
		var tags = new Array();
		var frame = 1;
		var actions = null;
		for( t in stags ) {
			switch( t ) {
			case TSandBox(_):
				// ignore
			case TClip(id, frames, ctags):
				tags.push(TClip(id, frames, mapTags(ctags,id)));
			case TDoActions(bytes):
				if( clipId == null )
					continue;
				var ops = new format.as1.Reader(new haxe.io.BytesInput(bytes)).read();
				if( actions == null )
					actions = new Array();
				if( actions[frame] != null )
					throw "assert";
				actions[frame] = ops;
			case TExport(el):
				for( e in el )
					exports.set(e.cid, e.name);
			case TPlaceObject2(_), TPlaceObject3(_), TRemoveObject2(_):
				if( clipId != null )
					tags.push(t);
				else
					topTags.push(t);
			case TShowFrame:
				if( clipId != null ) {
					tags.push(t);
					frame++;
				} else
					topTags.push(t);
			default:
				tags.push(t);
			}
		}
		if( actions != null ) {
			scripts.set(clipId, actions);
			exports.set(clipId, "__c" + clipId);
		}
		return tags;
	}
	
	function makeValue(ctx:format.abc.Context, v, onStack) {
		if( v == null ) {
			if( !onStack ) throw "value on stack";
			return; // already on stack
		}
		ctx.op(switch(v) {
		case PBool(v): v?OTrue:OFalse;
		case PInt(i): OInt(haxe.Int32.toInt(i));
		case PString(s): OString(ctx.string(s));
		case PNull: ONull;
		case PUndefined: OUndefined;
		case PFloat(f): OFloat(ctx.float(f));
		case PDouble(f): OFloat(ctx.float(f));
		case PReg(r): throw "assert";
		case PStack(_), PStack2(_): throw "assert";
		});
	}
	
	function makeOp( ctx : format.abc.Context, op ) {
		var a = stack.pop();
		var b = stack.pop();
		makeValue(ctx, a, true);
		makeValue(ctx, b, true);
		if( a != null && b == null )
			ctx.op(OSwap);
		ctx.op(OOp(op));
		stack.push(null);
	}
	
	function allocReg( name ) {
		var index = hregs.get(name);
		if( index == null ) {
			index = regs.length + 1;
			regs.push(name);
			hregs.set(name, index);
		}
		return index;
	}
	
	function emulateAS1( ctx : format.abc.Context, script : Array<Action>, inf : String ) {
		stack = new Array();
		hregs = new Hash();
		regs = new Array();
		var strings = null;
		var pos = 1;
		while( script.length > 0 ) {
			var op = script.shift();
			switch( op ) {
			case AStop:
				ctx.ops([
					OThis,
					OCallPropVoid(ctx.type("stop"), 0),
				]);
			case APlay:
				ctx.ops([
					OThis,
					OCallPropVoid(ctx.type("play"), 0),
				]);
			case AGotoFrame(fid):
				ctx.ops([
					OThis,
					OInt(fid + 1),
					OCallPropVoid(ctx.type("gotoAndStop"),1),
				]);
			case AGotoFrame2(play, delta):
				if( delta != null ) throw "assert";
				makeValue(ctx, stack.pop(), true);
				ctx.ops([
					OThis,
					OSwap,
					OCallPropVoid(ctx.type("gotoAnd"+(play?"Play":"Stop")),1),
				]);
			case AGotoLabel(label):
				ctx.ops([
					OThis,
					OString(ctx.string(label)),
					OCallPropVoid(ctx.type("gotoAndStop"),1),
				]);
			case APush(items):
				for( i in items )
					switch( i ) {
					case PStack(p), PStack2(p): stack.push(PString(strings[p]));
					default: stack.push(i);
					}
			case AStringPool(sl):
				strings = sl;
			case AGetProperty:
				var prop = stack.pop();
				var vthis = stack.pop();
				if( !Type.enumEq(vthis, PString("")) )
					throw vthis;
				var pname = switch( prop ) {
					case PInt(n):
						var n = haxe.Int32.toInt(n);
						if( n == 4 )
							"currentFrame";
						else
							throw prop;
					default:
						throw prop;
				};
				ctx.op(OThis);
				ctx.op(OGetProp(ctx.type(pname)));
				stack.push(null);
			case ASetProperty:
				var value = stack.pop();
				var prop = stack.pop();
				var vthis = stack.pop();
				if( !Type.enumEq(vthis, PString("")) )
					throw vthis;
				var pname = switch( prop ) {
					case PInt(n):
						var n = haxe.Int32.toInt(n);
						if( n == 7 )
							"visible";
						else
							throw prop;
					default:
						throw prop;
				};
				makeValue(ctx, value, true);
				ctx.ops([
					OThis,
					OSwap,
					OSetProp(ctx.type(pname))
				]);
			case AEval, AObjGet:
				var v = stack.pop();
				var inObj = (op == AObjGet);
				if( inObj ) {
					var obj = stack.pop();
					if( obj != null )
						throw obj;
				}
				switch(v) {
				case PString(s):
					switch( s ) {
					case "_parent": s = "parent";
					}
					if( inObj )
						ctx.op(OGetProp(ctx.type(s)));
					else {
						var index = hregs.get(s);
						if( !inObj && index != null )
							ctx.op(OReg(index));
						else switch( s ) {
						case "_root":
							ctx.op(OGetLex(ctx.type("_Root")));
						case "_global":
							ctx.op(OGetLex(ctx.type("_Global")));
						default:
							ctx.op(OThis);
							ctx.op(OGetProp(ctx.type(s)));
						}
					}
				default:
					throw v;
				}
				stack.push(null);
			case AObjSet:
				makeValue(ctx, stack.pop(), true);
				var field = stack.pop();
				var field = switch( field ) {
					case PString(s): s;
					default: throw field;
				}
				var field = switch( field ) {
					case "_visible":
						"visible";
					case "_alpha":
						ctx.ops([OFloat(ctx.float(0.01)),OOp(OpMul)]);
						"alpha";
					case "_xscale":
						ctx.ops([OFloat(ctx.float(0.01)),OOp(OpMul)]);
						"scaleX";
					case "_yscale":
						ctx.ops([OFloat(ctx.float(0.01)),OOp(OpMul)]);
						"scaleY";
					default: throw field;
				};
				var obj = stack.pop();
				if( obj != null ) throw obj;
				ctx.op(OSetProp(ctx.type(field)));
			case AObjCall:
				var method = stack.pop();
				var method = switch( method ) {
					case PString(s): s;
					default: throw method;
				}
				var obj = stack.pop();
				if( obj != null )
					throw obj;
				var nparams = stack.pop();
				var nparams = switch( nparams ) {
					case PInt(n): haxe.Int32.toInt(n);
					case PDouble(f):
						var x = Std.int(f);
						if( x == f ) x else throw nparams;
					default: throw nparams;
				};
				var arr = allocReg("");
				var arrset = ctx.name(NMultiLate(ctx.nsset([ctx.nsPublic])));
				ctx.ops([
					OArray(0),
					OAsAny,
					OSetReg(arr),
				]);
				for( i in 0...nparams ) {
					var s = stack.pop();
					if( s == null )
						ctx.op(OSwap);
					else
						makeValue(ctx, s, false);
					ctx.ops([
						OReg(arr),
						OSwap,
						OSmallInt(i),
						OSwap,
						OSetProp(arrset),
					]);
				}
				ctx.op(OReg(arr));
				ctx.op(OString(ctx.string(method)));
				ctx.op(OCallProperty(ctx.type("call"), 2));
				stack.push(null);
			case APop:
				ctx.op(OPop);
				stack.pop();
			case ALocalAssign:
				makeValue(ctx, stack.pop(), true);
				var name = stack.pop();
				var name = switch( name ) {
					case PString(s): s;
					default: throw name;
				}
				ctx.op(OAsAny);
				ctx.op(OSetReg(allocReg(name)));
			case ARandom:
				makeValue(ctx, stack.pop(), true);
				ctx.ops([
					OGetLex(ctx.type("Math")),
					OCallProperty(ctx.type("random"), 0),
					OOp(OpMul),
					OToInt
				]);
				stack.push(null);
			case ASubtract:
				makeOp(ctx, OpSub);
			case AAdd:
				makeOp(ctx, OpAdd);
			default:
				trace("Unknown " + Std.string(op)+" in "+inf+" "+Std.string(stack));
				while( stack.length > 0 ) {
					ctx.op(OPop);
					stack.pop();
				}
				break;
			}
		}
		if( stack.length > 0 )
			throw Std.string(stack);
		return regs;
	}
	
	public function buildBytes( bytes : haxe.io.Bytes ) {
		// read
		var t = timer("read");
		var f = new haxe.io.BytesInput(bytes);
		var swf = new format.swf.Reader(f).read();
		t();
		
		// process tags
		var t = timer("process");
		var tags = mapTags(swf.tags, null);
		tags.unshift(TSandBox(8));

		// add root timeline
		var id = 10000;
		var frames = 0;
		for( t in topTags )
			switch( t ) {
			case TShowFrame: frames++;
			default:
			}
		tags.push(TClip(id, frames, topTags));
		exports.set(id, "_root");
		t();
		
		// build AS3 classes
		var t = timer("classes");
		var ctx = new format.abc.Context();
		for( cid in exports.keys() ) {
			var name = exports.get(cid);
			var c = ctx.beginClass(name);
			c.isSealed = false;
			c.superclass = ctx.type("flash.display.MovieClip");
			var script = scripts.get(cid);
			if( script != null ) {
				var f = ctx.beginConstructor([]);
				ctx.ops([
					OThis,
					OScope,
					OThis,
					OConstructSuper(0),
					OFindPropStrict(ctx.type("addFrameScript")),
				]);
				var frames = 0;
				for( i in 1...script.length )
					if( script[i] != null ) {
						ctx.op(OInt(i - 1));
						ctx.op(OGetLex(ctx.type("frame" + i)));
						frames++;
					}
				f.maxStack = frames * 2 + 1;
				f.maxScope++;
				ctx.op(OCallPropVoid(ctx.type("addFrameScript"), frames * 2));
				ctx.op(ORetVoid);
				ctx.endMethod();
				for( i in 1...script.length )
					if( script[i] != null ) {
						var f = ctx.beginMethod("frame" + i, [], null);
						f.maxStack = 10;
						ctx.ops([
							OThis,
							OGetProp(ctx.type("stage")),
							ONull,
						]);
						var j = ctx.jump(JEq);
						var regs = emulateAS1(ctx, script[i], cid + "@" + i);
						f.nRegs = regs.length + 1;
						j();
						ctx.op(ORetVoid);
						ctx.endMethod();
					}
			}
			ctx.endClass();
		}
		ctx.finalize();
		t();
		
		// write as3 bytes
		var t = timer("write as3");
		var abc = ctx.getData();
		var f = new haxe.io.BytesOutput();
		var writer = new format.abc.Writer(f);
		writer.write(abc);
		tags.push(TActionScript3(f.getBytes()));
		t();
		
		// build exports
		var classes = new Array();
		for( cid in exports.keys() )
			classes.push( { className : exports.get(cid), cid : cid } );
		tags.push(TSymbolClass(classes));

		// done
		tags.push(TShowFrame);

		// build
		var t = timer("build");
		var swf = { header : swf.header, tags : tags };
		swf.header.version = 9;
		var f = new haxe.io.BytesOutput();
		new format.swf.Writer(f).write(swf);
		var bytes = f.getBytes();
		t();
		
		return bytes;
	}
	
}
