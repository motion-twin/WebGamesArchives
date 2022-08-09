import Common;

private typedef Table = #if flash flash.Vector<Block> #else Array<Block> #end;

enum BlockProp {
	PCanPick;
	PCollide;
	PRequireCharge;
	PLiquid;
	PLava;
	PTrack;
	PContainer;
}

class Block {

	public var index : Int;
	var name : String;
	public var type : BlockType;
	public var special : BlockFlag;
	public var flags : Array<BlockFlag>;

	public var k : BlockKind;
	public var tu : Int;
	public var td : Int;
	public var tlr : Int;

	public var shadeX : Float;
	public var shadeY : Float;
	public var shadeUp : Float;
	public var shadeDown : Float;

	public var props : haxe.EnumFlags<BlockProp>;

	public var covered : Block;
	public var uncover : Block;
	public var flip : Block;
	public var toggle : Block;
	public var propagate : Block;

	public var anchors : Int;
	public var magnets : Int;

	public var requiredPower : Null<Float>;
	public var model : BlockModel;
	public var weight : Float;
	public var charge : ChargeKind;

	public var activable : Where;
	public var quickBreaks : Array<{ c : ChargeKind, v : Float }>;
	public var matter : Block;

	public var size : { x1 : Float, y1 : Float, z1 : Float, x2 : Float, y2 : Float, z2 : Float };

	var drop : Block;
	public var dropCount : Int;

	#if flash
	public var renderTag : Int;
	#end

	public var collide(getCollide, never) : Bool;

	public function new(k) {
		this.k = k;
		props.init();
		props.set(PCanPick);
		props.set(PCollide);
		shadeX = 0.8;
		shadeY = 0.68;
		shadeUp = 1;
		shadeDown = 0.5;
		weight = 1;
		anchors = 0;
		magnets = 7;
		drop = this;
		dropCount = 1;
	}

	inline function getCollide() {
		return props.has(PCollide);
	}

	public function getMax(weight) {
		if( this.weight < 0 )
			return 0;
		if( this.weight == 0 )
			return weight;
		return Math.ceil(weight / this.weight);
	}

	public inline function hasProp(p) {
		return props.has(p);
	}

	public function hasFlag(f2) {
		for( f in flags )
			if( f == f2 )
				return true;
		return false;
	}

	public function getDropChance() { // 0-100
		for(f in flags)
			switch(f) {
				case BFDropChance(c) :
					return c;
				default :
			}
		return 100;
	}

	public function isTransparent() {
		return type != BTFull;
	}

	public function canOverride() {
		return hasFlag(BFDetail) || (hasProp(PLiquid) && !hasProp(PCanPick));
	}

	public inline function hasAnchor( a : BlockFace ) {
		return anchors & Type.enumIndex(a) != 0;
	}

	public inline function hasMagnet( a : BlockFace ) {
		return magnets & Type.enumIndex(a) != 0;
	}

	public inline function canPut( a : BlockFace ) {
		return (anchors | magnets) & Type.enumIndex(a) != 0;
	}

	public function isSame( b : Block ) {
		if( b == null ) return index == 0;
		return b == this || covered == b || uncover == b || flip == b || toggle == b;
	}

	public function toString() {
		return index + "#" + Std.string(k);
	}

	public function getMain() {
		if( uncover != null ) return uncover.getMain();
		if( flip != null && flip.index < index ) return flip.getMain();
		if( toggle != null && toggle.index < index ) return toggle.getMain();
		return this;
	}

	public function getDrop() {
		if( !hasProp(PCanPick) ) return null;
		if( uncover != null ) return uncover.getDrop();
		if( flip != null && flip.index < index ) return flip.getDrop();
		if( toggle != null && toggle.index < index ) return toggle.getDrop();
		if( drop == null ) return null;
		return { b : drop, count : dropCount };
	}

	public function getFlip( angle : Float ) {
		if( flip != null && Math.abs(Math.sin(angle)) > 0.5 )
			return flip;
		return this;
	}

	public function getHeight() {
		if( size != null )
			return size.z2;
		return 1;
	}

	public function getName() {
		var d = Names.NAMES[index];
		var n = d != null ? d.name : null;
		if( n == null || n == "" )
			n = this.name;
		if( n == null || n == "" ) {
			n = "#" + index;
			if( __unprotect__("mi") == "mi_" )
				n = Type.enumConstructor(k).substr(0, -1) + n;
		}
		return n;
	}


	// ------------------------ INIT --------------------------------------------------------------

	public static var all : Table = initBlocks();

	public static function get( b : BlockKind ) : Block return all[Type.enumIndex(b)]

	static function getTexture( b : Block, t : Array<Int> ) {
		if( t == null || t.length != 2 || (t[0] | t[1]) >>> 6 != 0 ) throw "Invalid tex " + Std.string(t) + " for " + b.k;
		return (t[1] << 6) | t[0];
	}

