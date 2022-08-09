package r3d;

import Common;
import r3d.Buffers;

typedef ModelInfos = {
	var pos : Int;
	var size : Int;
	var multi : Bool;
	var box : { x1 : Float, y1 : Float, z1 : Float, x2 : Float, y2 : Float, z2 : Float };
}

class LightInfos {
	public var ipower : Int;
	public var power : Float;
	public var falloff : Float;
	public function new(p, f) {
		power = p;
		falloff = f;
		ipower = Std.int(p);
		if( ipower > 15 ) ipower = 15;
	}
}

class BuilderLevel {
	public var posX : Int;
	public var posY : Int;
	public var posZ : Int;
	public var level : Level;
	public var stride : Int;
	public var cells : Array<CellBuffer>;
	public function new(l) {
		level = l;
		cells = [];
		stride = l.size << (Const.BITS - Builder.CELL);
		for( y in 0...stride )
			for( x in 0...stride )
				cells.push(new CellBuffer(this, x, y));
	}
	public inline function getCell(x, y) {
		return cells[x + y * stride];
	}
	public inline function real( v : Int ) {
		return (v + stride) % stride;
	}
	public inline function preal( v : Int ) {
		return (v + (stride<<Builder.CELL)) % (stride<<Builder.CELL);
	}
}

class Builder {

	public static inline var CELL = 4;
	public static inline var CSIZE = 1<<CELL;

	static inline var MAX_TRI_SIZE = CSIZE * CSIZE * Const.ZSIZE * 6 * 2 * Shaders.BlockShader.STRIDE * 4;

	static inline var MAX_LIGHTS = (CSIZE * CSIZE * Const.ZSIZE * 9) >> 4;
	
	static inline var TE = 0.999;
	static inline var VE = 0.97;

	static inline var Z = 0;
	static inline var X = Const.ZBITS;
	static inline var Y = Const.ZBITS + CELL + 2;
	static inline var DZ = 1 << Z;
	static inline var DX = 1 << X;
	static inline var DY = 1 << Y;

	public static inline var LBASE = 10;
	static inline var LDIST = 12;
	static inline var LDELTA = CSIZE - LDIST;

	public static inline var TAGBITS = 4;
	public static inline var TAGMASK = (1 << TAGBITS) - 1;

	static inline var TAG_NOLIGHT = Type.enumIndex(BlockType.BTReduced);

	static inline var MSIZE = 4096;

	public var level : BuilderLevel;
	public var extra : BuilderLevel;

	var game : AbstractGame;
	var engine : h3d.Engine;

	var currentTags : Level.LevelCell;

	var manager : VirtualBuffer.VirtualManager;
	var tags : VirtualBuffer.VirtualBuffer0;
	var blocks : VirtualBuffer;
	var levelTags : VirtualBuffer;
	var blockInfos : BlockBuffer;
	var models : VirtualBuffer;
	var lights : VirtualBuffer;
	var tmp : VirtualBuffer;
	var lightInfos : flash.Vector<LightInfos>;

	var deltaX : Int;
	var deltaY : Int;
	var bufferPos : Int;

	public function new(game) {

		this.game = game;

		level = new BuilderLevel(game.level);

		manager = new VirtualBuffer.VirtualManager();
		tags = manager.allocFirst( CSIZE * CSIZE * Const.ZSIZE * 12 );
		blocks = manager.alloc( CSIZE * CSIZE * Const.ZSIZE * 2 );
		models = manager.alloc( MSIZE * 4 );
		lights = manager.alloc( MAX_LIGHTS * 4 );
		levelTags = manager.alloc( Const.TSIZE );
		blockInfos = BlockBuffer.alloc(manager, Block.all.length);
		tmp = manager.alloc(MAX_TRI_SIZE >> 1);
	}
		
	public function toggleBlock( b : Block ) {
		manager.select();
		var i = blockInfos.get(b.index);
		i.tag = i.tag == 0 ? Type.enumIndex(b.type) : 0;
		for( l in level.cells )
			l.dirty = true;
		for( cx in game.level.cells )
			for( c in cx )
				c.tags = null;
	}
	
	public function init() {
		engine = game.engine;
		engine.mem.garbage = garbage;
		manager.select();
		
		var modelsData = initModels();
		var hlights = new Hash();
		lightInfos = new flash.Vector();
		
		for( b in Block.all ) {
			var i = blockInfos.get(b.index);
			var neg = b.hasFlag(BFNoShade) ? -1 : 1;
			function fshade(s) return Math.sqrt(s) * neg;
			var type = b.type;
			if( !engine.hardware )
				switch( type ) {
				case BTTransp: if( !b.hasFlag(BFNoOptimize) ) type = BTFull;
				default:
				}
			i.tag = Type.enumIndex(type);
			i.shadeDown = fshade(b.shadeDown);
			i.shadeUp = fshade(b.shadeUp);
			i.shadeX = fshade(b.shadeX);
			i.shadeY = fshade(b.shadeY);
			i.tlr = b.tlr;
			i.tu = b.tu;
			i.td = b.td;
			if( b.model != null ) {
				var m = modelsData[Type.enumIndex(b.model)];
				if( m == null ) m = modelsData[0];
				if( b.size == null ) b.size = m.box;
				i.modelPos = m.pos;
				i.modelSize = m.size;
				if( m.multi )
					i.tag = Type.enumIndex(BTModelMultiTex);
			}
			switch( type ) {
			case BTReduced:
				var last = modelsData[modelsData.length - 1];
				var pos = last.pos + last.size * 6;
				modelsData.push( { size : 1, pos : pos, multi : false, box : null } );
				i.modelPos = pos;
				var s = b.size;
				if( s == null )
					throw b.k + " does not have Size";
				models.setFloat(pos++, s.x1);
				models.setFloat(pos++, s.y1);
				models.setFloat(pos++, s.z1);
				models.setFloat(pos++, s.x2);
				models.setFloat(pos++, s.y2);
				models.setFloat(pos++, s.z2);
				if( pos > MSIZE )
					throw "overflow " + pos;
			default:
			}
			if( b.special != null ) {
				i.special = Type.enumIndex(b.special);
				// allocate light index
				switch( b.special ) {
				case BFLight(p, f):
					if( f == null ) f = 1.0;
					var key = Std.string(p+"#"+f);
					var index = hlights.get(key);
					if( index == null ) {
						index = lightInfos.length;
						if( index > 255 ) throw "Too many lights";
						lightInfos.push(new LightInfos(p, f));
						hlights.set(key, index);
						if( Math.ceil(p / f) > LDIST ) haxe.Log.trace("Warning : light cut for " + Std.string(b.special), null);
					}
					i.lightIndex = index;
				default:
				}
			}
			b.renderTag = i.tag;
		}
	}
	
