import Common;

class Block {

	public var index : Int;
	public var k : BlockKind;
	public var tu(default,setU) : Texture;
	public var td(default,setD) : Texture;
	public var tlr(default,setLR) : Texture;
	public var addrU(default,null) : Int;
	public var addrD(default,null) : Int;
	public var addrLR(default,null) : Int;
	public var shadeX : Int;
	public var shadeY : Int;
	public var shadeUp : Int;
	public var shadeDown : Int;
	public var parent : Block;
	public var isSpecial : Bool;


	public var fshadeX : Float;
	public var fshadeY : Float;
	public var fshadeUp : Float;
	public var fshadeDown : Float;
	
	public function new(k) {
		this.k = k;
		parent = this;
	}

	function setU(t) {
		tu = t;
		addrU = t.address;
		return t;
	}

	function setD(t) {
		td = t;
		addrD = t.address;
		return t;
	}

	function setLR(t) {
		tlr = t;
		addrLR = t.address;
		return t;
	}

	public function shade( v : Float ) {
		shadeX = shadeY = shadeUp = shadeDown = Std.int(v * 256);
	}

	public function clone(index) {
		var b = new Block(k);
		b.index = index;
		b.tu = tu;
		b.td = td;
		b.tlr = tlr;
		b.shadeX = shadeX;
		b.shadeY = shadeY;
		b.shadeUp = shadeUp;
		b.shadeDown = shadeDown;
		b.parent = this;
		return b;
	}

}

class Texture {

	public var address : Int;
	public var bmp : flash.display.BitmapData;
	public var scroll : Int;
	public var scrollVert : Bool;
	public var speed : Int;
	public var isEmpty : Bool;
	public var index : Int;
	public var isTransparent : Bool;
	public var block : Block;