	static function initBlocks() {
		var blocks = new Table();
		for( c in Type.getEnumConstructs(BlockKind) ) {
			var k = Reflect.field(BlockKind,c);
			var b = new Block(k);
			b.index = Type.enumIndex(k);
			blocks.push(b);
		}
		all = blocks;
		for( c in Data.getAllCharges() )
			for( fx in c.effects )
				switch( fx ) {
				case CEFast(k, s):
					var b = get(k);
					if( b.quickBreaks == null ) b.quickBreaks = [];
					b.quickBreaks.push( { c : c.id, v : s } );
				case CECanBreak(k):
					var b = get(k);
					b.props.set(PRequireCharge);
					if( b.quickBreaks == null ) b.quickBreaks = [];
					b.quickBreaks.push( { c : c.id, v : 1. } );
				}
		var bdata = Data.getBlocksData();
		for( b in blocks ) {
			var d = bdata[b.index];
			if( d == null ) throw "Missing block #" + b.k + " (" + b.index + ")";
			b.type = d.type;
			b.flags = d.flags;
			if( d.name != "-" )
				b.name = d.name;
			if( b.quickBreaks != null )
				b.quickBreaks.sort(function(b1, b2) return b2.v == b1.v ? Type.enumIndex(b1.c) - Type.enumIndex(b2.c) : Reflect.compare(b2.v,b1.v));
			var tex = if( d.texture.length > 0 ) getTexture(b, d.texture) else 0xFFF;
			b.tlr = b.tu = b.td = tex;
			if( d.texUp.length > 0 )
				b.tu = getTexture(b,d.texUp);
			if( d.texDown.length > 0 )
				b.td = getTexture(b, d.texDown);
			if( d.shadeX != null )
				b.shadeX = d.shadeX;
			if( d.shadeY != null )
				b.shadeY = d.shadeY;
			if( d.shadeUp != null )
				b.shadeUp = d.shadeUp;
			if( d.shadeDown != null )
				b.shadeDown = d.shadeDown;
			if( d.power != null )
				b.requiredPower = d.power;
			if( d.weight != null )
				b.weight = d.weight;
			if( d.matter != null )
				b.matter = Block.get(d.matter);
			else
				b.matter = b;
			for( f in d.flags )
				switch( f ) {
				case BFNoCollide:
					b.props.unset(PCollide);
				case BFModel(m):
					b.model = m;
				case BFCoverable:
					var next = blocks[b.index + 1];
					b.covered = next;
					next.uncover = b;
				case BFLiquid:
					b.props.unset(PCollide);
					b.props.set(PLiquid);
				case BFNoPick:
					b.props.unset(PCanPick);
				case BFDetail:
					b.props.unset(PCollide);
					b.props.unset(PCanPick);
				case BFFlip:
					var b2 = blocks[b.index + 1];
					b.flip = b2;
					b2.flip = b;
				case BFNoDrop:
					b.drop = null;
				case BFDropChance(c):
					// nothing
				case BFNoShade:
					// nothing
				case BFCantPut:
					b.anchors = 0;
					b.magnets = 0;
				case BFLight(_):
					b.special = f;
				case BFAnchor(a):
					b.anchors |= Type.enumIndex(a);
				case BFMagnet(m):
					if( b.magnets == 7 ) b.magnets = 0;
					b.magnets |= Type.enumIndex(m);
				case BFDrop(bt, count):
					b.drop = blocks[Type.enumIndex(bt)];
					b.dropCount = count == null ? 1 : count;
				case BFCharge(c):
					b.charge = c;
				case BFSize(x, y, z, x2, y2, z2):
					b.size = { x1 : x, y1 : y, z1 : z, x2 : x2, y2 : y2, z2 : z2 };
				case BFToggle(k):
					var b2 = blocks[Type.enumIndex(k)];
					b.toggle = b2;
					b2.toggle = b;
				case BFTextures(tids):
					var front = tids.length == 0 ? b.tlr : getTexture(b, [tids.shift(),tids.shift()]);
					var back = tids.length == 0 ? b.tlr : getTexture(b, [tids.shift(),tids.shift()]);
					var left = tids.length == 0 ? b.tlr : getTexture(b, [tids.shift(),tids.shift()]);
					var right = tids.length == 0 ? b.tlr : getTexture(b, [tids.shift(), tids.shift()]);
					b.tlr = (front << 12) | back;
					b.tu = (left << 12) | b.tu;
					b.td = (right << 12) | b.td;
				case BFActivable(w):
					b.activable = w;
				case BFTransform(_):
					b.drop = null;
				case BFPropagate(k):
					b.propagate = Block.get(k);
				case BFFallCopy:
					if( b.propagate == null ) b.propagate = b;
				case BFIsLava:
					b.props.set(PLava);
				case BFTrack(_):
					b.props.set(PTrack);
				case BFContainer(_):
					b.props.set(PContainer);
				case BFAlpha(_), BFColor(_), BFDamage(_), BFSlippy, BFHeal(_), BFJump(_), BFNoOptimize:
					// nothing
				}
		}
		return blocks;
	}

}