	function initModels() {
		var md = new Array<ModelInfos>();
		var start = 0;
		var pos = 0;
		var stride = 6;
		var bdef = new Block(null);
		function addVert(x, y, z, tu:Float, tv:Float, t = 0, s = 1.0) {
			models.setFloat(pos++, x);
			models.setFloat(pos++, y);
			models.setFloat(pos++, z);
			models.setFloat(pos++, tu * TE * (1 / 64) + t);
			models.setFloat(pos++, (1-tv) * TE * (1 / 64));
			models.setFloat(pos++, s);
		}
		function addCube(x, y, z, x2, y2, z2, u = 1., v = 1., u2 = 1., v2 = 1. ) {
			// up
			addVert(x, y, z2, 0, 0, 1, bdef.shadeUp);
			addVert(x2, y, z2, 0, v, 1, bdef.shadeUp);
			addVert(x, y2, z2, u, 0, 1, bdef.shadeUp);
			addVert(x2, y2, z2, u, v, 1, bdef.shadeUp);
			// down
			addVert(x, y, z, 0, 0, 2, bdef.shadeDown);
			addVert(x, y2, z, u, 0, 2, bdef.shadeDown);
			addVert(x2, y, z, 0, v, 2, bdef.shadeDown);
			addVert(x2, y2, z, u, v, 2, bdef.shadeDown);
			// 4 sides
			addVert(x, y, z, 0, 0, 0, bdef.shadeX);
			addVert(x, y, z2, 0, v2, 0, bdef.shadeX);
			addVert(x, y2, z, u2, 0, 0, bdef.shadeX);
			addVert(x, y2, z2, u2, v2, 0, bdef.shadeX);

			
			addVert(x, y2, z, 0, 0, 0, bdef.shadeY);
			addVert(x, y2, z2, 0, v2, 0, bdef.shadeY);
			addVert(x2, y2, z, u2, 0, 0, bdef.shadeY);
			addVert(x2, y2, z2, u2, v2, 0, bdef.shadeY);

			addVert(x2, y, z, u2, 0, 0, bdef.shadeX);
			addVert(x2, y2, z, 0, 0, 0, bdef.shadeX);
			addVert(x2, y, z2, u2, v2, 0, bdef.shadeX);
			addVert(x2, y2, z2, 0, v2, 0, bdef.shadeX);

			addVert(x, y, z, u2, 0, 0, bdef.shadeY);
			addVert(x2, y, z, 0, 0, 0, bdef.shadeY);
			addVert(x, y, z2, u2, v2, 0, bdef.shadeY);
			addVert(x2, y, z2, 0, v2, 0, bdef.shadeY);
			
			return { x1 : x, y1 : y, z1 : z, x2 : x2, y2 : y2, z2 : z2 };
		}
		
		function load( b : Array<Float> ) {
			var x1 = 1., y1 = 1., z1 = 1., x2 = 0., y2 = 0., z2 = 0.;
			var p = 0;
			for( i in 0...Std.int(b.length / 6) ) {
				var x = b[p++], y = b[p++], z = b[p++];
				if( x < x1 ) x1 = x;
				if( y < y1 ) y1 = y;
				if( z < z1 ) z1 = z;
				if( x > x2 ) x2 = x;
				if( y > y2 ) y2 = y;
				if( z > z2 ) z2 = z;
				models.setFloat(pos++, x);
				models.setFloat(pos++, y);
				models.setFloat(pos++, z);
				models.setFloat(pos++, b[p++]);
				models.setFloat(pos++, b[p++]);
				models.setFloat(pos++, b[p++]);
			}
			return { x1 : x1, y1 : y1, z1 : z1, x2 : x2, y2 : y2, z2 : z2 };
		}
		
		function flip() {
			var m = md[md.length - 1];
			var r = m.pos;
			var dpos = [0, 6, -12, 6];
			for( i in 0...m.size>>2 )  {
				for( dp in dpos ) {
					r += dp;
					var x = models.getFloat(r++);
					var y = models.getFloat(r++);
					var z = models.getFloat(r++);
					models.setFloat(pos++, y);
					models.setFloat(pos++, x);
					models.setFloat(pos++, z);
					models.setFloat(pos++, models.getFloat(r++));
					models.setFloat(pos++, models.getFloat(r++));
					models.setFloat(pos++, models.getFloat(r++));
				}
			}
			var sz = m.box;
			return { x1 : sz.y1, y1 : sz.x1, z1 : sz.z1, x2 : sz.y2, y2 : sz.x2, z2: sz.z2 };
		}

		for( m in Type.allEnums(BlockModel) ) {
			var multi = false;
			var size = null;
			switch( m ) {
			case MCross:
				addVert(0, 0, 0, 0, 0);
				addVert(0, 0, 1, 0, 1);
				addVert(1, 1, 0, 1, 0);
				addVert(1, 1, 1, 1, 1);

				addVert(0, 1, 0, 0, 0);
				addVert(0, 1, 1, 0, 1);
				addVert(1, 0, 0, 1, 0);
				addVert(1, 0, 1, 1, 1);
				
			case MPlanX:
				addVert(0.5, 0, 0, 0, 0);
				addVert(0.5, 0, 1, 0, 1);
				addVert(0.5, 1, 0, 1, 0);
				addVert(0.5, 1, 1, 1, 1);
				size = { x1 : 0.45, y1 : 0., z1 : 0., x2 : 0.55, y2 : 1., z2 : 1. };
			case MPlanY:
				addVert(0, 0.5, 0, 0, 0);
				addVert(0, 0.5, 1, 0, 1);
				addVert(1, 0.5, 0, 1, 0);
				addVert(1, 0.5, 1, 1, 1);
				size = { x1 : 0., y1 : 0.45, z1 : 0., x2 : 1., y2 : 0.55, z2 : 1. };
			case MPlanZ:
				addVert(0, 0, 0.5, 0, 0);
				addVert(0, 1, 0.5, 0, 1);
				addVert(1, 0, 0.5, 1, 0);
				addVert(1, 1, 0.5, 1, 1);
				size = { x1 : 0., y1 : 0., z1 : 0.45, x2 : 1., y2 : 1., z2 : 0.55 };
			case MHalf:
				size = addCube(0, 0, 0, 1, 1, 0.5, 1, 1, 1, 0.5);
				multi = true;
			case MMini:
				size = addCube(0.25, 0.25, 0, 0.75, 0.75, 0.5);
				multi = true;
			case MMiniTop:
				var pos = pos;
				size = addCube(0.2, 0.2, 0.4, 0.8, 0.8, 1);
				// no shades
				for( v in 0...6 * 4 ) {
					models.setFloat(pos + 5, 1.0);
					pos += stride;
				}
				multi = true;
			case MColumn:
				var w = 8 / 32; // pixels
				var pos = pos;
				size = addCube(0.35, 0.35, 0, 0.65, 0.65, 1, w, w, w, 1);
				// wrap u
				pos += stride * 8;
				for( v in 0...4*4 ) {
					models.setFloat(pos + 3, models.getFloat(pos+3) + w * Std.int(v/4) * 1/64 );
					pos += stride;
				}
				multi = true;
			case MBigColumn:
				var pos = pos;
				size = addCube(0.25, 0.25, 0, 0.75, 0.75, 1, 0.5, 0.5, 0.5, 1);
				// wrap u
				pos += stride * 8;
				for( v in 0...4 ) {
					models.setFloat(pos + 3, models.getFloat(pos+3) + 0.5 * 1/64 );
					pos += stride;
				}
				pos += stride * 4;
				for( v in 0...4 ) {
					models.setFloat(pos + 3, models.getFloat(pos+3) + 0.5 * 1/64 );
					pos += stride;
				}
				multi = true;
			case MPipeX, MPipeY:
				var w = 8 / 32; // pixels
				var pos = pos;
				size = addCube(0.35, 0.35, 0, 0.65, 0.65, 1, w, w, w, 1);
				// wrap u
				pos += stride * 8;
				for( v in 0...4 ) {
					models.setFloat(pos + 3, models.getFloat(pos+3) + w * Std.int(v/4) * 1/64 );
					pos += stride;
				}
				// inverse axis
				pos -= stride * 12;
				for( v in 0...6*4 ) {
					if( m == MPipeX ) {
						// inverse x/z
						var x = models.getFloat(pos);
						models.setFloat(pos, 1-models.getFloat(pos + 2));
						models.setFloat(pos + 2, x);
					} else {
						// inverse y/z
						var y = models.getFloat(pos+1);
						models.setFloat(pos+1, 1-models.getFloat(pos + 2));
						models.setFloat(pos + 2, y);
					}
					pos += stride;
				}
				multi = true;
			case MDoorOpenX:
				size = load(Macro.getModel("door.md"));
			case MDoorOpenY:
				size = flip();

			case MCrossSquare:
				addVert(0.25, 0, 0, 0, 0);
				addVert(0.25, 0, 1, 0, 1);
				addVert(0.25, 1, 0, 1, 0);
				addVert(0.25, 1, 1, 1, 1);

				addVert(0.75, 0, 0, 0, 0);
				addVert(0.75, 0, 1, 0, 1);
				addVert(0.75, 1, 0, 1, 0);
				addVert(0.75, 1, 1, 1, 1);

				addVert(0, 0.25, 0, 0, 0);
				addVert(0, 0.25, 1, 0, 1);
				addVert(1, 0.25, 0, 1, 0);
				addVert(1, 0.25, 1, 1, 1);

				addVert(0, 0.75, 0, 0, 0);
				addVert(0, 0.75, 1, 0, 1);
				addVert(1, 0.75, 0, 1, 0);
				addVert(1, 0.75, 1, 1, 1);
				
			case MCrossBox:
				// box
				addVert(0, 0, 0,  0, 0);
				addVert(0, 0, 1,  0, 1);
				addVert(0, 1, 0,  1, 0);
				addVert(0, 1, 1,  1, 1);
				
				addVert(1, 0, 0,  0, 0);
				addVert(1, 0, 1,  0, 1);
				addVert(1, 1, 0,  1, 0);
				addVert(1, 1, 1,  1, 1);
				
				addVert(0, 0, 0,  0, 0);
				addVert(0, 0, 1,  0, 1);
				addVert(1, 0, 0,  1, 0);
				addVert(1, 0, 1,  1, 1);
				
				addVert(0, 1, 0,  0, 0);
				addVert(0, 1, 1,  0, 1);
				addVert(1, 1, 0,  1, 0);
				addVert(1, 1, 1,  1, 1);
				
				addVert(0, 0, 0,  0, 0);
				addVert(0, 1, 0,  0, 1);
				addVert(1, 0, 0,  1, 0);
				addVert(1, 1, 0,  1, 1);
				
				addVert(0, 0, 1,  0, 0);
				addVert(0, 1, 1,  0, 1);
				addVert(1, 0, 1,  1, 0);
				addVert(1, 1, 1,  1, 1);
				
				// cross
				multi = true;
				addVert(0, 0, 0,  0, 0,  1);
				addVert(0, 0, 1,  0, 1,  1);
				addVert(1, 1, 0,  1, 0,  1);
				addVert(1, 1, 1,  1, 1,  1);

				addVert(0, 1, 0,  0, 0,  1);
				addVert(0, 1, 1,  0, 1,  1);
				addVert(1, 0, 0,  1, 0,  1);
				addVert(1, 0, 1,  1, 1,  1);

				//addVert(0.75, 0, 0, 0, 0);
				//addVert(0.75, 0, 1, 0, 1);
				//addVert(0.75, 1, 0, 1, 0);
				//addVert(0.75, 1, 1, 1, 1);
//
				//addVert(0, 0.25, 0, 0, 0);
				//addVert(0, 0.25, 1, 0, 1);
				//addVert(1, 0.25, 0, 1, 0);
				//addVert(1, 0.25, 1, 1, 1);
//
				//addVert(0, 0.75, 0, 0, 0);
				//addVert(0, 0.75, 1, 0, 1);
				//addVert(1, 0.75, 0, 1, 0);
				//addVert(1, 0.75, 1, 1, 1);
				
			case MCrossPyramid:
				addVert(0.1, 0, 0, 0, 0);
				addVert(0.5, 0, 1, 0, 1);
				addVert(0.1, 1, 0, 1, 0);
				addVert(0.5, 1, 1, 1, 1);

				addVert(0.9, 0, 0, 0, 0);
				addVert(0.5, 0, 1, 0, 1);
				addVert(0.9, 1, 0, 1, 0);
				addVert(0.5, 1, 1, 1, 1);

				addVert(0, 0.1, 0, 0, 0);
				addVert(0, 0.5, 1, 0, 1);
				addVert(1, 0.1, 0, 1, 0);
				addVert(1, 0.5, 1, 1, 1);

				addVert(0, 0.9, 0, 0, 0);
				addVert(0, 0.5, 1, 0, 1);
				addVert(1, 0.9, 0, 1, 0);
				addVert(1, 0.5, 1, 1, 1);
			}
			
			md.push( { pos : start, size : Std.int((pos - start)/6), multi : multi, box : size } );
			start = pos;
			if( pos > MSIZE )
				throw "overflow " + pos;
		}
		return md;
	}
	
