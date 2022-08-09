import Common;


class Block {

	public var index : Int;
	public var type : BlockType;
	public var special : BlockSpecial;
	
	public var k : BlockKind;
	public var tu(default,setU) : Texture;
	public var td(default,setD) : Texture;
	public var tlr(default,setLR) : Texture;

	public var shadeX : Float;
	public var shadeY : Float;
	public var shadeUp : Float;
	public var shadeDown : Float;
	
	public var collide : Bool;
	public var requiredPower : Int;
	public var model : Array<Float>;
	
	public function new(k) {
		this.k = k;
		collide = true;
		special = BSNone;
		requiredPower = 40;
	}
	
	public function init() {
		if( type == null )
			type = tu.isTransparent || td.isTransparent || tlr.isTransparent ? BTTransp : BTFull;
	}

	function setU(t) {
		tu = t;
		return t;
	}

	function setD(t) {
		td = t;
		return t;
	}

	function setLR(t) {
		tlr = t;
		return t;
	}

	public function shade( v : Float ) {
		shadeX = shadeY = shadeUp = shadeDown = v;
	}

}

class Texture {

	public var bmp : flash.display.BitmapData;
	public var isEmpty : Bool;
	public var index : Int;
	public var isTransparent : Bool;
	public var block : Block;

	public function new(i, b) {
		index = i;
		bmp = b;
		checkTransp();
		checkEmpty();
	}
	
	function checkEmpty() {
		for( x in 0...bmp.width )
			for( y in 0...bmp.height )
				if( bmp.getPixel32(x, y) != 0 )
					return;
		isEmpty = true;
	}
	
	function checkTransp() {
		for( x in 0...bmp.width )
			for( y in 0...bmp.height )
				if( bmp.getPixel32(x, y) >>> 24 != 0xFF ) {
					isTransparent = true;
					return;
				}
	}

}

class LevelCell {
	
	public var x : Int;
	public var y : Int;
	public var t : flash.utils.ByteArray;
	public var tags : flash.utils.ByteArray;
	public var specials : flash.utils.ByteArray;
	
	public function new(x, y) {
		this.x = x;
		this.y = y;
	}
	
}

class Level {
	
	static inline var TEX_BITS = 4;
	public static inline var TEX_SIZE = (1 << TEX_BITS);

	public var cells : Array<Array<LevelCell>>;
	public var blocks : flash.Vector<Block>;
	var textures : Hash<Texture>;
	var lastScrollTime : Float;
	public var allTextures : Array<Texture>;

	public function new(size) {
		blocks = new flash.Vector();
		blocks.push(null);
		cells = new Array();
		for( x in 0...size ) {
			cells[x] = [];
			for( y in 0...size )
				cells[x][y] = new LevelCell(x, y);
		}
		allTextures = new Array();
		lastScrollTime = 0.0;
		textures = new Hash();
		for( c in Type.getEnumConstructs(BlockKind) ) {
			var k = Reflect.field(BlockKind,c);
			var b = new Block(k);
			var t = load(c);
			if( t == null )
				t = load(__unprotect__("red"));
			t.block = b;
			b.tlr = b.tu = b.td = t;
			t = load(__unprotect__("ud")+"."+c);
			if( t != null ) b.tu = b.td = t;
			t = load(__unprotect__("lr")+"."+c);
			if( t != null ) b.tlr = t;
			t = load(__unprotect__("u")+"."+c);
			if( t != null ) b.tu = t;
			t = load(__unprotect__("d")+"."+c);
			if( t != null ) b.td = t;
			b.shadeX = 0.8;
			b.shadeY = 0.68;
			b.shadeUp = 1.0;
			b.shadeDown = 0.5;
			blocks.push(b);
		}
		setup();
		for( i in 1...blocks.length ) {
			var b = blocks[i];
			b.index = i;
			b.init();
		}
	}