	public function new(i, a, b) {
		index = i;
		address = a;
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

class Level {

	public static inline var X = 0;
	public static inline var Y = GameConst.XYBITS;
	public static inline var Z = GameConst.XYBITS + GameConst.XYBITS;
	public static inline var XYSIZE = 1 << GameConst.XYBITS;
	public static inline var ZSIZE = 1 << GameConst.ZBITS;

	public static inline var TBITS = 4;
	public static inline var TSIZE = (1 << TBITS);
	public static inline var TMASK = TSIZE - 1;

	public static var FORCE : Null<Int> = null;

	public var t : flash.utils.ByteArray;
	public var tbytes : flash.utils.ByteArray;
	public var blocks : flash.Vector<Block>;
	var textures : Hash<Texture>;
	var bdelta : Int;
	var lastScrollTime : Float;
	public var allTextures : Array<Texture>;
	public var bselect : Block;
	public var sign : Int;

	public function new() {
		tbytes = new flash.utils.ByteArray();
		blocks = new flash.Vector();
		blocks.push(null);
		allTextures = new Array();
		lastScrollTime = 0.0;
		textures = new Hash();
		for( c in Type.getEnumConstructs(BlockKind) ) {
			var k = Reflect.field(BlockKind,c);
			var b = new Block(k);
			b.index = blocks.length;
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
			b.shadeX = shade(0.8);
			b.shadeY = shade(0.68);
			b.shadeUp = shade(1.0);
			b.shadeDown = shade(0.5);
			blocks.push(b);
		}
		// finish
		bdelta = blocks.length - 1;
		for( i in 1...Std.int(blocks.length) ) {
			var b = blocks[i].clone(blocks.length);
			b.shadeUp = shade(0.7);
			b.shadeX = shade(0.7);
			b.shadeY = shade(0.7);
			blocks.push(b);
		}
		bselect = blocks[1].clone(blocks.length);
		blocks.push(bselect);
		flash.Memory.select(tbytes);
		var t = haxe.Timer.stamp();
		var sign = 0;
		for( i in 0...Std.int(tbytes.length) ) {
			var c = flash.Memory.getByte(i);
			sign ^= c << (i & 15);
		}
		this.sign = sign;
		setup();
	}

	function setup() {
		getBlock(BClouds1).shade(1.0);
		getShadeBlock(BClouds1).shade(1.0);
		getBlock(BClouds2).shade(1.0);
		getShadeBlock(BClouds2).shade(1.0);
		getBlock(BWater).shade(1.0);
		load(__unprotect__("BLava")).speed = 28;
		load(__unprotect__("BWater")).speed = 48;
		getBlock(BGold).shade(0.95);
		for( k in [BFog,BShade,BLight] ) {
			var b = getShadeBlock(k);
			b.shadeUp = b.parent.shadeUp = shade((k == BShade) ? 0.6 : 1.0);
			b.shadeX = b.parent.shadeX = shade(0.7);
			b.shadeY = b.parent.shadeY = shade(0.5);
			b.shadeDown = b.parent.shadeDown = shade(0.3);
		}
		for( k in [BAmethyste,BEmeraude,BRubis,BSaphir] ) {
			var b = getShadeBlock(k);
			b.shadeUp = shade(0.95);
			b.shadeX = shade(0.75);
			b.shadeY = shade(0.55);
			b.shadeDown = shade(0.45);
			b = b.parent;
			b.shadeUp = shade(1.0);
			b.shadeX = shade(0.8);
			b.shadeY = shade(0.6);
			b.shadeDown = shade(0.5);
		}
		for( b in blocks ) {
			if( b == null ) continue;
			b.fshadeUp = b.shadeUp / 256.0;
			b.fshadeDown = b.shadeDown / 256.0;
			b.fshadeX = b.shadeX / 256.0;
			b.fshadeY = b.shadeY / 256.0;
		}
		var abit = 0;
		for( k in [BInvisible,BAmethyste,BEmeraude,BRubis,BSaphir,BFog,BShade,BLight] ) {
			var b = getBlock(k);
			if( k != BInvisible ) {
				for( b in [b, getShadeBlock(k)] )
					b.isSpecial = true;
					switch(k) {
					case BAmethyste, BEmeraude, BRubis:
						b.fshadeX *= 8;
						b.fshadeY *= 8;
						b.fshadeDown *= 8;
						b.fshadeUp *= 8;
					case BSaphir:
						b.fshadeX *= 6;
						b.fshadeY *= 6;
						b.fshadeDown *= 6;
						b.fshadeUp *= 6;
					case BLight:
						b.fshadeX *= 5;
						b.fshadeY *= 5;
						b.fshadeDown *= 5;
						b.fshadeUp *= 5;
					default:
					}
			}
			setAlpha(b.tu, 1 << (abit++));
		}
	}

	inline function shade( k : Float ) {
		return Std.int(k * 256);
	}

	public function forceScroll() {
		for( t in textures )
			t.scroll = -1;
		lastScrollTime = -1;
	}

	function setAlpha( t : Texture, a : Int ) {
		var k = t.address;
		for( b in 0...TSIZE*TSIZE ) {
			flash.Memory.setByte(k,a);
			k += 4;
		}
	}

	public function updateTextures() {
		var time = flash.Lib.getTimer() / 1000.0;
		// 4 FPS
		if( time - lastScrollTime < 0.250 )
			return false;
		var move = false;
		for( t in textures ) {
			if( t.speed == 0 ) continue;
			var old = t.scroll;
			t.scroll = Std.int(t.speed * time / TSIZE) & TMASK;
			if( t.scroll == old ) continue;
			var k = t.address;
			for( b in 0...TSIZE*TSIZE ) {
				var col = if( t.scrollVert ) t.bmp.getPixel32((b+t.scroll) & TMASK,(b >> TBITS)&TMASK) else t.bmp.getPixel32(b & TMASK,(t.scroll + (b>> TBITS))&TMASK);
				flash.Memory.setByte(k++,(col>>>24)&0xFF);
				flash.Memory.setByte(k++,(col>>16)&0xFF);
				flash.Memory.setByte(k++,(col>>8)&0xFF);
				flash.Memory.setByte(k++,col&0xFF);
			}
			move = true;
			lastScrollTime = time;
		}
		return move;
	}

	public function getBlock(k) {
		for( b in blocks ) {
			if( b == null ) continue;
			if( b.k == k )
				return b;
		}
		return null;
	}

	public function getShadeBlock(k) {
		var shade = false;
		for( b in blocks ) {
			if( b == null ) continue;
			if( b.k == k ) {
				if( shade )
					return b;
				shade = true;
			}
		}
		return null;
	}

	function load( name : String ) {
		var t = textures.get(name);
		if( t != null )
			return t;
		var bmp : flash.display.BitmapData;
		if( name == __unprotect__("red") ) {
			bmp = new flash.display.BitmapData(TSIZE,TSIZE,true,0xFFFF0000);
			name = null;
		} else {
			var cl = Type.resolveClass(name);
			if( cl == null )
				return null;
			bmp = Type.createInstance(cl,[null,null]);
			// rotate 180 degrees
			var tmp = new flash.display.Bitmap(bmp.clone());
			var mat = new flash.geom.Matrix();
			mat.rotate(Math.PI);
			mat.translate(bmp.width,bmp.height);
			bmp.fillRect(bmp.rect,0);
			bmp.draw(tmp,mat);
			tmp.bitmapData.dispose();
		}
		t = new Texture(allTextures.length, tbytes.position, bmp);
		var bytes = bmp.getPixels(bmp.rect);
		tbytes.writeBytes(bytes);
		if( name != null ) textures.set(name,t);
		allTextures.push(t);
		return t;
	}

	public inline function addr(x,y,z) {
		return (x<<X)|(y<<Y)|(z<<Z);
	}

	public inline function outside(x,y,z) {
		return (x|y|(z<<(GameConst.XYBITS-GameConst.ZBITS))) >>> GameConst.XYBITS != 0;
	}

	public inline function has(x,y,z) {
		return !outside(x,y,z) && t[addr(x,y,z)] != 0;
	}

	public function get( x : Int, y : Int, z : Int ) {
		var b = blocks[t[addr(x,y,z)]];
		return b == null ? null : b.k;
	}

	public function getOpt(x,y,z) {
		return outside(x,y,z) ? null : get(x,y,z);
	}

	public function set( level : Int, x : Int, y : Int, z : Int, b : Block ) {
		var pos = addr(x,y,z);
		t[pos] = if( b == null ) 0 else Type.enumIndex(b.k) + 1;
		pos += level;
		if( b == null )
			flash.Memory.setByte(pos,0);
		else {
			var index = if( b.index > bdelta && b != bselect ) b.index - bdelta else b.index;
			flash.Memory.setByte(pos,index);
		}
		updateShade(level,x,y);
	}

	function updateShade(level,x,y) {
		var z = ZSIZE - 1;
		var pos = level + addr(x,y,ZSIZE-1);
		// skip blanks
		while( true ) {
			pos -= 1 << Z;
			z--;
			if( z < 0 ) return;
			var b = flash.Memory.getByte(pos);
			if( b > 0 ) break;
		}
		// unshade continuous blocks
		while( true ) {
			var b = flash.Memory.getByte(pos);
			if( b == 0 ) break;
			if( b > bdelta && b != bselect.index )
				flash.Memory.setByte(pos,b - bdelta);
			pos -= 1 << Z;
			z--;
			if( z < 0 ) return;
		}
		// shade blocks
		while( true ) {
			pos -= 1 << Z;
			z--;
			if( z < 0 ) return;
			var b = flash.Memory.getByte(pos);
			if( b > 0 && b < bdelta )
				flash.Memory.setByte(pos,b + bdelta);
		}
	}

	public function init( level : flash.Vector<BlockKind> ) {
		var t = new flash.utils.ByteArray();
		t.length = XYSIZE * XYSIZE * ZSIZE;
		flash.Memory.select(t);
		this.t = t;
		var p = 0;
		for( z in 0...ZSIZE )
			for( y in 0...XYSIZE )
				for( x in 0...XYSIZE ) {
					var b = level[p];
					flash.Memory.setByte(p,if( b == null ) 0 else (Type.enumIndex(b) + 1));
					p++;
				}
	}

	public function updateShades( lvl : Int ) {
		for( y in 0...XYSIZE )
			for( x in 0...XYSIZE )
				updateShade(lvl,x,y);
	}

	public function isSoil( k : BlockKind ) {
		return switch( k ) {
			case BFixed, BSoilTree, BAutumnTree, BHighTree, BClouds, BSphereTree, BLargeTree,
				BSnowSapin, BJungle, BCaverns, BField, BSwamp, BSoilPeaks, BSoilPeaks1, BPilarPlain, BPilarPlain1, BFlowerPlain, BSavana, BDesert, BLava:
				true;
			default:
				false;
		};
	}

}