	function sortByFrame(c1:CellBuffer, c2:CellBuffer) {
		return c1.frame - c2.frame;
	}
	
	function garbage() {
		var alloc = [];
		for( c in level.cells )
			if( c.buffers.length > 0 ) {
				if( c.dirty )
					c.dispose();
				else
					alloc.push(c);
			}
		if( alloc.length == 0 )
			return;
		alloc.sort(sortByFrame);
		var f0 = alloc[0].frame;
		for( c in alloc )
			if( c.frame == f0 )
				c.dispose();
	}

	function computeTags( c : Level.LevelCell ) {
		var tmp = tmp;
		var blockInfos = blockInfos;
		var levelTags = levelTags;
		var specials = new flash.utils.ByteArray();
		manager.copy(c.t, 0, tmp, Const.TSIZE * 2);
		
		var i = 0;
		var zMax = 0;
		for( y in 0...Const.SIZE )
			for( x in 0...Const.SIZE )
				for( z in 0...Const.ZSIZE ) {
					var bt = tmp.getUI16(i);
					if( bt == 0 ) {
						levelTags.setByte(i++, 0);
						continue;
					}
					var b = blockInfos.get(bt);
					levelTags.setByte(i, b.tag);
					if( b.special > 0 ) {
						specials.writeByte(x);
						specials.writeByte(y);
						specials.writeByte(z);
						specials.writeByte(b.special);
					}
					if( z > zMax ) zMax = z;
					i++;
				}
		c.zMax = zMax;
		c.tags = new flash.utils.ByteArray();
		c.tags.writeBytes(manager.bytes, levelTags.getPos(), Const.TSIZE);
		c.light = new flash.utils.ByteArray();
		c.light.length = Const.TSIZE;
		c.specials = specials;
		currentTags = c;
	}

	inline function addr(x, y, z) {
		return (x << X) | (y << Y) | (z << Z);
	}

	public function invalidate(x, y, z) {
		var level = level;
		if( extra != null && z > Const.SIZE ) {
			x = extra.preal(x - extra.posX);
			y = extra.preal(y - extra.posY);
			z -= extra.posZ;
			level = extra;
		}
		level.getCell(x >> CELL, y >> CELL).dirty = true;
		var lc = level.level.cells[x >> Const.BITS][y >> Const.BITS];
		if( lc == currentTags )
			currentTags = null;
	}
	
	public function updateKube(x, y, z, b:Block) {
		
		var level = level;
		if( extra != null && z > Const.SIZE ) {
			x = extra.preal(x - extra.posX);
			y = extra.preal(y - extra.posY);
			z -= extra.posZ;
			level = extra;
		}
		
		var cx = x >> CELL;
		var cy = y >> CELL;
		level.getCell(cx, cy).dirty = true;
		
		var lchange = LDIST; // TODO : calculate light change power

		var rx = x - (cx << CELL);
		var ry = y - (cy << CELL);
		if( rx == 0 || rx < lchange )
			level.getCell(level.real(cx - 1), cy).dirty = true;
		if( ry == 0 || ry < lchange )
			level.getCell(cx, level.real(cy - 1)).dirty = true;
		if( rx == CSIZE - 1 || CSIZE-1-rx < lchange )
			level.getCell(level.real(cx + 1), cy).dirty = true;
		if( ry == CSIZE - 1 || CSIZE-1-ry < lchange )
			level.getCell(cx, level.real(cy + 1)).dirty = true;
		if( lchange > 0 ) {
			if( rx + ry + 1 < lchange )
				level.getCell(level.real(cx - 1), level.real(cy - 1)).dirty = true;
			if( rx + (CSIZE-ry) < lchange )
				level.getCell(level.real(cx - 1), level.real(cy + 1)).dirty = true;
			if( (CSIZE-rx) + ry < lchange )
				level.getCell(level.real(cx + 1), level.real(cy - 1)).dirty = true;
			if( (CSIZE-rx) + (CSIZE-ry) - 1 < lchange )
				level.getCell(level.real(cx + 1), level.real(cy + 1)).dirty = true;
		}
	
		var cx = x >> Const.BITS;
		var cy = y >> Const.BITS;
		if( currentTags != null && currentTags.x == cx && currentTags.y == cy )
			currentTags = null;
	}
	