	function setup() {
		getBlock(BClouds1).shade(1.0);
		getBlock(BClouds2).shade(1.0);
		getBlock(BWater).shade(1.0);
		getBlock(BGold).shade(0.95);
		for( k in [BFog, BShade, BLight] ) {
			var b = getBlock(k);
			b.shadeUp = (k == BShade) ? 0.6 : 1.0;
			b.shadeX = 0.7;
			b.shadeY = 0.5;
			b.shadeDown = 0.3;
		}
		for( k in [BAmethyste,BEmeraude,BRubis,BSaphir] ) {
			var b = getBlock(k);
			b.shadeUp = 1.0;
			b.shadeX = 0.8;
			b.shadeY = 0.6;
			b.shadeDown = 0.5;
		}
		var abit = 0;
		for( k in [BInvisible,BAmethyste,BEmeraude,BRubis,BSaphir,BFog,BShade,BLight] ) {
			var b = getBlock(k);
			if( k != BInvisible ) {
				b.type = BTAlpha;
				switch(k) {
				case BAmethyste, BEmeraude, BRubis:
					b.shadeX *= 8;
					b.shadeY *= 8;
					b.shadeDown *= 8;
					b.shadeUp *= 8;
				case BSaphir:
					b.shadeX *= 6;
					b.shadeY *= 6;
					b.shadeDown *= 6;
					b.shadeUp *= 6;
				case BLight:
					b.shadeX *= 5;
					b.shadeY *= 5;
					b.shadeDown *= 5;
					b.shadeUp *= 5;
				default:
				}
			}
		}
		
		getBlock(BLight).special = BSLight;
		
		var bw = getBlock(BWater);
		bw.tu.isTransparent = true;
		bw.type = BTWater;
		
		var old = bw.tu.bmp;
		var alpha = 0.9;
		var bmp = new flash.display.BitmapData(old.width, old.height, true, 0);
		bmp.copyPixels(old, old.rect, new flash.geom.Point(0, 0));
		bmp.colorTransform(bw.tu.bmp.rect, new flash.geom.ColorTransform(1, 1, 1, alpha));
		old.dispose();
		bw.shade(1 / alpha);
		bw.tu.bmp = bmp;
		
		var herbs = getBlock(BField2);
		herbs.collide = false;
		herbs.type = BTModel;
		var t = herbs.tlr.index;
		var tu = (t % 16) / 16;
		var tv2 = Std.int(t / 16) / 16;
		var tu2 = tu + 0.9999 / 16;
		var tv = tv2 + 0.9999 / 16;
		var z = 0.8;
		herbs.requiredPower = 20;
		herbs.model = [
			0.5, 0, 0, tu, tv, 1,
			0.5, 1, 0, tu2, tv, 1,
			0.5, 1, z, tu2, tv2, 1,
			
			0.5, 0, 0, tu, tv, 1,
			0.5, 1, z, tu2, tv2, 1,
			0.5, 0, z, tu, tv2, 1,

			0, 0.5, 0, tu, tv, 1,
			1, 0.5, 0, tu2, tv, 1,
			1, 0.5, z, tu2, tv2, 1,
			
			0, 0.5, 0, tu, tv, 1,
			1, 0.5, z, tu2, tv2, 1,
			0, 0.5, z, tu, tv2, 1,

			0.5, 0, 0, tu, tv, 1,
			0.5, 1, z, tu2, tv2, 1,
			0.5, 1, 0, tu2, tv, 1,
			
			0.5, 0, 0, tu, tv, 1,
			0.5, 0, z, tu, tv2, 1,
			0.5, 1, z, tu2, tv2, 1,

			0, 0.5, 0, tu, tv, 1,
			1, 0.5, z, tu2, tv2, 1,
			1, 0.5, 0, tu2, tv, 1,
			
			0, 0.5, 0, tu, tv, 1,
			0, 0.5, z, tu, tv2, 1,
			1, 0.5, z, tu2, tv2, 1,
		];
	}

	public function getBlock(k) {
		for( b in blocks ) {
			if( b == null ) continue;
			if( b.k == k )
				return b;
		}
		return null;
	}

	function load( name : String ) {
		var t = textures.get(name);
		if( t != null )
			return t;
		var bmp : flash.display.BitmapData;
		if( name == __unprotect__("red") ) {
			bmp = new flash.display.BitmapData(TEX_SIZE,TEX_SIZE,true,0xFFFF0000);
			name = null;
		} else {
			var cl = Type.resolveClass(name);
			if( cl == null )
				return null;
			bmp = Type.createInstance(cl,[null,null]);
		}
		t = new Texture(allTextures.length, bmp);
		if( name != null )
			textures.set(name,t);
		allTextures.push(t);
		return t;
	}

	public inline function has(x, y, z) {
		return getInt(x,y,z) > 0;
	}
	
	public function collide(x, y, z) {
		var b = getInt(x, y, z);
		return b == -1 || (b > 0 && blocks[b].collide);
	}
	
	public function get(x, y, z) {
		var i = getInt(x, y, z);
		return i <= 0 ? null : blocks[i].k;
	}
	
	function getInt(x, y, z) {
		var c = cells[x >> Const.BITS][y >> Const.BITS];
		if( c.t == null ) return -1;
		if( z & Const.ZMASK != z ) return 0;
		c.t.position = addr(x&Const.MASK,y&Const.MASK,z) << 1;
		return c.t.readUnsignedShort();
	}
	
	public function set(x, y, z, b:Block) {
		var c = cells[x >> Const.BITS][y >> Const.BITS];
		if( c.t == null ) throw "TODO";
		var a = addr(x & Const.MASK, y & Const.MASK, z);
		c.t.position = a << 1;
		c.t.writeShort( b == null ? 0 : b.index );
		if( c.tags != null ) {
			var old = c.tags[a] & Builder.TAGMASK;
			var tag = b == null ? 0 : Type.enumIndex(b.type);
			c.tags[a] = tag;
			if( b != null && b.special != BSNone ) {
				c.specials.writeByte(x);
				c.specials.writeByte(y);
				c.specials.writeByte(z);
				c.specials.writeByte(Type.enumIndex(b.special));
			} else if( b == null ) {
				var i = 0;
				var max : Int = c.specials.length;
				while( i < max ) {
					if( c.specials[i] == x && c.specials[i + 1] == y && c.specials[i + 2] == z ) {
						c.specials.position = i;
						c.specials.writeBytes(c.specials, i + 4);
						c.specials.length = max - 4;
						break;
					}
					i += 4;
				}
			}
		}
	}
		
	public function add(cx, cy, t) {
		cells[cx][cy].t = t;
		t.endian = flash.utils.Endian.LITTLE_ENDIAN;
	}
	
	inline function addr(x,y,z) {
		return (x<<Const.X)|(y<<Const.Y)|(z<<Const.Z);
	}

}