	function relight(sun : Float,sunFall : Float, zMax : Int) {
		var outPos = tmp.getPos();

		var lmax = Std.int(sun) << TAGBITS;
		var light = Std.int(sun - sunFall) << TAGBITS;
		if( light < 0 ) light = 0;
		
		var zSunMax = zMax + 1;
		if( zSunMax >= game.planet.lightHeight ) zSunMax = game.planet.lightHeight - 1;
		
		// fill sun light
		for( y in LDELTA...CSIZE*3-LDELTA )
			for( x in LDELTA...CSIZE*3-LDELTA ) {
				var z = zSunMax;
				var addr = addr(x,y,z);
				while( z >= 0 ) {
					var t = flash.Memory.getByte(addr) & TAGMASK;
					if( t != 0 ) {
						if( t < TAG_NOLIGHT ) {
							flash.Memory.setByte(addr, t | light);
							flash.Memory.setByte(outPos++, x);
							flash.Memory.setByte(outPos++, y);
							flash.Memory.setByte(outPos++, z);
						}
						break;
					}
					flash.Memory.setByte(addr, lmax);
					// propagate our light to previous blocks
					if( x > LDELTA ) {
						var bt = flash.Memory.getByte(addr - DX);
						if( bt < TAG_NOLIGHT ) {
							flash.Memory.setByte(addr - DX, bt | light);
							flash.Memory.setByte(outPos++, x - 1);
							flash.Memory.setByte(outPos++, y);
							flash.Memory.setByte(outPos++, z);
						}
					}
					if( y > LDELTA ) {
						var bt = flash.Memory.getByte(addr - DY);
						if( bt < TAG_NOLIGHT ) {
							flash.Memory.setByte(addr - DY, bt | light);
							flash.Memory.setByte(outPos++, x);
							flash.Memory.setByte(outPos++, y - 1);
							flash.Memory.setByte(outPos++, z);
						}
					}
					z--;
					addr -= DZ;
				}
				while( z > 0 ) {
					// propagate previous blocks light to current block
					var t = flash.Memory.getByte(addr) & TAGMASK;
					if( t < TAG_NOLIGHT && (flash.Memory.getByte(addr - DX) == lmax || flash.Memory.getByte(addr - DY) == lmax) ) {
						flash.Memory.setByte(addr, t | light);
						flash.Memory.setByte(outPos++, x);
						flash.Memory.setByte(outPos++, y);
						flash.Memory.setByte(outPos++, z);
					}
					z--;
					addr -= DZ;
				}
			}

		processLight(sun - sunFall * 2, sunFall, outPos, zMax);
		
		// process lights
		var pos = 0;
		while( true ) {
			var x = lights.getByte(pos++);
			if( x == 0xFF ) break;
			var y = lights.getByte(pos++);
			var z = lights.getByte(pos++);
			var light = lightInfos[lights.getByte(pos++)];
			var addr = addr(x, y, z);
			var cur = flash.Memory.getByte(addr);
			if( cur >= light.ipower << TAGBITS )
				continue;
			flash.Memory.setByte(addr, (cur&TAGMASK) | (light.ipower << TAGBITS));
			outPos = tmp.getPos();
			flash.Memory.setByte(outPos++, x);
			flash.Memory.setByte(outPos++, y);
			flash.Memory.setByte(outPos++, z);
			processLight(light.power - light.falloff, light.falloff, outPos, zMax);
		}
	}
	
	function processLight( lvalue : Float, ldelta : Float, outPos : Int, zMax : Int ) {
		var curPos = tmp.getPos();
		var t;

		while( true ) {
			var light = Std.int(lvalue);
			if( light > 15 ) light = 15;
			if( light <= 0 ) break;
			light <<= TAGBITS;
			var endPos = outPos;
			while( curPos < endPos ) {
				var x = flash.Memory.getByte(curPos++);
				var y = flash.Memory.getByte(curPos++);
				var z = flash.Memory.getByte(curPos++);
				var addr = this.addr(x, y, z);

				if( x > LDELTA && (t=flash.Memory.getByte(addr - DX)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr - DX, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x - 1);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z);
				}
				if( x < CSIZE*3-LDELTA-1 && (t=flash.Memory.getByte(addr + DX)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr + DX, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x + 1);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z);
				}
				if( y > LDELTA && (t=flash.Memory.getByte(addr - DY)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr - DY, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y - 1);
					flash.Memory.setByte(outPos++, z);
				}
				if( y < CSIZE*3-LDELTA-1 && (t=flash.Memory.getByte(addr + DY)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr + DY, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y + 1);
					flash.Memory.setByte(outPos++, z);
				}
				if( z > 0 && (t=flash.Memory.getByte(addr - DZ)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr - DZ, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z - 1);
				}
				if( z < zMax && (t=flash.Memory.getByte(addr + DZ)) < light && t&TAGMASK < TAG_NOLIGHT ) {
					flash.Memory.setByte(addr + DZ, (t&TAGMASK) | light);
					flash.Memory.setByte(outPos++, x);
					flash.Memory.setByte(outPos++, y);
					flash.Memory.setByte(outPos++, z + 1);
				}
			}
			lvalue -= ldelta;
		}
	}

	public inline function addVertex(t, shade, x : Float , y : Float, z : Float, tu:Float, tv:Float) {
		var tu = ((t & 63) + tu * TE) * (1 / 64);
		var tv = ((t >> 6) + tv * TE) * (1 / 64);
		flash.Memory.setFloat(bufferPos, x + deltaX);	bufferPos += 4;
		flash.Memory.setFloat(bufferPos, y + deltaY);	bufferPos += 4;
		flash.Memory.setFloat(bufferPos, z);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, tu);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, tv);			bufferPos += 4;
		flash.Memory.setFloat(bufferPos, shade);		bufferPos += 4;
	}

	inline function addQuad( addr : Int, t : Int, shade : Float, sx, sy, sz, dx, dy, dz, side : Bool ) {
		var delta = (1 - dx) * DX * (side?1:-1) + (1 - dy) * DY * (side?1:-1) + (1 - dz) * DZ * (side?1:-1);
		var ldx = (1 - dx) * DY * (side?-1:1) + (1 - dy) * DX * (side?1:-1) + (1 - dz) * DY;
		var ldy = -(1 - dx) * DZ + -(1 - dy) * DZ - (1 - dz) * DX;
		var light = getLight(addr + delta);

		var lumTL, lumTR, lumBL, lumBR;
		if( shade < 0 ) {
			lumTL = lumTR = lumBL = lumBR = -shade;
		} else {
			var lightL = getLight(addr + delta - ldx);
			var lightR = getLight(addr + delta + ldx);
			var lightT = getLight(addr + delta - ldy);
			var lightB = getLight(addr + delta + ldy);
			var lightTL = getLight(addr + delta - ldx - ldy);
			var lightTR = getLight(addr + delta + ldx - ldy);
			var lightBL = getLight(addr + delta - ldx + ldy);
			var lightBR = getLight(addr + delta + ldx + ldy);

			
			lumTL = (light + lightL + lightT + lightTL) * shade * (0.25 / LBASE);
			lumTR = (light + lightR + lightT + lightTR) * shade * (0.25 / LBASE);
			lumBL = (light + lightL + lightB + lightBL) * shade * (0.25 / LBASE);
			lumBR = (light + lightR + lightB + lightBR) * shade * (0.25 / LBASE);
		}
		
		if( dx == 0 || dy == 0 ) {
			if( side ) {
				addVertex(t, lumBL, sx, sy + dy, sz, 0, 1);
				addVertex(t, lumTL, sx, sy + dy, sz + dz, 0, 0);
				addVertex(t, lumBR, sx + dx, sy, sz, 1, 1);
				addVertex(t, lumTR, sx + dx, sy, sz + dz, 1, 0);
			} else {
				addVertex(t, lumBL, sx + dx, sy, sz, 0, 1);
				addVertex(t, lumTL, sx + dx, sy, sz + dz, 0, 0);
				addVertex(t, lumBR, sx, sy + dy, sz, 1, 1);
				addVertex(t, lumTR, sx, sy + dy, sz + dz, 1, 0);
			}
		} else {
			if( side ) {
				addVertex(t, lumBL, sx, sy, sz, 0, 1);
				addVertex(t, lumTL, sx + dx, sy, sz, 0, 0);
				addVertex(t, lumBR, sx, sy + dy, sz, 1, 1);
				addVertex(t, lumTR, sx + dx, sy + dy, sz, 1, 0);
			} else {
				// flip vertex order
				addVertex(t, lumBL, sx, sy, sz, 0, 1);
				addVertex(t, lumBR, sx, sy + dy, sz, 1, 1);
				addVertex(t, lumTL, sx + dx, sy, sz, 0, 0);
				addVertex(t, lumTR, sx + dx, sy + dy, sz, 1, 0);
			}
		}
	}
	
	inline function addCustomQuad( addr : Int, t : Int, shade : Float, sx, sy, sz, dx, dy, dz, ddx:Float, ddy:Float, ddz:Float, side : Bool ) {
		var delta = (1 - dx) * DX * (side?1:-1) + (1 - dy) * DY * (side?1:-1) + (1 - dz) * DZ * (side?1:-1);
		var ldx = (1 - dx) * DY * (side?-1:1) + (1 - dy) * DX * (side?1:-1) + (1 - dz) * DY;
		var ldy = -(1 - dx) * DZ + -(1 - dy) * DZ - (1 - dz) * DX;
		var light = getLight(addr + delta);

		var lumTL, lumTR, lumBL, lumBR;
		if( shade < 0 ) {
			lumTL = lumTR = lumBL = lumBR = -shade;
		} else {
			var lightL = getLight(addr + delta - ldx);
			var lightR = getLight(addr + delta + ldx);
			var lightT = getLight(addr + delta - ldy);
			var lightB = getLight(addr + delta + ldy);
			var lightTL = getLight(addr + delta - ldx - ldy);
			var lightTR = getLight(addr + delta + ldx - ldy);
			var lightBL = getLight(addr + delta - ldx + ldy);
			var lightBR = getLight(addr + delta + ldx + ldy);

			
			lumTL = (light + lightL + lightT + lightTL) * shade * (0.25 / LBASE);
			lumTR = (light + lightR + lightT + lightTR) * shade * (0.25 / LBASE);
			lumBL = (light + lightL + lightB + lightBL) * shade * (0.25 / LBASE);
			lumBR = (light + lightR + lightB + lightBR) * shade * (0.25 / LBASE);
		}
		
		if( dx == 0 ) {
			if( side ) {
				addVertex(t, lumBL, sx, sy + ddy, sz, 0, ddz);
				addVertex(t, lumTL, sx, sy + ddy, sz + ddz, 0, 0);
				addVertex(t, lumBR, sx, sy, sz, ddy, ddz);
				addVertex(t, lumTR, sx, sy, sz + ddz, ddy, 0);
			} else {
				addVertex(t, lumBL, sx, sy, sz, 0, ddz);
				addVertex(t, lumTL, sx, sy, sz + ddz, 0, 0);
				addVertex(t, lumBR, sx, sy + ddy, sz, ddy, ddz);
				addVertex(t, lumTR, sx, sy + ddy, sz + ddz, ddy, 0);
			}
		} else if( dy == 0 ) {
			if( side ) {
				addVertex(t, lumBL, sx, sy, sz, 0, ddz);
				addVertex(t, lumTL, sx, sy, sz + ddz, 0, 0);
				addVertex(t, lumBR, sx + ddx, sy, sz, ddx, ddz);
				addVertex(t, lumTR, sx + ddx, sy, sz + ddz, ddx, 0);
			} else {
				addVertex(t, lumBL, sx + ddx, sy, sz, 0, ddz);
				addVertex(t, lumTL, sx + ddx, sy, sz + ddz, 0, 0);
				addVertex(t, lumBR, sx, sy, sz, ddx, ddz);
				addVertex(t, lumTR, sx, sy, sz + ddz, ddx, 0);
			}
		} else {
			if( side ) {
				addVertex(t, lumBL, sx, sy, sz, 0, ddx);
				addVertex(t, lumTL, sx + ddx, sy, sz, 0, 0);
				addVertex(t, lumBR, sx, sy + ddy, sz, ddy, ddx);
				addVertex(t, lumTR, sx + ddx, sy + ddy, sz, ddy, 0);
			} else {
				// flip vertex order
				addVertex(t, lumBL, sx, sy, sz, 0, ddx);
				addVertex(t, lumBR, sx, sy + ddy, sz, ddy, ddx);
				addVertex(t, lumTL, sx + ddx, sy, sz, 0, 0);
				addVertex(t, lumTR, sx + ddx, sy + ddy, sz, ddy, 0);
			}
		}
	}

	inline function getLight( addr : Int ) {
		return tags.getByte(addr) >> TAGBITS;
	}

	inline function isTransparent( addr : Int ) {
		return tags.getByte(addr)&TAGMASK != Type.enumIndex(BTFull);
	}

	inline function isTransparentNot( addr : Int, bt : BlockType ) {
		var t = tags.getByte(addr) & TAGMASK;
		return t != Type.enumIndex(BTFull) && t != Type.enumIndex(bt);
	}

	inline function isNotWater( addr : Int ) {
		return tags.getByte(addr)&TAGMASK != Type.enumIndex(BTWater);
	}

	public function allocBuffer() {
		var nfloats = (bufferPos - tmp.getPos()) >> 2;
		var nvect = Std.int(nfloats / Shaders.BlockShader.STRIDE);
		if( nvect == 0 ) return null;
		var buf = engine.mem.alloc(nvect, Shaders.BlockShader.STRIDE, 4);
		buf.upload(manager.bytes, tmp.getPos(), nvect);
		return buf;
	}
	
	public function initBuffer() {
		bufferPos = tmp.getPos();
		deltaX = 0;
		deltaY = 0;
		manager.select();
	}
	
	public function addBufferQuad( t : Int, shade : Float, sx : Float, sy : Float, sz : Float, dx:Float, dy:Float, dz:Float, side ) {
		if( shade < 0 ) shade = -shade;
		if( dx == 0 || dy == 0 ) {
			if( side ) {
				addVertex(t, shade, sx, sy + dy, sz, 0, 1);
				addVertex(t, shade, sx, sy + dy, sz + dz, 0, 0);
				addVertex(t, shade, sx + dx, sy, sz, 1, 1);
				addVertex(t, shade, sx + dx, sy, sz + dz, 1, 0);
			} else {
				addVertex(t, shade, sx + dx, sy, sz, 0, 1);
				addVertex(t, shade, sx + dx, sy, sz + dz, 0, 0);
				addVertex(t, shade, sx, sy + dy, sz, 1, 1);
				addVertex(t, shade, sx, sy + dy, sz + dz, 1, 0);
			}
		} else {
			if( side ) {
				addVertex(t, shade, sx, sy, sz, 0, 1);
				addVertex(t, shade, sx + dx, sy, sz + dz, 0, 0);
				addVertex(t, shade, sx, sy + dy, sz, 1, 1);
				addVertex(t, shade, sx + dx, sy + dy, sz + dz, 1, 0);
			} else {
				// flip vertex order
				addVertex(t, shade, sx, sy, sz, 0, 1);
				addVertex(t, shade, sx, sy + dy, sz, 1, 1);
				addVertex(t, shade, sx + dx, sy, sz + dz, 0, 0);
				addVertex(t, shade, sx + dx, sy + dy, sz + dz, 1, 0);
			}
		}
	}
	
	function addBufferCustomQuad( t : Int, shade : Float, sx : Float, sy : Float, sz : Float, ddx:Float, ddy:Float, ddz:Float, side ) {
		if( shade < 0 ) shade = -shade;
		if( ddx == 0 ) {
			if( side ) {
				addVertex(t, shade, sx, sy + ddy, sz, 0, ddz);
				addVertex(t, shade, sx, sy + ddy, sz + ddz, 0, 0);
				addVertex(t, shade, sx, sy, sz, ddy, ddz);
				addVertex(t, shade, sx, sy, sz + ddz, ddy, 0);
			} else {
				addVertex(t, shade, sx, sy, sz, 0, ddz);
				addVertex(t, shade, sx, sy, sz + ddz, 0, 0);
				addVertex(t, shade, sx, sy + ddy, sz, ddy, ddz);
				addVertex(t, shade, sx, sy + ddy, sz + ddz, ddy, 0);
			}
		} else if( ddy == 0 ) {
			if( side ) {
				addVertex(t, shade, sx, sy, sz, 0, ddz);
				addVertex(t, shade, sx, sy, sz + ddz, 0, 0);
				addVertex(t, shade, sx + ddx, sy, sz, ddx, ddz);
				addVertex(t, shade, sx + ddx, sy, sz + ddz, ddx, 0);
			} else {
				addVertex(t, shade, sx + ddx, sy, sz, 0, ddz);
				addVertex(t, shade, sx + ddx, sy, sz + ddz, 0, 0);
				addVertex(t, shade, sx, sy, sz, ddx, ddz);
				addVertex(t, shade, sx, sy, sz + ddz, ddx, 0);
			}
		} else {
			if( side ) {
				addVertex(t, shade, sx, sy, sz, 0, ddx);
				addVertex(t, shade, sx + ddx, sy, sz, 0, 0);
				addVertex(t, shade, sx, sy + ddy, sz, ddy, ddx);
				addVertex(t, shade, sx + ddx, sy + ddy, sz, ddy, 0);
			} else {
				// flip vertex order
				addVertex(t, shade, sx, sy, sz, 0, ddx);
				addVertex(t, shade, sx, sy + ddy, sz, ddy, ddx);
				addVertex(t, shade, sx + ddx, sy, sz, 0, 0);
				addVertex(t, shade, sx + ddx, sy + ddy, sz, ddy, 0);
			}
		}
	}
	
	public function blockTriangles( b : Block ) {
		var block = blockInfos.get(b.index);
		switch( b.type ) {
		case BTModel, BTModel2Side:
			return block.modelSize >> 1;
		case BTSprite:
			return 2;
		default:
			return 12;
		}
	}
	
	public function addBufferBlock( b : Block, x : Float, y : Float, z : Float, shade : Float ) {
		var block = blockInfos.get(b.index);
		switch( b.type ) {
		case BTModel, BTModel2Side, BTModelMultiTex:
			var model = block.modelPos;
			if( block.tag == Type.enumIndex(BTModelMultiTex) ) {
				var tu1 = (block.tlr & 63) * (1 / 64);
				var tv1 = (block.tlr >> 6) * (1 / 64);
				var tu2 = (block.tu & 63) * (1 / 64);
				var tv2 = (block.tu >> 6) * (1 / 64);
				var tu3 = (block.td & 63) * (1 / 64);
				var tv3 = (block.td >> 6) * (1 / 64);

				for( i in 0...block.modelSize ) {
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + x);		bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + y);		bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + z);		bufferPos += 4;
					var t = models.getFloat(model++);
					var tu, tv;
					var it = Std.int(t);
					t -= it;
					if( it == 0 ) {
						tu = tu1;
						tv = tv1;
					} else if( it == 1 ) {
						tu = tu2;
						tv = tv2;
					} else {
						tu = tu3;
						tv = tv3;
					}
					flash.Memory.setFloat(bufferPos, t + tu);	bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tv);	bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) * shade);	bufferPos += 4;
				}
				
			} else {
				var tu = (block.tlr & 63) * (1 / 64);
				var tv = (block.tlr >> 6) * (1 / 64);
				for( i in 0...block.modelSize ) {
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + x);		bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + y);		bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + z);		bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tu);	bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tv);	bufferPos += 4;
					flash.Memory.setFloat(bufferPos, models.getFloat(model++) * shade);	bufferPos += 4;
				}
			}
		case BTReduced:
			var pos = block.modelPos;
			var x1 = models.getFloat(pos++);
			var y1 = models.getFloat(pos++);
			var z1 = models.getFloat(pos++);
			var x2 = models.getFloat(pos++);
			var y2 = models.getFloat(pos++);
			var z2 = models.getFloat(pos++);
			addBufferCustomQuad(block.tu, block.shadeUp * shade, x+x1, y+y1, z+z2, x2-x1, y2-y1, 0, true);
			addBufferCustomQuad(block.tlr, block.shadeX * shade, x+x1, y+y1, z+z1, 0, y2-y1, z2-z1, false);
			addBufferCustomQuad(block.tlr, block.shadeY * shade, x+x1, y+y1, z+z1, x2-x1, 0, z2-z1, false);
			addBufferCustomQuad(block.tlr, block.shadeX * shade, x+x2, y+y1, z+z1, 0, y2-y1, z2-z1, true);
			addBufferCustomQuad(block.tlr, block.shadeY * shade, x+x1, y+y2, z+z1, x2-x1, 0, z2-z1, true);
			addBufferCustomQuad(block.td, block.shadeDown * shade, x+x1, y+y1, z+z1, x2-x1, y2-y1, 0, false);
		case BTSprite:
			
			addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 0, 0);
			addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 1, 0);
			addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 0, 1);
			addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 1, 1);
			
		case BTExtended:
			addBufferQuad(block.tu & 0xFFF, block.shadeUp * shade, x, y, z+1, 1, 1, 0, true);
			addBufferQuad(block.tlr & 0xFFF, block.shadeX * shade, x, y, z, 0, 1, 1, false);
			addBufferQuad(block.tu >> 12, block.shadeY * shade, x, y, z, 1, 0, 1, false);
			addBufferQuad(block.tlr >> 12, block.shadeX * shade, x+1, y, z, 0, 1, 1, true);
			addBufferQuad(block.td >> 12, block.shadeY * shade, x, y+1, z, 1, 0, 1, true);
			addBufferQuad(block.td & 0xFFF, block.shadeDown * shade, x, y, z, 1, 1, 0, false);
			
		default:
			addBufferQuad(block.tu, block.shadeUp * shade, x, y, z+1, 1, 1, 0, true);
			addBufferQuad(block.tlr, block.shadeX * shade, x, y, z, 0, 1, 1, false);
			addBufferQuad(block.tlr, block.shadeY * shade, x, y, z, 1, 0, 1, false);
			addBufferQuad(block.tlr, block.shadeX * shade, x+1, y, z, 0, 1, 1, true);
			addBufferQuad(block.tlr, block.shadeY * shade, x, y+1, z, 1, 0, 1, true);
			addBufferQuad(block.td, block.shadeDown * shade, x, y, z, 1, 1, 0, false);
		}
	}
	

	function makeVertexes( c : CellBuffer, zMax ) {
		var blocks = blocks;
		var blockInfos = blockInfos;
		var tagBits = 0;

		zMax++;
		this.deltaX = (c.x - 1) << CELL;
		this.deltaY = (c.y - 1) << CELL;
		this.bufferPos = tmp.getPos();

		for( cy in 0...CSIZE )
			for( cx in 0...CSIZE ) {
				var x = cx + CSIZE;
				var y = cy + CSIZE;
				var p = addr(x, y, 0);
				var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

				for( z in 0...zMax ) {
					var bt = tags.getByte(p) & TAGMASK;
					if( bt == 0 ) {
						p += DZ;
						continue;
					}
					if( bt != Type.enumIndex(BTFull) ) {
						tagBits |= 1 << bt;
						p += DZ;
						continue;
					}
					var kind = blocks.getUI16(p + pdelta);
					var block = blockInfos.get(kind);
					// z-top
					if( isTransparent(p + DZ) )
						addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
					// left
					if( isTransparent(p - DX) )
						addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
					// up
					if( isTransparent(p - DY) )
						addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
					// right
					if( isTransparent(p + DX) )
						addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
					// down
					if( isTransparent(p + DY) )
						addQuad(p, block.tlr, block.shadeY, x, y+1, z, 1, 0, 1, true);
					// z-bottom
					if( z > 0 && isTransparent(p - DZ) )
						addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
					p += DZ;
				}
			}

		for( tagGroup in [[BTFull,BTReduced,BTExtended], [BTTransp,BTModel,BTModelMultiTex], [BTModel2Side], [BTSprite], [BTAlpha], [BTWater]] ) {

			for( tag in tagGroup ) {

				var itag = Type.enumIndex(tag);
				if( tagBits & (1 << itag) == 0 )
					continue;

				switch( tag ) {
				case BTModel, BTModel2Side:
					var first = true;
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;
							var dx : Float = x + deltaX;
							var dy : Float = y + deltaY;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								var model = block.modelPos;
								var tu = (block.tlr & 63) * (1 / 64);
								var tv = (block.tlr >> 6) * (1 / 64);
								var shade = getLight(p) * (1 / LBASE);

								for( i in 0...block.modelSize ) {
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dx);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dy);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + z);		bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tu);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tv);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) * shade);	bufferPos += 4;
								}
								p += DZ;
							}
						}
					continue;
				case BTModelMultiTex:
					var first = true;
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;
							var dx : Float = x + deltaX;
							var dy : Float = y + deltaY;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								var model = block.modelPos;
								var tu1 = (block.tlr & 63) * (1 / 64);
								var tv1 = (block.tlr >> 6) * (1 / 64);
								var tu2 = (block.tu & 63) * (1 / 64);
								var tv2 = (block.tu >> 6) * (1 / 64);
								var tu3 = (block.td & 63) * (1 / 64);
								var tv3 = (block.td >> 6) * (1 / 64);
								var shade = getLight(p) * (1 / LBASE);

								for( i in 0...block.modelSize ) {
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dx);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + dy);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + z);		bufferPos += 4;
									var t = models.getFloat(model++);
									var tu, tv;
									var it = Std.int(t);
									t -= it;
									if( it == 0 ) {
										tu = tu1;
										tv = tv1;
									} else if( it == 1 ) {
										tu = tu2;
										tv = tv2;
									} else {
										tu = tu3;
										tv = tv3;
									}
									flash.Memory.setFloat(bufferPos, t + tu);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) + tv);	bufferPos += 4;
									flash.Memory.setFloat(bufferPos, models.getFloat(model++) * shade);	bufferPos += 4;
								}
								p += DZ;
							}
						}
					continue;
				case BTAlpha:
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								// z-top
								if( isTransparentNot(p + DZ, BTAlpha) )
									addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								// left
								if( isTransparentNot(p - DX,BTAlpha) )
									addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
								// up
								if( isTransparentNot(p - DY,BTAlpha) )
									addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
								// right
								if( isTransparentNot(p + DX,BTAlpha) )
									addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
								// down
								if( isTransparentNot(p + DY,BTAlpha) )
									addQuad(p, block.tlr, block.shadeY, x, y+1, z, 1, 0, 1, true);
								// z-bottom
								if( z > 0 && isTransparentNot(p - DZ, BTAlpha) )
									addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
								p += DZ;
							}
						}
					continue;
				case BTWater:
					var anim = game.planet.animWater != null;
					var waterLevel = game.planet.waterLevel;
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								// z-top
								if( anim && z == waterLevel ) {
									if( isNotWater(p+DZ) )
										addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								} else {
									if( isTransparentNot(p + DZ,BTWater) )
										addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								}
								// left
								if( isTransparentNot(p - DX,BTWater) )
									addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
								// up
								if( isTransparentNot(p - DY,BTWater) )
									addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
								// right
								if( isTransparentNot(p + DX,BTWater) )
									addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
								// down
								if( isTransparentNot(p + DY,BTWater) )
									addQuad(p, block.tlr, block.shadeY, x, y + 1, z, 1, 0, 1, true);
								// bottom
								if( isTransparentNot(p - DZ,BTWater) )
									addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
								p += DZ;
							}
						}
					continue;
				case BTReduced:
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								var pos = block.modelPos;
								var x1 = models.getFloat(pos++);
								var y1 = models.getFloat(pos++);
								var z1 = models.getFloat(pos++);
								var x2 = models.getFloat(pos++);
								var y2 = models.getFloat(pos++);
								var z2 = models.getFloat(pos++);
								// z-top
								if( z2 < 1 || isTransparent(p + DZ) )
									addCustomQuad(p, block.tu, block.shadeUp, x + x1, y + y1, z + z2, 1, 1, 0, x2 - x1, y2 - y1, 0, true);
								// left
								if( x1 > 0 || isTransparent(p - DX) )
									addCustomQuad(p, block.tlr, block.shadeX, x + x1, y + y1, z + z1, 0, 1, 1, 0, y2 - y1, z2 - z1, false);
								// up
								if( y1 > 0 || isTransparent(p - DY) )
									addCustomQuad(p, block.tlr, block.shadeY, x + x1, y + y1, z + z1, 1, 0, 1, x2 - x1, 0, z2 - z1, false);
								// right
								if( x2 < 1 || isTransparent(p + DX) )
									addCustomQuad(p, block.tlr, block.shadeX, x + x2, y + y1, z + z1, 0, 1, 1, 0, y2 - y1, z2 - z1, true);
								// down
								if( y2 < 1 || isTransparent(p + DY) )
									addCustomQuad(p, block.tlr, block.shadeY, x + x1, y + y2, z + z1, 1, 0, 1, x2 - x1, 0, z2 - z1, true);
								// z-bottom
								if( z1 > 0 || isTransparent(p - DZ) )
									addCustomQuad(p, block.td, block.shadeDown, x + x1, y + y1, z + z1, 1, 1, 0, x2 - x1, y2 - y1, 0, false);
								p += DZ;
							}
						}
					continue;
				case BTExtended:
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								// z-top
								if( isTransparent(p + DZ) )
									addQuad(p, block.tu & 0xFFF, block.shadeUp, x, y, z+1, 1, 1, 0, true);
								// left
								if( isTransparent(p - DX) )
									addQuad(p, block.tlr & 0xFFF, block.shadeX, x, y, z, 0, 1, 1, false);
								// up
								if( isTransparent(p - DY) )
									addQuad(p, block.tu >> 12, block.shadeY, x, y, z, 1, 0, 1, false);
								// right
								if( isTransparent(p + DX) )
									addQuad(p, block.tlr >> 12, block.shadeX, x+1, y, z, 0, 1, 1, true);
								// down
								if( isTransparent(p + DY) )
									addQuad(p, block.td >> 12, block.shadeY, x, y+1, z, 1, 0, 1, true);
								// z-bottom
								if( z > 0 && isTransparent(p - DZ) )
									addQuad(p, block.td & 0xFFF, block.shadeDown, x, y, z, 1, 1, 0, false);
								p += DZ;
							}
						}
					continue;
				case BTSprite:
					for( cy in 0...CSIZE )
						for( cx in 0...CSIZE ) {
							var x = cx + CSIZE;
							var y = cy + CSIZE;
							var p = addr(x, y, 0);
							var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

							for( z in 0...zMax ) {
								var bt = tags.getByte(p) & TAGMASK;
								if( bt != itag ) {
									p += DZ;
									continue;
								}
								var kind = blocks.getUI16(p + pdelta);
								var block = blockInfos.get(kind);
								var shade = getLight(p) * (1 / LBASE);
								
								addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 0, 0);
								addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 1, 0);
								addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 0, 1);
								addVertex(block.tlr, shade, x + 0.5, y + 0.5, z + 0.5, 1, 1);
								
								p += DZ;
							}
						}
					continue;
				default:
				}

				for( cy in 0...CSIZE )
					for( cx in 0...CSIZE ) {
						var x = cx + CSIZE;
						var y = cy + CSIZE;
						var p = addr(x, y, 0);
						var pdelta = ((cx << Const.ZBITS) | (cy << (Const.ZBITS + CELL))) - p;

						for( z in 0...zMax ) {
							var bt = tags.getByte(p) & TAGMASK;
							if( bt != itag ) {
								p += DZ;
								continue;
							}
							var kind = blocks.getUI16(p + pdelta);
							var block = blockInfos.get(kind);
							// z-top
							if( isTransparent(p + DZ) )
								addQuad(p, block.tu, block.shadeUp, x, y, z+1, 1, 1, 0, true);
							// left
							if( isTransparent(p - DX) )
								addQuad(p, block.tlr, block.shadeX, x, y, z, 0, 1, 1, false);
							// up
							if( isTransparent(p - DY) )
								addQuad(p, block.tlr, block.shadeY, x, y, z, 1, 0, 1, false);
							// right
							if( isTransparent(p + DX) )
								addQuad(p, block.tlr, block.shadeX, x+1, y, z, 0, 1, 1, true);
							// down
							if( isTransparent(p + DY) )
								addQuad(p, block.tlr, block.shadeY, x, y+1, z, 1, 0, 1, true);
							// z-bottom
							if( z > 0 && isTransparent(p - DZ) )
								addQuad(p, block.td, block.shadeDown, x, y, z, 1, 1, 0, false);
							p += DZ;
						}
					}
			}

			var b = allocBuffer();
			if( b != null )
				c.buffers[Type.enumIndex(tagGroup[0])] = b;
			bufferPos = tmp.getPos();
		}
	}

	public function rebuild( c : CellBuffer ) {
		manager.select();
		
		// check if all necessary cells are available
		var lcells = c.level.level.cells;
		for( dx in -1...2 )
			for( dy in -1...2 ) {
				var c = lcells[ (level.real(c.x + dx) << CELL) >> Const.BITS ][ (level.real(c.y + dy) << CELL) >> Const.BITS ];
				if( c.t == null ) {
					if( dx == 0 && dy == 0 )
						return false;
				} else if( c.tags == null )
					computeTags(c);
			}

		// copy tags from level cell to our manager memory
		var levelTags = levelTags;
		var tags = tags;
		var lightpos = 0;
		var lighttag = Type.enumIndex(BFLight(0));
		var zMax = 0;
		for( dx in 0...3 )
			for( dy in 0...3 ) {
				var cx = level.real(c.x + dx - 1);
				var cy = level.real(c.y + dy - 1);
				var lc = lcells[cx >> (Const.BITS - CELL)][cy >> (Const.BITS - CELL)];
				if( lc.t == null ) {
					var write = tags.getPos() + addr(dx << CELL, dy << CELL, 0);
					for( p in 0...(CSIZE * Const.ZSIZE * CSIZE) >> 2 )
						flash.Memory.setI32(p<<2, TAG_NOLIGHT | (TAG_NOLIGHT << 8) | (TAG_NOLIGHT << 16) | (TAG_NOLIGHT << 24));
					continue;
				}
				// write lights in current coordinates
				if( lc.specials.length > 0 ) {
					var i = lightpos;
					var max = i + lc.specials.length;
					manager.bytes.position = i + lights.getPos();
					manager.bytes.writeBytes(lc.specials);
					// we might have overwritten tags
					if( max - lights.getPos() >= (MAX_LIGHTS - 1) * 4 )
						currentTags = null;
					var lx = (lc.x << Const.BITS) - (cx << CELL);
					var ly = (lc.y << Const.BITS) - (cy << CELL);
					var curBlocks = lc.t;
					while( i < max ) {
						var x = lights.getByte(i++) + lx;
						var y = lights.getByte(i++) + ly;
						var z = lights.getByte(i++);
						var b = lights.getByte(i++);
						if( b != lighttag || (x|y)>>>CELL != 0 ) continue;
						lights.setByte(lightpos++, x + (dx << CELL));
						lights.setByte(lightpos++, y + (dy << CELL));
						lights.setByte(lightpos++, z);
						var addr = Const.addr(x - lx, y - ly, z) << 1;
						var bid = curBlocks[addr] | (curBlocks[addr + 1] << 8);
						lights.setByte(lightpos++, blockInfos.get(bid).lightIndex);
					}
				}
				if( lc != currentTags ) {
					currentTags = lc;
					manager.copy(lc.tags, 0, levelTags, Const.TSIZE);
				}
				if( lc.zMax > zMax )
					zMax = lc.zMax;
				var read = levelTags.getPos() + (((cx<<CELL)&Const.MASK)<<Const.X) + (((cy<<CELL)&Const.MASK)<<Const.Y);
				var write = tags.getPos() + addr(dx<<CELL,dy<<CELL,0);
				for( y in 0...CSIZE ) {
					var read = read + (y << Const.Y);
					var write = write + (y << Y);
					for( p in 0...(CSIZE * Const.ZSIZE) >> 2 ) {
						flash.Memory.setI32(write, flash.Memory.getI32(read));
						read += 4;
						write += 4;
					}
				}
			}
		
		// mark end of list of specials
		if( lightpos >= MAX_LIGHTS * 4 ) lightpos = (MAX_LIGHTS - 1) * 4;
		lights.setByte(lightpos++, 0xFF);

		// copy blocks from level cell to our manager memory
		var curCell = lcells[c.x >> (Const.BITS - CELL)][c.y >> (Const.BITS - CELL)];
		var cellX = (c.x << CELL) & Const.MASK;
		var cellY = (c.y << CELL) & Const.MASK;
		manager.bytes.position = blocks.getPos();
		for( y in 0...CSIZE ) {
			var read = (cellX << Const.X) | ((cellY + y) << Const.Y);
			manager.bytes.writeBytes(curCell.t, read<<1, CSIZE * Const.ZSIZE * 2);
		}

		// relight our buffer
		var b = game.planet.biome;
		relight(b.sunPower, b.sunFalloff == null ? 1 : b.sunFalloff, zMax);
		
		// copy back light information
		for( y in 0...CSIZE ) {
			curCell.light.position = (cellX << Const.X) | ((cellY +y) << Const.Y);
			curCell.light.writeBytes(manager.bytes, addr(CSIZE, y + CSIZE, 0), CSIZE * Const.ZSIZE);
		}
			
		c.dispose();

		// build vertexes
		makeVertexes(c, zMax);

		// done
		c.dirty = false;
		return true;
	}

}